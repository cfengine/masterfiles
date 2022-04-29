"""
NovaApi - module to interact with CFEngine Mission Portal Enterprise API

https://docs.cfengine.com/docs/3.18/enterprise-cfengine-guide-enterprise-api.html

Examples of usage:

```python
api = NovaApi() # defaults to CFE_ROBOT user and local hub certificate
print(api.fr_remote_hubs()) # should fail with message
api = NovaApi(api_user='admin', api_password='password')
response = api.fr_remote_hubs()
for hub in response['hubs']:
  print(hub)
  print(hub['ui_name'])
print(api.query("select * from hosts"))
print(api.query("select * from __hubs")["rows"])
print(api.status())
print(api.fr_hub_status())
print(api.get("user","admin"))
print(api.put('user',"yj",{"password":"quijibo"}))
print(api.put("role","yj",{}))
print(api.put_role_permissions("yj", ["query.post"]))
```
"""

import json
import os
import socket
import sys
import urllib3

_WORKDIR = os.environ.get("WORKDIR", "/var/cfengine")
_DEFAULT_SECRETS_PATH = "{}/httpd/secrets.ini".format(_WORKDIR)


class NovaApi:
    def __init__(
        self,
        hostname=None,
        api_user="CFE_ROBOT",
        api_password=None,
        cert_path=None,
        ca_cert_dir=None,
    ):
        self._hostname = hostname or str(socket.getfqdn())
        self._api_user = api_user
        if api_password is None:
            self._api_password = self._get_robot_password()
        else:
            self._api_password = api_password
        if cert_path is None:
            self._cert_path = "{}/httpd/ssl/certs/{}.cert".format(
                _WORKDIR, socket.getfqdn()
            )
        else:
            self._cert_path = cert_path
        if ca_cert_dir is None:
            self._ca_cert_dir = os.environ.get("SSL_CERT_DIR")
        else:
            self._ca_cert_dir = ca_cert_dir

        self._http = urllib3.PoolManager(
            cert_reqs="CERT_REQUIRED",
            ca_certs=self._cert_path,
            ca_cert_dir=self._ca_cert_dir,
        )
        self._headers = urllib3.make_headers(
            basic_auth="{}:{}".format(self._api_user, self._api_password)
        )
        self._headers["Content-Type"] = "application/json"
        # In order to avoid SubjectAltNameWarning with our self-signed certs, silence it
        if not sys.warnoptions:
            import warnings

            warnings.simplefilter(
                "ignore", category=urllib3.exceptions.SubjectAltNameWarning
            )

    def __str__(self):
        return str(self.__class__) + ":" + str(self.__dict__)

    def _get_robot_password(self):
        with open(_DEFAULT_SECRETS_PATH) as file:
            for line in file:
                if "cf_robot_password" in line:
                    tokens = line.split("=")
                    if len(tokens) == 2:
                        return tokens[1].strip()
        raise Exception(
            "Could not parse CFE_ROBOT password from {} file".format(
                _DEFAULT_SECRETS_PATH
            )
        )

    def _request(self, method, path, body=None):
        url = "https://{}/api/{}".format(self._hostname, path)
        if type(body) is not str:
            payload = json.JSONEncoder().encode(body)
        else:
            payload = body
        response = self._http.request(method, url, headers=self._headers, body=payload)
        return self._build_response(response)

    def _build_response(self, response):
        if response.status != 200:
            value = {}
            message = response.data.decode("utf-8").strip()
            if not message:
                if response.status == 201:
                    message = "Created"
            value["message"] = message
            value["status"] = response.status
        else:
            data = json.loads(response.data.decode("utf-8"))
            # some APIs like query API return a top-level data key which we want to skip for ease of use
            if "data" in data:
                # data response e.g. query API returns top-level key 'data'
                # which has a value of a list with one entry containing
                # the information.
                # see https://docs.cfengine.com/docs/master/reference-enterprise-api-ref-query.html#execute-sql-query
                value = data["data"][0]
                value["meta"] = data["meta"]
            else:
                value = data if type(data) is dict else {}
            value["status"] = response.status
        return value

    def query(self, sql):
        clean_sql = sql.replace("\n", " ").strip()
        return self._request(
            "POST",
            "query",
            body="""
           {{ "query": "{}" }}""".format(
                clean_sql
            ),
        )

    def status(self):
        return self._request("GET", "")

    def fr_remote_hubs(self):
        response = self._request("GET", "fr/remote-hub")
        values = {}
        values["hubs"] = [
            response[key] for key in response if type(response[key]) is dict
        ]
        values["status"] = response["status"]
        return values

    def fr_hub_status(self):
        return self._request("GET", "fr/hub-status")

    def fr_enable_as_superhub(self):
        return self._request("POST", "fr/setup-hub/superhub")

    def fr_enable_as_feeder(self):
        return self._request("POST", "fr/setup-hub/feeder")

    def get(self, entity, identifier):
        return self._request("GET", "{}/{}".format(entity, identifier))

    def put(self, entity, identifier, data):
        return self._request("PUT", "{}/{}".format(entity, identifier), data)

    def delete(self, entity, identifier):
        return self._request("DELETE", "{}/{}".format(entity, identifier))

    def put_role_permissions(self, identifier, data):
        return self._request("PUT", "role/{}/permissions".format(identifier), data)

#!/usr/bin/env python3
"""
fr_distributed_cleanup.py - a script to remove hosts which have migrated to
other feeder hubs. To be run on Federated Reporting superhub
after each import of feeder data.

First, to setup, enable fr_distributed_cleanup by setting a class in augments (def.json).
This enables policy in cfe_internal/enterprise/federation/federation.cf

```json
{
  "classes": {
    "cfengine_mp_fr_enable_distributed_cleanup": [ "any::" ]
  }
}
```

After the policy has run on superhub and feeders, run this script
to setup fr_distributed_cleanup role and account on all feeders and superhubs with
proper RBAC settings for normal operation.
You will be prompted for superhub admin credentials and then
admin credentials on each feeder.
"""

import argparse
import logging
import os
import socket
import string
import random
import subprocess
import sys
from getpass import getpass
from nova_api import NovaApi
from cfsecret import read_secret, write_secret

WORKDIR = None
CFE_FR_TABLES = None
# get WORKDIR and CFE_FR_TABLES from config.sh
config_sh_path = os.path.join(os.path.dirname(__file__), "config.sh")
cmd = "source {}; echo $WORKDIR; echo $CFE_FR_TABLES".format(config_sh_path)
with subprocess.Popen(
    cmd, stdout=subprocess.PIPE, shell=True, executable="/bin/bash"
) as proc:
    lines = proc.stdout.readlines()
    WORKDIR = lines[0].decode().strip()
    CFE_FR_TABLES = [table.strip() for table in lines[1].decode().split()]

if not WORKDIR or not CFE_FR_TABLES:
    print("Unable to get WORKDIR and CFE_FR_TABLES values from config.sh")
    sys.exit(1)

# Primary dir in which to place various needed files
DISTRIBUTED_CLEANUP_DIR = "/opt/cfengine/federation/cftransport/distributed_cleanup"

# collect cert files from /var/cfengine/httpd/ssl/certs on
# superhub and feeders and cat all together into hubs.cert
CERT_PATH = os.path.join(DISTRIBUTED_CLEANUP_DIR, "hubs.cert")

# Note: remove the file at DISTRIBUTED_CLEANUP_SECRET_PATH to reset everything.
# api calls will overwrite fr_distributed_cleanup user and role on superhub and all feeders.
DISTRIBUTED_CLEANUP_SECRET_PATH = os.path.join(
    WORKDIR, "state/fr_distributed_cleanup.cfsecret"
)


def interactive_setup_feeder(hub, email, fr_distributed_cleanup_password, force_interactive=False):
    if force_interactive:
        feeder_credentials = input(
            "admin credentials for {}: ".format(
                hub["ui_name"]
            )
        )
        print() # output newline for easier reading
    else:
        feeder_credentials = getpass(
            prompt="Enter admin credentials for {}: ".format(
                hub["ui_name"]
            )
        )
    feeder_hostname = hub["ui_name"]
    feeder_api = NovaApi(
        api_user="admin",
        api_password=feeder_credentials,
        cert_path=CERT_PATH,
        hostname=feeder_hostname,
    )

    logger.info("Creating fr_distributed_cleanup role on %s", feeder_hostname)
    response = feeder_api.put(
        "role",
        "fr_distributed_cleanup",
        {
            "description": "fr_distributed_cleanup Federated Host Cleanup role",
            "includeContext": "cfengine_3",
        },
    )
    if response["status"] != 201:
        print(
            "Problem creating fr_distributed_cleanup role on superhub. {}".format(
                response
            )
        )
        sys.exit(1)
    response = feeder_api.put_role_permissions(
        "fr_distributed_cleanup", ["host.delete"]
    )
    if response["status"] != 201:
        print("Unable to set RBAC permissions on role fr_distributed_cleanup")
        sys.exit(1)
    logger.info("Creating fr_distributed_cleanup user on %s", feeder_hostname)
    response = feeder_api.put(
        "user",
        "fr_distributed_cleanup",
        {
            "description": "fr_distributed_cleanup Federated Host Cleanup user",
            "email": "{}".format(email),
            "password": "{}".format(fr_distributed_cleanup_password),
            "roles": ["fr_distributed_cleanup"],
        },
    )
    if response["status"] != 201:
        print(
            "Problem creating fr_distributed_cleanup user on {}. {}".format(
                feeder_hostname, response
            )
        )
        sys.exit(1)


def interactive_setup(force_interactive=False):
    fr_distributed_cleanup_password = "".join(random.choices(string.digits + string.ascii_letters, k=20))
    if force_interactive:
        admin_pass = input("admin password for superhub {}: ".format(socket.getfqdn()))
        print() # newline for easier reading
    else:
        admin_pass = getpass(
            prompt="Enter admin password for superhub {}: ".format(socket.getfqdn())
        )

    api = NovaApi(api_user="admin", api_password=admin_pass)

    # first confirm that this host is a superhub
    status = api.fr_hub_status()
    if (
        status["status"] == 200
        and status["role"] == "superhub"
        and status["configured"]
    ):
        logger.debug("This host is a superhub configured for Federated Reporting.")
    else:
        if status["status"] == 401:
            print("admin credentials are incorrect, try again")
            sys.exit(1)
        else:
            print(
                "Check the status to ensure role is superhub and configured is True. {}".format(
                    status
                )
            )
            sys.exit(1)

    feederResponse = api.fr_remote_hubs()
    if not feederResponse["hubs"]:
        print(
            "No attached feeders. Please attach at least one feeder hub before running this script."
        )
        sys.exit(1)

    email = input("Enter email for fr_distributed_cleanup accounts: ")
    print() # newline for easier reading

    logger.info("Creating fr_distributed_cleanup role on superhub...")
    response = api.put(
        "role",
        "fr_distributed_cleanup",
        {
            "description": "fr_distributed_cleanup Federated Host Cleanup role",
            "includeContext": "cfengine_3",
        },
    )
    if response["status"] != 201:
        print(
            "Problem creating fr_distributed_cleanup role on superhub. {}".format(
                response
            )
        )
        sys.exit(1)
    response = api.put_role_permissions(
        "fr_distributed_cleanup", ["query.post", "remoteHub.list", "hubStatus.get"]
    )
    if response["status"] != 201:
        print("Unable to set RBAC permissions on role fr_distributed_cleanup")
        sys.exit(1)
    logger.info("Creating fr_distributed_cleanup user on superhub")
    response = api.put(
        "user",
        "fr_distributed_cleanup",
        {
            "description": "fr_distributed_cleanup Federated Host Cleanup user",
            "email": "{}".format(email),
            "password": "{}".format(fr_distributed_cleanup_password),
            "roles": ["fr_distributed_cleanup"],
        },
    )
    if response["status"] != 201:
        print(
            "Problem creating fr_distributed_cleanup user on superhub. {}".format(
                response
            )
        )
        sys.exit(1)

    for hub in feederResponse["hubs"]:
        interactive_setup_feeder(hub, email, fr_distributed_cleanup_password, force_interactive=force_interactive)
        write_secret(DISTRIBUTED_CLEANUP_SECRET_PATH, fr_distributed_cleanup_password)


def main():
    if not os.geteuid() == 0:
        sys.exit("\n{} must be run as root".format(os.path.basename(__file__)))

    parser = argparse.ArgumentParser(
        description="Clean up migrating clients in Federated Reporting setup"
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--debug", action="store_true")
    group.add_argument("--inform", action="store_true")

    parser.add_argument("--force-interactive", action="store_true", help="force interactive mode even when no tty, good for automation")
    args = parser.parse_args()

    global logger
    logger = logging.getLogger("fr_distributed_cleanup")
    ch = logging.StreamHandler()
    if args.debug:
        logger.setLevel(logging.DEBUG)
        ch.setLevel(logging.DEBUG)
    if args.inform:
        logger.setLevel(logging.INFO)
        ch.setLevel(logging.INFO)
    logger.addHandler(ch)

    if not os.path.exists(DISTRIBUTED_CLEANUP_SECRET_PATH):
        if sys.stdout.isatty() or args.force_interactive:
            interactive_setup(force_interactive=args.force_interactive)
        else:
            print(
                "{} requires manual setup, please run as root interactively.".format(
                    os.path.basename(__file__)
                )
            )
            sys.exit(1)

    fr_distributed_cleanup_password = read_secret(DISTRIBUTED_CLEANUP_SECRET_PATH)
    api = NovaApi(
        api_user="fr_distributed_cleanup", api_password=fr_distributed_cleanup_password
    )  # defaults to localhost
    response = api.fr_hub_status()
    if not (
        response["status"] == 200
        and response["role"] == "superhub"
        and response["configured"]
    ):
        print(
            "{} can only be run on a properly configured superhub. ".format(os.path.basename(__file__)) +
            " {}".format(response)
        )
        sys.exit(1)

    response = api.fr_remote_hubs()
    if not response["hubs"]:
        print(
            "No attached feeders. Please attach at least one feeder hub before running this script."
        )

    for hub in response["hubs"]:
        if hub["role"] != "feeder" or hub["target_state"] != "on":
            continue

        feeder_hostkey = hub["hostkey"]
        feeder_hostname = hub["ui_name"]
        feeder_api = NovaApi(
            api_user="fr_distributed_cleanup",
            api_password=fr_distributed_cleanup_password,
            cert_path=CERT_PATH,
            hostname=feeder_hostname,
        )
        response = feeder_api.status()
        if response["status"] == 401 and sys.stdout.isatty():
            # auth error when running interactively
            # assume it's a new feeder and offer to set it up interactively
            hub_user = api.get( "user", "fr_distributed_cleanup")
            if hub_user is None or 'email' not in hub_user:
                email = 'fr_distributed_cleanup@{}'.format(hub['ui_name'])
            else:
                email = hub_user['email']
            interactive_setup_feeder(hub, email, fr_distributed_cleanup_password)
        elif response["status"] != 200:
            print(
                "Unable to get status for feeder {}. Skipping".format(feeder_hostname)
            )
            continue

        sql = "SELECT hub_id FROM __hubs WHERE hostkey = '{}'".format(feeder_hostkey)
        response = api.query(sql)
        if response["status"] != 200:
            print("Unable to query for feeder hub_id. Response was {}".format(response))
            continue

        # query API should return one row, [0], and one column, [0], in rows value
        feeder_hubid = response["rows"][0][0]

        sql = """
SELECT DISTINCT hosts.hostkey
FROM hosts
WHERE hub_id = '{0}'
AND EXISTS(
  SELECT 1 FROM lastseenhosts ls
  JOIN (
    SELECT hostkey, max(lastseentimestamp) as newesttimestamp
    FROM lastseenhosts
    WHERE lastseendirection = 'INCOMING'
    GROUP BY hostkey
  ) as newest
  ON ls.hostkey = newest.hostkey
  AND ls.lastseentimestamp = newest.newesttimestamp
  AND ls.hostkey = hosts.hostkey
  AND ls.hub_id != '{0}'
)""".format(
            feeder_hubid
        )

        response = api.query(sql)
        if response["status"] != 200:
            print(
                "Unable to query for deletion candidates. Response was {}".format(
                    response
                )
            )
            sys.exit(1)
        logger.debug("Hosts to delete on %s are %s", hub["ui_name"], response["rows"])
        hosts_to_delete = response["rows"]
        if len(hosts_to_delete) == 0:
            logger.info("%s: No hosts to delete. No actions taken.", feeder_hostname)
            continue

        logger.debug(
            "%s host(s) to delete on feeder %s", len(hosts_to_delete), hub["ui_name"]
        )

        # build up a post-loop SQL statement to delete hosts locally from feeder schemas
        # change to feeder schema to make deletions easier/more direct without having to
        # specify hub_id in queries
        post_sql = "set schema 'hub_{}';\n".format(feeder_hubid)
        post_sql += "\\set ON_ERROR STOP on\n"
        delete_sql = ""
        post_hostkeys = []
        for row in hosts_to_delete:
            # The query API returns rows which are lists of column values.
            # We only selected hostkey so will take the first value.
            host_to_delete = row[0]

            response = feeder_api.delete("host", host_to_delete)
            # both 202 Accepted and 404 Not Found are acceptable responses
            if response["status"] not in [202, 404]:
                logger.warning(
                    "Delete %s on feeder %s got %s status code",
                    host_to_delete,
                    feeder_hostname,
                    response["status"],
                )
                continue

            # only add the host_to_delete if it was successfully deleted on the feeder
            post_hostkeys.append(host_to_delete)

        if len(post_hostkeys) == 0:
            logger.info(
                "No hosts on feeder %s need processing on superhub so skipping post processing",
                feeder_hostname,
            )
            continue

        # simulate the host api delete process by setting current_timestamp in deleted column
        # and delete from all federated tables similar to the clear_hosts_references() pgplsql function.
        post_sql += "INSERT INTO __hosts (hostkey,deleted) VALUES"
        deletes = []
        for hostkey in post_hostkeys:
            deletes.append("('{}', CURRENT_TIMESTAMP)".format(hostkey))

        delete_sql = ", ".join(deletes)
        delete_sql += (
            " ON CONFLICT (hostkey,hub_id) DO UPDATE SET deleted = excluded.deleted;\n"
        )
        clear_sql = "set schema 'public';\n"
        for table in CFE_FR_TABLES:
            # special case of partitioning, operating on parent table will work
            if "__promiselog_*" in table:
                table = "__promiselog"
            clear_sql += (
                "DELETE FROM {} WHERE hub_id = {} AND hostkey IN ({});\n".format(
                    table,
                    feeder_hubid,
                    ",".join(["'{}'".format(hk) for hk in post_hostkeys]),
                )
            )
        post_sql += delete_sql + clear_sql

        logger.debug("Running SQL:\n%s", post_sql)
        with subprocess.Popen(
            ["/var/cfengine/bin/psql", "cfdb"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ) as proc:
            logger.debug("got a proc, sending sql...")
            outs, errs = proc.communicate(input=post_sql.encode())
            if "ERROR" in errs.decode("utf-8"):
                print(
                    "Problem running post processing SQL. returncode was {}, stderr:\n{}\nstdout:\n{}".format(
                        proc.returncode, errs.decode("utf-8"), outs.decode("utf-8")
                    )
                )
                sys.exit(1)

            logger.debug(
                "Ran post processing SQL. returncode was %s, stderr:\n%s\nstdout:\n%s",
                proc.returncode,
                errs.decode("utf-8"),
                outs.decode("utf-8"),
            )

        if len(hosts_to_delete) != 0:
            logger.info(
                "%s: %s host deletions processed",
                hub["ui_name"],
                len(hosts_to_delete),
            )


if __name__ == "__main__":
    main()
else:
    raise ImportError("fr_distributed_cleanup.py must only be used as a script!")

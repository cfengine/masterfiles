The Masterfiles Policy Framework is the default policy
that ships with both the CFEngine Enterprise and
Community editions. The MPF includes policy to manage
cfengine itself, the stdlib, and policy to inventory
various aspects of the system.

# Overview

* `update.cf` - The update policy entry.
* `promises.cf` - The main policy entry.
* `lib/` - The standard library.
* `inventory/` - Inventory policy.
* `services` - User defined custom policy.
* `services/main.cf` - Contains an empty bundle agent main where custom policy
  can be integrated.
* `services/autorun/` - Automatically included policy files.
* `.no-distrib/` - A directory that is excluded from policy updates from remote agents.

The MPF is continually updated. You can track its development
on [github](https://github.com/cfengine/masterfiles/).

# Configuration

The most common controls reference variables in the ```def``` bundle in order to
keep the modifications to the distributed policy contained within a single
place. The recommended way to set classes and define variables in the ```def```
bundle is using an [augments file][Augments]. Keeping the modifications to the
distributed policy set makes policy framework upgrades significantly easier.

Note: If you need to make modification to a shipped file consider opening a pull
request to expose the tunable into the ```def``` bundle.

**Note:** `controls/def.cf` contains the defaults and settings for `promises.cf`
and `controls/update_def.cf` contains the defaults and settings for `update.cf`.

Since 3.7.8, 3.10.4, and 3.12.0 The class `cf_runagent_initated` is defined by
default in the MPF for agent executions initiated by `cf-runagent` through
`cf-serverd`. Previously the class `cfruncommand` was defined. See `body server
control cfruncommand` in `controls/cf_serverd.cf`.

## Update Policy (update.cf)

Synchronizing clients with the policy server happens here, in
`update.cf`. Its main job is to copy all the files on the policy
server (usually the hub) under `$(sys.masterdir)` (usually
`/var/cfengine/masterfiles`) to the local host into `$(sys.inputdir)`
(usually `/var/cfengine/inputs`).

This file should rarely if ever change. Should you ever change it (or
when you upgrade CFEngine), take special care to ensure the old and
the new CFEngine can parse and execute this file successfully. If not,
you risk losing control of your system (that is, **if CFEngine cannot
successfully execute `update.cf`, it has no mechanism for distributing
new policy files**).

By default, the policy defined in update.cf is executed at the
beginning of a `cf-execd` scheduled agent run (see `schedule` and
`exec_command` as defined in `body executor control` in
`controls/cf_execd.cf`). When the update policy completes
(regardless of success or failure) the policy defined in `promises.cf`
is activated.

This is a standalone policy file. You can actually run it with
`cf-agent -KI -f ./update.cf` but if you don't understand what that
command does, please hold off until you've gone through the CFEngine
documentation. The contents of `update.cf` duplicate other things
under `lib` sometimes, in order to be completely standalone.

To repeat, when `update.cf` is broken, things go bonkers. CFEngine
will try to run a backup `failsafe.cf` you can find in the C core
under `libpromises/failsafe.cf` (that `.cf` file is written into the C
code and can't be modified). If things get to that point, you probably
have to look at why corrupted policies made it into production.

As is typical for CFEngine, the policy and the configuration are mixed. In
`controls/update_def.cf` you'll find some very useful settings. Keep referring
to `controls/update_def.cf` as you read this. We are skipping the nonessential
ones.

### Configure upstream masterfiles location for policy update

Want to get your policy from a place other than `/var/cfengine/masterfiles` on
`sys.policy_hub`?

With an augments like this:

```
{
  "vars": {
            "house": "Gryffindor",
            "mpf_update_policy_master_location": "/srv/cfengine/$(sys.flavor)/$(def.house)"
          }
}
```

A CentOS 7 host would copy policy from `/srv/cfengine/centos_6/Gryffindor` to
`$(sys.inputdir)` (commonly `/var/cfengine/inputs`).

**History:**

- Introduced in 3.12.0.

### Append to inputs used by update policy

You can append to the inputs used by the update policy via augments by defining
```vars.update_inputs```. The following example will add the policy file
```my_updatebundle1.cf``` to the list of policy file inputs during the update policy.


```json
{
  "vars":{
    "update_inputs": [ "my_updatebundle1.cf" ]
  }
}
```

### Append to the update bundlesequence

You can specify bundles which should be run at the end of the default update
policy bundlesequence by defining ```control_common_update_bundlesequence_end```
in the vars of an [augments file][Augments].

For example:

```json
{
  "vars":{
    "control_common_update_bundlesequence_end": [ "my_updatebundle1", "mybundle2" ]
  }
}
```

**Notes:**

* The order in which bundles are actuates is not guaranteed.
* The agent will error if a named bundle is not part of inputs.

### Specify the agent bundle used for policy update

The MPF uses `cfe_internal_update_policy_cpv` to update inputs and modules on
remote agents. When new policy is verified by the agent
`/var/cfengine/masterfiles/cf_promises_validated` is updated with the current
timestamp. This file is used by remote agents to avoid unnecessary inspection of
all files each time the update policy is triggered.

Override this bundle by setting `def.mpf_update_policy_bundle` via augments:

```
{
    "vars": {
        "mpf_update_policy_bundle": "MyCustomPolicyUpdateBundle"
    }
}
```

**History:**

- Introduced in 3.12.0

#### ignore_missing_bundles

This option allows you to ignore errors when a bundle specified in body common control bundlesequence is not found.

This example illustrates enabling the option via augments.

```
{
  "vars": {
    "control_common_ignore_missing_bundles": "true"
  }
}
```

**NOTE:** The same augments key is used for both `update.cf` and `promsies.cf` entries.

**History:**

- Introduced in 3.12.0

#### ignore_missing_inputs

This option allows you to ignore errors when a file specified in body common control inputs is not found.

This example illustrates enabling the option via augments.

```
{
  "vars": {
    "control_common_ignore_missing_inputs": "true"
  }
}
```

**NOTE:** The same augments key is used for both `update.cf` and `promsies.cf` entries.

**History:**

- Introduced in 3.12.0

### Verify update transfers

Enable additional verrification after file transfers during policy update by
defining the class ```cfengine_internal_verify_update_transfers```. When this
class is defined, the update policy will hash the transfered file and compare it
against the hash given by the server

This [augments file][Augments] will enable this behavior for all clients.

```
{
  "classes": {
    "cfengine_internal_verify_update_transfers": [ "any" ]
  }
}
```

### Encrypted transfers

**Note:** When using protocol version 2 or greater all communications are
encapsulated within a TLS session. This configuration option is only relevant
for clients using protocol version 1 (default for versions 3.6 and prior).

To enable encryption during policy updates define the class
```cfengine_internal_encrypt_transfers```.

### Preserve permissions

By default the MPF does not *enforce* permissions of *inputs*. When
*masterfiles* are copied to *inputs*, new files are created with default
restrictive permissions. If the class
```cfengine_internal_preserve_permissions``` is defined the permissions of the
policy server's masterfiles will be preserved when they are copied.

### Enable CFEngine Enterprise HA

When the ```enable_cfengine_enterprise_hub_ha``` class is defined the policy to
manage High Availability of Enterprise Hubs is enabled.

**Note:** This class is **not** defined by default.

### Disable plain http for CFEngine Enterprise Mission Portal

By default Mission Portal listens for HTTP requests on port 80, redirecting to HTTPS on port 443. To prevent the web server from listening on port 80 at all define `default:cfe_cfengine_enterprise_disable_plain_http`.

**For example:**

```json
{
  "classes": {
    "default:cfe_enterprise_disable_plain_http": {
      "class_expressions": [ "am_policy_hub|policy_server::" ]
    }
  }
}
```

**History:**

- Added in CFEngine 3.23.0

### Disable cf\_promises\_validated check

For non policy hubs the default update policy only performs a full scan of
masterfiles if ```cf_promises_validated``` is repaired. This repair indicates
that the hub has validated new policy that the client needs to refresh.

To disable this check define the
```cfengine_internal_disable_cf_promises_validated``` class.

It not recommended to disable this check as it both removes a safety mechanism
that checks for policy to be valid before allowing clients to download updates,
and the increased load on the hub will affect scalability.

If you want to periodically perform a full scan consider adding custom policy to
simply remove ```$(sys.inputdir)/cf_promises_validated```. This will cause the
file to be repaired during the next update run triggering a full scan.

### Disable automatically removing files not present upstream (SYNC masterfiles)

By default, the MPF will keep inputdir in sync with masterfiles on the hub. If
the class ```cfengine_internal_purge_policies_disabled``` is defined the update
behavior will only keep files that exist on the remote up to date locally, files
that exist locally that do not exist upstream will be left behind. Note, if this
is disabled and a policy file that is dynamically loaded based on it's presence
is renamed, duplicate definition errors may occur, preventing policy execution.

This [augments file][Augments] will enable this behavior for all clients.

```
{
  "classes": {
    "cfengine_internal_purge_policies_disabled": [ "any" ]
  }
}
```

**History:**

- Introduced in 3.18.0, previously, the default behavior was opposite and the class `cfengine_internal_purge_policies`  had to be enabled to keep inputs in sync with masterfiles.

### Disable limiting robot agents

By default the MPF (Masterfiles Policy Framework) contains active policy that is intended to remediate a pathological condition where multiple agent component daemons (like cf-execd) are running concurrently.

Define the class ```mpf_disable_cfe_internal_limit_robot_agents``` to disable this automatic remediation.

```json
{
  "classes": {
    "mpf_disable_cfe_internal_limit_robot_agents": [ "any" ]
  }
}
```

**History:**

- Introduced in 3.15.0, 3.12.3, 3.10.7

### Automatically deploy masterfiles from Version Control

On a CFEngine Enterprise Hub during the update policy if the class
```cfengine_internal_masterfiles_update``` is defined masterfiles will be
automatically deployed from an upstream version control repository using
the
[settings defined via Mission Portal][Best Practices#Version Control and Configuration Policy] or
directly in ```/opt/cfengine/dc-scripts```.

**Note:** Any policy in the distribution location (/var/cfengine/masterfiles)
will be deleted the first time this tooling runs. Be wary of local modifications
before enabling.

### Policy Analyzer Exclude Files

When the policy analyzer is enabled, a copy of the policy is made available for viewing from Mission Portal. To exclude files from this view you can define ```def.cfengine_enterprise_policy_analyzer_exclude_files``` as a list of regular expressions matching files that you do not want to be viewable from Policy Analyzer.

This [augments file][Augments] will prevent any files named `please-no-copy` and any file names that contain `no-copy-me` from being copied and visible from Policy Analyzer.

```json
{
  "vars": {
    "cfengine_enterprise_policy_analyzer_exclude_files": [ "please-no-copy", ".*no-copy-me.*" ]
  },
}
```

**History:**

* Added in 3.19.0, 3.18.1

### Policy Permissions

By default the policy enforces permissions of ```0600``` meaning that inputs are
only readable by their owner. If you are distributing scripts with your
masterfiles, be sure there is a policy to ensure they are executable when you
expect them to be.

### Agent binary upgrades

Remote agents can upgrade their own binaries using the built in binary upgrade
policy. Packages must be placed in `/var/cfengine/master_software_updates` in
the appropriate platform directory. Clients will automatically download and
install packages when the ```trigger_upgrade``` class is defined during a run of
`update.cf`.


This [augments file][Augments] will defines `trigger_upgrade` on hosts with IPv4 addresses in 192.0.2.0/24 or 203.0.113.0/24 or hosts that have a cfengine 3.10 class not for cfengine 3.10.2.

```json
{
   "classes": {
    "trigger_upgrade": [
      "ipv4_10_10_1",
      "ipv4_10_10_2",
      "cfengine_3_10_(?!2$)\\d+"
    ]
   }
}
```

**Notes:**

- This policy is specific to CFEngine Enterprise.
- The negative look ahead regular expression is useful because it automatically
  turns off on hosts after they reach the target version.

#### Configure path that software is served from for autonomous agent upgrades

{% comment %}ENT-4953{% endcomment %}
`def.master_software_updates` defines the path that cfengine policy servers
share software updates from. Remote agents access this path via the
`master_software_updates` *shortcut*. By default this path is
`$(sys.workdir)/master_software_updates`. This path can be overridden via
`vars.dir_master_software_updates` in augments.

For example:

```json
{
   "vars": {
     "dir_master_software_updates": "/srv/cfengine-software-updates/"
   }
}
```

**History:**
- Introduced 3.15.0, 3.12.3, 3.10.8

#### Disable seeding binaries on hub

By default when `trigger_upgrade` is defined on a hub, the hub will download
packages for agents to use during self upgrade. This automatic download behavior
is disabled when the class `mpf_disable_hub_masterfiles_software_update_seed` is
defined.

For example:

```json
{
   "classes": {
     "mpf_disable_hub_masterfiles_software_update_seed": [ "policy_server::" ]
   }
}
```

**History:**

- Introduced 3.19.0, 3.18.1

### Files considered for copy during policy updates

The default update policy only copies files that match regular expressions
listed in ```def.input_name_patterns```.

This [augments file][Augments] ensures that only files ending in ```.cf```, ```.dat```,
```.mustache```, ```.json```, ```.yaml``` and the file
```cf_promises_release_id``` will be considered by the default update policy.

```
{
    "vars": {
        "input_name_patterns": [ ".*\\.cf", ".*\\.dat", ".*\\.txt", ".*\\.conf",
            ".*\\.mustache", ".*\\.sh", ".*\\.pl", ".*\\.py", ".*\\.rb",
            ".*\\.sed", ".*\\.awk", "cf_promises_release_id", ".*\\.json",
            ".*\\.yaml", ".*\\.csv" ]
    }
}
```

**Note:** This filter does **not** apply to bootstrap operations. During
bootstrap the
embedded
[failsafe policy](https://github.com/cfengine/core/blob/master/libpromises/failsafe.cf) is
used and it decides which files should be copied.

### Configuring component management

The Masterfiles Policy Framework ships with policy to manage the components of CFEngine.

By default, for hosts without systemd, this policy defaults to ensuring that components are running.

On systemd hosts, the policy to manage component units is disabled by default.

#### Enable management of components on systemd hosts

To allow the Masterfiles Policy Framework to actively manage cfengine systemd units and state define the `mpf_enable_cfengine_systemd_component_management`.

This example illustrates enabling management of components on systemd hosts having a class matching `redhat_8` via augments.

```json
{
  "classes": {
    "mpf_enable_cfengine_systemd_component_management": [ "redhat_8" ]
  }
}
```

When enabled, the policy will render systemd unit files in `/etc/systemd/system` for managed services. Mustache templates for service units are in the *templates* directory in the root of the Masterfiles Policy Framework.

When enabled, the policy will make sure that all units are enabled, unless they have been disabled by a persistent class or are explicitly listed as an agent to be disabled.

#### Enable or disable CFEngine components

##### Using persistent classes
###### persistent\_disable\_*DAEMON*

**Description:** Disable a CFEngine Enterprise daemon component persistently.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This will stop the AGENT from starting automatically.

This [augments file][Augments] will ensure that `cf-monitord` is disabled on hosts that have
`server1` or the `redhat` class defined.

```
{
  "classes": {
    "persistent_disable_cf_monitord": [ "server1", "redhat" ]
  }
}
```

###### clear_persistent\_disable\_*DAEMON*

**Description:** Re-enable a previously disabled CFEngine Enterprise daemon
component.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This [augments file][Augments] will ensure that `cf-monitord` is not disabled on `redhat`
hosts.

```
{
  "classes": {
    "clear_persistent_disable_cf_monitord": [ "redhat" ]
  }
}
```

##### Using augments
##### agents_to_be_disabled

**Description:** list of agents to disable.

This [augments file][Augments] is a way to specify that `cf-monitord` should be disabled on all hosts.

```
{
  "vars": {
    "agents_to_be_disabled": [ "cf-monitord" ]
  }
}
```

## Main Policy (promises.cf)

The following settings are defined in `controls/def.cf` can be set from an
[augments file][Augments].

### dmidecode inventory

When dmidecode is present, some key system attributes are inventoried. The
inventoried attributes can be overridden by defining
`def.cfe_autorun_inventory_demidecode[dmidefs]` via augments. dmidecode queries
each key in dmidefs and tags the result with the value prefixed with
`attribute_name=` Note, as the dmidefs are overridden, you must supply all
desired inventory attributes.

For example:

```json
{
  "vars": {
    "cfe_autorun_inventory_dmidecode": {
      "dmidefs": {
        "bios-vendor": "BIOS vendor",
        "bios-version": "BIOS version",
        "system-serial-number": "System serial number",
        "system-manufacturer": "System manufacturer",
        "system-version": "System version",
        "system-product-name": "System product name",
        "bios-release-date": "BIOS release date",
        "chassis-serial-number": "Chassis serial number",
        "chassis-asset-tag": "Chassis asset tag",
        "baseboard-asset-tag": "Baseboard asset tag"
      }
    }
  }
}
```

**History:**
- Introduced 3.13.0, 3.12.1, 3.10.5

### Configure proc inventory

By default the MPF inventories `consoles`, `cpuinfo`, `modules`, `partitions`, and `version` from `/proc`.
This can be adjusted by defining `default:cfe_autorun_inventory_proc.basefiles`.

For example:

```json
{
  "variables": {
    "default:cfe_autorun_inventory_proc.basefiles": {
      "value": [
        "consoles",
        "cpuinfo",
        "version"
      ],
      "comment": "We do not need the extra variables this produces since we get the info differently",
      "tags": [
        "Custom override MPF default"
      ]
    }
  }
}
```

**History:**

* Added 3.21.0

### Configure cf-agent syslog facility

To configure the syslog facility used by `cf-agent` configure `agentfacility` by
setting `default:def.control_agent_agentfacility` via augments to one of the
allowed values (`LOG_USER`, `LOG_DAEMON`, `LOG_LOCAL0`, `LOG_LOCAL1`,
`LOG_LOCAL2`, `LOG_LOCAL3`, `LOG_LOCAL4`, `LOG_LOCAL5`, `LOG_LOCAL6`,
`LOG_LOCAL7`)

```json
{
  "variables": {
    "default:def.control_agent_agentfacility": {
      "value": "LOG_USER"
    }
  }
}
```

**History:**

* Added in 3.22.0, 3.21.2

### mailto

The address that `cf-execd` should email agent output to.

### mailfrom

The address that output mailed from `cf-execd` should come from.

### smtpserver

The SMTP server that `cf-execd` should use to send emails.

### mailmaxlines

The maximumm number of lines of output that `cf-execd` will email.

**History:**

* Added in CFEngine 3.22.0, 3.21.1, 3.18.4

**See also:** [`maxmaillines`][cf-execd#maxmaillines]

### Configure subject for emails sent by cf-execd

When enabled `cf-execd` emails output that differs from previous executions. The subject of the email can be configured by setting `mailsubject` in `body executor control`. This will use the value of `default:def.control_executor_mailsubject` if it is a non-empty string.

```json
{
  "variables": {
    "default:def.control_executor_mailsubject": {
        "value": "CFEngine output from $(sys.fqhost)"
    }
  }
}
```

**History:**

* Added in 3.22.0, 3.21.2
### Configure lines that should be excluded from emails sent by cf-execd

When enabled `cf-execd` emails output that differs from previous executions.
Lines matching regular expressions in `mailfilter_exclude` in `body executor
control` are stripped before sending. The MPF will use the value of
`default:def.control_executor_mailfilter_exclude` if it is a non-empty list.

```json
{
  "variables": {
    "default:def.control_executor_mailfilter_exclude": {
        "value": [ ".*ps output line.*", ".*regline.*" ]
    }
  }
}
```

**History:**

* Added in 3.22.0, 3.21.2

### Configure lines that should be included from emails sent by cf-execd

When enabled `cf-execd` emails output that differs from previous executions.
Lines matching regular expressions in `mailfilter_include` in `body executor
control` are stripped before sending. The MPF will use the value of
`default:def.control_executor_mailfilter_include` if it is a non-empty list.

```json
{
  "variables": {
    "default:def.control_executor_mailfilter_include": {
        "value": [ ".*EMAIL.*" ]
    }
  }
}
```

**History:**

* Added in 3.22.0, 3.21.2

### acl

`def.acl` is a list of of network ranges that should be allowed to connect to cf-serverd. It is also used in the default access promises to allow hosts access to policy and modules that should be distributed.

Here is an example setting the acl from augments:

```
{
  "vars": {
    "acl": [ "24.124.0.0/16", "192.168.33.0/24" ]
  }
}
```

**See Also:** [Configure networks allowed to make collect calls (client initiated reporting)](#configure-networks-allowed-to-make-collect_calls-client-initiated-reporting)

### Configure hosts that may connect to cf-serverd

`allowconnects` is a list of IP addresses or subnets in `body server control` which restricts hosts that are allowed to connect to `cf-serverd`. This is the first layer of access control in `cf-serverd`, a client coming from a host not covered by this list will not be able to connect to `cf-serverd` at all.

In the MPF this defaults to include localhost and the value defined for `default:def.acl`.

`allowconnects` can be customized by configuring `default:def.control_server_allowconnects` via Augments. Note, this will *overwrite* the default value which includes `127.0.0.1` , `::1`, and `@(def.acl)` that you may want to include.

For example, this configuration allows any IPv4 client to connect to `cf-serverd`.

```json
{
  "variables": {
    "default:def.allowconnects": {
      "value": [
        "0.0.0.0/0"
      ]
    }
  }
}
```

**History:**

* Added in 3.22.0

### Configure hosts that may make multiple concurrent connections to cf-serverd

`allowallconnects` is a list of IP addresses or subnets in `body server control` specifying hosts that are allowed to have more than one connection to `cf-serverd`.

In the MPF this defaults to include localhost and the value defined for `default:def.acl`.

`allowallconnects` can be customized by configuring `default:def.control_server_allowallconnects` via Augments.

For example, this configuration allows any IPv4 client from the `192.168.56.0/24` subnet to have multiple concurrent connections to `cf-serverd`.


```json
{
  "variables": {
    "default:def.allowallconnects": {
      "value": [
        "192.168.56.0/24"
      ]
    }
  }
}
```

**History:**

* Added in 3.22.0

### ignore_missing_bundles

This option allows you to ignore errors when a bundle specified in body common control bundlesequence is not found.

This example illustrates enabling the option via augments.

```
{
  "vars": {
    "control_common_ignore_missing_bundles": "true"
  }
}
```

**NOTE:** The same augments key is used for both `update.cf` and `promises.cf` entries.

**History:**

- Introduced in 3.12.0

### ignore_missing_inputs

This option allows you to ignore errors when a file specified in body common control inputs is not found.

This example illustrates enabling the option via augments.

```
{
  "vars": {
    "control_common_ignore_missing_inputs": "true"
  }
}
```

**NOTE:** The same augments key is used for both `update.cf` and `promises.cf` entries.

**History:**

- Introduced in 3.12.0

### trustkeysfrom

The list of network ranges that `cf-serverd` should trust keys from. This is
should only be open on policy servers while new hosts are expected to be
bootstrapped. It should be empty after your hosts have been bootstrapped to
avoid unwanted hosts from being able to bootstrap.

By default the MPF configures `cf-serverd` to trust keys from any host. This is
convenient for simplified bootstrapping. After initial deployment it is
recommended that this setting be reviewed and adjusted appropriately according
to the needs of your infrastructure.

The [augments][Augments] file (```def.json```) can be used to override the
default setting. For example it can be restricted to ```127.0.0.1``` to prevent
keys from any foreign host from being automatically accepted.

```
{
  "vars": {
    "trustkeysfrom": [ "127.0.0.1" ]
    }
}
```

Prevent automatic trust for any host by specifying an empty value:

```
{
  "vars": {
    "trustkeysfrom": [ "" ]
    }
}
```
### Append to inputs used by main policy

The `inputs` key in augments can be used to add additional custom policy files.

**See Also:** [Append to inputs used by update policy][Append to inputs used by update policy]

**History:**

* Introduced in CFEngine 3.7.3, 3.12.0

### services\_autorun

See the documentation in [services/autorun][mpf-services-autorun].

### postgresql\_full\_maintenance

On CFEngine Enterprise policy hubs this class is defined by default on Sundays
at 2am. To adjust when postgres maintenance operations run edit
`controls/def.cf` directly.

### postgresql\_vacuum

On CFEngine Enterprise policy hubs this class is defined by default at 2am when
```postgresql_maintenance_supported``` is defined except for Sundays.

To adjust when postgres maintenance operations run edit `controls/def.cf`
directly.

### enable_cfengine_enterprise_hub_ha

Set this class when you want to enable the CFEngine Enterprise HA policies.

This class can be defined by an [augments file][Augments]. For example:

```
{
  "classes" {
    "enable_cfengine_enterprise_hub_ha": [ "hub001" ]
  }
}
```

### enable\_cfe\_internal\_cleanup\_agent\_reports

This class enables policy that cleans up report diffs when they exceed
`def.max_client_history_size`. By default is is **off** unless a CFEngine
Enterprise agent is detected.

### Configure splaytime

`splaytime` is the maximum number of minutes `exec_commad` should wait before executing.

Note: `splaytime` should be less than the scheduled interval plus agent run time. So for example if your agent run time is over 1 minute and you are running the default execution schedule of 5 mintues your splay time should be set to 3.

Configure it via augments by defining ```control_executor_splaytime```:

```
{
  "vars": {
    "control_executor_splaytime": "3"
  }
}
```

### Configure agent expiration

cf-agents spawned by cf-execd are killed after this number of minutes of not returning data.

Example configuration via augments:

```
{
  "vars": {
    "control_executor_agent_expireafter": "15"
  }
}
```

### Configure agent execution schedule

The execution scheduled is expressesd as a list of classes. If any of the classes are defined when cf-execd wakes up then exec_command is triggered. By default this is set to a list of time based classes for every 5th minute. This results in a 5 minute execution schedule.

Example configuration via augments:

```
{
  "vars": {
    "control_executor_schedule": [ "Min00", "Min30" ]
  }
}
```

The above configuration would result in exec_command being triggered at the top and half hour and sleeping for up to `splaytime` before agent execution.

### Configure cf-execd runagent socket users

On Enterprise hubs, access to cf-execd sockets can be configured as a list of users who should be allowed by defining `vars.control_executor_runagent_socket_allow_users`. By default on Enterprise Hubs, `cfapache` is allowed to access runagent sockets.

```
{
  "vars": {
    "control_executor_runagent_socket_allow_users": [ "cfapache", "vpodzime" ]
  }
}
```

**History:**

* Added in CFEngine 3.18.0

### Allow connections from the classic/legacy protocol

By default since 3.9.0 `cf-serverd` disallows connections from the classic protocol by default. To allow clients using the legacy protocol (versions prior to 3.7.0 by default) define ```control_server_allowlegacyconnects``` as a list of networks.

Example definition in augments file:

```
{
  "vars": {
    "control_server_allowlegacyconnects": [ "0.0.0.0/0" ]
  }
}
```

### Configure the ciphers which are allowed to be used by cf-serverd

When `default:def.control_server_allowciphers` is defined `cf-serverd` will use the ciphers specified instead of the binary defaults.

Example definition in augments file:

```json
{
  "variables": {
    "default:def.control_server_allowciphers": {
     "value": "AES256-GCM-SHA384:AES256-SHA",
     "comment": "Restrict the ciphers that cf-serverd is allowed to use for better security"
    }
  }
}
```

**Notes:**

* Be careful changing this setting. A setting that is not well aligned between all clients and the server could result in clients not being able to communicate with the hub preventing further policy updates.

**History:**

* Added in 3.22.0, 3.21.2

### Configure the ciphers which are allowed to be used by cf-agent

When `default:def.control_common_tls_ciphers` is defined `cf-agent` will use the ciphers specified instead of the binary defaults for outgoing connections.

Example definition in augments file:

```json
{
  "variables": {
    "default:def.control_common_tls_ciphers": {
     "value": "AES256-GCM-SHA384:AES256-SHA",
     "comment": "Restrict the ciphers that are used for outgoing connections."
    }
  }
}
```

**Notes:**

* Be careful changing this setting. A setting that is not well aligned between all clients and the server could result in clients not being able to communicate with the hub preventing further policy updates.
* This setting is instrumented in all of the default entry points (`promises.cf`, `update.cf`, `standalone_self_upgrade.cf`).

**History:**

* Added in 3.22.0, 3.21.2


### Configure the minimum TLS version which is allowed to be used by cf-serverd

When `default:def.control_server_allowtlsversion` is defined `cf-serverd` will use the minimum TLS version specified instead of the binary defaults.

Example definition in augments file:

```json
{
  "variables": {
    "default:def.control_server_allowtlsversion": {
     "value": "1.0",
     "comment": "We want to allow old (<3.7.0) clients to connect."
    }
  }
}
```

**Notes:**

* Be careful changing this setting. A setting that is not well aligned between all clients and the server could result in clients not being able to communicate with the hub preventing further policy updates.

**History:**

* Added in 3.22.0


### Configure the minimum TLS version which is allowed to be used by cf-agent

When `default:def.control_common_tls_min_version` is defined `cf-agent` will use the minimum TLS version specified instead of the binary defaults for outgoing connections.

Example definition in augments file:

```json
{
  "variables": {
    "default:def.control_common_tls_min_version": {
     "value": "1.0",
     "comment": "We want to connect to old (<3.7.0) servers."
    }
  }
}
```

**Notes:**

* Be careful changing this setting. A setting that is not well aligned between all clients and the server could result in clients not being able to communicate with the hub preventing further policy updates.
* This setting is instrumented in all of the default entry points (`promises.cf`, `update.cf`, `standalone_self_upgrade.cf`).

**History:**

* Added in 3.22.0


### Configure users allowed to initate execution via cf-runagent

cf-serverd only allows specified users to request unscheduled execution remotely via cf-runagent.

By default the MPF allows `root` to request unscheduled execution of non policy servers and does not allow any users to request unscheduled execution from policy servers.

To configure the list of users allowed to request unscheduled execution define `vars.control_server_allowusers`.

```
{
  "vars": {
    "control_server_allowusers": [ "root", "nickanderson", "cfapache" ],
  }
}
```

It's possible to configure different users that are allowed for policy servers versus non policy servers via `vars.control_server_allowusers_non_policy_server` and `vars.control_server_allowusers_policy_server`. However, if  `vars.control_server_allowusers` is defined, it has precedence.

This example allows the users `hubmanager` and  `cfoperator` to request unscheduled execution from policy servers and no users are allowed to request unscheduled runs from non policy servers.

```
{
  "vars": {
    "control_server_allowusers_non_policy_server": [ ],
    "control_server_allowusers_policy_server": [ "hubmanager", "cfoperator" ]
  }
}
```

**History:**

- Added in 3.13.0, 3.12.1
- Added `vars.control_server_allowusers` in 3.18.0

**See Also:** [Configure hosts allowed to initate execution via cf-runagent][Configure hosts allowed to initate execution via cf-runagent]

### Configure hosts allowed to initate execution via cf-runagent

cf-serverd only allows specified hosts to request unscheduled execution remotely via `cf-runagent`.

By default the MPF allows policy servers (as defined by `def.policy-servers`) to initiate agent runs via `cf-runagent`.


To configure the list of hosts allowed to request unscheduled execution define `vars.mpf_admit_cf_runagnet_shell`. This example allows the IPv4 address `192.168.42.10`, the host `bastion.example.com`, and the host with identity `SHA=43c979e264924d0b4a2d3b568d71ab8c768ef63487670f2c51cd85e8cec63834` and policy servers the ability to initiate agent runs via `cf-runagent`.

```json
{
    "vars": {
        "mpf_admit_cf_runagent_shell": [ "192.168.42.10",
                                         "bastion.example.com",
                                         "SHA=43c979e264924d0b4a2d3b568d71ab8c768ef63487670f2c51cd85e8cec63834",
                                         "@(def.policy_servers)"
                                       ]
    }
}
```

**See Also:** [Configure users allowed to initate execution via cf-runagent][Configure users allowed to initate execution via cf-runagent]

**History:**

- Added in CFEngine 3.18.0

### Configure retention for files in log directories

By default the MPF rotates managed log files when they reach 1M in size. To configure this limit via augments define `vars.mpf_log_file_max_size`.

For example:

```
{
  "vars": {
    "mpf_log_file_max_size": "10M"
  }
}
```

By default the MPF keeps up to 10 rotated log files. To configure this limit via augments define `vars.mpf_log_file_retention`.

For example:

```
{
  "vars": {
    "mpf_log_file_retention": "5"
  }
}
```

By default the MPF retains log files in log directories (`outputs`, `reports` and application logs in Enterprise) for 30 days. This can be configured by setting `vars.mpf_log_dir_retention` via augments.

For example:

```
{
  "vars": {
    "mpf_log_dir_retention": "7"
  }
}
```

### Configure retention of assets generated by asynchronous query api or scheduled reports

By default the MPF is configured to retain reports generated by the asynchronous query api and scheduled reports generated by CFEngine Enterprise. This can be configured by setting `vars.purge_scheduled_reports_older_than_days` via augments.

```json
{
  "vars": {
    "purge_scheduled_reports_older_than_days": "30"
  }
}
```

### Adjust the maximum amount of client side report data to retain (CFEngine Enterprise)

Enterprise agents cache detailed information about each agent run locally. The
data is purged when the data is reported to a hub. If the volume of data exceeds
`def.max_client_history_size` then the client will purge the local data in order
to keep report collection from timing out.

The default 50M threshold can be configured using an [augments file][Augments], for example:

```
{
  "vars": {
    "max_client_history_size": "5M"
  }
}
```

### Enterprise hub pull collection schedule

By default Enterprise hubs initiate pull collection once every 5 minutes. This can be overridden in the MPF by defining `def.control_hub_hub_schedule` as a list of classes that should trigger collection when defined.

Here we set the schedule to initiate pull collection once every 30 minutes via augments.

```json
{
  "vars": {
    "control_hub_hub_schedule": [ "Min00", "Min30" ]
  }
}
```

**History:**

- MPF override introduced in 3.13.0, 3.12.2

### Configure maximum age in hours of old reports for cf-hub to collect

By default cf-hub instructs clients to expire reports older than 6 hours in order to prevent a build up of reports that could cause a condition where the client is never able to send all reports within the collection window.

You can adjust this time by setting `vars.control_hub_client_history_timeout`

For example:


```json
{
  "vars": {
    "control_hub_client_history_timeout": "72"
  }
}
```

**History:**

- MPF override introduced in 3.13.0, 3.12.2

### Exclude hosts from hub initiated report collection

You may want to exclude some hosts like community agents, hosts behind NAT, and
hosts using client initiated reporting from hub initiated report collection. To
exclude hosts from hub initiated report collection define
`def.control_hub_exclude_hosts` in an [augments file][Augments].

For example to completely disable hub initiated report collection:

```json
{
  "vars": {
    "control_hub_exclude_hosts": [ "0.0.0.0/0" ]
  }
}
```

**History:**

- MPF override introduced in 3.13.0, 3.12.2

### Change port used for enterprise report collection

By default cf-hub collects reports by connecting to port 5308. You can change this default by setting `vars.control_hub_port` in augments.

For example:

```json
{
  "vars": {
    "control_hub_port": "8035"
  }
}
```

**History:**

- Added in 3.13.0, 3.12.2

### Change hub to client connection timeout

By default, cf-hub times out a connection after 30 seconds.
This can be configured in augments.

For example:

```json
{
  "vars": {
    "control_hub_query_timeout": "10"
  }
}
```

**Note:**

- A value of `"0"` will cause the default to be used.

**History:**

- Added in 3.15.0

### Enable client initiated reporting

In the default configuration for Enterprise report collection the hub
periodically polls agents that are bootstrapped to collect reports. Sometimes it
may be desirable or necessary for the client to initiate report collection.

To enable client initiated reporting define the class
`client_initiated_reporting_enabled`. You may also want to configure the report
interval (how frequently an agent will try to report it's data to the hub) by default it is set to 5. The
reporting interval `def.control_server_call_collect_interval` and the class can
be defined in an [augments file][Augments].

For example:

```
{
  "classes" {
    "client_initiated_reporting_enabled": [ "any" ]
  },
  "vars": {
    "control_server_call_collect_interval": "1",
  }
}
```

### Configure client initiated reporting timeout

By default cf-serverd holds an open connection for client initiated for 30
seconds. In some environments this value may need to be increased in order for
report collection to finish. Once the connection has been open for longer than
the specified seconds it is closed.

The window of time can be controled by setting `def.control_server_collect_window`.

For example, enable client initated reporting for all hosts with a 10 minute interval and hold the connection open for 90 seconds.

```
{
  "classes" {
    "client_initiated_reporting_enabled": [ "any" ]
  },
  "vars": {
    "control_server_collect_window": "90",
    "control_server_call_collect_interval": "10"
  }
}
```

**History:**

- Added in 3.10.6, 3.12.2, 3.13.1

### Configure MPF to automatically restart components on relevant data change

While the agent itsef will reload its config upon notice of policy change this
bundle specifically handles changes to variables used in the MPF which may come
from external data sources which are unknown to the components themselves.

Currently only `cf-serverd`, `cf-monitord`, and `cf-hub` are handled. `cf-execd` is
**NOT** automatically restarted.

To enable this functionality define the class **`mpf_augments_control_enabled`**

```json
{
  "classes":{
      "mpf_augments_control_enabled": [ "any" ]
  }
}
```

**Notes:** In order for custom ACLs to leverage augments and support data based
restart you should use variables prefixed with ```control_server_```.

For example changes to ```vars.control_server_my_access_rules```
when ```mpf_augments_control_enabled``` is defined will result
in `cf-serverd` restarting.


```json
{
  "classes": {
      "mpf_augments_control_enabled": [ "any" ]
  },
  "vars": {
    "control_server_my_access_rules" : {
      "/var/repo/": {
        "admit": "def.acl"
      }
    }
  }
}
```

**History:** Added 3.11.0

### Configure maxconnections for cf-serverd

`maxconnections` in `body server control` configures the maximum number of
connections allowed by cf-serverd. Recommended to be set greater than the number
of hosts bootstrapped.

This can be configured via [augments][Augments]:

```
{
  "vars":{
      "control_server_maxconnections": "1000"
  }
}
```

**History:** Added 3.11.0

### Configure networks allowed to make collect_calls (client initiated reporting)

By default the hub allows collect calls (client initiated reporting) from the
networks defined in `def.acl` To configure which networks are allowed to
initiate report collection define
`def.mpf_access_rules_collect_calls_admit_ips`.

For example to allow client initiated reporting for hosts coming from
`24.124.0.0/16`:

```
{
  "vars": {
    "mpf_access_rules_collect_calls_admit_ips": [ "24.124.0.0/16" ]
  }
}
```

**See Also:** [Generic acl](#acl)

### Configure Enterprise Measurement/Monitoring Collection

Metrics recorded by measurement promises in `cf-monitord` are only collected by
default for policy servers. In order to collect metrics for non policy servers
simply define `default_data_select_host_monitoring_include` via in an [augments file][Augments].

For example to collect all measurements for remote agents and only cpu and
memory related probes on policy servers:

```
{
  "vars": {
    "default_data_select_host_monitoring_include": [ ".*" ],
    "default_data_select_policy_hub_monitoring_include": [ "mem_.*", "cpu.*" ]
  }
}
```

**History:**

* Added in 3.10.2, 3.11.0

### Configure Enterprise Mission Portal Docroot

Primarily for developer conveniance, this setting allows you to easily disable the enforcement that the webapp consists of the packaged files in the docroot used for Mission Portal.


```
{
  "classes": {
    "mpf_disable_mission_portal_docroot_sync_from_share_gui": [ "any" ]
  }
}
```

### Bundlesequence

#### Classification bundles before autorun

You can specify a list of bundles which should be run before autorun policies (if enabled).

```json
{
  "vars":{
    "control_common_bundlesequence_classification": [ "classification_one", "classification_two" ]
  },

  "inputs": [ "services/my_classificaton.cf" ]
}
```

**History:**

* Added in CFEngine 3.18.0

#### Append to the main bundlesequence

You can specify bundles which should be run at the end of the default
bundlesequence by defining ```control_common_bundlesequence_end``` in the vars
of an  [augments file][Augments].

For example:

```json
{
  "vars":{
    "control_common_bundlesequence_end": [ "mybundle1", "mybundle2" ]
  },

  "inputs": [ "services/mybundles.cf" ]
}
```

**Notes:**

* The order in which bundles are actuates is not guaranteed.
* The agent will error if a named bundle is not part of inputs.

**History**: Added in 3.10.0

### Configure `abortclasses` via augments

Configure a list of regular expressions that result in cf-agent terminating
itself upon definition of a matching class.

For example, abort execution if any class starting with ```error_``` or ```abort_``` is defined:

```
{
  "vars":{
    "control_agent_abortclasses": [ "error.*", "abort.**" ]
  }
}
```

**History**: Added in 3.15.0, 3.12.3

### Configure `abortbundleclasses` via augments

Configure a list of regular expressions that match classes which if defined lead
to termination of current bundle.

If no list is defined, then a default of ```abortbundle``` is used.

For example, abort execution if any class starting with ```bundle_error_``` or ```bundle_abort_``` is defined:

```
{
  "vars":{
    "control_agent_abortbundleclasses": [ "bundle_error.*", "bundle_abort.**" ]
  }
}
```

**History**: Added in 3.15.0, 3.12.3

### Configure `files_single_copy` via augments

Specify a list of regular expressions that when matched will prevent the agent
from performing subsequent copy operations on the same promiser.

For example, to only allow any file to be copied a single time:

```
{
  "vars":{
    "control_agent_files_single_copy": [ ".*" ]
  }

}
```

**History**: Added in 3.11.0, 3.10.2

### Disable automatic policy hub detection

During bootstrap, if the executing host finds the IP address of the target on
itself it automatically classifies the host as a policy server by ensuring the
`$(sys.statedir)/am_policy_hub` file exists. When this file exists, the
`am_policy_hub` and `policy_server` classes are defined. To help avoid
accidental declassification, the MPF contains policy to regularly check if the
host is bootstrapped to an IP found on itself, and if so, to ensure the proper
state file exists.

To disable this check, define `mpf_auto_am_policy_hub_state_disabled`.

For example, to define this class via augments, place the following in your def.json.

```
{
  "classes":{
    "mpf_auto_am_policy_hub_state_disabled": [ "any" ]
  }

}
```

**History**: Added in 3.15.0, 3.12.3, 3.10.7

### Configure default repository for file backups

By default the agent creates a backup of a file before it is edited in the same
directory as the edited file. Defining the
`mpf_control_agent_default_repository` class will cause these backups to be
placed in `$(sys.workdir)/backups`. Customize the backup directory by setting
`def.control_agent_default_backup`.

For example:

```
{
  "classes": {
    "mpf_control_agent_default_repository": [ "any" ]
  },

  "vars": {
    "control_agent_default_repository": "/var/cfengine/edit_backups"
  }
}
```

**History**: Added in 3.10.1

### Configure periodic package inventory refresh interval

Note that there are currently two implementations of packages promises, package
modules and package methods. Each maintain their own cache of packages installed
and updates available.

#### For package modules
CFEngine refreshes software inventory when it makes changes via packages
promises. Additionally, by default, CFEngine refreshes it's
internal cache of packages installed (during each agent run) and package updates that
are available (once a day) according to the default package manager in order to
pick up changes made outside packages promises.

```json
{
  "vars": {
    "package_module_query_installed_ifelapsed": "5",
    "package_module_query_updates_ifelapsed": "60"
  }
}
```

WARNING: Be ware of setting `package_module_query_update_ifelapsed` too low,
especially with public repositories or you may be banned for abuse.

**See also:** `packagesmatching()`, `packageupdatesmatching()`

**History**:

* Added in 3.15.0, 3.12.3
* 3.17.0 decreased `package_module_query_installed_ifelapsed` from `60` to `0`

#### For package methods

CFEngine refreshes it's cache of information about packages installed and
updates available when it evaluates packages promises if the cache has not been
updated in the number of minutes stored in `package_list_update_ifelapsed` of
the package method in use. Many package methods in the standard library use the
value of `default:common_knowledge.list_updates_ifelapsed` for this value which
can be customized via Augments.

```json
{
  "variables": {
    "default:common_knowledge.list_update_ifelapsed": {
      "value": "0"
    }
  }
}
```

**Notes:**

* Unlike *many* variables that can be customized via Augments this variable is
  **not** in the `default:def` bundle scope. Customizing it requires CFEngine
  3.18.0 or newer which support targeting any namespace or variable.

**See also:**

* [package methods][lib/packages.cf]: ```pip```,
  ```npm```, ```npm_g```, ```brew```, ```apt```, ```apt_get```,
  ```apt_get_permissive```, ```apt_get_release```, ```dpkg_version```,
  ```rpm_version``` , ```yum```, ```yum_rpm```, ```yum_rpm_permissive```,
  ```yum_rpm_enable_repo``` , ```yum_group```, ```rpm_filebased```, ```ips```,
  ```smartos```, ```opencsw```, ```emerge```, ```pacman```, ```zypper```,
  ```generic```

* [package bundles][lib/packages.cf]: ```package_latest```,
  ```package_specific_present```, ```package_specific_absent```,
  ```package_specific_latest```, ```package_specific```

**History:**

* Added in 3.22.0, 3.21.2

### Enable logging of Enterprise License utilization

If the class `enable_log_cfengine_enterprise_license_utilization` is defined on
an enterprise hub license utilization will be logged by the hub in
`$(sys.workdir)/log/license_utilization.log`

Example enabling the class from an [augments file][Augments]:

```
{
  "classes": {
    "enable_log_cfengine_enterprise_license_utilization": [ "enterprise_edition" ]
  }
}
```

**History**: Added in 3.11, 3.10.2

### Enable external watchdog

**Note**: This feature is not enabled by default.

If the class `cfe_internal_core_watchdog_enabled` is defined, the feature is
enabled and the watchdog will be active. If the class
`cfe_internal_core_watchdog_disabled` is defined, the feature is disabled and
the watchdog will not be active.

```json
{
    "classes": {
        "cfe_internal_core_watchdog_enabled": [ "aix::" ],
        "cfe_internal_core_watchdog_disabled": [ "!cfe_internal_core_watchdog_enabled::" ]
        }
}
```

**See Also:** [Watchdog documentation][cfe_internal/core/watchdog]

### Environment Variables

Environment variables that should be inherited by child commands can be set using `def.control_agent_environment_vars_default`. The policy defaults are overridden if this is defined. This can be useful if you want to modify the default environment variables that are set.

For example:

```json
{
  "vars": {
    "control_agent_environment_vars_default":
      [ "DEBIAN_FRONTEND=noninteractive",
        "XPG_SUS_ENV=ON" ]
  }
}
```

The environment variables can also be extended by defining `def.control_agent_environment_vars_extra`. The extra environment variables defined here are combined with the defaults (if they exist).

```json
{
  "vars": {
    "control_agent_environment_vars_extra": [ "XPG_SUS_ENV=ON" ]
  }
}
```

**Notes:**

* Simple augments as shown above apply to *all* hosts. Consider using the
  [augments key][Augments#augments] or [host specific data][Augments#host_specific.json] if you want to set environment variables
  differently across different sets of hosts. The value set via Augments takes
  precedence over policy defaults, so be sure to take that into account when
  configuring.

**History:**

* Introduced in 3.20.0, 3.18.2

### Modules

Modules executed by the `usemodule()` function are expected to be found in
`$(sys.workdir)/modules` the modules are distributed to all remote agents by in
the default policy.

### Templates

For convenience the `templates` shortcut is provided and by default the path is
set to `$(sys.workdir/templates)` unless `$(def.template_dir)` is overridden via
[augments][Augments].

* **NOTE:** The templates directory is not currently managed by default policy.
  Unlike modules **templates are not distributed to all hosts by default**.

Copy a template from the templates directory:

```cf3
  files:

    "$(def.dir_templates)/mytemplate.mustache" -> { "myservice" }
      copy_from => remote_dcp("templates/mytemplate.mustache", $(sys.policy_server) ),
      comment => "mytemplate is necessary in order to render myservice configuration file.";
```

Override the path for `$(def.dir_templates)` by setting `vars.dir_templates` in
the  [augments file][Augments] (`def.json`):

```json
{
    "vars": {
        "dir_templates": "/var/cfengine/mytemplates"
        }
}
```

**Note:** When overriding the templates directory a change to the [augments][Augments] alone
will not cause `cf-serverd` to reload its configuration and update the access
control lists as necessary. `cf-serverd` will only automatically reload its
config when it notices a change in *policy*.

**History**: Added in 3.11.

### Federated Reporting
#### Enable Federated Reporting Distributed Cleanup

Hosts that report to multiple feeders result in duplicate entries and other issues. Distributed cleanup helps to deal with this condition.

To enable this functionality define the class `default:cfengine_mp_fr_enable_distributed_cleanup` on the _superhub_.

For example, to define this class via Augments:

```json
{
  "classes": {
    "cfengine_mp_fr_enable_distributed_cleanup": [ "any::" ]
  }
}
```

**History:**

* Added in CFEngine 3.19.0, 3.18.1

#### Configure SSL Certificate Directory for Federated Reporting Distributed Cleanup

When custom certificates are in use distributed cleanup needs to know where to find them. To configure the path where certificates are found define `default:def.DISTRIBUTED_CLEANUP_SSL_CERT_DIR`, for example:

```json
{
  "vars": {
    "DISTRIBUTED_CLEANUP_SSL_CERT_DIR": "/path/to/my/cert/dir"
  }
}
```

**History:**

* Added in CFEngine 3.20.0, 3.18.2

#### PostgreSQL Configuration

It's not uncommon to need to configure some PostgreSQL settings differently for Federated Reporting. The settings that are exposed as tunables which can be set via augments are listed here. These do not comprise all settings that may need adjusted, only those that are most commonly adjusted.

**Note:** When [setting parameters for the PostgreSQL configuration](https://www.postgresql.org/docs/current/config-setting.html)
file various units can be used. Valid memory units are B (bytes), kB
(kilobytes), MB (megabytes), GB (gigabytes), and TB (terabytes). The multiplier
for memory units is 1024, not 1000. Valid time units are us (microseconds), ms
(milliseconds), s (seconds), min (minutes), h (hours), and d (days).

##### shared_buffers

Shared buffers are the amount of memory the database server uses for shared memory buffers. Settings significantly higher than the minimum are usually needed for good performance.

The value should be set to 15% to 25% of the machine's total RAM. For example: if your machine's RAM size is 32 GB, then the recommended value for shared_buffers is 8 GB.

To adjust this set `cfengine_enterprise_federation:postgres_config.shared_buffers` via Augments.

For example:

```json
{
  "variables": {
    "cfengine_enterprise_federation:postgres_config.shared_buffers": "2560MB"
  }
}
```

**History:**

* Added in 3.20.0, 3.18.2

##### max_locks_per_transaction

The ```max_locks_per_transaction``` value indicates the number of database objects that can be locked simultaneously. When Federated Reporting is enabled, the MPF default is `4000`.

```json
{
  "variables": {
    "cfengine_enterprise_federation:postgres_config.max_locks_per_transaction": "4100"
  }
}
```

**History:**

* Added in 3.20.0, 3.18.2

##### log_lock_waits

Controls whether a log message is produced when a session waits longer than `deadlock_timeout` to acquire a lock. This is useful in determining if lock waits are causing poor performance. When Federated Reporting is enabled, the MPF default is `on`.

```json
{
  "variables": {
    "cfengine_enterprise_federation:postgres_config.log_lock_waits": "off"
  }
}
```

**History:**

* Added in 3.20.0, 3.18.2

##### max_wal_size

Sets the WAL size that triggers a checkpoint.

Maximum size to let the WAL grow during automatic checkpoints. This is a soft limit; WAL size can exceed `max_wal_size` under special circumstances, such as heavy load, a failing `archive_command`, or a high `wal_keep_size` setting. If this value is specified without units, it is taken as megabytes. The default is 1 GB (`1024MB`). Increasing this parameter can increase the amount of time needed for crash recovery.

```json
{
  "variables": {
    "cfengine_enterprise_federation:postgres_config.max_wal_size": "20G"
  }
}
```

**History:**

* Added in 3.20.0, 3.18.2

##### checkpoint_timeout

Sets the maximum time between automatic WAL checkpoints.

Maximum time between automatic WAL checkpoints. If this value is specified without units, it is taken as seconds. The valid range is between 30 seconds and one day. The default is five minutes (`5min`). Increasing this parameter can increase the amount of time needed for crash recovery.

```json
{
  "variables": {
    "cfengine_enterprise_federation:postgres_config.checkpoint_timeout": "30min"
  }
}
```

**History:**

* Added in 3.20.0, 3.18.2

## Recommendations

The MPF includes policy that inspects the system and makes recommendations about
the configuration of the system. When `cfengine_recommendations_enabled` is
defined bundles tagged `cfengine_recommendation` are executed in lexical order.
`cfengine_recommendations_enabled` is defined by default when
`cfengine_recommendations_disabled` is **not** defined.

To disable cfengine recommendations define `cfengine_recommendations_disabled`.

This snippet disables recommendations via augments.

```
{
    "classes": [
        "cfengine_recommendations_disabled"
    ]
}
```

**History:**

* Recommendations added in 3.12.1

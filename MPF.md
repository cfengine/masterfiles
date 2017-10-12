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

By default the MPF enforces restrictive permissions for inputs. If the class
```cfengine_internal_preserve_permissions``` is defined the permissions of the
policy server's masterfiles will be preserved when they are copied.

### Enable CFEngine Enterprise HA

When the ```enable_cfengine_enterprise_hub_ha``` class is defined the policy to
manage High Availability of Enterprise Hubs is enabled.

**Note:** This class is **not** defined by default.

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

### Automatically remove files not present upstream (SYNC masterfiles)

If the class ```cfengine_internal_purge_policies``` is defined the update
behavior to change from only copying changed files down to performing a
synchronization by purging files on the client that do not exist on the server.

This [augments file][Augments] will enable this behavior for all clients.

```
{
  "classes": {
    "cfengine_internal_purge_policies": [ "any" ]
  }
}
```

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

**Note:** This policy is specific to CFEngine Enterprise.

This [augments file][Augments] would define the ```trigger_upgrade``` class if the
`testhost5` class is defined.

```
{
  "classes": {
    "trigger_upgrade": [ "testhost5" ]
  }

}
```

### Files considered for copy during policy updates

The default update policy only copies files that match regular expressions
listed in ```def.input_name_patterns```.

This [augments file][Augments] ensures that only files ending in ```.cf```, ```.dat```,
```.mustache```, ```.json```, ```.yaml``` and the file
```cf_promises_release_id``` will be considered by the default update policy.

```
{
  "vars:" {
    "input_name_patterns": [ ".*\\.cf", ".*\\.dat",
                             ".*\\.mustache",
                             "cf_promises_release_id",
                             ".*\\.json", ".*\\.yaml" ]
  }
}
```

**Note:** This filter does **not** apply to bootstrap operations. During
bootstrap the
embedded
[failsafe policy](https://github.com/cfengine/core/blob/master/libpromises/failsafe.cf) is
used and it decides which files should be copied.

### Enable or disable CFEngine components

#### persistent\_disable\_*DAEMON*

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

#### clear_persistent\_disable\_*DAEMON*

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

### Main Policy (promises.cf)

The following settings are defined in `controls/def.cf` can be set from an
[augments file][Augments].

#### mailto

The address that `cf-execd` should email agent output to.

#### mailfrom

The address that output mailed from `cf-execd` should come from.

#### smtpserver

The SMTP server that `cf-execd` should use to send emails.

#### acl

This is a list of of network ranges that the hub should allow download of policy
files from.

#### trustkeysfrom

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

### services\_autorun

When the ```services_autorun``` class is defined bundles tagged with
```autorun``` are actuated in lexical order.

```cf3
bundle agent example
{
  meta:
    "tags" slist => { "autorun" };

  reports:
    "I will report when 'services_autorun' is defined."
}
```

**Note:** ```.cf``` files located in `services/autorun/` are automatically
included in inputs even when the ```services_autorun``` class is **not**
defined. Bundles tagged with ```autorun``` are **not required** to be placed in
`services/autorun/` in order to be automatically actuated.

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
`def.maxclient_history_size`. By default is is **off** unless a CFEngine
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

### Exclude hosts from hub initiated report collection

You may want to exclude some hosts like community agents, hosts behind NAT, and
hosts using client initiated reporting from hub initiated report collection. To
exclude hosts from hub initiated report collection define
`def.control_hub_exclude_hosts` in an [augments file][Augments].

For example to completely disable hub initiated report collection:

```
{
  "vars": {
    "control_hub_exclude_hosts": [ "0.0.0.0/0" ]
  }
}
```

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

### Configure MPF to automatically restart components on relevant data change

While the agent itsef will reload its config upon notice of policy change this
bundle specifically handles changes to variables used in the MPF which may come
from external data sources which are unknown to the components themselves.

Note currently only `cf-serverd` and `cf-monitord` are handled. `cf-execd` is
**NOT** automatically restarted.

To enable this functionality define the class **`mpf_augments_control_enabled`**

```
{
  "classes":{
      "mpf_augments_control_enabled": [ "any" ]
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
      "control_serverd_maxconnections": "1000"
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
    "default_data_select_policy_hub_monitoring_include": [ "mem_.*", "cpu_.*" ]
  }
}
```

### Append to the main bundlesequence

You can specify bundles which should be run at the end of the default
bundlesequence by defining ```control_common_bundlesequence_end``` in the vars
of an  [augments file][Augments].

For example:

```json
{
  "vars":{
    "control_common_bundlesequence_end": [ "mybundle1", "mybundle2" ]
  }

  "inputs": [ "services/mybundles.cf" ]
}
```

**Notes:**

* The order in which bundles are actuates is not guaranteed.
* The agent will error if a named bundle is not part of inputs.

**History**: Added in 3.10.0

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

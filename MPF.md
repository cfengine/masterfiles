The Masterfiles Policy Framework is the default policy
that ships with both the CFEngine Enterprise and
Community editions. The MPF includes policy to manage
cfengine itself, the stdlib, and policy to inventory
various aspects of the system.

# Framework Overview

* `update.cf` - The update policy entry.
* `promises.cf` - The main policy entry.
* `lib/` - The standard library.
* `services` - User defined custom policy.
* `services/main.cf` - Contains an empty bundle agent main where custom policy
  can be integrated.
* `services/autorun/` - Automatically included policy files.

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

This augments file will enable this behavior for all clients.

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

This augments file would define the ```trigger_upgrade``` class if the
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

This augments file ensures that only files ending in ```.cf```, ```.dat```,
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

This augments file will ensure that `cf-monitord` is disabled on hosts that have
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

This augments file will ensure that `cf-monitord` is not disabled on `redhat`
hosts.

```
{
  "classes": {
    "clear_persistent_disable_cf_monitord": [ "redhat" ]
  }
}
```

### Main Policy (promises.cf)

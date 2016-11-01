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

# Configuring

The most common controls reference variables in the ```def``` bundle in order to
keep the modifications to the distributed policy contained within a single
place. The recommended way to set classes and define variables in the ```def```
bundle is using an [augments file][Augments]. Keeping the modifications to the
distributed policy set makes policy framework upgrades significantly easier.

Note: If you need to make modification to a shipped file consider opening a pull
request to expose the tunable into the ```def``` bundle.

**Note:** `controls/def.cf` contains the defaults and settings for `promises.cf`
and `controls/update_def.cf` contains the defaults and settings for `update.cf`.

## Automatically remove files not present upstream (SYNC masterfiles)

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

## Automatically deploy masterfiles from Version Control

On a CFEngine Enterprise Hub during the update policy if the class
```cfengine_internal_masterfiles_update``` is defined masterfiles will be
automatically deployed from an upstream version control repository using
the
[settings defined via Mission Portal][Best Practices#Version Control and Configuration Policy] or
directly in ```/opt/cfengine/dc-scripts```.

**Note:** Any policy in the distribution location (/var/cfengine/masterfiles)
will be deleted the first time this tooling runs. Be wary of local modifications
before enabling.

## Policy Permissions

By default the policy enforces permissions of ```0600``` meaning that inputs are
only readable by their owner. If you are distributing scripts with your
masterfiles, be sure there is a policy to ensure they are executable when you
expect them to be.

## Agent binary upgrades

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

## Files considered for copy during policy updates

The default update policy only copies files that match regular expressions
listed in ```def.input_name_patterns```.

This augments file ensures that only files ending in ```.cf```, ```.dat```,
```.mustache```, ```.json```, ```.yaml``` and the file
```cf_promises_release_id``` will be considered by the default update policy.

**Note:** This filter does **not** apply to bootstrap operations. During
bootstrap the
embedded
[failsafe policy](https://github.com/cfengine/core/blob/master/libpromises/failsafe.cf) is
used and it decides which files should be copied.

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

## Enable or disable CFEngine components

### persistent\_disable\_*DAEMON*

**Description:** Disable a CFEngine Enterprise daemon component persistently.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This will stop the AGENT from starting automatically.

This augments file will ensure that `cf-monitord` is disabled on hosts that have
`server1` or the `redhat` class defined.

    {
      "classes": {
        "persistent_disable_cf_monitord": [ "server1", "redhat" ]
      }
    }

### clear_persistent\_disable\_*DAEMON*

**Description:** Re-enable a previously disabled CFEngine Enterprise daemon
component.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This augments file will ensure that `cf-monitord` is not disabled on `redhat`
hosts.

    {
      "classes": {
        "clear_persistent_disable_cf_monitord": [ "redhat" ]
      }
    }

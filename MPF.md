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

## Enable or disable CFEngine components

### persistent\_disable\_*DAEMON*

**Description:** Disable a CFEngine Enterprise daemon component persistently.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This will stop the AGENT from starting automatically.

This augments file will ensure that `cf-monitord` is disabled on hosts that have
`server1` or the `redhat` class defined.

```json
{
  "classes": {
    "persistent_disable_cf_monitord": [ "server1", "redhat" ]
  }
}
```

### clear_persistent\_disable\_*DAEMON*

**Description:** Re-enable a previously disabled CFEngine Enterprise daemon
component.

`DAEMON` can be one of `cf_execd`, `cf_monitord` or `cf_serverd`.

This augments file will ensure that `cf-monitord` is not disabled on `redhat`
hosts.

```json
{
  "classes": {
    "clear_persistent_disable_cf_monitord": [ "redhat" ]
  }
}
```

# CFEngine 3 masterfiles

CFEngine 3 is a popular open source configuration management system. Its primary
function is to provide automated configuration and maintenance of large-scale
computer systems.

This repository is intended to provide a stable base policy for
installations and upgrades, and is used by CFEngine 3.6 and newer.

## Structure

* `bootstrap/failsafe.cf`: the failsafe executed when all else fails
* `cfe_internal`: internal CFEngine policies you shouldn't have to modify
* `controls`: configuration of components, e.g. the `cf-agent` or `cf-serverd`
* `def.cf`: defaults you can and should configure
* `lib`: main library directory.  You'll see `3.5` and `3.6` under it.
* `libraries/cfengine_stdlib.cf`: old standard library (COPBL, used to be in https://github.com/cfengine/copl).  Do not use; only available for upgrading older clients.
* `promises.cf`: main policy, you will need to configure this
* `services`: your site's policies go here
* `sketches`: Design Center installations use this; do not touch
* `update` and `update.cf`: functionality for updating inputs and CFEngine itself.

## Contributing

Please see the [CONTRIBUTING.md](https://github.com/cfengine/core/blob/master/CONTRIBUTING.md) file.

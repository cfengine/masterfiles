# CFEngine 3 masterfiles

CFEngine 3 is a popular open source configuration management system. Its primary
function is to provide automated configuration and maintenance of large-scale
computer systems.

This repository is intended to provide a stable base policy for
installations and upgrades, and is used by CFEngine 3.6 and newer.

## Installation

The contents of this repository are intended to live in `/var/cfengine/masterfiles` or wherever `$(sys.masterdir)` points.

Use the convenience install target:

```
make install
```

to install only what's needed (without `tests`, only policies). By
default it installs in `/var/cfengine/masterfiles` but you can
override that easily:

```
make install DESTDIR=/my/other/install/directory
```

## Setting up

First, review `update.cf` and `def.cf`.  Most settings you need to change will live here.

### update.cf

Synchronizing clients with the policy server happens here, in
`update.cf`. Its main job is to copy all the files on the policy
server (usually the hub) under `$(sys.masterdir)` (usually
`/var/cfengine/masterfiles`) to the local host into `$(sys.inputdir)`
(usually `/var/cfengine/inputs`).

This is a standalone policy file. You can actually run it with
`cf-agent -KI -f ./update.cf` but if you don't understand what that
command does, please hold off until you've gone through the CFEngine
documentation. The contents of `update.cf` duplicate other things
under `lib` sometimes, in order to be completely standalone.

When `update.cf` is broken, things go bonkers. CFEngine will try to
run a backup `failsafe.cf` you can find at
https://github.com/cfengine/core/blob/3.6.x/libpromises/failsafe.cf
(that `.cf` file is written into the C code and can't be modified). If
things get to that point, you probably have to look at why corrupted
policies made it into production.

As is typical for CFEngine, the policy and the configuration are
mixed. In `update.cf` you'll find some very useful settings. Keep
referring to
https://github.com/cfengine/masterfiles/blob/3.6.x/update.cf as you
read this.  We are skipping the nonessential ones.

#### How it works

There are 4 stages in `update.cf`. See the `bundlesequence`: after
loading the configuration from `update_def`, we take these steps in
order.

##### cfe_internal_dc_workflow

This step implements the auto-deployment of policies. See
 https://docs.cfengine.com/docs/master/guide-enterprise-cfengine-guide-version-control-policy.html
 and `cfengine_internal_masterfiles_update` below for details.

##### cfe_internal_update_policy

This step updates the policy files themselves. See
https://github.com/cfengine/masterfiles/blob/3.6.x/update/update_policy.cf
for the implementation details. Basically it's a check step that looks
at `$(sys.inputdir)/cf_promises_validated` and compares it with the
policy server's `$(sys.masterdir)/cf_promises_validated`. Then there's
the actual copy, which happens only if the `cf_promises_validated`
file was updated in the check step.

##### cfe_internal_update_processes

This step manages the running processes, ensuring `cf-execd` and
`cf-serverd` and `cf-monitord` are running and doing some other tasks.

##### cfe_internal_update_bins

This step does a self-update of CFEngine. See the Enterprise
documentation for details; this functionality is unsupported in
CFEngine Community.

#### update.cf configuration

##### input_name_patterns

Change this variable to add more file extensions to the list copied
from the policy server.  By default this is a pretty sparse list.

##### masterfiles_perms_mode

Usually you want to leave this at `0600` meaning the inputs will be
readable only by their owner.

##### cfengine_internal_masterfiles_update

Off by default.

Turn this on (set to `any`) to auto-deploy policies on the policy
server, it has no effect on clients. See
https://docs.cfengine.com/docs/master/guide-enterprise-cfengine-guide-version-control-policy.html
for details on how to use it.

**This may result in DATA LOSS.**

##### cfengine_internal_encrypt_transfers

Off by default.

Turn this on (set to `any`) to encrypt your policy transfers.

Note it has a duplicate in `def.cf`, see below. If they are not
synchronized, you will get unexpected behavior.

##### cfengine_internal_purge_policies

Off by default.

Turn this on (set to `any`) to delete any files in your
`$(sys.inputdir)` that are not in the policy server's masterfiles.

**This may result in DATA LOSS.**

Note it has a duplicate in `def.cf`, see below. If they are not
synchronized, you will get unexpected behavior.

### def.cf

After `update.cf` is configured, you can configure the main `def.cf` policy.

This file is included by the main `promises.cf` and you can run that
with `cf-agent -KI -f ./promises.cf` but as before, make sure you
understand what this command does before using it.

Keep referring to
https://github.com/cfengine/masterfiles/blob/3.6.x/def.cf as you
read this.

#### How it works

`def.cf` has some crucial settings used by the rest of CFEngine. It's
expected that users will edit it but won't normally change the rest of
the masterfiles except in `services` or if they *know* it's necessary.

This is a simple CFEngine policy, so read on for configuring it.

#### def.cf configuration

##### domain

Set your `domain` to the right value. By default it's used for mail
and to deduce your file access ACLs.

##### acl

The `acl` is crucial. This is used by **every** host, not just the
policy server. Make sure you only allow hosts you want to allow.

##### trustkeysfrom

`trustkeysfrom` tells the policy server what hosts to trust for
bootstrapping. As the comments say, empty it after your hosts have
been bootstrapped to avoid unpleasant surprises.

##### services_autorun

Off by default.

Turn this on (set to `any`) to auto-load files in `services/autorun`
and run bundles found that are tagged `autorun`. See
https://github.com/cfengine/masterfiles/blob/3.6.x/services/autorun/hello.cf
for a simple example of such a bundle.

##### cfengine_internal_rotate_logs

On by default. Rotates CFEngine's own logs. For the details, see the
`cfe_internal_log_rotation` bundle in
https://github.com/cfengine/masterfiles/blob/3.6.x/cfe_internal/CFE_cfengine.cf

##### cfengine_internal_encrypt_transfers

Duplicate of the one in `update.cf`. They should be set in unison or
you will get unexpected behavior.

##### cfengine_internal_purge_policies

Duplicate of the one in `update.cf`. They should be set in unison or
you will get unexpected behavior.

##### cfengine_internal_sudoers_editing_enable

Off by default.  Only used on the CFEngine Enterprise hub.

Turn this on (set to `any`) to allow the hub to edit sudoers in order
for the Apache user to run passwordless sudo cf-runagent (part of
Mission Portal troubleshooting).

#### def.cf inventory control

The inventory is a cool new feature in 3.6.0. You can disable pieces
of it (inventory modules) or the whole thing if you wish.

##### disable_inventory

This class is off by default (meaning the inventory is on by default).
Here's the master switch to disable all inventory modules.

##### disable_inventory_lsb

LSB is the Linux Standard Base, see https://wiki.linuxfoundation.org/en/LSB

By default, this class is turned off (and the module is on) if the LSB
executable `/usr/bin/lsb_release` can be found. This inventory module
will populate inventory reports and variables for you with LSB
details. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/lsb.cf

##### disable_inventory_dmidecode

By default, this class is turned off (and the module is on) if the
executable `/usr/sbin/dmidecode` can be found. This inventory module
will populate inventory reports and variables for you. For details,
see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_LLDP

LLDP is a protocol for Link Layer Discovery. See
http://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol

By default, this class is turned off (and the module is on) if the
executable `/usr/bin/lldpctl` can be found. This inventory module will
populate variables for you. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_package_refresh

By default, this class is turned off (and the module is on). This
inventory module will populate the installed packages for you. On
CFEngine Enterprise, the available packages will also be populated.
For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_mtab

By default, this class is turned off (and the module is on) if
`/etc/mtab` exists. This inventory module will populate variables for
you based on the mounted filesystems. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_fstab

By default, this class is turned off (and the module is on) if
`$(sys.fstab)` (usually `/etc/fstab` or `/etc/vfstab`) exists. This
inventory module will populate variables for you based on the defined
filesystems. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_proc

By default, this class is turned off (and the module is on) if `/proc`
is a directory. This inventory module will populate variables for you
from some of the contents of `/proc`. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

##### disable_inventory_cmdb

By default, this class is turned on (and the module is off).

Turn this on (set to `any`) to allow each client to load a `me.json`
file from the server and load its contents. For details, see
https://github.com/cfengine/masterfiles/blob/3.6.x/inventory/any.cf

### promises.cf

#### How it works

`promises.cf` is your main run file. Keep referring to
https://github.com/cfengine/masterfiles/blob/3.6.x/promises.cf as you
read this.

#### promises.cf configuration

##### bundlesequence

Edit the `bundlesequence` to add any bundles you with. Consider using
the `services_autorun` facility so you don't have to edit this at all.

**BEWARE THAT ONLY VALID (KNOWN) BUNDLES CAN BE ADDED.**

By default, the inventory modules, then internal hub modules, then
Design Center sketches, then the autorun services, and finally
internal management bundles are in the `bundlesequence`.

##### inputs

In order to find bundles, CFEngine needs to know where to look. This
list defines what files are needed. Note there are several dynamic
entries here, coming from other bundles. CFEngine will keep evaluating
the `inputs` and `bundlesequence` until all the bundles are found and
resolved.

Make sure to add any of your own `services` files here if you don't
use the `services_autorun` facility, to ensure the bundles in them are
found.

## Unexpected behavior

Note that in this document, the term "unexpected behavior" has been
used, so a definition would help.

Last year, a CFEngine user got hit by a flying frisbee while walking
backwards through a revolving door. This year, he won 4 track events
in the **winter** Olympics. That's unexpected behavior.

## Further structure

* `cfe_internal`: internal CFEngine policies you shouldn't modify or you will get unexpected behavior
* `controls`: configuration of components, e.g. the `cf-agent` or `cf-serverd`, beyond what `def.cf` can offer
* `def.cf`: defaults you can and should configure, see above
* `inventory`: inventory modules (loaded before anything else to discover facts about the system) live here; see above
* `lib`: main library directory.  You'll see `3.5` and `3.6` under it.  These are the supported versions for masterfiles backwards compatibility.
* `libraries`: old stdlib library directory.  You'll see `cfengine_stdlib.cf` under it.  This is an old library (the COPBL) you should not use if at all possible.  All its contents, plus bug fixes, are now in `lib`.
* `promises.cf`: main policy, you will need to configure this, see above
* `services`: your site's policies go here
* `services_autorun`: see above
* `sketches`: Design Center installations use this; do not touch or you will get unexpected behavior
* `update` and `update.cf`: functionality for updating inputs and CFEngine itself, see above.  You shouldn't modify files under `update` or you will get unexpected behavior.

## Contributing

Please see the [CONTRIBUTING.md](https://github.com/cfengine/masterfiles/blob/3.6.x/CONTRIBUTING.md) file.

The CFEngine masterfiles are under the MIT license, see
https://github.com/cfengine/masterfiles/blob/3.6.x/LICENSE

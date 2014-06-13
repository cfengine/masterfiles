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

## Host report

A very important piece of functionality, which you may want for your
own use but will certainly be helpful for debugging or submitting bugs
to CFEngine (core, masterfiles, or any other are) is the host report.

Run the host report like so: `cf-agent -b host_info_report`

You should see output like:

```
R: Host info report generated and avilable at '/var/cfengine/reports/host_info_report.txt'
```

Take a look at the resulting file, it has lots of useful information about the system.

## Setting up

First, review `update.cf` and `def.cf`.  Most settings you need to change will live here.

### update.cf

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

By default, the policy defined in update.cf is executed from two sets of 
promise bodies. The "usual" one (defined in the `bundlesequence` in 
`promises.cf`) and another in the backup/failsafe `bundlesequence` (defined in 
`failsafe.cf`).

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

As is typical for CFEngine, the policy and the configuration are
mixed. In `update.cf` you'll find some very useful settings. Keep
referring to `update.cf` as you
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

This step updates the policy files themselves. Basically it's a check
step that looks at `$(sys.inputdir)/cf_promises_validated` and
compares it with the policy server's
`$(sys.masterdir)/cf_promises_validated`. Then there's the actual
copy, which happens only if the `cf_promises_validated` file was
updated in the check step.

Implementation (warning: advanced usage):

[%CFEngine_include_snippet(masterfiles/update/update_policy.cf)%]

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

Keep referring to `def.cf` as you read this.

Implementation (warning: advanced usage):

[%CFEngine_include_snippet(masterfiles/def.cf)%]

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

`trustkeysfrom` tells the policy server from which IPs it should accept
connections even if the host's key is unknown, trusting it at connect
time. This is only useful to be open during for bootstrapping these
hosts. As the comments say, empty it after your hosts have been
bootstrapped to avoid unpleasant surprises.

##### services_autorun

Off by default.

Turn this on (set to `any`) to auto-load files in `services/autorun`
and run bundles found that are tagged `autorun`. Here's a simple
example of such a bundle in `services/autorun/hello.cf`:

[%CFEngine_include_snippet(masterfiles/services/autorun/hello.cf)%]


##### cfengine_internal_rotate_logs

On by default. Rotates CFEngine's own logs. Here is the
`cfe_internal_log_rotation` bundle implementation:

[%CFEngine_include_snippet(masterfiles/cfe_internal/CFE_cfengine.cf, .+cfe_internal_log_rotation, \})%]

##### cfengine_internal_agent_email

On by default. Enables agent email output from `cf-execd`.

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
details. For details, see [LSB][LSB]

##### disable_inventory_dmidecode

By default, this class is turned off (and the module is on) if the
executable `/usr/sbin/dmidecode` can be found. This inventory module
will populate inventory reports and variables for you. For details,
see [DMI decoding][DMI decoding]

##### disable_inventory_LLDP

LLDP is a protocol for Link Layer Discovery. See
http://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol

By default, this class is turned off (and the module is on) if the
executable `/usr/bin/lldpctl` can be found. This inventory module will
populate variables for you. For details, see [LLDP][LLDP]

##### disable_inventory_package_refresh

By default, this class is turned off (and the module is on). This
inventory module will populate the installed packages for you. On
CFEngine Enterprise, the available packages will also be populated.

##### disable_inventory_mtab

By default, this class is turned off (and the module is on) if
`/etc/mtab` exists. This inventory module will populate variables for
you based on the mounted filesystems. For details, see [mtab][mtab]

##### disable_inventory_fstab

By default, this class is turned off (and the module is on) if
`$(sys.fstab)` (usually `/etc/fstab` or `/etc/vfstab`) exists. This
inventory module will populate variables for you based on the defined
filesystems. For details, see [fstab][fstab]

##### disable_inventory_proc

By default, this class is turned off (and the module is on) if `/proc`
is a directory. This inventory module will populate variables for you
from some of the contents of `/proc`. For details, see [procfs][procfs]

##### disable_inventory_cmdb

By default, this class is turned on (and the module is off).

Turn this on (set to `any`) to allow each client to load a `me.json`
file from the server and load its contents. For details, see [CMDB][CMDB]

### promises.cf

#### How it works

`promises.cf` is your main run file. Keep referring to your
installation's `promises.cf` as you read this.

`promises.cf` is the first file that `cf-agent` with no arguments will
try to look for. So whenever you see `cf-agent` with no flile
parameter, read it as "run my `promises.cf`".

It should contain all of the basic configuration
settings, including a list of other files to include. In normal
operation, it must also have a `bundlesequence`.

#### promises.cf configuration

##### bundlesequence

The `bundlesequence` acts like the 'genetic makeup' of the
configuration. Edit the `bundlesequence` to add any bundles you have
defined, or are pre-defined. Consider using the `services_autorun`
facility so you don't have to edit this setting at all.

**BEWARE THAT ONLY VALID (KNOWN) BUNDLES CAN BE ADDED.**

By default, the inventory modules, then internal hub modules, then
Design Center sketches, then the autorun services, and finally
internal management bundles are in the `bundlesequence`.

In a large configuration, you might want to have a different
`bundlesequence` for different classes of host, so that you can build
a complete system like a check-list from different combinations of
building blocks. You can construct different lists by composing them
from other lists, or you can use methods promises as an alternative
for composing bundles for different classes. This is an advanced topic
and a risky area (if you get it wrong, your policies will not
validate) so make sure you test your changes carefully!

##### inputs

In order to find bundles, CFEngine needs to know where to look. This
list defines what files are needed. Note there are several dynamic
entries here, coming from other bundles. CFEngine will keep evaluating
the `inputs` and `bundlesequence` until all the bundles are found and
resolved.

Make sure to add any of your own `services` files here if you don't
use the `services_autorun` facility, to ensure the bundles in them are
found.

## failsafe.cf

The `failsafe.cf` file ensures that your system can survive errors and
can upgrade gracefully to new versions even when mistakes are made.
It's literally a failsafe if `promises.cf` and `update.cf` should
fail.

This file is generated during the bootstrapping process, and should
normally never be changed. The only job of `failsafe.cf` is to execute
the update bundle in a “standalone” context should there be a syntax
error somewhere in the main set of promises. In this way, if a client
machine's policies are ever corrupted after downloading erroneous
policy from a server, that client will have a failsafe method for
downloading a corrected policy once it becomes available on the
server. Note that by “corrupted” and “erroneous” we typically mean
“broken via administrator error” - mistakes happen, and the
`failsafe.cf` file is CFEngine's way of being prepared for that
eventuality.

If you ever change `failsafe.cf` (or when you upgrade CFEngine), make
sure the old and the new CFEngine can successfully parse and execute
this file. If not, you risk losing control of your system (that is, if
CFEngine cannot successfully execute this policy file, it has no
failsafe/fallback mechanism for distributing new policy files).

Some general rules (but again, note you **can completely break your
CFEngine installation by editing `failsafe.cf`**):

* Upgrade the software first, then add new features to the configuration.
* Never use advanced features in the failsafe or update file.
* Avoid using library code (including any bodies from `stdlib.cf` or
the files it includes). Copy/paste any bodies you need using a unique
name that does not collide with a name in library (we recommend simply
adding the prefix “u_”). This may mean that you create duplicate
functionality, but that is okay in this case to ensure a 100%
functioning standalone update process). The promises which manage the
update process should not have any dependencies on any other files.

CFEngine will fail-over to the `failsafe.cf` configuration if it is
unable to read or parse the contents successfully. That means that any
syntax errors you introduce (or any new features you utilize in a
configuration) will cause a fail-over, because the parser will not be
able to interpret the policy. If the failover is due to the use of new
features, they will not parse until the software itself has been
updated (so we recommend that you always update CFEngine before
updating policy to use new features). If you accidentally cause a bad
(i.e., unparseable) policy to be distributed to client machines, the
`failsafe.cf` policy on those machines will run (and will eventually
download a working policy, once you fix it on the policy host).

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

## References

[LSB]: inventory/lsb.cf
[DMI decoding]: inventory/any.cf
[LLDP]: inventory/any.cf
[mtab]: inventory/any.cf
[fstab]: inventory/any.cf
[procfs]: inventory/any.cf
[CMDB]: inventory/any.cf

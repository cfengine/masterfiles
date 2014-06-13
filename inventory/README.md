# CFEngine 3 inventory modules

The CFEngine 3 inventory modules are pieces of CFEngine policy that
are loaded and used by the `promises.cf` mechanism in order to
*inventory* the system.

CFEngine Enterprise has specific functionality to show and use
inventory data, but users of the Community Version can use them as
well locally on each host.

## How It Works

The inventory modules are called in `promises.cf`:

```
body common control
{
      bundlesequence => {
                        # Common bundle first (Best Practice)
                          inventory_control,
                          @(inventory.bundles),
                          ...
```

As you see, this calls the `inventory_control` bundle, and then each
bundle in the list `inventory.bundles`. That list is built in the
top-level common `inventory` bundle, which will load the right things
for some common cases. The `any.cf` inventory module is always loaded;
the rest are loaded if they are appropriate for the platform. For
instance, Debian systems will load `debian.cf` and `linux.cf` and
`lsb.cf` but may load others as needed.

The effect for users is that the right inventory modules will be
loaded and evaluated.

The `inventory_control` bundle lives in `def.cf` and defines what
inventory modules should be disabled. You can simply set
`disable_inventory` to avoid the whole system, or you can look for the
`disable_inventory_xyz` class to disable module `xyz`.

Any inventory module works the same way, by doing some discovery work
and then tagging its classes and variables with the `report` or
`inventory` tags.  For example:

```
  vars:
      "ports" slist => { @(mon.listening_ports) },
      meta => { "inventory", "attribute_name=Ports listening" };
```

This defines a reported attribute "Ports listening" which contains a
list of strings representing the listening ports. More on this in a
second.

## Your Very Own Inventory Module

The good news is, writing an inventory module is incredibly easy.

They are just CFEngine bundles. You can see a simple one that collects
the listening ports in `any.cf`:

```
bundle agent cfe_autorun_inventory_listening_ports
# @brief Inventory the listening ports
#
# This bundle uses `mon.listening_ports` and is always enabled by
# default, as it runs instantly and has no side effects.
{
  vars:
      "ports" slist => { @(mon.listening_ports) },
      meta => { "inventory", "attribute_name=Ports listening" };
}
```

Well, the slist copy is a CFEngine detail (we get the listening ports
from the monitoring daemon), so just assume that the data is correct.
What's important is the second line that starts with
[`meta`][Promise Types and Attributes#meta]. That
defines metadata for the promise that CFEngine will use to determine
that this data is indeed inventory data and should be reported to the
CFEngine Enterprise Hub.

That's it. Really. The comments are optional but nice to have. You
don't have to put your new bundle in a file under the `inventory`
directory, either. The variables and classes can be declared anywhere
as long as they have the right tags. So you can use the `services`
directory or whatever else makes sense to you.

## CFEngine Enterprise vs. Community

In CFEngine Enterprise, the reported data is aggregated in the hub and
reported across the whole host population.

In CFEngine Community, users can use the `classesmatching()` and
`variablesmatching()` functions to collect all the inventory variables
and classes and report them in other ways.

## What Modules Are Available?

As soon as you use the `promises.cf` provided in the parent directory,
quite a few inventory modules will be enabled (if appropriate for your
system). Here's the list of modules and what they provide. Note they
are all enabled by code in `def.cf` as explained above.

### LSB

* lives in: `lsb.cf`
* applies to: LSB systems (most Linux distributions, basically)
* runs: `lsb_release -a`
* sample data:
```
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04 LTS
Release:	14.04
Codename:	trusty
```
* provides:
    * classes `lsb_$(os)`, `lsb_$(os)_$(release)`, `lsb_$(os)_$(codename)`
    * variables: `inventory_lsb.os` (Distributor ID), `inventory_lsb.codename`, `inventory_lsb.release`, `inventory_lsb.flavor`, `inventory_lsb.description`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/lsb.cf, .* )%]

* sample output:
```
% cf-agent -KI -binventory_control,inventory_lsb

R: inventory_lsb: OS = Ubuntu, codename = trusty, release = 14.04, flavor = Ubuntu_14_04, description = Ubuntu 14.04 LTS
```

### SUSE

* lives in: `suse.cf`
* applies to: SUSE Linux
* provides classes: `suse_pure` and `suse_derived`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/suse.cf, .* )%]

### Debian

* lives in: `debian.cf`
* applies to: Debian and its derivatives
* provides:
    * variables: `inventory_debian.mint_release` and `inventory_debian.mint_codename`
    * classes: `debian_pure`, `debian_derived`, `linuxmint`, `lmde`, `linuxmint_$(mint_release)`, `linuxmint_$(mint_codename)`, `$(mint_codename)`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/debian.cf, .* )%]

### Red Hat

* lives in: `redhat.cf`
* applies to: Red Hat and its derivatives
* provides classes: `redhat_pure`, `redhat_derived`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/redhat.cf, .* )%]

### Windows

* lives in: `windows.cf`

### Mac OS X

* lives in: `macos.cf`

### Generic (unknown OS)

* lives in: `generic.cf` (see `any.cf` for generally applicable inventory modules)

### LLDP

* lives in: `any.cf`
* runs `inventory_control.lldpctl_exec` through a Perl filter
* provides variables: `cfe_autorun_inventory_LLDP.K` for each `K` returned by the LLDB executable
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_LLDP, \})%]

### mtab

* lives in: `any.cf`
* parses: `/etc/mtab`
* provides classes: `have_mount_FSTYPE` and `have_mount_FSTYPE_MOUNTPOINT`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_mtab, \})%]

* sample output (note this is verbose mode with `-v` because there's a lot of output):

```
% cf-agent -Kv -binventory_control,cfe_autorun_inventory_mtab|grep 'cfe_autorun_inventory_mtab: we have'

R: cfe_autorun_inventory_mtab: we have a ext4 mount under /
...
R: cfe_autorun_inventory_mtab: we have a cgroup mount under /sys/fs/cgroup/systemd
R: cfe_autorun_inventory_mtab: we have a tmpfs mount under /run/shm
```

### fstab

* lives in: `any.cf`
* parses: `sys.fstab`
* provides classes: `have_fs_FSTYPE` `have_fs_MOUNTPOINT` and `have_fs_FSTYPE_MOUNTPOINT`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_fstab, \})%]

* sample output (note this is verbose mode with `-v` because there's a LOT of output):

```
% cf-agent -Kv -binventory_control,cfe_autorun_inventory_fstab|grep 'cfe_autorun_inventory_fstab: we have'

R: cfe_autorun_inventory_fstab: we have a ext4 fstab entry under /
R: cfe_autorun_inventory_fstab: we have a cifs fstab entry under /backups/load
R: cfe_autorun_inventory_fstab: we have a auto fstab entry under /mnt/cdrom
```

### CMDB

* lives in: `any.cf`
* parses: `me.json` (which is copied from the policy server; see implementation)
* provides classes: `CLASS` for each CLASS found under the ```classes``` key in the JSON data
* provides variables: `inventory_cmdb_load.VARNAME` for each VARNAME found under the `vars` key in the JSON data
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+inventory_cmdb_load, \})%]

### DMI decoding

* lives in: `any.cf`
* runs: `dmidecode`
* provides variables: `cfe_autorun_inventory_dmidecode.dmi[K]` for each key K in the `dmidecode` output
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_dmidecode, \})%]

* sample output (sudo is needed to access the DMI):

```
% sudo /var/cfengine/bin/cf-agent -KI -binventory_control,cfe_autorun_inventory_dmidecode

R: cfe_autorun_inventory_dmidecode: Obtained BIOS vendor = 'Intel Corp.'
R: cfe_autorun_inventory_dmidecode: Obtained BIOS version = 'BLH6710H.86A.0146.2013.1555.1888'
R: cfe_autorun_inventory_dmidecode: Obtained System serial number = ''
R: cfe_autorun_inventory_dmidecode: Obtained System manufacturer = ''
R: cfe_autorun_inventory_dmidecode: Obtained System version = ''
R: cfe_autorun_inventory_dmidecode: Obtained CPU model = 'Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz'
```

### Listening ports

* lives in: `any.cf`
* provides variables: `cfe_autorun_inventory_listening_ports.ports` as a copy of `mon.listening_ports`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_listening_ports, \})%]

### Disk space

* lives in: `any.cf`
* provides variables: `cfe_autorun_inventory_disk.free` as a copy of `mon.value_diskfree`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_disk, \})%]

### Available memory

* lives in: `any.cf`
* provides variables: `cfe_autorun_inventory_memory.free` as a copy of `mon.value_mem_free` and `cfe_autorun_inventory_memory.total` as a copy of `mon.value_mem_total`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_memory, \})%]

### Load average

* lives in: `any.cf`
* provides variables: `cfe_autorun_inventory_loadaverage.value` as a copy of `mon.value_loadavg`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_loadaverage, \})%]

### procfs

* lives in: `any.cf`
* parses: `consoles`, `cpuinfo`, `modules`, `partitions`, `version`
* provides variables: `cfe_autorun_inventory_proc.console_count`, `cfe_autorun_inventory_proc.cpuinfo[K]` for each CPU info key, `cfe_autorun_inventory_proc.paritions[K]` for each partition key
* provides classes: `_have_console_CONSOLENAME`, `have_module_MODULENAME`
* implementation:
[%CFEngine_include_snippet(masterfiles/inventory/any.cf, .+cfe_autorun_inventory_proc, \})%]

* sample output (note this is verbose mode with `-v` because there's a LOT of output):

```
% cf-agent -Kv -binventory_control,cfe_autorun_inventory_proc|grep 'cfe_autorun_inventory_proc: we have'

R: cfe_autorun_inventory_proc: we have console tty0

R: cfe_autorun_inventory_proc: we have module snd_seq_midi
...
R: cfe_autorun_inventory_proc: we have module ghash_clmulni_intel

R: cfe_autorun_inventory_proc: we have cpuinfo flags = fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid
...
R: cfe_autorun_inventory_proc: we have cpuinfo model name = Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz

R: cfe_autorun_inventory_proc: we have partitions sr0 with 1048575 blocks
...
R: cfe_autorun_inventory_proc: we have partitions sda with 468851544 blocks

R: cfe_autorun_inventory_proc: we have kernel version 'Linux version 3.11.0-15-generic (buildd@roseapple) (gcc version 4.8.1 (Ubuntu/Linaro 4.8.1-10ubuntu8) ) #25-Ubuntu SMP Thu Jan 30 17:22:01 UTC 2014'
```

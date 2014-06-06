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

## What Modules Are Available?

* LSB
* SUSE, Debian, and Red Hat
* Windows, Mac OS, and anything else (`generic`)
* LLDP
* mtab and fstab
* /proc (currently "consoles", "cpuinfo", "modules", "partitions", "version")
* CMDB (custom, server-side per-client parameter definitions)
* DMI decoding
* listening ports
* disk and memory
* load average

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
What's important is the second line that starts with `meta`. That
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

# CFEngine 3 masterfiles

CFEngine 3 is a popular open source configuration management system. Its primary
function is to provide automated configuration and maintenance of large-scale
computer systems.

This repository is intended to provide a stable base policy for
installations and upgrades, and is used by CFEngine 3.6 and newer.

The documentation for the masterfiles, highly recommended, is at

https://docs.cfengine.com/docs/master/guide-writing-and-serving-policy-policy-framework.html

## Installation

The contents of this repository are intended to live in `/var/cfengine/masterfiles` or wherever `$(sys.masterdir)` points.

If you have cloned the repository from github:

```
./autogen.sh
make install
```

If you have downloaded a release tarball, you don't need to run
`autogen.sh`. By default it installs in `/var/cfengine/masterfiles` but
you can override that easily:

```
./configure --prefix=/install/directory
make install
```

Note that the last directory component will always be called `masterfiles`.

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

## Contributing

Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file.

The CFEngine masterfiles are under the MIT license, see [LICENSE](LICENSE)

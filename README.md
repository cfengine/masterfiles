| Version | Core                                                                                                               | MPF                                                                                                                             |
|---------|--------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
|  master | [![Core Build Status](https://travis-ci.org/cfengine/core.svg?branch=master)](https://travis-ci.org/cfengine/core) | [![MPF Build Status](https://travis-ci.org/cfengine/masterfiles.svg?branch=master)](https://travis-ci.org/cfengine/masterfiles) |
|  3.12.x | [![Core Build Status](https://travis-ci.org/cfengine/core.svg?branch=3.12.x)](https://travis-ci.org/cfengine/core) | [![MPF Build Status](https://travis-ci.org/cfengine/masterfiles.svg?branch=3.12.x)](https://travis-ci.org/cfengine/masterfiles) |
|  3.10.x | [![Core Build Status](https://travis-ci.org/cfengine/core.svg?branch=3.10.x)](https://travis-ci.org/cfengine/core) | [![MPF Build Status](https://travis-ci.org/cfengine/masterfiles.svg?branch=3.10.x)](https://travis-ci.org/cfengine/masterfiles) |
|   3.7.x | [![Core Build Status](https://travis-ci.org/cfengine/core.svg?branch=3.7.x)](https://travis-ci.org/cfengine/core)  | [![MPF Build Status](https://travis-ci.org/cfengine/masterfiles.svg?branch=3.7.x)](https://travis-ci.org/cfengine/masterfiles)    |

Looking for help?

[![IRC channel](https://kiwiirc.com/buttons/irc.cfengine.com/cfengine.png)](https://kiwiirc.com/client/irc.cfengine.com/#cfengine)

[![Developer IRC channel](https://kiwiirc.com/buttons/irc.freenode.net/cfengine-dev.png)](https://kiwiirc.com/client/irc.cfengine.com/#cfengine-dev)

# CFEngine 3 masterfiles

CFEngine 3 is a popular open source configuration management system. Its primary
function is to provide automated configuration and maintenance of large-scale
computer systems.

The MPF or Masterfiles Policy Framework is intended to provide a stable base
policy installations and upgrades, and is used by both CFEngine Enterprise and
CFEngine community in versions 3.6 and newer.
The
[documentation for the MPF](https://docs.cfengine.com/docs/master/reference-masterfiles-policy-framework.html) is
highly recommended.

## Installation

There are several methods available for installing the CFEngine Masterfiles
Policy Framework.

* From pkg tarball
* From git
* From source tarball

### From pkg tarball

If you have downloaded
a [package tarball from our website](https://cfengine.com/product/community/)
(not from github), you don't need to `autogen`, `configure` or `make` anything.
Instead simply unpack the tarball to the desired location using `tar`.

For example:

```
tar zxvf cfengine-masterfiles-MAJOR.MINOR.PATCH.pkg.tar.gz --exclude="modules" -C /var/cfengine/masterfiles --strip-components=2
```

**Note:** The above command installs only the policy from masterfiles. Typically
the modules that are distributed within the masterfiles repository are not
installed until the binaries are upgraded. However, if you wish to install the modules along with the policy you can use this simplified command:

```
tar zxvf cfengine-masterfiles-MAJOR.MINOR.PATCH.pkg.tar.gz /var/cfengine/masterfiles
```

### From git

Clone this repository

```
git clone https://github.com/cfengine/masterfiles
```

If you have cloned the repository from github:

Run autogen and make to build masterfiles.

```
./autogen.sh
make
```

Optionally configure masterfiles to install to a different location (perhaps your
own version control checkout)

```
./configure --prefix=/tmp/cfengine/
make
```

```
make install
```

### From source tarball

If you have downloaded
a [release tarball from our website](https://cfengine.com/product/community/)
(not from github), you don't need to run `autogen.sh`. By default it installs in
`/var/cfengine/masterfiles` but you can override that easily:

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
R: Host info report generated and available at '/var/cfengine/reports/host_info_report.txt'
```

Take a look at the resulting file, it has lots of useful information about the system.

## Contributing

Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file.

The CFEngine masterfiles are under the MIT license, see [LICENSE](LICENSE)

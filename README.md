Looking for help?
* [Chat with us in #CFEngine:matrix.org](https://matrix.to/#/#CFEngine:matrix.org).
* Ask questions on [Github Discussions](https://github.com/cfengine/core/discussions/) or the mailing list [help-cfengine@googlegroups.com](https://groups.google.com/g/help-cfengine).

# CFEngine 3 masterfiles

CFEngine 3 is a popular open source configuration management system. Its primary
function is to provide automated configuration and maintenance of large-scale
computer systems.

The MPF or Masterfiles Policy Framework is intended to provide a stable base
policy for installations and upgrades, and is used by both CFEngine Enterprise and
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

# Authors

CFEngine was originally created by Mark Burgess with many contributions from
around the world. Thanks [everyone](https://github.com/cfengine/core/blob/master/AUTHORS)!

[CFEngine](https://cfengine.com) is sponsored by [Northern.tech AS](https://northern.tech)

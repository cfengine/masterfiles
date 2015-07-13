Package Module API
==================

This document describes how to create a package module for the CFEngine package
promise. Package modules are backends that enable the package promise to work
with different types of platform package managers.


The CFEngine side
-----------------

CFEngine never calls any package manager commands, it only ever calls the
package module. The information that CFEngine deals in is:

  * Which packages are currently installed:
    * Name
    * Version
    * Architecture
  * Which of the installed packages have updates available:
    * Name
    * Version
    * Architecture

These two lists are everything that CFEngine needs to know to decide whether its
package promises are fulfilled or not. In addition to this it will carry out
package operations by asking the package module to do certain tasks, but in the
end, the result of the operation is always determined by comparing the promise
against those two lists. Therefore it is very important that the package module
has a robust and deterministic way of returning these lists.

To take one example: When a package is installed, CFEngine does not really care
what the return code of the operation is, the reason being that not all package
managers can be trusted to return the correct return code (yum has a tendency to
always report success, for instance). Instead, it ignores the return code, and
instead asks for the list of currently installed packages after the
installation, and if the package we tried to install has not appeared, it knows
that the promise failed.

In the same fashion, if we try to install an update, that update is expected to
disappear from the list of available updates after the operation.


The package module
------------------

The package module itself is simply an executable, and can be in any executable
format, whether than is Python, Perl, Shell script or native binary.

The package module resides in the /var/cfengine/modules/packages both on the hub
and the clients, and out of the box CFEngine is set up to synchronize this
directory among its clients. For this reason it is advised to avoid native
binary formats for package modules, to reduce the burden of distribution to
different platforms, but the API does not forbid it, and it may be useful in
some circumstances.


The API
-------

The API consists of commands which are passed in the module arguments, combined
with a simple text protocol that will be fed on the module's standard input, and
replies are expected on its standard output.

In the examples below we use simple "Here Documents" to show how standard input
can be passed to a package module in order to produce the indented output or
effect. If you don't know about Here Documents, the man page for bash is a good
place to read about them. During actual execution, the input will come from
CFEngine itself.

The API commands are listed roughly in the order that they should be
implemented, in order to facilitate a nice debugging cycle during development.


### options attribute

All the API commands listed below, except `supports-api-version`, support the
`options` attribute. This attribute will contain the contents from the `options`
attribute in the promise, or the `default_options` in the package module body,
if the former is unspecified. This attribute has no inherent meaning to
CFEngine, and will be passed verbatim. It is meant as a mechanism to communicate
special attributes to the package module that are not covered by the main
API. For example, for certain package modules it may be used to pass a
repository URL.

The `options` attribute will not be explicitly listed in the examples below, but
it is valid in all of them except `supports-api-version`, even when the
description reads "no input".


### supports-api-version

The very first command that any package module must implement is
`supports-api-version`. This command takes no input, and is expected to print
a single digit followed by a newline. This is simply a way for CFEngine and the
package module to agree on which version of the protocol to use. For now there
is only one such version, and the expected output is simply "1".

This is the only command which does not support the `options` attribute.

Example:

```
$ ./package-module supports-api-version < /dev/null
1
$
```


### get-package-data

CFEngine uses this command to determine what kind of promise has been
made. Currently two types are supported: "file" and "repo".

The input is expected to be a triplet of `Name/Version/Architecture`, where
`Name` is the promiser string from the promise, and `Version` and `Architecture`
contain the strings from the corresponding promise attributes, if they were
specified. This implies that either one of `Version` and `Architecture` may not
be included, so some entries may only contain `Name` or `Name` with one more
attribute.

What the module should do is figure out whether the string passed in `Name` is
referring to a file based or a repository based package. Exactly what identifies
each one is up to the package module, but generally it means that file based
packages should refer to actual files on the file system, whereas repository
based packages should refer to package names that a "smart" package manager can
resolve, such as for instance "apt". There are exceptions to this rule however,
for example if a string is a URL referring to a downloadable package file, the
type of package would still be file based, since it refers to a single package
file which is not part of a repository.

The module should start by returning one attribute `PackageType`, which should
be either `file` or `repo`. Next, it should return the proper name of the
package in a `Name` attribute. Proper name means the name that will be displayed
in package listings, so for example, `/home/johndoe/zip-3.0-4.el5.x86_64.rpm`
would resolve to simply `zip`. For repository based package name, in most cases
the returned `Name` will be the same as what what passed in, but this may not be
the case for all package managers.

Next, for file based package name it should return `Version` and `Architecture`
if it is able to determine these, but it is allowed to omit them if the module
doesn't know (if the resource is remote, for instance).

For repository based package names the module should *not* return `Version` and
`Architecture`, since they are often ambiguous in repository situations, and any
discrepancies will be handled at the install stage instead.

Example 1:

```
$ ./package-module get-package-data <<EOF
Name=zip
Version=3.0-4
Architecture=amd64
EOF
PackageType=repo
Name=zip
$
```

Example 2:

```
$ ./package-module get-package-data <<EOF
Name=zip
EOF
PackageType=repo
Name=zip
$
```

Example 3:

```
$ ./package-module get-package-data <<EOF
Name=/home/johndoe/zip-3.0-4.el5.x86_64.rpm
Version=3.0-4
Architecture=amd64
EOF
PackageType=file
Name=zip
Version=3.0-4
Architecture=amd64
$
```

Example 4:

```
$ ./package-module get-package-data <<EOF
Name=/home/johndoe/zip-3.0-4.el5.x86_64.rpm
EOF
PackageType=file
Name=zip
Version=3.0-4
Architecture=amd64
$
```


### list-installed

This command is expected to return a list of all currently installed packages on
the system. It takes no input, and the output is expected to be a list of
triplets of `Name/Version/Architecture`.

Example:

```
$ ./package-module list-installed < /dev/null
Name=zip
Version=3.0-4
Architecture=amd64
Name=libc6
Version=2.15
Architecture=amd64
Name=libc6
Version=2.15
Architecture=i386
...
$
```

### list-updates

This command is expected to return a list of all the available updates for
currently installed updates. The command takes no input, and the output is
expected to be a list of triplets of `Name/Version/Architecture`.

It is not an error to include updates to packages that are not installed, but
this information will not be used, and it is therefore recommended to omit it
for performance purposes.

If the available updates come from an external source, such as an online
repository service or a remote file server, this command is expected to fetch
the information from there. CFEngine will make sure that this command is not
called too often, so there is no need to try to limit the online resource usage
in this command. See more about caching and `list-updates-local` below.

Example:

```
$ ./package-module list-updates < /dev/null
Name=zip
Version=3.0-4
Architecture=amd64
Name=libc6
Version=2.15
Architecture=amd64
Name=libc6
Version=2.15
Architecture=i386
...
$
```


### list-updates-local

This command is expected to return a list of all the available updates for
currently installed updates. The command takes no input, and the output is
expected to be a list of triplets of `Name/Version/Architecture`.

It is not an error to include updates to packages that are not installed, but
this information will not be used, and it is therefore recommended to omit it
for performance purposes.

Unlike `list-updates`, this command is *not* expected to use the network to
fetch information from external sources, but should fetch all the information
from local storage. This command exists precisely to limit such expensive
operations.

Example:

```
$ ./package-module list-updates-local < /dev/null
Name=zip
Version=3.0-4
Architecture=amd64
Name=libc6
Version=2.15
Architecture=amd64
Name=libc6
Version=2.15
Architecture=i386
...
$
```


### repo-install

This command is used by CFEngine to ask the package module to install packages
from the package repository. Note that CFEngine itself has no notion of *which*
package repository it should come from. This is up to the package module, and
may either be a platform configured default, such as is the case for for example
yum, or a specific repository which is passed in via the `options`
attribute. The command will be called for promises where `get-package-data`
returned `PackageType=repo`.

The command takes a list of triplets, `Name`, `Version` and `Architecture`,
where the last two may be omitted. In this case the module is expected to
provide some default, which is usually the latest version and the native
platform architecture.

No output is expected.

Example:

```
$ ./package-module repo-install <<EOF
Name=zip
Name=libc6
Version=2.15
Architecture=amd64
Name=libc6
Version=2.15
Architecture=i386
EOF
$
```


### file-install

This command is used by CFEngine to ask the package module to install a specific
package file. The command will be called for promises where `get-package-data`
returned `PackageType=file`.

The command takes a list of triplets, `File`, `Version` and `Architecture`,
where the last two may be omitted. For package files that can contain more than
one package, the last two attributes may be used to select the correct one. The
command should never be called with attributes that are not present in the
package, since this will already have been detected after querying
`get-package-data`.

No output is expected.

Example:

```
$ ./package-module file-install <<EOF
File=/mnt/storage/zip-3.0-4.el5.x86_64.rpm
File=/mnt/storage/libc6-2.15.el5.i386.rpm
Version=2.15
Architecture=i386
EOF
$
```


### remove

To remove packages, CFEngine will call the package module with the `remove`
command.

The command takes a list of triplets, `Name`, `Version` and `Architecture`,
where the last two may be omitted. If so, the module is expected to remove all
packages matching the other attribute(s). Note that `Name` is the basename of
the package, the same format that `get-package-data` returns in `Name`.

No output is expected.

Example:

```
$ ./package-module remove <<EOF
Name=zip
Name=libc6
Version=2.15
Architecture=amd64
Name=libc6
Version=2.15
Architecture=i386
EOF
$
```


Error messages
--------------

All of the package module commands except `supports-api-version` have the option
of returning error messages. The error messages are simply an attribute
`ErrorMessage` with a string, which may optionally be preceded by whatever
`Name` or `File` triplet was given to the command initially, in order to tie it
to a specific promise.

Example:

```
$ ./package-module file-install <<EOF
File=/mnt/storage/zip-3.0-4.el5.x86_64.rpm
File=/mnt/storage/libc6-2.15.el5.i386.rpm
Version=2.15
Architecture=i386
EOF
File=/mnt/storage/zip-3.0-4.el5.x86_64.rpm
ErrorMessage=File not found
File=/mnt/storage/libc6-2.15.el5.i386.rpm
Version=2.15
Architecture=x86_64
ErrorMessage=Doesn't contain architecture 'x86_64'
$
```


Other output
------------

CFEngine does not expect any other output on the package module's standard
output, so the module should make sure it silences the output from its sub
commands. Alternatively, it may redirect their output to standard error instead,
but this will not be formatted using CFEngine's normal log formatting and is not
recommended.


Caching
-------

For performance reasons, CFEngine will cache the list of packages returned from
`list-packages` and the list of updates from either of `list-updates` or
`list-updates-local`. The exact circumstances where each is called is:

  * `list-packages`: When either the system is changed, or
    `query_installed_ifelapsed` in the policy has expired.

  * `list-updates`: Only when `query_updates_ifelapsed` in the policy has expired.

  * `list-updates-local`: Only when the system is changed.

Whenever one is called its result is cached by CFEngine and will be used
internally. It is a good idea to set the two policy attributes,
`query_installed_ifelapsed` and `query_updates_ifelapsed` to zero during module
development to avoid any issues with caching during debugging, but they should
be set back when deploying in production.

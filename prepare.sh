#!/bin/sh

set -e

if [ $# = 0 ] || [ $1 != "-y" ]; then
  echo "WARNING: This script deletes files and directories, including itself."
  echo "Never run it in your development clone of MPF!"
  echo -n "Do you really want to continue? [y/N] "
  read ans
  if [ x$ans != "xy" ] && [ x$ans != "xY" ]; then
    exit 0
  fi
fi

cd "$(dirname $0)"

# Prefer EXPLICIT_VERSION variable over running the shell script,
# this means you can set it explicitly, for example from CFEngine Build steps:
if [ -z $EXPLICIT_VERSION ]
then
  echo "Running determine-version.sh ..."
  rm -f CFVERSION
  misc/determine-version.sh .CFVERSION > CFVERSION \
      || echo "Unable to auto-detect CFEngine version, continuing"
else
  echo "Using version number from env: EXPLICIT_VERSION=$EXPLICIT_VERSION"
  echo $EXPLICIT_VERSION > CFVERSION
fi

# Same for release, can be overriden explicitly from env var:
if [ -z $EXPLICIT_RELEASE ]
then
  echo "Running determine-release.sh ..."
  rm -f CFRELEASE
  misc/determine-release.sh CFRELEASE \
      || { echo "Unable to auto-detect CFEngine release, continuing"; echo 1 >CFRELEASE; }
else
  echo "Using release number from env: EXPLICIT_RELEASE=$EXPLICIT_RELEASE"
  echo $EXPLICIT_RELEASE > CFRELEASE
fi

# CFVERSION file may look like this: 3.18.4-2 and this matches a tag
# However, for the version variable here, used to put into policy files
# we don't want the -2 part. That part should go into the other variable
# called release:
version=$(cat CFVERSION | awk -F"-" '{print $1}')
# The code above should already have parsed tags / env var and put the correct
# thing or default in CFRELEASE, no need to do more awk here:
release=$(cat CFRELEASE)
prefix="/var/cfengine"

templates=$(find . -name .git -prune -o -name '*.in' -print)
for template in $templates; do
  sed -e "s|@VERSION@|$version|g" -e "s|@RELEASE@|$release|g" -e "s|@prefix@|$prefix|g" $template > ${template%%.in}
done

find . -name .git -prune -o -type f -print | xargs chmod u=rw,g=-,o=-
find . -name .git -prune -o -type d -print | xargs chmod u=rwx,g=-,o=-

cat <<EOF | xargs rm -rf
aclocal.m4
autogen.sh
autom4te.cache
CFRELEASE
.CFVERSION
CFVERSION
CHANGELOG.md
CODE_OF_CONDUCT.org
config.guess
config.log
config.status
config.sub
configure
configure.ac
CONTRIBUTING.md
example_def.json
.git
.gitignore
install-sh
m4
.mailmap
Makefile
Makefile.am
Makefile.in
misc
missing
MPF.md
README.md
test-driver
tests
cfe_internal/core/watchdog/README.md
cfe_internal/enterprise/ha/ha_info.json
.github
inventory/README.md
lib/README.md
LICENSE
modules/promises
.no-distrib
services/autorun/README.md
templates/README.md

$templates
$(basename $0)
EOF

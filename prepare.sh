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

templates=$(find . -name .git -prune -o -name '*.cf.in' -print)
./render-templates.sh

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

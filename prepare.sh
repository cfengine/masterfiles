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

echo "Running determine-version.sh ..."
rm -f CFVERSION
misc/determine-version.sh .CFVERSION > CFVERSION \
    || echo "Unable to auto-detect CFEngine version, continuing"

export RELEASE="1"
echo "Running determine-release.sh ..."
rm -f CFRELEASE
misc/determine-release.sh CFRELEASE \
    || { echo "Unable to auto-detect CFEngine release, continuing"; echo 1 >CFRELEASE; }

version=$(cat CFVERSION | awk -F"-" '{print $1}')
release=$(cat CFRELEASE)
prefix="/var/cfengine/"

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
travis-scripts
.travis.yml

$templates
$(basename $0)
EOF

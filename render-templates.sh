#!/bin/sh

set -e

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
version_without_commit=$(cat CFVERSION | awk -F'a.' '{print $1}')
# The code above should already have parsed tags / env var and put the correct
# thing or default in CFRELEASE, no need to do more awk here:
release=$(cat CFRELEASE)
prefix="/var/cfengine"

templates=$(find . -name .git -prune -o -name '*.cf.in' -print)
for template in $templates; do
  sed -e "s|@VERSION@|$version|g" -e "s|@RELEASE@|$release|g" -e "s|@prefix@|$prefix|g" -e "s|@DEFAULT_SELF_UPGRADE_BINARY_VERSION@|$version_without_commit|g" $template > ${template%%.in}
done

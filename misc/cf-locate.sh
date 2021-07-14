#!/usr/bin/env sh

if [[ $# -eq 0 ]] ; then
  echo "Usage: $0 [-f] BODY_OR_BUNDLE_REGEX"
  echo "       -f print out full content of body or bundle"
  exit 0
fi
prefix="^\s*(body|bundle).*"
while getopts f option
do
  case "${option}" in
    f)
      find . -name '*.cf' | xargs awk "/$prefix$2/,/^}/"
      exit 0
  esac
done
find . -name '*.cf' | xargs grep -n -E "$prefix$1"

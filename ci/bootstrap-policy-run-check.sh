#!/usr/bin/env bash
set -ex

# find the dir two levels up from here, home of all the repositories
COMPUTED_ROOT="$(readlink -e "$(dirname "$0")/../../")"
# NTECH_ROOT should be the same, but if available use it so user can do their own thing.
NTECH_ROOT=${NTECH_ROOT:-$COMPUTED_ROOT}

if docker ps | grep mpf; then
  docker stop mpf
fi
if docker ps -a | grep mpf; then
  docker rm mpf
fi
docker build -t mpf -f "${NTECH_ROOT}"/masterfiles/ci/Dockerfile  "${NTECH_ROOT}"/masterfiles
if docker run --name mpf mpf sh -c "grep error: *.log"; then
  echo "fail"
  exit 1
else
  echo "success"
fi

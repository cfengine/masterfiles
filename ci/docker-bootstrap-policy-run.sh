#!/usr/bin/env bash
set -ex

# find the dir two levels up from here, home of all the repositories
COMPUTED_ROOT="$(readlink -e "$(dirname "$0")/../../")"
# NTECH_ROOT should be the same, but if available use it so user can do their own thing.
NTECH_ROOT=${NTECH_ROOT:-$COMPUTED_ROOT}

cd "${NTECH_ROOT}/masterfiles"

# cleanup
rm -f update.log bootstrap.log promise.log
if docker ps | grep mpf; then
  docker stop mpf
fi
if docker ps -a | grep mpf; then
  docker ps -a | grep mpf | awk '{print $1}' | xargs docker rm
fi
if docker images | grep mpf; then
  docker rmi mpf
fi

# run the test
docker build -t mpf -f "${NTECH_ROOT}"/masterfiles/ci/bootstrap-policy-run.Dockerfile  "${NTECH_ROOT}"/masterfiles
docker run --workdir /mpf --volume "${NTECH_ROOT}"/masterfiles:/mpf --tty mpf sh /mpf/ci/bootstrap-policy-run.sh
if grep error *.log; then
  echo "fail"
  exit 1
else
  echo "success"
fi

#!/usr/bin/env sh
set -ex
./autogen.sh --prefix=/var/lib/cfengine
make install
which cf-agent
cf-agent -IB $(hostname -i) | tee bootstrap.log
cf-agent -KIf update.cf | tee update.log
cf-agent -KI | tee promise.log
cf-agent -KI | tee -a promise.log
cf-agent -KI | tee -a promise.log

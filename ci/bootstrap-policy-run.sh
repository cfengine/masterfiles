#!/usr/bin/env sh
set -ex
if [ -f ../core/ci/install.sh ]; then
  ../core/ci/install.sh
else
  # here we use community so that masterfiles has less errors when bootstrapping as it expects an enterprise hub with the -nova package
  PATH=/root/.local/bin:$PATH cf-remote --version "$CFENGINE_VERSION" install --edition community --clients localhost
fi
./autogen.sh
make install
export PATH=/var/cfengine/bin:$PATH
which cf-agent
ps -efl | grep cf- # debug cf-serverd already running somehow?
cf-agent -IB $(hostname -i) | tee bootstrap.log
cf-agent -KIf update.cf | tee update.log
cf-agent -KI | tee promise.log
cf-agent -KI | tee -a promise.log
cf-agent -KI | tee -a promise.log

#!/bin/bash
#
# A script to pull items for fr_distributed_cleanup.py script from a given hub to local
#
# $@ -- one or more hub hostname/IP to pull items from
#

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"

# check that we have all the variables we need
true "${CFE_FR_SSH?undefined}"

true "${CFE_FR_DISTRIBUTED_CLEANUP_DIR?undefined}"
true "${CFE_FR_TRANSPORTER?undefined}"
true "${CFE_FR_TRANSPORTER_ARGS?undefined}"
true "${CFE_FR_FEEDER_USERNAME?undefined}"

if [ $# = 0 ]; then
  log "Must provide at least one hub hostname/IP to $0, exiting!"
  exit 1
fi

for feeder in $@; do
  feeder_hostname=$("$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" hostname -f)
  "$CFE_FR_TRANSPORTER" $CFE_FR_TRANSPORTER_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}:/$CFE_FR_DISTRIBUTED_CLEANUP_DIR/${feeder_hostname}.pub" "$CFE_FR_DISTRIBUTED_CLEANUP_DIR/" &&
  "$CFE_FR_TRANSPORTER" $CFE_FR_TRANSPORTER_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}:/$CFE_FR_DISTRIBUTED_CLEANUP_DIR/${feeder_hostname}.cert" "$CFE_FR_DISTRIBUTED_CLEANUP_DIR/" ||
    log "Failed to pull fr_distributed_cleanup items from hub $feeder"
done


# check that hubs.cert is the most recent *.cert file, if not then update it
# from the other cert files (all the hubs).
ls -t1 $CFE_FR_DISTRIBUTED_CLEANUP_DIR/*.cert | head -n1 | grep -q hubs.cert || sed -sn 'p' $(ls $CFE_FR_DISTRIBUTED_CLEANUP_DIR/*.cert | grep -v hubs.cert) > "$CFE_FR_DISTRIBUTED_CLEANUP_DIR/hubs.cert"

for feeder in $@; do
  "$CFE_FR_TRANSPORTER" $CFE_FR_TRANSPORTER_ARGS "$CFE_FR_DISTRIBUTED_CLEANUP_DIR/hubs.cert" "$CFE_FR_FEEDER_USERNAME@${feeder}:/$CFE_FR_DISTRIBUTED_CLEANUP_DIR/" ||
    log "Failed to transfer superhub certificate to hub $feeder"
done

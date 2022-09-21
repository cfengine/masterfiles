#!/bin/bash
#
# A script to pull dumps from a given feeder hub to the $PWD/$feeder folder.
#
# $1 -- feeder hub hostname/IP to pull the dumps from
#

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"

# check that we have all the variables we need
true "${CFE_FR_TRANSPORT_DIR?undefined}"
true "${CFE_FR_SUPERHUB_DROP_DIR?undefined}"
true "${CFE_FR_THIS_HOSTKEY?undefined}"
true "${CFE_FR_TRANSPORTER?undefined}"
true "${CFE_FR_TRANSPORTER_ARGS?undefined}"
true "${CFE_FR_SSH?undefined}"
true "${CFE_FR_SSH_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_FEEDER_USERNAME?undefined}"

if [ $# != 1 ]; then
  log "Invalid number of arguments ($#) given to $0, exiting!"
  exit 1
fi

feeder="$1"

mkdir -p "$feeder"

REMOTE_DIR="$CFE_FR_TRANSPORT_DIR/$CFE_FR_THIS_HOSTKEY"
"$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" "test -d $REMOTE_DIR" ||
  {
    REMOTE_DIR="$CFE_FR_TRANSPORT_DIR"
    log "Trying fallback dump directory $REMOTE_DIR. Upgrade masterfiles on feeder to enable multiple superhubs pulling from one feeder."
  }
"$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" "test -e $REMOTE_DIR/*.sql.$CFE_FR_COMPRESSOR_EXT" ||
  {
    log "No files to transport."
    exit 0
  }

# move the files so that they don't get overwritten/deleted during the transport
"$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" "mkdir $REMOTE_DIR/$$.transporting"
"$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" "mv $REMOTE_DIR/*.sql.$CFE_FR_COMPRESSOR_EXT $REMOTE_DIR/$$.transporting/"

failed=0
"$CFE_FR_TRANSPORTER" $CFE_FR_TRANSPORTER_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}:/$REMOTE_DIR/$$.transporting/*.sql.$CFE_FR_COMPRESSOR_EXT" "$feeder/" ||
  failed=1

"$CFE_FR_SSH" $CFE_FR_SSH_ARGS "$CFE_FR_FEEDER_USERNAME@${feeder}" "rm -rf $REMOTE_DIR/$$.transporting"

if [ "$failed" != "0" ]; then
  touch "$feeder.failed"
  rm -rf "$feeder"
  exit 1
fi

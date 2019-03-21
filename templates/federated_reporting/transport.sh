#!/bin/bash

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"

# check that we have all the variables we need
true "${CFE_FR_TRANSPORT_DIR?undefined}"
true "${CFE_FR_SUPERHUB_DROP_DIR?undefined}"
true "${CFE_FR_TRANSPORTER?undefined}"
true "${CFE_FR_TRANSPORTER_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_SUPERHUB_LOGIN?undefined}"

if ! type "$CFE_FR_TRANSPORTER" >/dev/null; then
  log "Transporter $CFE_FR_TRANSPORTER not available!"
  exit 1
fi

dump_files="$(ls -1 "$CFE_FR_TRANSPORT_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT" 2>/dev/null)" ||
  {
    log "No files to transport."
    exit 0
  }

log "Transporting files: $dump_files"
some_failed=0
for dump_file in $dump_files; do
  failed=0
  mv "$dump_file" "$dump_file.transporting"
  "$CFE_FR_TRANSPORTER" "$CFE_FR_TRANSPORTER_ARGS" "$dump_file.transporting" "$CFE_FR_SUPERHUB_LOGIN:$CFE_FR_SUPERHUB_DROP_DIR/$(basename "$dump_file")" &&
    rm -f "$dump_file.transporting" || failed=1
  if [ "$failed" != 0 ]; then
    log "Transporting file $dump_file failed!"
    some_failed=1
  fi
done

if [ "$some_failed" != "0" ]; then
  log "Transporting files: FAILED"
  exit 1
else
  log "Transporting files: DONE"
fi

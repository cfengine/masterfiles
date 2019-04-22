#!/bin/bash

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"

# check that we have all the variables we need
true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_DUMP_DIR?undefined}"
true "${CFE_FR_TRANSPORT_DIR?undefined}"
true "${CFE_FR_COMPRESSOR?undefined}"
true "${CFE_FR_COMPRESSOR_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_FEEDER?undefined}"
true "${CFE_FR_TABLES?undefined}"
true "${CFE_FR_FEEDER_USERNAME?undefined}"

mkdir -p "$CFE_FR_DUMP_DIR"
mkdir -p "$CFE_FR_TRANSPORT_DIR"
chown "$CFE_FR_FEEDER_USERNAME" "$CFE_FR_TRANSPORT_DIR"

if ! type "$CFE_FR_COMPRESSOR" >/dev/null; then
  log "Compressor $CFE_FR_COMPRESSOR not available!"
  exit 1
fi

failed=0
ts="$(date -Iseconds)"  # ISO 8601 format that doesn't have spaces in it
in_progress_file="$CFE_FR_DUMP_DIR/$CFE_FR_FEEDER_$ts.sql.$CFE_FR_COMPRESSOR_EXT.dumping"

log "Dumping tables: $CFE_FR_TABLES"
"$CFE_BIN_DIR"/pg_dump --inserts --data-only $(printf ' -t "%s"' $CFE_FR_TABLES) cfdb |
  "$CFE_FR_COMPRESSOR" $CFE_FR_COMPRESSOR_ARGS > "$in_progress_file" || failed=1

if [ "$failed" != "0" ]; then
  log "Dumping tables: FAILED"
  echo "$in_progress_file" >> "$CFE_FR_DUMP_DIR/failed"
  rm -f "$in_progress_file"
  exit 1
else
  log "Dumping tables: DONE"
  mv "$in_progress_file" "$CFE_FR_TRANSPORT_DIR/$CFE_FR_FEEDER.sql.$CFE_FR_COMPRESSOR_EXT"
  chown "$CFE_FR_FEEDER_USERNAME" "$CFE_FR_TRANSPORT_DIR/$CFE_FR_FEEDER.sql.$CFE_FR_COMPRESSOR_EXT"
fi

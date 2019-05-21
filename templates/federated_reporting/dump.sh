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

# switch to using --exclude-table=table or --tables
# tables can include views, mat views, sequences, foreign tables
# pattern according to the same rules used by psql's \d commands, include wildcard characters for __promiselog_* !!!
# let's experiment with no --inserts and instead rely on the default of COPY, since that is much faster and due to partitioning should not be such a problem :)
# so for a first go, just do a simple naive dump!!! `pg_dump cfdb` ---->
# if I use the simple case I get all the functions without ifexists or anything, so try --clean and --if-exists
# keep the plain text format for granular error reporting. :)
# --no-owner for me as I am running this locally, wouldn't be a problem in production
# <2019-06-09 Sun 21:47> remove --clean and --if-exists, the schema should always be empty to start with
log "Dumping tables: $CFE_FR_TABLES"
"$CFE_BIN_DIR"/pg_dump --no-owner cfdb |
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

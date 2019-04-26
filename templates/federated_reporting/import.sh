#!/bin/bash

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"
source "$(dirname "$0")/parallel.sh"

# check that we have all the variables we need
true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_SUPERHUB_DROP_DIR?undefined}"
true "${CFE_FR_SUPERHUB_IMPORT_DIR?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_EXTRACTOR?undefined}"
true "${CFE_FR_TABLES?undefined}"
true "${CFE_FR_INVENTORY_REFRESH_CMD?undefined}"

if ! type "$CFE_FR_EXTRACTOR" >/dev/null; then
  log "Extractor $CFE_FR_EXTRACTOR not available!"
  exit 1
fi

# TODO: we should do some validation of the files here
mkdir -p "$CFE_FR_SUPERHUB_IMPORT_DIR"
no_drop_files=0
ls -l "$CFE_FR_SUPERHUB_DROP_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT" >/dev/null 2>/dev/null ||
  no_drop_files=1

if [ "$no_drop_files" != "0" ]; then
  log "No files in drop dir."
else
  log "Moving files from drop dir to import dir."
  mv "$CFE_FR_SUPERHUB_DROP_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT" "$CFE_FR_SUPERHUB_IMPORT_DIR" ||
    log "Failed to move files from drop dir to import dir."
fi

dump_files="$(ls -1 "$CFE_FR_SUPERHUB_IMPORT_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT" 2>/dev/null)" ||
  {
    log "No files to import."
    exit 0
  }

log "Database cleanup"
{
  cat<<EOF
\set QUIET on
\set ON_ERROR_STOP 1
SET session_replication_role = replica;
EOF
  # XXX: this needs to be moved into the importing transaction once partitioning
  #      is done
  printf 'TRUNCATE %s;\n' $CFE_FR_TABLES
} | "$CFE_BIN_DIR"/psql -U cfpostgres -d cfdb
log "Database cleanup: DONE"

# make sure the script we are about to run is executable
chmod u+x "$(dirname "$0")/import_file.sh"

log "Importing files: $dump_files"
failed=0
echo "$dump_files" | run_in_parallel "$(dirname "$0")/import_file.sh" - $CFE_FR_IMPORT_NJOBS ||
  failed=1

if [ "$failed" != "0" ]; then
  log "Importing files: FAILED"
  for file in "$CFE_FR_SUPERHUB_IMPORT_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT.failed"; do
    log "Failed to import file '${file%%.failed}'"
    rm -f "$file"
  done
  exit 1
else
  log "Importing files: DONE"
  if [ -n "$CFE_FR_INVENTORY_REFRESH_CMD" ]; then
    log "Refreshing inventory"
    inv_refresh_failed=0
    $CFE_FR_INVENTORY_REFRESH_CMD || inv_refresh_failed=1
    if [ "$inv_refresh_failed" != "0" ]; then
      log "Refreshing inventory: FAILED"
      exit 1
    else
      log "Refreshing inventory: DONE"
    fi
  fi
fi

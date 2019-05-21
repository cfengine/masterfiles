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

# make sure the script we are about to run is executable
chmod u+x "$(dirname "$0")/import_file.sh"

log "Importing files: $dump_files"
failed=0
# for now, import in serial to avoid deadlocks (ENT-4742)
for file in $dump_files; do
  "$(dirname "$0")/import_file.sh" $file || failed=1
done

if [ "$failed" != "0" ]; then
  log "Importing files: FAILED"
  find "$CFE_FR_SUPERHUB_IMPORT_DIR"
  for file in "$CFE_FR_SUPERHUB_IMPORT_DIR/*.sql.$CFE_FR_COMPRESSOR_EXT.failed"; do
    echo "file=$file"
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

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

table_whitelist=$(printf "'%s'," $CFE_FR_TABLES | sed -e 's/,$//')

failed=0
# make sure the script we are about to run is executable
chmod u+x "$(dirname "$0")/import_file.sh"

# build an array of dump files so we can delete any that fail in import step
# and try to process others that do not.
declare -A dump_files_array
for dump_file in $dump_files; do
  hostkey=$(basename "$file" | cut -d. -f1)
  dump_files_array[$hostkey]=$dump_file  
done

echo "dump_files_array=${dump_files_array[@]}"

log "Importing files: $dump_files"
echo "$dump_files" | run_in_parallel "$(dirname "$0")/import_file.sh" - $CFE_FR_IMPORT_NJOBS ||
  failed=1
if [ "$failed" = "0" ]; then
  log "Importing files: DONE"
else
  log "Importing files: FAILED"
  for file in "$CFE_FR_SUPERHUB_IMPORT_DIR/*.sql.$CFE_FR_COMPRESSOR_EXT.failed"; do
    # TODO, does this * and %% business actually work?
    # in my testing "" there make it fail
    hostkey="${file%%.sql.$CFE_FR_COMPRESSOR_EXT.failed}"
    # remove this host from future operations
    unset dump_files_array[$hostkey]  
    log "Failed to import file '${file%%.failed}'"
    rm -f "$file"
  done
  exit 1
fi

log "Attaching schemas"
for file in ${dump_files_array[@]}; do
  hostkey=$(basename "$file" | cut -d. -f1)
  "$CFE_BIN_DIR"/psql -U $CFE_FR_DB_USER -d cfdb --set "ON_ERROR_STOP=1" \
                      -c "SET SCHEMA 'public'; SELECT attach_feeder_schema('$hostkey', ARRAY[$table_whitelist]);" \
                      > schema_attach.log 2>&1 || \
      {
          unset dump_files_array[$hostkey]
          failed=1
      }
done
if [ "$failed" = "0" ]; then
  log "Attaching schemas: All DONE"
else
  log "Attaching schemas: 1 or more FAILED"
fi

if [ "${#dump_files_array[@]}" != "0" ]; then
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
else
  log "All files failed to import."
fi

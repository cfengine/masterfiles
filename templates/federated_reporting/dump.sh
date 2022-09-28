#!/bin/bash

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"

# check that we have all the variables we need
true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_DUMP_DIR?undefined}"
true "${CFE_FR_DUMP_FILTERS_DIR?undefined}"
true "${CFE_FR_SED_ARGS?undefined}"
true "${CFE_FR_TRANSPORT_DIR?undefined}"
true "${CFE_FR_COMPRESSOR?undefined}"
true "${CFE_FR_COMPRESSOR_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_FEEDER?undefined}"
true "${CFE_FR_TABLES?undefined}"
true "${CFE_FR_FEEDER_USERNAME?undefined}"
true "${CFE_FR_SUPERHUB_HOSTKEYS?undefined}"

mkdir -p "$CFE_FR_DUMP_DIR"
mkdir -p "$CFE_FR_TRANSPORT_DIR"
chown "$CFE_FR_FEEDER_USERNAME" "$CFE_FR_TRANSPORT_DIR"

if ! type "$CFE_FR_COMPRESSOR" >/dev/null; then
  log "Compressor $CFE_FR_COMPRESSOR not available!"
  exit 1
fi

function sed_filters() {
  sed_scripts="$(ls -1 "$CFE_FR_DUMP_FILTERS_DIR/"*".sed" 2>/dev/null | sort)"
  if [ -n "$sed_scripts" ]; then
    sed $CFE_FR_SED_ARGS $(printf ' -f %s' $sed_scripts)
  else
    cat
  fi
}

function awk_filters() {
  awk_scripts="$(ls -1 "$CFE_FR_DUMP_FILTERS_DIR/"*".awk" 2>/dev/null | sort)"
  if [ -n "$awk_scripts" ]; then
    awk $CFE_FR_AWK_ARGS $(printf ' -f %s' $awk_scripts)
  else
    cat
  fi
}

failed=0
ts="$(date -Iseconds)"  # ISO 8601 format that doesn't have spaces in it
in_progress_file="$CFE_FR_DUMP_DIR/$CFE_FR_FEEDER_$ts.sql.$CFE_FR_COMPRESSOR_EXT.dumping"

log "Dumping tables: $CFE_FR_TABLES"
{
  "$CFE_BIN_DIR"/pg_dump --column-inserts --data-only $(printf ' -t %s' $CFE_FR_TABLES) cfdb

  # in case of 3.12 must copy m_inventory as if it was __inventory
  if [[ "$CFE_VERSION" =~ "3.12." ]]; then
    # pg_dump will not dump the contents of views so we must run the following SQL:
    "$CFE_BIN_DIR"/psql cfdb -c "COPY (SELECT * FROM m_inventory WHERE values IS NOT NULL) TO STDOUT CSV QUOTE '''' FORCE QUOTE *" |
      sed -e 's.^.INSERT INTO __inventory (hostkey, values) VALUES (.' \
          -e 's.$.);.'
  fi
} | sed_filters | awk_filters |
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

if [ -n "$CFE_FR_SUPERHUB_HOSTKEYS" ]; then
  log "Linking for superhub(s): $CFE_FR_SUPERHUB_HOSTKEYS"
  for superhub_hostkey in $CFE_FR_SUPERHUB_HOSTKEYS; do
    mkdir -p "$CFE_FR_TRANSPORT_DIR/$superhub_hostkey"
    ln "$CFE_FR_TRANSPORT_DIR/$CFE_FR_FEEDER.sql.$CFE_FR_COMPRESSOR_EXT" "$CFE_FR_TRANSPORT_DIR/$superhub_hostkey/"
    chown -R "$CFE_FR_FEEDER_USERNAME" "$CFE_FR_TRANSPORT_DIR/$superhub_hostkey"
  done
  log "Linking for superhub(s): DONE"
fi

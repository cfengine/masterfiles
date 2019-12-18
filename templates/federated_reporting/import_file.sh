#!/bin/bash
# A script to import a compressed SQL file
#
# $1 -- compressed SQL file to import
set -e
set -o pipefail

source "$(dirname "$0")/config.sh"

true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_IMPORT_FILTERS_DIR?undefined}"
true "${CFE_FR_SED_ARGS?undefined}"
true "${CFE_FR_EXTRACTOR?undefined}"
true "${CFE_FR_EXTRACTOR_ARGS?undefined}"
true "${CFE_FR_DB_USER?undefined}"
true "${CFE_FR_TABLES?undefined}"
true "${CFE_FR_COMPRESSOR?undefined}"
true "${CFE_FR_COMPRESSOR_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"

file="$1"

function sed_filters() {
  sed_scripts="$(ls -1 "$CFE_FR_IMPORT_FILTERS_DIR/"*".sed" 2>/dev/null | sort)"
  if [ -n "$sed_scripts" ]; then
    sed $CFE_FR_SED_ARGS $(printf ' -f %s' $sed_scripts)
  else
    cat
  fi
}

function awk_filters() {
  awk_scripts="$(ls -1 "$CFE_FR_IMPORT_FILTERS_DIR/"*".awk" 2>/dev/null | sort)"
  if [ -n "$awk_scripts" ]; then
    awk $CFE_FR_AWK_ARGS $(printf ' -f %s' $awk_scripts)
  else
    cat
  fi
}

hostkey=$(basename "$file" | cut -d. -f1)

table_whitelist=$(printf "'%s'," $CFE_FR_TABLES | sed -e 's/,$//')

mv "$file" "$file.importing"

{
  cat<<EOF
\set ON_ERROR_STOP 1
BEGIN;
SELECT switch_to_feeder_schema('$hostkey'); -- so that the import below imports into it
EOF

  "$CFE_FR_EXTRACTOR" $CFE_FR_EXTRACTOR_ARGS "$file.importing" | sed_filters | awk_filters

  cat<<EOF

UPDATE public.__hubs SET last_import_ts = now() WHERE hostkey = '$hostkey';
COMMIT;
EOF
} | "$CFE_BIN_DIR"/psql -U $CFE_FR_DB_USER -d cfdb 2>&1 | "$CFE_FR_COMPRESSOR" $CFE_FR_COMPRESSOR_ARGS >"$file.log.$CFE_FR_COMPRESSOR_EXT" && {
  rm -f "$file.importing"
  exit 0
} || {
  mv "$file.importing" "$file.failed"
  exit 1
}

#!/bin/bash
# A script to import a compressed SQL file
#
# $1 -- compressed SQL file to import
set -e

source "$(dirname "$0")/config.sh"

true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_SED_FILTERS_DIR?undefined}"
true "${CFE_FR_SED_ARGS?undefined}"
true "${CFE_FR_EXTRACTOR?undefined}"
true "${CFE_FR_EXTRACTOR_ARGS?undefined}"
true "${CFE_FR_DB_USER?undefined}"
true "${CFE_FR_TABLES?undefined}"
true "${CFE_FR_DEBUG?undefined}"
true "${CFE_FR_COMPRESSOR?undefined}"
true "${CFE_FR_COMPRESSOR_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"

file="$1"

sed_scripts="$(ls -1 "$CFE_FR_SED_FILTERS_DIR/"*".sed" 2>/dev/null)"

hostkey=$(basename "$file" | cut -d. -f1)

table_whitelist=$(printf "'%s'," $CFE_FR_TABLES | sed -e 's/,$//')

psql_debug_option="--quiet"

if $CFE_FR_DEBUG; then
    psql_debug_option="--echo-all"
fi

mv "$file" "$file.importing"

{
  if $CFE_FR_DEBUG; then
      echo "\set client_min_messages = notice"
  else
      echo "\set client_min_messages = warning"
  fi

  cat<<EOF
\set ON_ERROR_STOP 1
BEGIN;
SELECT switch_to_feeder_schema('$hostkey'); -- so that the import below imports into it
EOF

  "$CFE_FR_EXTRACTOR" $CFE_FR_EXTRACTOR_ARGS "$file.importing" | sed $CFE_FR_SED_ARGS $(printf ' -f %s' $sed_scripts)

  cat<<EOF
COMMIT;
EOF
} | "$CFE_BIN_DIR"/psql -U $CFE_FR_DB_USER $psql_debug_option -d cfdb 2>&1 | "$CFE_FR_COMPRESSOR" $CFE_FR_COMPRESSOR_ARGS > "$file.log.$CFE_FR_COMPRESSOR_EXT" && {
  rm -f "$file.importing"
  exit 0
} || {
  mv "$file.importing" "$file.failed"
  exit 1
}

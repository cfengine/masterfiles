#!/bin/bash
# A script to import a compressed SQL file
#
# $1 -- compressed SQL file to import

source "$(dirname "$0")/config.sh"

true "${CFE_BIN_DIR?undefined}"
true "${CFE_FR_SED_FILTERS_DIR?undefined}"
true "${CFE_FR_SED_ARGS?undefined}"
true "${CFE_FR_EXTRACTOR?undefined}"
true "${CFE_FR_EXTRACTOR_ARGS?undefined}"

file="$1"

sed_scripts="$(ls -1 "$CFE_FR_SED_FILTERS_DIR/"*".sed" 2>/dev/null)"

mv "$file" "$file.importing"
{
  cat<<EOF
\set QUIET on
\set ON_ERROR_STOP 1
SET session_replication_role = replica;
BEGIN;
EOF

  "$CFE_FR_EXTRACTOR" $CFE_FR_EXTRACTOR_ARGS "$file.importing" | sed $CFE_FR_SED_ARGS $(printf ' -f %s' $sed_scripts)

  printf "COMMIT;"
} | "$CFE_BIN_DIR"/psql -U cfpostgres -d cfdb &&
  rm -f "$file.importing" || mv "$file.importing" "$file.failed"


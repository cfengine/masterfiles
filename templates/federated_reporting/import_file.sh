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

file="$1"

sed_scripts="$(ls -1 "$CFE_FR_SED_FILTERS_DIR/"*".sed" 2>/dev/null)"

hostkey=$(basename "$file" | cut -d. -f1)

mv "$file" "$file.importing"

{
  cat<<EOF
\set ON_ERROR_STOP 1
SET session_replication_role = replica;
BEGIN;
SELECT ensure_feeder_schema('$hostkey');
SELECT current_schema(); -- debug info about which current schema
-- we need to get to some types in public so change search_path
SELECT pg_catalog.set_config('search_path', ( select current_schema() || ', public' ), false);
EOF

  "$CFE_FR_EXTRACTOR" $CFE_FR_EXTRACTOR_ARGS "$file.importing" | sed $CFE_FR_SED_ARGS $(printf ' -f %s' $sed_scripts)

cat<<EOF
SET SCHEMA 'public';
SELECT attach_feeder_schema('$hostkey');
COMMIT;
EOF
} | "$CFE_BIN_DIR"/psql -U $CFE_FR_DB_USER --echo-all -d cfdb >$file.log 2>&1 &&
  rm -f "$file.importing" || mv "$file.importing" "$file.failed"


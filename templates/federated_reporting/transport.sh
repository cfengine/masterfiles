#!/bin/bash
#
# Transport dump files from the feeder hubs to the superhub.
#
# Can be run as:
#   transport.sh
#         On a feeder hub, pushes dump files to the superhub.
#   transport.sh push
#         The same as with no arguments.
#   transport.sh pull FEEDER_HUB [FEEDER_HUB2...FEEDER_HUBn]
#         On the superhub, pull dumps from the given feeder hubs (in parallel).
#

set -e

# make sure a failure in any part of a pipe sequence is a failure
set -o pipefail

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/log.sh"
source "$(dirname "$0")/parallel.sh"

# check that we have all the variables we need
true "${CFE_FR_TRANSPORT_DIR?undefined}"
true "${CFE_FR_SUPERHUB_DROP_DIR?undefined}"
true "${CFE_FR_TRANSPORTER?undefined}"
true "${CFE_FR_TRANSPORTER_ARGS?undefined}"
true "${CFE_FR_COMPRESSOR_EXT?undefined}"
true "${CFE_FR_SUPERHUB_LOGIN?undefined}"

if ! type "$CFE_FR_TRANSPORTER" >/dev/null; then
  log "Transporter $CFE_FR_TRANSPORTER not available!"
  exit 1
fi

function push() {
  # Runs on the feeder hub, pushes dumps to the superhub.

  dump_files="$(ls -1 "$CFE_FR_TRANSPORT_DIR/"*".sql.$CFE_FR_COMPRESSOR_EXT" 2>/dev/null)" ||
    {
      log "No files to transport."
      exit 0
    }

  log "Transporting files: $dump_files"
  some_failed=0
  for dump_file in $dump_files; do
    failed=0
    mv "$dump_file" "$dump_file.transporting"
    "$CFE_FR_TRANSPORTER" "$CFE_FR_TRANSPORTER_ARGS" "$dump_file.transporting" "$CFE_FR_SUPERHUB_LOGIN:$CFE_FR_SUPERHUB_DROP_DIR/$(basename "$dump_file")" ||
      failed=1
    rm -f "$dump_file.transporting"
    if [ "$failed" != 0 ]; then
      log "Transporting file $dump_file to $CFE_FR_SUPERHUB_LOGIN:$CFE_FR_SUPERHUB_DROP_DIR failed!"
      some_failed=1
    fi
  done

  if [ "$some_failed" != "0" ]; then
    log "Transporting files: FAILED"
    return 1
  else
    log "Transporting files: DONE"
    return 0
  fi
}

function pull() {
  # $@ -- feeder hubs to pull the dumps from
  feeder_lines="$(printf "%s\n" "$@")"
  log "Pulling dumps from: $feeder_lines"

  chmod u+x "$(dirname "$0")/pull_dumps_from.sh"

  # create and work inside a process specific sub-directory for WIP
  mkdir "$CFE_FR_SUPERHUB_DROP_DIR/$$"

  # Determine the absolute path of the pull_dumps_from.sh script. If this was
  # run with absolute path, use the absolute path, otherwise use the relative
  # part as the base path.
  if [ "${0:0:1}" = "/" ]; then
    pull_dumps_path="$(dirname "$0")/pull_dumps_from.sh"
  else
    pull_dumps_path="$PWD/$(dirname "$0")/pull_dumps_from.sh"
  fi

  pushd "$CFE_FR_SUPERHUB_DROP_DIR/$$" >/dev/null

  failed=0
  echo "$feeder_lines" | run_in_parallel "$pull_dumps_path" - || failed=1
  if [ "$failed" != "0" ]; then
    log "Pulling dumps: FAILED"
    for feeder in "$@"; do
      if [ -f "$feeder.failed" ]; then
        log "Failed to pull dumps from: $feeder"
        rm -f "$feeder.failed"
      fi
    done
  else
    log "Pulling dumps: DONE"
  fi

  for feeder in "$@"; do
    if ! ls "$feeder/"*".sql.$CFE_FR_COMPRESSOR_EXT" >/dev/null 2>/dev/null; then
      log "No dump files from $feeder"
      continue
    fi
    mv "$feeder/"*".sql.$CFE_FR_COMPRESSOR_EXT" "$CFE_FR_SUPERHUB_DROP_DIR/"

    # the $feeder directory is not supposed to contain anything else
    rmdir "$feeder" || log "Failed to remove directory after $feeder"
  done

  popd >/dev/null
  rm -rf "$CFE_FR_SUPERHUB_DROP_DIR/$$"
  return $failed
}

if [ $# = 0 ]; then
  push
elif [ $# = 1 ]; then
  if [ "$1" = "push" ]; then
    push
  else
    if [ "$1" = "pull" ]; then
      log "No feeder hubs given to pull from"
    else
      log "Invalid command given to $0: $1"
    fi
    exit 1
  fi
else
  # more than one argument given
  if [ "$1" = "pull" ]; then
    shift
    pull "$@"
  else
    log "Invalid command given to $0: $1"
    exit 1
  fi
fi

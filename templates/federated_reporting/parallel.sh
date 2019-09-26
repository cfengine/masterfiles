# A shell "library" providing a function to run a given command on multiple
# arguments in parallel.
#
# For best results, make sure 'parallel' is installed.
#

if type parallel >/dev/null 2>&1; then
  HAVE_PARALLEL=1
else
  HAVE_PARALLEL=0
fi

if type xargs >/dev/null 2>&1; then
  HAVE_XARGS=1
else
  HAVE_XARGS=0
fi

if type getconf >/dev/null 2>&1; then
  NCPUs="$(getconf _NPROCESSORS_ONLN)"
else
  NCPUs="$(grep processor /proc/cpuinfo | wc -l)"
fi


_run_using_parallel() {
  max_jobs=""
  if [ $# -gt 2 ]; then
    max_jobs="-j$3"
  fi

  if [ "$2" = "-" ]; then
    parallel $max_jobs "$1 {}"
  else
    parallel $max_jobs "$1 {}" :::: "$2"
  fi
  return $?
}

_run_using_xargs() {
  if [ $# -gt 2 ]; then
    max_jobs="-P$3"
  else
    max_jobs="-P$NCPUs"
  fi

  if [ "$2" = "-" ]; then
    xargs -n1 $max_jobs "$1"
  else
    xargs -n1 $max_jobs -a "$2" "$1"
  fi
  return $?
}

_run_using_for() {
  if [ $# -gt 2 ]; then
    job_slots="$3"
  else
    job_slots="$NCPUs"
  fi

  if [ "$2" = "-" ]; then
    input_arg="/dev/stdin"
  else
    input_arg="$2"
  fi
  failure=0
  while read item; do
    if [ "$job_slots" = 0 ]; then
      wait -n
      if [ $? != 0 ] && [ $failure = 0 ]; then
        failure=1
      fi
      job_slots="$(expr $job_slots + 1)"
    fi
    "$1" "$item" &
    job_slots="$(expr $job_slots - 1)"
  done < $input_arg

  # wait for the jobs one by one and check the exit statuses (127 means there
  # are no more jobs to wait for)
  wait -n
  exit_status=$?
  while [ $exit_status != 127 ]; do
    wait -n
    exit_status=$?
    if [ $exit_status != 0 ] && [ $exit_status != 127 ] && [ $failure = 0 ]; then
      failure=1
    fi
  done
  return $failure
}

run_in_parallel() {
  # Run the given command with the read arguments in parallel
  #
  # $1     -- command to run
  # $2     -- path to the file to read the argument items from,
  #           or "-" to load from STDIN
  # $3     -- OPTIONAL, maximum number of parallel jobs to run,
  #           defaults to the number of CPUs
  # return -- 0 if all runs of the command exited with 0, 1 otherwise
  #
  # Reads the arguments (one arg per line) and runs the given command in
  # parallel with them. One argument per command. Uses 'parallel', 'xargs' or a
  # for-loop with background jobs in respective order of preference.

  # we need to know if $1 is a function because 'xargs' doesn't support
  # functions at all and for 'parallel' we need to export the function
  if type "$1" | head -n1 | grep "$1 is a function" >/dev/null; then
    IS_A_FUNC=1
  else
    IS_A_FUNC=0
  fi

  if [ $HAVE_PARALLEL = 1 ]; then
    if [ $IS_A_FUNC = 1 ]; then
      export -f "$1"
    fi

    _run_using_parallel "$@"
    if [ $? = 0 ]; then
      return 0
    else
      return 1
    fi
  elif [ $HAVE_XARGS = 1 ] && [ $IS_A_FUNC != 1 ]; then
    _run_using_xargs "$@"
    if [ $? = 0 ]; then
      return 0
    else
      return 1
    fi
  else
    _run_using_for "$@"
    return $?
  fi
}

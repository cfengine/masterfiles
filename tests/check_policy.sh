#!/bin/sh
#
# Verify that the policy is correct. If you want to avoid commiting invalid
# changes, just do:
#   cp -a tests/check_policy.sh .git/hooks/pre-commit

cf_promises=""
if type cf-promises >/dev/null 2>&1; then
  cf_promises="cf-promises";
elif [ -x "../core/cf-promises/cf-promises" ]; then
  cf_promises="../core/cf-promises/cf-promises"
else
  echo "No cf-promises executable found"
  exit 0
fi

cf_promises="$cf_promises --full-check --eval-functions"

fail=0
if [ -n "$cf_promises" ]; then
  if [ ! -f "promises.cf" ]; then
    echo "Running autogen.sh to get the policy to verify"
    ./autogen.sh
  fi
  echo "Verifying policy with cf-promises"
  $cf_promises promises.cf                || fail=1
  $cf_promises update.cf                  || fail=1
  $cf_promises standalone_self_upgrade.cf || fail=1
fi

test $fail = 0

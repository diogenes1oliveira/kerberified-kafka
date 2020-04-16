#!/usr/bin/env bash

set -euo pipefail

lockfile="/var/init-scripts-running"
touchfile="/var/init-scripts-ran"
initpath="/docker-entrypoint-init.d"

if ! [ -s "$touchfile" ]; then
  # obtain an exclusive handle to a lockfile so entrypoint invocations
  # won't run simultaneously
  exec 200>$lockfile
  flock -n 200
  echo $$ >&200

  # init scripts should be ran only once
  if ! [ -s "$touchfile" ]; then
    if [ -d "$initpath" ]; then
      for s in `find "$initpath" -mindepth 1 -maxdepth 1 -name '*.sh' | sort`; do
        source "$s"
      done
    fi

    kerberos-initialize
    kerberos-as-admin --wait

    touch "$touchfile"
  fi

fi

exec "$@"
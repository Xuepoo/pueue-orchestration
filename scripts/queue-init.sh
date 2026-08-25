#!/usr/bin/env bash
# queue-init.sh — create pueue groups for agent orchestration and set concurrency.
# Usage: queue-init.sh <group>[:<parallel>] [group2[:parallel] ...]
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <group>[:<parallel>] [group2[:parallel] ...]" >&2
  exit 1
fi

for spec in "$@"; do
  group=${spec%%:*}
  parallel=${spec#*:}
  [[ "$parallel" == "$spec" ]] && parallel=1
  if ! pueue group add "$group" 2>/dev/null; then
    echo "group '$group' already exists"
  fi
  pueue parallel "$parallel" -g "$group"
  echo "ready: group=$group parallel=$parallel"
done

pueue group --json | jq .

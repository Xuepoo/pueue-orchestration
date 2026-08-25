#!/usr/bin/env bash
# queue-claim.sh — atomic worker claim flow: print the oldest stashed task id in a
# group, enqueue it, and wait for completion; then emit its JSON log entry.
# Usage: queue-claim.sh <group> [--no-wait]
set -euo pipefail

group=${1:?usage: queue-claim.sh <group> [--no-wait]}
mode=${2:-}

id=$(pueue status --json -g "$group" |
  jq -r '.tasks
    | to_entries
    | map(select(.value.status.Stashed))
    | sort_by(.key)
    | first | .value.id // empty')

if [[ -z "$id" ]]; then
  echo "no stashed tasks in group '$group'" >&2
  exit 2
fi

pueue enqueue "$id" >/dev/null
echo "claimed task $id in group '$group'"
[[ "$mode" == "--no-wait" ]] && exit 0

pueue wait "$id"
pueue log --json "$id"

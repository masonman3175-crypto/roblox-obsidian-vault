#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then
  echo "usage: ROLLBACK.sh <target-file> <baseline-file>" >&2
  exit 2
fi
cp -- "$2" "$1"
cmp -- "$1" "$2"
echo "restored: $1"

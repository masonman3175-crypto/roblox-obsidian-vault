#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?target directory required}"
if [[ ! -d "$TARGET" ]]; then
  echo "Target directory does not exist" >&2
  exit 2
fi
cp "$HERE/baseline/PunchFxController.luau" "$TARGET/PunchFxController.luau"
echo "ROLLBACK PASS: baseline PunchFxController restored to target copy"

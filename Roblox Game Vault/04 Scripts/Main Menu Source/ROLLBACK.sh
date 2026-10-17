#!/usr/bin/env bash
set -euo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-$dir/rollback-copy.luau}"
original="$(sha256sum "$dir/MODIFIED_FILE.luau" | cut -d' ' -f1)"
if [ "$(realpath -m "$target")" = "$(realpath "$dir/MODIFIED_FILE.luau")" ]; then
  echo "Choose a separate fixture copy for this verification rollback." >&2
  exit 2
fi
cp "$dir/BASELINE_MenuClient.luau" "$target"
cmp -s "$dir/BASELINE_MenuClient.luau" "$target"
test "$original" = "$(sha256sum "$dir/MODIFIED_FILE.luau" | cut -d' ' -f1)"
echo "ROLLBACK: baseline SHA256 restored on copy; live MODIFIED_FILE untouched"

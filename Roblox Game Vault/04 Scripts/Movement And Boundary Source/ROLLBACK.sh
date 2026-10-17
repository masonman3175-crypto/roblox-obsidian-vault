#!/usr/bin/env bash
set -euo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-$dir/rollback-copy.luau}"
resolved="$(realpath -m "$target")"
case "$resolved" in "$dir"/*) ;; *) echo "Use a fixture inside this folder." >&2; exit 2;; esac
if [ "$resolved" = "$(realpath "$dir/MODIFIED_FILE.luau")" ]; then
  echo "Use a separate rollback fixture." >&2; exit 2
fi
cp "$dir/BASELINE_Client.luau" "$target"
python "$dir/verify.py" ROLLBACK "$target"

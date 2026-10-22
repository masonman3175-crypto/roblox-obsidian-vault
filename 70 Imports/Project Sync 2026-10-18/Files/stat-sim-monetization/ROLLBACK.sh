#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")" && pwd -P)"
target="${1:-$root/modified/src}"
mkdir -p "$target"
target="$(cd "$target" && pwd -P)"
case "$target" in "$root"/*) ;; *) echo 'ROLLBACK REFUSED: target outside project' >&2; exit 2;; esac
cp "$root"/baseline/src/*.luau "$target"/
python "$root/validate.py" rollback "$target"
echo 'ROLLBACK PASS: original source behavior restored in target copy'

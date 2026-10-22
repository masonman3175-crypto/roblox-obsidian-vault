#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$ROOT/rollback-copy.rbxlx}"
cp -- "$ROOT/baseline/Place2.rbxlx" "$TARGET"
cmp -- "$ROOT/baseline/Place2.rbxlx" "$TARGET"
printf '%s\n' 'ROLLBACK PASS: original baseplate restored in target copy; modified game retained'

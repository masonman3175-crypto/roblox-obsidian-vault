#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cp "$ROOT/.backup/MODIFIED_FILE.baseline" "$ROOT/MODIFIED_FILE"
printf 'ROLLBACK_OK\n'

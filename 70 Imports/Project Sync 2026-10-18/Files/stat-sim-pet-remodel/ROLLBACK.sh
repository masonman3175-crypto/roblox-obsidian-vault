#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-/c/Python314/python.exe}"
if [[ $# -eq 0 ]]; then set -- --test; fi
exec "$PYTHON" -X utf8 "$ROOT/tools/check.py" rollback "$@"

#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PYTHON="${PYTHON:-/c/Python314/python.exe}"
exec "$PYTHON" "$ROOT/tools/verify_build03.py" rollback "$@"

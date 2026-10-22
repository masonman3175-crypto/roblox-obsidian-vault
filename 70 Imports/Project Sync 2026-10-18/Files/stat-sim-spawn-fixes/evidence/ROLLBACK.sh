#!/usr/bin/env bash
# Local manifest rollback only; live Studio rollback is STUDIO_ROLLBACK.luau.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "${PYTHON:-/c/Python314/python.exe}" "$ROOT/tools/check.py" rollback "$@"

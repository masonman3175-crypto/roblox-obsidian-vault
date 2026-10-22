#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "${PYTHON:-/c/Python314/python.exe}" "$ROOT/tools/build.py" rollback "$@"

#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "${PYTHON_OVERRIDE:-C:/Users/mason/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe}" "$HERE/sync_vault.py" rollback "$@"

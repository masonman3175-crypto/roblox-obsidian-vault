#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-C:/Users/mason/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe}"
case "${1:---self-test}" in
 --self-test) "$PYTHON" "$HERE/rollback_helper.py" ;;
 --emit-studio) cat "$HERE/RESTORE.luau" ;;
 *) printf '%s\n' 'Use --self-test or --emit-studio'; exit 2 ;;
esac

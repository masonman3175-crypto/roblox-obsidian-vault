#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v python >/dev/null 2>&1; then
  exec python "$HERE/tools/verify.py" rollback "$@"
else
  exec python3 "$HERE/tools/verify.py" rollback "$@"
fi

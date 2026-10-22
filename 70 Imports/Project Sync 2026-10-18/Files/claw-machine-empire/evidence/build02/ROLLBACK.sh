#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$HERE/../.." && pwd)"
if command -v python >/dev/null 2>&1; then
  exec python "$ROOT/tools/verify_build02.py" rollback "$@"
else
  exec python3 "$ROOT/tools/verify_build02.py" rollback "$@"
fi

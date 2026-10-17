#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
# Restore only an explicit local .blend copy, never overwrite the live rebuilt deliverable.
target="${1:-rollback-test.blend}"
case "$target" in
  *[!a-zA-Z0-9_.-]*|MODIFIED_FILE.blend|BASELINE.blend) echo 'Invalid rollback target'; exit 2 ;;
esac
case "$target" in *.blend) ;; *) echo 'Expected a .blend target'; exit 2 ;; esac
expected='756c82a4242274cd5f06c33c9b9a183f8b7e5723d93c4b9604a76d5dd6231ba5'
actual="$(sha256sum BASELINE.blend | cut -d' ' -f1)"
test "$actual" = "$expected"
cp -- BASELINE.blend "$target"
actual="$(sha256sum "$target" | cut -d' ' -f1)"
test "$actual" = "$expected"
printf 'ROLLBACK COPY PASS restored_sha256=%s target=%s\n' "$actual" "$target"

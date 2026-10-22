#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:?target path required}"
BACKUP="${2:?backup path required}"
cp -- "$BACKUP" "$TARGET"
printf 'ROLLBACK_OK restored %s from %s\n' "$TARGET" "$BACKUP"

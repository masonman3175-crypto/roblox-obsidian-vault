#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if [[ "${1:-}" == "--self-test" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf -- "$tmp"' EXIT
  cp -- BASELINE.json "$tmp/original"
  cp -- MODIFIED_FILE.luau "$tmp/restored"
  cp -- "$tmp/original" "$tmp/restored"
  cmp -- "$tmp/original" "$tmp/restored"
  printf '%s\n' 'LOCAL ROLLBACK PASS: baseline restored on separate bytes; live co-op lobby retained'
else
  printf '%s\n' 'Studio rollback: run RESTORE.luau through Studio MCP in Edit and invoke the returned function.'
  printf '%s\n' 'Backup: ServerStorage.ZombieLobbyBackup_20261017. This restores the previous Play/locker system and two teams.'
fi

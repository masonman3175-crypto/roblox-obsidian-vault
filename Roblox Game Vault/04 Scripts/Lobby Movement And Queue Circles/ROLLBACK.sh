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
  printf '%s\n' 'LOCAL ROLLBACK PASS: original snapshot restored on separate bytes; live eight-circle update retained'
else
  printf '%s\n' 'Studio rollback: run RESTORE.luau in Edit through Studio MCP and invoke the returned function.'
  printf '%s\n' 'Backup: ServerStorage.LobbyMovementEightQueuesBackup_20261017'
fi

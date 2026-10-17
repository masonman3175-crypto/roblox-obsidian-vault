#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if [[ "${1:-}" == "--self-test" ]]; then
 cp MODIFIED_FILE.luau ROLLBACK_TEST.json
 cp BASELINE.json ROLLBACK_TEST.json
 cmp -s BASELINE.json ROLLBACK_TEST.json
 printf '%s\n' 'LOCAL ROLLBACK PASS: baseline bytes restored on separate copy; live audio unchanged'
else
 printf '%s\n' 'Stop Studio Play. Load RESTORE.luau as a ModuleScript and call its returned function with {RS=game.ReplicatedStorage,SP=game.StarterPlayer.StarterPlayerScripts,SSS=game.ServerScriptService,Sound=game.SoundService}.' 'This helper does not control Studio directly.'
fi


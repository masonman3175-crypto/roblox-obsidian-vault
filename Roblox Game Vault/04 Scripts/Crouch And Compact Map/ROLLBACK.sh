#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if [[ "${1:-}" == "--self-test" ]]; then
 cp MODIFIED_FILE.luau ROLLBACK_TEST.json
 cp BASELINE.json ROLLBACK_TEST.json
 cmp -s BASELINE.json ROLLBACK_TEST.json
 printf '%s\n' 'LOCAL ROLLBACK PASS: original snapshot restored on a separate file; live changes retained'
else
 printf '%s\n' 'Stop Studio Play. Load RESTORE.luau as a ModuleScript, then invoke the returned function with (game, game.ServerStorage.CrouchCompactFloorBackup_20261017).' 'This shell prints Studio instructions; it does not edit live Studio.'
fi


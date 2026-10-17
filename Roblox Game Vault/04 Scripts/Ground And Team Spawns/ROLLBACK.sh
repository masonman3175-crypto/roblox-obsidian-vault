#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
if [[ "${1:-}" == "--self-test" ]]; then
 cp MODIFIED_FILE.luau ROLLBACK_TEST.json
 cp BASELINE.json ROLLBACK_TEST.json
 cmp -s BASELINE.json ROLLBACK_TEST.json
 printf '%s\n' 'LOCAL ROLLBACK PASS: original baseline bytes restored to separate test copy'
else
 printf '%s\n' 'Studio rollback: execute RESTORE.luau as a ModuleScript, then invoke the returned function with {Baseplate=workspace.Baseplate,Spawns=workspace.Map.Spawns,Teams=game.Teams} and game.ServerStorage.GroundTeamSpawnsBackup_20261017.' 'This shell does not have direct Studio access. No live state changed.'
fi


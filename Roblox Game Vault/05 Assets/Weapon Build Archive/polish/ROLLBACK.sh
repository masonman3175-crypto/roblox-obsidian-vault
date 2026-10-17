#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
# Test restoration into separate files; leave the live Studio package untouched.
# The adjacent rollback.luau restores the actual Studio package in Edit mode.
expected='41eb405746c39f99c0cb5075479d095dfd24fde8bc1a47504b0aa3faac06dfac'
actual="$(sha256sum BASELINE_Controller.luau | cut -d' ' -f1)"
test "$actual" = "$expected"
cp -- BASELINE_Controller.luau ROLLBACK_TEST_Controller.luau
cp -- BASELINE_Config.luau ROLLBACK_TEST_Config.luau
cmp -- BASELINE_Controller.luau ROLLBACK_TEST_Controller.luau
cmp -- BASELINE_Config.luau ROLLBACK_TEST_Config.luau
printf 'ROLLBACK FILE PASS controller/config restored on copies; modified files retained\n'

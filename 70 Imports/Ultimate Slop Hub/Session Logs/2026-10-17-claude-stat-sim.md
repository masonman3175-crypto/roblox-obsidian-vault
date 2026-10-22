# 2026-10-17 claude, Stat Sim

## Done
- Made the hub vault (`ultimate-slop-hub`), pushed to GitHub. Rules in CLAUDE.md / AGENTS.md, blueprint pages, tool notes from the FPS vault.
- Ingested 9 screenshots (homepage grid, speed sim, keyboard escape) into 6 wiki pages.
- Built Stat Sim v0 in place 98823628319724 (see [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Design|Stat Sim Design]]). Scripts mirrored to `games/Stat Sim/src/` with [[70 Imports/Ultimate Slop Hub/wiki/tools/Script Mirror|Script Mirror]].

## Tested (Studio playtest)
- Train remote: 30 spam clicks in 1.5s gave 24 (rate limit OK). Level-ups and XP bar OK.
- Teleporting to floor 3 without Strength sent the player back to spawn.
- At 134 Strength: floor 2 unlocked, gain x2 on floor 2, gate 2 open, gate 3 solid (client).
- Rebirth (requirement temporarily set to 2, then put back to 10): denied below the level, then rebirth 1, stats reset, gain x1.5.
- HUD screenshot checked. No script errors in Output.

## Not tested
- DataStore saving: Studio API access is off in this place (code falls back to temp data with a warning).
- Real purchases: all IDs are 0.
- Auto Train loop (needs the pass), leaderboard with the real OrderedDataStore, mobile layout on a phone.

## v1 pass (after Cade's feedback)
- Split work: map session (hub, training area, floor themes, pet models) and UI style session (UiStyle kit + [[70 Imports/Ultimate Slop Hub/wiki/ui/Sim Button Anatomy|Sim Button Anatomy]]). I did gameplay + integration.
- Added: free Strength every second, Auto Click pass, Punch the Dummy lane with Coins, 6 floor pet stands + followers, character growth, Studio free-test purchases, new numbers, UiStyle buttons/panels in the HUD.
- Tested in playtest: passive 35 > 50 in 3s; Studio test x2 pass + Strength pack granted; E at the dummy gave 138 studs / 276 Coins and later 348 studs; pet stand buy took 25 Coins, x1.5 Pets, follower spawned; scale 1.34 at 12.5K Strength; new HUD + Shop panel screenshots look like the refs.
- Fixed after test: pets were huge and blocked the camera (now sized to 3 studs, beside the player), dummy flew too high, double emoji on TRAIN.
- Not tested: dummy flight seen up close, pets 2-6 (need higher floors), saving (API access still off).

## Next
- See [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Next Pass|Stat Sim Next Pass]]. Cade: turn on Studio API access, publish, make passes/products.

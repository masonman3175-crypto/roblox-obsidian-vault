---
kind: game-roadmap
game: ultimate-frisbee
status: planned
updated: 2026-10-21
tags: [roblox, ultimate-frisbee, roadmap]
---

# Ultimate Frisbee - Roadmap

One bounded pass at a time. Each pass ends with a Studio playtest (start_stop_play + console check) and a note in the [[Ultimate Frisbee - Current Build]] page.

## Pass 0 - Baseline (next)
- [ ] Playtest the current build solo: throw, catch, score, lobby flow. Log the bugs.
- [ ] Remove the leftover `Baseplate` / `SpawnLocation` if unused.
- [ ] Measure the stadium's FPS cost; decide whether to keep it or slim it down.

## Pass 1 - Real ultimate rules
- [ ] Possession: a turnover flips the offense, and only the offense can pick up.
- [ ] Stall count from the nearest defender + HUD counter.
- [ ] Pull after a score.
- [ ] Out-of-bounds handling: the disc goes back to the sideline.
- [ ] Pivot step for the holder.

## Pass 2 - Movement tech
- [ ] `MovementController` (client) + server validation of speeds.
- [ ] Sprint + stamina, slide, slide-hop, dash, dive/layout with catch reach, skying.
- [ ] Movement course in practice mode for tuning.

## Pass 3 - Throws
- [ ] Lateral curve in `FrisbeeConfig.step`.
- [ ] Backhand / forehand / hammer / blade / fake.
- [ ] Charge UI + throw-type indicator.

## Pass 4 - Powers v1
- [ ] Kit framework: a `PowerService` (server) with cooldowns and ult charge, plus `PowerConfig` (shared).
- [ ] 3 starter kits: Blink, Magnet, Gale.
- [ ] Kit select in the lobby.

## Pass 5 - Juice and weather gameplay
- [ ] Trails, catch freeze-frame, callouts, play feed.
- [ ] Weather effects on disc physics + wind.

## Pass 6 - Retention
- [ ] XP / levels / cosmetic unlocks, DataStore saving.
- [ ] Practice range with targets and time trials.
- [ ] Remaining kits.

## Related
[[Ultimate Frisbee - Game Hub]] · [[Ultimate Frisbee - Design]]

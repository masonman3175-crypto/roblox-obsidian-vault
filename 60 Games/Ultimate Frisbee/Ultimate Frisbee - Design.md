---
kind: game-design
game: ultimate-frisbee
status: draft
updated: 2026-10-21
tags: [roblox, ultimate-frisbee, design]
---

# Ultimate Frisbee - Design (draft)

> [!note] Draft
> First pass at fleshing out the idea. Everything here is a proposal. Cut, rename or change anything. Numbers are starting points for tuning, not decisions.

## Pitch
Fast team ultimate frisbee where **the disc can't move on foot, but everyone else can move like crazy.** The handler is a planted quarterback reading the field. The other players chain slides, dives and dashes to get open or shut down lanes, and each one brings a power that bends the rules for a few seconds.

**Why it works:** the "no running with the disc" rule makes movement tech matter for *everyone without the disc*, and every possession is a quick read → throw → highlight catch.

## Core rules (simplified real ultimate)
- **Teams:** 4v4 default (3v3 and 5v5 supported). Field is the existing stadium, 160 x 440 studs with endzones.
- **Score:** catch the disc inside the endzone you're attacking. First to 5 (current), or a 6-minute timer.
- **Pull:** after a score, the scoring team throws off from its own endzone (replaces "reset to midfield").
- **No running with it:** the holder is planted. They can **pivot** (rotate freely, plus one short pivot step of about 3 studs).
- **Stall count:** the nearest defender within 10 studs starts a 10-count (about 1 count per 0.8s, shown above the holder). If it reaches 10, it's a turnover.
- **Turnovers:** the disc hits the ground, goes out of bounds, gets intercepted or knocked down, or stalls. Possession flips, and the new offense picks it up where it stopped (or at the sideline if it went out).
- **No contact:** players can't tackle or steal from the holder. Powers can affect the *disc in flight* and *space*, never rip the disc out of hands. This keeps it frisbee, not a fighting game.

## Movement tech
The skill ceiling. Everything is momentum-based and chainable, Titanfall/Apex style but readable.

| Tech | Input (PC / pad / mobile) | What it does | Notes |
| --- | --- | --- | --- |
| Sprint | Shift / L3 / auto | 16 → 24 WalkSpeed | Stamina bar shared with dash |
| Slide | C while sprinting / B / button | Low, fast slide that keeps momentum and decays slowly | Slide on a slope = speed gain |
| Slide-hop | Jump out of slide | Carries slide speed into the air | The core "tech" people will learn |
| Dash | Q / LB / button | Short burst in the move direction, 1 charge, 2.5s recharge | Works in the air once per jump |
| Dive (layout) | Space mid-air toward disc, or E while sprinting | Horizontal dive with a big catch reach (10 studs) for 0.4s | Landing has 0.8s recovery: high risk, high reward |
| Skying | Jump + E at peak | Higher jump-catch reach if timed at the apex | Beats a defender for a contested disc |
| Wall kick | Jump into the stadium walls | One kick off the wall | Optional, depends on map |
| Cut | Quick 120°+ direction change while sprinting | Keeps 80% speed instead of stopping | Rewards sharp cuts, like real ultimate |

The holder gets **pivot** + **fakes** (below) instead of movement.

## Throwing
Current: charge to power, straight line. Proposed throw types:

| Throw | Input | Flight |
| --- | --- | --- |
| Backhand | Default | Curves slightly left (right-handed) |
| Forehand / flick | Hold Q while releasing | Curves right |
| Hammer | Aim up steeply | Overhead arc that flips and drops fast, good over a crowd |
| Blade | Hold full charge 0.5s extra | Fast, little lift, drops hard |
| Hold curve | Mouse sideways during flight window | Small after-release bend (tunable, maybe a power-only thing) |
| Fake | Tap R while charging | Throw animation with no release; defenders who react get baited |

Physics change: add a lateral term to `FrisbeeConfig.step` (bank angle × speed) so curves are deterministic and shared by client prediction and server.

## Powers
Each player picks one **kit** before the match: 1 ability (short cooldown) + 1 ultimate (charged by catches, assists, blocks). Kits are unlocked cosmetically and never pay-to-win: all kits are free, earnable or rotate.

| Kit | Ability (≈10-14s CD) | Ultimate | Role |
| --- | --- | --- | --- |
| **Blink** | Short teleport (15 studs) in the move direction | **Phase Cut**: 4s of no collision, 2 blinks | Cutter |
| **Magnet** | 1.5s of huge catch reach (12 studs) | **Tractor**: a disc thrown to you homes in gently for 2s | Receiver |
| **Gale** | Wind cone that pushes a disc in flight sideways | **Storm Wall**: a 6s wind wall at midfield that slows discs through it | Defender |
| **Rocket** | Stores the next throw as a no-gravity laser for 30 studs | **Comet**: full-field straight-line throw, no drop | Handler |
| **Frost** | Ice strip where you slide: allies speed up, enemies slip | **Freeze Lane**: freezes a 20-stud strip and slows enemies 40% | Utility |
| **Echo** | Spawns a decoy runner that copies your last 2s | **Mirage**: you look like the disc holder to enemies for 3s | Trickster |
| **Anchor** | Drop a pylon that blocks discs (it can be thrown around) | **Bastion**: a 4s dome over the holder that stops marks/stall | Defender |

Balance rules:
- Powers never take the disc from a player's hands.
- One ultimate active per team at a time.
- A disc block from a power counts as a turnover (that's the defensive payoff).
- Power use is server-validated (cooldowns and positions) like every other action.

## Weather (already in the build, give it gameplay)
| Weather | Effect |
| --- | --- |
| Day | Baseline |
| Rain | +30% drag, slides go 20% further, louder splash VFX |
| Snow | Gravity on the disc −15% (floaty), sprint −10% |
| Night | Field lights; the disc has a glowing trail, and players far from the disc are darker |
| **Wind** (new) | Random wind direction per point that bends the disc. Shown with flags + a HUD arrow |

## Modes
1. **Ranked-ish 4v4**: the full rules above, captain draft as now.
2. **Quickplay**: auto teams, no draft, timer match.
3. **Practice range**: solo throw targets and moving rings, a movement tech course, and time trials (great for retention).
4. **Hot Disc** (party mode): no teams; holding the disc builds points, and the disc explodes after 6s (confetti, no gore).
5. Later: **Tournament** (bracket of 4 teams in a server).

## Feel and juice
- Disc trail by charge power; whoosh pitch rises with speed.
- Catch freeze-frame (0.05s) + camera punch on dives and skies.
- "Huck" callout for 60+ yard throws, "Greatest" for diving catches across the out-of-bounds line.
- Kill-feed style play feed: "Blink → Magnet 42yd SCORE".
- Replay of the last point's throw on score (later).

## Progression and monetization
- **Cade's call (2026-10-21):** anime powers are sold in a shop. Buy them with **coins** earned from match performance, or directly with **Robux**. Coin packs are also sold for Robux. The partner is building the powers; the shop UI is built (see [[Ultimate Frisbee - Current Build]]).
- XP per catch, assist, score, block → levels, plus cosmetics: disc skins, trails, dive effects, celebration emotes.
- No paid random loot boxes.
- Daily challenges ("3 diving catches", "2 hammers that land").

## Controls summary
| Action | PC | Gamepad | Mobile |
| --- | --- | --- | --- |
| Throw (hold/release) | Mouse1 | R2 | Throw button (hold) |
| Catch / hands | E | X | Auto + catch button |
| Sprint | Shift | L3 | Auto when stick fully pushed |
| Slide | C | B | Slide button |
| Dash | Q | LB | Dash button |
| Ability | F | RB | Ability button |
| Ultimate | G | Y | Ult button |
| Forehand modifier | Hold Q while charging | L2 | Swipe direction on release |

Conflict: Q is dash *and* forehand. Fine because the holder can't dash, so Q means forehand only while holding.

## Open questions (Cade to decide)
1. Game name?
2. Default team size: 3v3, 4v4 or 5v5?
3. Kits (pick one before the match) vs power pickups spawning on the field?
4. Competitive-first (ranked, clean rules) or chaos-first (big ults, party feel)?
5. Is Mason / Codex on this game too? If so, how do we split it (e.g. Cade = disc + movement + powers, partner = rounds/UI/lobby)?
6. Keep the current stadium (21.8k parts) or build a lighter one for mobile?

## Related
[[Ultimate Frisbee - Game Hub]] · [[Ultimate Frisbee - Current Build]] · [[Ultimate Frisbee - Roadmap]]

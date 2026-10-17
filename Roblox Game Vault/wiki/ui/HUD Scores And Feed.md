---
type: ui
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# HUD Scores And Feed

Branch of [[Gameplay HUD]]. Display wiring exists; a complete round/score service is **not** established by this UI.

## Workspace attributes
| Input | Default / interpretation |
|---|---|
| `ScoreRed`, `ScoreBlue` | 0, 0 |
| `ScoreTarget` | 100 |
| `MatchActive` | false => WARMUP |
| `MatchEndsAt` | server timestamp; subtract `workspace:GetServerTimeNow()` |
| `MatchSecondsRemaining` | fallback seconds, default 0 |

The header shows WARMUP / TIED / RED LEADS / BLUE LEADS from actual values. The screenshot's 51–21 and timer are not hardcoded as real match results.

## Feed and responsibilities
`ReplicatedStorage.GameplayPresentation.HUDEvent.OnClientEvent` accepts an `Elimination` presentation event for feed rows. Only a server combat service should publish verified eliminations. No mock kills are inserted. The newer [[Claude AK]] uses its own hit-confirm/replication remotes; end-to-end score/feed integration still needs multiplayer verification rather than assuming these contracts are already connected.

## Next test
Inject known match attributes in an isolated test, verify red/blue/tie and clock rollover, then connect actual server kill credit to score/feed once round ownership is agreed. See [[Current Test And Integration Backlog]].

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Collectible lifecycle state machine

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Write allowed transitions explicitly and make illegal transitions no-ops with a diagnostic result.

## Implementation and rationale
Use Spawned, Reserved, Carried, Depositing, Displayed, Dropped, and Removed states. A reservation prevents simultaneous pickup. Define cancellation and timeout rules for each transient state. A client animation ending must not determine when the server commits a reward. Attach a monotonic revision to state changes.

## Acceptance test
- [ ] Replay each transition twice, reorder two requests, and interrupt with disconnect. Every item has at most one carrier or one display slot at a time.

## Related decisions
- [[Carrying creates a readable choice]]
- [[Stable item IDs and provenance]]
- [[Deposits must commit once]]
- [[UI snapshots and revisions]]

## Sources
- [[REF - Client-server boundary validation]]
- [[REF - Remote events and callbacks]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]

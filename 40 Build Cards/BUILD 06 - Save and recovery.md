---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 06 - Save and recovery

**Status:** not started — research/build instruction only.
**Depends on:** Inventory and wallet records have stable IDs and a schema.

## Required output
Versioned save layer, session ownership decision, load-failure UI, and migration fixtures.

## Acceptance gate
- [ ] Fault injection preserves existing data and recovers after reconnect.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[Persistence is part of gameplay]]
- [[Session ownership and concurrent joins]]
- [[Versioned player-data migrations]]
- [[Persistence fault-injection matrix]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 05 - Wallet and upgrades]]

Next: [[BUILD 07 - Responsive HUD]]

[[MVP Build Board]] · [[Robot Prompt Library]]

---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 05 - Wallet and upgrades

**Status:** not started — research/build instruction only.
**Depends on:** Stable deposits and a draft economy config.

## Required output
One server wallet service and one free upgrade with a visible payback.

## Acceptance gate
- [ ] Concurrent spending cannot overdraw; earned and spent amounts reconcile.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[One currency mutation path]]
- [[Upgrade curves with readable payback]]
- [[Deterministic economy simulation]]
- [[Currency sources and sinks ledger]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 04 - Guardian and routes]]

Next: [[BUILD 06 - Save and recovery]]

[[MVP Build Board]] · [[Robot Prompt Library]]

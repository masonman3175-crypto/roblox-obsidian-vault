---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 02 - Authoritative pickup

**Status:** not started — research/build instruction only.
**Depends on:** Card 01 and written remote contracts.

## Required output
A server record and client request for pickup with explicit rejection codes.

## Acceptance gate
- [ ] Malformed and simultaneous requests produce one valid carrier at most.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[Intent-only network contracts]]
- [[Collectible lifecycle state machine]]
- [[Stable item IDs and provenance]]
- [[Rate limits are gameplay contracts]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 01 - Original greybox]]

Next: [[BUILD 03 - Carry and deposit]]

[[MVP Build Board]] · [[Robot Prompt Library]]

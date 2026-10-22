---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 10 - Purchase sandbox

**Status:** not started — research/build instruction only.
**Depends on:** Reviewed save layer and catalog; mock products only until real test setup is explicit.

## Required output
One dispatcher and grant schema with durable deduplication and pending UI.

## Acceptance gate
- [ ] Replay, save-failure, unknown-product, cancellation, and reconnect cases pass.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[Durable idempotent purchase grants]]
- [[Many products through one catalog]]
- [[Purchase flow is a state machine]]
- [[Products are not all the same entitlement]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 09 - First-time experience]]

Next: [[BUILD 11 - Product and policy gates]]

[[MVP Build Board]] · [[Robot Prompt Library]]

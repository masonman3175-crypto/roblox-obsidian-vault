---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 03 - Carry and deposit

**Status:** not started — research/build instruction only.
**Depends on:** Card 02 and item lifecycle invariants.

## Required output
Carrying, dropping, depositing, and display occupancy with cancellation paths.

## Acceptance gate
- [ ] Reset, fall, disconnect, double-trigger, and full-slot cases do not duplicate or destroy ownership.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[Deposits must commit once]]
- [[Carrying creates a readable choice]]
- [[Inventory is not the Workspace]]
- [[Two-client and bad-network scenarios]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 02 - Authoritative pickup]]

Next: [[BUILD 04 - Guardian and routes]]

[[MVP Build Board]] · [[Robot Prompt Library]]

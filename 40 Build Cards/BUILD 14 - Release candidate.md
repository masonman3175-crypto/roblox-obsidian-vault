---
research_pack: slop-lab-v2
kind: build-card
status: not-started
created: 2026-10-17
tags: [roblox, build]
---

# BUILD 14 - Release candidate

**Status:** not started — research/build instruction only.
**Depends on:** All previous blocking state and product defects are resolved.

## Required output
Named release packet, asset ledger, performance capture, regression evidence, and tested rollback boundaries.

## Acceptance gate
- [ ] A fresh unpaid account, returning owner, restricted fixture, and bad-network test all pass the release gate.
- [ ] Preserve unrelated working behavior.
- [ ] Record the actual build and test evidence, not only a plan.
- [ ] Save a named checkpoint and identify rollback limits.

## Decisions to read
- [[Launch gate before live purchases]]
- [[Release packet and rollback boundaries]]
- [[Measured mobile performance budget]]
- [[Regression suite organized by invariant]]

## Evidence to attach after implementation
Changed files/instances; fixture and input; exact test procedure; literal result; remaining defects; checkpoint/source revision. This card stays unstarted until implementation evidence exists.

Previous: [[BUILD 13 - Telemetry and playtest]]

Next: Evaluate a controlled release; no automatic public publish.

[[MVP Build Board]] · [[Robot Prompt Library]]

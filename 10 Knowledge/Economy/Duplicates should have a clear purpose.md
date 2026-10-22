---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Duplicates should have a clear purpose

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Define duplicate handling before a random collection system floods inventories.

## Implementation and rationale
Options include keeping a separate instance, converting to a small crafting resource, or deterministic fusion. Preview conversion before removing favorites. Do not reward duplicates with an ever-expanding source that breaks coins. A collection discovery is still counted once even if inventory holds many copies.

## Acceptance test
- [ ] Fill capacity with duplicate species, acquire one more, and reconnect. No reward disappears, first-discovery claims remain idempotent, and favorite protection works.

## Related decisions
- [[Collection as a goal system]]
- [[Fusion as a deterministic MVP]]
- [[Capacity is a pacing tool not a trap]]
- [[Inventory is not the Workspace]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Introduction to quest design]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]

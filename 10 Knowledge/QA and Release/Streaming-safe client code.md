---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Streaming-safe client code

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Treat world-instance availability as temporary while keeping gameplay identity stable.

## Implementation and rationale
Store item IDs separately from instance references and let presentation attach or detach as models appear. Use bounded waits and cancellation for world markers. Do not make every model persistent just to hide missing-reference bugs. Keep essential tutorial landmarks appropriately available while preserving the memory benefit of streaming.

## Acceptance test
- [ ] Move rapidly between zones, respawn, and load into a busy base. No infinite WaitForChild or stale reference blocks the HUD or duplicates a collectible.

## Related decisions
- [[UI snapshots and revisions]]
- [[Contextual guidance that ends]]
- [[Inventory is not the Workspace]]
- [[Measured mobile performance budget]]

## Sources
- [[REF - Instance streaming]]
- [[REF - Improve performance]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Destructive actions need a preview

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Sell, fuse, and prestige dialogs should show the exact consequences before committing.

## Implementation and rationale
List affected items and currencies in plain terms, distinguish equipped or favorite items, and make cancel the easy route. Revalidate state on the server at confirmation time. If the inventory changes while the dialog is open, invalidate the preview rather than executing a stale destructive operation.

## Acceptance test
- [ ] Open a prestige dialog, earn currency elsewhere, then confirm. The system either recomputes with a fresh preview or rejects the stale request without an unexpected reset.

## Related decisions
- [[Prestige with an explicit contract]]
- [[Fusion as a deterministic MVP]]
- [[UI snapshots and revisions]]
- [[Inventory is not the Workspace]]

## Sources
- [[REF - UI and UX design]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

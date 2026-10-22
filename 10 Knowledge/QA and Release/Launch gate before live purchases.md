---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Launch gate before live purchases

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a short blocking checklist for failure modes that would immediately break player trust.

## Implementation and rationale
Require passing save/receipt recovery, full free-loop completion, core multi-client invariants, product-price consistency, eligibility behavior, asset ownership/permissions, and mobile/controller navigation. Keep unresolved cosmetic polish separate from state-loss or purchase defects. Real product creation and publishing require an explicit implementation task, not this research pack.

## Acceptance test
- [ ] Run the gate against a named test build. Any item-loss, duplicate-grant, or inaccessible-core-loop issue blocks the launch; record remaining low-impact defects honestly.

## Related decisions
- [[Persistence fault-injection matrix]]
- [[Product eligibility test fixtures]]
- [[UI state and viewport matrix]]
- [[Purchase and progress support records]]

## Sources
- [[REF - Studio testing modes]]
- [[REF - Player data and purchasing systems]]
- [[REF - Version History]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

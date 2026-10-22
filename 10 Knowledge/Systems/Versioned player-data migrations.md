---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Versioned player-data migrations

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make schema changes explicit, small, and repeatable.

## Implementation and rationale
Write one transformation per schema version and retain fixtures for old accounts. Separate renaming a field from changing economic values. Check invariants before saving the migrated record, and preserve unknown data until a deliberate cleanup. A place-code rollback is not automatically a data rollback.

## Acceptance test
- [ ] Migrate each fixture twice and compare results. Removed catalog entries map to a documented fallback, and purchased entitlements are preserved across every version.

## Related decisions
- [[Persistence is part of gameplay]]
- [[Stable item IDs and provenance]]
- [[Prestige with an explicit contract]]
- [[Release packet and rollback boundaries]]

## Sources
- [[REF - Data stores]]
- [[REF - Version History]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]

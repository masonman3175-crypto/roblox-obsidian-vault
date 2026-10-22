---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Roll out economy changes with a return path

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep tuning data versioned and bounded so an incorrect multiplier can be stopped quickly.

## Implementation and rationale
Validate a config snapshot before enabling it, record the build/config version in diagnostics, and keep a last-known-good configuration. Separate turning off future rewards from compensating already-valid player earnings. Do not assume a code rollback can erase live economic effects. Use a small test cohort when infrastructure supports it.

## Acceptance test
- [ ] Inject an invalid price, missing item key, and excessive multiplier into a test config. Validation fails before use; reverting restores future behavior without corrupting stored items.

## Related decisions
- [[Inflation and content consumption]]
- [[Deterministic economy simulation]]
- [[Release packet and rollback boundaries]]
- [[Versioned player-data migrations]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Version History]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]

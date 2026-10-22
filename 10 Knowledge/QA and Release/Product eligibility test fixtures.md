---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Product eligibility test fixtures

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Test eligible, restricted, and unknown eligibility as separate user states.

## Implementation and rationale
Build a policy adapter that can use controlled fixtures in a test environment. Verify UI visibility and server rejection independently. Include indirect paid-currency paths, luck modifiers, trading of paid outcomes, and unavailable product information. Recheck current Roblox requirements before enabling a new monetization type.

## Acceptance test
- [ ] A restricted fixture cannot reach a disallowed random outcome through alternate currencies or stale remotes, while direct cosmetics and the entire core free loop remain usable.

## Related decisions
- [[Per-player product availability]]
- [[Paid randomness decision gate]]
- [[Trading is a later transaction system]]
- [[Runtime prices not painted prices]]

## Sources
- [[REF - PolicyService API]]
- [[REF - Paid random item guidelines]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

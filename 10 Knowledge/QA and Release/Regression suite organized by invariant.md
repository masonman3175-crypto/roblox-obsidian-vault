---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Regression suite organized by invariant

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep tests for the promises players depend on rather than only individual implementation functions.

## Implementation and rationale
Core invariants: one owner per item, one committed deposit, no negative wallets, no duplicate receipt grant, consistent entitlements, recoverable load failure, and useful touch/controller navigation. Make every fixed bug add a case to this suite. Maintain small fixtures for content and old schemas.

## Acceptance test
- [ ] A risky refactor must pass the same invariants and a short manual two-client playtest. Passing a formatter or static checker alone is never reported as gameplay verification.

## Related decisions
- [[Static checks do not replace playtests]]
- [[Persistence fault-injection matrix]]
- [[Two-client and bad-network scenarios]]
- [[UI state and viewport matrix]]

## Sources
- [[REF - Studio testing modes]]
- [[REF - Luau types]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Private servers as an optional social product

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Treat private servers as a play-group preference, not a place to sell impossible public-server advantages.

## Implementation and rationale
Support solo practice, friends-only sessions, and content recording. Keep public competitive rewards consistent or clearly separate private-server progression if the rules differ. A private-server purchase has its own platform subscription behavior; do not bundle it implicitly into an unrelated game pass.

## Acceptance test
- [ ] Run the full loop in an empty private server, then compare progress with public rules. Players understand exactly what the server option changes and what it does not.

## Related decisions
- [[Fun at one concurrent player]]
- [[Social play that creates stories]]
- [[Products are not all the same entitlement]]
- [[Shareable moments without fake spectacle]]

## Sources
- [[REF - Private servers]]
- [[REF - Monetization overview]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]

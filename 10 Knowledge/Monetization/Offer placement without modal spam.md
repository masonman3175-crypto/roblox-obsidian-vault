---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Offer placement without modal spam

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Let players ask for information and choose when to buy; keep active gameplay readable.

## Implementation and rationale
Use a cosmetic preview stand, shop drawer, or between-run screen as a browsing opportunity. Avoid prompting checkout during a chase, after every loss, or as a tutorial requirement. A session-level offer coordinator prevents repeated and overlapping offers. Context should explain relevance, not manufacture panic.

## Acceptance test
- [ ] Fail three runs and close an offer. The game remains playable and does not stack or immediately repeat checkout prompts. Measure voluntary shop opens separately from forced exposures.

## Related decisions
- [[One modal at a time]]
- [[Risk without permanent misery]]
- [[Starter bundle after demonstrated value]]
- [[Shop metrics include failed fulfilment]]

## Sources
- [[REF - Contextual purchases]]
- [[REF - Monetization overview]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Acquisition cost is a hypothesis

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Separate real costs, platform revenue, and unproven future value before deciding an ad test is profitable.

## Implementation and rationale
Draft a worksheet for impressions, visits, qualified plays, first-loop completions, spend, and revenue over a stated window. Do not convert a creator's anecdote into a likely return for this game. Keep gross Robux, earned Robux, cash costs, and eligibility-dependent cash-out concepts separate rather than silently equating them.

## Acceptance test
- [ ] Evaluate a synthetic campaign with weak retention and strong click rate. The decision rule stops scaling for diagnosis rather than rewarding clicks alone.

## Related decisions
- [[Small launch before paid scale]]
- [[Clicks and meaningful plays are different]]
- [[Shop metrics include failed fulfilment]]
- [[One question per experiment]]

## Sources
- [[REF - Advertising for creators]]
- [[REF - Acquisition]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]

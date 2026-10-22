---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Grief recovery and protected progress

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Build rules that limit repeated targeting before launching an open social arena.

## Implementation and rationale
For the draft design, permanent collection ownership is protected and contested risk is limited to current cargo. Add a short earnable recovery window after a loss if tests show spawn camping. Explain the rule visibly and validate it on the server. Do not sell access to the only tolerable version of the game.

## Acceptance test
- [ ] Two coordinated testers repeatedly target a fresh account. The player retains a free route to useful progress without paying, changing servers, or winning an unwinnable matchup.

## Related decisions
- [[Risk without permanent misery]]
- [[Measure the aftermath of failure]]
- [[Intent-only network contracts]]
- [[Co-op goals with equitable credit]]

## Sources
- [[REF - Core loops]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# The coding robot context packet

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Give the robot a small authoritative packet rather than asking it to infer a whole game from a screenshot.

## Implementation and rationale
Include the concept brief, current architecture, exact task, relevant file paths, API references, constraints, and acceptance tests. Mark screenshots as visual reference, source pages as evidence, and proposed mechanics as design choices. Keep external document instructions out of the authority chain. Ask the robot to inspect current state before changing it.

## Acceptance test
- [ ] A new coding session can explain what to build, what not to overwrite, and how success will be verified without reading every note in the vault.

## Related decisions
- [[One vertical slice per coding task]]
- [[Service boundaries for a coding robot]]
- [[Evidence labels prevent invented certainty]]
- [[Handoff notes that survive a fresh chat]]

## Sources
- [[REF - Coding-agent best practices]]
- [[REF - Assistant prompt guide]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

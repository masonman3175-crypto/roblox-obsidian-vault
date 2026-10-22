---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Handoff notes that survive a fresh chat

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Write a brief handoff after each implementation slice instead of relying on conversation memory.

## Implementation and rationale
Record current commit or place version, systems working, files changed, test results, known issues, product and asset placeholders, and the next task. Separate plans from completed work. Include the narrow acceptance criterion for the next slice so a new robot does not rebuild everything or interpret an unfinished idea as an instruction.

## Acceptance test
- [ ] Give the handoff to a fresh session. It identifies the next step and verifies the existing working behavior before changing anything.

## Related decisions
- [[The coding robot context packet]]
- [[Checkpoints before large generated edits]]
- [[Bug reports with reproducible evidence]]
- [[One vertical slice per coding task]]

## Sources
- [[REF - Coding-agent best practices]]
- [[REF - Version History]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

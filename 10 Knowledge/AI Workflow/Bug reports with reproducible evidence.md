---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Bug reports with reproducible evidence

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Give the robot observed inputs and outputs, not only the instruction to fix everything.

## Implementation and rationale
Include environment, account fixture, exact steps, expected behavior, actual behavior, logs, and a screenshot where relevant. Ask it to reproduce the problem before patching. Preserve the failing fixture as a regression test. Fix the narrow cause before restyling unrelated UI or replacing the data layer.

## Acceptance test
- [ ] A second person reproduces the same failure from the report. After the patch, the original reproduction and adjacent edge cases behave correctly.

## Related decisions
- [[One vertical slice per coding task]]
- [[Regression suite organized by invariant]]
- [[Evidence labels prevent invented certainty]]
- [[Handoff notes that survive a fresh chat]]

## Sources
- [[REF - Coding-agent best practices]]
- [[REF - Studio testing modes]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

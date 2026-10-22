---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# One vertical slice per coding task

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Ask for a playable end-to-end behavior, not fifty disconnected scripts or a whole one-shot game.

## Implementation and rationale
A useful first slice is one snack that can be grabbed, carried, and deposited with a placeholder HUD and two-client validation. State which services it may change and which behaviors must remain. End with evidence: modified files, executed tests, untested claims, and the next smallest task. Limit speculative abstractions.

## Acceptance test
- [ ] The slice works with placeholder assets and one player before adding content. A code diff can be reviewed without understanding the entire future game.

## Related decisions
- [[The coding robot context packet]]
- [[Greybox before content volume]]
- [[Bug reports with reproducible evidence]]
- [[Checkpoints before large generated edits]]

## Sources
- [[REF - Coding-agent best practices]]
- [[REF - Prototyping]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

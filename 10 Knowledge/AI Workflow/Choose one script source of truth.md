---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Choose one script source of truth

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Either use a documented Studio-first workflow or an intentional file-first workflow; do not silently mix them.

## Implementation and rationale
Rojo is optional but useful for text-based review and Git. Document which folders sync into which services and where visual assets are edited. Save the place before connecting a sync tool to a mature project. A local file appearing in a repository does not prove it has reached Studio or been published.

## Acceptance test
- [ ] Change a test script, sync it, inspect the intended Script instance, and run it. Studio edits are either exported intentionally or kept outside the managed sync scope.

## Related decisions
- [[Service boundaries for a coding robot]]
- [[Checkpoints before large generated edits]]
- [[Static checks do not replace playtests]]
- [[Release packet and rollback boundaries]]

## Sources
- [[REF - Rojo introduction]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

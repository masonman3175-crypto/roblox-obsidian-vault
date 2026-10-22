---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Checkpoints before large generated edits

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make AI iteration recoverable through small changes and named saves.

## Implementation and rationale
Before a risky generation, keep an editable place checkpoint and file-based source snapshot where available. Record product IDs and data-schema changes separately. Review the diff before publishing. Avoid multiple tools editing the same service at once; broad automation without an ownership plan creates silent overwrites.

## Acceptance test
- [ ] Restore a checkpoint in a separate test copy and replay the last passing scenario. Do not treat restoring place code as restoring already-migrated live player data.

## Related decisions
- [[Release packet and rollback boundaries]]
- [[Versioned player-data migrations]]
- [[Handoff notes that survive a fresh chat]]
- [[Choose one script source of truth]]

## Sources
- [[REF - Version History]]
- [[REF - Rojo introduction]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

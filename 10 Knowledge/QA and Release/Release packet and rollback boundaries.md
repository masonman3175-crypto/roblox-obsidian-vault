---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Release packet and rollback boundaries

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A release includes code, catalog/config, assets, schema, and product mappings—not only a place publish.

## Implementation and rationale
Record a named place version, source revision if used, content manifest, migration version, product IDs, test evidence, and the previous working config. Keep the public release separate from test environments. Document which changes are reversible immediately and which require data compatibility or compensation.

## Acceptance test
- [ ] Restore the previous code/config in a separate test environment and load fixtures written by the new version. Identify incompatibility before promising a one-click rollback.

## Related decisions
- [[Checkpoints before large generated edits]]
- [[Versioned player-data migrations]]
- [[Roll out economy changes with a return path]]
- [[Launch gate before live purchases]]

## Sources
- [[REF - Version History]]
- [[REF - Publish games and places]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

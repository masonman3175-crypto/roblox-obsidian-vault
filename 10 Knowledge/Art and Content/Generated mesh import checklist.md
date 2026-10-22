---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Generated mesh import checklist

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Treat generated 3D content as raw production material, not a finished gameplay asset.

## Implementation and rationale
Inspect scale, pivot, forward axis, texture mapping, collision, part count, and the owning creator during import. Keep a simple collision proxy where appropriate. Store the source file and an asset ledger entry with revision and permissions. Test the uploaded asset in the actual intended experience, not only the artist's preview.

## Acceptance test
- [ ] Reimport a changed asset and verify orientation, pickup alignment, collision, and group usage. Missing textures have a useful fallback and do not break gameplay.

## Related decisions
- [[Asset provenance and ownership ledger]]
- [[Asset acceptance is functional]]
- [[Consistent inventory previews]]
- [[Original art bible]]

## Sources
- [[REF - Studio Importer]]
- [[REF - Blender to Studio]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]

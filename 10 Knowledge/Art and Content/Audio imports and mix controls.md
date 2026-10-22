---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Audio imports and mix controls

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A successful upload is not the same as approved, permitted playback in the target experience.

## Implementation and rationale
Track sound role, source/license, asset ID, approval, owner, allowed experience, loop flag, and intended volume group. Keep spoken lines brief and optional. Avoid baking essential objective instructions only into speech, since players may mute audio or use another language.

## Acceptance test
- [ ] Play every cue in a published test experience owned by the correct creator. Missing permission is detected before release and text feedback remains useful when audio is unavailable.

## Related decisions
- [[Asset provenance and ownership ledger]]
- [[A small consistent sound language]]
- [[Localization-ready strings from day one]]
- [[Launch gate before live purchases]]

## Sources
- [[REF - Audio assets]]
- [[REF - Audio overview]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]

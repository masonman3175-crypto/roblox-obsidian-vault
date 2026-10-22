---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# UI state and viewport matrix

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Test combinations of state and device instead of taking one attractive desktop screenshot.

## Implementation and rationale
Matrix dimensions: phone/tablet/desktop, touch/controller/mouse, loading/ready/error, empty/full inventory, no/owned/pending product, and short/expanded text. Prioritize high-risk combinations rather than exhaustively testing every cosmetic. Record screenshots with viewport and build metadata so regressions can be compared.

## Acceptance test
- [ ] Complete the full free loop and a mock purchase cancellation in every supported input mode. Text does not clip, focus returns correctly, and platform safe areas remain clear.

## Related decisions
- [[Mobile thumb zones and safe areas]]
- [[Controller focus is a first-class state]]
- [[Useful loading and error states]]
- [[Specify UI behavior as well as appearance]]

## Sources
- [[REF - Studio testing modes]]
- [[REF - Cross-platform development]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Localization-ready strings from day one

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep text separate from artwork and use parameterized messages instead of concatenated sentence fragments.

## Implementation and rationale
Create keys for objectives, item benefits, durations, errors, and transaction states. Translate dynamic values through placeholders so grammar can vary. Avoid putting all prices or names into generated icons. Keep a fallback language and log missing keys in test builds. Species names can remain authored proper names when intentional.

## Acceptance test
- [ ] Use long-string and pseudo-localization tests, then inspect important pricing and reward strings in selected languages. Confirm that item names and amounts remain correctly associated.

## Related decisions
- [[Accessible feedback and localization audit]]
- [[Shop browsing before checkout]]
- [[Useful loading and error states]]
- [[Consistent inventory previews]]

## Sources
- [[REF - Localization]]
- [[REF - Translate dynamic content]]
- [[REF - Studio testing modes]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

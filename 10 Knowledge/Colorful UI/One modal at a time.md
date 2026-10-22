---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# One modal at a time

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A central modal coordinator should decide which panel is visible and where input goes.

## Implementation and rationale
Use explicit priorities for a purchase details screen, tutorial overlay, settings, and collection claim. Queue only a bounded number of nonurgent messages; discard outdated ones. Background clicks must not activate a purchase through the modal. Closing a panel returns focus to the control that opened it.

## Acceptance test
- [ ] Trigger level-up, event start, and a shop opening together. Only the intended panel owns focus, and queued messages do not repeatedly reopen dismissed offers.

## Related decisions
- [[Controller focus is a first-class state]]
- [[Purchase flow is a state machine]]
- [[Offer placement without modal spam]]
- [[Lifecycle cleanup for long sessions]]

## Sources
- [[REF - Contextual purchases]]
- [[REF - UI and UX design]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

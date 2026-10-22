---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Specify UI behavior as well as appearance

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Give the robot a component and state specification before requesting a colorful interface.

## Implementation and rationale
Describe hierarchy, semantic colors, spacing, text roles, input behavior, loading/error states, and the exact purchase transition. Include multiple viewport examples. Ask for reusable components and tokens instead of a single giant LocalScript. Require an original layout and artwork even when a reference image supplies mood.

## Acceptance test
- [ ] Verify every panel using the same state fixtures at phone, tablet, and desktop widths. The UI remains functional before final icon assets are approved.

## Related decisions
- [[A reusable toy-box visual system]]
- [[Shop browsing before checkout]]
- [[HUD hierarchy and safe play space]]
- [[UI state and viewport matrix]]

## Sources
- [[REF - Assistant prompt guide]]
- [[REF - User interface overview]]
- [[REF - Cross-platform development]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Mobile thumb zones and safe areas

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Design frequent actions for reachable positions without colliding with Roblox controls.

## Implementation and rationale
Use responsive margins and a small number of large buttons. Let inventory navigation move into a drawer on narrow screens. Avoid interactions that require tiny nested targets or hover explanations. Account for device cutouts, on-screen keyboards, and changes in orientation. Choose target dimensions through real-device testing rather than assuming one pixel number fits every screen.

## Acceptance test
- [ ] Complete grab, deposit, upgrade, and shop cancellation on a small phone with touch only. Repeat while a keyboard or platform overlay is open.

## Related decisions
- [[HUD hierarchy and safe play space]]
- [[Controller focus is a first-class state]]
- [[Bright style without unreadable information]]
- [[UI state and viewport matrix]]

## Sources
- [[REF - Cross-platform development]]
- [[REF - UI position and size]]
- [[REF - Studio testing modes]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

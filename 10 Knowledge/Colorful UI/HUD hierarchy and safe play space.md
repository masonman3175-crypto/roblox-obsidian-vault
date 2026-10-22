---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# HUD hierarchy and safe play space

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Reserve the center for play and keep the next action more prominent than the shop.

## Implementation and rationale
Top: one primary balance and compact status. Left: shop and index navigation. Right: contextual action and event entry. Bottom: input-specific hotbar that avoids mobile controls. Collapse low-priority information on smaller screens rather than shrinking every label. Keep settings and close controls predictably placed.

## Acceptance test
- [ ] At narrow phone, tablet, and desktop sizes, the carry target and return route remain visible. No paid button overlaps movement, jump, or a normal gameplay action.

## Related decisions
- [[Mobile thumb zones and safe areas]]
- [[Chunky buttons with honest states]]
- [[Contextual guidance that ends]]
- [[Shop browsing before checkout]]

## Sources
- [[REF - UI and UX design]]
- [[REF - Cross-platform development]]
- [[REF - UI position and size]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

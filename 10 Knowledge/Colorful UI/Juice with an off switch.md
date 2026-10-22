---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Juice with an off switch

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use short, purposeful feedback rather than continuous screen shake and pulsing offers.

## Implementation and rationale
Celebrate a successful deposit with a brief scale pulse, a bounded particle burst, and a soft sound. Reserve stronger spectacle for a major discovery. Add reduced-motion and independent audio settings; disable nonessential loops when a panel is hidden. Never animate paid buttons to impersonate a system alert.

## Acceptance test
- [ ] Toggle reduced motion mid-session. All actions still communicate success, no screen flash remains essential, and idle menus do not consume growing frame time.

## Related decisions
- [[Rarity VFX within a budget]]
- [[A small consistent sound language]]
- [[Chunky buttons with honest states]]
- [[Lifecycle cleanup for long sessions]]

## Sources
- [[REF - UI animation and tweens]]
- [[REF - Accessibility guidelines]]
- [[REF - Improve performance]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

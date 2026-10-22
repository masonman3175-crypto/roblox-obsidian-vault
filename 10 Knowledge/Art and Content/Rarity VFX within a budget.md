---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Rarity VFX within a budget

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use VFX to punctuate a discovery, not to fill the server with permanent transparent overdraw.

## Implementation and rationale
Set per-effect and per-camera caps and a low-effects tier. Prefer bounded bursts for deposits and local cosmetic motion where the server does not need it. Stop emitters for hidden panels or distant displays. Profile simultaneous displays and celebrations, not just a single pretty asset in isolation.

## Acceptance test
- [ ] Populate every base with high-tier displays and trigger multiple deposits together. Baseline-device frame times remain within the project's measured budget.

## Related decisions
- [[Juice with an off switch]]
- [[Lifecycle cleanup for long sessions]]
- [[Measured mobile performance budget]]
- [[Bases as collectible showcases]]

## Sources
- [[REF - ParticleEmitter API]]
- [[REF - Improve performance]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]

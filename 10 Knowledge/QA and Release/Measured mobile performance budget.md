---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Measured mobile performance budget

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Choose a real baseline device and use frame time, memory, and load time as ongoing constraints.

## Implementation and rationale
Set draft goals such as a stable playable frame rate, bounded join delay, and no increasing memory trend; refine them from real tests rather than treating one triangle count as universal. Test the worst visible scene: full bases, multiple guardians, particle bursts, and open UI. Profile the largest cost before optimizing unrelated code.

## Acceptance test
- [ ] Capture before/after measurements on the same device and scene. Separate CPU, GPU, replication, and memory symptoms; an editor's fast frame rate is not a mobile result.

## Related decisions
- [[Rarity VFX within a budget]]
- [[Lifecycle cleanup for long sessions]]
- [[Streaming-safe client code]]
- [[Asset acceptance is functional]]

## Sources
- [[REF - Design for performance]]
- [[REF - MicroProfiler walkthrough]]
- [[REF - Improve performance]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]

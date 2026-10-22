---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Contextual guidance that ends

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Show the next meaningful action and remove guidance when it is done.

## Implementation and rationale
Use a modest world marker plus one short objective. Hide irrelevant arrows while a player is carrying something. Base the target on the server-confirmed tutorial step rather than a timed animation. If the target is absent or streamed out, provide a stable fallback direction rather than a broken world reference.

## Acceptance test
- [ ] Rejoin during tutorial, switch input devices, and move outside the target's streaming range. Guidance updates and eventually disappears instead of becoming a permanent HUD ornament.

## Related decisions
- [[First successful run]]
- [[HUD hierarchy and safe play space]]
- [[Streaming-safe client code]]
- [[A measurable onboarding funnel]]

## Sources
- [[REF - Onboarding]]
- [[REF - Proximity prompts]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

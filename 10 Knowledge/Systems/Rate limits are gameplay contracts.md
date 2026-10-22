---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Rate limits are gameplay contracts

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Define server request limits per action instead of trusting client debounce buttons.

## Implementation and rationale
An upgrade click, grab attempt, and snapshot request have different legitimate rates. Use per-player action buckets and bounded work per accepted request. Disconnect or expiry should clear limiter state. Log aggregate rejected counts rather than flooding output. Keep a short client cooldown only for responsive feedback.

## Acceptance test
- [ ] Hold touch input, replay requests, and reconnect. Normal tapping still works, repeated invalid requests consume bounded resources, and one player cannot starve the server.

## Related decisions
- [[Intent-only network contracts]]
- [[One currency mutation path]]
- [[Spatial validation under latency]]
- [[Two-client and bad-network scenarios]]

## Sources
- [[REF - Client-server boundary validation]]
- [[REF - Security and cheat mitigation]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]

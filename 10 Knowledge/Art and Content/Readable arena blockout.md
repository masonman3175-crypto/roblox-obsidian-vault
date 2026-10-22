---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Readable arena blockout

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use landmarks and route geometry to organize chaos rather than filling every empty area with props.

## Implementation and rationale
Place bases around a shared activity space and keep return paths visibly connected. Use height or material changes to distinguish danger, safe display, and shop. Reserve expansion sockets rather than building a huge empty map. A large decorative guardian must not hide a required path or obstruct every camera angle.

## Acceptance test
- [ ] Walk every route from a new player's camera height on touch and desktop. The destination remains visible or signposted, and crowded servers still allow navigation.

## Related decisions
- [[Greybox before content volume]]
- [[Zones change play not just price]]
- [[Streaming-safe client code]]
- [[A ten-second hook]]

## Sources
- [[REF - Prototyping]]
- [[REF - Design for performance]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]

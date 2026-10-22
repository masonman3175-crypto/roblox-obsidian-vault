---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# UI snapshots and revisions

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep clients synchronized with compact authoritative state rather than letting each panel invent local truth.

## Implementation and rationale
Send a full initial view after load, then bounded updates with a revision. UI controllers reject older revisions and can request a fresh snapshot after a gap. Do not replicate private receipt history or internal diagnostics to every client. Keep purely cosmetic animation progress local.

## Acceptance test
- [ ] Open shop and index during a delayed deposit response. Both eventually show the same balance and ownership without the older reply undoing newer state.

## Related decisions
- [[Collectible lifecycle state machine]]
- [[Intent-only network contracts]]
- [[Service boundaries for a coding robot]]
- [[Useful loading and error states]]

## Sources
- [[REF - Remote events and callbacks]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]

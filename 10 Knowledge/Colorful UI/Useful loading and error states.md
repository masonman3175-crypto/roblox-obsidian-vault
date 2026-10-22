---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Useful loading and error states

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A missing model, failed request, or slow data load should leave the player with an intelligible interface.

## Implementation and rationale
Use separate states for initial load, temporary retry, partial content, and unrecoverable session initialization. Show a neutral placeholder for unapproved images; keep item names and benefits in text. Bound retries and avoid infinite spinners. Never present a fresh empty inventory as confirmed data while the account is still loading.

## Acceptance test
- [ ] Disable selected assets and delay service responses. The player can close nonessential panels, understands what is pending, and does not accidentally repurchase an item.

## Related decisions
- [[Persistence is part of gameplay]]
- [[Purchase flow is a state machine]]
- [[Index cards that guide exploration]]
- [[UI snapshots and revisions]]

## Sources
- [[REF - User interface overview]]
- [[REF - Data stores]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

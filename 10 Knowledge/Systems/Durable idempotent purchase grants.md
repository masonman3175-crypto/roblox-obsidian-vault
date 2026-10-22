---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Durable idempotent purchase grants

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A purchase grant is complete only when the durable record and grant agree.

## Implementation and rationale
Route every product ID through one receipt dispatcher. Deduplicate by PurchaseId, apply the grant to the authoritative record, persist grant plus receipt identity, and acknowledge only after durable success. Serialize against other player mutations and use session ownership. Unknown IDs and unavailable player data must remain retryable, not disappear.

## Acceptance test
- [ ] Replay one receipt repeatedly, fail persistence after the first in-memory grant, and reconnect during fulfilment. Exactly one durable grant remains; a cancelled prompt grants nothing.

## Related decisions
- [[Session ownership and concurrent joins]]
- [[Persistence is part of gameplay]]
- [[Purchase flow is a state machine]]
- [[Products are not all the same entitlement]]

## Sources
- [[REF - Developer products]]
- [[REF - Player data and purchasing systems]]
- [[REF - MarketplaceService API]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]

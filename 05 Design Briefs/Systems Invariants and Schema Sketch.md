---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, brief, architecture]
---

# Systems Invariants and Schema Sketch

## Proposed serializable record
```text
schemaVersion
coins
inventory[instanceId] = speciesId, acquisitionKind, acquiredAt, locked, cosmeticId
displaySlots[slotId] = instanceId
discoveredSpecies[speciesId] = firstFoundAt, milestoneClaimed
tutorialStep
upgrades
prestige
boosts = kind, expiryOrRemaining, stackingRule
processedPurchaseIds
seasonProgress[seasonId]
pendingGrants
lastEligibleOfflineTimestamp
settings
```

This is an architectural sketch, not a drop-in production schema. Keep sensitive operational records off public clients. Platform pass/subscription ownership and profile-stored entitlements require different reconciliation paths. Do not let unbounded arrays or arbitrary client fields grow forever; decide on limits and archival during implementation.

## Invariants
1. An item instance has one owner and at most one active carry/display location.
2. A display slot references an owned, eligible instance.
3. Every currency mutation uses the same validation path.
4. A failed load never authorizes overwriting a real account with defaults.
5. A legitimate receipt has one durable grant; acknowledgement follows durable success.
6. A state transition can be retried without creating extra items or awards.
7. A client can request but cannot choose a reward or another player's authoritative state.
8. An analytics outage cannot corrupt the economic operation it observes.
9. A model or preview disappearing does not destroy inventory ownership.
10. A schema migration preserves valid durable purchases and is tested with old fixtures.

## Transaction boundaries
A deposit updates item lifecycle, owner inventory, and slot occupancy consistently before publishing the new view. A sale removes one eligible item and credits once. A fusion reserves and consumes exact instance IDs with a recoverable deterministic output. A trade across two records is a separate distributed transaction design and is deferred.

## Failure states
Account loading, read-only recovery, transient save failure, pending receipt fulfilment, missing asset, stale request, full capacity, and rejected eligibility each need a deliberate user experience. A spinner and a warning in Output are not complete recovery designs.

## Implementation order
Write types and fixtures → implement in-memory operations → test invariants → integrate persistence/session ownership → test faults → integrate receipts → test replays → connect UI projections → run real multi-client/device tests.

Related: [[Service boundaries for a coding robot]] · [[Stable item IDs and provenance]] · [[Collectible lifecycle state machine]] · [[Persistence is part of gameplay]] · [[Durable idempotent purchase grants]] · [[Regression suite organized by invariant]]

References: [[REF - Remote events and callbacks]] · [[REF - Client-server boundary validation]] · [[REF - Player data and purchasing systems]] · [[REF - Data stores]]

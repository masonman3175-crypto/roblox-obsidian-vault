---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Purchase flow is a state machine

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Model browsing, prompting, pending fulfilment, owned, cancelled, and error states explicitly.

## Implementation and rationale
A closed platform prompt is not proof of a completed purchase. After a legitimate purchase, show pending fulfilment until authoritative entitlement state arrives. If save or delivery is delayed, keep recovery messaging calm and do not immediately prompt the user to purchase again. Allow the panel to close while preserving fulfilment.

## Acceptance test
- [ ] Cancel, disconnect, delay receipt delivery, and retry a known receipt. UI never displays a permanent grant that the server has not confirmed, and never grants from the prompt-finished event.

## Related decisions
- [[Durable idempotent purchase grants]]
- [[Products are not all the same entitlement]]
- [[Shop browsing before checkout]]
- [[Useful loading and error states]]

## Sources
- [[REF - Developer products]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]

---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, brief, monetization]
---

# Monetization Catalog and Grant Map

## Broad catalog, small reliable launch
The user wants many microtransactions. This draft supplies **28 product ideas** across eight visual families without making 28 unrelated purchase systems. Launch only a small tested subset first. The example Robux values below are **unvalidated design hypotheses**, not competitor prices, optimal prices, or products created on Roblox. Every external product ID remains `UNASSIGNED`.

| SKU | Product | Draft platform kind | Exact benefit | Draft base Robux |
|---|---|---|---|---|
| WRAP_BUBBLEGUM | Bubblegum wrapper | Pass | Permanent cosmetic skin | 39 |
| WRAP_SPACE | Space-foil wrapper | Pass | Permanent cosmetic skin | 79 |
| WRAP_PAPER | Paper-craft wrapper | Pass | Permanent cosmetic skin | 39 |
| WRAP_GOLD | Golden foil wrapper | Pass | Permanent cosmetic skin; no income bonus | 149 |
| TRAIL_SPRINKLE | Sprinkle trail | Pass | Permanent trail unlock | 59 |
| TRAIL_COMET | Comet crumbs | Pass | Permanent trail unlock | 99 |
| TRAIL_BUBBLE | Soda bubbles | Pass | Permanent trail unlock | 59 |
| TRAIL_PIXEL | Pixel confetti | Pass | Permanent trail unlock | 79 |
| BASE_DINER | Retro diner base | Pass | Permanent base theme | 149 |
| BASE_SPACE | Space cafeteria base | Pass | Permanent base theme | 199 |
| BASE_CLOUD | Cloud picnic base | Pass | Permanent base theme | 149 |
| BASE_PAPER | Paper lunchbox base | Pass | Permanent base theme | 99 |
| POSE_CHEF | Chef celebration | Pass | Permanent emote unlock | 39 |
| POSE_CART | Cartwheel celebration | Pass | Permanent emote unlock | 59 |
| POSE_SODA | Soda toast | Pass | Permanent emote unlock | 39 |
| POSE_ROBOT | Robot delivery dance | Pass | Permanent emote unlock | 79 |
| PLINTH_TOY | Toy pedestal set | Pass | Permanent display appearance | 79 |
| PLINTH_NEON | Neon pedestal set | Pass | Permanent display appearance | 99 |
| NAME_NOODLE | Noodle courier nameplate | Pass | Permanent nameplate | 39 |
| NAME_STAR | Star courier nameplate | Pass | Permanent nameplate | 59 |
| CARRY_CART | Toy-cart carry style | Pass | Animation only; identical movement | 99 |
| CARRY_BALLOON | Balloon carry style | Pass | Animation only; identical movement | 99 |
| CAMERA_PROPS | Photo prop set | Pass | Noncompetitive camera props | 79 |
| COSMETIC_BUNDLE | Snack-party cosmetic bundle | Pass | Exact listed cosmetics; ownership-aware | 249 |
| COINS_SMALL | Small coin pack | Developer product | Fixed earned-currency amount; no random outlet | 19 |
| COINS_MEDIUM | Medium coin pack | Developer product | Fixed amount from reviewed config | 49 |
| BOOST_DISPLAY | Display boost | Developer product | Defined time and bounded production modifier | 39 |
| BOOST_ROUTE | Route practice token | Developer product | Optional practice convenience; free practice remains | 19 |

## Grant routing
- Permanent pass: use current documented platform ownership checks and reconcile the cosmetic unlock. Do not treat it as a developer-product receipt.
- Repeatable developer product: one server receipt dispatcher applies the configured grant with durable PurchaseId deduplication and persistence before acknowledgement.
- Bundle: enumerate exact included items, existing-ownership handling, and any duplicate benefit. Do not accidentally charge for an already-owned cosmetic without a disclosed rule.
- Currency: no randomized spending path in the MVP. A paid currency can make downstream randomness a paid-random system even when the wheel itself does not show Robux.
- Boost: disclose duration, effect, stacking, offline behavior, and expiry; do not promise hidden luck or permanent value.

## Shop contract
Show current runtime prices; the draft numbers are never painted into final product artwork. Use explicit categories, previews, duration, owned state, and an intentional purchase button. Never make a close button trigger checkout. Never create a resetting discount timer, fake stock warning, or forced purchase during onboarding.

## Economy review
Coins are optional convenience and must not be required to reach core content. Model their impact before enabling the packs. If coin purchasing makes earned progress trivial or creates pressure to buy, reduce or remove the packs instead of making free progress worse. Keep competitive movement/hitboxes consistent across paid visuals.

## Deferred products
Season premium track, subscriptions, private servers, inventory convenience, and any paid randomness each need their own reviewed lifecycle. The linked decision notes explain these options; they are not automatically part of MVP. No live products or purchase IDs are created by this research work.

## Rollout checklist
- [ ] Catalog definition validates and maps to the right platform kind.
- [ ] All grant failure and replay scenarios pass in a separate test setup.
- [ ] Card price equals platform prompt price for test users.
- [ ] Full core loop remains useful without spending.
- [ ] Asset permissions, owned state, and support trace are ready.
- [ ] Current platform requirements are rechecked before enabling a new product type.

Related: [[Many products through one catalog]] · [[Durable idempotent purchase grants]] · [[Products are not all the same entitlement]] · [[Runtime prices not painted prices]] · [[Paid randomness decision gate]] · [[Shop metrics include failed fulfilment]]

Sources: [[REF - Monetization overview]] · [[REF - Developer products]] · [[REF - Passes]] · [[REF - Player data and purchasing systems]] · [[REF - Paid random item guidelines]] · [[REF - Regional pricing]]

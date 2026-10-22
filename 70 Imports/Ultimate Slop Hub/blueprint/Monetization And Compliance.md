---
type: monetization
game: hub
owner: shared
status: building
sources:
  - https://create.roblox.com/docs/production/monetization/developer-products
  - https://create.roblox.com/docs/production/monetization/game-passes
  - Cade's brief (2026-10-17)
updated: 2026-10-17
---

# Monetization And Compliance

Hard rules for every slop game. Stat boosts and convenience passes are fine in these games. Lying to players is not.

## Allowed
- Gamepasses: 2x stats, auto-train, VIP (chat tag, VIP zone, bonus), extra pet slots, faster walk.
- Dev products: stat packs, timed boosts, zone skips, rebirth skips, currency packs.
- Shop buttons on screen, popups after an unlock, "boost" buttons near training spots.

## Not allowed
- **Paid random items without odds.** Any egg, crate, or spin bought with Robux (or with currency that is bought with Robux) must show the % chance of every item before purchase.
- **Fake timers or fake scarcity** ("only 2 left!", countdowns that reset).
- **Misleading prices**: show the real Robux price from `MarketplaceService:GetProductInfo`, never a made-up "was 999" price.
- Hiding that something costs Robux, or tricking a tap into a purchase.
- Real-money gambling style stuff, trading items for Robux outside Roblox.
- Same content rules as CLAUDE.md (no gangs, gore, real places, other IP).

## Server-authoritative purchases
- Gamepasses: check ownership on join with `MarketplaceService:UserOwnsGamePassAsync` (pcall, cache the result), and on `PromptGamePassPurchaseFinished` re-check on the server. Never trust a client "I bought it" remote.
- Dev products: **one** `MarketplaceService.ProcessReceipt` callback for the whole game.
  1. Find the player. Not in game: return `NotProcessedYet`.
  2. Make sure their data is loaded. Not loaded: `NotProcessedYet`.
  3. Check `PurchaseId` against the saved list of processed receipts. Already done: `PurchaseGranted`.
  4. Grant the item, record the `PurchaseId`, save. Save failed: `NotProcessedYet` (Roblox retries).
  5. Return `PurchaseGranted` only after the grant is saved.
- All IDs in `ReplicatedStorage.Shared.Config.Monetization`. Placeholder `0` means "not created yet": the button shows "Coming soon" and does not prompt.

## Related
- [[70 Imports/Ultimate Slop Hub/blueprint/Slop Blueprint|Slop Blueprint]]
- [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]

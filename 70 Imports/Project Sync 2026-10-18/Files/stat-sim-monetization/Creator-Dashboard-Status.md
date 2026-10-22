# Creator Dashboard setup status

Place: `ultimate slopp v1` (`98823628319724`). The place is private. The Studio Edit session has the code; cloud save of the edited place was not verified.

The current catalog has **13 passes and 14 developer products**, each with an intended price from **R$5 to R$99**. An `Id` of `0` means that listing has **not** been created; its button shows the planned price plus `SETUP` and cannot grant a test purchase. The client checks the real Roblox price and blocks mismatches or prices above R$100 before prompting.

## Created and verified

| Product key | Creator Dashboard ID | Price | API status |
|---|---:|---:|---|
| StrengthSmall | 3719745475 | R$5 | On sale; API R$5 |
| StrengthMedium | 3719749527 | R$15 | On sale; API R$15 |
| StrengthLarge | 3719749718 | R$49 | On sale; API R$49 |
| CoinsSmall | 3719749809 | R$5 | On sale; API R$5 |

All four have Managed Pricing disabled to preserve a fixed maximum. No Robux purchase was made for testing.

## Still to create

Create these in **Creator Dashboard → Monetization → Developer products**, keep **Managed Pricing off**, set the shown price, and enter each resulting ID in `ReplicatedStorage.Shared.Config.Monetization` (also update `build.py`'s `created_ids` so regeneration preserves it):

| Key | Name | R$ |
|---|---|---:|
| CoinsMedium | Coin Chest | 15 |
| CoinsLarge | Coin Vault | 49 |
| Boost | x2 Strength (15 min) | 9 |
| CoinBoost | x2 Coins (15 min) | 9 |
| LuckBoost | x2 Luck (15 min) | 9 |
| Level | +1 Level | 9 |
| RebirthSkip | Rebirth Skip | 39 |
| WorldSkip | Unlock Next World | 59 |
| MegaEgg | Mega Egg | 39 |
| UltraEgg | Ultra Robux Egg | 99 |

Create these in **Creator Dashboard → Monetization → Passes**, keep each pass on sale at the listed price, and enter its ID in the same config:

| Key | Name | R$ |
|---|---|---:|
| Double | x2 Strength | 79 |
| AutoTrain | Auto Click | 49 |
| VIP | VIP | 99 |
| AutoPunch | Auto Punch | 59 |
| DoubleCoins | x2 Coins | 49 |
| FastWalk | Speed Boots | 19 |
| TripleHatch | Triple Hatch | 39 |
| AutoHatch | Auto Hatch | 69 |
| Lucky | Lucky Eggs | 59 |
| PetSlots | +3 Pet Slots | 49 |
| GymVIP | VIP Gym | 19 |
| GymMega | Mega Gym | 39 |
| GymAdmin | Admin Gym | 79 |

The **Mega Egg** has Diamond Dog 70%, Rainbow Dragon 25%, Golden Cerberus 5%. The new **Ultra Robux Egg** has Candy Hydra 65%, Blizzard Dragon 25%, Demon King 10%. Both odds appear on the in-game shop cards before buying. Paid random egg prompts check `PolicyService.ArePaidRandomItemsRestricted`; the server rejects unpaid hatches and defers a paid receipt if inventory is full rather than consuming it without a pet.

After IDs are set, verify each Creator Dashboard price with `MarketplaceService:GetProductInfo`, save the Studio place to Roblox, and test a real purchase only in a controlled private session. The current browser automation stopped because it could not verify the browser URL, so the remaining listings were not submitted.

Official reference: [Developer products](https://create.roblox.com/docs/production/monetization/developer-products), [passes](https://create.roblox.com/docs/production/monetization/passes), [paid random item rules](https://create.roblox.com/docs/production/monetization/paid-random-items).

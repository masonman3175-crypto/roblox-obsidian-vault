---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Config.Monetization

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Config.Monetization`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Monetization.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Config/Monetization.luau)

```luau
-- Catalog prices are the intended Creator Dashboard prices; Id=0 means not on sale.
-- Never grant a purchase from an unbound listing.
local Monetization = {}
Monetization.MaxRobux = 100

-- Tab = which shop tab shows it.
Monetization.Passes = {
	Double = {Id = 0, Price = 79, Tab = "Passes", Name = "x2 Strength", Description = "Double every Strength gain forever"},
	AutoTrain = {Id = 0, Price = 49, Tab = "Passes", Name = "Auto Click", Description = "+5 free clicks every second"},
	VIP = {Id = 0, Price = 99, Tab = "Passes", Name = "VIP", Description = "+50% Strength and Coins, VIP tag"},
	AutoPunch = {Id = 0, Price = 59, Tab = "Passes", Name = "Auto Punch", Description = "Keeps punching the dummy for you"},
	DoubleCoins = {Id = 0, Price = 49, Tab = "Passes", Name = "x2 Coins", Description = "Double Coins from every punch"},
	FastWalk = {Id = 0, Price = 19, Tab = "Passes", Name = "Speed Boots", Description = "+50% walk speed"},
	TripleHatch = {Id = 0, Price = 39, Tab = "Eggs", Name = "Triple Hatch", Description = "Open 3 eggs at once"},
	AutoHatch = {Id = 0, Price = 69, Tab = "Eggs", Name = "Auto Hatch", Description = "Keeps hatching the closest egg"},
	Lucky = {Id = 0, Price = 59, Tab = "Eggs", Name = "Lucky Eggs", Description = "x2 chance for Epic, Legendary, Mythic"},
	PetSlots = {Id = 0, Price = 49, Tab = "Eggs", Name = "+3 Pet Slots", Description = "Equip 6 pets instead of 3"},
	GymVIP = {Id = 0, Price = 19, Tab = "Gym", Name = "VIP Gym", Description = "Unlocks the x10 VIP bench"},
	GymMega = {Id = 0, Price = 39, Tab = "Gym", Name = "Mega Gym", Description = "Unlocks the x25 Mega bench"},
	GymAdmin = {Id = 0, Price = 79, Tab = "Gym", Name = "Admin Gym", Description = "Unlocks the x99 Admin bench"},
}
Monetization.PassOrder = {"Double", "AutoTrain", "VIP", "AutoPunch", "DoubleCoins", "FastWalk", "TripleHatch", "AutoHatch", "Lucky", "PetSlots", "GymVIP", "GymMega", "GymAdmin"}

Monetization.Products = {
	StrengthSmall = {Id = 3719745475, Price = 5, Tab = "Boosts", Name = "Strength Pack", Description = "100 clicks of Strength", Clicks = 100},
	StrengthMedium = {Id = 3719749527, Price = 15, Tab = "Boosts", Name = "Big Strength Pack", Description = "500 clicks of Strength", Clicks = 500},
	StrengthLarge = {Id = 3719749718, Price = 49, Tab = "Boosts", Name = "Huge Strength Pack", Description = "2,500 clicks of Strength", Clicks = 2500},
	CoinsSmall = {Id = 3719749809, Price = 5, Tab = "Coins", Name = "Coin Bag", Description = "10 punches worth of Coins", Punches = 10},
	CoinsMedium = {Id = 3719845747, Price = 15, Tab = "Coins", Name = "Coin Chest", Description = "50 punches worth of Coins", Punches = 50},
	CoinsLarge = {Id = 3719859286, Price = 49, Tab = "Coins", Name = "Coin Vault", Description = "250 punches worth of Coins", Punches = 250},
	Boost = {Id = 3719860768, Price = 9, Tab = "Boosts", Name = "x2 Strength (15 min)", Description = "Double Strength for 15 minutes", Seconds = 900},
	CoinBoost = {Id = 0, Price = 9, Tab = "Boosts", Name = "x2 Coins (15 min)", Description = "Double Coins for 15 minutes", Seconds = 900},
	LuckBoost = {Id = 0, Price = 9, Tab = "Eggs", Name = "x2 Luck (15 min)", Description = "Lucky hatching for 15 minutes", Seconds = 900},
	Level = {Id = 0, Price = 9, Tab = "Boosts", Name = "+1 Level", Description = "Instantly gain a level"},
	RebirthSkip = {Id = 0, Price = 39, Tab = "Boosts", Name = "Rebirth Skip", Description = "+1 Rebirth and keep your Strength and level"},
	WorldSkip = {Id = 0, Price = 59, Tab = "Boosts", Name = "Unlock Next World", Description = "Opens the next world right now"},
	MegaEgg = {Id = 0, Price = 39, Tab = "Eggs", Name = "Mega Egg", Description = "One random pet; odds shown below"},
	UltraEgg = {Id = 0, Price = 99, Tab = "Eggs", Name = "Ultra Robux Egg", Description = "One random ultra pet; odds shown below"},
}
Monetization.ProductOrder = {"StrengthSmall", "StrengthMedium", "StrengthLarge", "Boost", "Level", "RebirthSkip", "WorldSkip", "CoinsSmall", "CoinsMedium", "CoinsLarge", "CoinBoost", "MegaEgg", "UltraEgg", "LuckBoost"}
Monetization.Tabs = {"Passes", "Boosts", "Coins", "Eggs", "Gym"}

function Monetization.FindProduct(productId)
	if productId == 0 then
		return nil
	end
	for key, product in Monetization.Products do
		if product.Id == productId then
			return key, product
		end
	end
	return nil
end

return Monetization


```


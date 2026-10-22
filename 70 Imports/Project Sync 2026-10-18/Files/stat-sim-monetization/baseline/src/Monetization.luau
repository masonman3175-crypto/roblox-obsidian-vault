-- ALL gamepass and dev product IDs live here.
-- Id 0 = not created yet: live servers show "Soon" and never prompt.
-- In Studio, Id 0 buttons grant the item for free so we can test (server checks IsStudio).
-- Prices are never written here; the UI reads the real price from Roblox.
local Monetization = {}

-- Tab = which shop tab shows it.
Monetization.Passes = {
	Double = {Id = 0, Tab = "Passes", Name = "x2 Strength", Description = "Double every Strength gain forever"},
	AutoTrain = {Id = 0, Tab = "Passes", Name = "Auto Click", Description = "+5 free clicks every second"},
	VIP = {Id = 0, Tab = "Passes", Name = "VIP", Description = "+50% Strength and Coins, VIP tag"},
	AutoPunch = {Id = 0, Tab = "Passes", Name = "Auto Punch", Description = "Keeps punching the dummy for you"},
	DoubleCoins = {Id = 0, Tab = "Passes", Name = "x2 Coins", Description = "Double Coins from every punch"},
	FastWalk = {Id = 0, Tab = "Passes", Name = "Speed Boots", Description = "+50% walk speed"},
	TripleHatch = {Id = 0, Tab = "Eggs", Name = "Triple Hatch", Description = "Open 3 eggs at once"},
	AutoHatch = {Id = 0, Tab = "Eggs", Name = "Auto Hatch", Description = "Keeps hatching the closest egg"},
	Lucky = {Id = 0, Tab = "Eggs", Name = "Lucky Eggs", Description = "x2 chance for Epic, Legendary, Mythic"},
	PetSlots = {Id = 0, Tab = "Eggs", Name = "+3 Pet Slots", Description = "Equip 6 pets instead of 3"},
	GymVIP = {Id = 0, Tab = "Gym", Name = "VIP Gym", Description = "Unlocks the x10 VIP bench"},
	GymMega = {Id = 0, Tab = "Gym", Name = "Mega Gym", Description = "Unlocks the x25 Mega bench"},
	GymAdmin = {Id = 0, Tab = "Gym", Name = "Admin Gym", Description = "Unlocks the x99 Admin bench"},
}
Monetization.PassOrder = {"Double", "AutoTrain", "VIP", "AutoPunch", "DoubleCoins", "FastWalk", "TripleHatch", "AutoHatch", "Lucky", "PetSlots", "GymVIP", "GymMega", "GymAdmin"}

Monetization.Products = {
	StrengthSmall = {Id = 0, Tab = "Boosts", Name = "Strength Pack", Description = "100 clicks of Strength", Clicks = 100},
	StrengthMedium = {Id = 0, Tab = "Boosts", Name = "Big Strength Pack", Description = "500 clicks of Strength", Clicks = 500},
	StrengthLarge = {Id = 0, Tab = "Boosts", Name = "Huge Strength Pack", Description = "2,500 clicks of Strength", Clicks = 2500},
	CoinsSmall = {Id = 0, Tab = "Coins", Name = "Coin Bag", Description = "10 punches worth of Coins", Punches = 10},
	CoinsMedium = {Id = 0, Tab = "Coins", Name = "Coin Chest", Description = "50 punches worth of Coins", Punches = 50},
	CoinsLarge = {Id = 0, Tab = "Coins", Name = "Coin Vault", Description = "250 punches worth of Coins", Punches = 250},
	Boost = {Id = 0, Tab = "Boosts", Name = "x2 Strength (15 min)", Description = "Double Strength for 15 minutes", Seconds = 900},
	CoinBoost = {Id = 0, Tab = "Boosts", Name = "x2 Coins (15 min)", Description = "Double Coins for 15 minutes", Seconds = 900},
	LuckBoost = {Id = 0, Tab = "Eggs", Name = "x2 Luck (15 min)", Description = "Lucky hatching for 15 minutes", Seconds = 900},
	Level = {Id = 0, Tab = "Boosts", Name = "+1 Level", Description = "Instantly gain a level"},
	RebirthSkip = {Id = 0, Tab = "Boosts", Name = "Rebirth Skip", Description = "+1 Rebirth and keep your Strength and level"},
	WorldSkip = {Id = 0, Tab = "Boosts", Name = "Unlock Next World", Description = "Opens the next world right now"},
	MegaEgg = {Id = 0, Tab = "Eggs", Name = "Mega Egg", Description = "70% Diamond Dog, 25% Rainbow Dragon, 5% Golden Cerberus"},
}
Monetization.ProductOrder = {"StrengthSmall", "StrengthMedium", "StrengthLarge", "Boost", "Level", "RebirthSkip", "WorldSkip", "CoinsSmall", "CoinsMedium", "CoinsLarge", "CoinBoost", "MegaEgg", "LuckBoost"}
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

-- Eggs. Odds are shown to players on the egg board and in the hatch UI
-- (required for any random item, and always for the Robux egg).
-- Chance values are percents and add up to 100 per egg.
local Eggs = {}

local STANDARD = {55, 28, 12, 4, 0.9, 0.1}

local function egg(name, world, cost, petIds)
	local pets = {}
	for i, id in petIds do
		table.insert(pets, {Id = id, Chance = STANDARD[i]})
	end
	return {Name = name, World = world, Cost = cost, Pets = pets}
end

Eggs.List = {
	Starter = egg("Starter Egg", 1, 25, {"Doggy", "Kitty", "Bunny", "Fox", "Unicorn", "DemiDog"}),
	Buff = egg("Buff Egg", 1, 250, {"Bear", "Gorilla", "Wolf", "Lion", "GoldenGorilla", "Cerberus"}),
	Candy = egg("Candy Egg", 2, 5000, {"GummyBear", "LollipopCat", "CupcakePup", "CandyDragon", "SugarDemon", "RainbowUnicorn"}),
	CandyPlus = egg("Candy+ Egg", 2, 40000, {"ChocoBunny", "MarshmallowSheep", "DonutDog", "CottonCandyFairy", "CandyKing", "CandyHydra"}),
	Frost = egg("Frost Egg", 3, 400000, {"Penguin", "SnowFox", "IceWolf", "Yeti", "FrostPhoenix", "IceHydra"}),
	FrostPlus = egg("Frost+ Egg", 3, 3000000, {"SnowOwl", "Walrus", "PolarBear", "IceGolem", "FrostTitan", "BlizzardDragon"}),
	Inferno = egg("Inferno Egg", 4, 30000000, {"MagmaSlime", "FireBat", "LavaHound", "FlameGolem", "Hellhound", "ThreeHeadedDragon"}),
	InfernoPlus = egg("Inferno+ Egg", 4, 250000000, {"EmberFox", "ObsidianTurtle", "PhoenixChick", "MagmaTitan", "InfernoDemon", "DemonKing"}),
	Galaxy = egg("Galaxy Egg", 5, 2500000000, {"Alien", "UFOCat", "StarWolf", "NebulaDragon", "VoidTitan", "CosmicGod"}),
	GalaxyPlus = egg("Galaxy+ Egg", 5, 20000000000, {"MoonBunny", "AstroDog", "MeteorGolem", "BlackHoleBeast", "GalaxyLeviathan", "InfinityDragon"}),
	-- Robux egg: bought with the MegaEgg dev product, odds shown before buying
	Mega = {Name = "Mega Egg", World = 1, Cost = 0, ProductKey = "MegaEgg", Pets = {
		{Id = "DiamondDog", Chance = 70},
		{Id = "RainbowDragon", Chance = 25},
		{Id = "GoldenCerberus", Chance = 5},
	}},
}

-- Lucky (pass or boost) doubles Epic and better, taken evenly from the rest
function Eggs.Roll(eggId, lucky, rng)
	local e = Eggs.List[eggId]
	local weights = {}
	local total = 0
	for i, entry in e.Pets do
		local w = entry.Chance
		if lucky and i >= 4 and #e.Pets == 6 then
			w *= 2
		end
		weights[i] = w
		total += w
	end
	local roll = rng:NextNumber() * total
	for i, entry in e.Pets do
		roll -= weights[i]
		if roll <= 0 then
			return entry.Id
		end
	end
	return e.Pets[1].Id
end

return Eggs

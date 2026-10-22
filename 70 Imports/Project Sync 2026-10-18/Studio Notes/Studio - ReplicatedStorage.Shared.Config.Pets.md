---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Config.Pets

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Config.Pets`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Pets.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Config/Pets.luau)

```luau
-- Every pet, by id. Hatched from eggs (Config.Eggs). Equipped pets add their
-- Power to the Pets multiplier: total = 1 + sum of equipped Power.
-- 3D models: ReplicatedStorage.PetModels.<id> (placeholder ball if missing).
local Pets = {}

Pets.Rarities = {
	Common = {Order = 1, Color = Color3.fromRGB(200, 200, 210)},
	Uncommon = {Order = 2, Color = Color3.fromRGB(90, 220, 90)},
	Rare = {Order = 3, Color = Color3.fromRGB(60, 150, 255)},
	Epic = {Order = 4, Color = Color3.fromRGB(180, 80, 255)},
	Legendary = {Order = 5, Color = Color3.fromRGB(255, 190, 30)},
	Mythic = {Order = 6, Color = Color3.fromRGB(255, 50, 90)},
}

local function pet(name, rarity, power, color)
	return {Name = name, Rarity = rarity, Power = power, Color = color}
end

local C3 = Color3.fromRGB

Pets.List = {
	-- Starter Egg (hub)
	Doggy = pet("Doggy", "Common", 0.2, C3(200, 150, 100)),
	Kitty = pet("Kitty", "Common", 0.25, C3(255, 170, 90)),
	Bunny = pet("Bunny", "Uncommon", 0.4, C3(240, 240, 250)),
	Fox = pet("Fox", "Rare", 0.8, C3(255, 120, 40)),
	Unicorn = pet("Unicorn", "Epic", 2, C3(255, 200, 250)),
	DemiDog = pet("Demi-Dog", "Legendary", 6, C3(255, 215, 80)),
	-- Buff Egg (hub)
	Bear = pet("Bear", "Common", 0.5, C3(140, 90, 60)),
	Gorilla = pet("Gorilla", "Uncommon", 1, C3(70, 70, 80)),
	Wolf = pet("Wolf", "Rare", 2, C3(150, 150, 170)),
	Lion = pet("Lion", "Epic", 4, C3(230, 170, 60)),
	GoldenGorilla = pet("Golden Gorilla", "Legendary", 12, C3(255, 200, 40)),
	Cerberus = pet("Cerberus", "Mythic", 40, C3(120, 20, 30)),
	-- Candy Egg (world 2)
	GummyBear = pet("Gummy Bear", "Common", 2, C3(255, 80, 80)),
	LollipopCat = pet("Lollipop Cat", "Uncommon", 4, C3(255, 120, 220)),
	CupcakePup = pet("Cupcake Pup", "Rare", 8, C3(255, 180, 200)),
	CandyDragon = pet("Candy Dragon", "Epic", 18, C3(255, 90, 180)),
	SugarDemon = pet("Sugar Demon", "Legendary", 50, C3(200, 40, 140)),
	RainbowUnicorn = pet("Rainbow Unicorn", "Mythic", 150, C3(255, 255, 255)),
	-- Candy+ Egg
	ChocoBunny = pet("Choco Bunny", "Common", 4, C3(120, 70, 40)),
	MarshmallowSheep = pet("Marshmallow Sheep", "Uncommon", 8, C3(255, 240, 245)),
	DonutDog = pet("Donut Dog", "Rare", 16, C3(230, 160, 110)),
	CottonCandyFairy = pet("Cotton Candy Fairy", "Epic", 35, C3(180, 220, 255)),
	CandyKing = pet("Candy King", "Legendary", 100, C3(255, 60, 160)),
	CandyHydra = pet("Candy Hydra", "Mythic", 300, C3(255, 100, 200)),
	-- Frost Egg (world 3)
	Penguin = pet("Penguin", "Common", 8, C3(40, 40, 60)),
	SnowFox = pet("Snow Fox", "Uncommon", 15, C3(235, 245, 255)),
	IceWolf = pet("Ice Wolf", "Rare", 30, C3(150, 210, 255)),
	Yeti = pet("Yeti", "Epic", 70, C3(220, 235, 255)),
	FrostPhoenix = pet("Frost Phoenix", "Legendary", 200, C3(110, 200, 255)),
	IceHydra = pet("Ice Hydra", "Mythic", 600, C3(80, 170, 255)),
	-- Frost+ Egg
	SnowOwl = pet("Snow Owl", "Common", 15, C3(245, 245, 255)),
	Walrus = pet("Walrus", "Uncommon", 30, C3(160, 110, 90)),
	PolarBear = pet("Polar Bear", "Rare", 60, C3(250, 250, 255)),
	IceGolem = pet("Ice Golem", "Epic", 140, C3(120, 190, 240)),
	FrostTitan = pet("Frost Titan", "Legendary", 400, C3(90, 150, 255)),
	BlizzardDragon = pet("Blizzard Dragon", "Mythic", 1200, C3(170, 230, 255)),
	-- Inferno Egg (world 4)
	MagmaSlime = pet("Magma Slime", "Common", 30, C3(255, 100, 30)),
	FireBat = pet("Fire Bat", "Uncommon", 60, C3(200, 50, 30)),
	LavaHound = pet("Lava Hound", "Rare", 120, C3(255, 80, 20)),
	FlameGolem = pet("Flame Golem", "Epic", 280, C3(255, 140, 40)),
	Hellhound = pet("Hellhound", "Legendary", 800, C3(150, 20, 20)),
	ThreeHeadedDragon = pet("Three-Headed Dragon", "Mythic", 2500, C3(220, 30, 30)),
	-- Inferno+ Egg
	EmberFox = pet("Ember Fox", "Common", 60, C3(255, 130, 50)),
	ObsidianTurtle = pet("Obsidian Turtle", "Uncommon", 120, C3(40, 30, 50)),
	PhoenixChick = pet("Phoenix Chick", "Rare", 240, C3(255, 170, 40)),
	MagmaTitan = pet("Magma Titan", "Epic", 560, C3(200, 60, 20)),
	InfernoDemon = pet("Inferno Demon", "Legendary", 1600, C3(180, 0, 30)),
	DemonKing = pet("Demon King", "Mythic", 5000, C3(90, 0, 20)),
	-- Galaxy Egg (world 5)
	Alien = pet("Alien", "Common", 120, C3(130, 255, 120)),
	UFOCat = pet("UFO Cat", "Uncommon", 250, C3(180, 180, 200)),
	StarWolf = pet("Star Wolf", "Rare", 500, C3(90, 90, 200)),
	NebulaDragon = pet("Nebula Dragon", "Epic", 1200, C3(170, 80, 255)),
	VoidTitan = pet("Void Titan", "Legendary", 3500, C3(40, 0, 80)),
	CosmicGod = pet("Cosmic God", "Mythic", 12000, C3(255, 230, 120)),
	-- Galaxy+ Egg
	MoonBunny = pet("Moon Bunny", "Common", 250, C3(220, 220, 240)),
	AstroDog = pet("Astro Dog", "Uncommon", 500, C3(255, 255, 255)),
	MeteorGolem = pet("Meteor Golem", "Rare", 1000, C3(110, 90, 80)),
	BlackHoleBeast = pet("Black Hole Beast", "Epic", 2500, C3(20, 10, 30)),
	GalaxyLeviathan = pet("Galaxy Leviathan", "Legendary", 7000, C3(60, 40, 200)),
	InfinityDragon = pet("Infinity Dragon", "Mythic", 25000, C3(255, 120, 255)),
	-- Mega Egg (Robux, hub)
	DiamondDog = pet("Diamond Dog", "Epic", 10, C3(150, 240, 255)),
	RainbowDragon = pet("Rainbow Dragon", "Legendary", 40, C3(255, 120, 200)),
	GoldenCerberus = pet("Golden Cerberus", "Mythic", 150, C3(255, 210, 50)),
}

Pets.BaseSlots = 3
Pets.ExtraSlotsPass = 3
Pets.MaxInventory = 120

-- Power of a list of equipped pet ids
function Pets.Multiplier(equippedIds)
	local total = 1
	for _, id in equippedIds do
		local p = Pets.List[id]
		if p then
			total += p.Power
		end
	end
	return total
end

return Pets

```


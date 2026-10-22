---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Services.StatService

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Services.StatService`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [StatService.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Services/StatService.luau)

```luau
-- Owns Strength, XP, Level, Coins and every multiplier. Replicates state as
-- player attributes (the client only reads them).
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage.Shared.Config
local StatsConfig = require(Config.Stats)
local Zones = require(Config.Zones)
local RebirthConfig = require(Config.Rebirth)
local PetsConfig = require(Config.Pets)
local Gym = require(Config.Gym)
local DataService = require(script.Parent.DataService)

local StatService = {}

local owned = {}
local currentWorld = {}
local currentGym = {}

function StatService.SetPass(player, passKey, value)
	owned[player] = owned[player] or {}
	owned[player][passKey] = value
	player:SetAttribute("Pass_" .. passKey, value)
	StatService.Refresh(player)
end

function StatService.OwnsPass(player, passKey)
	return owned[player] ~= nil and owned[player][passKey] == true
end

function StatService.SetLocation(player, world, gymTier)
	if currentWorld[player] == world and currentGym[player] == gymTier then
		return
	end
	currentWorld[player] = world
	currentGym[player] = gymTier
	StatService.Refresh(player)
end

function StatService.CurrentWorld(player)
	return currentWorld[player] or 1
end

-- Highest world the player may enter (Strength or the World Skip product)
function StatService.AllowedWorld(profile)
	local allowed = 1
	for i, world in Zones.List do
		if profile.Strength >= world.Required then
			allowed = i
		end
	end
	return math.max(allowed, math.min(profile.WorldUnlocked or 1, #Zones.List))
end

function StatService.GymUnlocked(player, tier)
	local profile = DataService.Get(player)
	local info = Gym.Tiers[tier]
	if not profile or not info then
		return false
	end
	if info.Pass then
		return StatService.OwnsPass(player, info.Pass)
	end
	return profile.Rebirths >= (info.Rebirths or 0)
end

function StatService.EquippedIds(profile)
	local ids = {}
	for _, entry in profile.PetInv do
		if entry.e then
			table.insert(ids, entry.p)
		end
	end
	return ids
end

function StatService.PetSlots(player)
	return PetsConfig.BaseSlots + (if StatService.OwnsPass(player, "PetSlots") then PetsConfig.ExtraSlotsPass else 0)
end

function StatService.Multipliers(player)
	local profile = DataService.Get(player)
	local world = Zones.List[currentWorld[player] or 1]
	local gymTier = currentGym[player]
	local gamepass = 1
	if StatService.OwnsPass(player, "Double") then
		gamepass *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		gamepass *= 1.5
	end
	return {
		World = world.Multiplier,
		Gym = if gymTier then Gym.Tiers[gymTier].Multiplier else 1,
		Rebirth = if profile then RebirthConfig.Multiplier(profile.Rebirths) else 1,
		Gamepass = gamepass,
		Pets = if profile then PetsConfig.Multiplier(StatService.EquippedIds(profile)) else 1,
		Boost = if profile and profile.BoostEnd > os.time() then 2 else 1,
	}
end

function StatService.Gain(player)
	local total = StatsConfig.BaseGain
	for _, value in StatService.Multipliers(player) do
		total *= value
	end
	return total
end

function StatService.CoinMultiplier(player)
	local profile = DataService.Get(player)
	local m = 1
	if StatService.OwnsPass(player, "DoubleCoins") then
		m *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		m *= 1.5
	end
	if profile and profile.CoinBoostEnd > os.time() then
		m *= 2
	end
	return m
end

function StatService.IsLucky(player)
	local profile = DataService.Get(player)
	return StatService.OwnsPass(player, "Lucky") or (profile ~= nil and profile.LuckEnd > os.time())
end

function StatService.Refresh(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local mults = StatService.Multipliers(player)
	player:SetAttribute("Strength", profile.Strength)
	player:SetAttribute("XP", profile.XP)
	player:SetAttribute("XPNeeded", StatsConfig.XpForLevel(profile.Level))
	player:SetAttribute("Level", profile.Level)
	player:SetAttribute("Rebirths", profile.Rebirths)
	player:SetAttribute("Gain", StatService.Gain(player))
	player:SetAttribute("Zone", currentWorld[player] or 1)
	player:SetAttribute("GymTier", currentGym[player] or 0)
	player:SetAttribute("AllowedZone", StatService.AllowedWorld(profile))
	player:SetAttribute("BoostEnd", profile.BoostEnd)
	player:SetAttribute("CoinBoostEnd", profile.CoinBoostEnd)
	player:SetAttribute("LuckEnd", profile.LuckEnd)
	player:SetAttribute("AutoTrainOn", profile.AutoTrainOn)
	player:SetAttribute("AutoPunchOn", profile.AutoPunchOn)
	player:SetAttribute("AutoHatchOn", profile.AutoHatchOn)
	player:SetAttribute("Coins", profile.Coins)
	player:SetAttribute("CoinMult", StatService.CoinMultiplier(player))
	player:SetAttribute("BestPunch", profile.BestPunch)
	player:SetAttribute("PetSlots", StatService.PetSlots(player))
	player:SetAttribute("PetInv", HttpService:JSONEncode(profile.PetInv))
	for name, value in mults do
		player:SetAttribute("Mult_" .. name, value)
	end

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Strength.Value = math.min(math.floor(profile.Strength), 2 ^ 53)
		stats.Coins.Value = math.min(math.floor(profile.Coins), 2 ^ 53)
		stats.Rebirths.Value = profile.Rebirths
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local speed = StatsConfig.WalkSpeed(profile.Strength)
		if StatService.OwnsPass(player, "FastWalk") then
			speed *= 1.5
		end
		if not character:GetAttribute("Frozen") then
			humanoid.WalkSpeed = speed
		end
		local target = StatsConfig.BodyScale(profile.Strength)
		if math.abs(character:GetScale() - target) > 0.02 then
			character:ScaleTo(target)
		end
	end
end

function StatService.AddStrength(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Strength += amount
	profile.TotalStrength += amount
	profile.XP += amount
	while profile.XP >= StatsConfig.XpForLevel(profile.Level) do
		profile.XP -= StatsConfig.XpForLevel(profile.Level)
		profile.Level += 1
	end
	StatService.Refresh(player)
end

function StatService.AddLevels(player, count)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	profile.Level += count
	StatService.Refresh(player)
end

function StatService.AddCoins(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Coins += amount
	StatService.Refresh(player)
end

local function onLoaded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	for _, name in {"Strength", "Coins", "Rebirths"} do
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Parent = stats
	end
	stats.Parent = player
	player:SetAttribute("Loaded", true)
	StatService.Refresh(player)
end

function StatService.Start()
	DataService.ProfileLoaded:Connect(onLoaded)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.defer(StatService.Refresh, player)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		owned[player] = nil
		currentWorld[player] = nil
		currentGym[player] = nil
	end)
end

return StatService

```


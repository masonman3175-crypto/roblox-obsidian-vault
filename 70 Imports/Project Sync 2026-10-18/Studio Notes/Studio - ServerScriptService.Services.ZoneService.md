---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Services.ZoneService

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Services.ZoneService`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [ZoneService.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Services/ZoneService.luau)

```luau
-- Where is each player: which world (by distance to world centers) and which
-- gym pad. Portals teleport (server checks Strength). Gym pads with a pass
-- lock get a buy prompt.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage.Shared.Config
local Zones = require(Config.Zones)
local Gym = require(Config.Gym)
local Monetization = require(Config.Monetization)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local ZoneService = {}

local CHECK_SECONDS = 0.25
local lastAllowed = {}
local lastTeleport = {}
local gymPads = {}

local function gameplay()
	return workspace:WaitForChild("Map"):WaitForChild("Gameplay")
end

local function worldAt(position)
	for i = #Zones.List, 2, -1 do
		local c = Zones.List[i].Center
		if (Vector3.new(position.X, 0, position.Z) - Vector3.new(c.X, 0, c.Z)).Magnitude < Zones.Radius then
			return i
		end
	end
	return 1
end

local function gymAt(position)
	for tier, pad in gymPads do
		local rel = pad.CFrame:PointToObjectSpace(position)
		if math.abs(rel.X) <= pad.Size.X / 2 + 1 and math.abs(rel.Z) <= pad.Size.Z / 2 + 1 and rel.Y < 12 and rel.Y > -2 then
			return tier
		end
	end
	return nil
end

local function hubSpawn()
	local spawnPart = workspace:FindFirstChildOfClass("SpawnLocation")
	return if spawnPart then spawnPart.CFrame + Vector3.new(0, 4, 0) else CFrame.new(0, 5, 0)
end

local function teleportTo(player, world)
	local character = player.Character
	if not character then
		return
	end
	if world == 1 then
		character:PivotTo(hubSpawn())
		return
	end
	local folder = gameplay().Worlds:FindFirstChild("World" .. world)
	local spawnPart = folder and folder:FindFirstChild("WorldSpawn")
	if spawnPart then
		character:PivotTo(spawnPart.CFrame + Vector3.new(0, 4, 0))
	end
end

local function tryTeleport(player, world)
	local profile = DataService.Get(player)
	if not profile or not Zones.List[world] then
		return
	end
	local now = os.clock()
	if lastTeleport[player] and now - lastTeleport[player] < 2 then
		return
	end
	if world > StatService.AllowedWorld(profile) then
		lastTeleport[player] = now
		Remotes.Notify:FireClient(player, "Need " .. Format.Number(Zones.List[world].Required) .. " Strength for " .. Zones.List[world].Name .. " World")
		return
	end
	lastTeleport[player] = now
	teleportTo(player, world)
	Remotes.Notify:FireClient(player, "Welcome to " .. Zones.List[world].Name .. " World! x" .. Zones.List[world].Multiplier .. " Strength here")
end

local function label(parent, text, offset)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Label"
	bb.Size = UDim2.fromOffset(300, 90)
	bb.StudsOffset = offset
	bb.MaxDistance = 140
	bb.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.RichText = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Text = text
	local s = Instance.new("UIStroke")
	s.Thickness = 3
	s.Parent = t
	t.Parent = bb
	bb.Parent = parent
	return t
end

local function promptPass(player, passKey)
	local pass = Monetization.Passes[passKey]
	if StatService.OwnsPass(player, passKey) then
		return
	end
	if pass.Id==0 then
		Remotes.Notify:FireClient(player,pass.Name.." is not listed yet")
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, pass.Id)
end

local function setupPortals()
	for _, pad in gameplay().Portals:GetChildren() do
		local world = pad:GetAttribute("World")
		local info = Zones.List[world]
		label(pad, string.format("%s WORLD\n<font size=\"22\">Need %s Strength \u{2022} x%d</font>", string.upper(info.Name), Format.Number(info.Required), info.Multiplier), Vector3.new(0, 9, 0))
		pad.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				tryTeleport(player, world)
			end
		end)
	end
	for _, folder in gameplay().Worlds:GetChildren() do
		local back = folder:FindFirstChild("ReturnPortal")
		if back then
			label(back, "BACK TO HUB", Vector3.new(0, 8, 0))
			back.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					tryTeleport(player, 1)
				end
			end)
		end
	end
end

local function setupGym()
	for _, pad in gameplay().GymPads:GetChildren() do
		local tier = pad:GetAttribute("Tier")
		local info = Gym.Tiers[tier]
		if info then
			gymPads[tier] = pad
			local need = if info.Pass then Monetization.Passes[info.Pass].Name else (if (info.Rebirths or 0) > 0 then info.Rebirths .. " Rebirths" else "FREE")
			label(pad, string.format("%s\n<font color=\"#9BFF8A\">x%d STRENGTH</font>\n<font size=\"20\">%s</font>", string.upper(info.Name), info.Multiplier, need), Vector3.new(0, 8, 0))
			if info.Pass then
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = "BuyPrompt"
				prompt.ActionText = "Unlock " .. info.Name
				prompt.ObjectText = "x" .. info.Multiplier .. " Strength"
				prompt.HoldDuration = 0
				prompt.MaxActivationDistance = 14
				prompt.RequiresLineOfSight = false
				prompt.KeyboardKeyCode = Enum.KeyCode.F
				prompt.Parent = pad
				prompt.Triggered:Connect(function(player)
					promptPass(player, info.Pass)
				end)
			end
		end
	end
end

local function check(player)
	local profile = DataService.Get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not profile or not root then
		return
	end
	local allowed = StatService.AllowedWorld(profile)
	if lastAllowed[player] and allowed > lastAllowed[player] then
		Remotes.Notify:FireClient(player, Zones.List[allowed].Name .. " World unlocked! Take the portal in the hub")
	end
	lastAllowed[player] = allowed

	local world = worldAt(root.Position)
	if world > allowed then
		teleportTo(player, 1)
		world = 1
	end
	local gymTier = if world == 1 then gymAt(root.Position) else nil
	if gymTier and not StatService.GymUnlocked(player, gymTier) then
		gymTier = nil
	end
	StatService.SetLocation(player, world, gymTier)
end

function ZoneService.Start()
	setupPortals()
	setupGym()
	Players.PlayerRemoving:Connect(function(player)
		lastAllowed[player] = nil
		lastTeleport[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(CHECK_SECONDS)
			for _, player in Players:GetPlayers() do
				check(player)
			end
		end
	end)
end

return ZoneService


```


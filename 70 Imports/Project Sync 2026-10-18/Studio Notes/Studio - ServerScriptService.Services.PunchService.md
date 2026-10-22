---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Services.PunchService

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Services.PunchService`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [PunchService.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Services/PunchService.luau)

```luau
-- Punch the dummy (ProximityPrompt + Auto Punch pass). The server decides the
-- feet, the Coins and where on the track it lands; clients only animate it.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage.Shared.Config
local PunchConfig = require(Config.Punch)
local Zones = require(Config.Zones)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local PunchService = {}

local lastPunch = {}
local dummy = nil

-- Coins one punch would give right now (also used by Coin products)
function PunchService.CoinsPerPunch(player)
	local profile = DataService.Get(player)
	if not profile then
		return 0
	end
	local feet = PunchConfig.Feet(profile.Strength)
	local world = Zones.List[StatService.AllowedWorld(profile)]
	return PunchConfig.Coins(feet, world.Multiplier, StatService.CoinMultiplier(player)), feet
end

local function punch(player, isAuto)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local now = os.clock()
	if lastPunch[player] and now - lastPunch[player] < PunchConfig.Cooldown then
		return
	end
	lastPunch[player] = now

	local coins, feet = PunchService.CoinsPerPunch(player)
	StatService.AddCoins(player, coins)
	if feet > profile.BestPunch then
		profile.BestPunch = feet
		StatService.Refresh(player)
		if not isAuto then
			Remotes.Notify:FireClient(player, "NEW BEST: " .. Format.Number(feet) .. " FT!")
		end
	end
	Remotes.PunchFx:FireAllClients(player, feet, coins, PunchConfig.TrackX(feet), isAuto)
end

local function onPrompt(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not dummy then
		return
	end
	local reach = PunchConfig.MaxRange * character:GetScale()
	if (root.Position - dummy:GetPivot().Position).Magnitude > reach then
		return
	end
	punch(player, false)
end

function PunchService.Start()
	dummy = workspace:WaitForChild("Map"):WaitForChild("Gameplay"):WaitForChild("PunchLane"):WaitForChild("Dummy")
	dummy.PrimaryPart:WaitForChild("PunchPrompt").Triggered:Connect(onPrompt)
	Players.PlayerRemoving:Connect(function(player)
		lastPunch[player] = nil
	end)

	-- Auto Punch pass: punches for you anywhere until you turn it off
	task.spawn(function()
		while true do
			task.wait(PunchConfig.AutoInterval)
			for _, player in Players:GetPlayers() do
				local profile = DataService.Get(player)
				if profile and profile.AutoPunchOn and StatService.OwnsPass(player, "AutoPunch") then
					punch(player, true)
				end
			end
		end
	end)
end

return PunchService

```


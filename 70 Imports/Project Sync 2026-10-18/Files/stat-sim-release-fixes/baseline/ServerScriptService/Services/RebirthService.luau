local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthConfig = require(ReplicatedStorage.Shared.Config.Rebirth)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local RebirthService = {}

-- reset = false is the paid Rebirth Skip (keeps Strength and level)
function RebirthService.DoRebirth(player, reset)
	local profile = DataService.Get(player)
	if not profile then
		return false
	end
	profile.Rebirths += 1
	if reset then
		profile.Strength = 0
		profile.XP = 0
		profile.Level = 1
	end
	StatService.Refresh(player)
	Remotes.Notify:FireClient(player, "Rebirth " .. profile.Rebirths .. "! Gains are now x" .. RebirthConfig.Multiplier(profile.Rebirths))
	return true
end

local function onRebirth(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local need = RebirthConfig.LevelRequired(profile.Rebirths)
	if profile.Level < need then
		Remotes.Notify:FireClient(player, "Reach Level " .. need .. " to rebirth")
		return
	end
	RebirthService.DoRebirth(player, true)
end

function RebirthService.Start()
	Remotes.Rebirth.OnServerEvent:Connect(onRebirth)
end

return RebirthService


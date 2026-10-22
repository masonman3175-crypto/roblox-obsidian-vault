-- Free Strength every second for everyone, clicks on top (rate limited),
-- extra auto clicks for Auto Click owners. Popups are drawn by the client.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatsConfig = require(ReplicatedStorage.Shared.Config.Stats)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local TrainingService = {}

local clickWindows = {}

local function isAlive(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function onTrain(player)
	local now = os.clock()
	local window = clickWindows[player]
	if not window or now - window.Start >= 1 then
		window = {Start = now, Count = 0}
		clickWindows[player] = window
	end
	window.Count += 1
	if window.Count > StatsConfig.MaxClicksPerSecond then
		return
	end
	if not DataService.Get(player) or not isAlive(player) then
		return
	end
	StatService.AddStrength(player, StatService.Gain(player) * StatsConfig.ClickValue)
end

local function toggler(field)
	return function(player, on)
		if typeof(on) ~= "boolean" then
			return
		end
		local profile = DataService.Get(player)
		if not profile then
			return
		end
		profile[field] = on
		StatService.Refresh(player)
	end
end

function TrainingService.Start()
	Remotes.Train.OnServerEvent:Connect(onTrain)
	Remotes.ToggleAutoTrain.OnServerEvent:Connect(toggler("AutoTrainOn"))
	Remotes.ToggleAutoPunch.OnServerEvent:Connect(toggler("AutoPunchOn"))
	Remotes.ToggleAutoHatch.OnServerEvent:Connect(toggler("AutoHatchOn"))
	Players.PlayerRemoving:Connect(function(player)
		clickWindows[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(StatsConfig.TickSeconds)
			for _, player in Players:GetPlayers() do
				local profile = DataService.Get(player)
				if profile and isAlive(player) then
					local clicks = StatsConfig.PassiveClicks
					if profile.AutoTrainOn and StatService.OwnsPass(player, "AutoTrain") then
						clicks += StatsConfig.AutoClicks
					end
					StatService.AddStrength(player, StatService.Gain(player) * clicks)
				end
			end
		end
	end)
end

return TrainingService

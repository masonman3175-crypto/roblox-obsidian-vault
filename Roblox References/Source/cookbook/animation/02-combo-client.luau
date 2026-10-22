--[[
	Combo input (client) with server validation
	Client sends the intent; the server checks cooldown and combo window. Never trust client timing.
	Tags: animation, combat, security
	Status: Compiled in Studio 0.743. Not run: needs a character rig / RemoteEvent and an animation asset.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
-- CLIENT (LocalScript)
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackRemote = ReplicatedStorage:WaitForChild("Attack") :: RemoteEvent

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		attackRemote:FireServer() -- no payload: the server decides the combo step
	end
end)

-- SERVER (Script) - sketch
--[[
local COMBO_WINDOW, COOLDOWN, MAX_STEP = 0.8, 0.25, 3
local state = {} -- [Player] = { step: number, last: number }
attackRemote.OnServerEvent:Connect(function(player)
	local now = os.clock()
	local s = state[player] or { step = 0, last = 0 }
	if now - s.last < COOLDOWN then return end
	s.step = (now - s.last <= COMBO_WINDOW) and (s.step % MAX_STEP) + 1 or 1
	s.last = now
	state[player] = s
	-- play animation step s.step on the character, spawn server-authoritative hitbox, apply damage
end)
]]

-- AK47Server.server.lua
-- Place this Script inside the Tool. Add a RemoteEvent named Action.

local Tool = script.Parent
local Action = Tool:WaitForChild("Action")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local DAMAGE = 28
local RANGE = 1000
local FIRE_COOLDOWN = 0.1
local lastFire = {}

local function validOwner(player)
    return player.Character and Tool:IsDescendantOf(player.Character)
end

local function fire(player, origin, direction)
    if not validOwner(player) then return end
    if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return end
    if direction.Magnitude < 1 then return end
    local now = os.clock()
    if now - (lastFire[player] or 0) < FIRE_COOLDOWN then return end
    lastFire[player] = now

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, Tool}
    local result = workspace:Raycast(origin, direction.Unit * RANGE, params)
    if not result then return end

    local model = result.Instance:FindFirstAncestorOfClass("Model")
    local humanoid = model and model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        local amount = result.Instance.Name == "Head" and DAMAGE * 2 or DAMAGE
        humanoid:TakeDamage(amount)
    end
end

Action.OnServerEvent:Connect(function(player, command, origin, direction)
    if command == "Fire" then
        fire(player, origin, direction)
    elseif command == "ReloadStart" or command == "ReloadEnd" then
        if validOwner(player) then
            Tool:SetAttribute("Reloading", command == "ReloadStart")
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastFire[player] = nil
end)

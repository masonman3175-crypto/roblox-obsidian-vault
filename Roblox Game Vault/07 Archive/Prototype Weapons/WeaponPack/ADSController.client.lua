-- ADSController.client.lua
-- Put inside each firearm Tool. Right mouse toggles aiming.
-- The weapon model should contain an Attachment named ADS inside its Handle.

local Tool = script.Parent
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local aiming = false
local equipped = false
local normalFOV = 70
local adsFOV = 52
local connection

local function setAim(value)
    aiming = value and equipped
end

Tool.Equipped:Connect(function()
    equipped = true
    normalFOV = camera.FieldOfView
    connection = RunService.RenderStepped:Connect(function(dt)
        local targetFOV = aiming and adsFOV or normalFOV
        camera.FieldOfView += (targetFOV - camera.FieldOfView) * math.min(dt * 14, 1)
    end)
end)

Tool.Unequipped:Connect(function()
    equipped = false
    aiming = false
    if connection then connection:Disconnect(); connection = nil end
    camera.FieldOfView = normalFOV
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not equipped then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        setAim(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        setAim(false)
    end
end)

-- AK47Client.client.lua
-- Place this LocalScript inside the Tool. The Tool should contain a RemoteEvent named Action.

local Tool = script.Parent
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local action = Tool:WaitForChild("Action")
local mouse
local equipped = false
local firing = false
local reloading = false
local ammo = 30
local magazineSize = 30
local fireInterval = 60 / 600 -- 600 RPM
local lastShot = 0

local function getMuzzle()
    return Tool:FindFirstChild("Muzzle", true) or Tool:FindFirstChild("Handle")
end

local function tracer(origin, destination)
    local distance = (destination - origin).Magnitude
    local beam = Instance.new("Part")
    beam.Name = "Tracer"
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(255, 210, 90)
    beam.Size = Vector3.new(0.045, 0.045, distance)
    beam.CFrame = CFrame.lookAt((origin + destination) / 2, destination)
    beam.Parent = workspace
    Debris:AddItem(beam, 0.045)
end

local function ejectCasing()
    local muzzle = getMuzzle()
    if not muzzle then return end
    local casing = Instance.new("Part")
    casing.Name = "EjectedCasing"
    casing.Shape = Enum.PartType.Cylinder
    casing.Size = Vector3.new(0.08, 0.16, 0.08)
    casing.Material = Enum.Material.Metal
    casing.Color = Color3.fromRGB(190, 125, 45)
    casing.CFrame = muzzle.CFrame * CFrame.new(0, 0.18, 0)
    casing.CanCollide = true
    casing.Parent = workspace
    casing.AssemblyLinearVelocity = muzzle.CFrame.RightVector * 14 + Vector3.new(0, 7, 0)
    casing.AssemblyAngularVelocity = Vector3.new(8, 12, 4)
    Debris:AddItem(casing, 4)
end

local function fire()
    if not equipped or reloading or ammo <= 0 then return end
    if os.clock() - lastShot < fireInterval then return end
    lastShot = os.clock()
    ammo -= 1
    local muzzle = getMuzzle()
    local origin = muzzle and muzzle.Position or workspace.CurrentCamera.CFrame.Position
    local direction = (mouse.Hit.Position - origin).Unit * 1000
    action:FireServer("Fire", origin, direction)
    tracer(origin, origin + direction)
    ejectCasing()
end

local function reload()
    if reloading or ammo == magazineSize then return end
    reloading = true
    action:FireServer("ReloadStart")
    task.wait(1.65)
    ammo = magazineSize
    action:FireServer("ReloadEnd")
    reloading = false
end

Tool.Equipped:Connect(function(m)
    mouse = m
    equipped = true
    mouse.Button1Down:Connect(function()
        firing = true
        while firing do
            fire()
            RunService.RenderStepped:Wait()
        end
    end)
    mouse.Button1Up:Connect(function() firing = false end)
    mouse.KeyDown:Connect(function(key)
        if key:lower() == "r" then reload() end
    end)
end)

Tool.Unequipped:Connect(function()
    equipped = false
    firing = false
end)

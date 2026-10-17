local id = TEST_ID
local p = game.Players.LocalPlayer
local bridge = assert(p.PlayerScripts:WaitForChild('ReferenceFPSControl', 20))
bridge:Invoke('TestMode', true)
local config = require(game.ReplicatedStorage.ReferenceWeapons.WeaponConfig).Guns[id]
local tool = p.Backpack:FindFirstChild(config.Name) or p.Character:FindFirstChild(config.Name)
assert(tool)
p.Character.Humanoid:EquipTool(tool)
task.wait(.6)
local before = bridge:Invoke('State')
assert(before.WeaponId == id and before.HasArms)
assert(bridge:Invoke('Fire'), 'Fire rejected')
local peak, yaw = 0, 0
for i = 1, 10 do
    task.wait(.025)
    local state = bridge:Invoke('State')
    peak = math.max(peak, state.RecoilPitchDegrees or 0)
    yaw = math.max(yaw, math.abs(state.RecoilYawDegrees or 0))
end
assert(peak > .30, 'No measurable camera recoil')
assert(yaw > .01, 'No horizontal recoil')
task.wait(1.0)
local rest = bridge:Invoke('State')
assert(rest.Ammo == before.Ammo - 1, 'One shot did not use one round')
assert(math.abs(rest.RecoilPitchDegrees) < .05, 'Recoil failed to recover')
local vm = p.PlayerGui.ReferenceWeaponHUD.ViewmodelViewport.WorldModel.ReferenceFPS_Active
local camera = workspace.CurrentCamera
local hip = camera.CFrame:ToObjectSpace(vm.PrimaryPart.CFrame)
if config.Pistol then
    assert(hip.Position.Z < -1.4, 'Pistol still too close to the camera')
    assert(math.abs(hip.LookVector.X) > .25, 'Pistol still shows only a flat rear face')
    assert(vm:FindFirstChild('SlideRearPlate'), 'Missing slide rear cap')
end
bridge:Invoke('Aim', true)
task.wait(.85)
local point = camera:WorldToViewportPoint(vm.PrimaryPart.Aim.WorldPosition)
local error = (Vector2.new(point.X, point.Y) - camera.ViewportSize / 2).Magnitude
assert(error < 5, 'Aim is off center by ' .. error .. 'px')
if id == 'W2' then
    local dot = assert(vm:FindFirstChild('ReflexDot'))
    local d = camera:WorldToViewportPoint(dot.Position)
    assert((Vector2.new(d.X, d.Y) - camera.ViewportSize / 2).Magnitude < 5, 'Optic dot is not centered')
    for _, ob in ipairs(vm:GetDescendants()) do if ob:IsA('BasePart') and ob ~= dot then ob.CanQuery = true end end
    local delta = dot.Position - camera.CFrame.Position
    local hit = vm.Parent:Raycast(camera.CFrame.Position, delta.Unit * (delta.Magnitude - .025))
    for _, ob in ipairs(vm:GetDescendants()) do if ob:IsA('BasePart') then ob.CanQuery = false end end
    assert(not hit, 'ADS aperture obstructed by ' .. (hit and hit.Instance.Name or '?'))
end
bridge:Invoke('Aim', false)
assert(bridge:Invoke('Reload'))
task.wait(config.ReloadTime + .2)
assert(bridge:Invoke('State').Ammo == config.MagazineSize)
return string.format('MODIFIED PASS %s ADS=%.2fpx recoilPitch=%.2fdeg recoilYaw=%.2fdeg recovery=PASS reload=PASS arms=PASS', id, error, peak, yaw)

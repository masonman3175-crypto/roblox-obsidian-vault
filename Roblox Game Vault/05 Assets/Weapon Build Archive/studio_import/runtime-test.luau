local id = TEST_WEAPON_ID
local p = game.Players.LocalPlayer
local bridge = assert(p.PlayerScripts:WaitForChild('ReferenceFPSControl', 30), 'Live controller did not start')
local config = require(game.ReplicatedStorage.ReferenceWeapons.WeaponConfig).Guns[id]
bridge:Invoke('TestMode', true)
local deadline = os.clock() + 30
while (not p.Character or not p.Character:FindFirstChildOfClass('Humanoid')) and os.clock() < deadline do task.wait(.1) end
assert(p.Character and p.Character:FindFirstChildOfClass('Humanoid'), 'Character did not load')
local tool = p.Backpack:FindFirstChild(config.Name) or p.Character:FindFirstChild(config.Name)
assert(tool, 'Missing tool ' .. id)
p.Character.Humanoid:EquipTool(tool)
task.wait(.65)
local before = bridge:Invoke('State')
assert(before.WeaponId == id and before.HasArms, 'Wrong weapon or missing arms')
if before.Ammo < config.MagazineSize or before.Reloading then
    if not before.Reloading then bridge:Invoke('Reload') end
    task.wait(config.ReloadTime + .3)
    before = bridge:Invoke('State')
end
assert(before.FirstPerson == 'LockFirstPerson', 'First person is not locked')
assert(bridge:Invoke('Fire'), 'Fire rejected')
local fired = bridge:Invoke('State')
assert(fired.Ammo == before.Ammo - 1, 'Shot did not consume exactly one round')
assert(bridge:Invoke('Reload'), 'Reload rejected')
local m = p.PlayerGui.ReferenceWeaponHUD.ViewmodelViewport.WorldModel:FindFirstChild('ReferenceFPS_Active')
local leftBefore = workspace.CurrentCamera.CFrame:PointToObjectSpace(m.LeftHand.Position)
task.wait(config.ReloadTime * .36)
local leftAfter = workspace.CurrentCamera.CFrame:PointToObjectSpace(m.LeftHand.Position)
assert((leftAfter - leftBefore).Magnitude > .05, 'Left arm did not animate during reload')
assert(not bridge:Invoke('Fire'), 'Fire allowed during reload')
task.wait(config.ReloadTime * .70 + .15)
local loaded = bridge:Invoke('State')
assert(not loaded.Reloading and loaded.Ammo == config.MagazineSize, 'Reload did not finish')
assert(loaded.Reserve == fired.Reserve - (config.MagazineSize - fired.Ammo), 'Reserve bookkeeping failed')
bridge:Invoke('Aim', true)
task.wait(.90)
local aimed = bridge:Invoke('State')
assert(aimed.Aiming, 'ADS did not activate')
local cam = workspace.CurrentCamera
local point = cam:WorldToViewportPoint(m.PrimaryPart.Aim.WorldPosition)
local errorPixels = (Vector2.new(point.X, point.Y) - cam.ViewportSize / 2).Magnitude
assert(errorPixels < 10, 'Iron sight off center by ' .. errorPixels .. ' pixels')
bridge:Invoke('Aim', false)
assert(bridge:Invoke('Inspect'), 'Inspect rejected')
task.wait(.35)
assert(bridge:Invoke('State').Inspecting, 'Inspect did not activate')
return string.format('MODIFIED PASS %s meshes=%d arms=animated fire=PASS reload=PASS reserve=PASS ADS=%.2fpx inspect=PASS firstPerson=PASS', id, loaded.Meshes, errorPixels)

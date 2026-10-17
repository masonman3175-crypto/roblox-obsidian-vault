local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local source = assert(workspace:FindFirstChild('ReferenceWeapons_Studio'), 'Import FBX first')
local backup = assert(SS:FindFirstChild('WeaponMigrationBackup_20261016'), 'Back up old tools first')
assert(not RS:FindFirstChild('ReferenceWeapons'), 'Already installed')
local package = Instance.new('Folder')
package.Name = 'ReferenceWeapons'
local vms = Instance.new('Folder')
vms.Name, vms.Parent = 'Viewmodels', package
-- Modules are inserted by the installer runner before this script is called.
local configModule = assert(SS:FindFirstChild('ReferenceWeaponConfigStaging'))
configModule.Name, configModule.Parent = 'WeaponConfig', package
local controller = assert(SS:FindFirstChild('ReferenceControllerStaging'))
controller.Name, controller.Parent = 'Controller', package
local config = require(configModule)
local colors = {
    BluedSteel = Color3.fromRGB(40, 48, 58), SatinMachinedSteel = Color3.fromRGB(104, 116, 126),
    BrushedSilver = Color3.fromRGB(191, 204, 214), CarbonBlack = Color3.fromRGB(23, 27, 32),
    BoreDark = Color3.fromRGB(6, 7, 9), HoneyWalnut = Color3.fromRGB(211, 133, 48),
    DarkWalnut = Color3.fromRGB(119, 61, 28), GripRubber = Color3.fromRGB(36, 41, 46),
    LimeGrip = Color3.fromRGB(75, 207, 23), Brass = Color3.fromRGB(195, 147, 56),
    ShellRed = Color3.fromRGB(190, 36, 18), SightWhite = Color3.fromRGB(207, 242, 216),
}
local parts = source:GetDescendants()
local first, second = source:FindFirstChild('W1__ORIGIN', true), source:FindFirstChild('W2__ORIGIN', true)
assert(first and second, 'Missing scale/origin markers')
local importedScale = (second.Position - first.Position).Magnitude / 15
assert(importedScale > 0, 'Bad import scale')
local orient = CFrame.Angles(0, math.pi / 2, 0)
local report = {}
for _, id in ipairs(config.Order) do
    local gun = config.Guns[id]
    local origin = assert(source:FindFirstChild(id .. '__ORIGIN', true)).Position
    local model = Instance.new('Model')
    model.Name, model.Parent = id, vms
    model:SetAttribute('DisplayName', gun.Name)
    model:SetAttribute('Source', 'Blender reference mesh FBX')
    local root = Instance.new('Part')
    root.Name, root.Size, root.Transparency = 'Root', Vector3.new(.05, .05, .05), 1
    root.Anchored, root.CanCollide, root.CanTouch, root.CanQuery = true, false, false, false
    root.CFrame, root.Parent = CFrame.identity, model
    model.PrimaryPart = root
    local anchor = Vector3.new(gun.SourceGrip.Y, gun.SourceGrip.Z, gun.SourceGrip.X) * gun.Scale
    local count = 0
    for _, p in ipairs(parts) do
        if p:IsA('MeshPart') and p.Name:sub(1, #id + 2) == id .. '__' and not p.Name:find('ORIGIN', 1, true) then
            local clone = p:Clone()
            local component, material = p.Name:match('^W%d+__(%w+)__(%w+)__')
            assert(component and material, 'Unrecognized mesh name ' .. p.Name)
            clone.Size = p.Size * (gun.Scale / importedScale)
            clone.CFrame = CFrame.new(orient:VectorToWorldSpace((p.Position - origin) * (gun.Scale / importedScale)) - anchor) * orient * p.CFrame.Rotation
            clone.Anchored, clone.CanCollide, clone.CanTouch, clone.CanQuery = true, false, false, false
            clone.CastShadow = false
            clone.Color = colors[material] or Color3.fromRGB(65, 70, 75)
            local isMetal = material:find('Steel') or material:find('Silver') or material == 'Brass'
            clone.Material = isMetal and Enum.Material.Metal or Enum.Material.SmoothPlastic
            clone.Reflectance = 0
            for _, child in ipairs(clone:GetDescendants()) do
                if child:IsA('BaseScript') or child:IsA('SurfaceAppearance') then child:Destroy() end
            end
            clone.TextureID = ''
            clone:SetAttribute('Component', component)
            clone:SetAttribute('RestCFrame', clone.CFrame)
            clone.Parent = model
            count += 1
        end
    end
    assert(count >= 10, 'Incomplete mesh import for ' .. id)
    local muzzle = Instance.new('Attachment')
    muzzle.Name, muzzle.Position, muzzle.Parent = 'Muzzle', gun.Muzzle, root
    local aim = Instance.new('Attachment')
    aim.Name, aim.Position, aim.Parent = 'Aim', gun.Aim, root
    model:SetAttribute('ImportedMeshes', count)
    table.insert(report, gun.Name .. '=' .. count .. ' meshes')
end
package.Parent = RS
-- Replace only the old FPS prototypes owned by this task, not unrelated tools.
for _, t in ipairs(game.StarterPack:GetChildren()) do if t:GetAttribute('FPSPrototype') then t:Destroy() end end
for _, id in ipairs(config.Order) do
    local gun, template = config.Guns[id], vms[id]
    local tool = Instance.new('Tool')
    tool.Name, tool.CanBeDropped, tool.RequiresHandle = gun.Name, false, true
    tool.ToolTip = 'LMB fire | RMB aim | R reload | F inspect'
    tool:SetAttribute('ReferenceWeaponId', id)
    local handle = Instance.new('Part')
    handle.Name, handle.Size, handle.Transparency = 'Handle', Vector3.new(.15, .30, .15), 1
    handle.CanCollide, handle.CanTouch, handle.CanQuery, handle.Massless = false, false, false, true
    handle.CFrame, handle.Parent = CFrame.identity, tool
    local world = template:Clone()
    world.Name, world.Parent = 'WorldModel', tool
    for _, p in ipairs(world:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.Massless = false, false, false, false, true
            local weld = Instance.new('WeldConstraint')
            weld.Part0, weld.Part1, weld.Parent = handle, p, handle
        end
    end
    tool.Grip = CFrame.new(0, -.15, -.10) * CFrame.Angles(-math.pi / 2, 0, 0)
    tool.Parent = game.StarterPack
end
local old = game.StarterPlayer.StarterPlayerScripts:FindFirstChild('FPSWeaponController')
if old then old:Destroy() end
local oldModels = RS:FindFirstChild('Viewmodels')
if oldModels then oldModels:Destroy() end
local boot = Instance.new('LocalScript')
boot.Name = 'ReferenceFPS'
boot.Source = "require(game:GetService('ReplicatedStorage'):WaitForChild('ReferenceWeapons'):WaitForChild('Controller')).Start()"
boot.Parent = game.StarterPlayer.StarterPlayerScripts
game.StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
game.StarterPlayer.CameraMinZoomDistance, game.StarterPlayer.CameraMaxZoomDistance = .5, .5
source.Name, source.Parent = 'ImportedReferenceWeaponPack', SS
game:GetService('ChangeHistoryService'):SetWaypoint('Reference weapons and first person installed')
return 'INSTALLED scale=' .. importedScale .. ' | ' .. table.concat(report, ', ') .. ' | LockFirstPerson | old prototypes removed'

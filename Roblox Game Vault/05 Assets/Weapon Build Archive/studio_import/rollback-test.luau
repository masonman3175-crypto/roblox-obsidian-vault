local realGame = game
local fixtures = Instance.new('Folder')
fixtures.Name = 'IsolatedRollbackFixture'
local ss, rs, pack, scripts = Instance.new('Folder'), Instance.new('Folder'), Instance.new('Folder'), Instance.new('Folder')
ss.Name, rs.Name, pack.Name, scripts.Name = 'ServerStorage', 'ReplicatedStorage', 'StarterPack', 'StarterPlayerScripts'
ss.Parent, rs.Parent, pack.Parent, scripts.Parent = fixtures, fixtures, fixtures, fixtures
realGame.ServerStorage.WeaponMigrationBackup_20261016:Clone().Parent = ss
realGame.ReplicatedStorage.ReferenceWeapons:Clone().Parent = rs
for _, t in ipairs(realGame.StarterPack:GetChildren()) do if t:GetAttribute('ReferenceWeaponId') then t:Clone().Parent = pack end end
realGame.StarterPlayer.StarterPlayerScripts.ReferenceFPS:Clone().Parent = scripts
local mock = {
    StarterPack = pack,
    StarterPlayer = {StarterPlayerScripts = scripts, CameraMode = Enum.CameraMode.LockFirstPerson, CameraMinZoomDistance = .5, CameraMaxZoomDistance = .5},
}
function mock:GetService(name) return name == 'ServerStorage' and ss or (name == 'ReplicatedStorage' and rs or error(name)) end
local fn = assert(loadstring(ROLLBACK_SOURCE))
setfenv(fn, setmetatable({game = mock}, {__index = getfenv()}))
local result = fn()
assert(#pack:GetChildren() == 5 and scripts:FindFirstChild('FPSWeaponController') and rs:FindFirstChild('Viewmodels'))
assert(mock.StarterPlayer.CameraMode == Enum.CameraMode.Classic)
assert(scripts.FPSWeaponController.Source == ss.WeaponMigrationBackup_20261016.FPSWeaponController.Source)
assert(realGame.ReplicatedStorage:FindFirstChild('ReferenceWeapons') and realGame.StarterPlayer.CameraMode == Enum.CameraMode.LockFirstPerson)
fixtures:Destroy()
return result .. ' | LIVE UNCHANGED tools=5 CameraMode=LockFirstPerson'

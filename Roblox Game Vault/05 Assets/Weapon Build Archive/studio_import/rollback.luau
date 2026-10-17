-- Run only in Edit mode. Restores the earlier camera, five tools and controller.
local SS, RS = game:GetService('ServerStorage'), game:GetService('ReplicatedStorage')
local backup = assert(SS:FindFirstChild('WeaponMigrationBackup_20261016'))
for _, t in ipairs(game.StarterPack:GetChildren()) do if t:GetAttribute('ReferenceWeaponId') then t:Destroy() end end
local scripts = game.StarterPlayer.StarterPlayerScripts
local boot = scripts:FindFirstChild('ReferenceFPS'); if boot then boot:Destroy() end
local package = RS:FindFirstChild('ReferenceWeapons'); if package then package:Destroy() end
for _, t in ipairs(backup.StarterPack:GetChildren()) do t:Clone().Parent = game.StarterPack end
local old = scripts:FindFirstChild('FPSWeaponController'); if old then old:Destroy() end
backup.FPSWeaponController:Clone().Parent = scripts
local models = RS:FindFirstChild('Viewmodels'); if models then models:Destroy() end
backup.Viewmodels:Clone().Parent = RS
game.StarterPlayer.CameraMode = Enum.CameraMode[backup:GetAttribute('CameraMode')]
game.StarterPlayer.CameraMinZoomDistance = backup:GetAttribute('CameraMinZoomDistance')
game.StarterPlayer.CameraMaxZoomDistance = backup:GetAttribute('CameraMaxZoomDistance')
return 'ROLLBACK PASS tools=5 CameraMode=' .. game.StarterPlayer.CameraMode.Name

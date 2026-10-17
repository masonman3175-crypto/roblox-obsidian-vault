-- Edit-mode rollback for this movement/boundary pass only.
local RS=game:GetService('ReplicatedStorage')
local SSS=game:GetService('ServerScriptService')
local SS=game:GetService('ServerStorage')
local WS=game:GetService('Workspace')
local backup=assert(SS:FindFirstChild('MovementBoundaryBackup_20261016'),'Movement baseline missing')
local pkg=RS.GameplayPresentation
pkg.MovementConfig.Source=backup.MovementConfig.Source
pkg.MovementClient.Source=backup.MovementClient.Source
SSS.GameplayMovement.Service.Source=backup.MovementServer.Source
local boundary=WS.Map:FindFirstChild('PerimeterBoundary')
if boundary then boundary:Destroy()end
if backup:FindFirstChild('PerimeterBoundary')then backup.PerimeterBoundary:Clone().Parent=WS.Map end
for _,p in ipairs(pkg.MinimapWorld:GetChildren())do if p.Name:match('^Boundary_')then p:Destroy()end end
return 'ROLLBACK: PASS'

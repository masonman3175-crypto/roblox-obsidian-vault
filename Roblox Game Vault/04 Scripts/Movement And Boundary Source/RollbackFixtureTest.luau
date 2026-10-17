local root=Instance.new('Folder');root.Name='MovementBoundaryRollbackFixture'
local services={}
for _,name in ipairs({'ReplicatedStorage','ServerScriptService','ServerStorage','Workspace'})do local f=Instance.new('Folder');f.Name=name;f.Parent=root;services[name]=f end
game.ReplicatedStorage.GameplayPresentation:Clone().Parent=services.ReplicatedStorage
game.ServerScriptService.GameplayMovement:Clone().Parent=services.ServerScriptService
game.ServerStorage.MovementBoundaryBackup_20261016:Clone().Parent=services.ServerStorage
local map=Instance.new('Folder');map.Name='Map';map.Parent=services.Workspace
workspace.Map.PerimeterBoundary:Clone().Parent=map
local spawn=Instance.new('SpawnLocation');spawn.Name='SpawnSentinel';spawn.CFrame=CFrame.new(-190,.3,0);spawn.Parent=map;local original=spawn.CFrame
local fn=assert(loadstring([====[-- Edit-mode rollback for this movement/boundary pass only.
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
]====]))
setfenv(fn,setmetatable({game={GetService=function(_,name)return services[name]end}},{__index=getfenv()}))
local result=fn()
local pkg=services.ReplicatedStorage.GameplayPresentation
local backup=services.ServerStorage.MovementBoundaryBackup_20261016
assert(pkg.MovementConfig.Source==backup.MovementConfig.Source)
assert(pkg.MovementClient.Source==backup.MovementClient.Source)
assert(services.ServerScriptService.GameplayMovement.Service.Source==backup.MovementServer.Source)
assert(not map:FindFirstChild('PerimeterBoundary'))
for _,p in ipairs(pkg.MinimapWorld:GetChildren())do assert(not p.Name:match('^Boundary_'))end
assert(spawn.CFrame==original)
assert(game.ReplicatedStorage.GameplayPresentation.MovementConfig.Source:find('SprintDrain=5',1,true))
assert(workspace.Map.PerimeterBoundary~=nil)
root:Destroy()
return {Result=result,FixtureOnly=true,LiveModifiedRetained=true,SpawnsUntouched=true,ExitStatus=0}

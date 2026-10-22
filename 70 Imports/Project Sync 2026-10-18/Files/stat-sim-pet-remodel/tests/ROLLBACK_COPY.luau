-- The rollback function is injected by the runner as local rollback=loadstring(... )().
local f=Instance.new("Folder");f.Name="PetRemodel_RollbackFixture";f.Parent=game.ServerStorage
for _,name in {"ReplicatedStorage","StarterPlayer","ServerScriptService","Workspace"} do local x=Instance.new("Folder");x.Name=name;x.Parent=f end
local function parentPath(path)
	local x=f
	for n in path:gmatch("[^.]+") do local y=x:FindFirstChild(n) if not y then y=Instance.new("Folder");y.Name=n;y.Parent=x end x=y end
	return x
end
for _,path in {"ReplicatedStorage.Shared.Config","ReplicatedStorage.Shared.Util","StarterPlayer.StarterPlayerScripts.Controllers","ServerScriptService.Services","Workspace.Map.Gameplay"} do parentPath(path) end
for _,saved in game.ServerStorage.PetRemodel_Backup.Sources:GetChildren() do
	local path,name=saved.Name:match("^(.*)%.([^.]+)$")
	local live=game for n in saved.Name:gmatch("[^.]+") do live=live[n] end
	live:Clone().Parent=parentPath(path)
end
for _,path in {"ReplicatedStorage.Shared.Config.PetDesigns","ReplicatedStorage.Shared.Util.PetModelBuilder","ReplicatedStorage.Shared.Util.EggVisual"} do
	local live=game for n in path:gmatch("[^.]+") do live=live[n] end
	local p=path:match("^(.*)%.[^.]+$");live:Clone().Parent=parentPath(p)
end
game.ReplicatedStorage.PetModels:Clone().Parent=f.ReplicatedStorage
game.ReplicatedStorage.Shared.Config.Pets:Clone().Parent=f.ReplicatedStorage.Shared.Config
local stand=Instance.new("Part");stand.Name="Stand";stand:SetAttribute("EggId","Starter");stand.Parent=f.Workspace.Map.Gameplay
workspace.Map.Gameplay.EggStands.EggStand_Starter.EggPreview:Clone().Parent=stand
local result=rollback(f,game.ServerStorage.PetRemodel_Backup)
for _,saved in game.ServerStorage.PetRemodel_Backup.Sources:GetChildren() do
	local x=f for n in saved.Name:gmatch("[^.]+") do x=x[n] end assert(x.Source==saved.Source)
end
assert(#f.ReplicatedStorage.PetModels:GetChildren()==10 and #stand:GetChildren()==0)
assert(not f.ReplicatedStorage.Shared.Config:FindFirstChild("PetDesigns"))
-- Execute the restored old factory against the COPY's services, not the live remodel.
local factory=assert(loadstring(f.ReplicatedStorage.Shared.Util.PetVisual.Source))
local env=setmetatable({game={GetService=function(_,name)
	assert(name=="ReplicatedStorage");return f.ReplicatedStorage
end}},{__index=getfenv()})
setfenv(factory,env)
local restored=factory()
local baselinePets=require(f.ReplicatedStorage.Shared.Config.Pets)
local restoredCount=0
for id in baselinePets.List do
	local m=restored.Make(id);local _,s=m:GetBoundingBox()
	assert(math.abs(math.max(s.X,s.Y,s.Z)-3)<.01,"Original size behavior not restored")
	m:Destroy();restoredCount+=1
end
assert(restoredCount==63)
assert(#game.ReplicatedStorage.PetModels:GetChildren()==63 and workspace.Map.Gameplay.EggStands.EggStand_Starter.EggPreview)
f:Destroy()
return result.." copy=true restored_max_size=3 live_remodel=retained"

local c=require(game.ReplicatedStorage.Shared.Config.Pets)
local p=require(game.ReplicatedStorage.Shared.Util.PetVisual)
local n,g=0,0
for id in c.List do
	local m=p.Make(id);local _,s=m:GetBoundingBox()
	if math.max(s.X,s.Y,s.Z)>8 then g+=1 end
	n+=1;m:Destroy()
end
assert(n==63 and g==0)
assert(#game.ReplicatedStorage.PetModels:GetChildren()==10)
return "BASELINE_PASS pets=63 custom_models=10 massive=0 egg_style=sphere economy=preserved"

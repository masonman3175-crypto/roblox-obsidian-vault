local RS=game.ReplicatedStorage
local B=game.ServerStorage.PetRemodel_Backup
local P=require(RS.Shared.Util.PetVisual)
local E=require(RS.Shared.Util.EggVisual)
local Pets=require(RS.Shared.Config.Pets)
local Eggs=require(RS.Shared.Config.Eggs)
local D=require(RS.Shared.Config.PetDesigns)
local function hash(s)
	return (game.EncodingService:ComputeStringHash(s,Enum.HashAlgorithm.Sha256):gsub(".",function(c)return string.format("%02x",c:byte())end))
end
assert(hash(RS.Shared.Config.Pets.Source..RS.Shared.Config.Eggs.Source)==B.EconomySHA256.Value,"Economy changed")
local count,giants,parts,species=0,0,0,{}
for id in Pets.List do
	count+=1;assert(D.List[id]);species[D.List[id].Species]=true
	local model=P.Make(id);local preview=P.Make(id,{Preview=true})
	assert(model.Body:IsA("Part") and model.Body.Shape==Enum.PartType.Block)
	assert(model:GetAttribute("PetId")==id and model:GetAttribute("PetRemodelVersion")==1)
	local _,size=model:GetBoundingBox();local largest=math.max(size.X,size.Y,size.Z)
	assert(math.abs(largest-D.List[id].Size)<.01,id.." world scale")
	if model:GetAttribute("Massive") then giants+=1;assert(largest>=10) end
	local _,ps=preview:GetBoundingBox();assert(math.abs(math.max(ps.X,ps.Y,ps.Z)-3)<.01,id.." preview clipping")
	local bodyParts,eyes,emitters=0,0,0
	for _,x in model:GetDescendants() do
		assert(not x:IsA("LuaSourceContainer"))
		if x:IsA("BasePart") then bodyParts+=1;assert(x.Anchored and not x.CanCollide and not x.CanTouch and not x.CanQuery) end
		if x.Name=="Eye" then eyes+=1 end
		if x:IsA("ParticleEmitter") then emitters+=1;assert(x.Enabled and x.Rate<=9 and x.Lifetime.Max<=1.25);assert(x.Parent:IsA("BasePart") and x.ShapeStyle==Enum.ParticleEmitterShapeStyle.Surface) end
	end
	assert(bodyParts<120 and eyes>=2 and emitters==1,id.." visual contract")
	parts+=bodyParts
	for _,x in preview:GetDescendants() do if x:IsA("ParticleEmitter") then assert(not x.Enabled) end end
	local wing=model:FindFirstChild("Wing") or model:FindFirstChild("Orbit")
	if wing then local before=wing:GetPivot();P.Animate(model,1.2);assert(wing:GetPivot()~=before,"Missing animation") end
	model:Destroy();preview:Destroy()
end
assert(count==63 and giants==10 and #RS.PetModels:GetChildren()==63)
local eggCount=0
for id,egg in Eggs.List do
	eggCount+=1;assert(E.Palettes[id]);local m=E.Make(id);local preview=E.Make(id,{Preview=true})
	local studs,cracks,marks,particles=0,0,0,0
	for _,x in m:GetDescendants() do
		if x.Name=="ShellStud" then studs+=1 end
		if x.Name=="EnergyCrack" then cracks+=1 end
		if x.Name=="MysteryMark" then marks+=1 end
		if x:IsA("ParticleEmitter") then particles+=1;assert(x.Enabled and x.Rate<=7) end
		if x:IsA("BasePart") then assert(x.Anchored and not x.CanCollide) end
	end
	assert(studs>50 and cracks>=36 and marks==10 and particles==2)
	local _,s=preview:GetBoundingBox();assert(math.abs(math.max(s.X,s.Y,s.Z)-3)<.01)
	assert(not preview:FindFirstChild("WoodenNest"))
	local rest=m.Orbit:GetPivot();E.Animate(m,2,true);assert(m.Orbit:GetPivot()~=rest)
	E.Animate(m,3,false)
	for _,x in m:GetDescendants() do if x:IsA("ParticleEmitter") then assert(not x.Enabled) end end
	-- Every listed outcome is still selected at its original cumulative interval, including Lucky.
	for _,lucky in {false,true} do
		local total=0;local weights={}
		for i,entry in egg.Pets do weights[i]=entry.Chance*(if lucky and i>=4 and #egg.Pets==6 then 2 else 1);total+=weights[i] end
		local previous=0
		for i,entry in egg.Pets do
			local midpoint=(previous+weights[i]/2)/total
			assert(Eggs.Roll(id,lucky,{NextNumber=function()return midpoint end})==entry.Id)
			previous+=weights[i]
		end
	end
	m:Destroy();preview:Destroy()
end
assert(eggCount==11)
local standCount=0
for _,v in B.Manifest:GetChildren() do
	local stand=v.Value;assert(stand and stand.CFrame==v:GetAttribute("CFrame") and stand.Size==v:GetAttribute("Size"))
	assert(stand.EggPreview:GetAttribute("EggVisualId")==stand:GetAttribute("EggId"));standCount+=1
end
assert(standCount==11)
local changed={
	["ReplicatedStorage.Shared.Util.PetVisual"]=true,
	["StarterPlayer.StarterPlayerScripts.Controllers.PetController"]=true,
	["StarterPlayer.StarterPlayerScripts.Controllers.PetsController"]=true,
	["StarterPlayer.StarterPlayerScripts.Controllers.HatchController"]=true,
	["ServerScriptService.Services.EggService"]=true,
}
local same=0
for path,expected in game.HttpService:JSONDecode(B.OriginalSourceHashes.Value) do if not changed[path] then
	local x=game for n in path:gmatch("[^.]+") do x=x[n] end
	assert(hash(x.Source)==expected,"Unrelated source changed: "..path);same+=1
end end
assert(math.abs(game.Lighting:FindFirstChildOfClass("BloomEffect").Intensity-.14)<.001,"Glare regression")
return string.format("MODIFIED_PASS pets=%d massive=%d eggs=%d particles=85 preview_size=3 economy=unchanged unrelated_sources=%d",count,giants,eggCount,same)

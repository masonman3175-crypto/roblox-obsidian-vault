-- Reversible EDIT-only restoration. Optional root is an isolated fixture with service-named folders.
local function rollback(root, backup)
	local function resolve(path)
		local x=root
		for n in path:gmatch("[^.]+") do x=x:FindFirstChild(n);assert(x,"Missing "..path) end
		return x
	end
	for _,saved in backup.Sources:GetChildren() do
		local parentPath,name=saved.Name:match("^(.*)%.([^.]+)$")
		local parent=resolve(parentPath)
		local old=parent:FindFirstChild(name);if old then old:Destroy() end
		local restored=saved:Clone();restored.Name=name;restored:SetAttribute("OriginalSHA256",nil);restored.Parent=parent
	end
	for _,path in {"ReplicatedStorage.Shared.Config.PetDesigns","ReplicatedStorage.Shared.Util.PetModelBuilder","ReplicatedStorage.Shared.Util.EggVisual"} do
		local parentPath,name=path:match("^(.*)%.([^.]+)$")
		local x=resolve(parentPath):FindFirstChild(name);if x then x:Destroy() end
	end
	local rs=resolve("ReplicatedStorage")
	if rs:FindFirstChild("PetModels") then rs.PetModels:Destroy() end
	if backup:GetAttribute("HadPetModels") then backup.PetModels:Clone().Parent=rs end
	for _,stand in resolve("Workspace.Map.Gameplay"):GetDescendants() do
		if stand:IsA("BasePart") and stand:GetAttribute("EggId") then
			for _,x in stand:GetChildren() do if x.Name=="EggPreview" or x.Name=="Egg" then x:Destroy() end end
		end
	end
	return "ROLLBACK_PASS sources=5 original_models=10 egg_previews=0 restored=original_visuals"
end
return rollback

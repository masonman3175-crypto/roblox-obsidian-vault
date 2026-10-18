-- Insert creator-store model119702734710201 with Roblox_Studio.insert_asset into ServerStorage first.
-- Observed source name: Classic Bed Bedroom House Furniture Vibe. Never insert store characters/weapons.
local SS=game.ServerStorage
local bed=SS:FindFirstChild("SurvivalBedAsset")or SS:FindFirstChild("Classic Bed Bedroom House Furniture Vibe")
assert(bed,"Insert the vetted bed through Roblox_Studio.insert_asset first")
local removed={}
for _,v in bed:GetDescendants()do if v:IsA("LuaSourceContainer")then table.insert(removed,v.Name);v:Destroy()end end
bed.Name="SurvivalBedAsset"
if not SS:FindFirstChild("SurvivalZombieRig")then
 local d=Instance.new("HumanoidDescription");d.HeadColor=Color3.fromRGB(115,130,112);d.LeftArmColor=d.HeadColor;d.RightArmColor=d.HeadColor;d.TorsoColor=Color3.fromRGB(32,36,39);d.LeftLegColor=Color3.fromRGB(40,49,57);d.RightLegColor=d.LeftLegColor
 local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15);rig.Name="SurvivalZombieRig"
 for _,v in rig:GetDescendants()do if v:IsA("LuaSourceContainer")then table.insert(removed,v.Name);v:Destroy()end end
 rig.Parent=SS;d:Destroy()
end
-- Bake upgraded rig joints in Edit so all body parts start at correct positions before simulation.
local rig=SS.SurvivalZombieRig;local by,seen={},{}
for _,j in rig:GetDescendants()do if (j:IsA("Motor6D")or j:IsA("AnimationConstraint"))and j.Part1 then by[j.Part1]=j end end
local function bake(p)
 if seen[p]then return p.CFrame end
 local j=by[p];if j and j.Part0 then p.CFrame=bake(j.Part0)*j.C0*j.Transform*j.C1:Inverse()end
 seen[p]=true;return p.CFrame
end
rig.HumanoidRootPart.CFrame=CFrame.new(0,3,0)
for _,v in rig:GetDescendants()do if v:IsA("BasePart")then bake(v)end end
return game.HttpService:JSONEncode({Assets={"SurvivalBedAsset","SurvivalZombieRig"},DeletedScripts=removed})


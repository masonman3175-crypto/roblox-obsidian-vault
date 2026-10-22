local track=workspace.Map.Track
local preview=assert(track:FindFirstChild("ExtensionsPreview"))
assert(#preview:GetChildren()==60)
local seen={};local parts=0;local landmarks=0
for _,world in ipairs(preview:GetChildren()) do
 local stage=world:GetAttribute("Stage");assert(stage>=7 and stage<=66 and not seen[stage]);seen[stage]=true
 local base=world.LandscapeBase
 assert(base:FindFirstChild("Arch") and base:FindFirstChild("Ground") and base:FindFirstChild("Scenery"))
 local strips=0;local first=math.huge;local last=-math.huge
 for _,p in ipairs(base.Ground:GetChildren()) do
  if p:IsA("BasePart") and p.Name=="Track" then
   strips+=1;assert(math.abs(p.Size.X-50)<.01 and math.abs(p.Size.Z-120)<.01)
   first=math.min(first,p.Position.X-p.Size.X/2);last=math.max(last,p.Position.X+p.Size.X/2)
  end
 end
 assert(strips==20 and math.abs(first-(40+(stage-1)*1000))<.01 and math.abs(last-first-1000)<.01,"Ground discontinuity "..stage)
 assert(#world.NaturalLandmarks:GetChildren()>0)
 for _,p in ipairs(world:GetDescendants()) do
  assert(not p:IsA("LuaSourceContainer"),"Unexpected executable scenery")
  if p:IsA("BasePart") then parts+=1;assert(p.Anchored)
   if p:IsDescendantOf(world.NaturalLandmarks) then
    landmarks+=1
    -- Axis-aligned world-space bounds of rotated pieces.
    local size=p.Size;local cf=p.CFrame
    local z=math.abs(cf.RightVector.Z)*size.X/2+math.abs(cf.UpVector.Z)*size.Y/2+math.abs(cf.LookVector.Z)*size.Z/2
    assert(p.Position.Z+z < -65 or p.Position.Z-z > 65,"New landmark crosses flight lane: "..p:GetFullName())
   end
  end
 end
 task.wait()
end
return "SCENE_PASS originals=6 appended=60 contiguous_length=60000 lane_clear=true extra_parts="..parts.." landmark_parts="..landmarks

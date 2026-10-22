local backup=assert(game.ServerStorage:FindFirstChild("PunchExpansion_Backup"))
local expected=backup.Track
local current=workspace.Map.Track
local names={"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}
local function signature(root,allowGate)
 local values={}
 for _,p in ipairs(root:GetDescendants()) do
  local row=p.ClassName.."|"..p.Name
  if p:IsA("BasePart") then
   local a={p.CFrame:GetComponents()};for _,n in ipairs(a) do row..=string.format("|%.5f",n) end
   row..="|"..tostring(p.Size).."|"..tostring(p.Color).."|"..p.Material.Name.."|"..tostring(p.CanCollide).."|"..p.TopSurface.Name
   if not (allowGate and p.Name=="BackdropEnd") then row..="|"..p.Transparency end
   if p:IsA("MeshPart") then row..="|"..p.MeshId.."|"..p.TextureID end
  elseif p:IsA("TextLabel") then row..="|"..p.Text.."|"..p.TextSize.."|"..tostring(p.TextColor3)
  elseif p:IsA("ParticleEmitter") then row..="|"..p.Texture.."|"..p.Rate end
  table.insert(values,row)
 end
 table.sort(values);return table.concat(values,"\n")
end
local count=0
for _,name in ipairs(names) do
 assert(current:FindFirstChild(name),"Missing original "..name)
 assert(signature(current[name],true)==signature(expected[name],true),"Original changed: "..name)
 count+=#current[name]:GetDescendants()
end
assert(signature(current.DistanceBoards,false)==signature(expected.DistanceBoards,false),"Original distance boards changed")
assert(not current:FindFirstChild("Finish"),"Old MAX barrier remains")
return "ORIGINALS_PASS worlds=6 original_descendants="..count.." geometry_colors_meshes_signs=preserved distance_boards=preserved exception=outer_end_backdrop_opened"


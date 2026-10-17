local base=workspace.Baseplate
assert(base.Material==Enum.Material.Asphalt)
for _,v in base:GetChildren() do if v:IsA("Texture") or v:IsA("Decal") then assert(v.Transparency==1) end end
assert(base.Position==Vector3.new(0,-8,0) and base.Size==Vector3.new(2048,16,2048) and base.CanCollide)
local specs={{"Spawn_West","Crips",Vector3.new(-235,.5,-135)},{"Spawn_East","Bloods",Vector3.new(245,.5,135)}}
assert(#game.Teams:GetTeams()==2)
local clearSamples=0
for _,s in specs do
 local spawn=workspace.Map.Spawns[s[1]];local team=game.Teams[s[2]]
 assert(spawn.Enabled and not spawn.Neutral and not spawn.AllowTeamChangeOnTouch and spawn.Duration==3)
 assert(spawn.TeamColor==team.TeamColor and team.AutoAssignable)
 assert((spawn.Position-s[3]).Magnitude<.01)
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={workspace.Map.Spawns}
 for _,p in workspace:GetPartBoundsInBox(CFrame.new(spawn.Position.X,5,spawn.Position.Z),Vector3.new(14,9,14),overlap) do assert(not p.CanCollide,"Spawn blocked by "..p:GetFullName()) end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={workspace.Map.Spawns}
 for x=-4,4 do for z=-4,4 do
  local r=workspace:Raycast(Vector3.new(spawn.Position.X+x,60,spawn.Position.Z+z),Vector3.new(0,-70,0),params)
  assert(r and math.abs(r.Position.Y)<.01,"Spawn footprint unsupported/roofed")
  clearSamples+=1
 end end
end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.Baseplate,workspace.Map.Ground,workspace.Map.PerimeterBoundary}
params.RespectCanCollide=true
local floorSamples=0
for x=-255,265,10 do for z=-145,145,10 do
 local r=workspace:Raycast(Vector3.new(x,10,z),Vector3.new(0,-25,0),params)
 assert(r and r.Instance.CanCollide,"Floor gap");floorSamples+=1
end end
return "VERIFY PASS: checker hidden; two team-only spawns; diagonal corners; 162 clear grounded spawn samples; "..floorSamples.." floor rays; unchanged baseplate collision/transform; three-second protection"


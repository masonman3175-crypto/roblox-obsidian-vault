local map=workspace.Map
assert(math.abs(game.SoundService.BackgroundMusic.Volume-.05)<1e-6)
local freshConfig=game.ReplicatedStorage.AudioPresentation.Config:Clone();freshConfig.Name="QA_AudioConfig";freshConfig.Parent=game.ServerStorage
local cfg=require(freshConfig);freshConfig:Destroy();assert(cfg.MusicVolume==.05)
local b=map.PerimeterBoundary
assert(b.WestSolid.Position.X+b.WestSolid.Size.X/2==-236)
assert(b.EastSolid.Position.X-b.EastSolid.Size.X/2==246)
assert(b.NorthSolid.Position.Z+b.NorthSolid.Size.Z/2==-122)
assert(b.SouthSolid.Position.Z-b.SouthSolid.Size.Z/2==122)
assert(not b:FindFirstChild("EastGroundApron"))
local mini=game.ReplicatedStorage.GameplayPresentation.MinimapWorld
for _,name in {"WestSolid","EastSolid","NorthSolid","SouthSolid"}do
 assert(mini["Boundary_"..name].CFrame==b[name].CFrame)
 assert(mini["Boundary_"..name].Size==b[name].Size)
end
local spawns=0;local samples=0
local excluded={map.Spawns};for _,p in game.Players:GetPlayers()do if p.Character then table.insert(excluded,p.Character)end end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=excluded;params.RespectCanCollide=true
for _,s in map.Spawns:GetChildren()do if s:IsA("SpawnLocation")then
 spawns+=1
 assert(s.Enabled and not s.Neutral)
 assert(s.Position.X>-230 and s.Position.X<240 and s.Position.Z>-117 and s.Position.Z<117)
 for x=-5,5 do for z=-5,5 do
  local r=workspace:Raycast(Vector3.new(s.Position.X+x,80,s.Position.Z+z),Vector3.new(0,-100,0),params)
  assert(r and r.Position.Y<1.2,"Spawn roofed or unsupported")
  samples+=1
 end end
 local op=OverlapParams.new();op.FilterType=Enum.RaycastFilterType.Exclude;op.FilterDescendantsInstances=excluded;op.RespectCanCollide=true
 assert(#workspace:GetPartBoundsInBox(CFrame.new(s.Position.X,5,s.Position.Z),Vector3.new(12,8,12),op)==0,"Spawn blocked")
end end
assert(spawns==2)
local gapSamples=0
local wallParams=RaycastParams.new();wallParams.FilterType=Enum.RaycastFilterType.Include;wallParams.FilterDescendantsInstances={b}
for _,y in {-1,3,15,40,70}do
 for x=-232,242,8 do
  assert(workspace:Raycast(Vector3.new(x,y,0),Vector3.new(0,0,140),wallParams))
  assert(workspace:Raycast(Vector3.new(x,y,0),Vector3.new(0,0,-140),wallParams));gapSamples+=2
 end
 for z=-118,118,8 do
  assert(workspace:Raycast(Vector3.new(5,y,z),Vector3.new(260,0,0),wallParams))
  assert(workspace:Raycast(Vector3.new(5,y,z),Vector3.new(-260,0,0),wallParams));gapSamples+=2
 end
end
return game.HttpService:JSONEncode({result="VERIFY PASS",music=.05,spawns=spawns,spawnFloorSamples=samples,wallRays=gapSamples,area=482*244,oldArea=534*300})


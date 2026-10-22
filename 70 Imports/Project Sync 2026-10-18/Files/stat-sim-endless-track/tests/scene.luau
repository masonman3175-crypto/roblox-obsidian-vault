-- Isolated scene fixture: builds and destroys each level. Never reads/writes player data.
local Builder=require(game.ReplicatedStorage.Shared.Util.PunchTrackBuilder)
local Levels=require(game.ReplicatedStorage.Shared.Config.PunchLevels)
local storage=game.ServerStorage
assert(not storage:FindFirstChild("PunchExpansion_SceneQA"))
local fixture=Instance.new("Folder");fixture.Name="PunchExpansion_SceneQA";fixture.Parent=storage
local ok,result=pcall(function()
 local signatures={};local maxParts=0;local minParts=math.huge
 for stage=1,60 do
  local model=Builder.Build(fixture,stage,40)
  local signature={};local count=0
  for _,p in ipairs(model.Landmark:GetDescendants()) do if p:IsA("BasePart") then
   local pos=p.Position-Vector3.new(40+320*.54,0,-113)
   table.insert(signature,string.format("%s:%.2f,%.2f,%.2f:%.2f,%.2f,%.2f:%.1f,%.1f,%.1f",
     p.Shape.Name,p.Size.X,p.Size.Y,p.Size.Z,pos.X,pos.Y,pos.Z,p.Orientation.X,p.Orientation.Y,p.Orientation.Z))
  end end
  table.sort(signature);local key=table.concat(signature,";")
  assert(not signatures[key],"Duplicate color-independent geometry: "..stage);signatures[key]=true
  assert(#signature>=8,"Hero too small "..stage)
  for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
   count+=1;assert(p.Anchored)
   assert(p.Name~="MaxWall" and p.Name~="MaxSign")
   if p.Position.Z>-8 and p.Position.Z<45 and p.Position.Y+p.Size.Y/2>1 and p.Position.Y-p.Size.Y/2<60 then error("Blocked flight corridor: "..stage.." / "..p.Name) end
  end end
  assert(model.Ground.TopSurface==Enum.SurfaceType.Studs)
  assert(count<=380,"Per-stage part budget exceeded")
  minParts=math.min(minParts,count);maxParts=math.max(maxParts,count)
  model:Destroy();if stage%3==0 then task.wait() end
 end
 local a=Builder.Build(fixture,61,40)
 assert(a:GetAttribute("VirtualStage")==61 and a.PocketScenery:FindFirstChild("EchoShard"),"echo geometry absent");a:Destroy()
 local b=Builder.Build(fixture,2991,40)
 assert(b:GetAttribute("VirtualStage")==2991);b:Destroy()
 return "SCENE_PASS themes=60 geometry_unique=60 clear_flight_corridors=60 studs=60 echo_61_and_2991=true parts_per_stage="..minParts.."-"..maxParts
end)
fixture:Destroy();assert(not storage:FindFirstChild("PunchExpansion_SceneQA"));assert(ok,result)
return result


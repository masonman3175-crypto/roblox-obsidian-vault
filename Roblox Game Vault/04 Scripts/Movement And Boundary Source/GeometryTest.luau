local boundary=workspace.Map.PerimeterBoundary
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={boundary}
local hits,misses=0,{}
local function ray(origin,direction)
 local hit=workspace:Raycast(origin,direction,params)
 if hit and hit.Instance.CanCollide then hits+=1 else table.insert(misses,tostring(origin))end
end
for _,y in ipairs({-2,2,8,20,60,80})do
 for x=-260,270,12 do
  ray(Vector3.new(x,y,-146),Vector3.new(0,0,-20))
  ray(Vector3.new(x,y,146),Vector3.new(0,0,20))
 end
 for z=-148,148,12 do
  ray(Vector3.new(-258,y,z),Vector3.new(-20,0,0))
  ray(Vector3.new(268,y,z),Vector3.new(20,0,0))
 end
end
assert(#misses==0,'Boundary gap')
local c=assert(loadstring(game.ReplicatedStorage.GameplayPresentation.MovementConfig.Source))()
assert(c.SlideCooldown==0 and c.SlideEndSpeed>=c.SlideMinSpeed)
assert(c.StaminaMax/c.SprintDrain>=20)
assert(c.CameraDrop>=1.4)
local spawns={}
for _,s in ipairs(workspace.Map:GetDescendants())do if s:IsA('SpawnLocation')then
 assert(s.Position.X>-262 and s.Position.X<272 and math.abs(s.Position.Z)<150)
 table.insert(spawns,{s.Name,tostring(s.CFrame),s.Enabled})
end end
return {Phase='MODIFIED',BoundaryRays=hits,Misses=#misses,StaminaSeconds=c.StaminaMax/c.SprintDrain,
 Cooldown=c.SlideCooldown,CameraDrop=c.CameraDrop,Spawns=spawns,ExitStatus=0}

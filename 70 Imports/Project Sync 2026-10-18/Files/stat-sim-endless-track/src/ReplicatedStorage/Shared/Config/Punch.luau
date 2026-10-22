-- Authoritative distance/reward math. No MAX wall or six-biome distance clamp.
local Levels=require(script.Parent.PunchLevels)
local Punch={}
Punch.Cooldown=2
Punch.AutoInterval=3
Punch.MaxRange=18
Punch.TrackStartX=40
Punch.BiomeLength=320
Punch.TrackZ=0
Punch.LevelsPerDecade=10
Punch.MaxVisibleStages=8
Punch.Biomes={}
for _,v in ipairs(Levels.List) do table.insert(Punch.Biomes,v[2]) end
local function finite(n) return type(n)=="number" and n==n and n<math.huge and n>-math.huge end
function Punch.Feet(strength)
 assert(finite(strength) and strength>=0,"Invalid strength")
 return math.floor(3.3*strength)+5
end
function Punch.Coins(feet,worldMultiplier,coinMultiplier)
 assert(finite(feet) and feet>=0,"Invalid distance")
 return math.floor(feet^.75*2*worldMultiplier*coinMultiplier)
end
function Punch.Progress(feet)
 assert(finite(feet) and feet>=0,"Invalid distance")
 return math.max(0,(math.log10(math.max(feet,10))-1)*Punch.LevelsPerDecade)
end
function Punch.StageAtFeet(feet) return math.floor(Punch.Progress(feet)+1e-9)+1 end
function Punch.Threshold(stage)
 assert(type(stage)=="number" and stage>=1 and stage%1==0,"Invalid stage")
 return 10^(1+(stage-1)/Punch.LevelsPerDecade)
end
function Punch.TrackX(feet) return Punch.TrackStartX+Punch.Progress(feet)*Punch.BiomeLength end
function Punch.BiomeAt(x)
 assert(finite(x),"Invalid virtual coordinate")
 local index=math.max(1,math.floor((x-Punch.TrackStartX)/Punch.BiomeLength+1e-9)+1)
 return index,Levels.Get(index).name
end
function Punch.Route(feet)
 local stage=Punch.StageAtFeet(feet)
 local count=math.min(stage,Punch.MaxVisibleStages)
 local route={}
 for i=1,count do
  local index=if count==1 then stage else 1+math.floor((stage-1)*(i-1)/(count-1)+.5)
  table.insert(route,{stage=index,x=Punch.TrackStartX+(i-1)*Punch.BiomeLength,warp=i>1 and index>route[i-1].stage+1})
 end
 -- Presentation is deliberately rebased near the hub, not a trillion-stud world.
 -- Reached stages/distance are not capped. Long flights use clearly marked portals
 -- between sampled milestones and always render the actual destination.
 local fraction=Punch.Progress(feet)%1
 local landing=route[#route].x+55+fraction*185
 return route,landing
end
return Punch

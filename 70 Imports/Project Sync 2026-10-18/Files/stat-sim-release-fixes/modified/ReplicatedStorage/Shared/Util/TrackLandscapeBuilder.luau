-- Append-only landscape extension. Uses the user's actual six biomes as style templates.
local RS=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.Parent.Config.TrackExtensionCatalog)
local Punch=require(script.Parent.Parent.Config.Punch)
local B={}
local v=Vector3.new
local white=Color3.fromRGB(228,239,245)
local function part(parent,name,size,pos,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color
 p.Anchored=true;p.Material=Enum.Material.Plastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
 if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function cyl(parent,name,size,pos,color)
 local p=part(parent,name,size,pos,color,Enum.PartType.Cylinder);p.Orientation=v(0,0,90);return p
end
local function beam(parent,name,a,b,width,color)
 local p=part(parent,name,v(width,width,(b-a).Magnitude),(a+b)/2,color);p.CFrame=CFrame.lookAt((a+b)/2,b);return p
end
local function ridge(ctx,x,z,h,w)
 for i=0,3 do
  local size=v(w-i*w*.13,h/4,w*.8-i*w*.1)
  local p=part(ctx.parent,"TerraceRock",size,ctx.origin+v(x,h/8+i*h/4,z),ctx.spec.terrain:Lerp(ctx.spec.foliage,i*.09))
  p.TopSurface=Enum.SurfaceType.Studs
 end
end
local function mountain(ctx,x,z,h,w)
 for _,angle in ipairs({0,90,180,270}) do
  local p=Instance.new("WedgePart");p.Name="MountainFace";p.Size=v(w,h,w*.65);p.Anchored=true;p.CanCollide=false
  p.Color=ctx.spec.foliage;p.CFrame=CFrame.new(ctx.origin+v(x,h/2,z))*CFrame.Angles(0,math.rad(angle),0);p.Parent=ctx.parent
  local cap=p:Clone();cap.Name="MountainCap";cap.Size=v(w*.5,h*.42,w*.33);cap.Position=ctx.origin+v(x,h*.8,z);cap.Color=white;cap.Parent=ctx.parent
 end
end
local function tree(ctx,x,z,h,redwood)
 local origin=ctx.origin+v(x,0,z)
 cyl(ctx.parent,"AncientTrunk",v(h*.65,h*.13,h*.13),origin+v(0,h*.32,0),Color3.fromRGB(119,82,55))
 if redwood then
  for i=0,4 do
   local width=h*(.75-i*.1)
   local p=cyl(ctx.parent,"EvergreenTier",v(h*.18,width,width),origin+v(0,h*.54+i*h*.1,0),ctx.spec.foliage)
   p.TopSurface=Enum.SurfaceType.Studs
  end
 else
  for i=1,4 do
   local a=i*math.pi/2
   part(ctx.parent,"Canopy",v(h*.65,h*.4,h*.6),origin+v(math.cos(a)*h*.17,h*.8,math.sin(a)*h*.17),ctx.spec.foliage,Enum.PartType.Ball)
  end
 end
end
local F={}
function F.waterfall(c)
 for i=1,3 do
  local x=130+i*215;local z=-205-(i%2)*90;local h=75+i*16
  ridge(c,x,z,h,100)
  for j=-1,1 do
   local p=part(c.parent,"Waterfall",v(11,h-8,3),c.origin+v(x+j*13,h/2,z+42),c.spec.accent)
   p.Material=Enum.Material.Glass;p.Transparency=.2
  end
  cyl(c.parent,"WaterfallPool",v(1,130,90),c.origin+v(x,.5,z+70),c.spec.accent).Material=Enum.Material.Glass
 end
end
function F.canyon(c)
 for i=1,6 do ridge(c,80+i*130,-130-(i%2)*150,65+c.rng:NextInteger(0,60),65+c.rng:NextInteger(0,30)) end
 for i=1,4 do beam(c.parent,"RockBridge",c.origin+v(i*195-55,48,-155),c.origin+v(i*195+55,48,-155),15,c.spec.foliage) end
end
function F.arches(c)
 for i=1,3 do
  local x=i*240;local z=-240;local h=80+i*8
  ridge(c,x-45,z,h,34);ridge(c,x+45,z,h,34)
  beam(c.parent,"NaturalRockArch",c.origin+v(x-52,h,z),c.origin+v(x+52,h,z),22,c.spec.terrain)
  part(c.parent,"ArchCrown",v(42,15,30),c.origin+v(x,h+8,z),c.spec.foliage)
 end
end
function F.glacier(c)
 for i=1,10 do
  local h=40+c.rng:NextInteger(0,90)
  local p=part(c.parent,"GlacierBlade",v(20+c.rng:NextInteger(0,20),h,35),c.origin+v(70+i*83,h/2,-155-(i%3)*90),c.spec.accent)
  p.Orientation=v(0,i*17,(-1)^i*8);p.Transparency=.12
 end
end
function F.aurora(c)
 F.glacier(c)
 for band=1,3 do for i=0,12 do
  local p=part(c.parent,"AuroraCurtain",v(65,27,1),c.origin+v(90+i*63,155+math.sin(i*.55+band)*20,-400+band*25),c.spec.accent:Lerp(c.spec.foliage,band*.18))
  p.Material=Enum.Material.Neon;p.Transparency=.65
 end end
end
function F.basalt(c)
 for i=1,14 do
  local h=25+c.rng:NextInteger(0,75)
  local p=cyl(c.parent,"BasaltColumn",v(h,25,25),c.origin+v(80+i*58,h/2,-110-(i%4)*70),c.spec.foliage)
  p.TopSurface=Enum.SurfaceType.Studs
 end
end
function F.rifts(c)
 for i=1,10 do
  local x=60+i*85;local z=-180+math.sin(i*.75)*35
  part(c.parent,"RiftGlow",v(105,1,15),c.origin+v(x,.2,z),c.spec.accent).Material=Enum.Material.Neon
  ridge(c,x,z-38,24+i%3*12,45)
 end
end
function F.crystals(c)
 for i=1,15 do
  local h=20+c.rng:NextInteger(0,80);local x=50+i*60;local z=-130-(i%4)*70
  local p=part(c.parent,"CrystalSpire",v(12,h,17),c.origin+v(x,h/2,z),c.spec.accent)
  p.Orientation=v(i%3*9,i*31,(-1)^i*16);p.Material=Enum.Material.Glass;p.Transparency=.12
  part(c.parent,"CrystalCluster",v(8,h*.6,10),c.origin+v(x+15,h*.3,z+8),c.spec.accent).Orientation=v(0,i*18,25)
 end
end
function F.cavern(c)
 F.crystals(c)
 for i=1,4 do
  local x=i*200
  ridge(c,x-55,-280,88,50);ridge(c,x+55,-280,95,50)
  beam(c.parent,"CavernCeiling",c.origin+v(x-68,95,-280),c.origin+v(x+68,95,-280),35,c.spec.foliage)
 end
end
function F.planet(c)
 part(c.parent,"DistantPlanet",v(180,180,180),c.origin+v(630,170,-410),c.spec.accent,Enum.PartType.Ball)
 for i=1,32 do
  local a=i*math.pi/16;local b=(i+1)*math.pi/16
  beam(c.parent,"PlanetRing",c.origin+v(630+math.cos(a)*135,170,-410+math.sin(a)*135),c.origin+v(630+math.cos(b)*135,170,-410+math.sin(b)*135),6,c.spec.foliage)
 end
end
function F.outpost(c)
 for i=1,3 do
  local x=150+i*210;local z=-150-(i%2)*100
  cyl(c.parent,"HabitatBase",v(4,64,64),c.origin+v(x,2,z),white)
  local dome=part(c.parent,"ResearchDome",v(60,43,60),c.origin+v(x,15,z),c.spec.accent,Enum.PartType.Ball);dome.Transparency=.4
  part(c.parent,"Airlock",v(17,20,18),c.origin+v(x,10,z+25),white)
  for j=0,3 do part(c.parent,"SolarArray",v(13,1,23),c.origin+v(x+50+j*15,13,z),c.spec.foliage).Orientation=v(0,0,12) end
 end
end
function F.canopy(c)
 for i=1,11 do tree(c,70+i*77,-160-(i%3)*90,65+c.rng:NextInteger(0,40),false) end
end
function F.terraces(c)
 for i=1,5 do
  local x=70+i*150
  for j=0,3 do
   local p=cyl(c.parent,"TerraceIsland",v(11,90-j*14,75-j*9),c.origin+v(x,5.5+j*11,-155-i%2*95),if j==3 then c.spec.foliage else c.spec.terrain)
   p.TopSurface=Enum.SurfaceType.Studs
  end
 end
end
function F.ruins(c)
 for i=1,4 do
  local x=i*205;local z=-220
  for _,dx in ipairs({-35,35}) do
   part(c.parent,"AncientPillar",v(14,55+i*5,14),c.origin+v(x+dx,28+i*2.5,z),c.spec.terrain)
   part(c.parent,"PillarCapital",v(23,7,23),c.origin+v(x+dx,58+i*5,z),c.spec.foliage)
  end
  part(c.parent,"RuinedLintel",v(100,12,24),c.origin+v(x,65+i*5,z),c.spec.terrain)
  for j=1,3 do part(c.parent,"Rubble",v(17,9,15),c.origin+v(x-35+j*20,4,-175),c.spec.terrain).Orientation=v(0,j*38,9) end
 end
end
function F.coast(c)
 for i=1,6 do
  cyl(c.parent,"CoastalPool",v(.6,120,90),c.origin+v(60+i*135,.35,-160-(i%2)*120),c.spec.accent).Material=Enum.Material.Glass
  ridge(c,60+i*135,-245-(i%2)*80,18,70)
 end
end
function F.vines(c)
 for i=1,6 do
  local x=80+i*130
  tree(c,x,-220,75,false)
  for j=1,4 do beam(c.parent,"HangingVine",c.origin+v(x+j*9-18,65,-200),c.origin+v(x+j*9-18,12+j*5,-200),1.8,c.spec.accent) end
 end
end
function F.peaks(c)
 for i=1,7 do mountain(c,45+i*125,-190-(i%2)*160,90+c.rng:NextInteger(0,90),100) end
end
function F.storm(c)
 F.peaks(c)
 for i=1,4 do
  local x=100+i*190
  for j=0,4 do part(c.parent,"StormCloud",v(55,26,35),c.origin+v(x+j*25,175+math.sin(j)*8,-280),c.spec.foliage,Enum.PartType.Ball) end
  beam(c.parent,"Lightning",c.origin+v(x+40,160,-275),c.origin+v(x+20,120,-275),3,c.spec.accent).Material=Enum.Material.Neon
  beam(c.parent,"Lightning",c.origin+v(x+20,120,-275),c.origin+v(x+55,85,-275),3,c.spec.accent).Material=Enum.Material.Neon
 end
end
function F.lavafall(c)
 F.waterfall(c)
 for _,p in ipairs(c.parent:GetChildren()) do if p:IsA("BasePart") and (p.Name=="Waterfall" or p.Name=="WaterfallPool") then p.Material=Enum.Material.Neon;p.Transparency=0 end end
end
function F.foundry(c)
 for i=1,4 do
  local x=100+i*180;ridge(c,x,-220,40,80)
  for _,dx in ipairs({-25,25}) do
   cyl(c.parent,"FoundryChimney",v(90,18,18),c.origin+v(x+dx,75,-220),c.spec.foliage)
   cyl(c.parent,"SmokestackRim",v(6,24,24),c.origin+v(x+dx,122,-220),c.spec.accent)
  end
  part(c.parent,"FoundryGlow",v(45,28,2),c.origin+v(x,25,-177),c.spec.accent).Material=Enum.Material.Neon
 end
end
function F.sugar(c)
 for i=1,9 do
  local x=65+i*93
  part(c.parent,"SugarCrystal",v(20,42,20),c.origin+v(x,24,-150-(i%3)*75),c.spec.accent).Orientation=v(0,i*29,16)
  tree(c,x,-310,55,false)
 end
end
function F.savanna(c)
 for i=1,10 do tree(c,65+i*85,-150-i%3*85,45+i%3*9,false) end
 F.mesas(c)
end
function F.mesas(c)
 for i=1,5 do ridge(c,50+i*165,-210-(i%2)*100,55+i%3*24,100) end
end
function F.bamboo(c)
 for cluster=1,3 do for i=1,12 do
  local x=cluster*260-50+math.sin(i*2)*45;local z=-170-cluster%2*90+math.cos(i*2)*30
  local h=55+i%4*12
  for j=0,4 do cyl(c.parent,"BambooSegment",v(h/5-1,4.5,4.5),c.origin+v(x,h/10+j*h/5,z),c.spec.foliage) end
 end end
end
function F.moon(c)
 part(c.parent,"Moon",v(105,105,105),c.origin+v(650,175,-420),c.spec.accent,Enum.PartType.Ball)
 for i=1,4 do ridge(c,i*210,-250,35+i*5,75) end
end
function F.islands(c)
 for i=1,6 do
  local h=25+i%3*24;local x=35+i*145;local z=-190-(i%2)*130
  cyl(c.parent,"FloatingRock",v(26,100,80),c.origin+v(x,h,z),c.spec.terrain)
  local p=cyl(c.parent,"FloatingGrass",v(3,102,82),c.origin+v(x,h+15,z),c.spec.foliage);p.TopSurface=Enum.SurfaceType.Studs
  part(c.parent,"HangingRock",v(29,35,26),c.origin+v(x,h-22,z),c.spec.terrain).Orientation=v(0,45,20)
 end
end
function F.dunes(c)
 for i=1,10 do
  local x=40+i*88;local h=15+i%3*8
  part(c.parent,"GreatDune",v(140,h*2,85),c.origin+v(x,0,-150-(i%3)*90),c.spec.terrain,Enum.PartType.Ball)
 end
end
function F.ash(c)
 F.basalt(c)
 for i=1,9 do part(c.parent,"AshCloud",v(65,20,35),c.origin+v(50+i*95,115+i%2*15,-300),c.spec.foliage,Enum.PartType.Ball) end
end
function F.mushrooms(c)
 for i=1,16 do
  local h=25+i%4*10;local p=c.origin+v(35+i*56,0,-140-(i%4)*65)
  cyl(c.parent,"MushroomStem",v(h,7,7),p+v(0,h/2,0),c.spec.terrain)
  part(c.parent,"MushroomCap",v(38,h*.4,33),p+v(0,h,0),c.spec.foliage,Enum.PartType.Ball)
  for j=1,3 do part(c.parent,"CapSpot",v(5,2,5),p+v(math.cos(j*2)*10,h+h*.16,math.sin(j*2)*8),c.spec.accent,Enum.PartType.Ball) end
 end
end
function F.gingerbread(c)
 for i=1,4 do
  local x=i*210;part(c.parent,"GingerbreadCottage",v(65,42,45),c.origin+v(x,21,-210),c.spec.terrain)
  for j=0,3 do part(c.parent,"IcingRoof",v(78-j*15,5,60-j*8),c.origin+v(x,45+j*5,-210),white) end
  part(c.parent,"CandyDoor",v(14,23,1),c.origin+v(x,12,-187),c.spec.accent)
 end
end
function F.craters(c)
 for i=1,7 do
  local pos=c.origin+v(60+i*120,0,-130-(i%3)*95)
  cyl(c.parent,"CraterRim",v(7,85,72),pos+v(0,3,0),c.spec.foliage)
  cyl(c.parent,"CraterFloor",v(1,65,53),pos+v(0,7,0),c.spec.terrain)
 end
end
function F.meteors(c)
 for i=1,10 do
  local s=18+i%4*7;local pos=c.origin+v(40+i*90,55+i%3*35,-180-i%2*100)
  part(c.parent,"Meteor",v(s,s,s),pos,c.spec.foliage,Enum.PartType.Ball)
  for j=1,3 do part(c.parent,"MeteorTail",v(s*.6-j,s*.6-j,s*.6-j),pos-v(j*22,-j*4,0),c.spec.accent,Enum.PartType.Ball) end
 end
end
function F.river(c)
 for i=0,9 do part(c.parent,"River",v(104,.6,35),c.origin+v(50+i*100,.4,-140-math.sin(i*.5)*25),c.spec.accent).Material=Enum.Material.Glass end
end
function F.redwoods(c)
 for i=1,10 do tree(c,50+i*90,-150-(i%3)*90,80+i%4*15,true) end
end
function F.citadel(c)
 F.ruins(c)
 for i=1,4 do
  local x=i*205;part(c.parent,"CitadelTower",v(38,86,38),c.origin+v(x,43,-330),c.spec.terrain)
  for j=-1,1 do part(c.parent,"Battlement",v(9,11,15),c.origin+v(x+j*12,90,-310),c.spec.foliage) end
 end
end
function F.bones(c)
 for i=1,8 do
  local x=65+i*105;local h=35+math.sin(i*.4)*18
  beam(c.parent,"FossilRib",c.origin+v(x,1,-190),c.origin+v(x,h,-240),7,white)
  part(c.parent,"BoneKnuckle",v(13,13,13),c.origin+v(x,h,-240),white,Enum.PartType.Ball)
 end
 beam(c.parent,"FossilSpine",c.origin+v(120,45,-245),c.origin+v(890,45,-245),8,white)
end
function F.coral(c)
 for i=1,15 do
  local pos=c.origin+v(30+i*61,0,-145-i%3*85);local h=20+i%4*10
  beam(c.parent,"CoralTrunk",pos,pos+v(0,h,0),6,c.spec.foliage)
  for j=-1,1 do beam(c.parent,"CoralBranch",pos+v(0,h*.6,0),pos+v(j*17,h*1.1,0),5,c.spec.accent) end
 end
end
function F.mist(c)
 for i=1,9 do
  local p=part(c.parent,"LowMist",v(100,12,40),c.origin+v(50+i*100,18,-200-i%3*75),c.spec.accent,Enum.PartType.Ball);p.Transparency=.8
 end
end
function F.honey(c)
 for i=1,15 do
  local h=20+i%4*10;local p=cyl(c.parent,"HoneyMesa",v(h,45,45),c.origin+v(35+i*60,h/2,-160-i%3*65),c.spec.terrain);p.TopSurface=Enum.SurfaceType.Studs
  cyl(c.parent,"HoneyCap",v(2,47,47),p.Position+v(0,h/2,0),c.spec.accent)
 end
end
function F.caldera(c)
 for j=0,6 do
  cyl(c.parent,"CalderaLayer",v(15,260-j*25,220-j*20),c.origin+v(520,7.5+j*15,-300),c.spec.foliage)
 end
 cyl(c.parent,"CalderaLake",v(2,90,80),c.origin+v(520,106,-300),c.spec.accent).Material=Enum.Material.Neon
end
function F.gears(c)
 F.mesas(c)
 for i=1,3 do
  local pos=c.origin+v(i*245,75,-220);local r=33+i*5
  for j=1,12 do
   local a=j*math.pi/6;local p=part(c.parent,"AncientGear",v(15,22,10),pos+v(math.cos(a)*r,math.sin(a)*r,0),c.spec.accent)
   p.Orientation=v(0,0,math.deg(a))
  end
  local axle=part(c.parent,"GearAxle",v(15,15,22),pos,c.spec.foliage,Enum.PartType.Cylinder);axle.Orientation=v(0,90,0)
 end
end
function F.supernova(c)
 F.planet(c)
 for i=1,28 do
  local a=i*math.pi/14;local center=c.origin+v(630,170,-410)
  beam(c.parent,"SupernovaRay",center+v(math.cos(a)*115,math.sin(a)*115,0),center+v(math.cos(a)*160,math.sin(a)*160,0),4,c.spec.accent).Material=Enum.Material.Neon
 end
end
function B.Build(parent,stage,options)
 options=options or {};local spec=Catalog.Get(stage);assert(not spec.original,"Never rebuild originals")
 local templates=RS:WaitForChild("TrackExtensionTemplates")
 local template=assert(templates:FindFirstChild(Catalog.Folders[spec.template]),"Missing landscape template")
 local start=40+(stage-1)*1000;local oldStart=40+(spec.template-1)*1000;local delta=v(start-oldStart,0,0)
 local model=Instance.new("Model");model.Name=string.format("World_%03d_%s",stage,spec.name:gsub("[^%w]",""))
 model:SetAttribute("Stage",stage);model:SetAttribute("OriginalStyle",Catalog.Folders[spec.template]);model:SetAttribute("Name",spec.name)
 local base=template:Clone();base.Name="LandscapeBase";base.Parent=model
 model:PivotTo(model:GetPivot()+delta)
 local serial=0
 for _,p in ipairs(base:GetDescendants()) do
  if p:IsA("LuaSourceContainer") then p:Destroy()
  elseif p:IsA("BasePart") then
   serial+=1
   if p.Name=="BackdropEnd" or p.Name=="Filler" then p:Destroy()
   elseif options.lod and (p.Name=="Star" or p.Name=="Rim" or p.Name=="Sprinkle") and serial%3~=0 then p:Destroy()
   else
    if p.Name=="Track" or p.Name=="SideFar" or p.Name=="SideNear" then p.Color=p.Color:Lerp(spec.terrain,.5)
    elseif p.Name:find("Leaves") or p.Name=="Puff" or p.Name=="Dune" or p.Name=="Rock" or p.Name=="Snow" then p.Color=p.Color:Lerp(spec.foliage,.45)
    elseif p.Name=="Lava" or p.Name=="Glow" or p.Name=="Crater" or p.Name=="Crystal" or p.Name=="SpikeGlow" then p.Color=spec.accent end
   end
  elseif p:IsA("TextLabel") and p:IsDescendantOf(base.Arch) then p.Text=string.upper(spec.name) end
 end
 if not base.Ground:FindFirstChild("SideFar") then
  local p=part(base.Ground,"SideFar",v(1000,2,440),v(start+500,-1,-280),spec.terrain);p.CanCollide=true;p.CanQuery=true
 end
 if not base.Ground:FindFirstChild("SideNear") then
  local p=part(base.Ground,"SideNear",v(1000,2,190),v(start+500,-1,155),spec.terrain);p.CanCollide=true;p.CanQuery=true
 end
 local landmarks=Instance.new("Folder");landmarks.Name="NaturalLandmarks";landmarks.Parent=model
 local context={parent=landmarks,origin=v(start,0,0),spec=spec,rng=Random.new(spec.seed)}
 assert(F[spec.feature],spec.feature)(context);assert(F[spec.secondary],spec.secondary)(context)
 if spec.cycle>0 then
  for i=1,3+spec.cycle%4 do ridge(context,100+i*130,-390,45+spec.cycle%7*9,60) end
 end
 -- Match the existing distance-board construction rather than introducing a new HUD style.
 local board=templates:FindFirstChild("DistanceBoard")
 if board then for i=0,3 do
  local m=Instance.new("Model");m.Name="DistanceBoard";local b=board:Clone();b.Parent=m
  local x=start+i*250;local pivot=m:GetPivot();m:PivotTo(pivot+v(x-40,0,0))
  local feet=Punch.FeetAtX(x)
  for _,l in ipairs(m:GetDescendants()) do if l:IsA("TextLabel") then l.Text=B.Number(feet).." FT" end end
  m.Parent=model
 end end
 model.WorldPivot=CFrame.new(start,0,0);model.Parent=parent
 return model
end
function B.Number(n)
 if n>=1e12 then local e=math.floor(math.log10(n));return string.format("%.2fe%d",n/10^e,e) end
 if n>=1e9 then return string.format("%.1fB",n/1e9) end
 if n>=1e6 then return string.format("%.1fM",n/1e6) end
 if n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n))
end
function B.Preview(parent,first,last)
 local f=Instance.new("Folder");f.Name="ExtensionsPreview";f.Parent=parent
 for stage=first or 7,last or Catalog.Count do
  B.Build(f,stage);task.wait()
 end
 return f
end
return B



local checks=0
local function check(v,m) assert(v,m);checks+=1 end
local function near(a,b,m)check(math.abs(a-b)<1e-4,m) end
check(#Catalog.Originals==6 and #Catalog.List==60 and Catalog.Count==66,"six originals plus sixty")
local names={}
for stage=1,66 do
 local spec=Catalog.Get(stage)
 check(not names[spec.name],"unique world name");names[spec.name]=true
 check(Punch.Biomes[stage]==spec.name,"public name order")
 if stage<=6 then
  check(spec.original and spec.template==stage,"original world retained")
 else
  check(spec.template>=1 and spec.template<=6,"uses original landscape style")
  check(type(spec.feature)=="string" and type(spec.secondary)=="string","landscape features")
 end
 local feet=Punch.Threshold(stage)
 near(Punch.TrackX(feet),40+(stage-1)*1000,"threshold mapping")
 check(Punch.BiomeAt(Punch.TrackX(feet))==stage,"stage lookup")
 local echo=Catalog.Get(stage+66)
 check(type(echo.name)=="string","continued destination")
end
for _,feet in ipairs({0,5,10,100,1000,10000,1e5,1e6,1e7}) do
 local old=40+math.clamp(math.log10(math.max(feet,10))-1,0,6)*1000
 near(Punch.TrackX(feet),old,"original first-six mapping unchanged")
end
check(Punch.TrackX(1e8)>6040,"former max surpassed")
check(Punch.TrackX(1e13)>=66040,"sixty extra landscapes reachable")
check(Punch.TrackX(1e100)>Punch.TrackX(1e20),"no catalog clamp")
local stage,name=Punch.BiomeAt(Punch.TrackX(1e100));check(stage>66 and name:find("Frontier"),"frontiers beyond catalog")
for _,strength in ipairs({0,1,100,10000,1e6}) do
 local feet=Punch.Feet(strength);check(feet==math.floor(3.3*strength)+5,"original feet formula")
 for _,world in ipairs({1,3,10,40,150}) do check(Punch.Coins(feet,world,1.5)==math.floor(feet^.75*2*world*1.5),"original reward formula") end
end
check(Punch.BiomeLength==1000,"full original-sized landscapes")
check(Punch.MaxExtraWorlds==8,"runtime budget")
return "CONTRACTS_PASS checks="..checks.." originals=6 appended=60 original_mapping=preserved former_max=removed rewards=unchanged"


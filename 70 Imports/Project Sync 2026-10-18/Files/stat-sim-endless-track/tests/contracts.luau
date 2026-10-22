local checks=0
local function check(v,message) assert(v,message);checks+=1 end
local function near(a,b,message) check(math.abs(a-b)<.001,message) end
check(Levels.Count==60,"sixty worlds")
check(#Punch.Biomes==60,"legacy list compatible")
local ids,kinds={},{}
for i=1,60 do
 local s=Levels.Get(i);check(not ids[s.id],"unique original id");ids[s.id]=true
 check(not kinds[s.kind],"unique handcrafted landmark");kinds[s.kind]=true
 check(s.index==i and s.cycle==0,"catalog index")
 check(s.name==Punch.Biomes[i],"name parity")
 check(Punch.StageAtFeet(Punch.Threshold(i))==i,"threshold exact stage "..i)
 near(Punch.TrackX(Punch.Threshold(i)),40+(i-1)*320,"virtual distance")
 if i>1 then check(Punch.StageAtFeet(Punch.Threshold(i)*(1-1e-5))==i-1,"threshold lower boundary") end
 local echo=Levels.Get(i+60)
 check(echo.id==s.id and echo.cycle==1 and echo.name~=s.name,"echo progression")
 check(echo.color~=s.color,"echo palette")
end
local lastX=-1
for _,feet in ipairs({0,5,10,12,100,1000,1e5,1e7,1e8,1e12,1e20,1e100,1e300}) do
 local x=Punch.TrackX(feet);check(x>=lastX,"monotonic distance");lastX=x
 local stage=Punch.StageAtFeet(feet)
 local route,landing=Punch.Route(feet)
 check(#route>=1 and #route<=8,"bounded scenery")
 check(route[#route].stage==stage,"true reached destination")
 check(route[1].stage==1,"launch continuity")
 check(landing<2700 and landing>=route[#route].x,"near-origin rebasing")
 for i,e in ipairs(route) do
  check(e.stage%1==0 and e.stage>=1,"valid route id")
  if i>1 then check(e.stage>route[i-1].stage,"strict milestone order") end
 end
 check(Punch.BiomeAt(x)==stage,"virtual biome lookup")
end
check(Punch.TrackX(1e8)>Punch.TrackX(1e7),"former cap surpassed")
check(Punch.StageAtFeet(1e7)==61,"sixty levels before former max")
check(Punch.StageAtFeet(1e300)==2991,"extreme finite distance remains advancing")
for _,strength in ipairs({0,1,10,10000,1e6,1e12}) do
 local feet=Punch.Feet(strength)
 check(feet==math.floor(3.3*strength)+5,"original distance economy")
 for _,world in ipairs({1,3,10,40,150}) do
  check(Punch.Coins(feet,world,1.5)==math.floor(feet^.75*2*world*1.5),"original coin formula")
 end
end
for _,bad in ipairs({math.huge,-math.huge,0/0}) do check(not pcall(Punch.TrackX,bad),"reject non-finite") end
check(not pcall(Punch.TrackX,-1),"reject negative")
check(Format.Number(1e100)=="1.00e100","scientific display")
check(Format.Number(1250)=="1.2K","old small format")
return "CONTRACTS_PASS checks="..checks.." original_themes=60 former_cap=surpassed stage_at_1e300=2991 render_budget=8 rewards=unchanged"


-- External test harness: never installed into the game. SOURCE and MODE are injected.
local function clone(v)
 if type(v)~="table" then return v end
 local t={};for k,x in v do t[k]=clone(x) end;return t
end
local function fixture(studio)
 local db,failures,writes={},0,0
 local store={}
 function store:GetAsync(k) if failures>0 then failures-=1;error("API unavailable") end;return clone(db[k]) end
 function store:UpdateAsync(k,fn)
  if failures>0 then failures-=1;error("API unavailable") end
  local nextValue=fn(clone(db[k]));if nextValue==nil then return nil end
  writes+=1;db[k]=clone(nextValue);return clone(db[k])
 end
 local added,removed=Instance.new("BindableEvent"),Instance.new("BindableEvent")
 local services={Players={PlayerAdded=added.Event,PlayerRemoving=removed.Event,GetPlayers=function()return {}end},
 RunService={IsStudio=function()return studio end},HttpService=game:GetService("HttpService"),
 DataStoreService={GetDataStore=function(_,name) assert(name==(if studio and MODE~="baseline" then "StatSim_v1_Studio" else "StatSim_v1"));return store end}}
 local shutdown
 local fakeGame={GetService=function(_,name)return assert(services[name],name)end,BindToClose=function(_,fn)shutdown=fn end}
 local code=assert(loadstring(SOURCE,"DataService under test"))
 local env=setmetatable({game=fakeGame,task={spawn=function()end,wait=function()end},warn=function()end},{__index=getfenv()})
 setfenv(code,env)
 local ds=code();ds.Start()
 local function player(id)
  return {UserId=id,Parent=true,Attributes={},SetAttribute=function(self,k,v)self.Attributes[k]=v end,
   Kick=function(self,reason)self.Kicked=reason end}
 end
 return ds,db,player,function(n)failures=n end,function()return writes end,shutdown
end

if MODE=="baseline" then
 local ds,db,player,fail=fixture(true)
 fail(10);local p=player(501);ds.Load(p)
 local reported=ds.Save(p)
 assert(reported==true,"Baseline drift: expected preview Save to report success")
 local d=ds.Get(p);for i=1,51 do ds.AddReceipt(d,tostring(i)) end
 assert(not ds.HasReceipt(d,"1"))
 return "BASELINE: preview Save=true without persistence; receipt 1 evicted after 51; duplicate egg prompts present"
end

local ds,db,player,fail,writes=fixture(false)
local a=player(501);ds.Load(a)
local d=assert(ds.Get(a));d.Strength=4321;d.Coins=987;d.Level=12;d.XP=34;d.Rebirths=3;d.WorldUnlocked=4;d.BestPunch=456
d.PetInv={{u="7",p="Doggy",e=true}};d.NextPetUid=8;d.BoostEnd=os.time()+900;d.AutoPunchOn=false
for i=1,75 do ds.AddReceipt(d,tostring(i)) end
assert(ds.HasReceipt(d,"1"))
assert(ds.Save(a,true));assert(db.player_501._Session==nil)
local b=player(501);ds.Load(b);local r=assert(ds.Get(b))
for _,key in {"Strength","Coins","Level","XP","Rebirths","WorldUnlocked","BestPunch","NextPetUid","BoostEnd","AutoPunchOn"}do assert(r[key]==d[key],key.." lost")end
assert(r.PetInv[1].u=="7" and r.PetInv[1].e and ds.HasReceipt(r,"1"))
-- Snapshot and load copies cannot mutate the stored value out of band.
r.Coins=999;assert(db.player_501.Coins==987)
-- Foreign active session cannot load or overwrite progress.
local c=player(501);local before=writes();ds.Load(c);assert(c.Kicked and not ds.Get(c) and writes()==before)
-- Losing ownership prevents an old server from saving stale data.
db.player_501._Session.Id="foreign-session";assert(ds.Save(b)==false);assert(db.player_501.Coins==987 and b.Kicked)
-- Live failed loads never initialize or save defaults.
local e=player(502);fail(10);ds.Load(e);assert(e.Kicked and not ds.Get(e));assert(not ds.Save(e));assert(db.player_502==nil)
-- Studio API failures are visibly session-only, never a successful durable save.
local preview,_,make,breakApi=fixture(true);local p=make(601);breakApi(10);preview.Load(p)
assert(preview.Get(p) and p.Attributes.DataPersistent==false and preview.Save(p)==false)
-- Transient writes retry successfully.
local retry,_,make2,break2=fixture(false);local q=make2(602);retry.Load(q);retry.Get(q).Coins=55;break2(2);assert(retry.Save(q))
return "MODIFIED: 8/8 persistence checks PASS (rejoin fields, pets, receipts, snapshots, session conflict, stale writer, failed load, retry/preview)"

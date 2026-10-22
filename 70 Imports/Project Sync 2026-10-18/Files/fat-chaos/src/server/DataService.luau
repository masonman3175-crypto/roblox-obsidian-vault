local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local D={Profiles={},Sessions={},Status={},Saving={}}
local store
pcall(function() store=DSS:GetDataStore("FatChaosProfiles_v1") end)
local token=game.JobId~="" and game.JobId or Http:GenerateGUID(false)
local function fresh()
 return {Size=0,Coins=0,XP=0,Rebirths=0,Best=0,Zone=1,Powers={jump=true},Equipped="jump",Cosmetics={},EquippedCosmetic="",Food=0,BossWins=0,Rolls=0,Achievements={},Daily={Day=0,Growth=0,Food=0,Boss=0,Claimed={}},Title="Tiny Menace"}
end
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e15 end
function D.Sanitize(raw)
 local p=fresh()
 if type(raw)~="table" then return p end
 for _,key in ipairs({"Size","Coins","XP","Rebirths","Best","Zone","Food","BossWins","Rolls","BestSprint"}) do if finite(raw[key]) then p[key]=math.max(0,raw[key]) end end
 p.Zone=math.clamp(p.Zone,1,5);p.Rebirths=math.min(p.Rebirths,10000)
 for _,key in ipairs({"Powers","Cosmetics","Achievements"}) do if type(raw[key])=="table" then for k,v in pairs(raw[key]) do if type(k)=="string" and v==true then p[key][k]=true end end end end
 if type(raw.Equipped)=="string" and p.Powers[raw.Equipped] then p.Equipped=raw.Equipped end
 if type(raw.EquippedCosmetic)=="string" and p.Cosmetics[raw.EquippedCosmetic] then p.EquippedCosmetic=raw.EquippedCosmetic end
 if type(raw.Daily)=="table" then
  for _,k in ipairs({"Day","Growth","Food","Boss"}) do if finite(raw.Daily[k]) then p.Daily[k]=math.max(0,raw.Daily[k]) end end
  if type(raw.Daily.Claimed)=="table" then for k,v in pairs(raw.Daily.Claimed) do if type(k)=="string" and v==true then p.Daily.Claimed[k]=true end end end
 end
 return p
end
function D.Load(player)
 local key="u"..player.UserId; local profile; local state="Guest session • saving unavailable"
 for attempt=1,store and 3 or 0 do
  local locked=false
  local ok,value=pcall(function() return store:UpdateAsync(key,function(old)
   if type(old)=="table" and type(old.Lock)=="table" and old.Lock.Token~=token and (old.Lock.Time or 0)>os.time()-180 then locked=true;return nil end
   local p=D.Sanitize(old);p.Lock={Token=token,Time=os.time()};return p
  end) end)
  if ok and locked then return nil,"Your profile is active on another server. Please rejoin shortly." end
  if ok and value then profile=D.Sanitize(value);D.Sessions[player]=true;state="Cloud save connected";break end
  if attempt<3 then task.wait(attempt) end
 end
 if not player.Parent then return nil,"Player left" end
 D.Profiles[player]=profile or fresh();D.Status[player]=state
 return D.Profiles[player]
end
function D.Save(player,release)
 if D.Saving[player] then
  if not release then return false end
  local untilTime=os.clock()+10;while D.Saving[player] and os.clock()<untilTime do task.wait(.1) end
  if D.Saving[player] then return false end
 end
 local p=D.Profiles[player];if not p or not D.Sessions[player] then return false end
 D.Saving[player]=true
 local snapshot=D.Sanitize(p)
 for attempt=1,3 do
  local lost=false
  local ok,result=pcall(function() return store:UpdateAsync("u"..player.UserId,function(old)
   if type(old)~="table" or type(old.Lock)~="table" or old.Lock.Token~=token then lost=true;return nil end
   snapshot.Lock=not release and {Token=token,Time=os.time()} or nil;return snapshot
  end) end)
  if lost then D.Sessions[player]=nil;D.Status[player]="Save lock lost • rejoin recommended";D.Saving[player]=nil;return false end
  if ok and result then D.Status[player]="Saved to cloud";D.Saving[player]=nil;return true end
  if attempt<3 then task.wait(attempt) end
 end
 D.Status[player]="Cloud retry pending";D.Saving[player]=nil;return false
end
function D.Remove(player) D.Save(player,true);D.Profiles[player]=nil;D.Sessions[player]=nil;D.Status[player]=nil end
return D

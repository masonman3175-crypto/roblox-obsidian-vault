---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Services.DataService

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Services.DataService`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [DataService.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Services/DataService.luau)

```luau
-- Ordered durable profiles with cross-server leases; Studio saves stay separate from live.
local DataStoreService=game:GetService("DataStoreService")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local DataService={}
local STORE_NAME=if RunService:IsStudio() then "StatSim_v1_Studio" else "StatSim_v1"
local AUTOSAVE_SECONDS,LEASE_SECONDS=45,180
local profiles,sessions,loading={},{},{}
local store,started,shuttingDown=nil,false,false
local loadedEvent=Instance.new("BindableEvent")
DataService.ProfileLoaded=loadedEvent.Event

local function defaults()
 return {SchemaVersion=2,Strength=0,TotalStrength=0,XP=0,Level=1,Rebirths=0,Coins=0,
 BestPunch=0,PetInv={},NextPetUid=1,WorldUnlocked=1,BoostEnd=0,CoinBoostEnd=0,LuckEnd=0,
 AutoTrainOn=true,AutoPunchOn=true,AutoHatchOn=true,Receipts={},ReceiptOrder={},WorldSkipCredits=0}
end
local function copy(value)
 if type(value)~="table" then return value end
 local result={}
 for k,v in value do result[k]=copy(v) end
 return result
end
local function reconcile(value)
 assert(value==nil or type(value)=="table","Stored profile is not a table")
 local data=copy(value or {})
 for k,v in defaults() do
  if type(data[k])~=type(v) then data[k]=copy(v) end
  if type(v)=="number" and (data[k]~=data[k] or math.abs(data[k])==math.huge or data[k]<v) then data[k]=v end
 end
 data.SchemaVersion=2
 data._Session=nil
 return data
end
local function retries(fn)
 local err
 for attempt=1,3 do
  local ok,result=pcall(fn)
  if ok then return true,result end
  err=result
  if attempt<3 then task.wait(attempt) end
 end
 return false,err
end
local function key(player) return "player_"..player.UserId end
local function status(player,text,persistent)
 player:SetAttribute("DataStatus",text)
 player:SetAttribute("DataPersistent",persistent)
end
function DataService.Load(player)
 if loading[player] or sessions[player] or shuttingDown then return end
 loading[player]=true
 status(player,"Loading",false)
 local token=HttpService:GenerateGUID(false)
 local data,err,ok,locked
 for attempt=1,5 do
  locked=false
  ok,err=retries(function()
   assert(store,"Data store unavailable")
   return store:UpdateAsync(key(player),function(old)
    local lease=type(old)=="table" and old._Session
    if lease and lease.Id~=token and type(lease.ExpiresAt)=="number" and lease.ExpiresAt>os.time() then
     locked=true
     return nil
    end
    local nextData=reconcile(old)
    nextData._Session={Id=token,ExpiresAt=os.time()+LEASE_SECONDS}
    return nextData
   end)
  end)
  if ok and err then data=err;break end
  if not locked or attempt==5 or not player.Parent then break end
  task.wait(2)
 end
 loading[player]=nil
 if data then
  profiles[player]=reconcile(data)
  sessions[player]={Token=token,Persistent=true,Busy=false,Closing=false}
  status(player,"Saved",true)
  player:SetAttribute("LastSaveAt",os.time())
 elseif RunService:IsStudio() and not locked then
  -- Explicit preview only: never acknowledges a purchase or writes defaults over real data.
  profiles[player]=defaults()
  sessions[player]={Persistent=false,Busy=false,Closing=false}
  status(player,"Session only - enable Studio API access",false)
  warn("[DataService] Studio data access unavailable; progress is session-only. "..tostring(err))
 else
  status(player,"Load failed",false)
  player:Kick(if locked then "Your previous server is still saving. Please rejoin in a moment." else "Saved progress could not be loaded. Please rejoin; your existing data has not been replaced.")
  return
 end
 if not player.Parent or shuttingDown then
  DataService.Save(player,true)
  profiles[player],sessions[player]=nil,nil
  return
 end
 loadedEvent:Fire(player,profiles[player])
end
function DataService.Get(player)
 local session=sessions[player]
 return if session and not session.Closing then profiles[player] else nil
end
function DataService.Save(player,release)
 local session=sessions[player]
 if not session or not profiles[player] or not session.Persistent then return false end
 if release then session.Closing=true end
 -- Snapshot is taken after waiting: stale autosaves cannot overwrite newer purchases.
 while session.Busy do task.wait() end
 if session.Released then return session.LastResult==true end
 session.Busy=true
 local snapshot=copy(profiles[player])
 snapshot.SavedAt=os.time()
 snapshot._Session=if release then nil else {Id=session.Token,ExpiresAt=os.time()+LEASE_SECONDS}
 status(player,"Saving",true)
 local lost=false
 local ok,result=retries(function()
  return store:UpdateAsync(key(player),function(old)
   if type(old)~="table" or type(old._Session)~="table" or old._Session.Id~=session.Token then
    lost=true
    return nil
   end
   return snapshot
  end)
 end)
 local saved=ok and result~=nil and not lost
 session.LastResult=saved
 if release and saved then session.Released=true end
 session.Busy=false
 if saved then
  player:SetAttribute("LastSaveAt",snapshot.SavedAt)
  status(player,"Saved",true)
 else
  status(player,"Save retry pending",not lost)
  warn("[DataService] Save failed for "..player.UserId..": "..tostring(result))
  if lost and player.Parent then player:Kick("Your data session moved to another server. Please rejoin to reload your latest progress.") end
 end
 return saved
end
function DataService.HasReceipt(profile,purchaseId) return profile.Receipts[tostring(purchaseId)]==true end
function DataService.AddReceipt(profile,purchaseId)
 -- Keep the receipt ledger; pruning old IDs can award a retried receipt twice.
 local id=tostring(purchaseId)
 if profile.Receipts[id] then return end
 profile.Receipts[id]=true
 table.insert(profile.ReceiptOrder,id)
end
function DataService.Start()
 if started then return end
 started=true
 local ok,result=pcall(function() return DataStoreService:GetDataStore(STORE_NAME) end)
 if ok then store=result end
 Players.PlayerAdded:Connect(DataService.Load)
 for _,player in Players:GetPlayers() do task.spawn(DataService.Load,player) end
 Players.PlayerRemoving:Connect(function(player)
  DataService.Save(player,true)
  profiles[player],sessions[player]=nil,nil
 end)
 game:BindToClose(function()
  shuttingDown=true
  local pending=0
  for player in profiles do
   pending+=1
   task.spawn(function() DataService.Save(player,true);pending-=1 end)
  end
  local deadline=os.clock()+26
  while pending>0 and os.clock()<deadline do task.wait() end
 end)
 task.spawn(function()
  while not shuttingDown do
   task.wait(AUTOSAVE_SECONDS)
   for player,session in sessions do
    if not session.Closing then task.spawn(DataService.Save,player) end
   end
  end
 end)
end
return DataService


```


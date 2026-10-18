local Players=game:GetService("Players")
local TS=game:GetService("TeleportService")
local MS=game:GetService("MemoryStoreService")
local HTTP=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local C=require(game.ReplicatedStorage.SurvivalRun.Config)
local T={}
local registry=MS:GetHashMap(C.RegistryName)
local pending={}
local failed
local started=false
-- No access code is sent to clients. Newer engines use the reserved id.
function T.Options(privateId,accessCode,party)
    local options=Instance.new("TeleportOptions")
    local modern=pcall(function()options.ReservedServerId=privateId end)
    if not modern then options.ReservedServerAccessCode=accessCode end
    options:SetTeleportData({Protocol=C.Protocol,PartyId=party})
    return options
end
function T.CheckManifest(record,userId,placeId)
    if type(record)~="table" or record.PlaceId~=placeId or type(record.Users)~="table" or type(record.PartyId)~="string" or #record.PartyId>80 or type(record.ExpiresAt)~="number" or record.ExpiresAt<os.time()then return false end
    local cap=({Solos=1,Duos=2,Trios=3,Squads=4})[record.Mode]
    if not cap or #record.Users<1 or #record.Users>cap then return false end
    local seen={}
    for _,id in record.Users do if type(id)~="number" or id%1~=0 or seen[id]then return false end;seen[id]=true end
    local index=table.find(record.Users,userId);if not index then return false end
    return {PartyId=record.PartyId,Size=#record.Users,Index=index,Mode=record.Mode}
end
function T.Validate(p)
    if RunService:IsStudio()then return nil end
    if game.PrivateServerId=="" or game.PrivateServerOwnerId~=0 then return nil end
    local ok,record=pcall(function()return registry:GetAsync(game.PrivateServerId)end)
    if not ok then return false end
    return T.CheckManifest(record,p.UserId,game.PlaceId)
end
function T.Depart(members,mode,onFailure)
    assert(not RunService:IsStudio(),"Studio uses an explicitly labelled local intro preview")
    local party=HTTP:GenerateGUID(false)
    local ok,accessCode,privateId=pcall(function()return TS:ReserveServerAsync(game.PlaceId)end)
    if not ok or type(privateId)~="string" or privateId=="" then onFailure(members,"Server reservation failed. Step out and try again.");return false end
    local users={};for _,p in members do table.insert(users,p.UserId)end
    local stored=pcall(function()registry:SetAsync(privateId,{PartyId=party,Users=users,Mode=mode,PlaceId=game.PlaceId,ExpiresAt=os.time()+C.RegistryTTL},C.RegistryTTL)end)
    if not stored then onFailure(members,"Session registration failed. Step out and try again.");return false end
    local options=T.Options(privateId,accessCode,party)
    for _,p in members do pending[p]={Options=options,Attempts=0,Failure=onFailure,Party=party}end
    local success=false
    for attempt=1,3 do
        for _,p in members do if pending[p]then pending[p].Attempts=attempt end end
        success=pcall(function()TS:TeleportAsync(game.PlaceId,members,options)end)
        if success then break end
        task.wait(attempt)
    end
    if not success then
        for _,p in members do pending[p]=nil end
        onFailure(members,"Teleport failed. Step out and try again.")
    end
    if success then task.delay(45,function()
        local stranded={};for _,p in members do if pending[p] and p.Parent==Players then pending[p]=nil;table.insert(stranded,p)end end
        if #stranded>0 then onFailure(stranded,"Teleport timed out. Step out and try again.")end
    end)end
    return success
end
function T.Return(p,onFailure)
    if RunService:IsStudio()or game.PrivateServerId==""then return false end
    local options=Instance.new("TeleportOptions")
    pending[p]={Options=options,Attempts=1,Failure=onFailure or function()end}
    local ok=pcall(function()TS:TeleportAsync(game.PlaceId,{p},options)end)
    if not ok then pending[p]=nil end
    return ok
end
function T.Start()
    if started then return end;started=true
    TS.TeleportInitFailed:Connect(function(p,_,_,placeId)
        local rec=pending[p]
        if not rec or placeId~=game.PlaceId then return end
        if rec.Retrying then return end
        rec.Retrying=true
        task.delay(2,function()
            if pending[p]~=rec or p.Parent~=Players then return end
            rec.Attempts+=1;rec.Retrying=false
            if rec.Attempts<=3 then
                local ok=pcall(function()TS:TeleportAsync(game.PlaceId,{p},rec.Options)end)
                if ok then return end
            end
            pending[p]=nil;rec.Failure({p},"Teleport interrupted. Step out and try again.")
        end)
    end)
    Players.PlayerRemoving:Connect(function(p)pending[p]=nil end)
end
return T


local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local MarketplaceService=game:GetService("MarketplaceService")
local shared=game.ReplicatedStorage.ClawEmpire.Shared
local Config=require(shared.Config)
local Big=require(shared.BigNumber)
local Economy=require(shared.Economy)
local World=require(script.Parent.World)
local ProfileStore=require(script.Parent.ProfileStore)
local container=game.ReplicatedStorage.ClawEmpire
local remotes=Instance.new("Folder"); remotes.Name="Remotes"; remotes.Parent=container
local request=Instance.new("RemoteEvent"); request.Name="Request"; request.Parent=remotes
local update=Instance.new("RemoteEvent"); update.Name="Update"; update.Parent=remotes
local plots=Instance.new("Folder"); plots.Name="ClawEmpirePlots"; plots.Parent=workspace
local preview=workspace:FindFirstChild("ClawEmpirePreview"); if preview then preview:Destroy() end
local sessionOnly=RunService:IsStudio() and Config.StudioSessionOnly
local backend
if sessionOnly then
    local records={}
    backend={UpdateAsync=function(_,key,transform)
        local nextValue=transform(ProfileStore.copy(records[key]))
        if nextValue==nil then return nil end
        records[key]=ProfileStore.copy(nextValue); return ProfileStore.copy(nextValue)
    end}
else backend=game:GetService("DataStoreService"):GetDataStore("ClawEmpire_Build01_v1") end
local store=ProfileStore.new(backend)
local active,occupied={},{}
local rng=Random.new()
-- Closed purchase gate: even stray unresolved receipts are not acknowledged.
MarketplaceService.ProcessReceipt=function() return Enum.ProductPurchaseDecision.NotProcessedYet end
local function send(player,message,kind)
    local p=active[player]; if not p or player.Parent~=Players then return end
    update:FireClient(player,{state=p.session.data,attempts=p.attempts,
        nextAttempt=math.max(0,Config.AttemptRefillSeconds-(os.clock()-p.lastRefill)),
        round=p.round and {id=p.round.id,phase=p.round.phase,x=p.round.x,z=p.round.z,
            remaining=math.max(0,p.round.expires-os.clock()),targets=p.round.targets} or false,
        offset=p.plot.offset,sessionOnly=sessionOnly,message=message,kind=kind})
end
local function healthy(p)
    return not p.leaving and not p.session.closed and p.session.expires>os.time()+20
end
local function inside(player,p)
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    return root and hum and hum.Health>0 and (root.Position-p.plot.offset).Magnitude<70
end
local function shelf(p)
    World.shelves(p.plot,p.session.data)
    p.plot.income.Text="$"..Big.format(Economy.rate(p.session.data)).." / SEC"
end
local function startRound(player,p)
    if p.round then return false,"Finish or leave your current claw round." end
    if p.attempts<1 then return false,"Free plays refill every 12 seconds. No purchase needed." end
    if #p.session.data.inventory>=Config.Storage then return false,"Storage full (40). You can still rearrange your shelves." end
    p.attempts-=1
    local targets={}
    for z=-2,2,2 do for x=-3,3,3 do
        local species=Economy.roll(p.session.data,rng:NextNumber())
        if x==0 and z==0 and p.session.data.totalCatches==0 then species="duck" end
        table.insert(targets,{x=x,z=z,species=species})
    end end
    p.round={id=HttpService:GenerateGUID(false),phase="aim",x=0,z=0,dx=0,dz=0,
        expires=os.clock()+Config.RoundSeconds,targets=targets,tier=p.session.data.machine}
    World.targets(p.plot,p.round.tier,targets); World.aim(p.plot,p.round.tier,0,0)
    return true,if p.session.data.totalCatches==0 then "Aim, then DROP! Your first duck is in the center."
        else "Aim over a plushie, then DROP! These plays are always free."
end
local function finishRound(player,p)
    local round=p.round
    if not round or round.phase~="aim" then return false,"No active claw" end
    if os.clock()>round.expires then p.round=nil; return false,"Round finished. Free plays recharge automatically." end
    round.phase="drop"; round.dx=0; round.dz=0
    local best,distance=nil,math.huge
    for _,t in ipairs(round.targets) do
        local d=Vector2.new(t.x-round.x,t.z-round.z).Magnitude
        if d<distance then best,distance=t,d end
    end
    round.prize=if distance<=1.4 then best.species else nil
    round.started=os.clock(); send(player,"Claw dropping...","drop")
    task.delay(Config.DropSeconds,function()
        if active[player]~=p or p.round~=round or not healthy(p) then return end
        p.round=nil; World.aim(p.plot,round.tier,0,0)
        if round.prize then
            local ok,item=Economy.grant(p.session.data,round.prize)
            if ok then send(player,"You caught "..Config.plushie(item.species).name.."! Place it on a shelf.","catch")
            else send(player,item,"error") end
        else send(player,"Just missed! Center the claw over a plushie and try again.","miss") end
    end)
    return true,nil
end
request.OnServerEvent:Connect(function(player,action,payload)
    local p=active[player]
    if not p or not healthy(p) or type(action)~="string" then return end
    -- A token bucket covers every action, including malformed/unknown requests.
    local now=os.clock(); p.tokens=math.min(24,p.tokens+(now-p.lastToken)*16); p.lastToken=now
    if p.tokens<1 then return end; p.tokens-=1
    if action=="sync" then send(player); return end
    if not inside(player,p) then send(player,"Return to your own arcade to interact.","error"); return end
    if action=="aim" then
        if not p.round or p.round.phase~="aim" or type(payload)~="table" then return end
        local x,z=payload.x,payload.z
        if type(x)~="number" or type(z)~="number" or x~=x or z~=z or math.abs(x)>1 or math.abs(z)>1 then return end
        p.round.dx=x; p.round.dz=z; p.round.inputAt=now; return
    end
    if now-p.lastAction<0.18 then return end; p.lastAction=now
    local ok,message=false,"Unknown action"
    if action=="start" then ok,message=startRound(player,p)
    elseif action=="drop" then ok,message=finishRound(player,p)
    elseif action=="cancel" then
        if p.round and p.round.phase=="drop" then return end
        p.round=nil; ok,message=true,"Claw round ended. Plays refill for free."
    elseif action=="collect" then ok,message=Economy.collect(p.session.data)
    elseif action=="display" or action=="stow" or action=="sell" then
        if type(payload)~="number" or payload~=payload or payload%1~=0 or payload<1 or payload>1e12 then return end
        ok,message=Economy[action](p.session.data,payload); if ok then shelf(p) end
    elseif action=="unlock" then
        if p.round then ok,message=false,"Finish your round before unlocking a machine."
        else ok,message=Economy.unlock(p.session.data); if ok then World.unlock(p.plot,p.session.data.machine) end end
    elseif action=="upgrade" then
        if type(payload)~="string" or #payload>20 then return end
        ok,message=Economy.upgrade(p.session.data,payload); if ok then shelf(p) end
    end
    send(player,message,if ok then "success" else "error")
end)
local function join(player)
    local slot
    for i=1,Config.MaxPlayers do if not occupied[i] then occupied[i]=player; slot=i; break end end
    if not slot then player:Kick("This alpha has four arcade plots. Please join another server."); return end
    local session,err
    local token=HttpService:GenerateGUID(false) -- Reuse after an ambiguous committed load.
    for attempt=1,3 do
        session,err=store:load("u_"..player.UserId,token)
        if session then break end
        task.wait(attempt)
    end
    if not session or player.Parent~=Players then
        occupied[slot]=nil
        if session then store:save(session,true) end
        if player.Parent==Players then player:Kick(err or "Profile load interrupted") end
        return
    end
    local plot=World.build(plots,"Arcade_"..player.UserId,Vector3.new((slot-1)*140,0,0))
    local p={session=session,plot=plot,slot=slot,attempts=Config.FreeAttempts,lastRefill=os.clock(),
        tokens=24,lastToken=os.clock(),lastAction=0,lastSave=os.clock(),tickAt=os.clock()}
    active[player]=p; player.RespawnLocation=plot.spawn
    local function spawnCharacter(character)
        local root=character:WaitForChild("HumanoidRootPart",10)
        if root then character:PivotTo(CFrame.new(plot.spawn.Position+Vector3.new(0,4,0))) end
    end
    player.CharacterAdded:Connect(function(char)
        if p.round and p.round.phase~="drop" then p.round=nil end
        spawnCharacter(char)
    end)
    if player.Character then task.spawn(spawnCharacter,player.Character) end
    shelf(p)
    for i=2,session.data.machine do World.unlock(plot,i) end
    send(player,"Welcome! Catch your first plushie, then put it on display.","welcome")
    print("CME_PROFILE_READY",player.UserId,if sessionOnly then "STUDIO_SESSION_ONLY" else "PERSISTENT")
end
local function leave(player)
    local p=active[player]; if not p or p.leaving then return end
    p.leaving=true; p.round=nil
    local deadline=os.clock()+12
    while p.session.saving and os.clock()<deadline do task.wait(0.1) end
    local saved=false
    for attempt=1,3 do
        saved=store:save(p.session,true)
        if saved then break end; task.wait(attempt)
    end
    if not saved then warn("CME_FINAL_SAVE_FAILED",player.UserId) end
    active[player]=nil; occupied[p.slot]=nil; p.plot.root:Destroy()
end
Players.PlayerAdded:Connect(join); Players.PlayerRemoving:Connect(leave)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
task.spawn(function()
    while true do
        task.wait(0.1)
        local now=os.clock()
        for player,p in pairs(active) do
            if p.leaving then continue end
            if not healthy(p) then
                player:Kick("Saving is paused; your last saved arcade is protected. Please rejoin."); continue
            end
            local dt=math.min(now-p.tickAt,1); p.tickAt=now
            Economy.tick(p.session.data,dt)
            if now-p.lastRefill>=Config.AttemptRefillSeconds then
                local refills=math.floor((now-p.lastRefill)/Config.AttemptRefillSeconds)
                p.attempts=math.min(Config.FreeAttempts,p.attempts+refills)
                p.lastRefill+=refills*Config.AttemptRefillSeconds
            end
            local round=p.round
            if round then
                if round.phase=="aim" then
                    if now>round.expires or not inside(player,p) then p.round=nil
                    else
                        local dx,dz=round.dx,round.dz
                        if not round.inputAt or now-round.inputAt>0.4 then dx,dz=0,0 end
                        local magnitude=math.max(1,Vector2.new(dx,dz).Magnitude)
                        local speed=2.5+0.5*p.session.data.upgrades.speed
                        round.x=math.clamp(round.x+dx/magnitude*speed*dt,-4,4)
                        round.z=math.clamp(round.z+dz/magnitude*speed*dt,-3,3)
                        World.aim(p.plot,round.tier,round.x,round.z)
                    end
                else
                    local progress=math.clamp((now-round.started)/Config.DropSeconds,0,1)
                    local depth=math.sin(progress*math.pi)*6
                    World.aim(p.plot,round.tier,round.x,round.z,15-depth)
                end
            end
            p.lastPush=p.lastPush or 0
            if now-p.lastPush>=0.2 then p.lastPush=now; send(player) end
            if now-p.lastSave>=30 and not p.session.saving then
                p.lastSave=now
                task.spawn(function()
                    local ok,saveErr=store:save(p.session,false)
                    if not ok then warn("CME_AUTOSAVE",saveErr); send(player,"Save retry pending. Please stay connected.","error") end
                end)
            end
        end
    end
end)
game:BindToClose(function()
    local pending=0
    for player in pairs(active) do pending+=1; task.spawn(function() leave(player); pending-=1 end) end
    local deadline=os.clock()+25
    while pending>0 and os.clock()<deadline do task.wait(0.1) end
end)
print("CME_SERVER_READY",Config.Build)

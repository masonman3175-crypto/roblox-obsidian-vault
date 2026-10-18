local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Pathfinding=game:GetService("PathfindingService")
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local C=require(game.ReplicatedStorage.SurvivalRun.Config)
local World=require(script.Parent.World)
local S={}
local records,zombies={},{}
local started=false
local root,houses,infected
local activeParty
local function state(p,key,value)if p:GetAttribute(key)~=value then p:SetAttribute(key,value)end end
local function living(p)local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");return c,h,c and c:FindFirstChild("HumanoidRootPart")end
local function clearTools(p)
    local c=p.Character;local pack=p:FindFirstChildOfClass("Backpack")
    for _,container in {c,pack}do if container then for _,v in container:GetChildren()do if v:IsA("Tool")then v:Destroy()end end end end
end
local function pistol(p)
    clearTools(p)
    for _,t in game.StarterPack:GetChildren()do if t:GetAttribute("ReferenceWeaponId")==C.StartingWeapon then
        local copy=t:Clone();copy.Parent=p:FindFirstChildOfClass("Backpack");local _,h=living(p);if h then h:EquipTool(copy)end;return copy
    end end
end
local function sound(parent,id,volume)
    local s=Instance.new("Sound");s.SoundId=id;s.Volume=volume;s.RollOffMinDistance=8;s.RollOffMaxDistance=90;s.Parent=parent;s:Play();Debris:AddItem(s,9)
end
function S.Remove(p)
    local rec=records[p];records[p]=nil
    state(p,"CutsceneActive",false);state(p,"SurvivalActive",false);state(p,"InArena",false)
    local _,h,r=living(p);if h then h.PlatformStand=false;h.AutoRotate=true;h.WalkSpeed=14 end;if r then r.Anchored=false;r:SetNetworkOwnershipAuto()end
    p.ReplicationFocus=nil
    if rec and rec.House then rec.House.Model:Destroy();if rec.Focus then rec.Focus:Destroy()end end
    if next(records)==nil then
        activeParty=nil
        for z in zombies do if z.Parent then z:Destroy()end end;table.clear(zombies)
    end
end
function S.CanPreview()
    return not activeParty or next(records)==nil
end
local function spawnInfected(party)
    if next(zombies)then return end
    local count=0
    for i,porch in C.Porches do for side=-1,1,2 do
        if activeParty~=party or next(records)==nil then return end
        local position=Vector3.new(porch.X+side*4,4,13+(i%2)*3)
        local z=World.Zombie(game.ServerStorage.SurvivalZombieRig,infected,position,party)
        local hum=z.Humanoid;hum.MaxHealth=C.ZombieHealth;hum.Health=C.ZombieHealth;hum.WalkSpeed=C.ZombieSpeed
        local rec={Hum=hum,Root=z.HumanoidRootPart,NextPath=0,LastAttack=-10};zombies[z]=rec;count+=1
        if count%2==0 then task.wait()end
        local previous=hum.Health
        hum.HealthChanged:Connect(function(value)if value<previous then z:SetAttribute("ZombieHitAt",workspace:GetServerTimeNow())end;previous=value end)
        hum.Died:Connect(function()
            z:SetAttribute("ZombieAction","Dead");z:SetAttribute("ZombieDeathAt",workspace:GetServerTimeNow());rec.Root.Anchored=true
            local id=z:GetAttribute("LastDamageUserId");local killer=typeof(id)=="number" and Players:GetPlayerByUserId(id)
            if killer and records[killer] and os.clock()-(z:GetAttribute("LastDamageClock")or -1e9)<12 then killer:SetAttribute("ZombieKills",(killer:GetAttribute("ZombieKills")or 0)+1)end
            task.delay(2,function()if z.Parent then for _,v in z:GetDescendants()do if v:IsA("BasePart")then TweenService:Create(v,TweenInfo.new(1),{Transparency=1}):Play()end end end end)
            Debris:AddItem(z,3.2)
        end)
    end end
    root:SetAttribute("SpawnedZombies",count)
end
function S.Begin(p,party,index,size,onReady)
    S.Remove(p)
    activeParty=party
    local c,h,r=living(p);if not c or not h or not r then return false end
    local house=World.House(houses,index,p.UserId,C.HouseCenters[index])
    local rec={House=house,Party=party,Index=index,Start=workspace:GetServerTimeNow(),Phase="Waking"}
    records[p]=rec
    local focus=Instance.new("Part");focus.Name="RevealFocus_"..p.UserId;focus.Size=Vector3.one;focus.Transparency=1;focus.CanCollide=false;focus.CanTouch=false;focus.CanQuery=false;focus.Anchored=true;focus.Position=C.Porches[index];focus.Parent=root;rec.Focus=focus;p.ReplicationFocus=focus
    state(p,"SurvivalActive",true);state(p,"InArena",false);state(p,"HouseIndex",index);state(p,"HouseCenter",C.HouseCenters[index]);state(p,"PorchPosition",C.Porches[index])
    state(p,"CoopPartyId",party);state(p,"CoopPartySize",size);state(p,"PreferredWeapon","W3")
    state(p,"IntroStartedAt",rec.Start);state(p,"IntroStage","Waking");state(p,"CutsceneActive",true)
    state(p,"InLobby",false);state(p,"InMenu",true);state(p,"LobbyPhase","Intro");state(p,"MenuClientOpen",false)
    h:UnequipTools();clearTools(p);r.Anchored=true;h.PlatformStand=true;h.AutoRotate=false
    c:PivotTo(house.Lie);r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
    local shield=c:FindFirstChild("LobbyShield");if not shield then shield=Instance.new("ForceField");shield.Name="LobbyShield";shield.Visible=false;shield.Parent=c end
    task.defer(spawnInfected,party)
    house.Prompt.Triggered:Connect(function(who)
        if who~=p or records[p]~=rec or p:GetAttribute("CutsceneActive")or not p:GetAttribute("SurvivalActive")then return end
        local character,hum,hrp=living(p);if not hrp or hum.Health<=0 or (hrp.Position-house.Prompt.Parent.Position).Magnitude>9 then return end
        character:PivotTo(CFrame.lookAt(C.Porches[index],C.Porches[index]+Vector3.new(0,0,-10)))
        hrp.AssemblyLinearVelocity=Vector3.zero;state(p,"InArena",true);state(p,"SurvivalObjective","Stay together. Clear the infected.")
        local ff=character:FindFirstChild("LobbyShield");if ff then ff:Destroy()end
        local safe=Instance.new("ForceField");safe.Visible=false;safe.Parent=character;Debris:AddItem(safe,2)
    end)
    task.delay(2.4,function()
        if records[p]~=rec or p.Character~=c then return end
        sound(house.WindowPart,C.CrashSound,.3)
        state(p,"IntroStage","Ruckus");TweenService:Create(r,TweenInfo.new(1.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=house.Stand}):Play()
    end)
    task.delay(4.2,function()
        if records[p]~=rec or p.Character~=c then return end
        state(p,"IntroStage","CheckWindow");h.PlatformStand=false;r.Anchored=false;r:SetNetworkOwner(nil);h.WalkSpeed=7;h:MoveTo(house.Window.Position)
    end)
    task.delay(7.2,function()if records[p]==rec then
        state(p,"IntroStage","Reveal");h:MoveTo(r.Position);r.Anchored=true;sound(house.WindowPart,C.GrowlSound,.22)
    end end)
    task.delay(C.IntroDuration,function()
        if records[p]~=rec or p.Character~=c or h.Health<=0 then return end
        p.ReplicationFocus=nil
        c:PivotTo(house.Window);r.Anchored=false;r:SetNetworkOwnershipAuto();h.PlatformStand=false;h.AutoRotate=true;h.WalkSpeed=14
        if onReady then onReady()end
        state(p,"CutsceneActive",false);state(p,"IntroStage","Complete");state(p,"InMenu",false);state(p,"LobbyPhase","Deployed")
        state(p,"SurvivalObjective","Your pistol is ready. Use your front door to go outside.")
        pistol(p)
    end)
    return true
end
local function sight(z,target)
    local params=RaycastParams.new();params.FilterDescendantsInstances={z};params.RespectCanCollide=true
    local from=z.HumanoidRootPart.Position;local r=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    local hit=workspace:Raycast(from,r.Position-from,params)
    return not hit or hit.Instance:IsDescendantOf(target.Character)
end
local function updateZombie(z,rec,now)
    if not z.Parent then zombies[z]=nil;return end
    if rec.Hum.Health<=0 then return end
    local nearest,best
    for p,run in records do
        local _,h,r=living(p)
        if h and h.Health>0 and r and p:GetAttribute("InArena") and not p:GetAttribute("CutsceneActive") and run.Party==z:GetAttribute("PartyId")then
            local distance=(r.Position-rec.Root.Position).Magnitude
            if distance<110 and (not best or distance<best)then nearest,best=p,distance end
        end
    end
    if not nearest then z:SetAttribute("ZombieAction","Idle");return end
    local _,h,r=living(nearest)
    if best<C.ZombieAttackRange and sight(z,nearest)then
        rec.Hum:MoveTo(rec.Root.Position)
        if now-rec.LastAttack>1.5 then
            rec.LastAttack=now;z:SetAttribute("ZombieAction","Attack");z:SetAttribute("ZombieAttackAt",workspace:GetServerTimeNow())
            task.delay(.43,function()
                local _,targetHum,targetRoot=living(nearest)
                if z.Parent and rec.Hum.Health>0 and targetHum and targetRoot and targetHum.Health>0 and nearest:GetAttribute("InArena") and not nearest:GetAttribute("CutsceneActive") and (targetRoot.Position-rec.Root.Position).Magnitude<C.ZombieAttackRange+.5 and sight(z,nearest)then targetHum:TakeDamage(C.ZombieDamage)end
            end)
        end
    else
        z:SetAttribute("ZombieAction","Walk")
        if sight(z,nearest)then rec.Hum:MoveTo(r.Position)
        elseif now>rec.NextPath and not rec.PathBusy then
            rec.NextPath=now+1.6;rec.PathBusy=true
            task.spawn(function()
                local path=Pathfinding:CreatePath({AgentRadius=1.6,AgentHeight=5,AgentCanJump=true})
                local ok=pcall(function()path:ComputeAsync(rec.Root.Position,r.Position)end)
                if ok and path.Status==Enum.PathStatus.Success then rec.Points=path:GetWaypoints();rec.Point=2 end
                rec.PathBusy=false
            end)
        elseif rec.Points and rec.Points[rec.Point]then
            local point=rec.Points[rec.Point]
            if (point.Position-rec.Root.Position).Magnitude<3 then rec.Point+=1 else rec.Hum:MoveTo(point.Position);if point.Action==Enum.PathWaypointAction.Jump then rec.Hum.Jump=true end end
        end
    end
    if now>(rec.NextGroan or 0)then rec.NextGroan=now+math.random(8,14);sound(z.Head,C.GrowlSound,.12)end
end
function S.State(p)
    local count=0;for _,rec in zombies do if rec.Hum.Health>0 then count+=1 end end
    local rec=p and records[p]
    return {Active=rec~=nil,House=rec and rec.Index,Party=rec and rec.Party,Zombies=count,Preview=RunService:IsStudio()}
end
function S.Start()
    if started then return end;started=true
    root=Instance.new("Folder");root.Name="SurvivalRun";root.Parent=workspace
    houses=Instance.new("Folder");houses.Name="Houses";houses.Parent=root
    infected=Instance.new("Folder");infected.Name="Infected";infected.Parent=root
    Players.PlayerRemoving:Connect(S.Remove)
    local elapsed=0;RunService.Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed<.16 then return end;elapsed=0;for z,rec in zombies do updateZombie(z,rec,os.clock())end end)
    local ctrl=Instance.new("BindableFunction");ctrl.Name="Control";ctrl.OnInvoke=function(p,action)
        if action=="State"then return S.State(p)
        elseif action=="EncounterQA" and RunService:IsStudio() and records[p] then
            for z in zombies do if z.Parent then z:Destroy()end end;table.clear(zombies)
            spawnInfected(records[p].Party);return true
        elseif action=="ExitHouse"then
            local rec=records[p];if not rec then return false end
            local c,h,r=living(p);if not h or h.Health<=0 or p:GetAttribute("CutsceneActive")then return false end
            c:PivotTo(CFrame.lookAt(C.Porches[rec.Index],C.Porches[rec.Index]+Vector3.new(0,0,-10)));r.AssemblyLinearVelocity=Vector3.zero;p:SetAttribute("InArena",true)
            local ff=c:FindFirstChild("LobbyShield");if ff then ff:Destroy()end
            return true
        end
    end;ctrl.Parent=script.Parent
end
return S


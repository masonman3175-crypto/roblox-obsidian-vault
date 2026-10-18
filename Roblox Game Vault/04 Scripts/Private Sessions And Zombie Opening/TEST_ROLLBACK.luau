local actualGame=game
local fixture=Instance.new("Folder");fixture.Name="PrivateRunIsolatedRollbackQA";fixture.Parent=actualGame.ServerStorage
local function ensure(path,class)local o=fixture;local parts=string.split(path,".");for i,key in parts do local child=o:FindFirstChild(key);if not child then child=Instance.new(i==#parts and (class or "ModuleScript")or "Folder");child.Name=key;child.Parent=o end;o=child end;return o end
local baseline={
[ [====[ReplicatedStorage.LobbySystem.Config]====] ]=[====[local C = {
    TeamName = "Survivors",
    TeamColor = BrickColor.new("Earth green"),
    LobbyCenter = Vector3.new(1000, 0, 0),
    LobbySpawn = CFrame.lookAt(Vector3.new(1000, 4.5, 20), Vector3.new(1000, 4.5, -5)),
    ArenaSpawn = CFrame.lookAt(Vector3.new(0, 4.6, 0), Vector3.new(0, 4.6, -15)),
    Countdown = 15,
    ScanInterval = .2,
    Modes = {
        {Id="Solos", Size=1, X=-63, Color=Color3.fromRGB(75,210,156)},
        {Id="Duos", Size=2, X=-21, Color=Color3.fromRGB(64,170,243)},
        {Id="Trios", Size=3, X=21, Color=Color3.fromRGB(180,125,249)},
        {Id="Squads", Size=4, X=63, Color=Color3.fromRGB(245,173,77)},
    },
}
C.Queues = {}
for _,mode in C.Modes do
    for slot=1,2 do
        table.insert(C.Queues, {
            Id=mode.Id.."_"..slot, Mode=mode.Id, Slot=slot, Size=mode.Size,
            X=mode.X, Z=slot==1 and -9 or 9, Radius=7, Color=mode.Color,
        })
    end
end
return C
]====],
[ [====[ServerScriptService.LobbySystem.Queue]====] ]=[====[-- Pure co-op queue kernel. No Player instances, remotes or world mutations.
local Q={}
Q.__index=Q
function Q.new(modes,countdown)
    local self=setmetatable({Queues={},Membership={},Countdown=countdown},Q)
    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0} end
    return self
end
function Q:Remove(id)
    local mode=self.Membership[id]
    if not mode then return false end
    local q=self.Queues[mode]
    for i,v in q.Members do if v==id then table.remove(q.Members,i);break end end
    q.Deadline=nil;q.Generation+=1
    self.Membership[id]=nil
    return true
end
function Q:Add(id,mode)
    local q=self.Queues[mode]
    if not q then return false,"Unknown queue" end
    if self.Membership[id]==mode then return true end
    if #q.Members>=q.Size then return false,"Queue full" end
    self:Remove(id)
    table.insert(q.Members,id);self.Membership[id]=mode;q.Deadline=nil;q.Generation+=1
    return true
end
function Q:Step(now,eligible)
    local launches={}
    for mode,q in self.Queues do
        local remove={}
        for _,id in q.Members do if not eligible(id,mode) then table.insert(remove,id) end end
        for _,id in remove do self:Remove(id) end
        if #q.Members==q.Size then
            if not q.Deadline then q.Deadline=now+self.Countdown end
            if now>=q.Deadline then
                local members=table.clone(q.Members)
                for _,id in members do self.Membership[id]=nil end
                q.Members={};q.Deadline=nil;q.Generation+=1
                table.insert(launches,{Mode=mode,Members=members})
            end
        else q.Deadline=nil end
    end
    return launches
end
function Q:Snapshot()
    local result={}
    for mode,q in self.Queues do result[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline} end
    return result
end
return Q
]====],
[ [====[ServerScriptService.LobbySystem.Service]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local PhysicsService=game:GetService("PhysicsService")
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local Queue=require(script.Parent.Queue)
local S={}
local states,links={},{}
local queue=Queue.new(C.Queues,C.Countdown)
local queueById={}
for _,descriptor in C.Queues do queueById[descriptor.Id]=descriptor end
local started=false
local world,team,toolRoot
local rejected,launched=0,0
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function charState(p)
    local char=p.Character
    local h=char and char:FindFirstChildOfClass("Humanoid")
    local r=char and char:FindFirstChild("HumanoidRootPart")
    return char,h,r
end
local function inPad(p,mode)
    local s=states[p]
    if not s or s.Phase~="Lobby" then return false end
    local _,h,r=charState(p)
    local pad=world.Queues:FindFirstChild(mode)
    if not h or h.Health<=0 or not r or not pad then return false end
    local point=pad.Zone.CFrame:PointToObjectSpace(r.Position)
    local radius=pad:GetAttribute("Radius") or 7
    return point.X*point.X+point.Z*point.Z<=radius*radius and point.Y>=-2 and point.Y<=10
end
local function region(p)
    for _,m in C.Queues do if inPad(p,m.Id) then return m.Id end end
end
local function setMode(p,id)
    local descriptor=id and queueById[id]
    p:SetAttribute("QueuedQueueId",id or "")
    p:SetAttribute("QueuedMode",descriptor and descriptor.Mode or "")
end
local function haltSlide(p)
    local movement=game.ServerScriptService:FindFirstChild("GameplayMovement")
    local control=movement and movement:FindFirstChild("MovementControl")
    if control then control:Invoke(p,"CancelSlide");control:Invoke(p,"Crouch",false) end
end
local function pivot(p,transform)
    haltSlide(p)
    local char,_,root=charState(p)
    char:PivotTo(transform)
    if root then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
end
local function strip(p,tool)
    local s=states[p]
    if s and s.Phase=="Lobby" and tool:IsA("Tool") then tool.Parent=s.Tools end
end
local function restoreTools(p)
    local s=states[p]
    local backpack=p:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    for _,t in s.Tools:GetChildren() do t.Parent=backpack end
    local char,h=charState(p)
    if char and h then
        local preferred
        for _,t in backpack:GetChildren() do if t:IsA("Tool") and t:GetAttribute("ReferenceWeaponId")==(p:GetAttribute("PreferredWeapon") or "W1") then preferred=t;break end end
        if preferred then h:EquipTool(preferred) end
    end
end
local function phase(p,value)
    local s=states[p];s.Phase=value
    p:SetAttribute("InLobby",value=="Lobby")
    p:SetAttribute("InMenu",value=="Lobby")
    p:SetAttribute("LobbyPhase",value)
    p:SetAttribute("MenuClientOpen",false)
    p.Team=team;p.Neutral=false
    p.RespawnLocation=world.Spawn
end
local function endSurvival(p,s)
    if s.RunStart then s.Best=math.max(s.Best,math.floor(os.clock()-s.RunStart));s.RunStart=nil end
    p:SetAttribute("BestSurvival",s.Best)
end
local function protectLobby(char)
    local force=char:FindFirstChild("LobbyShield")
    if not force then force=Instance.new("ForceField");force.Name="LobbyShield";force.Visible=false;force.Parent=char end
end
function S.Return(p,respawn)
    local s=states[p];if not s then return false end
    endSurvival(p,s)
    queue:Remove(p.UserId);setMode(p,nil)
    s.Blocked=region(p)
    s.Generation+=1
    phase(p,"Lobby")
    p:SetAttribute("CoopPartyId","");p:SetAttribute("CoopPartySize",0);p:SetAttribute("CoopMode","");p:SetAttribute("CoopQueueId","")
    local char,h=charState(p)
    if respawn or not h or h.Health<=0 then
        if s.Busy then return false end
        s.Busy=true
        s.Tools:ClearAllChildren() -- Fresh characters receive a fresh StarterPack; never accumulate duplicates.
        local ok=pcall(function() p:LoadCharacterAsync() end)
        s.Busy=false
        if not ok then p:SetAttribute("LobbyNotice","Spawn retry in progress");task.delay(3,function() if states[p]==s then S.Return(p,true) end end) end
        return ok
    end
    h:UnequipTools()
    for _,t in char:GetChildren() do strip(p,t) end
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then for _,t in backpack:GetChildren() do strip(p,t) end end
    protectLobby(char)
    pivot(p,C.LobbySpawn)
    return true
end
local function deploy(group)
    local members={}
    for _,id in group.Members do
        local p=Players:GetPlayerByUserId(id)
        local s=p and states[p]
        if p then
            local _,h,r=charState(p)
            if s and s.Phase=="Lobby" and h and h.Health>0 and r and inPad(p,group.Mode) then table.insert(members,p) end
        end
    end
    local descriptor=queueById[group.Mode]
    local expected=descriptor and descriptor.Size
    if #members~=expected then for _,p in members do setMode(p,nil) end return false end
    local party=game.HttpService:GenerateGUID(false)
    for _,p in members do
        local s=states[p];s.Generation+=1;s.RunStart=os.clock()
        phase(p,"Deployed");setMode(p,nil)
        p:SetAttribute("CoopPartyId",party);p:SetAttribute("CoopPartySize",#members);p:SetAttribute("CoopMode",descriptor.Mode);p:SetAttribute("CoopQueueId",group.Mode)
        local char=p.Character
        local shield=char:FindFirstChild("LobbyShield");if shield then shield:Destroy() end
        pivot(p,C.ArenaSpawn)
        s.LastSpawn=char:GetPivot().Position
        p:SetAttribute("LastDeploymentSpawn",s.LastSpawn)
        restoreTools(p)
        local protection=Instance.new("ForceField");protection.Name="CoopSpawnShield";protection.Visible=false;protection.Parent=char
        game.Debris:AddItem(protection,5)
        launched+=1
    end
    return true
end
local function character(p,char)
    local s=states[p];if not s then return end
    s.Generation+=1
    phase(p,"Lobby");setMode(p,nil);queue:Remove(p.UserId)
    task.spawn(function()
        local h=char:WaitForChild("Humanoid",10)
        local root=char:WaitForChild("HumanoidRootPart",10)
        if not h or not root or states[p]~=s or p.Character~=char then return end
        local function child(o)
            if o:IsA("BasePart") then o.CollisionGroup="CoopSurvivors" end
            if o:IsA("Tool") then strip(p,o) end
        end
        for _,o in char:GetDescendants() do child(o) end
        char.DescendantAdded:Connect(child)
        protectLobby(char)
        pivot(p,C.LobbySpawn)
        h.WalkSpeed=14
        h.Died:Connect(function()
            if states[p]~=s or p.Character~=char then return end
            endSurvival(p,s)
            queue:Remove(p.UserId);setMode(p,nil)
            phase(p,"Lobby")
            task.delay(2.5,function() if states[p]==s and p.Character==char then S.Return(p,true) end end)
        end)
    end)
end
local function added(p)
    if states[p] then return end
    local tools=Instance.new("Folder");tools.Name=tostring(p.UserId);tools.Parent=toolRoot
    local s={Phase="Lobby",Tools=tools,Best=0,Tokens=4,TokenTime=os.clock(),Generation=0,Links={}}
    states[p]=s
    local function link(signal,fn) local c=signal:Connect(fn);table.insert(s.Links,c);return c end
    p:SetAttribute("PreferredWeapon",p:GetAttribute("PreferredWeapon") or "W1")
    p:SetAttribute("BestSurvival",0);setMode(p,nil);phase(p,"Lobby")
    link(p:GetPropertyChangedSignal("Team"),function() if states[p] and p.Team~=team then p.Team=team;p.Neutral=false end end)
    link(p.CharacterAdded,function(char) character(p,char) end)
    local function backpackAdded(backpack)
        if not backpack:IsA("Backpack") or s.Backpack==backpack then return end
        s.Backpack=backpack
        if s.BackpackLink then s.BackpackLink:Disconnect() end
        s.BackpackLink=backpack.ChildAdded:Connect(function(t) strip(p,t) end)
        for _,t in backpack:GetChildren() do strip(p,t) end
    end
    link(p.ChildAdded,backpackAdded)
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then backpackAdded(backpack) end
    if p.Character then character(p,p.Character) else task.spawn(function() S.Return(p,true) end) end
end
function S.Handle(p,action,...)
    local s=states[p]
    if not s or p.Parent~=Players or type(action)~="string" or #action>12 or select("#",...)~=0 then rejected+=1;return false end
    local now=os.clock()
    s.Tokens=math.min(4,s.Tokens+(now-s.TokenTime)*2);s.TokenTime=now
    if s.Tokens<1 then rejected+=1;return false end
    s.Tokens-=1
    if action=="Leave" and s.Phase=="Lobby" then
        s.Blocked=queue.Membership[p.UserId] or region(p)
        queue:Remove(p.UserId);setMode(p,nil)
        return true
    elseif action=="Return" and s.Phase=="Deployed" then return S.Return(p,false) end
    rejected+=1;return false
end
local function scan()
    for p,s in states do
        local _,h,r=charState(p)
        if s.Phase=="Lobby" and h and h.Health>0 and r then
            local mode=region(p)
            if s.Blocked and mode~=s.Blocked then s.Blocked=nil end
            local old=queue.Membership[p.UserId]
            if old and old~=mode then queue:Remove(p.UserId);setMode(p,nil) end
            if mode and s.Blocked~=mode then
                if queue:Add(p.UserId,mode) then setMode(p,mode) end
            end
            local offset=r.Position-C.LobbyCenter
            if math.abs(offset.X)>110 or math.abs(offset.Z)>83 or r.Position.Y<-10 then pivot(p,C.LobbySpawn) end
        end
    end
    for _,group in queue:Step(workspace:GetServerTimeNow(),function(id,mode)
        local p=Players:GetPlayerByUserId(id);return p and inPad(p,mode) or false
    end) do deploy(group) end
    for _,m in C.Queues do
        local q=queue.Queues[m.Id]
        local pad=world.Queues[m.Id]
        pad:SetAttribute("QueueCount",#q.Members);pad:SetAttribute("DepartureAt",q.Deadline or 0)
    end
end
local function board()
    local rows={}
    for p,s in states do
        local kills=p:GetAttribute("ZombieKills")
        local stats=p:FindFirstChild("leaderstats")
        local stat=stats and stats:FindFirstChild("ZombieKills")
        if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then kills=stat.Value end
        if type(kills)~="number" or kills~=kills or math.abs(kills)>1e9 then kills=0 end
        local best=math.max(s.Best,s.RunStart and math.floor(os.clock()-s.RunStart) or 0)
        p:SetAttribute("BestSurvival",best)
        table.insert(rows,{Name=p.DisplayName,Kills=math.max(0,math.floor(kills)),Best=best,UserId=p.UserId})
    end
    table.sort(rows,function(a,b) if a.Kills~=b.Kills then return a.Kills>b.Kills end if a.Best~=b.Best then return a.Best>b.Best end return a.UserId<b.UserId end)
    local surface=world.Leaderboard.Board.SurfaceGui
    for i=1,10 do
        local row=surface.Rows:FindFirstChild("Row"..i);local data=rows[i]
        row.NameCell.Text=data and string.format("%02d   %s",i,data.Name) or string.format("%02d   —",i)
        row.Kills.Text=data and tostring(data.Kills) or "—"
        row.Best.Text=data and string.format("%02d:%02d",math.floor(data.Best/60),data.Best%60) or "—"
    end
    world:SetAttribute("LobbyPlayers",#rows)
end
function S.GetState(p)
    local s=p and states[p]
    return {Phase=s and s.Phase,Queued=s and queue.Membership[p.UserId],Queues=queue:Snapshot(),Rejected=rejected,Deployed=launched,LastSpawn=s and s.LastSpawn and tostring(s.LastSpawn),Players=world and world:GetAttribute("LobbyPlayers")}
end
function S.Start()
    if started then return end
    started=true
    world=assert(workspace:FindFirstChild("SurvivorLobby"))
    team=assert(game.Teams:FindFirstChild(C.TeamName))
    pcall(function() PhysicsService:RegisterCollisionGroup("CoopSurvivors") end)
    PhysicsService:CollisionGroupSetCollidable("CoopSurvivors","CoopSurvivors",false)
    Players.CharacterAutoLoads=false
    toolRoot=Instance.new("Folder");toolRoot.Name="RuntimeTools";toolRoot.Parent=script.Parent
    for _,p in Players:GetPlayers() do added(p) end
    connect(Players.PlayerAdded,added)
    connect(Players.PlayerRemoving,function(p)
        queue:Remove(p.UserId)
        local s=states[p];if s then
            for _,c in s.Links do c:Disconnect() end
            if s.BackpackLink then s.BackpackLink:Disconnect() end
            s.Tools:Destroy()
        end
        states[p]=nil
    end)
    connect(package.Request.OnServerEvent,S.Handle)
    local elapsed,boardTime=0,0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;boardTime+=dt
        if elapsed>=C.ScanInterval then elapsed=0;scan() end
        if boardTime>=1 then boardTime=0;board() end
    end)
    local control=Instance.new("BindableFunction");control.Name="Control";control.Parent=script.Parent
    control.OnInvoke=function(p,action) if action=="State" then return S.GetState(p) elseif action=="Return" then return S.Return(p,false) end end
end
return S
]====],
[ [====[ReplicatedStorage.LobbySystem.Client]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local p=Players.LocalPlayer
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local M={}
local started,third=false,true
local gui,panel,queueTitle,queueDetail,back,cameraButton,bridge
local links,parts={},{}
local characterLink
local original={Mode=p.CameraMode,Min=p.CameraMinZoomDistance,Max=p.CameraMaxZoomDistance}
local altered=setmetatable({},{__mode="k"})
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function new(class,props,parent)
    local o=Instance.new(class);for k,v in props do o[k]=v end;o.Parent=parent;return o
end
local function text(name,content,size,pos,parent)
    return new("TextLabel",{Name=name,Text=content,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=Color3.fromRGB(233,237,230),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function camera()
    local char=p.Character
    task.spawn(function()
        local h=char and char:WaitForChild("Humanoid",10)
        if not started or p.Character~=char or not h then return end
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h;cam.FieldOfView=72 end
        p.CameraMinZoomDistance=.5
        p.CameraMode=third and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        p.CameraMaxZoomDistance=third and 8 or .5
        p.CameraMinZoomDistance=third and 8 or .5
        UIS.MouseBehavior=third and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled=third
        p:SetAttribute("ThirdPersonView",third)
        cameraButton.Text=third and "CAM: THIRD  [V]" or "CAM: FIRST  [V]"
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not p:GetAttribute("InLobby")) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true) end)
    end)
end
-- Third person only (Cade, 2026-10-17). Claude's ClaudeThirdPerson script handles the shoulder cam + mouse lock.
function M.SetThirdPerson(value)
    third=true
    camera()
end
local function refresh()
    local lobby=p:GetAttribute("InLobby")==true
    back.Visible=not lobby
    panel.Visible=lobby and (p:GetAttribute("QueuedQueueId") or "")~=""
end
local function hookCharacter(char)
    if characterLink then characterLink:Disconnect() end
    parts={}
    local function add(ob) if ob:IsA("BasePart") then table.insert(parts,ob) end end
    for _,ob in char:GetDescendants() do add(ob) end
    characterLink=char.DescendantAdded:Connect(add)
    camera();refresh()
end
function M.GetStats()
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
    return {ThirdPerson=third,Camera=p.CameraMode.Name,MinZoom=p.CameraMinZoomDistance,MaxZoom=p.CameraMaxZoomDistance,
        Banner=gui and gui:FindFirstChild("Status")~=nil,QueueId=p:GetAttribute("QueuedQueueId"),
        ViewmodelVisible=viewport and viewport.Visible,Connections=#links+(characterLink and 1 or 0)}
end
function M.Start()
    if started then return M end
    started=true
    gui=new("ScreenGui",{Name="SurvivorLobbyUI",ResetOnSpawn=false,DisplayOrder=42,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild("PlayerGui"))
    -- No title/status banner; queue information lives above each physical circle.
    panel=new("Frame",{Name="QueuePanel",Size=UDim2.new(.9,0,0,106),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-25),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.08,BorderSizePixel=0},gui)
    new("UISizeConstraint",{MaxSize=Vector2.new(560,106)},panel)
    new("UICorner",{CornerRadius=UDim.new(0,12)},panel)
    new("UIStroke",{Color=Color3.fromRGB(81,196,144),Transparency=.25},panel)
    queueTitle=text("Mode","",UDim2.new(1,-140,0,30),UDim2.fromOffset(16,13),panel)
    queueDetail=text("Countdown","",UDim2.new(1,-140,0,46),UDim2.fromOffset(16,43),panel);queueDetail.TextSize=12
    local leave=new("TextButton",{Name="LeaveQueue",Text="LEAVE",Size=UDim2.fromOffset(100,40),Position=UDim2.new(1,-116,.5,-20),BackgroundColor3=Color3.fromRGB(55,76,67),TextColor3=Color3.fromRGB(240,244,239),Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0},panel)
    new("UICorner",{CornerRadius=UDim.new(0,7)},leave)
    back=new("TextButton",{Name="ReturnToLobby",Text="LOBBY [M]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-212),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},back)
    cameraButton=new("TextButton",{Name="CameraMode",Text="CAM: THIRD  [V]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-174),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},cameraButton)
    connect(leave.Activated,function() package.Request:FireServer("Leave") end)
    connect(back.Activated,function() package.Request:FireServer("Return") end)
    cameraButton.Visible=false
    connect(UIS.InputBegan,function(input,processed)
        if processed or UIS:GetFocusedTextBox() then return end
        if input.KeyCode==Enum.KeyCode.M and not p:GetAttribute("InLobby") then package.Request:FireServer("Return")
        end
    end)
    RunService:BindToRenderStep("SurvivorLobbyCursor",Enum.RenderPriority.Last.Value+1,function()
        if third then
            -- Character/weapon initialization may request first person after our first camera setup.
            -- Reconcile the selected presentation mode after those render passes, without editing combat.
            if p.CameraMode~=Enum.CameraMode.Classic or p.CameraMinZoomDistance~=8 or p.CameraMaxZoomDistance~=8 then
                p.CameraMinZoomDistance=.5;p.CameraMode=Enum.CameraMode.Classic
                p.CameraMaxZoomDistance=8;p.CameraMinZoomDistance=8
            end
            -- The weapon controller remains untouched. Reveal only this client's world avatar in third person.
            for _,ob in parts do if ob.Parent then
                if altered[ob]==nil then altered[ob]=ob.LocalTransparencyModifier end
                ob.LocalTransparencyModifier=0
            end end
        end
        local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
        local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
        if viewport then viewport.Visible=not third end
    end)
    connect(p:GetAttributeChangedSignal("InLobby"),function() refresh();camera() end)
    connect(p:GetAttributeChangedSignal("QueuedQueueId"),refresh)
    connect(p.CharacterAdded,hookCharacter)
    local world=workspace:WaitForChild("SurvivorLobby")
    local elapsed=0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;if elapsed<.1 then return end;elapsed=0
        for _,descriptor in C.Queues do
            local pad=world.Queues[descriptor.Id]
            local count=pad:GetAttribute("QueueCount") or 0
            local deadline=pad:GetAttribute("DepartureAt") or 0
            local remaining=deadline>0 and math.max(0,math.ceil(deadline-workspace:GetServerTimeNow())) or C.Countdown
            local label=pad.LabelAnchor.QueueLabel
            label.Count.Text=count.."/"..descriptor.Size
            label.Timer.Text=remaining.." (sec)"
            if p:GetAttribute("QueuedQueueId")==descriptor.Id then
                queueTitle.Text=string.upper(descriptor.Mode).." "..descriptor.Slot.."  •  "..count.."/"..descriptor.Size
                queueDetail.Text=deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or ("Waiting for "..math.max(0,descriptor.Size-count).." more survivor(s)")
            end
        end
    end)
    bridge=new("BindableFunction",{Name="LobbyPresentationControl"},p:WaitForChild("PlayerScripts"))
    bridge.OnInvoke=function(action,value) if action=="ThirdPerson" then M.SetThirdPerson(value) end return M.GetStats() end
    refresh()
    if p.Character then hookCharacter(p.Character) end
    return M
end
function M.Destroy()
    started=false
    RunService:UnbindFromRenderStep("SurvivorLobbyCursor")
    for _,c in links do c:Disconnect() end;links={}
    if characterLink then characterLink:Disconnect();characterLink=nil end
    for ob,value in altered do if ob.Parent then ob.LocalTransparencyModifier=value end end
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport");if viewport then viewport.Visible=true end
    p.CameraMinZoomDistance=.5;p.CameraMode=original.Mode;p.CameraMaxZoomDistance=original.Max;p.CameraMinZoomDistance=original.Min
    if gui then gui:Destroy() end;if bridge then bridge:Destroy() end
end
return M
]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementConfig]====] ]=[====[return {
    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=.60, CrouchCameraDrop=.95, SlideSpeed=36, SlideEndSpeed=18,
    SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
    StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
    ExhaustionRecovery=15, HipDrop=1.05, CameraDrop=.65,
    SprintFov=8, SlideFov=10, CameraShakeScale=1,
    MinimapHeight=155, MinimapFov=70,
}
]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementClient]====] ]=[====[local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local C=require(script.Parent.MovementConfig)
local p=Players.LocalPlayer
local remote=script.Parent:WaitForChild('MovementRequest')
local M={}
local started=false
local held,toggled,sent,forced=false,false,false,false
local phase,fov,drop,amount=0,0,0,0
local lastOffset=CFrame.identity
local previousMode='Idle'
local slideAge=10
local oldGrounded=true
local landing=0
local char,hum,root
local baseCameraOffset=Vector3.zero
local queuedSlideUntil=0
local queuedSlideStamp,lastChainAttempt=0,-10
local function deployed()
    return char and char.Parent and hum and hum.Health>0 and ((not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')) or p:GetAttribute('InLobby')==true)
end
local function sendSprint(value)
    if value~=sent then sent=value;remote:FireServer('Sprint',value)end
end
function M.Sprint(value)
    if value and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
    forced=value==true;held=forced
    if not value then toggled=false;sendSprint(false)end
    return true
end
function M.Slide()
    if not deployed() then return false end
    if p:GetAttribute('MovementState')=='Sliding' then
        queuedSlideUntil=os.clock()+C.SlideBuffer
        queuedSlideStamp=p:GetAttribute('SlideStartedAt') or 0
        return true
    end
    local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
    if v.Magnitude<C.SlideMinSpeed or hum.FloorMaterial==Enum.Material.Air then return false end
    remote:FireServer('Slide',v.Unit);return true
end
function M.Crouch(value)
    if not deployed()then return false end
    queuedSlideUntil=0
    if value then held,toggled,forced=false,false,false;sendSprint(false)end
    remote:FireServer('Crouch',value==true)
    return true
end
function M.Stance()
    local mode=p:GetAttribute('MovementState')
    if mode=='Sliding' or mode=='Sprinting'then return M.Slide()end
    return M.Crouch(not p:GetAttribute('MovementCrouched'))
end
function M.CancelSlide()queuedSlideUntil=0;remote:FireServer('CancelSlide');return true end
function M.GetState()
    return {Mode=p:GetAttribute('MovementState') or 'Idle',Stamina=p:GetAttribute('MovementStamina') or 100,
        FovOffset=fov,CameraDrop=drop,ShakeDegrees=amount,SlideReadyIn=p:GetAttribute('SlideReadyIn') or 0,
        WalkSpeed=hum and hum.WalkSpeed,Grounded=hum and hum.FloorMaterial~=Enum.Material.Air,
        Crouched=p:GetAttribute('MovementCrouched')==true,
        CameraOffsetY=hum and hum.CameraOffset.Y,SlideBuffered=queuedSlideUntil>os.clock(),
        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y,Pose=require(script.Parent.CharacterPose).State(p)}
end
local function hook(c)
    char=c;hum=c:WaitForChild('Humanoid');root=c:WaitForChild('HumanoidRootPart')
    held,toggled,sent,forced=false,false,false,false
    baseCameraOffset=hum.CameraOffset;queuedSlideUntil=0
    drop,fov,landing=0,0,0
end
function M.Start()
    if started then return M end;started=true
    if p.Character then task.spawn(hook,p.Character)end
    p.CharacterAdded:Connect(hook)
    require(script.Parent.CharacterPose).Start()
    p.CharacterRemoving:Connect(function(c)
        if char==c then
            if hum and hum.Parent then hum.CameraOffset=baseCameraOffset end
            queuedSlideUntil=0;char,hum,root=nil,nil,nil;sendSprint(false)
        end
    end)
    CAS:BindActionAtPriority('GameplaySprint',function(_,state,input)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
        if input.KeyCode==Enum.KeyCode.ButtonL3 and state==Enum.UserInputState.Begin then toggled=not toggled
        elseif state==Enum.UserInputState.Begin then held=true
        elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false;forced=false end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
    CAS:SetTitle('GameplaySprint','SPRINT');CAS:SetPosition('GameplaySprint',UDim2.fromScale(.72,.72))
    CAS:BindActionAtPriority('GameplaySlide',function(_,state)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin then M.Stance()end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.C,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB)
    CAS:SetTitle('GameplaySlide','CROUCH');CAS:SetPosition('GameplaySlide',UDim2.fromScale(.84,.72))
    UIS.InputBegan:Connect(function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.Space and p:GetAttribute('MovementState')=='Sliding'then M.CancelSlide()end
    end)
    UIS.WindowFocusReleased:Connect(function()held,toggled,forced=false,false,false;queuedSlideUntil=0;sendSprint(false)end)
    p:GetAttributeChangedSignal('MovementFireInterrupt'):Connect(function()sendSprint(false)end)
    local bridge=Instance.new('BindableFunction');bridge.Name='MovementControl'
    bridge.OnInvoke=function(action,value)
        if action=='Sprint'then return M.Sprint(value)
        elseif action=='Slide'then return M.Slide()
        elseif action=='Crouch'then return M.Crouch(value)
        elseif action=='CancelSlide'then return M.CancelSlide()end
        return M.GetState()
    end;bridge.Parent=p:WaitForChild('PlayerScripts')
    RunService:BindToRenderStep('GameplayMovementClean',Enum.RenderPriority.Camera.Value-1,function(dt)
        local camera=workspace.CurrentCamera
        if camera then camera.CFrame=camera.CFrame*lastOffset:Inverse()end
        lastOffset=CFrame.identity
        -- CameraOffset is consumed by Roblox's first-person camera this same frame.
        -- The later viewmodel pass sees the lowered camera without double-applying it.
        local live=deployed()
        local target=live and (p:GetAttribute('MovementState')=='Sliding' and C.CameraDrop or p:GetAttribute('MovementCrouched') and C.CrouchCameraDrop or 0) or 0
        local rate=target>drop and 24 or 14
        drop+=(target-drop)*(1-math.exp(-math.min(dt,.05)*rate))
        if not live then drop=0 end
        if hum and hum.Parent then hum.CameraOffset=baseCameraOffset+Vector3.new(0,-drop,0)end
        p:SetAttribute('MovementCameraDrop',drop)
    end)
    RunService:BindToRenderStep('GameplayMovementCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
        dt=math.min(dt,.05)
        local camera=workspace.CurrentCamera;if not camera then return end
        local live=deployed()
        local wants=live and (held or toggled or forced) and not UIS:GetFocusedTextBox()
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            and (p:GetAttribute('InLobby') or (not p:GetAttribute('FPSAiming') and not p:GetAttribute('FPSReloading'))) and not p:GetAttribute('MovementCrouched')
        sendSprint(wants==true)
        local state=live and p:GetAttribute('MovementState') or 'Idle'
        local sprint,slide=state=='Sprinting',state=='Sliding'
        if not live or not wants then queuedSlideUntil=0
        elseif queuedSlideUntil>0 and slide and (p:GetAttribute('SlideStartedAt') or 0)~=queuedSlideStamp then
            queuedSlideUntil=0
        elseif queuedSlideUntil>0 and not slide then
            if os.clock()<=queuedSlideUntil then
                local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
                if hum.FloorMaterial~=Enum.Material.Air and v.Magnitude>=C.SlideMinSpeed and os.clock()-lastChainAttempt>.12 then
                    lastChainAttempt=os.clock();remote:FireServer('Slide',v.Unit)
                end
            else queuedSlideUntil=0 end
        end
        if slide and previousMode~='Sliding'then slideAge=0 end
        slideAge+=dt
        local grounded=live and hum.FloorMaterial~=Enum.Material.Air
        if grounded and not oldGrounded and live then landing=.65 end
        oldGrounded=grounded;landing*=math.exp(-dt*12)
        previousMode=state
        local targetFov=slide and C.SlideFov or sprint and C.SprintFov or p:GetAttribute('MovementCrouched') and -2 or 0
        fov+=(targetFov-fov)*(1-math.exp(-dt*9))
        p:SetAttribute('MovementFovOffset',fov)
        if not live then amount=0;drop=0;fov=0;return end
        if camera.CameraType~=Enum.CameraType.Custom then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=hum end
        if not char:FindFirstChildOfClass('Tool')then camera.FieldOfView+=(72+fov-camera.FieldOfView)*(1-math.exp(-dt*10))end
        phase+=dt*(sprint and 13 or 9)
        local scale=math.clamp(p:GetAttribute('CameraShakeScale') or C.CameraShakeScale,0,1)
        local entry=slide and math.exp(-slideAge*9) or 0
        local pitch=(sprint and math.sin(phase*2)*.27 or 0)+(slide and math.sin(phase*3.4)*.14-entry*.85 or 0)-landing*.35
        local yaw=(sprint and math.sin(phase)*.15 or 0)+(slide and math.noise(os.clock()*18,2)*.28 or 0)
        local roll=(sprint and math.cos(phase)*.42 or 0)+(slide and entry*1.5+math.sin(phase*3)*.24 or 0)
        pitch,yaw,roll=pitch*scale,yaw*scale,roll*scale
        amount=math.sqrt(pitch*pitch+yaw*yaw+roll*roll)
        local bob=sprint and math.abs(math.sin(phase))*.025*scale or 0
        lastOffset=CFrame.new(0,-bob,0)*CFrame.Angles(math.rad(pitch),math.rad(yaw),math.rad(roll))
        camera.CFrame=camera.CFrame*lastOffset
        -- The weapon controller consumes MovementFovOffset before rendering its viewmodel.
    end)
    return M
end
return M
]====],
[ [====[ReplicatedStorage.GameplayPresentation.CharacterPose]====] ]=[====[-- Client-evaluated R15 pose. Server attributes remain the movement/aim authority.
-- Supports Avatar Joint Upgrade without changing rig attachments or asset IDs.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local C=require(script.Parent.MovementConfig)
local P={}
local started=false
local records={}
local localPlayer=Players.LocalPlayer
local rad=math.rad
local identity=CFrame.identity
local profiles={
    W1={Grip=Vector3.new(.12,.50,-.55),Support=Vector3.new(-.12,.08,-.62)},
    W2={Grip=Vector3.new(.12,.45,-.55),Support=Vector3.new(-.12,.10,-.55)},
    W3={Grip=Vector3.new(.15,.30,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
}
local crouch={Waist=8,LeftHip=-40,RightHip=-40,LeftKnee=80,RightKnee=80,LeftAnkle=-40,RightAnkle=-40}
local slide={
    Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
    Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
    RightHip=CFrame.Angles(rad(95),0,rad(-4)),RightKnee=CFrame.Angles(rad(-8),0,0),
    RightAnkle=CFrame.Angles(rad(-77),0,0),
    LeftHip=CFrame.Angles(rad(110),0,rad(8)),LeftKnee=CFrame.Angles(rad(-145),0,0),
    LeftAnkle=CFrame.Angles(rad(45),0,0),
    RightShoulder=CFrame.Angles(rad(30),0,rad(12)),RightElbow=CFrame.Angles(rad(-35),0,0),
    LeftShoulder=CFrame.Angles(rad(22),0,rad(-25)),LeftElbow=CFrame.Angles(rad(-55),0,0),
}
local function joint(c,name)
    local j=c:FindFirstChild(name,true)
    if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then return j end
end
local function reset(rec)
    for j,saved in rec.Applied do
        -- Do not undo an Animator/another system's newer evaluation.
        if j.Parent and j.Transform==saved.Value then j.Transform=saved.Base end
    end
    rec.Applied={}
end
local function set(rec,j,value)
    if not j or not j.Parent then return end
    local old=rec.Applied[j]
    rec.Applied[j]={Base=old and old.Base or j.Transform,Value=value}
    j.Transform=value
end
local function world(rec,part,cache)
    if cache[part] then return cache[part] end
    local j=rec.ByPart[part]
    local cf
    if j and j.Part0 then cf=world(rec,j.Part0,cache)*j.C0*j.Transform*j.C1:Inverse()
    else cf=part.CFrame end
    cache[part]=cf
    return cf
end
local function segment(localA,localB,worldA,worldB,normal)
    return CFrame.lookAt(worldA,worldB,normal)*CFrame.lookAt(localA,localB,Vector3.zAxis):Inverse()
end
local function arm(rec,side,torsoCF,handCF)
    local sh=rec.Joints[side.."Shoulder"]
    local el=rec.Joints[side.."Elbow"]
    local wr=rec.Joints[side.."Wrist"]
    if not sh or not el or not wr then return nil end
    local a=(torsoCF*sh.C0).Position
    local target=(handCF*wr.C1).Position
    local l1=(el.C0.Position-sh.C1.Position).Magnitude
    local l2=(wr.C0.Position-el.C1.Position).Magnitude
    local delta=target-a
    if l1<.01 or l2<.01 or delta.Magnitude<.01 then return nil end
    local dir=delta.Unit
    local length=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
    local wrist=a+dir*length
    local bend=torsoCF:VectorToWorldSpace(Vector3.new(side=="Right" and .7 or -.7,-1,.25))
    bend-=dir*bend:Dot(dir)
    if bend.Magnitude<.01 then bend=torsoCF.UpVector:Cross(dir) end
    bend=bend.Unit
    local x=(l1*l1-l2*l2+length*length)/(2*length)
    local elbow=a+dir*x+bend*math.sqrt(math.max(0,l1*l1-x*x))
    local normal=dir:Cross(bend).Unit
    local upper=segment(sh.C1.Position,el.C0.Position,a,elbow,normal)
    local lower=segment(el.C1.Position,wr.C0.Position,elbow,wrist,normal)
    -- If an unusual body scale exceeds reach, keep the chain connected.
    handCF=CFrame.new(wrist-target)*handCF
    set(rec,sh,sh.C0:Inverse()*torsoCF:ToObjectSpace(upper)*sh.C1)
    set(rec,el,el.C0:Inverse()*upper:ToObjectSpace(lower)*el.C1)
    set(rec,wr,wr.C0:Inverse()*lower:ToObjectSpace(handCF)*wr.C1)
    return handCF,(wrist-target).Magnitude
end
local function getRecord(plr,c)
    local rec=records[plr]
    if rec and rec.Char~=c then reset(rec);records[plr]=nil;rec=nil end
    if not rec then
        rec={Char=c,Joints={},ByPart={},Applied={},Slide=0,Crouch=0}
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
        records[plr]=rec
    end
    if os.clock()>(rec.ScanAt or 0) then
        rec.ScanAt=os.clock()+1
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
    end
    return rec
end
local function floorClearance(rec)
    local rootJoint=rec.Joints.Root
    local hrp=rec.Char:FindFirstChild("HumanoidRootPart")
    if not rootJoint or not hrp then return end
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={rec.Char}
    params.RespectCanCollide=true
    params.CollisionGroup=hrp.CollisionGroup
    local cache={}
    local lift=0
    for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LowerTorso"} do
        local part=rec.Char:FindFirstChild(name)
        if part then
            local cf=world(rec,part,cache)
            local hit=workspace:Raycast(Vector3.new(cf.X,hrp.Position.Y+1,cf.Z),Vector3.new(0,-7,0),params)
            if hit and hit.Normal.Y>.6 then
                local low=math.huge
                for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
                    low=math.min(low,(cf*Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)).Y)
                end end end
                lift=math.max(lift,hit.Position.Y+.14-low)
            end
        end
    end
    lift=math.clamp(lift,0,1.8)
    if lift>0 then
        local parentFrame=world(rec,rootJoint.Part0,{})*rootJoint.C0
        set(rec,rootJoint,CFrame.new(parentFrame:VectorToObjectSpace(Vector3.new(0,lift,0)))*rootJoint.Transform)
    end
    rec.ClearanceLift=lift
end
local function evaluate(dt)
    dt=math.min(dt,.05)
    for _,plr in Players:GetPlayers() do
        local c=plr.Character
        if c then
            local rec=getRecord(plr,c)
            local h=c:FindFirstChildOfClass("Humanoid")
            local live=h and h.Health>0
            local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
            local crouched=live and plr:GetAttribute("MovementCrouched")==true
            rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
            rec.Crouch+=( (crouched and 1 or 0)-rec.Crouch)*(1-math.exp(-dt*16))
            if live then
                for name,angle in crouch do
                    local j=rec.Joints[name]
                    if j and rec.Crouch>.001 then set(rec,j,j.Transform*CFrame.Angles(rad(angle)*rec.Crouch,0,0)) end
                end
                if rec.Slide>.001 then
                    for name,pose in slide do
                        local j=rec.Joints[name]
                        if j then set(rec,j,j.Transform:Lerp(pose,rec.Slide)) end
                    end
                end
                if sliding then rec.ClearanceUntil=os.clock()+.4 end
                if os.clock()<(rec.ClearanceUntil or 0) or rec.Crouch>.001 then floorClearance(rec) end
                local tool=c:FindFirstChildOfClass("Tool")
                local id=tool and tool:GetAttribute("ReferenceWeaponId")
                local profile=profiles[id]
                local torso=c:FindFirstChild("UpperTorso")
                local hand=c:FindFirstChild("RightHand")
                local handle=tool and tool:FindFirstChild("Handle")
                local model=tool and tool:FindFirstChild("WorldModel")
                local root=model and model:FindFirstChild("Root")
                local weld=hand and hand:FindFirstChild("RightGrip")
                if profile and torso and hand and root and handle and weld and not plr:GetAttribute("InLobby") then
                    local camera=workspace.CurrentCamera
                    local pitch=plr==localPlayer and camera and math.asin(math.clamp(camera.CFrame.LookVector.Y,-1,1)) or plr:GetAttribute("AimPitch") or 0
                    pitch=math.clamp(pitch,rad(-70),rad(70))
                    local waist=rec.Joints.Waist
                    local neck=rec.Joints.Neck
                    if waist then set(rec,waist,waist.Transform*CFrame.Angles(pitch*.35,0,0)) end
                    if neck then set(rec,neck,neck.Transform*CFrame.Angles(pitch*.4,0,0)) end
                    local torsoCF=world(rec,torso,{})
                    local bodyRoot=c:FindFirstChild("HumanoidRootPart")
                    local forward=bodyRoot and bodyRoot.CFrame.LookVector*Vector3.new(1,0,1) or torsoCF.LookVector*Vector3.new(1,0,1)
                    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) end
                    local aim=forward.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
                    local gunCF=CFrame.new(torsoCF:PointToWorldSpace(profile.Grip))*CFrame.lookAt(Vector3.zero,aim)
                    local handToRoot=weld.C0*weld.C1:Inverse()*handle.CFrame:ToObjectSpace(root.CFrame)
                    local rightCF=gunCF*handToRoot:Inverse()
                    local actualRight,rightError=arm(rec,"Right",torsoCF,rightCF)
                    if actualRight then
                        gunCF=actualRight*handToRoot
                        local leftCF=gunCF*CFrame.new(profile.Support)*handToRoot.Rotation:Inverse()
                        local _,leftError=arm(rec,"Left",torsoCF,leftCF)
                        rec.Weapon=id;rec.RightError=rightError;rec.LeftError=leftError
                        rec.Support=profile.Support
                    end
                else rec.Weapon=nil;rec.LeftError=nil;rec.RightError=nil end
            end
        end
    end
end
function P.State(plr)
    local rec=records[plr or localPlayer]
    if not rec then return {} end
    local count=0;for _ in rec.Joints do count+=1 end
    return {JointCount=count,Slide=rec.Slide,Crouch=rec.Crouch,Weapon=rec.Weapon,LeftError=rec.LeftError,RightError=rec.RightError,Support=rec.Support,ClearanceLift=rec.ClearanceLift}
end
function P.Start()
    if started then return P end;started=true
    RunService.PreAnimation:Connect(function()for _,rec in records do reset(rec)end end)
    -- One pose writer, after Animator, for aim + slide. No frame-order tug of war.
    RunService.PreSimulation:Connect(evaluate)
    Players.PlayerRemoving:Connect(function(plr)if records[plr]then reset(records[plr]);records[plr]=nil end end)
    return P
end
return P]====],
[ [====[ServerScriptService.GameplayMovement.Service]====] ]=[====[local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local package=RS:WaitForChild('GameplayPresentation')
local C=require(package.MovementConfig)
local Math=require(package.MovementMath)
local S={}
local states={}
local started=false
local function publish(p,s,key,value)
    if p:GetAttribute(key)~=value then p:SetAttribute(key,value)end
end
local function mode(p,s,value)
    s.Mode=value;publish(p,s,'MovementState',value)
end
local function ground(s)
    local r,h=s.Root,s.Hum
    if not r or not r.Parent or not h or h.Health<=0 then return nil end
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={s.Char};params.RespectCanCollide=true
    local legHeight=h.RigType==Enum.HumanoidRigType.R6 and 2 or 0
    -- A lower target HipHeight must not shorten the ground probe before physics settles.
    local probeHip=s.Mode=="Sliding" and math.max(h.HipHeight,s.BaseHip or 0) or h.HipHeight
    local standing=math.max(0,probeHip)+r.Size.Y/2+legHeight
    if r.AssemblyLinearVelocity.Y>6 then return nil end
    local hit=workspace:Raycast(r.Position,Vector3.new(0,-(standing+.8),0),params)
    return hit and hit.Normal.Y>.45 and hit or nil
end
local function finishSlide(p,s,reason)
    local wasSliding=s.Mode=='Sliding' or s.Drive~=nil
    if wasSliding then s.NextSlide=os.clock()+C.SlideCooldown end
    if s.Drive then s.Drive:Destroy();s.Drive=nil end
    if s.Attachment then s.Attachment:Destroy();s.Attachment=nil end
    if wasSliding and s.Hum and s.Hum.Parent then
        s.Hum.HipHeight=s.BaseHip;s.Hum.AutoRotate=s.BaseRotate
    end
    for ob,value in pairs(s.Collision or {})do if ob.Parent then ob.CanCollide=value end end
    s.Collision={}
    if s.Mode=='Sliding'then mode(p,s,'Walking')end
    publish(p,s,'SlideEndReason',reason or 'Finished')
end
local function canStand(s)
    if not s.Crouched then return true end
    local head=s.Char and s.Char:FindFirstChild('Head')
    if not head or not s.Root then return false end
    local delta=math.max(0,s.BaseHip-s.Hum.HipHeight)
    local top=head.Position.Y+head.Size.Y/2
    local params=OverlapParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={s.Char}
    params.RespectCanCollide=true
    local center=Vector3.new(head.Position.X,top+(delta+.18)/2,head.Position.Z)
    for _,part in workspace:GetPartBoundsInBox(CFrame.new(center),Vector3.new(1.8,math.max(.2,delta+.18),1.8),params) do
        if part.CanCollide then return false end
    end
    return true
end
local function setCrouch(p,s,value)
    if not value and not canStand(s) then return false end
    if value then finishSlide(p,s,'Crouch') end
    s.Crouched=value
    if s.Hum and s.Hum.Parent then
        s.Hum.HipHeight=math.max(0,s.BaseHip-(value and C.CrouchHipDrop or 0))
    end
    publish(p,s,'MovementCrouched',value)
    return true
end
local function reset(p,s)
    if s.Crouched then setCrouch(p,s,false);s.Crouched=false;publish(p,s,'MovementCrouched',false) end
    finishSlide(p,s,'Reset')
    if s.Hum and s.Hum.Parent then s.Hum.WalkSpeed=s.BaseSpeed or C.WalkSpeed end
    s.Wants=false;s.Char=nil;s.Root=nil;s.Hum=nil;s.Joint=nil
    mode(p,s,'Idle')
end
local function bindCharacter(p,s,char)
    reset(p,s)
    s.Char=char;s.Stamina=C.StaminaMax;s.Exhausted=false
    task.spawn(function()
        local hum=char:WaitForChild('Humanoid',10);local root=char:WaitForChild('HumanoidRootPart',10)
        if not hum or not root or s.Char~=char then return end
        s.Hum,s.Root=hum,root
        s.BaseSpeed,s.BaseHip,s.BaseRotate=hum.WalkSpeed,hum.HipHeight,hum.AutoRotate
        s.Joint=root:FindFirstChildWhichIsA('Motor6D') or (char:FindFirstChild('LowerTorso') and char.LowerTorso:FindFirstChild('Root'))
        s.BaseC0=s.Joint and s.Joint.C0
        hum.WalkSpeed=C.WalkSpeed
        hum.Died:Connect(function()if s.Char==char then reset(p,s)end end)
    end)
end
local function reject(p,s,why)
    publish(p,s,'MovementRejectReason',why)
    return false,why
end
function S.Handle(p,action,payload,...)
    local s=states[p]
    if not s or typeof(action)~='string' or #action>20 then return false,'Invalid action'end
    if select('#',...)~=0 then return reject(p,s,'Unexpected payload')end
    local now=os.clock()
    -- Token bucket permits normal press/release bursts but bounds remote spam.
    s.Tokens=math.min(12,(s.Tokens or 12)+(now-(s.TokenTime or now))*8);s.TokenTime=now
    if s.Tokens<1 then return reject(p,s,'RateLimited')end;s.Tokens-=1
    if action=='Sprint' and typeof(payload)~='boolean' then return reject(p,s,'Invalid sprint payload')end
    if action=='Crouch' and typeof(payload)~='boolean' then return reject(p,s,'Invalid crouch payload')end
    if action=='CancelSlide' and payload~=nil then return reject(p,s,'Invalid cancel payload')end
    if action~='Sprint' and action~='Slide' and action~='CancelSlide' and action~='Crouch' then return reject(p,s,'Unknown action')end
    if (p:GetAttribute('InMenu') and not p:GetAttribute('InLobby')) or not s.Hum or not s.Root or not s.Char.Parent or s.Hum.Health<=0 then return reject(p,s,'Not deployed')end
    if action=='Crouch'then
        if payload and not ground(s) then return reject(p,s,'Ground required')end
        if not setCrouch(p,s,payload) then return reject(p,s,'Low ceiling')end
        s.Wants=false
        mode(p,s,payload and 'Crouching' or 'Walking')
        publish(p,s,'MovementRejectReason','')
        return true
    elseif action=='Sprint'then
        if payload and s.Crouched and not setCrouch(p,s,false) then return reject(p,s,'Low ceiling')end
        s.Wants=payload
        return true
    elseif action=='CancelSlide'then
        finishSlide(p,s,'Cancelled');return true
    end
    local dir=Math.Direction(payload)
    if not dir then return reject(p,s,'Invalid slide direction')end
    if s.Mode=='Sliding' or now<(s.NextSlide or 0)then return reject(p,s,'Cooldown')end
    if not s.Wants or s.Stamina<C.SlideCost or s.Exhausted then return reject(p,s,'Sprint and stamina required')end
    if not ground(s) then return reject(p,s,'Ground required')end
    local velocity=s.Root.AssemblyLinearVelocity*Vector3.new(1,0,1)
    if velocity.Magnitude<C.SlideMinSpeed then return reject(p,s,'Build sprint speed first')end
    if velocity.Unit:Dot(dir)<.65 then return reject(p,s,'Direction must follow momentum')end
    s.Stamina-=C.SlideCost;s.LastEffort=now;s.NextSlide=now
    s.SlideStart=now;s.Direction=dir;s.AirTime=0;s.BaseHip=s.Hum.HipHeight;s.BaseRotate=s.Hum.AutoRotate
    s.BaseC0=s.Joint and s.Joint.C0
    s.Hum.HipHeight=s.BaseHip-C.HipDrop;s.Hum.AutoRotate=false;s.Hum.WalkSpeed=C.SlideEndSpeed
    s.Collision={}
    for _,o in ipairs(s.Char:GetDescendants())do if o:IsA('BasePart') and (o.Name:find('Leg') or o.Name:find('Foot'))then s.Collision[o]=o.CanCollide;o.CanCollide=false end end
    local attach=Instance.new('Attachment');attach.Name='GameplaySlideAttachment';attach.Parent=s.Root
    local drive=Instance.new('LinearVelocity');drive.Name='GameplaySlideVelocity'
    drive.Attachment0=attach;drive.RelativeTo=Enum.ActuatorRelativeTo.World
    drive.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
    drive.PrimaryTangentAxis=Vector3.xAxis;drive.SecondaryTangentAxis=Vector3.zAxis
    drive.ForceLimitsEnabled=true;drive.ForceLimitMode=Enum.ForceLimitMode.PerAxis
    local force=math.max(50000,s.Root.AssemblyMass*1600)
    drive.MaxPlanarAxesForce=Vector2.new(force,force)
    drive.PlaneVelocity=Vector2.new(dir.X*C.SlideSpeed,dir.Z*C.SlideSpeed);drive.Parent=s.Root
    s.Attachment,s.Drive=attach,drive
    mode(p,s,'Sliding');publish(p,s,'SlideStartedAt',workspace:GetServerTimeNow())
    publish(p,s,'MovementRejectReason','')
    return true
end
local function tickPlayer(p,s,dt)
    local now=os.clock()
    if (p:GetAttribute('InMenu') and not p:GetAttribute('InLobby')) or not s.Hum or not s.Root or not s.Root.Parent or s.Hum.Health<=0 then
        if s.Mode~='Idle'then finishSlide(p,s,'MenuOrDeath');mode(p,s,'Idle')end
        if s.Crouched then
            if s.Hum and s.Hum.Parent then s.Hum.HipHeight=s.BaseHip end
            s.Crouched=false;publish(p,s,'MovementCrouched',false)
        end
        s.Wants=false;s.Stamina=math.min(C.StaminaMax,s.Stamina+C.StaminaRegen*dt)
    elseif s.Crouched then
        s.Hum.WalkSpeed=C.CrouchSpeed
        mode(p,s,'Crouching')
        if now-(s.LastEffort or 0)>C.RegenDelay then s.Stamina=Math.Stamina(s.Stamina,false,dt)end
        if s.Exhausted and s.Stamina>=C.ExhaustionRecovery then s.Exhausted=false end
    elseif s.Mode=='Sliding'then
        local elapsed=now-s.SlideStart
        if ground(s)then s.AirTime=0 else s.AirTime+=dt end
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.Char};params.RespectCanCollide=true
        local wall=workspace:Raycast(s.Root.Position,s.Direction*(2.1+Math.SlideSpeed(elapsed)*dt),params)
        if elapsed>=C.SlideDuration then finishSlide(p,s,'Completed')
        elseif s.AirTime>.14 then finishSlide(p,s,'Airborne')
        elseif wall and wall.Normal.Y<.45 then finishSlide(p,s,'Wall')
        elseif s.Drive then
            local speed=Math.SlideSpeed(elapsed)
            s.Drive.PlaneVelocity=Vector2.new(s.Direction.X*speed,s.Direction.Z*speed)
            publish(p,s,'SlideSpeed',math.floor(speed*10)/10)
        end
    else
        local horizontal=s.Root.AssemblyLinearVelocity*Vector3.new(1,0,1)
        local moving=horizontal.Magnitude>1.5
        if s.Stamina<=0 then s.Exhausted=true end
        if s.Exhausted and s.Stamina>=C.ExhaustionRecovery then s.Exhausted=false end
        local sprint=s.Wants and not s.Exhausted and s.Stamina>0
        s.Hum.WalkSpeed=sprint and C.SprintSpeed or C.WalkSpeed
        local grounded=ground(s)~=nil
        if sprint and moving and grounded then
            mode(p,s,'Sprinting');s.Stamina=Math.Stamina(s.Stamina,true,dt);s.LastEffort=now
        else
            mode(p,s,moving and 'Walking' or 'Idle')
            if now-(s.LastEffort or 0)>C.RegenDelay then s.Stamina=Math.Stamina(s.Stamina,false,dt)end
        end
    end
    publish(p,s,'MovementStamina',math.floor(s.Stamina*10)/10)
    publish(p,s,'SlideReadyIn',math.max(0,math.ceil(((s.NextSlide or 0)-now)*10)/10))
end
function S.Start()
    if started then return end;started=true
    local function added(p)
        if states[p]then return end
        local s={Mode='Idle',Stamina=C.StaminaMax,Wants=false,Crouched=false};states[p]=s
        p.CharacterAdded:Connect(function(char)bindCharacter(p,s,char)end)
        p.CharacterRemoving:Connect(function(char)if s.Char==char then reset(p,s)end end)
        if p.Character then bindCharacter(p,s,p.Character)end
    end
    for _,p in ipairs(Players:GetPlayers())do added(p)end
    Players.PlayerAdded:Connect(added)
    Players.PlayerRemoving:Connect(function(p)if states[p]then reset(p,states[p]);states[p]=nil end end)
    package.MovementRequest.OnServerEvent:Connect(S.Handle)
    RunService.Heartbeat:Connect(function(dt)for p,s in pairs(states)do tickPlayer(p,s,math.min(dt,.1))end end)
    -- Server-local QA entry point; never exposed to clients.
    local control=Instance.new('BindableFunction');control.Name='MovementControl'
    control.OnInvoke=function(p,action,value)
        if action=='State'then local s=states[p];return s and {Mode=s.Mode,Stamina=s.Stamina,Wants=s.Wants,Sliding=s.Drive~=nil,WalkSpeed=s.Hum and s.Hum.WalkSpeed,BaseHip=s.BaseHip,Hip=s.Hum and s.Hum.HipHeight,Crouched=s.Crouched,CanStand=not s.Crouched or canStand(s)}end
        return S.Handle(p,action,value)
    end
    control.Parent=script.Parent
end
return S
]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson]====] ]=[====[-- Claude's third-person combat camera + aim pose.
-- Over-the-shoulder camera, mouse locked in matches, character faces where you look,
-- arms + torso aim at the camera pitch (other players' pitch comes from the server attribute AimPitch).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local aimRemote = package:WaitForChild("AimPitch")
local player = Players.LocalPlayer
local gameSettings = UserSettings():GetService("UserGameSettings")

local SHOULDER = Vector3.new(2.1, 0.55, 0)
local shoulderX = SHOULDER.X
local lastSent, lastSentAt = 0, 0

local function inMatch()
	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
end

local function armed(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool and tool:GetAttribute("ReferenceWeaponId") ~= nil
end

local function cameraPitch()
	local cam = workspace.CurrentCamera
	return cam and math.asin(math.clamp(cam.CFrame.LookVector.Y, -1, 1)) or 0
end

-- camera: runs after the default camera, the gun controller and the lobby script
RunService:BindToRenderStep("ClaudeThirdPerson", Enum.RenderPriority.Last.Value + 2, function(dt)
	local cam = workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not cam or not humanoid or humanoid.Health <= 0 or not head then return end
	local combat = inMatch()
	UserInputService.MouseBehavior = combat and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = not combat
	gameSettings.RotationType = combat and Enum.RotationType.CameraRelative or Enum.RotationType.MovementRelative
	if not combat then return end
	-- shoulder offset, pulled in when a wall is on the right
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, workspace:FindFirstChild("ClaudeAKFx")}
	local right = cam.CFrame.RightVector
	local wall = workspace:Raycast(head.Position, right * (SHOULDER.X + 0.6), params)
	local wanted = wall and math.max(0, (wall.Position - head.Position).Magnitude - 0.7) or SHOULDER.X
	shoulderX += (wanted - shoulderX) * (1 - math.exp(-dt * 14))
	cam.CFrame = cam.CFrame * CFrame.new(shoulderX, SHOULDER.Y, 0)
	-- share pitch with the server (10x a second, only when it changed)
	local pitch = cameraPitch()
	local now = os.clock()
	if now - lastSentAt > 0.1 and math.abs(pitch - lastSent) > math.rad(1) then
		lastSent, lastSentAt = pitch, now
		aimRemote:FireServer(pitch)
	end
end)

-- Aim and movement now share GameplayPresentation.CharacterPose (bounded pose-only integration).
-- Camera, mouse lock and AimPitch network protocol above remain unchanged.
]====],
[ [====[ReplicatedStorage.ReferenceWeapons.Controller]====] ]=[====[-- Client-only presentation. Damage/hit authority remains outside this controller.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local ContextActionService = game:GetService('ContextActionService')
local StarterGui = game:GetService('StarterGui')
local Config = require(script.Parent.WeaponConfig)
local Controller = {}
-- Claude's AK hook: guns with CustomFx skip the stock effects and fire this signal instead.
local shotSignal = Instance.new('BindableEvent')
Controller.Shot = shotSignal.Event
local player = Players.LocalPlayer
local package = script.Parent
local camera
local started = false
local activeTool, spec, model, hud, nameText, ammoText, statusText
local parts, arms, connections = {}, {}, {}
local hooked = setmetatable({}, {__mode = 'k'})
local ammo = setmetatable({}, {__mode = 'k'})
local hidden = setmetatable({}, {__mode = 'k'})
local trigger, aiming, sprinting = false, false, false
local reloadStart, inspectStart, equipStart = nil, nil, 0
local lastShot, shotAt = -100, -100
local recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
local yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
local elapsed, crossBloom, generation = 0, 0, 0
local crossLines, casings, characterConnections = {}, {}, {}
local baseFov = 72
local controlBridge
local viewScene, viewCamera, testing = nil, nil, false
local skin = Color3.fromRGB(222, 172, 116)
local renderName = 'ReferenceFPS_Viewmodel'
local identity = CFrame.identity

local function smooth(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
local function mix(a, b, t) return a:Lerp(b, smooth(t)) end
local function bump(t, startTime, peakTime, endTime)
    if t < startTime or t > endTime then return 0 end
    if t <= peakTime then return smooth((t - startTime) / (peakTime - startTime)) end
    return 1 - smooth((t - peakTime) / (endTime - peakTime))
end
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function part(name, size, color, parent)
    local p = Instance.new('Part')
    p.Name, p.Size, p.Color = name, size, color
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.CastShadow, p.Material = false, Enum.Material.SmoothPlastic
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function label(name, size, pos, text, parent)
    local l = Instance.new('TextLabel')
    l.Name, l.Size, l.Position = name, size, pos
    l.BackgroundTransparency = 1
    l.TextColor3, l.Font, l.TextSize = Color3.fromRGB(235, 240, 245), Enum.Font.GothamMedium, 18
    l.TextStrokeTransparency = .65
    l.Text, l.TextXAlignment = text, Enum.TextXAlignment.Right
    l.Parent = parent
    return l
end
local function createHUD()
    local old = player.PlayerGui:FindFirstChild('ReferenceWeaponHUD')
    if old then old:Destroy() end
    hud = Instance.new('ScreenGui')
    hud.Name, hud.ResetOnSpawn, hud.IgnoreGuiInset = 'ReferenceWeaponHUD', false, true
    hud.DisplayOrder = 8
    hud.Parent = player:WaitForChild('PlayerGui')
    -- A transparent live 3D viewmodel pass keeps the Blender colors legible at night.
    local viewport = Instance.new('ViewportFrame')
    viewport.Name, viewport.Size, viewport.BackgroundTransparency = 'ViewmodelViewport', UDim2.fromScale(1, 1), 1
    viewport.BorderSizePixel = 0
    viewport.Ambient, viewport.LightColor = Color3.fromRGB(135, 135, 140), Color3.fromRGB(240, 235, 225)
    viewport.LightDirection = Vector3.new(-1, -1.5, -1)
    viewport.Parent = hud
    viewScene = Instance.new('WorldModel'); viewScene.Name, viewScene.Parent = 'WorldModel', viewport
    viewCamera = Instance.new('Camera'); viewCamera.Name, viewCamera.Parent = 'ViewmodelCamera', viewport
    viewport.CurrentCamera = viewCamera
    nameText = label('WeaponName', UDim2.fromOffset(300, 25), UDim2.new(1, -330, 1, -122), '', hud)
    nameText.TextSize = 15
    ammoText = label('Ammo', UDim2.fromOffset(250, 45), UDim2.new(1, -280, 1, -96), '', hud)
    ammoText.Font, ammoText.TextSize = Enum.Font.GothamBold, 32
    statusText = label('Status', UDim2.fromOffset(330, 25), UDim2.new(1, -360, 1, -49), '', hud)
    statusText.TextSize = 12
    statusText.TextColor3 = Color3.fromRGB(167, 184, 199)
    local center = Instance.new('Frame')
    center.Name, center.Size, center.Position = 'Reticle', UDim2.fromOffset(1, 1), UDim2.fromScale(.5, .5)
    center.BackgroundTransparency = 1
    center.Parent = hud
    local dot = Instance.new('Frame')
    dot.Name, dot.Size, dot.AnchorPoint = 'CenterDot', UDim2.fromOffset(3, 3), Vector2.new(.5, .5)
    dot.BorderSizePixel, dot.BackgroundColor3 = 0, Color3.fromRGB(255, 199, 94)
    dot.Parent = center
    local corner = Instance.new('UICorner'); corner.CornerRadius = UDim.new(1, 0); corner.Parent = dot
    for i, dir in ipairs({Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)}) do
        local f = Instance.new('Frame')
        f.Name, f.AnchorPoint, f.BorderSizePixel = 'Line' .. i, Vector2.new(.5, .5), 0
        f.Size = i % 2 == 0 and UDim2.fromOffset(7, 2) or UDim2.fromOffset(2, 7)
        f.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
        f.Parent = center
        local stroke = Instance.new('UIStroke'); stroke.Color = Color3.new(0, 0, 0); stroke.Transparency = .45; stroke.Parent = f
        table.insert(crossLines, {Frame = f, Direction = dir, Stroke = stroke})
    end
    if ReplicatedStorage:FindFirstChild('GameplayPresentation') then
        nameText.Visible=false;ammoText.Visible=false;statusText.Visible=false;center.Visible=false
    end
    if UserInputService.TouchEnabled then
        for i, action in ipairs({'FIRE', 'AIM', 'RELOAD'}) do
            local button = Instance.new('TextButton')
            button.Name, button.Text = action, action
            button.Size, button.Position = UDim2.fromOffset(78, 45), UDim2.new(1, -90, .50, (i - 1) * 53)
            button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(30, 40, 50), Color3.new(1, 1, 1)
            button.BackgroundTransparency = .25
            button.Parent = hud
            connect(button.Activated, function()
                if action == 'FIRE' then Controller.Fire() elseif action == 'AIM' then Controller.SetAim(not aiming) else Controller.Reload() end
            end)
        end
    end
end
local function updateHUD()
    local function publish(key,value)if player:GetAttribute(key)~=value then player:SetAttribute(key,value)end end
    local current=activeTool and ammo[activeTool]
    publish('FPSWeaponId',spec and spec.Id or '')
    publish('FPSAmmo',current and current.Current or nil)
    publish('FPSReserve',current and current.Reserve or nil)
    publish('FPSReloading',reloadStart~=nil)
    publish('FPSInspecting',inspectStart~=nil)
    local a = activeTool and ammo[activeTool]
    if a and spec then
        nameText.Text = string.upper(spec.Name)
        ammoText.Text = string.format('%02d  /  %03d', a.Current, a.Reserve)
        statusText.Text = reloadStart and 'RELOADING' or (inspectStart and 'INSPECTING' or 'R  RELOAD    RMB  AIM    F  INSPECT')
    else
        nameText.Text, ammoText.Text, statusText.Text = '', '', ''
    end
end
local function clear()
    generation += 1
    if camera then camera.CFrame *= CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() end
    if model then model:Destroy() end
    model, activeTool, spec = nil, nil, nil
    parts, arms = {}, {}
    trigger, aiming, reloadStart, inspectStart = false, false, nil, nil
    recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
    yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
    if camera then camera.FieldOfView = baseFov end
    updateHUD()
end
local function armParts(side)
    local result = {}
    local handScale = spec and spec.Pistol and .82 or 1
    result.Upper = part(side .. 'UpperArm', Vector3.new(.39, 1, .40), skin, model)
    result.Lower = part(side .. 'Forearm', Vector3.new(.36, 1, .38), skin, model)
    result.Palm = part(side .. 'Hand', Vector3.new(.34, .43, .37) * handScale, skin, model)
    result.Cuff = part(side .. 'Sleeve', Vector3.new(.42, .35, .44), (player:GetAttribute('EquippedSleeveColor') or Color3.fromRGB(31, 38, 46)), model)
    result.Fingers = {}
    for i = 1, 4 do
        result.Fingers[i] = part(side .. 'Finger' .. i, Vector3.new(.105, .12, .28) * handScale, skin, model)
    end
    result.Thumb = part(side .. 'Thumb', Vector3.new(.15, .23, .20) * handScale, skin, model)
    return result
end
local function segment(ob, a, b, width)
    local length = (b - a).Magnitude
    ob.Size = Vector3.new(width, math.max(.02, length), width * 1.06)
    ob.CFrame = CFrame.lookAt((a + b) * .5, b) * CFrame.Angles(math.pi * .5, 0, 0)
end
local function solveArm(limb, shoulder, handFrame, pole, side)
    local target = handFrame.Position
    local delta = target - shoulder
    local distance = math.max(delta.Magnitude, .001)
    local direction = delta / distance
    local upper, lower = 1.22, 1.26
    local d = math.clamp(distance, .12, upper + lower - .005)
    local adjacent = (upper * upper - lower * lower + d * d) / (2 * d)
    local height = math.sqrt(math.max(0, upper * upper - adjacent * adjacent))
    local bend = pole - shoulder
    bend = bend - direction * bend:Dot(direction)
    if bend.Magnitude < .01 then bend = Vector3.yAxis:Cross(direction) end
    local elbow = shoulder + direction * adjacent + bend.Unit * height
    segment(limb.Upper, shoulder, elbow, .39)
    segment(limb.Lower, elbow, target, .36)
    limb.Cuff.CFrame = CFrame.lookAt(shoulder:Lerp(elbow, .22), elbow) * CFrame.Angles(math.pi / 2, 0, 0)
    limb.Palm.CFrame = handFrame
    local handScale = spec and spec.Pistol and .82 or 1
    for i, finger in ipairs(limb.Fingers) do
        finger.CFrame = handFrame * CFrame.new(Vector3.new((i - 2.5) * .075, -.03, -.18) * handScale) * CFrame.Angles(-.40, 0, 0)
    end
    limb.Thumb.CFrame = handFrame * CFrame.new(Vector3.new(side * .19, .04, -.07) * handScale) * CFrame.Angles(0, 0, side * .48)
end
local function equip(tool)
    if activeTool == tool then return end
    clear()
    spec = Config.Guns[tool:GetAttribute('ReferenceWeaponId')]
    if not spec then return end
    local template = package.Viewmodels:FindFirstChild(spec.Id)
    if not template then warn('Missing imported weapon template ' .. spec.Id); return end
    activeTool = tool
    if not ammo[tool] then ammo[tool] = {Current = spec.MagazineSize, Reserve = spec.Reserve} end
    camera = workspace.CurrentCamera
    model = template:Clone()
    model.Name = 'ReferenceFPS_Active'
    model.Parent = viewScene
    local menuPackage = ReplicatedStorage:FindFirstChild('MainMenu')
    if menuPackage and menuPackage:FindFirstChild('Cosmetics') then require(menuPackage.Cosmetics).ApplyWeapon(model, player:GetAttribute('CosmeticWrap') or 'ORIGINAL') end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
            if p ~= model.PrimaryPart then
                table.insert(parts, {Part = p, Rest = p.CFrame, Component = p:GetAttribute('Component') or 'Body'})
            end
        end
    end
    -- Claude's guns with CustomArms carry their own posed hand meshes.
    if not spec.CustomArms then arms.Left, arms.Right = armParts('Left'), armParts('Right') end
    equipStart = os.clock()
    model:SetAttribute('WeaponId', spec.Id)
    model:SetAttribute('Pose', 'Equip')
    updateHUD()
end
local function effectPart(name, size, color, frame)
    local p = part(name, size, color, workspace)
    p.CFrame = frame
    p.Material = Enum.Material.Neon
    return p
end
local function muzzleEffects()
    if not model then return end
    local root = model.PrimaryPart.CFrame
    local muzzle = root * CFrame.new(spec.Muzzle)
    local flash = effectPart('ReferenceMuzzleFlash', Vector3.new(.09, .09, .32), Color3.fromRGB(255, 210, 115), muzzle * CFrame.new(0, 0, -.09))
    flash.Shape = Enum.PartType.Ball
    local light = Instance.new('PointLight'); light.Brightness, light.Range, light.Color = 3, 8, flash.Color; light.Parent = flash
    Debris:AddItem(flash, .045)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, model}
    local origin, direction = camera.CFrame.Position, camera.CFrame.LookVector * 400
    local hit = workspace:Raycast(origin, direction, params)
    local target = hit and hit.Position or origin + direction
    local delta = target - muzzle.Position
    local trace = effectPart('ReferenceTracer', Vector3.new(.015, .015, math.min(delta.Magnitude, 150)), Color3.fromRGB(255, 220, 130), CFrame.lookAt(muzzle.Position, target) * CFrame.new(0, 0, -math.min(delta.Magnitude, 150) / 2))
    trace.Transparency = .3
    Debris:AddItem(trace, .045)
    local casing = part('ReferenceEjectedCasing', Vector3.new(.06, .13, .06), Color3.fromRGB(196, 145, 57), workspace)
    casing.Shape, casing.Material = Enum.PartType.Cylinder, Enum.Material.Metal
    casing.CFrame = root * CFrame.new(spec.Bolt + Vector3.new(.13, 0, 0))
    table.insert(casings, {Part = casing, Frame = casing.CFrame, Age = 0, Velocity = root.RightVector * 4 + Vector3.yAxis * 2.2})
    if #casings > 16 then table.remove(casings, 1).Part:Destroy() end
end
function Controller.Fire()
    if sprinting then player:SetAttribute('MovementFireInterrupt',os.clock());sprinting=false end
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return false end
    if not activeTool or not model or not spec or reloadStart or sprinting then return false end
    local now, a = os.clock(), ammo[activeTool]
    if now - equipStart < .40 or now - lastShot < 60 / spec.RPM then return false end
    if a.Current <= 0 then Controller.Reload(); return false end
    inspectStart = nil
    lastShot, shotAt = now, now
    a.Current -= 1
    recoilVelocity += spec.Kick * 65
    shotCounter += 1
    yawVelocity += math.rad(spec.RecoilYaw or .3) * math.sin(shotCounter * 2.399963) * 28
    crossBloom = math.min(crossBloom + 7, 22)
    if spec.CustomFx then shotSignal:Fire(spec, model, aiming) else muzzleEffects() end
    updateHUD()
    return true
end
function Controller.Reload()
    local a = activeTool and ammo[activeTool]
    if not a or not spec or reloadStart or a.Current == spec.MagazineSize or a.Reserve == 0 then return false end
    reloadStart, inspectStart, aiming, trigger = os.clock(), nil, false, false
    updateHUD()
    return true
end
function Controller.Inspect()
    if not activeTool or reloadStart then return false end
    inspectStart, aiming = os.clock(), false
    return true
end
function Controller.SetAim(value)
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then aiming = false; return end
    aiming = value == true and activeTool ~= nil and reloadStart == nil
    if aiming then sprinting, inspectStart = false, nil end
end
function Controller.GetState()
    local a = activeTool and ammo[activeTool]
    return {
        WeaponId = spec and spec.Id, Ammo = a and a.Current, Reserve = a and a.Reserve,
        Aiming = aiming, Reloading = reloadStart ~= nil, Inspecting = inspectStart ~= nil,
        Pose = model and model:GetAttribute('Pose'), FirstPerson = player.CameraMode.Name,
        Meshes = #parts, HasArms = arms.Left ~= nil and arms.Right ~= nil,
        CameraFov = camera and camera.FieldOfView,
        RecoilPitchDegrees = math.deg(lastCameraKick), RecoilYawDegrees = math.deg(lastCameraYaw),
        WeaponKick = recoil,
    }
end
local function render(dt)
    dt = math.min(dt, .05)
    elapsed += dt
    camera = workspace.CurrentCamera
    if not camera then return end
    local inMenu = player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen')
    if hud then hud.Enabled = not inMenu end
    if inMenu then trigger=false;aiming=false;player:SetAttribute('FPSAiming',false);return end
    sprinting=player:GetAttribute('MovementState')=='Sprinting'
    if player:GetAttribute('MovementState')=='Sliding' then aiming=false end
    if player:GetAttribute('FPSAiming')~=aiming then player:SetAttribute('FPSAiming',aiming)end
    if player:GetAttribute('FPSReloading')~=(reloadStart~=nil) then player:SetAttribute('FPSReloading',reloadStart~=nil)end
    if player:GetAttribute('FPSInspecting')~=(inspectStart~=nil) then player:SetAttribute('FPSInspecting',inspectStart~=nil)end
    -- Character and world-held weapon remain visible to other players, hidden only here.
    local character = player.Character
    if character then
        for _, ob in ipairs(character:GetDescendants()) do
            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = 1 end
        end
    end
    for i = #casings, 1, -1 do
        local c = casings[i]; c.Age += dt
        if c.Age > .9 then c.Part:Destroy(); table.remove(casings, i) else
            c.Velocity -= Vector3.yAxis * dt * 18
            c.Frame += c.Velocity * dt
            c.Part.CFrame = c.Frame * CFrame.Angles(c.Age * 9, c.Age * 7, c.Age * 4)
            c.Part.Transparency = math.max(0, (c.Age - .55) / .35)
        end
    end
    if not model or not activeTool or not spec then return end
    if model.Parent ~= viewScene then model.Parent = viewScene end
    local now = os.clock()
    if not testing and trigger and spec.Automatic and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then Controller.Fire() end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then trigger = false end
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local moving = humanoid and humanoid.MoveDirection.Magnitude or 0
    local reloading = reloadStart ~= nil
    local r = reloading and math.clamp((now - reloadStart) / spec.ReloadTime, 0, 1) or 0
    if reloading and r >= 1 then
        local a = ammo[activeTool]
        local count = math.min(spec.MagazineSize - a.Current, a.Reserve)
        a.Current, a.Reserve = a.Current + count, a.Reserve - count
        reloadStart, reloading, r = nil, false, 0
        updateHUD()
    end
    local inspect = inspectStart and (now - inspectStart) / 2.2 or 0
    if inspect >= 1 then inspectStart, inspect = nil, 0; updateHUD() end
    aimAlpha += ((aiming and not reloading and not sprinting and 1 or 0) - aimAlpha) * (1 - math.exp(-dt * 15))
    camera.FieldOfView += ((baseFov + (player:GetAttribute('MovementFovOffset') or 0) * (1-aimAlpha) + (spec.AimFov - baseFov) * aimAlpha) - camera.FieldOfView) * (1 - math.exp(-dt * 18))
    recoilVelocity += (-150 * recoil - 20 * recoilVelocity) * dt
    recoil += recoilVelocity * dt
    yawVelocity += (-150 * yawRecoil - 20 * yawVelocity) * dt
    yawRecoil += yawVelocity * dt
    local kick = math.clamp(recoil * (spec.CameraRecoil or .75) * (1 - .18 * aimAlpha), 0, math.rad(7))
    local yaw = math.clamp(yawRecoil * (1 - .18 * aimAlpha), -math.rad(1.2), math.rad(1.2))
    camera.CFrame = camera.CFrame * CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() * CFrame.Angles(kick, yaw, 0)
    lastCameraKick, lastCameraYaw = kick, yaw
    local aimPosition = Vector3.new(-spec.Aim.X, -spec.Aim.Y, -(spec.SightDistance or .90) - spec.Aim.Z)
    local stance = spec.Hip:Lerp(CFrame.new(aimPosition), aimAlpha)
    local delta = UserInputService:GetMouseDelta()
    local sway = CFrame.Angles(math.clamp(-delta.Y * .00055, -.025, .025), math.clamp(-delta.X * .00055, -.025, .025), 0)
    local bob = CFrame.new(math.sin(elapsed * 8) * .018 * moving, math.cos(elapsed * 16) * .015 * moving, 0)
    local breathe = CFrame.new(0, math.sin(elapsed * 2) * .004, 0)
    local draw = 1 - smooth((now - equipStart) / .45)
    local reloadPose = math.sin(r * math.pi)
    local inspectPose = math.sin(math.pi * math.clamp(inspect, 0, 1))
    local sprintPose=sprinting and moving>.1 and 1 or 0
    if player:GetAttribute('MovementState')=='Sliding' then sprintPose=.7 end
    local visualKick = math.clamp(recoil, 0, .24)
    local pullback = (spec.Pullback or .1) * math.clamp(visualKick / .10, 0, 1.5)
    local action = CFrame.new(-.12 * reloadPose, -.12 * reloadPose - .9 * draw - .2 * sprintPose - .015 * visualKick, .12 * reloadPose + .28 * draw + pullback)
        * CFrame.Angles(-visualKick * 1.05 + .25 * draw - .3 * sprintPose, .09 * reloadPose + .32 * inspectPose + yawRecoil * .45, -.30 * reloadPose - .48 * inspectPose - visualKick * .12)
    local base = camera.CFrame * stance * breathe * bob * sway * action
    viewCamera.CFrame, viewCamera.FieldOfView = camera.CFrame, camera.FieldOfView
    model.PrimaryPart.CFrame = base
    local magDrop = bump(r, .10, .33, .72) * .90
    local boltPull = bump(r, .78, .84, .94) * .20
    local age = now - shotAt
    local fireBolt = age >= 0 and age < .11 and math.sin(age / .11 * math.pi) * .15 or 0
    local pumpPull = spec.Shotgun and bump(age, .10, .24, .48) * .29 or 0
    local motion = {
        Body = identity,
        Magazine = CFrame.new(.03 * magDrop, -magDrop, .08 * magDrop) * CFrame.Angles(0, 0, -.14 * magDrop),
        Bolt = CFrame.new(0, 0, boltPull + fireBolt),
        Trigger = CFrame.new(0, 0, age < .10 and .025 or 0),
        Pump = CFrame.new(0, 0, pumpPull + (spec.Shotgun and bump(r, .78, .87, .97) * .26 or 0)),
    }
    for _, p in ipairs(parts) do p.Part.CFrame = base * (motion[p.Component] or identity) * p.Rest end
    local left = spec.Support
    if spec.Shotgun then
        left += Vector3.new(0, 0, motion.Pump.Position.Z)
        if reloading then
            local insertion = bump(r, .10, .30, .76)
            left = mix(left, Vector3.new(.21, .23, -.21), insertion)
        end
    elseif reloading then
        local mag = motion.Magazine:PointToWorldSpace(spec.Magazine) + Vector3.new(-.12, -.10, 0)
        if r < .20 then left = mix(spec.Support, mag, r / .20)
        elseif r < .73 then left = mag
        elseif r < .85 then left = mix(mag, spec.Bolt + Vector3.new(.1, 0, boltPull), (r - .73) / .12)
        else left = mix(spec.Bolt, spec.Support, (r - .85) / .15) end
    end
    local rightFrame = base * CFrame.new(.02, -.01, 0) * CFrame.Angles(-.27, 0, 0)
    local leftFrame = base * CFrame.new(left) * CFrame.Angles(spec.Pistol and -.27 or .25, 0, spec.Pistol and -.4 or -.9)
    local cam = camera.CFrame
    if arms.Right then
        solveArm(arms.Right, cam:PointToWorldSpace(Vector3.new(.84, -.99, .19)), rightFrame, cam:PointToWorldSpace(Vector3.new(1.4, -1.6, -.3)), 1)
        solveArm(arms.Left, cam:PointToWorldSpace(Vector3.new(-.78, -.99, .19)), leftFrame, cam:PointToWorldSpace(Vector3.new(-.85, -1.7, -.4)), -1)
    end
    model:SetAttribute('Pose', reloading and 'Reload' or (inspectStart and 'Inspect' or (draw > .01 and 'Equip' or (aimAlpha > .8 and 'ADS' or (age < .13 and 'Fire' or 'Idle')))))
    model:SetAttribute('Ammo', ammo[activeTool].Current)
    crossBloom *= math.exp(-dt * 10)
    local gap = 8 + crossBloom + moving * 3
    for _, item in ipairs(crossLines) do
        item.Frame.Position = UDim2.fromOffset(item.Direction.X * gap, item.Direction.Y * gap)
        item.Frame.BackgroundTransparency = aimAlpha * .9
        item.Stroke.Transparency = .45 + aimAlpha * .5
    end
end
local function hookTool(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ReferenceWeaponId') or hooked[tool] then return end
    hooked[tool] = true
    connect(tool.Equipped, function() equip(tool) end)
    connect(tool.Unequipped, function() if activeTool == tool then clear() end end)
    connect(tool.Activated, function() if not testing then Controller.Fire() end end)
    connect(tool.Deactivated, function() trigger = false end)
    if tool.Parent == player.Character then equip(tool) end
end
local function hookCharacter(character)
    clear()
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
    -- Neutral tan bare arms match the supplied first-person reference instead of yellow test-avatar limbs.
    skin = player:GetAttribute('EquippedHandColor') or Color3.fromRGB(222, 172, 116)
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    characterConnections = {character.ChildAdded:Connect(hookTool)}
    for _, child in ipairs(character:GetChildren()) do hookTool(child) end
    task.spawn(function()
        local humanoid = character:WaitForChild('Humanoid', 10)
        local backpack = player:WaitForChild('Backpack', 10)
        if not humanoid or not backpack or character ~= player.Character then return end
        local preferred = Config.Guns[player:GetAttribute('PreferredWeapon') or 'W1'] or Config.Guns.W1
        local ak = backpack:FindFirstChild(preferred.Name) or backpack:WaitForChild(preferred.Name, 8)
        if ak and character == player.Character and humanoid.Health > 0 then humanoid:EquipTool(ak) end
        connect(humanoid.Died, clear)
    end)
end
function Controller.Start()
    if started then return Controller end
    started = true
    camera = workspace.CurrentCamera
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
    UserInputService.MouseIconEnabled = false
    createHUD()
    -- Local-only diagnostics/commands; no RemoteEvents or server damage authority.
    controlBridge = Instance.new('BindableFunction')
    controlBridge.Name = 'ReferenceFPSControl'
    controlBridge.OnInvoke = function(action, value)
        if action == 'TestMode' then
            testing, trigger, sprinting, aiming = value == true, false, false, false
            if testing then
                ContextActionService:BindActionAtPriority('ReferenceFPS_TestKeys', function() return Enum.ContextActionResult.Sink end, false, 4000,
                    Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five)
            else ContextActionService:UnbindAction('ReferenceFPS_TestKeys') end
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not testing)
            return true
        elseif action == 'Fire' then return Controller.Fire()
        elseif action == 'Reload' then return Controller.Reload()
        elseif action == 'Inspect' then return Controller.Inspect()
        elseif action == 'Aim' then Controller.SetAim(value); return true end
        return Controller.GetState()
    end
    controlBridge.Parent = player:WaitForChild('PlayerScripts')
    local backpack = player:WaitForChild('Backpack')
    for _, child in ipairs(backpack:GetChildren()) do hookTool(child) end
    connect(backpack.ChildAdded, hookTool)
    connect(player.CharacterAdded, hookCharacter)
    if player.Character then hookCharacter(player.Character) end
    connect(UserInputService.InputBegan, function(input, processed)
        if processed or testing or player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = true; Controller.Fire()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(true)
        elseif input.KeyCode == Enum.KeyCode.R then Controller.Reload()
        elseif input.KeyCode == Enum.KeyCode.F then Controller.Inspect()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(false)
        end
    end)
    connect(UserInputService.WindowFocusReleased, function() trigger, aiming, sprinting = false, false, false end)
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 2, render)
    return Controller
end
function Controller.Destroy()
    clear()
    RunService:UnbindFromRenderStep(renderName)
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    for ob, transparency in pairs(hidden) do if ob.Parent then ob.LocalTransparencyModifier = transparency end end
    for _, c in ipairs(casings) do c.Part:Destroy() end
    if hud then hud:Destroy() end
    if controlBridge then controlBridge:Destroy(); controlBridge = nil end
    ContextActionService:UnbindAction('ReferenceFPS_TestKeys')
    if testing then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end
    testing = false
    UserInputService.MouseIconEnabled = true
    connections, crossLines, casings, hidden = {}, {}, {}, setmetatable({}, {__mode = 'k'})
    hooked = setmetatable({}, {__mode = 'k'})
    started = false
end
return Controller]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeAKClient]====] ]=[====[-- Claude's guns client: firing feel (recoil climb, shake, screen fuzz, smoke, shells, tracers, impacts,
-- dynamic crosshair, hit markers, reload sound). Visuals only. The server decides every hit.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package:WaitForChild("Config"))
local Fx = require(package:WaitForChild("Fx"))
local Controller = require(ReplicatedStorage:WaitForChild("ReferenceWeapons"):WaitForChild("Controller"))

local player = Players.LocalPlayer
local random = Random.new()

local pendingPitch, pendingYaw = 0, 0
local shake, lastShake = 0, CFrame.identity
local heat, lastShotAt, smokeTimer = 0, -10, 0
local fuzz, flash, bloom = 0, 0, 0
local activeModel, activeSpec

-- pre-made shot sounds per weapon so rapid fire overlaps cleanly
local shotSounds, shotIndex = {}, {}
for id, w in Config.Weapons do
	shotSounds[id], shotIndex[id] = {}, 0
	for i = 1, 4 do
		local s = Instance.new("Sound")
		s.Name = "ClaudeShot" .. id .. "_" .. i
		s.SoundId = w.Shot
		s.Volume = w.ShotVolume or 0.7
		s.Parent = SoundService
		shotSounds[id][i] = s
	end
end
local reloadSound = Instance.new("Sound")
reloadSound.Name = "ClaudeReload"
reloadSound.Volume = 0.6
reloadSound.Parent = SoundService

-- screen fuzz: world blurs and pops for a split second, the viewmodel (GUI) stays sharp
local blur = Instance.new("BlurEffect")
blur.Name = "ClaudeGunFuzz"
blur.Size = 0
blur.Parent = Lighting
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ClaudeGunFlash"
grade.Parent = Lighting

local function weaponFor(spec)
	return spec and Config.Weapons[spec.Id]
end

local function muzzleFrame(model, spec)
	local root = model.PrimaryPart.CFrame
	return CFrame.lookAlong((root * CFrame.new(spec.Muzzle)).Position, root.LookVector), root
end

local function spreadDirection(look, degrees)
	local cf = CFrame.lookAlong(Vector3.zero, look)
	local angle = math.rad(degrees) * math.sqrt(random:NextNumber())
	local spin = random:NextNumber(0, math.pi * 2)
	return (cf * CFrame.Angles(0, 0, spin) * CFrame.Angles(angle, 0, 0)).LookVector
end

local function rayParams()
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = {player.Character, Fx.GetFolder()}
	return p
end

-- hit marker + dynamic crosshair
local gui = Instance.new("ScreenGui")
gui.Name = "ClaudeGunHUD"
gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = true, false, 9
gui.Parent = player:WaitForChild("PlayerGui")
local function line(parent, w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(w, h)
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Parent = parent
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(0, 0, 0)
	st.Transparency = 0.5
	st.Parent = f
	return f, st
end
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.Size = UDim2.fromOffset(1, 1)
cross.BackgroundTransparency = 1
cross.Visible = false
cross.Parent = gui
local arms = {}
for i, dir in {Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)} do
	local f, st = line(cross, dir.X ~= 0 and 9 or 2, dir.Y ~= 0 and 9 or 2)
	arms[i] = {Frame = f, Stroke = st, Dir = dir}
end
local dot, dotStroke = line(cross, 2, 2)

local marker = Instance.new("Frame")
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Position = UDim2.fromScale(0.5, 0.5)
marker.Size = UDim2.fromOffset(28, 28)
marker.BackgroundTransparency = 1
marker.Parent = gui
local ticks = {}
for i = 1, 4 do
	local f = Instance.new("Frame")
	local a = math.rad(45 + 90 * i)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(9, 2)
	f.Position = UDim2.new(0.5, math.cos(a) * 9, 0.5, math.sin(a) * 9)
	f.Rotation = 45 + 90 * i
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 1
	f.Parent = marker
	ticks[i] = f
end
local markerTween
local function showHit(headshot, killed)
	local color = killed and Color3.fromRGB(255, 70, 60) or (headshot and Color3.fromRGB(255, 214, 90) or Color3.new(1, 1, 1))
	marker.Size = UDim2.fromOffset(killed and 40 or 28, killed and 40 or 28)
	for _, f in ticks do
		f.BackgroundColor3 = color
		f.BackgroundTransparency = 0
		TweenService:Create(f, TweenInfo.new(killed and 0.45 or 0.22), {BackgroundTransparency = 1}):Play()
	end
	if markerTween then markerTween:Cancel() end
	markerTween = TweenService:Create(marker, TweenInfo.new(0.12), {Size = UDim2.fromOffset(22, 22)})
	markerTween:Play()
end

local function onShot(spec, model, aiming)
	local weapon = weaponFor(spec)
	if not weapon or not model or not model.PrimaryPart then return end
	activeModel, activeSpec = model, spec
	local camera = workspace.CurrentCamera
	local camCF = camera.CFrame
	local third = player:GetAttribute("ThirdPersonView") ~= false
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local worldModel = tool and tool:FindFirstChild("WorldModel")
	local worldRoot = worldModel and worldModel:FindFirstChild("Root")
	-- aim point: from the camera through the crosshair
	local aimDir = spreadDirection(camCF.LookVector, (aiming and weapon.SpreadAim or weapon.SpreadHip) + bloom * 0.04)
	local camHit = workspace:Raycast(camCF.Position, aimDir * Config.Range, rayParams())
	local aimPoint = camHit and camHit.Position or camCF.Position + aimDir * Config.Range
	local origin, muzzle, root
	if third and head and worldRoot then
		-- third person: bullets leave from the head line toward the crosshair, effects at the gun in your hands
		origin = head.Position
		root = worldRoot.CFrame
		local m = worldRoot:FindFirstChild("Muzzle")
		muzzle = CFrame.lookAt(m and m.WorldPosition or root.Position, aimPoint)
	else
		origin = camCF.Position
		muzzle, root = muzzleFrame(model, spec)
	end
	local dir = (aimPoint - origin).Unit

	package.Shoot:FireServer(origin, dir)

	shotIndex[spec.Id] = shotIndex[spec.Id] % 4 + 1
	local snd = shotSounds[spec.Id][shotIndex[spec.Id]]
	snd.PlaybackSpeed = random:NextNumber(0.95, 1.05)
	snd.TimePosition = 0
	snd:Play()

	Fx.Muzzle(muzzle, not third, weapon.FlashScale)
	local pellets = weapon.Pellets or 1
	for i = 1, pellets do
		local d = pellets > 1 and spreadDirection(dir, weapon.PelletSpread or 4) or dir
		local hit = workspace:Raycast(origin, d * Config.Range, rayParams())
		local hitPos = hit and hit.Position or origin + d * Config.Range
		if i <= 4 then Fx.Tracer(muzzle.Position + muzzle.LookVector * 0.3, hitPos) end
		if hit then
			local m2 = hit.Instance:FindFirstAncestorOfClass("Model")
			local isChar = m2 and m2:FindFirstChildOfClass("Humanoid") ~= nil
			Fx.Impact(hit.Position, hit.Normal, hit.Material, hit.Instance.Color, isChar, i == 1)
		end
	end
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local port = root * CFrame.new(weapon.Eject)
	task.delay(0.02, Fx.Shell, port, root.RightVector + root.UpVector * 0.35, hrp and hrp.AssemblyLinearVelocity, weapon.ShellSize)

	local aimScale = aiming and 0.7 or 1
	pendingPitch += math.rad(weapon.ClimbPitch * aimScale * random:NextNumber(0.85, 1.15))
	pendingYaw += math.rad(weapon.ClimbYaw * aimScale * random:NextNumber(-1, 1.25))
	shake = math.min(shake + (aiming and 0.5 or 1) * weapon.Shake, 3)
	fuzz = math.min(fuzz + weapon.Fuzz * (third and 0.5 or 1), 1.6)
	flash = 1
	bloom = math.min(bloom + (spec.Pistol and 9 or 6), 26)
	heat = math.min(heat + 1, 20)
	lastShotAt = os.clock()
end
Controller.Shot:Connect(onShot)

package.HitConfirm.OnClientEvent:Connect(showHit)

-- reload sound, synced to the reload length
player:GetAttributeChangedSignal("FPSReloading"):Connect(function()
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	if player:GetAttribute("FPSReloading") and weapon and weapon.Reload then
		reloadSound.SoundId = weapon.Reload
		reloadSound.PlaybackSpeed = (weapon.ReloadClipLength or weapon.ReloadTime) / weapon.ReloadTime
		reloadSound.TimePosition = 0
		reloadSound:Play()
	else
		reloadSound:Stop()
	end
end)

local MATERIALS = {}
for _, m in Enum.Material:GetEnumItems() do MATERIALS[m.Name] = m end

-- other players' shots: flash at their gun, tracer, impact, 3D sound
package.Replicate.OnClientEvent:Connect(function(shooter, hitPos, normal, materialName, isChar, weaponId)
	local weapon = Config.Weapons[weaponId or "W1"] or Config.Weapons.W1
	local character = shooter and shooter.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local muzzleAttachment = tool and tool:FindFirstChild("Muzzle", true)
	local head = character and character:FindFirstChild("Head")
	local from = muzzleAttachment and muzzleAttachment.WorldPosition or (head and head.Position)
	if not from then return end
	local dir = (hitPos - from)
	if dir.Magnitude < 0.01 then return end
	local cf = CFrame.lookAlong(from, dir.Unit)
	Fx.Muzzle(cf, false, weapon.FlashScale)
	Fx.Tracer(from, hitPos)
	local soundParent = muzzleAttachment and muzzleAttachment.Parent or head
	Fx.Sound(weapon.Shot, soundParent, 0.9, random:NextNumber(0.95, 1.05))
	local color
	local probe = workspace:Raycast(hitPos + normal * 0.3, -normal * 0.6, rayParams())
	if probe then color = probe.Instance.Color end
	Fx.Impact(hitPos, normal, MATERIALS[materialName] or Enum.Material.Concrete, color, isChar, true)
	if tool and tool:FindFirstChild("Handle") then
		local h = tool.Handle.CFrame
		Fx.Shell(CFrame.lookAlong(h.Position, dir.Unit), CFrame.lookAlong(Vector3.zero, dir.Unit).RightVector, Vector3.zero, weapon.ShellSize)
	end
end)

-- blocky Roblox arms on Claude's guns take the player's skin and sleeve colors
local function paintArms()
	local skin = player:GetAttribute("EquippedHandColor")
	local sleeve = player:GetAttribute("EquippedSleeveColor")
	local character = player.Character
	local bodyColors = character and character:FindFirstChildOfClass("BodyColors")
	if not skin and bodyColors then skin = bodyColors.RightArmColor3 end
	for id in Config.Weapons do
		local template = ReplicatedStorage.ReferenceWeapons.Viewmodels:FindFirstChild(id)
		if template then
			for _, p in template:GetChildren() do
				local kind = p:GetAttribute("ArmPart")
				if kind == "Skin" and skin then p.Color = skin end
				if kind == "Sleeve" and sleeve then p.Color = sleeve end
			end
		end
	end
end
paintArms()
player:GetAttributeChangedSignal("EquippedHandColor"):Connect(paintArms)
player:GetAttributeChangedSignal("EquippedSleeveColor"):Connect(paintArms)
player.CharacterAdded:Connect(function() task.wait(1); paintArms() end)

local hudMark
RunService:BindToRenderStep("ClaudeGunFeel", Enum.RenderPriority.Camera.Value + 3, function(dt)
	dt = math.min(dt, 0.05)
	local camera = workspace.CurrentCamera
	if not camera then return end
	-- climb: eased in over a few frames, never undone
	local k = 1 - math.exp(-dt * 28)
	local p, y = pendingPitch * k, pendingYaw * k
	pendingPitch -= p
	pendingYaw -= y
	-- shake: random jitter that is undone next frame
	shake *= math.exp(-dt * 16)
	local amp = math.rad(0.18) * shake
	local newShake = CFrame.Angles(random:NextNumber(-amp, amp), random:NextNumber(-amp, amp), random:NextNumber(-amp, amp) * 1.6)
	camera.CFrame = camera.CFrame * lastShake:Inverse() * CFrame.Angles(p, y, 0) * newShake
	lastShake = newShake
	-- fuzz + flash pop
	fuzz *= math.exp(-dt * 11)
	flash *= math.exp(-dt * 32)
	blur.Size = math.clamp(fuzz * 3.2, 0, 5)
	grade.Brightness = 0.06 * flash
	grade.Contrast = 0.08 * flash
	grade.Saturation = -0.12 * math.min(fuzz, 1)
	-- barrel smoke after bursts
	local now = os.clock()
	if now - lastShotAt > 0.15 then heat = math.max(0, heat - dt * 6) end
	smokeTimer -= dt
	if heat > 4 and now - lastShotAt > 0.1 and smokeTimer <= 0 then
		smokeTimer = 0.07
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		local wm = tool and tool:FindFirstChild("WorldModel")
		local m = wm and wm:FindFirstChild("Muzzle", true)
		if player:GetAttribute("ThirdPersonView") ~= false and m then
			Fx.BarrelSmoke(m.WorldCFrame, math.clamp(heat / 15, 0.2, 1))
		elseif activeModel and activeModel.Parent and activeModel.PrimaryPart then
			Fx.BarrelSmoke(muzzleFrame(activeModel, activeSpec), math.clamp(heat / 15, 0.2, 1))
		end
	end
	-- dynamic crosshair: opens with shots, movement and jumping, fades when aiming
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	local show = weapon ~= nil and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
	cross.Visible = show
	hudMark = hudMark and hudMark.Parent and hudMark or player.PlayerGui:FindFirstChild("AimMark", true)
	if hudMark and hudMark ~= cross then hudMark.Visible = not show end
	if show then
		bloom *= math.exp(-dt * 7)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local speed = root and (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude or 0
		local air = humanoid and humanoid.FloorMaterial == Enum.Material.Air and 10 or 0
		local aim = player:GetAttribute("FPSAiming") and 1 or 0
		local gap = 6 + bloom + math.min(speed, 24) * 0.45 + air
		for _, a in arms do
			a.Frame.Position = UDim2.fromOffset(a.Dir.X * (gap + 4.5), a.Dir.Y * (gap + 4.5))
			a.Frame.BackgroundTransparency = aim * 0.95
			a.Stroke.Transparency = 0.5 + aim * 0.5
		end
		dot.BackgroundTransparency = aim
		dotStroke.Transparency = 0.5 + aim * 0.5
	end
end)
]====],
[ [====[ServerScriptService.ClaudeAKServer.Logic]====] ]=[====[-- Server authority for Claude's guns: validates every shot, raycasts, applies damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package.Config)

local Logic = {}
local state = {}
local BODY = {Head = "Head", UpperTorso = "Body", LowerTorso = "Body", Torso = "Body", HumanoidRootPart = "Body"}

local function finiteVector(v)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 1e6 and math.abs(v.Y) < 1e6 and math.abs(v.Z) < 1e6
end

local function equippedWeapon(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	local id = tool and tool:GetAttribute("ReferenceWeaponId")
	return id and Config.Weapons[id], id
end

local function sameTeam(a, b)
	return a.Team ~= nil and a.Team == b.Team and not a.Neutral
end

local random = Random.new()

-- one ray: skips invisible non-solid parts, returns the hit and the humanoid/zone if it hit a character
local function castRay(character, origin, direction)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {character}
	local fx = workspace:FindFirstChild("ClaudeAKFx")
	if fx then table.insert(ignore, fx) end
	params.FilterDescendantsInstances = ignore
	local result
	local from = origin
	local remaining = Config.Range
	for _ = 1, 6 do
		result = workspace:Raycast(from, direction * remaining, params)
		if not result then break end
		local inst = result.Instance
		local m = inst:FindFirstAncestorOfClass("Model")
		if (m and m:FindFirstChildOfClass("Humanoid")) or inst.CanCollide or inst.Transparency < 0.9 then break end
		table.insert(ignore, inst)
		params.FilterDescendantsInstances = ignore
		remaining -= (result.Position - from).Magnitude
		from = result.Position
		result = nil
	end
	if not result then return origin + direction * Config.Range, Vector3.yAxis, "" end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local target = model and model:FindFirstChildOfClass("Humanoid")
	if not target or target.Health <= 0 or model == character then
		return result.Position, result.Normal, result.Material.Name
	end
	local partName = result.Instance.Name
	if result.Instance:FindFirstAncestorOfClass("Accessory") then partName = "Head" end
	return result.Position, result.Normal, result.Material.Name, target, BODY[partName] or "Limb", (result.Position - origin).Magnitude
end

local function onShoot(player, origin, direction)
	if not finiteVector(origin) or not finiteVector(direction) then return end
	if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end
	direction = direction.Unit
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end
	local weapon, weaponId = equippedWeapon(character)
	if not weapon then return end
	-- origin must be near the shooter's head (camera); otherwise use the head
	if (origin - head.Position).Magnitude > 7 then origin = head.Position end
	local now = os.clock()
	state[player] = state[player] or {}
	local s = state[player][weaponId]
	if not s then s = {Last = 0, Mag = weapon.MagazineSize}; state[player][weaponId] = s end
	if s.Mag <= 0 then
		if now - s.Last < weapon.ReloadTime * 0.75 then return end
		s.Mag = weapon.MagazineSize
	end
	if now - s.Last < 60 / weapon.RPM * 0.8 then return end
	s.Last = now
	s.Mag -= 1

	local pellets = weapon.Pellets or 1
	local totals = {}
	for i = 1, pellets do
		local dir = direction
		if pellets > 1 then
			local cf = CFrame.lookAlong(Vector3.zero, direction)
			local a = math.rad(weapon.PelletSpread or 4) * math.sqrt(random:NextNumber())
			dir = (cf * CFrame.Angles(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.Angles(a, 0, 0)).LookVector
		end
		local hitPos, normal, material, target, zone, dist = castRay(character, origin, dir)
		if target then
			local victim = Players:GetPlayerFromCharacter(target.Parent)
			if not (victim and sameTeam(player, victim)) then
				local falloff = 1 - math.clamp((dist - weapon.FalloffNear) / (weapon.FalloffFar - weapon.FalloffNear), 0, 1) * (1 - weapon.MinScale)
				local t = totals[target] or {Damage = 0, Head = false}
				t.Damage += weapon.Damage[zone] * falloff
				t.Head = t.Head or zone == "Head"
				totals[target] = t
			end
		end
		if i <= 4 then
			for _, other in Players:GetPlayers() do
				if other ~= player then
					package.Replicate:FireClient(other, player, hitPos, normal, material, target ~= nil, weaponId)
				end
			end
		end
	end
	for target, t in totals do
		if target.Health > 0 then
			local damage = math.floor(t.Damage + 0.5)
			target:TakeDamage(damage)
			package.HitConfirm:FireClient(player, t.Head, target.Health <= 0, damage)
		end
	end
end

-- third-person aim pitch, shared with every client for the arm pose
local lastPitch = {}
local function onAimPitch(player, pitch)
	if typeof(pitch) ~= "number" or pitch ~= pitch then return end
	local now = os.clock()
	if now - (lastPitch[player] or 0) < 0.05 then return end
	lastPitch[player] = now
	player:SetAttribute("AimPitch", math.clamp(pitch, -1.3, 1.3))
end

function Logic.Start()
	package.Shoot.OnServerEvent:Connect(onShoot)
	package.AimPitch.OnServerEvent:Connect(onAimPitch)
	Players.PlayerRemoving:Connect(function(p) state[p] = nil end)
end

return Logic
]====],
}
for path,source in baseline do ensure(path).Source=source end
ensure("ServerStorage.SurvivalBedAsset","Model");ensure("ServerStorage.SurvivalZombieRig","Model");ensure("Workspace","Folder")
local pads=ensure("Workspace.SurvivorLobby.Queues","Folder")
for _,mode in {"Solos","Duos","Trios","Squads"}do for i=1,2 do local path="Workspace.SurvivorLobby.Queues."..mode.."_"..i;ensure(path,"Model");ensure(path..".LabelAnchor.QueueLabel","BillboardGui");ensure(path..".LabelAnchor.QueueLabel.Timer","TextLabel").Text="15 (sec)"end end
local installed=(function()local game=fixture
local expected={
[ [====[ReplicatedStorage.LobbySystem.Config]====] ]=[====[local C = {
    TeamName = "Survivors",
    TeamColor = BrickColor.new("Earth green"),
    LobbyCenter = Vector3.new(1000, 0, 0),
    LobbySpawn = CFrame.lookAt(Vector3.new(1000, 4.5, 20), Vector3.new(1000, 4.5, -5)),
    ArenaSpawn = CFrame.lookAt(Vector3.new(0, 4.6, 0), Vector3.new(0, 4.6, -15)),
    Countdown = 15,
    ScanInterval = .2,
    Modes = {
        {Id="Solos", Size=1, X=-63, Color=Color3.fromRGB(75,210,156)},
        {Id="Duos", Size=2, X=-21, Color=Color3.fromRGB(64,170,243)},
        {Id="Trios", Size=3, X=21, Color=Color3.fromRGB(180,125,249)},
        {Id="Squads", Size=4, X=63, Color=Color3.fromRGB(245,173,77)},
    },
}
C.Queues = {}
for _,mode in C.Modes do
    for slot=1,2 do
        table.insert(C.Queues, {
            Id=mode.Id.."_"..slot, Mode=mode.Id, Slot=slot, Size=mode.Size,
            X=mode.X, Z=slot==1 and -9 or 9, Radius=7, Color=mode.Color,
        })
    end
end
return C
]====],
[ [====[ServerScriptService.LobbySystem.Queue]====] ]=[====[-- Pure co-op queue kernel. No Player instances, remotes or world mutations.
local Q={}
Q.__index=Q
function Q.new(modes,countdown)
    local self=setmetatable({Queues={},Membership={},Countdown=countdown},Q)
    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0} end
    return self
end
function Q:Remove(id)
    local mode=self.Membership[id]
    if not mode then return false end
    local q=self.Queues[mode]
    for i,v in q.Members do if v==id then table.remove(q.Members,i);break end end
    q.Deadline=nil;q.Generation+=1
    self.Membership[id]=nil
    return true
end
function Q:Add(id,mode)
    local q=self.Queues[mode]
    if not q then return false,"Unknown queue" end
    if self.Membership[id]==mode then return true end
    if #q.Members>=q.Size then return false,"Queue full" end
    self:Remove(id)
    table.insert(q.Members,id);self.Membership[id]=mode;q.Deadline=nil;q.Generation+=1
    return true
end
function Q:Step(now,eligible)
    local launches={}
    for mode,q in self.Queues do
        local remove={}
        for _,id in q.Members do if not eligible(id,mode) then table.insert(remove,id) end end
        for _,id in remove do self:Remove(id) end
        if #q.Members==q.Size then
            if not q.Deadline then q.Deadline=now+self.Countdown end
            if now>=q.Deadline then
                local members=table.clone(q.Members)
                for _,id in members do self.Membership[id]=nil end
                q.Members={};q.Deadline=nil;q.Generation+=1
                table.insert(launches,{Mode=mode,Members=members})
            end
        else q.Deadline=nil end
    end
    return launches
end
function Q:Snapshot()
    local result={}
    for mode,q in self.Queues do result[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline} end
    return result
end
return Q
]====],
[ [====[ServerScriptService.LobbySystem.Service]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local PhysicsService=game:GetService("PhysicsService")
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local Queue=require(script.Parent.Queue)
local S={}
local states,links={},{}
local queue=Queue.new(C.Queues,C.Countdown)
local queueById={}
for _,descriptor in C.Queues do queueById[descriptor.Id]=descriptor end
local started=false
local world,team,toolRoot
local rejected,launched=0,0
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function charState(p)
    local char=p.Character
    local h=char and char:FindFirstChildOfClass("Humanoid")
    local r=char and char:FindFirstChild("HumanoidRootPart")
    return char,h,r
end
local function inPad(p,mode)
    local s=states[p]
    if not s or s.Phase~="Lobby" then return false end
    local _,h,r=charState(p)
    local pad=world.Queues:FindFirstChild(mode)
    if not h or h.Health<=0 or not r or not pad then return false end
    local point=pad.Zone.CFrame:PointToObjectSpace(r.Position)
    local radius=pad:GetAttribute("Radius") or 7
    return point.X*point.X+point.Z*point.Z<=radius*radius and point.Y>=-2 and point.Y<=10
end
local function region(p)
    for _,m in C.Queues do if inPad(p,m.Id) then return m.Id end end
end
local function setMode(p,id)
    local descriptor=id and queueById[id]
    p:SetAttribute("QueuedQueueId",id or "")
    p:SetAttribute("QueuedMode",descriptor and descriptor.Mode or "")
end
local function haltSlide(p)
    local movement=game.ServerScriptService:FindFirstChild("GameplayMovement")
    local control=movement and movement:FindFirstChild("MovementControl")
    if control then control:Invoke(p,"CancelSlide");control:Invoke(p,"Crouch",false) end
end
local function pivot(p,transform)
    haltSlide(p)
    local char,_,root=charState(p)
    char:PivotTo(transform)
    if root then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
end
local function strip(p,tool)
    local s=states[p]
    if s and s.Phase=="Lobby" and tool:IsA("Tool") then tool.Parent=s.Tools end
end
local function restoreTools(p)
    local s=states[p]
    local backpack=p:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    for _,t in s.Tools:GetChildren() do t.Parent=backpack end
    local char,h=charState(p)
    if char and h then
        local preferred
        for _,t in backpack:GetChildren() do if t:IsA("Tool") and t:GetAttribute("ReferenceWeaponId")==(p:GetAttribute("PreferredWeapon") or "W1") then preferred=t;break end end
        if preferred then h:EquipTool(preferred) end
    end
end
local function phase(p,value)
    local s=states[p];s.Phase=value
    p:SetAttribute("InLobby",value=="Lobby")
    p:SetAttribute("InMenu",value=="Lobby")
    p:SetAttribute("LobbyPhase",value)
    p:SetAttribute("MenuClientOpen",false)
    p.Team=team;p.Neutral=false
    p.RespawnLocation=world.Spawn
end
local function endSurvival(p,s)
    if s.RunStart then s.Best=math.max(s.Best,math.floor(os.clock()-s.RunStart));s.RunStart=nil end
    p:SetAttribute("BestSurvival",s.Best)
end
local function protectLobby(char)
    local force=char:FindFirstChild("LobbyShield")
    if not force then force=Instance.new("ForceField");force.Name="LobbyShield";force.Visible=false;force.Parent=char end
end
function S.Return(p,respawn)
    local s=states[p];if not s then return false end
    endSurvival(p,s)
    queue:Remove(p.UserId);setMode(p,nil)
    s.Blocked=region(p)
    s.Generation+=1
    phase(p,"Lobby")
    p:SetAttribute("CoopPartyId","");p:SetAttribute("CoopPartySize",0);p:SetAttribute("CoopMode","");p:SetAttribute("CoopQueueId","")
    local char,h=charState(p)
    if respawn or not h or h.Health<=0 then
        if s.Busy then return false end
        s.Busy=true
        s.Tools:ClearAllChildren() -- Fresh characters receive a fresh StarterPack; never accumulate duplicates.
        local ok=pcall(function() p:LoadCharacterAsync() end)
        s.Busy=false
        if not ok then p:SetAttribute("LobbyNotice","Spawn retry in progress");task.delay(3,function() if states[p]==s then S.Return(p,true) end end) end
        return ok
    end
    h:UnequipTools()
    for _,t in char:GetChildren() do strip(p,t) end
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then for _,t in backpack:GetChildren() do strip(p,t) end end
    protectLobby(char)
    pivot(p,C.LobbySpawn)
    return true
end
local function deploy(group)
    local members={}
    for _,id in group.Members do
        local p=Players:GetPlayerByUserId(id)
        local s=p and states[p]
        if p then
            local _,h,r=charState(p)
            if s and s.Phase=="Lobby" and h and h.Health>0 and r and inPad(p,group.Mode) then table.insert(members,p) end
        end
    end
    local descriptor=queueById[group.Mode]
    local expected=descriptor and descriptor.Size
    if #members~=expected then for _,p in members do setMode(p,nil) end return false end
    local party=game.HttpService:GenerateGUID(false)
    for _,p in members do
        local s=states[p];s.Generation+=1;s.RunStart=os.clock()
        phase(p,"Deployed");setMode(p,nil)
        p:SetAttribute("CoopPartyId",party);p:SetAttribute("CoopPartySize",#members);p:SetAttribute("CoopMode",descriptor.Mode);p:SetAttribute("CoopQueueId",group.Mode)
        local char=p.Character
        local shield=char:FindFirstChild("LobbyShield");if shield then shield:Destroy() end
        pivot(p,C.ArenaSpawn)
        s.LastSpawn=char:GetPivot().Position
        p:SetAttribute("LastDeploymentSpawn",s.LastSpawn)
        restoreTools(p)
        local protection=Instance.new("ForceField");protection.Name="CoopSpawnShield";protection.Visible=false;protection.Parent=char
        game.Debris:AddItem(protection,5)
        launched+=1
    end
    return true
end
local function character(p,char)
    local s=states[p];if not s then return end
    s.Generation+=1
    phase(p,"Lobby");setMode(p,nil);queue:Remove(p.UserId)
    task.spawn(function()
        local h=char:WaitForChild("Humanoid",10)
        local root=char:WaitForChild("HumanoidRootPart",10)
        if not h or not root or states[p]~=s or p.Character~=char then return end
        local function child(o)
            if o:IsA("BasePart") then o.CollisionGroup="CoopSurvivors" end
            if o:IsA("Tool") then strip(p,o) end
        end
        for _,o in char:GetDescendants() do child(o) end
        char.DescendantAdded:Connect(child)
        protectLobby(char)
        pivot(p,C.LobbySpawn)
        h.WalkSpeed=14
        h.Died:Connect(function()
            if states[p]~=s or p.Character~=char then return end
            endSurvival(p,s)
            queue:Remove(p.UserId);setMode(p,nil)
            phase(p,"Lobby")
            task.delay(2.5,function() if states[p]==s and p.Character==char then S.Return(p,true) end end)
        end)
    end)
end
local function added(p)
    if states[p] then return end
    local tools=Instance.new("Folder");tools.Name=tostring(p.UserId);tools.Parent=toolRoot
    local s={Phase="Lobby",Tools=tools,Best=0,Tokens=4,TokenTime=os.clock(),Generation=0,Links={}}
    states[p]=s
    local function link(signal,fn) local c=signal:Connect(fn);table.insert(s.Links,c);return c end
    p:SetAttribute("PreferredWeapon",p:GetAttribute("PreferredWeapon") or "W1")
    p:SetAttribute("BestSurvival",0);setMode(p,nil);phase(p,"Lobby")
    link(p:GetPropertyChangedSignal("Team"),function() if states[p] and p.Team~=team then p.Team=team;p.Neutral=false end end)
    link(p.CharacterAdded,function(char) character(p,char) end)
    local function backpackAdded(backpack)
        if not backpack:IsA("Backpack") or s.Backpack==backpack then return end
        s.Backpack=backpack
        if s.BackpackLink then s.BackpackLink:Disconnect() end
        s.BackpackLink=backpack.ChildAdded:Connect(function(t) strip(p,t) end)
        for _,t in backpack:GetChildren() do strip(p,t) end
    end
    link(p.ChildAdded,backpackAdded)
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then backpackAdded(backpack) end
    if p.Character then character(p,p.Character) else task.spawn(function() S.Return(p,true) end) end
end
function S.Handle(p,action,...)
    local s=states[p]
    if not s or p.Parent~=Players or type(action)~="string" or #action>12 or select("#",...)~=0 then rejected+=1;return false end
    local now=os.clock()
    s.Tokens=math.min(4,s.Tokens+(now-s.TokenTime)*2);s.TokenTime=now
    if s.Tokens<1 then rejected+=1;return false end
    s.Tokens-=1
    if action=="Leave" and s.Phase=="Lobby" then
        s.Blocked=queue.Membership[p.UserId] or region(p)
        queue:Remove(p.UserId);setMode(p,nil)
        return true
    elseif action=="Return" and s.Phase=="Deployed" then return S.Return(p,false) end
    rejected+=1;return false
end
local function scan()
    for p,s in states do
        local _,h,r=charState(p)
        if s.Phase=="Lobby" and h and h.Health>0 and r then
            local mode=region(p)
            if s.Blocked and mode~=s.Blocked then s.Blocked=nil end
            local old=queue.Membership[p.UserId]
            if old and old~=mode then queue:Remove(p.UserId);setMode(p,nil) end
            if mode and s.Blocked~=mode then
                if queue:Add(p.UserId,mode) then setMode(p,mode) end
            end
            local offset=r.Position-C.LobbyCenter
            if math.abs(offset.X)>110 or math.abs(offset.Z)>83 or r.Position.Y<-10 then pivot(p,C.LobbySpawn) end
        end
    end
    for _,group in queue:Step(workspace:GetServerTimeNow(),function(id,mode)
        local p=Players:GetPlayerByUserId(id);return p and inPad(p,mode) or false
    end) do deploy(group) end
    for _,m in C.Queues do
        local q=queue.Queues[m.Id]
        local pad=world.Queues[m.Id]
        pad:SetAttribute("QueueCount",#q.Members);pad:SetAttribute("DepartureAt",q.Deadline or 0)
    end
end
local function board()
    local rows={}
    for p,s in states do
        local kills=p:GetAttribute("ZombieKills")
        local stats=p:FindFirstChild("leaderstats")
        local stat=stats and stats:FindFirstChild("ZombieKills")
        if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then kills=stat.Value end
        if type(kills)~="number" or kills~=kills or math.abs(kills)>1e9 then kills=0 end
        local best=math.max(s.Best,s.RunStart and math.floor(os.clock()-s.RunStart) or 0)
        p:SetAttribute("BestSurvival",best)
        table.insert(rows,{Name=p.DisplayName,Kills=math.max(0,math.floor(kills)),Best=best,UserId=p.UserId})
    end
    table.sort(rows,function(a,b) if a.Kills~=b.Kills then return a.Kills>b.Kills end if a.Best~=b.Best then return a.Best>b.Best end return a.UserId<b.UserId end)
    local surface=world.Leaderboard.Board.SurfaceGui
    for i=1,10 do
        local row=surface.Rows:FindFirstChild("Row"..i);local data=rows[i]
        row.NameCell.Text=data and string.format("%02d   %s",i,data.Name) or string.format("%02d   —",i)
        row.Kills.Text=data and tostring(data.Kills) or "—"
        row.Best.Text=data and string.format("%02d:%02d",math.floor(data.Best/60),data.Best%60) or "—"
    end
    world:SetAttribute("LobbyPlayers",#rows)
end
function S.GetState(p)
    local s=p and states[p]
    return {Phase=s and s.Phase,Queued=s and queue.Membership[p.UserId],Queues=queue:Snapshot(),Rejected=rejected,Deployed=launched,LastSpawn=s and s.LastSpawn and tostring(s.LastSpawn),Players=world and world:GetAttribute("LobbyPlayers")}
end
function S.Start()
    if started then return end
    started=true
    world=assert(workspace:FindFirstChild("SurvivorLobby"))
    team=assert(game.Teams:FindFirstChild(C.TeamName))
    pcall(function() PhysicsService:RegisterCollisionGroup("CoopSurvivors") end)
    PhysicsService:CollisionGroupSetCollidable("CoopSurvivors","CoopSurvivors",false)
    Players.CharacterAutoLoads=false
    toolRoot=Instance.new("Folder");toolRoot.Name="RuntimeTools";toolRoot.Parent=script.Parent
    for _,p in Players:GetPlayers() do added(p) end
    connect(Players.PlayerAdded,added)
    connect(Players.PlayerRemoving,function(p)
        queue:Remove(p.UserId)
        local s=states[p];if s then
            for _,c in s.Links do c:Disconnect() end
            if s.BackpackLink then s.BackpackLink:Disconnect() end
            s.Tools:Destroy()
        end
        states[p]=nil
    end)
    connect(package.Request.OnServerEvent,S.Handle)
    local elapsed,boardTime=0,0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;boardTime+=dt
        if elapsed>=C.ScanInterval then elapsed=0;scan() end
        if boardTime>=1 then boardTime=0;board() end
    end)
    local control=Instance.new("BindableFunction");control.Name="Control";control.Parent=script.Parent
    control.OnInvoke=function(p,action) if action=="State" then return S.GetState(p) elseif action=="Return" then return S.Return(p,false) end end
end
return S
]====],
[ [====[ReplicatedStorage.LobbySystem.Client]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local p=Players.LocalPlayer
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local M={}
local started,third=false,true
local gui,panel,queueTitle,queueDetail,back,cameraButton,bridge
local links,parts={},{}
local characterLink
local original={Mode=p.CameraMode,Min=p.CameraMinZoomDistance,Max=p.CameraMaxZoomDistance}
local altered=setmetatable({},{__mode="k"})
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function new(class,props,parent)
    local o=Instance.new(class);for k,v in props do o[k]=v end;o.Parent=parent;return o
end
local function text(name,content,size,pos,parent)
    return new("TextLabel",{Name=name,Text=content,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=Color3.fromRGB(233,237,230),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function camera()
    local char=p.Character
    task.spawn(function()
        local h=char and char:WaitForChild("Humanoid",10)
        if not started or p.Character~=char or not h then return end
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h;cam.FieldOfView=72 end
        p.CameraMinZoomDistance=.5
        p.CameraMode=third and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        p.CameraMaxZoomDistance=third and 8 or .5
        p.CameraMinZoomDistance=third and 8 or .5
        UIS.MouseBehavior=third and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled=third
        p:SetAttribute("ThirdPersonView",third)
        cameraButton.Text=third and "CAM: THIRD  [V]" or "CAM: FIRST  [V]"
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not p:GetAttribute("InLobby")) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true) end)
    end)
end
-- Third person only (Cade, 2026-10-17). Claude's ClaudeThirdPerson script handles the shoulder cam + mouse lock.
function M.SetThirdPerson(value)
    third=true
    camera()
end
local function refresh()
    local lobby=p:GetAttribute("InLobby")==true
    back.Visible=not lobby
    panel.Visible=lobby and (p:GetAttribute("QueuedQueueId") or "")~=""
end
local function hookCharacter(char)
    if characterLink then characterLink:Disconnect() end
    parts={}
    local function add(ob) if ob:IsA("BasePart") then table.insert(parts,ob) end end
    for _,ob in char:GetDescendants() do add(ob) end
    characterLink=char.DescendantAdded:Connect(add)
    camera();refresh()
end
function M.GetStats()
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
    return {ThirdPerson=third,Camera=p.CameraMode.Name,MinZoom=p.CameraMinZoomDistance,MaxZoom=p.CameraMaxZoomDistance,
        Banner=gui and gui:FindFirstChild("Status")~=nil,QueueId=p:GetAttribute("QueuedQueueId"),
        ViewmodelVisible=viewport and viewport.Visible,Connections=#links+(characterLink and 1 or 0)}
end
function M.Start()
    if started then return M end
    started=true
    gui=new("ScreenGui",{Name="SurvivorLobbyUI",ResetOnSpawn=false,DisplayOrder=42,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild("PlayerGui"))
    -- No title/status banner; queue information lives above each physical circle.
    panel=new("Frame",{Name="QueuePanel",Size=UDim2.new(.9,0,0,106),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-25),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.08,BorderSizePixel=0},gui)
    new("UISizeConstraint",{MaxSize=Vector2.new(560,106)},panel)
    new("UICorner",{CornerRadius=UDim.new(0,12)},panel)
    new("UIStroke",{Color=Color3.fromRGB(81,196,144),Transparency=.25},panel)
    queueTitle=text("Mode","",UDim2.new(1,-140,0,30),UDim2.fromOffset(16,13),panel)
    queueDetail=text("Countdown","",UDim2.new(1,-140,0,46),UDim2.fromOffset(16,43),panel);queueDetail.TextSize=12
    local leave=new("TextButton",{Name="LeaveQueue",Text="LEAVE",Size=UDim2.fromOffset(100,40),Position=UDim2.new(1,-116,.5,-20),BackgroundColor3=Color3.fromRGB(55,76,67),TextColor3=Color3.fromRGB(240,244,239),Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0},panel)
    new("UICorner",{CornerRadius=UDim.new(0,7)},leave)
    back=new("TextButton",{Name="ReturnToLobby",Text="LOBBY [M]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-212),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},back)
    cameraButton=new("TextButton",{Name="CameraMode",Text="CAM: THIRD  [V]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-174),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},cameraButton)
    connect(leave.Activated,function() package.Request:FireServer("Leave") end)
    connect(back.Activated,function() package.Request:FireServer("Return") end)
    cameraButton.Visible=false
    connect(UIS.InputBegan,function(input,processed)
        if processed or UIS:GetFocusedTextBox() then return end
        if input.KeyCode==Enum.KeyCode.M and not p:GetAttribute("InLobby") then package.Request:FireServer("Return")
        end
    end)
    RunService:BindToRenderStep("SurvivorLobbyCursor",Enum.RenderPriority.Last.Value+1,function()
        if third then
            -- Character/weapon initialization may request first person after our first camera setup.
            -- Reconcile the selected presentation mode after those render passes, without editing combat.
            if p.CameraMode~=Enum.CameraMode.Classic or p.CameraMinZoomDistance~=8 or p.CameraMaxZoomDistance~=8 then
                p.CameraMinZoomDistance=.5;p.CameraMode=Enum.CameraMode.Classic
                p.CameraMaxZoomDistance=8;p.CameraMinZoomDistance=8
            end
            -- The weapon controller remains untouched. Reveal only this client's world avatar in third person.
            for _,ob in parts do if ob.Parent then
                if altered[ob]==nil then altered[ob]=ob.LocalTransparencyModifier end
                ob.LocalTransparencyModifier=0
            end end
        end
        local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
        local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
        if viewport then viewport.Visible=not third end
    end)
    connect(p:GetAttributeChangedSignal("InLobby"),function() refresh();camera() end)
    connect(p:GetAttributeChangedSignal("QueuedQueueId"),refresh)
    connect(p.CharacterAdded,hookCharacter)
    local world=workspace:WaitForChild("SurvivorLobby")
    local elapsed=0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;if elapsed<.1 then return end;elapsed=0
        for _,descriptor in C.Queues do
            local pad=world.Queues[descriptor.Id]
            local count=pad:GetAttribute("QueueCount") or 0
            local deadline=pad:GetAttribute("DepartureAt") or 0
            local remaining=deadline>0 and math.max(0,math.ceil(deadline-workspace:GetServerTimeNow())) or C.Countdown
            local label=pad.LabelAnchor.QueueLabel
            label.Count.Text=count.."/"..descriptor.Size
            label.Timer.Text=remaining.." (sec)"
            if p:GetAttribute("QueuedQueueId")==descriptor.Id then
                queueTitle.Text=string.upper(descriptor.Mode).." "..descriptor.Slot.."  •  "..count.."/"..descriptor.Size
                queueDetail.Text=deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or ("Waiting for "..math.max(0,descriptor.Size-count).." more survivor(s)")
            end
        end
    end)
    bridge=new("BindableFunction",{Name="LobbyPresentationControl"},p:WaitForChild("PlayerScripts"))
    bridge.OnInvoke=function(action,value) if action=="ThirdPerson" then M.SetThirdPerson(value) end return M.GetStats() end
    refresh()
    if p.Character then hookCharacter(p.Character) end
    return M
end
function M.Destroy()
    started=false
    RunService:UnbindFromRenderStep("SurvivorLobbyCursor")
    for _,c in links do c:Disconnect() end;links={}
    if characterLink then characterLink:Disconnect();characterLink=nil end
    for ob,value in altered do if ob.Parent then ob.LocalTransparencyModifier=value end end
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport");if viewport then viewport.Visible=true end
    p.CameraMinZoomDistance=.5;p.CameraMode=original.Mode;p.CameraMaxZoomDistance=original.Max;p.CameraMinZoomDistance=original.Min
    if gui then gui:Destroy() end;if bridge then bridge:Destroy() end
end
return M
]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementConfig]====] ]=[====[return {
    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=.60, CrouchCameraDrop=.95, SlideSpeed=36, SlideEndSpeed=18,
    SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
    StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
    ExhaustionRecovery=15, HipDrop=1.05, CameraDrop=.65,
    SprintFov=8, SlideFov=10, CameraShakeScale=1,
    MinimapHeight=155, MinimapFov=70,
}
]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementClient]====] ]=[====[local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local C=require(script.Parent.MovementConfig)
local p=Players.LocalPlayer
local remote=script.Parent:WaitForChild('MovementRequest')
local M={}
local started=false
local held,toggled,sent,forced=false,false,false,false
local phase,fov,drop,amount=0,0,0,0
local lastOffset=CFrame.identity
local previousMode='Idle'
local slideAge=10
local oldGrounded=true
local landing=0
local char,hum,root
local baseCameraOffset=Vector3.zero
local queuedSlideUntil=0
local queuedSlideStamp,lastChainAttempt=0,-10
local function deployed()
    return char and char.Parent and hum and hum.Health>0 and ((not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')) or p:GetAttribute('InLobby')==true)
end
local function sendSprint(value)
    if value~=sent then sent=value;remote:FireServer('Sprint',value)end
end
function M.Sprint(value)
    if value and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
    forced=value==true;held=forced
    if not value then toggled=false;sendSprint(false)end
    return true
end
function M.Slide()
    if not deployed() then return false end
    if p:GetAttribute('MovementState')=='Sliding' then
        queuedSlideUntil=os.clock()+C.SlideBuffer
        queuedSlideStamp=p:GetAttribute('SlideStartedAt') or 0
        return true
    end
    local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
    if v.Magnitude<C.SlideMinSpeed or hum.FloorMaterial==Enum.Material.Air then return false end
    remote:FireServer('Slide',v.Unit);return true
end
function M.Crouch(value)
    if not deployed()then return false end
    queuedSlideUntil=0
    if value then held,toggled,forced=false,false,false;sendSprint(false)end
    remote:FireServer('Crouch',value==true)
    return true
end
function M.Stance()
    local mode=p:GetAttribute('MovementState')
    if mode=='Sliding' or mode=='Sprinting'then return M.Slide()end
    return M.Crouch(not p:GetAttribute('MovementCrouched'))
end
function M.CancelSlide()queuedSlideUntil=0;remote:FireServer('CancelSlide');return true end
function M.GetState()
    return {Mode=p:GetAttribute('MovementState') or 'Idle',Stamina=p:GetAttribute('MovementStamina') or 100,
        FovOffset=fov,CameraDrop=drop,ShakeDegrees=amount,SlideReadyIn=p:GetAttribute('SlideReadyIn') or 0,
        WalkSpeed=hum and hum.WalkSpeed,Grounded=hum and hum.FloorMaterial~=Enum.Material.Air,
        Crouched=p:GetAttribute('MovementCrouched')==true,
        CameraOffsetY=hum and hum.CameraOffset.Y,SlideBuffered=queuedSlideUntil>os.clock(),
        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y,Pose=require(script.Parent.CharacterPose).State(p)}
end
local function hook(c)
    char=c;hum=c:WaitForChild('Humanoid');root=c:WaitForChild('HumanoidRootPart')
    held,toggled,sent,forced=false,false,false,false
    baseCameraOffset=hum.CameraOffset;queuedSlideUntil=0
    drop,fov,landing=0,0,0
end
function M.Start()
    if started then return M end;started=true
    if p.Character then task.spawn(hook,p.Character)end
    p.CharacterAdded:Connect(hook)
    require(script.Parent.CharacterPose).Start()
    p.CharacterRemoving:Connect(function(c)
        if char==c then
            if hum and hum.Parent then hum.CameraOffset=baseCameraOffset end
            queuedSlideUntil=0;char,hum,root=nil,nil,nil;sendSprint(false)
        end
    end)
    CAS:BindActionAtPriority('GameplaySprint',function(_,state,input)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
        if input.KeyCode==Enum.KeyCode.ButtonL3 and state==Enum.UserInputState.Begin then toggled=not toggled
        elseif state==Enum.UserInputState.Begin then held=true
        elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false;forced=false end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
    CAS:SetTitle('GameplaySprint','SPRINT');CAS:SetPosition('GameplaySprint',UDim2.fromScale(.72,.72))
    CAS:BindActionAtPriority('GameplaySlide',function(_,state)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin then M.Stance()end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.C,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB)
    CAS:SetTitle('GameplaySlide','CROUCH');CAS:SetPosition('GameplaySlide',UDim2.fromScale(.84,.72))
    UIS.InputBegan:Connect(function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.Space and p:GetAttribute('MovementState')=='Sliding'then M.CancelSlide()end
    end)
    UIS.WindowFocusReleased:Connect(function()held,toggled,forced=false,false,false;queuedSlideUntil=0;sendSprint(false)end)
    p:GetAttributeChangedSignal('MovementFireInterrupt'):Connect(function()sendSprint(false)end)
    local bridge=Instance.new('BindableFunction');bridge.Name='MovementControl'
    bridge.OnInvoke=function(action,value)
        if action=='Sprint'then return M.Sprint(value)
        elseif action=='Slide'then return M.Slide()
        elseif action=='Crouch'then return M.Crouch(value)
        elseif action=='CancelSlide'then return M.CancelSlide()end
        return M.GetState()
    end;bridge.Parent=p:WaitForChild('PlayerScripts')
    RunService:BindToRenderStep('GameplayMovementClean',Enum.RenderPriority.Camera.Value-1,function(dt)
        local camera=workspace.CurrentCamera
        if camera then camera.CFrame=camera.CFrame*lastOffset:Inverse()end
        lastOffset=CFrame.identity
        -- CameraOffset is consumed by Roblox's first-person camera this same frame.
        -- The later viewmodel pass sees the lowered camera without double-applying it.
        local live=deployed()
        local target=live and (p:GetAttribute('MovementState')=='Sliding' and C.CameraDrop or p:GetAttribute('MovementCrouched') and C.CrouchCameraDrop or 0) or 0
        local rate=target>drop and 24 or 14
        drop+=(target-drop)*(1-math.exp(-math.min(dt,.05)*rate))
        if not live then drop=0 end
        if hum and hum.Parent then hum.CameraOffset=baseCameraOffset+Vector3.new(0,-drop,0)end
        p:SetAttribute('MovementCameraDrop',drop)
    end)
    RunService:BindToRenderStep('GameplayMovementCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
        dt=math.min(dt,.05)
        local camera=workspace.CurrentCamera;if not camera then return end
        local live=deployed()
        local wants=live and (held or toggled or forced) and not UIS:GetFocusedTextBox()
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            and (p:GetAttribute('InLobby') or (not p:GetAttribute('FPSAiming') and not p:GetAttribute('FPSReloading'))) and not p:GetAttribute('MovementCrouched')
        sendSprint(wants==true)
        local state=live and p:GetAttribute('MovementState') or 'Idle'
        local sprint,slide=state=='Sprinting',state=='Sliding'
        if not live or not wants then queuedSlideUntil=0
        elseif queuedSlideUntil>0 and slide and (p:GetAttribute('SlideStartedAt') or 0)~=queuedSlideStamp then
            queuedSlideUntil=0
        elseif queuedSlideUntil>0 and not slide then
            if os.clock()<=queuedSlideUntil then
                local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
                if hum.FloorMaterial~=Enum.Material.Air and v.Magnitude>=C.SlideMinSpeed and os.clock()-lastChainAttempt>.12 then
                    lastChainAttempt=os.clock();remote:FireServer('Slide',v.Unit)
                end
            else queuedSlideUntil=0 end
        end
        if slide and previousMode~='Sliding'then slideAge=0 end
        slideAge+=dt
        local grounded=live and hum.FloorMaterial~=Enum.Material.Air
        if grounded and not oldGrounded and live then landing=.65 end
        oldGrounded=grounded;landing*=math.exp(-dt*12)
        previousMode=state
        local targetFov=slide and C.SlideFov or sprint and C.SprintFov or p:GetAttribute('MovementCrouched') and -2 or 0
        fov+=(targetFov-fov)*(1-math.exp(-dt*9))
        p:SetAttribute('MovementFovOffset',fov)
        if not live then amount=0;drop=0;fov=0;return end
        if camera.CameraType~=Enum.CameraType.Custom then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=hum end
        if not char:FindFirstChildOfClass('Tool')then camera.FieldOfView+=(72+fov-camera.FieldOfView)*(1-math.exp(-dt*10))end
        phase+=dt*(sprint and 13 or 9)
        local scale=math.clamp(p:GetAttribute('CameraShakeScale') or C.CameraShakeScale,0,1)
        local entry=slide and math.exp(-slideAge*9) or 0
        local pitch=(sprint and math.sin(phase*2)*.27 or 0)+(slide and math.sin(phase*3.4)*.14-entry*.85 or 0)-landing*.35
        local yaw=(sprint and math.sin(phase)*.15 or 0)+(slide and math.noise(os.clock()*18,2)*.28 or 0)
        local roll=(sprint and math.cos(phase)*.42 or 0)+(slide and entry*1.5+math.sin(phase*3)*.24 or 0)
        pitch,yaw,roll=pitch*scale,yaw*scale,roll*scale
        amount=math.sqrt(pitch*pitch+yaw*yaw+roll*roll)
        local bob=sprint and math.abs(math.sin(phase))*.025*scale or 0
        lastOffset=CFrame.new(0,-bob,0)*CFrame.Angles(math.rad(pitch),math.rad(yaw),math.rad(roll))
        camera.CFrame=camera.CFrame*lastOffset
        -- The weapon controller consumes MovementFovOffset before rendering its viewmodel.
    end)
    return M
end
return M
]====],
[ [====[ReplicatedStorage.GameplayPresentation.CharacterPose]====] ]=[====[-- Client-evaluated R15 pose. Server attributes remain the movement/aim authority.
-- Supports Avatar Joint Upgrade without changing rig attachments or asset IDs.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local C=require(script.Parent.MovementConfig)
local P={}
local started=false
local records={}
local localPlayer=Players.LocalPlayer
local rad=math.rad
local identity=CFrame.identity
local profiles={
    W1={Grip=Vector3.new(.12,.50,-.55),Support=Vector3.new(-.12,.08,-.62)},
    W2={Grip=Vector3.new(.12,.45,-.55),Support=Vector3.new(-.12,.10,-.55)},
    W3={Grip=Vector3.new(.15,.30,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
}
local crouch={Waist=8,LeftHip=-40,RightHip=-40,LeftKnee=80,RightKnee=80,LeftAnkle=-40,RightAnkle=-40}
local slide={
    Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
    Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
    RightHip=CFrame.Angles(rad(95),0,rad(-4)),RightKnee=CFrame.Angles(rad(-8),0,0),
    RightAnkle=CFrame.Angles(rad(-77),0,0),
    LeftHip=CFrame.Angles(rad(110),0,rad(8)),LeftKnee=CFrame.Angles(rad(-145),0,0),
    LeftAnkle=CFrame.Angles(rad(45),0,0),
    RightShoulder=CFrame.Angles(rad(30),0,rad(12)),RightElbow=CFrame.Angles(rad(-35),0,0),
    LeftShoulder=CFrame.Angles(rad(22),0,rad(-25)),LeftElbow=CFrame.Angles(rad(-55),0,0),
}
local function joint(c,name)
    local j=c:FindFirstChild(name,true)
    if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then return j end
end
local function reset(rec)
    for j,saved in rec.Applied do
        -- Do not undo an Animator/another system's newer evaluation.
        if j.Parent and j.Transform==saved.Value then j.Transform=saved.Base end
    end
    rec.Applied={}
end
local function set(rec,j,value)
    if not j or not j.Parent then return end
    local old=rec.Applied[j]
    rec.Applied[j]={Base=old and old.Base or j.Transform,Value=value}
    j.Transform=value
end
local function world(rec,part,cache)
    if cache[part] then return cache[part] end
    local j=rec.ByPart[part]
    local cf
    if j and j.Part0 then cf=world(rec,j.Part0,cache)*j.C0*j.Transform*j.C1:Inverse()
    else cf=part.CFrame end
    cache[part]=cf
    return cf
end
local function segment(localA,localB,worldA,worldB,normal)
    return CFrame.lookAt(worldA,worldB,normal)*CFrame.lookAt(localA,localB,Vector3.zAxis):Inverse()
end
local function arm(rec,side,torsoCF,handCF)
    local sh=rec.Joints[side.."Shoulder"]
    local el=rec.Joints[side.."Elbow"]
    local wr=rec.Joints[side.."Wrist"]
    if not sh or not el or not wr then return nil end
    local a=(torsoCF*sh.C0).Position
    local target=(handCF*wr.C1).Position
    local l1=(el.C0.Position-sh.C1.Position).Magnitude
    local l2=(wr.C0.Position-el.C1.Position).Magnitude
    local delta=target-a
    if l1<.01 or l2<.01 or delta.Magnitude<.01 then return nil end
    local dir=delta.Unit
    local length=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
    local wrist=a+dir*length
    local bend=torsoCF:VectorToWorldSpace(Vector3.new(side=="Right" and .7 or -.7,-1,.25))
    bend-=dir*bend:Dot(dir)
    if bend.Magnitude<.01 then bend=torsoCF.UpVector:Cross(dir) end
    bend=bend.Unit
    local x=(l1*l1-l2*l2+length*length)/(2*length)
    local elbow=a+dir*x+bend*math.sqrt(math.max(0,l1*l1-x*x))
    local normal=dir:Cross(bend).Unit
    local upper=segment(sh.C1.Position,el.C0.Position,a,elbow,normal)
    local lower=segment(el.C1.Position,wr.C0.Position,elbow,wrist,normal)
    -- If an unusual body scale exceeds reach, keep the chain connected.
    handCF=CFrame.new(wrist-target)*handCF
    set(rec,sh,sh.C0:Inverse()*torsoCF:ToObjectSpace(upper)*sh.C1)
    set(rec,el,el.C0:Inverse()*upper:ToObjectSpace(lower)*el.C1)
    set(rec,wr,wr.C0:Inverse()*lower:ToObjectSpace(handCF)*wr.C1)
    return handCF,(wrist-target).Magnitude
end
local function getRecord(plr,c)
    local rec=records[plr]
    if rec and rec.Char~=c then reset(rec);records[plr]=nil;rec=nil end
    if not rec then
        rec={Char=c,Joints={},ByPart={},Applied={},Slide=0,Crouch=0}
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
        records[plr]=rec
    end
    if os.clock()>(rec.ScanAt or 0) then
        rec.ScanAt=os.clock()+1
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
    end
    return rec
end
local function floorClearance(rec)
    local rootJoint=rec.Joints.Root
    local hrp=rec.Char:FindFirstChild("HumanoidRootPart")
    if not rootJoint or not hrp then return end
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={rec.Char}
    params.RespectCanCollide=true
    params.CollisionGroup=hrp.CollisionGroup
    local cache={}
    local lift=0
    for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LowerTorso"} do
        local part=rec.Char:FindFirstChild(name)
        if part then
            local cf=world(rec,part,cache)
            local hit=workspace:Raycast(Vector3.new(cf.X,hrp.Position.Y+1,cf.Z),Vector3.new(0,-7,0),params)
            if hit and hit.Normal.Y>.6 then
                local low=math.huge
                for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
                    low=math.min(low,(cf*Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)).Y)
                end end end
                lift=math.max(lift,hit.Position.Y+.14-low)
            end
        end
    end
    lift=math.clamp(lift,0,1.8)
    if lift>0 then
        local parentFrame=world(rec,rootJoint.Part0,{})*rootJoint.C0
        set(rec,rootJoint,CFrame.new(parentFrame:VectorToObjectSpace(Vector3.new(0,lift,0)))*rootJoint.Transform)
    end
    rec.ClearanceLift=lift
end
local function evaluate(dt)
    dt=math.min(dt,.05)
    for _,plr in Players:GetPlayers() do
        local c=plr.Character
        if c then
            local rec=getRecord(plr,c)
            local h=c:FindFirstChildOfClass("Humanoid")
            local live=h and h.Health>0
            local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
            local crouched=live and plr:GetAttribute("MovementCrouched")==true
            rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
            rec.Crouch+=( (crouched and 1 or 0)-rec.Crouch)*(1-math.exp(-dt*16))
            if live then
                for name,angle in crouch do
                    local j=rec.Joints[name]
                    if j and rec.Crouch>.001 then set(rec,j,j.Transform*CFrame.Angles(rad(angle)*rec.Crouch,0,0)) end
                end
                if rec.Slide>.001 then
                    for name,pose in slide do
                        local j=rec.Joints[name]
                        if j then set(rec,j,j.Transform:Lerp(pose,rec.Slide)) end
                    end
                end
                if sliding then rec.ClearanceUntil=os.clock()+.4 end
                if os.clock()<(rec.ClearanceUntil or 0) or rec.Crouch>.001 then floorClearance(rec) end
                local tool=c:FindFirstChildOfClass("Tool")
                local id=tool and tool:GetAttribute("ReferenceWeaponId")
                local profile=profiles[id]
                local torso=c:FindFirstChild("UpperTorso")
                local hand=c:FindFirstChild("RightHand")
                local handle=tool and tool:FindFirstChild("Handle")
                local model=tool and tool:FindFirstChild("WorldModel")
                local root=model and model:FindFirstChild("Root")
                local weld=hand and hand:FindFirstChild("RightGrip")
                if profile and torso and hand and root and handle and weld and not plr:GetAttribute("InLobby") then
                    local camera=workspace.CurrentCamera
                    local pitch=plr==localPlayer and camera and math.asin(math.clamp(camera.CFrame.LookVector.Y,-1,1)) or plr:GetAttribute("AimPitch") or 0
                    pitch=math.clamp(pitch,rad(-70),rad(70))
                    local waist=rec.Joints.Waist
                    local neck=rec.Joints.Neck
                    if waist then set(rec,waist,waist.Transform*CFrame.Angles(pitch*.35,0,0)) end
                    if neck then set(rec,neck,neck.Transform*CFrame.Angles(pitch*.4,0,0)) end
                    local torsoCF=world(rec,torso,{})
                    local bodyRoot=c:FindFirstChild("HumanoidRootPart")
                    local forward=bodyRoot and bodyRoot.CFrame.LookVector*Vector3.new(1,0,1) or torsoCF.LookVector*Vector3.new(1,0,1)
                    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) end
                    local aim=forward.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
                    local gunCF=CFrame.new(torsoCF:PointToWorldSpace(profile.Grip))*CFrame.lookAt(Vector3.zero,aim)
                    local handToRoot=weld.C0*weld.C1:Inverse()*handle.CFrame:ToObjectSpace(root.CFrame)
                    local rightCF=gunCF*handToRoot:Inverse()
                    local actualRight,rightError=arm(rec,"Right",torsoCF,rightCF)
                    if actualRight then
                        gunCF=actualRight*handToRoot
                        local leftCF=gunCF*CFrame.new(profile.Support)*handToRoot.Rotation:Inverse()
                        local _,leftError=arm(rec,"Left",torsoCF,leftCF)
                        rec.Weapon=id;rec.RightError=rightError;rec.LeftError=leftError
                        rec.Support=profile.Support
                    end
                else rec.Weapon=nil;rec.LeftError=nil;rec.RightError=nil end
            end
        end
    end
end
function P.State(plr)
    local rec=records[plr or localPlayer]
    if not rec then return {} end
    local count=0;for _ in rec.Joints do count+=1 end
    return {JointCount=count,Slide=rec.Slide,Crouch=rec.Crouch,Weapon=rec.Weapon,LeftError=rec.LeftError,RightError=rec.RightError,Support=rec.Support,ClearanceLift=rec.ClearanceLift}
end
function P.Start()
    if started then return P end;started=true
    RunService.PreAnimation:Connect(function()for _,rec in records do reset(rec)end end)
    -- One pose writer, after Animator, for aim + slide. No frame-order tug of war.
    RunService.PreSimulation:Connect(evaluate)
    Players.PlayerRemoving:Connect(function(plr)if records[plr]then reset(records[plr]);records[plr]=nil end end)
    return P
end
return P]====],
[ [====[ServerScriptService.GameplayMovement.Service]====] ]=[====[local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local package=RS:WaitForChild('GameplayPresentation')
local C=require(package.MovementConfig)
local Math=require(package.MovementMath)
local S={}
local states={}
local started=false
local function publish(p,s,key,value)
    if p:GetAttribute(key)~=value then p:SetAttribute(key,value)end
end
local function mode(p,s,value)
    s.Mode=value;publish(p,s,'MovementState',value)
end
local function ground(s)
    local r,h=s.Root,s.Hum
    if not r or not r.Parent or not h or h.Health<=0 then return nil end
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={s.Char};params.RespectCanCollide=true
    local legHeight=h.RigType==Enum.HumanoidRigType.R6 and 2 or 0
    -- A lower target HipHeight must not shorten the ground probe before physics settles.
    local probeHip=s.Mode=="Sliding" and math.max(h.HipHeight,s.BaseHip or 0) or h.HipHeight
    local standing=math.max(0,probeHip)+r.Size.Y/2+legHeight
    if r.AssemblyLinearVelocity.Y>6 then return nil end
    local hit=workspace:Raycast(r.Position,Vector3.new(0,-(standing+.8),0),params)
    return hit and hit.Normal.Y>.45 and hit or nil
end
local function finishSlide(p,s,reason)
    local wasSliding=s.Mode=='Sliding' or s.Drive~=nil
    if wasSliding then s.NextSlide=os.clock()+C.SlideCooldown end
    if s.Drive then s.Drive:Destroy();s.Drive=nil end
    if s.Attachment then s.Attachment:Destroy();s.Attachment=nil end
    if wasSliding and s.Hum and s.Hum.Parent then
        s.Hum.HipHeight=s.BaseHip;s.Hum.AutoRotate=s.BaseRotate
    end
    for ob,value in pairs(s.Collision or {})do if ob.Parent then ob.CanCollide=value end end
    s.Collision={}
    if s.Mode=='Sliding'then mode(p,s,'Walking')end
    publish(p,s,'SlideEndReason',reason or 'Finished')
end
local function canStand(s)
    if not s.Crouched then return true end
    local head=s.Char and s.Char:FindFirstChild('Head')
    if not head or not s.Root then return false end
    local delta=math.max(0,s.BaseHip-s.Hum.HipHeight)
    local top=head.Position.Y+head.Size.Y/2
    local params=OverlapParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={s.Char}
    params.RespectCanCollide=true
    local center=Vector3.new(head.Position.X,top+(delta+.18)/2,head.Position.Z)
    for _,part in workspace:GetPartBoundsInBox(CFrame.new(center),Vector3.new(1.8,math.max(.2,delta+.18),1.8),params) do
        if part.CanCollide then return false end
    end
    return true
end
local function setCrouch(p,s,value)
    if not value and not canStand(s) then return false end
    if value then finishSlide(p,s,'Crouch') end
    s.Crouched=value
    if s.Hum and s.Hum.Parent then
        s.Hum.HipHeight=math.max(0,s.BaseHip-(value and C.CrouchHipDrop or 0))
    end
    publish(p,s,'MovementCrouched',value)
    return true
end
local function reset(p,s)
    if s.Crouched then setCrouch(p,s,false);s.Crouched=false;publish(p,s,'MovementCrouched',false) end
    finishSlide(p,s,'Reset')
    if s.Hum and s.Hum.Parent then s.Hum.WalkSpeed=s.BaseSpeed or C.WalkSpeed end
    s.Wants=false;s.Char=nil;s.Root=nil;s.Hum=nil;s.Joint=nil
    mode(p,s,'Idle')
end
local function bindCharacter(p,s,char)
    reset(p,s)
    s.Char=char;s.Stamina=C.StaminaMax;s.Exhausted=false
    task.spawn(function()
        local hum=char:WaitForChild('Humanoid',10);local root=char:WaitForChild('HumanoidRootPart',10)
        if not hum or not root or s.Char~=char then return end
        s.Hum,s.Root=hum,root
        s.BaseSpeed,s.BaseHip,s.BaseRotate=hum.WalkSpeed,hum.HipHeight,hum.AutoRotate
        s.Joint=root:FindFirstChildWhichIsA('Motor6D') or (char:FindFirstChild('LowerTorso') and char.LowerTorso:FindFirstChild('Root'))
        s.BaseC0=s.Joint and s.Joint.C0
        hum.WalkSpeed=C.WalkSpeed
        hum.Died:Connect(function()if s.Char==char then reset(p,s)end end)
    end)
end
local function reject(p,s,why)
    publish(p,s,'MovementRejectReason',why)
    return false,why
end
function S.Handle(p,action,payload,...)
    local s=states[p]
    if not s or typeof(action)~='string' or #action>20 then return false,'Invalid action'end
    if select('#',...)~=0 then return reject(p,s,'Unexpected payload')end
    local now=os.clock()
    -- Token bucket permits normal press/release bursts but bounds remote spam.
    s.Tokens=math.min(12,(s.Tokens or 12)+(now-(s.TokenTime or now))*8);s.TokenTime=now
    if s.Tokens<1 then return reject(p,s,'RateLimited')end;s.Tokens-=1
    if action=='Sprint' and typeof(payload)~='boolean' then return reject(p,s,'Invalid sprint payload')end
    if action=='Crouch' and typeof(payload)~='boolean' then return reject(p,s,'Invalid crouch payload')end
    if action=='CancelSlide' and payload~=nil then return reject(p,s,'Invalid cancel payload')end
    if action~='Sprint' and action~='Slide' and action~='CancelSlide' and action~='Crouch' then return reject(p,s,'Unknown action')end
    if (p:GetAttribute('InMenu') and not p:GetAttribute('InLobby')) or not s.Hum or not s.Root or not s.Char.Parent or s.Hum.Health<=0 then return reject(p,s,'Not deployed')end
    if action=='Crouch'then
        if payload and not ground(s) then return reject(p,s,'Ground required')end
        if not setCrouch(p,s,payload) then return reject(p,s,'Low ceiling')end
        s.Wants=false
        mode(p,s,payload and 'Crouching' or 'Walking')
        publish(p,s,'MovementRejectReason','')
        return true
    elseif action=='Sprint'then
        if payload and s.Crouched and not setCrouch(p,s,false) then return reject(p,s,'Low ceiling')end
        s.Wants=payload
        return true
    elseif action=='CancelSlide'then
        finishSlide(p,s,'Cancelled');return true
    end
    local dir=Math.Direction(payload)
    if not dir then return reject(p,s,'Invalid slide direction')end
    if s.Mode=='Sliding' or now<(s.NextSlide or 0)then return reject(p,s,'Cooldown')end
    if not s.Wants or s.Stamina<C.SlideCost or s.Exhausted then return reject(p,s,'Sprint and stamina required')end
    if not ground(s) then return reject(p,s,'Ground required')end
    local velocity=s.Root.AssemblyLinearVelocity*Vector3.new(1,0,1)
    if velocity.Magnitude<C.SlideMinSpeed then return reject(p,s,'Build sprint speed first')end
    if velocity.Unit:Dot(dir)<.65 then return reject(p,s,'Direction must follow momentum')end
    s.Stamina-=C.SlideCost;s.LastEffort=now;s.NextSlide=now
    s.SlideStart=now;s.Direction=dir;s.AirTime=0;s.BaseHip=s.Hum.HipHeight;s.BaseRotate=s.Hum.AutoRotate
    s.BaseC0=s.Joint and s.Joint.C0
    s.Hum.HipHeight=s.BaseHip-C.HipDrop;s.Hum.AutoRotate=false;s.Hum.WalkSpeed=C.SlideEndSpeed
    s.Collision={}
    for _,o in ipairs(s.Char:GetDescendants())do if o:IsA('BasePart') and (o.Name:find('Leg') or o.Name:find('Foot'))then s.Collision[o]=o.CanCollide;o.CanCollide=false end end
    local attach=Instance.new('Attachment');attach.Name='GameplaySlideAttachment';attach.Parent=s.Root
    local drive=Instance.new('LinearVelocity');drive.Name='GameplaySlideVelocity'
    drive.Attachment0=attach;drive.RelativeTo=Enum.ActuatorRelativeTo.World
    drive.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
    drive.PrimaryTangentAxis=Vector3.xAxis;drive.SecondaryTangentAxis=Vector3.zAxis
    drive.ForceLimitsEnabled=true;drive.ForceLimitMode=Enum.ForceLimitMode.PerAxis
    local force=math.max(50000,s.Root.AssemblyMass*1600)
    drive.MaxPlanarAxesForce=Vector2.new(force,force)
    drive.PlaneVelocity=Vector2.new(dir.X*C.SlideSpeed,dir.Z*C.SlideSpeed);drive.Parent=s.Root
    s.Attachment,s.Drive=attach,drive
    mode(p,s,'Sliding');publish(p,s,'SlideStartedAt',workspace:GetServerTimeNow())
    publish(p,s,'MovementRejectReason','')
    return true
end
local function tickPlayer(p,s,dt)
    local now=os.clock()
    if (p:GetAttribute('InMenu') and not p:GetAttribute('InLobby')) or not s.Hum or not s.Root or not s.Root.Parent or s.Hum.Health<=0 then
        if s.Mode~='Idle'then finishSlide(p,s,'MenuOrDeath');mode(p,s,'Idle')end
        if s.Crouched then
            if s.Hum and s.Hum.Parent then s.Hum.HipHeight=s.BaseHip end
            s.Crouched=false;publish(p,s,'MovementCrouched',false)
        end
        s.Wants=false;s.Stamina=math.min(C.StaminaMax,s.Stamina+C.StaminaRegen*dt)
    elseif s.Crouched then
        s.Hum.WalkSpeed=C.CrouchSpeed
        mode(p,s,'Crouching')
        if now-(s.LastEffort or 0)>C.RegenDelay then s.Stamina=Math.Stamina(s.Stamina,false,dt)end
        if s.Exhausted and s.Stamina>=C.ExhaustionRecovery then s.Exhausted=false end
    elseif s.Mode=='Sliding'then
        local elapsed=now-s.SlideStart
        if ground(s)then s.AirTime=0 else s.AirTime+=dt end
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.Char};params.RespectCanCollide=true
        local wall=workspace:Raycast(s.Root.Position,s.Direction*(2.1+Math.SlideSpeed(elapsed)*dt),params)
        if elapsed>=C.SlideDuration then finishSlide(p,s,'Completed')
        elseif s.AirTime>.14 then finishSlide(p,s,'Airborne')
        elseif wall and wall.Normal.Y<.45 then finishSlide(p,s,'Wall')
        elseif s.Drive then
            local speed=Math.SlideSpeed(elapsed)
            s.Drive.PlaneVelocity=Vector2.new(s.Direction.X*speed,s.Direction.Z*speed)
            publish(p,s,'SlideSpeed',math.floor(speed*10)/10)
        end
    else
        local horizontal=s.Root.AssemblyLinearVelocity*Vector3.new(1,0,1)
        local moving=horizontal.Magnitude>1.5
        if s.Stamina<=0 then s.Exhausted=true end
        if s.Exhausted and s.Stamina>=C.ExhaustionRecovery then s.Exhausted=false end
        local sprint=s.Wants and not s.Exhausted and s.Stamina>0
        s.Hum.WalkSpeed=sprint and C.SprintSpeed or C.WalkSpeed
        local grounded=ground(s)~=nil
        if sprint and moving and grounded then
            mode(p,s,'Sprinting');s.Stamina=Math.Stamina(s.Stamina,true,dt);s.LastEffort=now
        else
            mode(p,s,moving and 'Walking' or 'Idle')
            if now-(s.LastEffort or 0)>C.RegenDelay then s.Stamina=Math.Stamina(s.Stamina,false,dt)end
        end
    end
    publish(p,s,'MovementStamina',math.floor(s.Stamina*10)/10)
    publish(p,s,'SlideReadyIn',math.max(0,math.ceil(((s.NextSlide or 0)-now)*10)/10))
end
function S.Start()
    if started then return end;started=true
    local function added(p)
        if states[p]then return end
        local s={Mode='Idle',Stamina=C.StaminaMax,Wants=false,Crouched=false};states[p]=s
        p.CharacterAdded:Connect(function(char)bindCharacter(p,s,char)end)
        p.CharacterRemoving:Connect(function(char)if s.Char==char then reset(p,s)end end)
        if p.Character then bindCharacter(p,s,p.Character)end
    end
    for _,p in ipairs(Players:GetPlayers())do added(p)end
    Players.PlayerAdded:Connect(added)
    Players.PlayerRemoving:Connect(function(p)if states[p]then reset(p,states[p]);states[p]=nil end end)
    package.MovementRequest.OnServerEvent:Connect(S.Handle)
    RunService.Heartbeat:Connect(function(dt)for p,s in pairs(states)do tickPlayer(p,s,math.min(dt,.1))end end)
    -- Server-local QA entry point; never exposed to clients.
    local control=Instance.new('BindableFunction');control.Name='MovementControl'
    control.OnInvoke=function(p,action,value)
        if action=='State'then local s=states[p];return s and {Mode=s.Mode,Stamina=s.Stamina,Wants=s.Wants,Sliding=s.Drive~=nil,WalkSpeed=s.Hum and s.Hum.WalkSpeed,BaseHip=s.BaseHip,Hip=s.Hum and s.Hum.HipHeight,Crouched=s.Crouched,CanStand=not s.Crouched or canStand(s)}end
        return S.Handle(p,action,value)
    end
    control.Parent=script.Parent
end
return S
]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson]====] ]=[====[-- Claude's third-person combat camera + aim pose.
-- Over-the-shoulder camera, mouse locked in matches, character faces where you look,
-- arms + torso aim at the camera pitch (other players' pitch comes from the server attribute AimPitch).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local aimRemote = package:WaitForChild("AimPitch")
local player = Players.LocalPlayer
local gameSettings = UserSettings():GetService("UserGameSettings")

local SHOULDER = Vector3.new(2.1, 0.55, 0)
local shoulderX = SHOULDER.X
local lastSent, lastSentAt = 0, 0

local function inMatch()
	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
end

local function armed(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool and tool:GetAttribute("ReferenceWeaponId") ~= nil
end

local function cameraPitch()
	local cam = workspace.CurrentCamera
	return cam and math.asin(math.clamp(cam.CFrame.LookVector.Y, -1, 1)) or 0
end

-- camera: runs after the default camera, the gun controller and the lobby script
RunService:BindToRenderStep("ClaudeThirdPerson", Enum.RenderPriority.Last.Value + 2, function(dt)
	local cam = workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not cam or not humanoid or humanoid.Health <= 0 or not head then return end
	local combat = inMatch()
	UserInputService.MouseBehavior = combat and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = not combat
	gameSettings.RotationType = combat and Enum.RotationType.CameraRelative or Enum.RotationType.MovementRelative
	if not combat then return end
	-- shoulder offset, pulled in when a wall is on the right
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, workspace:FindFirstChild("ClaudeAKFx")}
	local right = cam.CFrame.RightVector
	local wall = workspace:Raycast(head.Position, right * (SHOULDER.X + 0.6), params)
	local wanted = wall and math.max(0, (wall.Position - head.Position).Magnitude - 0.7) or SHOULDER.X
	shoulderX += (wanted - shoulderX) * (1 - math.exp(-dt * 14))
	cam.CFrame = cam.CFrame * CFrame.new(shoulderX, SHOULDER.Y, 0)
	-- share pitch with the server (10x a second, only when it changed)
	local pitch = cameraPitch()
	local now = os.clock()
	if now - lastSentAt > 0.1 and math.abs(pitch - lastSent) > math.rad(1) then
		lastSent, lastSentAt = pitch, now
		aimRemote:FireServer(pitch)
	end
end)

-- Aim and movement now share GameplayPresentation.CharacterPose (bounded pose-only integration).
-- Camera, mouse lock and AimPitch network protocol above remain unchanged.
]====],
[ [====[ReplicatedStorage.ReferenceWeapons.Controller]====] ]=[====[-- Client-only presentation. Damage/hit authority remains outside this controller.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local ContextActionService = game:GetService('ContextActionService')
local StarterGui = game:GetService('StarterGui')
local Config = require(script.Parent.WeaponConfig)
local Controller = {}
-- Claude's AK hook: guns with CustomFx skip the stock effects and fire this signal instead.
local shotSignal = Instance.new('BindableEvent')
Controller.Shot = shotSignal.Event
local player = Players.LocalPlayer
local package = script.Parent
local camera
local started = false
local activeTool, spec, model, hud, nameText, ammoText, statusText
local parts, arms, connections = {}, {}, {}
local hooked = setmetatable({}, {__mode = 'k'})
local ammo = setmetatable({}, {__mode = 'k'})
local hidden = setmetatable({}, {__mode = 'k'})
local trigger, aiming, sprinting = false, false, false
local reloadStart, inspectStart, equipStart = nil, nil, 0
local lastShot, shotAt = -100, -100
local recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
local yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
local elapsed, crossBloom, generation = 0, 0, 0
local crossLines, casings, characterConnections = {}, {}, {}
local baseFov = 72
local controlBridge
local viewScene, viewCamera, testing = nil, nil, false
local skin = Color3.fromRGB(222, 172, 116)
local renderName = 'ReferenceFPS_Viewmodel'
local identity = CFrame.identity

local function smooth(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
local function mix(a, b, t) return a:Lerp(b, smooth(t)) end
local function bump(t, startTime, peakTime, endTime)
    if t < startTime or t > endTime then return 0 end
    if t <= peakTime then return smooth((t - startTime) / (peakTime - startTime)) end
    return 1 - smooth((t - peakTime) / (endTime - peakTime))
end
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function part(name, size, color, parent)
    local p = Instance.new('Part')
    p.Name, p.Size, p.Color = name, size, color
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.CastShadow, p.Material = false, Enum.Material.SmoothPlastic
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function label(name, size, pos, text, parent)
    local l = Instance.new('TextLabel')
    l.Name, l.Size, l.Position = name, size, pos
    l.BackgroundTransparency = 1
    l.TextColor3, l.Font, l.TextSize = Color3.fromRGB(235, 240, 245), Enum.Font.GothamMedium, 18
    l.TextStrokeTransparency = .65
    l.Text, l.TextXAlignment = text, Enum.TextXAlignment.Right
    l.Parent = parent
    return l
end
local function createHUD()
    local old = player.PlayerGui:FindFirstChild('ReferenceWeaponHUD')
    if old then old:Destroy() end
    hud = Instance.new('ScreenGui')
    hud.Name, hud.ResetOnSpawn, hud.IgnoreGuiInset = 'ReferenceWeaponHUD', false, true
    hud.DisplayOrder = 8
    hud.Parent = player:WaitForChild('PlayerGui')
    -- A transparent live 3D viewmodel pass keeps the Blender colors legible at night.
    local viewport = Instance.new('ViewportFrame')
    viewport.Name, viewport.Size, viewport.BackgroundTransparency = 'ViewmodelViewport', UDim2.fromScale(1, 1), 1
    viewport.BorderSizePixel = 0
    viewport.Ambient, viewport.LightColor = Color3.fromRGB(135, 135, 140), Color3.fromRGB(240, 235, 225)
    viewport.LightDirection = Vector3.new(-1, -1.5, -1)
    viewport.Parent = hud
    viewScene = Instance.new('WorldModel'); viewScene.Name, viewScene.Parent = 'WorldModel', viewport
    viewCamera = Instance.new('Camera'); viewCamera.Name, viewCamera.Parent = 'ViewmodelCamera', viewport
    viewport.CurrentCamera = viewCamera
    nameText = label('WeaponName', UDim2.fromOffset(300, 25), UDim2.new(1, -330, 1, -122), '', hud)
    nameText.TextSize = 15
    ammoText = label('Ammo', UDim2.fromOffset(250, 45), UDim2.new(1, -280, 1, -96), '', hud)
    ammoText.Font, ammoText.TextSize = Enum.Font.GothamBold, 32
    statusText = label('Status', UDim2.fromOffset(330, 25), UDim2.new(1, -360, 1, -49), '', hud)
    statusText.TextSize = 12
    statusText.TextColor3 = Color3.fromRGB(167, 184, 199)
    local center = Instance.new('Frame')
    center.Name, center.Size, center.Position = 'Reticle', UDim2.fromOffset(1, 1), UDim2.fromScale(.5, .5)
    center.BackgroundTransparency = 1
    center.Parent = hud
    local dot = Instance.new('Frame')
    dot.Name, dot.Size, dot.AnchorPoint = 'CenterDot', UDim2.fromOffset(3, 3), Vector2.new(.5, .5)
    dot.BorderSizePixel, dot.BackgroundColor3 = 0, Color3.fromRGB(255, 199, 94)
    dot.Parent = center
    local corner = Instance.new('UICorner'); corner.CornerRadius = UDim.new(1, 0); corner.Parent = dot
    for i, dir in ipairs({Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)}) do
        local f = Instance.new('Frame')
        f.Name, f.AnchorPoint, f.BorderSizePixel = 'Line' .. i, Vector2.new(.5, .5), 0
        f.Size = i % 2 == 0 and UDim2.fromOffset(7, 2) or UDim2.fromOffset(2, 7)
        f.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
        f.Parent = center
        local stroke = Instance.new('UIStroke'); stroke.Color = Color3.new(0, 0, 0); stroke.Transparency = .45; stroke.Parent = f
        table.insert(crossLines, {Frame = f, Direction = dir, Stroke = stroke})
    end
    if ReplicatedStorage:FindFirstChild('GameplayPresentation') then
        nameText.Visible=false;ammoText.Visible=false;statusText.Visible=false;center.Visible=false
    end
    if UserInputService.TouchEnabled then
        for i, action in ipairs({'FIRE', 'AIM', 'RELOAD'}) do
            local button = Instance.new('TextButton')
            button.Name, button.Text = action, action
            button.Size, button.Position = UDim2.fromOffset(78, 45), UDim2.new(1, -90, .50, (i - 1) * 53)
            button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(30, 40, 50), Color3.new(1, 1, 1)
            button.BackgroundTransparency = .25
            button.Parent = hud
            connect(button.Activated, function()
                if action == 'FIRE' then Controller.Fire() elseif action == 'AIM' then Controller.SetAim(not aiming) else Controller.Reload() end
            end)
        end
    end
end
local function updateHUD()
    local function publish(key,value)if player:GetAttribute(key)~=value then player:SetAttribute(key,value)end end
    local current=activeTool and ammo[activeTool]
    publish('FPSWeaponId',spec and spec.Id or '')
    publish('FPSAmmo',current and current.Current or nil)
    publish('FPSReserve',current and current.Reserve or nil)
    publish('FPSReloading',reloadStart~=nil)
    publish('FPSInspecting',inspectStart~=nil)
    local a = activeTool and ammo[activeTool]
    if a and spec then
        nameText.Text = string.upper(spec.Name)
        ammoText.Text = string.format('%02d  /  %03d', a.Current, a.Reserve)
        statusText.Text = reloadStart and 'RELOADING' or (inspectStart and 'INSPECTING' or 'R  RELOAD    RMB  AIM    F  INSPECT')
    else
        nameText.Text, ammoText.Text, statusText.Text = '', '', ''
    end
end
local function clear()
    generation += 1
    if camera then camera.CFrame *= CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() end
    if model then model:Destroy() end
    model, activeTool, spec = nil, nil, nil
    parts, arms = {}, {}
    trigger, aiming, reloadStart, inspectStart = false, false, nil, nil
    recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
    yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
    if camera then camera.FieldOfView = baseFov end
    updateHUD()
end
local function armParts(side)
    local result = {}
    local handScale = spec and spec.Pistol and .82 or 1
    result.Upper = part(side .. 'UpperArm', Vector3.new(.39, 1, .40), skin, model)
    result.Lower = part(side .. 'Forearm', Vector3.new(.36, 1, .38), skin, model)
    result.Palm = part(side .. 'Hand', Vector3.new(.34, .43, .37) * handScale, skin, model)
    result.Cuff = part(side .. 'Sleeve', Vector3.new(.42, .35, .44), (player:GetAttribute('EquippedSleeveColor') or Color3.fromRGB(31, 38, 46)), model)
    result.Fingers = {}
    for i = 1, 4 do
        result.Fingers[i] = part(side .. 'Finger' .. i, Vector3.new(.105, .12, .28) * handScale, skin, model)
    end
    result.Thumb = part(side .. 'Thumb', Vector3.new(.15, .23, .20) * handScale, skin, model)
    return result
end
local function segment(ob, a, b, width)
    local length = (b - a).Magnitude
    ob.Size = Vector3.new(width, math.max(.02, length), width * 1.06)
    ob.CFrame = CFrame.lookAt((a + b) * .5, b) * CFrame.Angles(math.pi * .5, 0, 0)
end
local function solveArm(limb, shoulder, handFrame, pole, side)
    local target = handFrame.Position
    local delta = target - shoulder
    local distance = math.max(delta.Magnitude, .001)
    local direction = delta / distance
    local upper, lower = 1.22, 1.26
    local d = math.clamp(distance, .12, upper + lower - .005)
    local adjacent = (upper * upper - lower * lower + d * d) / (2 * d)
    local height = math.sqrt(math.max(0, upper * upper - adjacent * adjacent))
    local bend = pole - shoulder
    bend = bend - direction * bend:Dot(direction)
    if bend.Magnitude < .01 then bend = Vector3.yAxis:Cross(direction) end
    local elbow = shoulder + direction * adjacent + bend.Unit * height
    segment(limb.Upper, shoulder, elbow, .39)
    segment(limb.Lower, elbow, target, .36)
    limb.Cuff.CFrame = CFrame.lookAt(shoulder:Lerp(elbow, .22), elbow) * CFrame.Angles(math.pi / 2, 0, 0)
    limb.Palm.CFrame = handFrame
    local handScale = spec and spec.Pistol and .82 or 1
    for i, finger in ipairs(limb.Fingers) do
        finger.CFrame = handFrame * CFrame.new(Vector3.new((i - 2.5) * .075, -.03, -.18) * handScale) * CFrame.Angles(-.40, 0, 0)
    end
    limb.Thumb.CFrame = handFrame * CFrame.new(Vector3.new(side * .19, .04, -.07) * handScale) * CFrame.Angles(0, 0, side * .48)
end
local function equip(tool)
    if activeTool == tool then return end
    clear()
    spec = Config.Guns[tool:GetAttribute('ReferenceWeaponId')]
    if not spec then return end
    local template = package.Viewmodels:FindFirstChild(spec.Id)
    if not template then warn('Missing imported weapon template ' .. spec.Id); return end
    activeTool = tool
    if not ammo[tool] then ammo[tool] = {Current = spec.MagazineSize, Reserve = spec.Reserve} end
    camera = workspace.CurrentCamera
    model = template:Clone()
    model.Name = 'ReferenceFPS_Active'
    model.Parent = viewScene
    local menuPackage = ReplicatedStorage:FindFirstChild('MainMenu')
    if menuPackage and menuPackage:FindFirstChild('Cosmetics') then require(menuPackage.Cosmetics).ApplyWeapon(model, player:GetAttribute('CosmeticWrap') or 'ORIGINAL') end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
            if p ~= model.PrimaryPart then
                table.insert(parts, {Part = p, Rest = p.CFrame, Component = p:GetAttribute('Component') or 'Body'})
            end
        end
    end
    -- Claude's guns with CustomArms carry their own posed hand meshes.
    if not spec.CustomArms then arms.Left, arms.Right = armParts('Left'), armParts('Right') end
    equipStart = os.clock()
    model:SetAttribute('WeaponId', spec.Id)
    model:SetAttribute('Pose', 'Equip')
    updateHUD()
end
local function effectPart(name, size, color, frame)
    local p = part(name, size, color, workspace)
    p.CFrame = frame
    p.Material = Enum.Material.Neon
    return p
end
local function muzzleEffects()
    if not model then return end
    local root = model.PrimaryPart.CFrame
    local muzzle = root * CFrame.new(spec.Muzzle)
    local flash = effectPart('ReferenceMuzzleFlash', Vector3.new(.09, .09, .32), Color3.fromRGB(255, 210, 115), muzzle * CFrame.new(0, 0, -.09))
    flash.Shape = Enum.PartType.Ball
    local light = Instance.new('PointLight'); light.Brightness, light.Range, light.Color = 3, 8, flash.Color; light.Parent = flash
    Debris:AddItem(flash, .045)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, model}
    local origin, direction = camera.CFrame.Position, camera.CFrame.LookVector * 400
    local hit = workspace:Raycast(origin, direction, params)
    local target = hit and hit.Position or origin + direction
    local delta = target - muzzle.Position
    local trace = effectPart('ReferenceTracer', Vector3.new(.015, .015, math.min(delta.Magnitude, 150)), Color3.fromRGB(255, 220, 130), CFrame.lookAt(muzzle.Position, target) * CFrame.new(0, 0, -math.min(delta.Magnitude, 150) / 2))
    trace.Transparency = .3
    Debris:AddItem(trace, .045)
    local casing = part('ReferenceEjectedCasing', Vector3.new(.06, .13, .06), Color3.fromRGB(196, 145, 57), workspace)
    casing.Shape, casing.Material = Enum.PartType.Cylinder, Enum.Material.Metal
    casing.CFrame = root * CFrame.new(spec.Bolt + Vector3.new(.13, 0, 0))
    table.insert(casings, {Part = casing, Frame = casing.CFrame, Age = 0, Velocity = root.RightVector * 4 + Vector3.yAxis * 2.2})
    if #casings > 16 then table.remove(casings, 1).Part:Destroy() end
end
function Controller.Fire()
    if sprinting then player:SetAttribute('MovementFireInterrupt',os.clock());sprinting=false end
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return false end
    if not activeTool or not model or not spec or reloadStart or sprinting then return false end
    local now, a = os.clock(), ammo[activeTool]
    if now - equipStart < .40 or now - lastShot < 60 / spec.RPM then return false end
    if a.Current <= 0 then Controller.Reload(); return false end
    inspectStart = nil
    lastShot, shotAt = now, now
    a.Current -= 1
    recoilVelocity += spec.Kick * 65
    shotCounter += 1
    yawVelocity += math.rad(spec.RecoilYaw or .3) * math.sin(shotCounter * 2.399963) * 28
    crossBloom = math.min(crossBloom + 7, 22)
    if spec.CustomFx then shotSignal:Fire(spec, model, aiming) else muzzleEffects() end
    updateHUD()
    return true
end
function Controller.Reload()
    local a = activeTool and ammo[activeTool]
    if not a or not spec or reloadStart or a.Current == spec.MagazineSize or a.Reserve == 0 then return false end
    reloadStart, inspectStart, aiming, trigger = os.clock(), nil, false, false
    updateHUD()
    return true
end
function Controller.Inspect()
    if not activeTool or reloadStart then return false end
    inspectStart, aiming = os.clock(), false
    return true
end
function Controller.SetAim(value)
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then aiming = false; return end
    aiming = value == true and activeTool ~= nil and reloadStart == nil
    if aiming then sprinting, inspectStart = false, nil end
end
function Controller.GetState()
    local a = activeTool and ammo[activeTool]
    return {
        WeaponId = spec and spec.Id, Ammo = a and a.Current, Reserve = a and a.Reserve,
        Aiming = aiming, Reloading = reloadStart ~= nil, Inspecting = inspectStart ~= nil,
        Pose = model and model:GetAttribute('Pose'), FirstPerson = player.CameraMode.Name,
        Meshes = #parts, HasArms = arms.Left ~= nil and arms.Right ~= nil,
        CameraFov = camera and camera.FieldOfView,
        RecoilPitchDegrees = math.deg(lastCameraKick), RecoilYawDegrees = math.deg(lastCameraYaw),
        WeaponKick = recoil,
    }
end
local function render(dt)
    dt = math.min(dt, .05)
    elapsed += dt
    camera = workspace.CurrentCamera
    if not camera then return end
    local inMenu = player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen')
    if hud then hud.Enabled = not inMenu end
    if inMenu then trigger=false;aiming=false;player:SetAttribute('FPSAiming',false);return end
    sprinting=player:GetAttribute('MovementState')=='Sprinting'
    if player:GetAttribute('MovementState')=='Sliding' then aiming=false end
    if player:GetAttribute('FPSAiming')~=aiming then player:SetAttribute('FPSAiming',aiming)end
    if player:GetAttribute('FPSReloading')~=(reloadStart~=nil) then player:SetAttribute('FPSReloading',reloadStart~=nil)end
    if player:GetAttribute('FPSInspecting')~=(inspectStart~=nil) then player:SetAttribute('FPSInspecting',inspectStart~=nil)end
    -- Character and world-held weapon remain visible to other players, hidden only here.
    local character = player.Character
    if character then
        for _, ob in ipairs(character:GetDescendants()) do
            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = 1 end
        end
    end
    for i = #casings, 1, -1 do
        local c = casings[i]; c.Age += dt
        if c.Age > .9 then c.Part:Destroy(); table.remove(casings, i) else
            c.Velocity -= Vector3.yAxis * dt * 18
            c.Frame += c.Velocity * dt
            c.Part.CFrame = c.Frame * CFrame.Angles(c.Age * 9, c.Age * 7, c.Age * 4)
            c.Part.Transparency = math.max(0, (c.Age - .55) / .35)
        end
    end
    if not model or not activeTool or not spec then return end
    if model.Parent ~= viewScene then model.Parent = viewScene end
    local now = os.clock()
    if not testing and trigger and spec.Automatic and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then Controller.Fire() end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then trigger = false end
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local moving = humanoid and humanoid.MoveDirection.Magnitude or 0
    local reloading = reloadStart ~= nil
    local r = reloading and math.clamp((now - reloadStart) / spec.ReloadTime, 0, 1) or 0
    if reloading and r >= 1 then
        local a = ammo[activeTool]
        local count = math.min(spec.MagazineSize - a.Current, a.Reserve)
        a.Current, a.Reserve = a.Current + count, a.Reserve - count
        reloadStart, reloading, r = nil, false, 0
        updateHUD()
    end
    local inspect = inspectStart and (now - inspectStart) / 2.2 or 0
    if inspect >= 1 then inspectStart, inspect = nil, 0; updateHUD() end
    aimAlpha += ((aiming and not reloading and not sprinting and 1 or 0) - aimAlpha) * (1 - math.exp(-dt * 15))
    camera.FieldOfView += ((baseFov + (player:GetAttribute('MovementFovOffset') or 0) * (1-aimAlpha) + (spec.AimFov - baseFov) * aimAlpha) - camera.FieldOfView) * (1 - math.exp(-dt * 18))
    recoilVelocity += (-150 * recoil - 20 * recoilVelocity) * dt
    recoil += recoilVelocity * dt
    yawVelocity += (-150 * yawRecoil - 20 * yawVelocity) * dt
    yawRecoil += yawVelocity * dt
    local kick = math.clamp(recoil * (spec.CameraRecoil or .75) * (1 - .18 * aimAlpha), 0, math.rad(7))
    local yaw = math.clamp(yawRecoil * (1 - .18 * aimAlpha), -math.rad(1.2), math.rad(1.2))
    camera.CFrame = camera.CFrame * CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() * CFrame.Angles(kick, yaw, 0)
    lastCameraKick, lastCameraYaw = kick, yaw
    local aimPosition = Vector3.new(-spec.Aim.X, -spec.Aim.Y, -(spec.SightDistance or .90) - spec.Aim.Z)
    local stance = spec.Hip:Lerp(CFrame.new(aimPosition), aimAlpha)
    local delta = UserInputService:GetMouseDelta()
    local sway = CFrame.Angles(math.clamp(-delta.Y * .00055, -.025, .025), math.clamp(-delta.X * .00055, -.025, .025), 0)
    local bob = CFrame.new(math.sin(elapsed * 8) * .018 * moving, math.cos(elapsed * 16) * .015 * moving, 0)
    local breathe = CFrame.new(0, math.sin(elapsed * 2) * .004, 0)
    local draw = 1 - smooth((now - equipStart) / .45)
    local reloadPose = math.sin(r * math.pi)
    local inspectPose = math.sin(math.pi * math.clamp(inspect, 0, 1))
    local sprintPose=sprinting and moving>.1 and 1 or 0
    if player:GetAttribute('MovementState')=='Sliding' then sprintPose=.7 end
    local visualKick = math.clamp(recoil, 0, .24)
    local pullback = (spec.Pullback or .1) * math.clamp(visualKick / .10, 0, 1.5)
    local action = CFrame.new(-.12 * reloadPose, -.12 * reloadPose - .9 * draw - .2 * sprintPose - .015 * visualKick, .12 * reloadPose + .28 * draw + pullback)
        * CFrame.Angles(-visualKick * 1.05 + .25 * draw - .3 * sprintPose, .09 * reloadPose + .32 * inspectPose + yawRecoil * .45, -.30 * reloadPose - .48 * inspectPose - visualKick * .12)
    local base = camera.CFrame * stance * breathe * bob * sway * action
    viewCamera.CFrame, viewCamera.FieldOfView = camera.CFrame, camera.FieldOfView
    model.PrimaryPart.CFrame = base
    local magDrop = bump(r, .10, .33, .72) * .90
    local boltPull = bump(r, .78, .84, .94) * .20
    local age = now - shotAt
    local fireBolt = age >= 0 and age < .11 and math.sin(age / .11 * math.pi) * .15 or 0
    local pumpPull = spec.Shotgun and bump(age, .10, .24, .48) * .29 or 0
    local motion = {
        Body = identity,
        Magazine = CFrame.new(.03 * magDrop, -magDrop, .08 * magDrop) * CFrame.Angles(0, 0, -.14 * magDrop),
        Bolt = CFrame.new(0, 0, boltPull + fireBolt),
        Trigger = CFrame.new(0, 0, age < .10 and .025 or 0),
        Pump = CFrame.new(0, 0, pumpPull + (spec.Shotgun and bump(r, .78, .87, .97) * .26 or 0)),
    }
    for _, p in ipairs(parts) do p.Part.CFrame = base * (motion[p.Component] or identity) * p.Rest end
    local left = spec.Support
    if spec.Shotgun then
        left += Vector3.new(0, 0, motion.Pump.Position.Z)
        if reloading then
            local insertion = bump(r, .10, .30, .76)
            left = mix(left, Vector3.new(.21, .23, -.21), insertion)
        end
    elseif reloading then
        local mag = motion.Magazine:PointToWorldSpace(spec.Magazine) + Vector3.new(-.12, -.10, 0)
        if r < .20 then left = mix(spec.Support, mag, r / .20)
        elseif r < .73 then left = mag
        elseif r < .85 then left = mix(mag, spec.Bolt + Vector3.new(.1, 0, boltPull), (r - .73) / .12)
        else left = mix(spec.Bolt, spec.Support, (r - .85) / .15) end
    end
    local rightFrame = base * CFrame.new(.02, -.01, 0) * CFrame.Angles(-.27, 0, 0)
    local leftFrame = base * CFrame.new(left) * CFrame.Angles(spec.Pistol and -.27 or .25, 0, spec.Pistol and -.4 or -.9)
    local cam = camera.CFrame
    if arms.Right then
        solveArm(arms.Right, cam:PointToWorldSpace(Vector3.new(.84, -.99, .19)), rightFrame, cam:PointToWorldSpace(Vector3.new(1.4, -1.6, -.3)), 1)
        solveArm(arms.Left, cam:PointToWorldSpace(Vector3.new(-.78, -.99, .19)), leftFrame, cam:PointToWorldSpace(Vector3.new(-.85, -1.7, -.4)), -1)
    end
    model:SetAttribute('Pose', reloading and 'Reload' or (inspectStart and 'Inspect' or (draw > .01 and 'Equip' or (aimAlpha > .8 and 'ADS' or (age < .13 and 'Fire' or 'Idle')))))
    model:SetAttribute('Ammo', ammo[activeTool].Current)
    crossBloom *= math.exp(-dt * 10)
    local gap = 8 + crossBloom + moving * 3
    for _, item in ipairs(crossLines) do
        item.Frame.Position = UDim2.fromOffset(item.Direction.X * gap, item.Direction.Y * gap)
        item.Frame.BackgroundTransparency = aimAlpha * .9
        item.Stroke.Transparency = .45 + aimAlpha * .5
    end
end
local function hookTool(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ReferenceWeaponId') or hooked[tool] then return end
    hooked[tool] = true
    connect(tool.Equipped, function() equip(tool) end)
    connect(tool.Unequipped, function() if activeTool == tool then clear() end end)
    connect(tool.Activated, function() if not testing then Controller.Fire() end end)
    connect(tool.Deactivated, function() trigger = false end)
    if tool.Parent == player.Character then equip(tool) end
end
local function hookCharacter(character)
    clear()
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
    -- Neutral tan bare arms match the supplied first-person reference instead of yellow test-avatar limbs.
    skin = player:GetAttribute('EquippedHandColor') or Color3.fromRGB(222, 172, 116)
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    characterConnections = {character.ChildAdded:Connect(hookTool)}
    for _, child in ipairs(character:GetChildren()) do hookTool(child) end
    task.spawn(function()
        local humanoid = character:WaitForChild('Humanoid', 10)
        local backpack = player:WaitForChild('Backpack', 10)
        if not humanoid or not backpack or character ~= player.Character then return end
        local preferred = Config.Guns[player:GetAttribute('PreferredWeapon') or 'W1'] or Config.Guns.W1
        local ak = backpack:FindFirstChild(preferred.Name) or backpack:WaitForChild(preferred.Name, 8)
        if ak and character == player.Character and humanoid.Health > 0 then humanoid:EquipTool(ak) end
        connect(humanoid.Died, clear)
    end)
end
function Controller.Start()
    if started then return Controller end
    started = true
    camera = workspace.CurrentCamera
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
    UserInputService.MouseIconEnabled = false
    createHUD()
    -- Local-only diagnostics/commands; no RemoteEvents or server damage authority.
    controlBridge = Instance.new('BindableFunction')
    controlBridge.Name = 'ReferenceFPSControl'
    controlBridge.OnInvoke = function(action, value)
        if action == 'TestMode' then
            testing, trigger, sprinting, aiming = value == true, false, false, false
            if testing then
                ContextActionService:BindActionAtPriority('ReferenceFPS_TestKeys', function() return Enum.ContextActionResult.Sink end, false, 4000,
                    Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five)
            else ContextActionService:UnbindAction('ReferenceFPS_TestKeys') end
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not testing)
            return true
        elseif action == 'Fire' then return Controller.Fire()
        elseif action == 'Reload' then return Controller.Reload()
        elseif action == 'Inspect' then return Controller.Inspect()
        elseif action == 'Aim' then Controller.SetAim(value); return true end
        return Controller.GetState()
    end
    controlBridge.Parent = player:WaitForChild('PlayerScripts')
    local backpack = player:WaitForChild('Backpack')
    for _, child in ipairs(backpack:GetChildren()) do hookTool(child) end
    connect(backpack.ChildAdded, hookTool)
    connect(player.CharacterAdded, hookCharacter)
    if player.Character then hookCharacter(player.Character) end
    connect(UserInputService.InputBegan, function(input, processed)
        if processed or testing or player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = true; Controller.Fire()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(true)
        elseif input.KeyCode == Enum.KeyCode.R then Controller.Reload()
        elseif input.KeyCode == Enum.KeyCode.F then Controller.Inspect()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(false)
        end
    end)
    connect(UserInputService.WindowFocusReleased, function() trigger, aiming, sprinting = false, false, false end)
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 2, render)
    return Controller
end
function Controller.Destroy()
    clear()
    RunService:UnbindFromRenderStep(renderName)
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    for ob, transparency in pairs(hidden) do if ob.Parent then ob.LocalTransparencyModifier = transparency end end
    for _, c in ipairs(casings) do c.Part:Destroy() end
    if hud then hud:Destroy() end
    if controlBridge then controlBridge:Destroy(); controlBridge = nil end
    ContextActionService:UnbindAction('ReferenceFPS_TestKeys')
    if testing then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end
    testing = false
    UserInputService.MouseIconEnabled = true
    connections, crossLines, casings, hidden = {}, {}, {}, setmetatable({}, {__mode = 'k'})
    hooked = setmetatable({}, {__mode = 'k'})
    started = false
end
return Controller]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeAKClient]====] ]=[====[-- Claude's guns client: firing feel (recoil climb, shake, screen fuzz, smoke, shells, tracers, impacts,
-- dynamic crosshair, hit markers, reload sound). Visuals only. The server decides every hit.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package:WaitForChild("Config"))
local Fx = require(package:WaitForChild("Fx"))
local Controller = require(ReplicatedStorage:WaitForChild("ReferenceWeapons"):WaitForChild("Controller"))

local player = Players.LocalPlayer
local random = Random.new()

local pendingPitch, pendingYaw = 0, 0
local shake, lastShake = 0, CFrame.identity
local heat, lastShotAt, smokeTimer = 0, -10, 0
local fuzz, flash, bloom = 0, 0, 0
local activeModel, activeSpec

-- pre-made shot sounds per weapon so rapid fire overlaps cleanly
local shotSounds, shotIndex = {}, {}
for id, w in Config.Weapons do
	shotSounds[id], shotIndex[id] = {}, 0
	for i = 1, 4 do
		local s = Instance.new("Sound")
		s.Name = "ClaudeShot" .. id .. "_" .. i
		s.SoundId = w.Shot
		s.Volume = w.ShotVolume or 0.7
		s.Parent = SoundService
		shotSounds[id][i] = s
	end
end
local reloadSound = Instance.new("Sound")
reloadSound.Name = "ClaudeReload"
reloadSound.Volume = 0.6
reloadSound.Parent = SoundService

-- screen fuzz: world blurs and pops for a split second, the viewmodel (GUI) stays sharp
local blur = Instance.new("BlurEffect")
blur.Name = "ClaudeGunFuzz"
blur.Size = 0
blur.Parent = Lighting
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ClaudeGunFlash"
grade.Parent = Lighting

local function weaponFor(spec)
	return spec and Config.Weapons[spec.Id]
end

local function muzzleFrame(model, spec)
	local root = model.PrimaryPart.CFrame
	return CFrame.lookAlong((root * CFrame.new(spec.Muzzle)).Position, root.LookVector), root
end

local function spreadDirection(look, degrees)
	local cf = CFrame.lookAlong(Vector3.zero, look)
	local angle = math.rad(degrees) * math.sqrt(random:NextNumber())
	local spin = random:NextNumber(0, math.pi * 2)
	return (cf * CFrame.Angles(0, 0, spin) * CFrame.Angles(angle, 0, 0)).LookVector
end

local function rayParams()
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = {player.Character, Fx.GetFolder()}
	return p
end

-- hit marker + dynamic crosshair
local gui = Instance.new("ScreenGui")
gui.Name = "ClaudeGunHUD"
gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = true, false, 9
gui.Parent = player:WaitForChild("PlayerGui")
local function line(parent, w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(w, h)
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Parent = parent
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(0, 0, 0)
	st.Transparency = 0.5
	st.Parent = f
	return f, st
end
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.Size = UDim2.fromOffset(1, 1)
cross.BackgroundTransparency = 1
cross.Visible = false
cross.Parent = gui
local arms = {}
for i, dir in {Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)} do
	local f, st = line(cross, dir.X ~= 0 and 9 or 2, dir.Y ~= 0 and 9 or 2)
	arms[i] = {Frame = f, Stroke = st, Dir = dir}
end
local dot, dotStroke = line(cross, 2, 2)

local marker = Instance.new("Frame")
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Position = UDim2.fromScale(0.5, 0.5)
marker.Size = UDim2.fromOffset(28, 28)
marker.BackgroundTransparency = 1
marker.Parent = gui
local ticks = {}
for i = 1, 4 do
	local f = Instance.new("Frame")
	local a = math.rad(45 + 90 * i)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(9, 2)
	f.Position = UDim2.new(0.5, math.cos(a) * 9, 0.5, math.sin(a) * 9)
	f.Rotation = 45 + 90 * i
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 1
	f.Parent = marker
	ticks[i] = f
end
local markerTween
local function showHit(headshot, killed)
	local color = killed and Color3.fromRGB(255, 70, 60) or (headshot and Color3.fromRGB(255, 214, 90) or Color3.new(1, 1, 1))
	marker.Size = UDim2.fromOffset(killed and 40 or 28, killed and 40 or 28)
	for _, f in ticks do
		f.BackgroundColor3 = color
		f.BackgroundTransparency = 0
		TweenService:Create(f, TweenInfo.new(killed and 0.45 or 0.22), {BackgroundTransparency = 1}):Play()
	end
	if markerTween then markerTween:Cancel() end
	markerTween = TweenService:Create(marker, TweenInfo.new(0.12), {Size = UDim2.fromOffset(22, 22)})
	markerTween:Play()
end

local function onShot(spec, model, aiming)
	local weapon = weaponFor(spec)
	if not weapon or not model or not model.PrimaryPart then return end
	activeModel, activeSpec = model, spec
	local camera = workspace.CurrentCamera
	local camCF = camera.CFrame
	local third = player:GetAttribute("ThirdPersonView") ~= false
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local worldModel = tool and tool:FindFirstChild("WorldModel")
	local worldRoot = worldModel and worldModel:FindFirstChild("Root")
	-- aim point: from the camera through the crosshair
	local aimDir = spreadDirection(camCF.LookVector, (aiming and weapon.SpreadAim or weapon.SpreadHip) + bloom * 0.04)
	local camHit = workspace:Raycast(camCF.Position, aimDir * Config.Range, rayParams())
	local aimPoint = camHit and camHit.Position or camCF.Position + aimDir * Config.Range
	local origin, muzzle, root
	if third and head and worldRoot then
		-- third person: bullets leave from the head line toward the crosshair, effects at the gun in your hands
		origin = head.Position
		root = worldRoot.CFrame
		local m = worldRoot:FindFirstChild("Muzzle")
		muzzle = CFrame.lookAt(m and m.WorldPosition or root.Position, aimPoint)
	else
		origin = camCF.Position
		muzzle, root = muzzleFrame(model, spec)
	end
	local dir = (aimPoint - origin).Unit

	package.Shoot:FireServer(origin, dir)

	shotIndex[spec.Id] = shotIndex[spec.Id] % 4 + 1
	local snd = shotSounds[spec.Id][shotIndex[spec.Id]]
	snd.PlaybackSpeed = random:NextNumber(0.95, 1.05)
	snd.TimePosition = 0
	snd:Play()

	Fx.Muzzle(muzzle, not third, weapon.FlashScale)
	local pellets = weapon.Pellets or 1
	for i = 1, pellets do
		local d = pellets > 1 and spreadDirection(dir, weapon.PelletSpread or 4) or dir
		local hit = workspace:Raycast(origin, d * Config.Range, rayParams())
		local hitPos = hit and hit.Position or origin + d * Config.Range
		if i <= 4 then Fx.Tracer(muzzle.Position + muzzle.LookVector * 0.3, hitPos) end
		if hit then
			local m2 = hit.Instance:FindFirstAncestorOfClass("Model")
			local isChar = m2 and m2:FindFirstChildOfClass("Humanoid") ~= nil
			Fx.Impact(hit.Position, hit.Normal, hit.Material, hit.Instance.Color, isChar, i == 1)
		end
	end
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local port = root * CFrame.new(weapon.Eject)
	task.delay(0.02, Fx.Shell, port, root.RightVector + root.UpVector * 0.35, hrp and hrp.AssemblyLinearVelocity, weapon.ShellSize)

	local aimScale = aiming and 0.7 or 1
	pendingPitch += math.rad(weapon.ClimbPitch * aimScale * random:NextNumber(0.85, 1.15))
	pendingYaw += math.rad(weapon.ClimbYaw * aimScale * random:NextNumber(-1, 1.25))
	shake = math.min(shake + (aiming and 0.5 or 1) * weapon.Shake, 3)
	fuzz = math.min(fuzz + weapon.Fuzz * (third and 0.5 or 1), 1.6)
	flash = 1
	bloom = math.min(bloom + (spec.Pistol and 9 or 6), 26)
	heat = math.min(heat + 1, 20)
	lastShotAt = os.clock()
end
Controller.Shot:Connect(onShot)

package.HitConfirm.OnClientEvent:Connect(showHit)

-- reload sound, synced to the reload length
player:GetAttributeChangedSignal("FPSReloading"):Connect(function()
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	if player:GetAttribute("FPSReloading") and weapon and weapon.Reload then
		reloadSound.SoundId = weapon.Reload
		reloadSound.PlaybackSpeed = (weapon.ReloadClipLength or weapon.ReloadTime) / weapon.ReloadTime
		reloadSound.TimePosition = 0
		reloadSound:Play()
	else
		reloadSound:Stop()
	end
end)

local MATERIALS = {}
for _, m in Enum.Material:GetEnumItems() do MATERIALS[m.Name] = m end

-- other players' shots: flash at their gun, tracer, impact, 3D sound
package.Replicate.OnClientEvent:Connect(function(shooter, hitPos, normal, materialName, isChar, weaponId)
	local weapon = Config.Weapons[weaponId or "W1"] or Config.Weapons.W1
	local character = shooter and shooter.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local muzzleAttachment = tool and tool:FindFirstChild("Muzzle", true)
	local head = character and character:FindFirstChild("Head")
	local from = muzzleAttachment and muzzleAttachment.WorldPosition or (head and head.Position)
	if not from then return end
	local dir = (hitPos - from)
	if dir.Magnitude < 0.01 then return end
	local cf = CFrame.lookAlong(from, dir.Unit)
	Fx.Muzzle(cf, false, weapon.FlashScale)
	Fx.Tracer(from, hitPos)
	local soundParent = muzzleAttachment and muzzleAttachment.Parent or head
	Fx.Sound(weapon.Shot, soundParent, 0.9, random:NextNumber(0.95, 1.05))
	local color
	local probe = workspace:Raycast(hitPos + normal * 0.3, -normal * 0.6, rayParams())
	if probe then color = probe.Instance.Color end
	Fx.Impact(hitPos, normal, MATERIALS[materialName] or Enum.Material.Concrete, color, isChar, true)
	if tool and tool:FindFirstChild("Handle") then
		local h = tool.Handle.CFrame
		Fx.Shell(CFrame.lookAlong(h.Position, dir.Unit), CFrame.lookAlong(Vector3.zero, dir.Unit).RightVector, Vector3.zero, weapon.ShellSize)
	end
end)

-- blocky Roblox arms on Claude's guns take the player's skin and sleeve colors
local function paintArms()
	local skin = player:GetAttribute("EquippedHandColor")
	local sleeve = player:GetAttribute("EquippedSleeveColor")
	local character = player.Character
	local bodyColors = character and character:FindFirstChildOfClass("BodyColors")
	if not skin and bodyColors then skin = bodyColors.RightArmColor3 end
	for id in Config.Weapons do
		local template = ReplicatedStorage.ReferenceWeapons.Viewmodels:FindFirstChild(id)
		if template then
			for _, p in template:GetChildren() do
				local kind = p:GetAttribute("ArmPart")
				if kind == "Skin" and skin then p.Color = skin end
				if kind == "Sleeve" and sleeve then p.Color = sleeve end
			end
		end
	end
end
paintArms()
player:GetAttributeChangedSignal("EquippedHandColor"):Connect(paintArms)
player:GetAttributeChangedSignal("EquippedSleeveColor"):Connect(paintArms)
player.CharacterAdded:Connect(function() task.wait(1); paintArms() end)

local hudMark
RunService:BindToRenderStep("ClaudeGunFeel", Enum.RenderPriority.Camera.Value + 3, function(dt)
	dt = math.min(dt, 0.05)
	local camera = workspace.CurrentCamera
	if not camera then return end
	-- climb: eased in over a few frames, never undone
	local k = 1 - math.exp(-dt * 28)
	local p, y = pendingPitch * k, pendingYaw * k
	pendingPitch -= p
	pendingYaw -= y
	-- shake: random jitter that is undone next frame
	shake *= math.exp(-dt * 16)
	local amp = math.rad(0.18) * shake
	local newShake = CFrame.Angles(random:NextNumber(-amp, amp), random:NextNumber(-amp, amp), random:NextNumber(-amp, amp) * 1.6)
	camera.CFrame = camera.CFrame * lastShake:Inverse() * CFrame.Angles(p, y, 0) * newShake
	lastShake = newShake
	-- fuzz + flash pop
	fuzz *= math.exp(-dt * 11)
	flash *= math.exp(-dt * 32)
	blur.Size = math.clamp(fuzz * 3.2, 0, 5)
	grade.Brightness = 0.06 * flash
	grade.Contrast = 0.08 * flash
	grade.Saturation = -0.12 * math.min(fuzz, 1)
	-- barrel smoke after bursts
	local now = os.clock()
	if now - lastShotAt > 0.15 then heat = math.max(0, heat - dt * 6) end
	smokeTimer -= dt
	if heat > 4 and now - lastShotAt > 0.1 and smokeTimer <= 0 then
		smokeTimer = 0.07
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		local wm = tool and tool:FindFirstChild("WorldModel")
		local m = wm and wm:FindFirstChild("Muzzle", true)
		if player:GetAttribute("ThirdPersonView") ~= false and m then
			Fx.BarrelSmoke(m.WorldCFrame, math.clamp(heat / 15, 0.2, 1))
		elseif activeModel and activeModel.Parent and activeModel.PrimaryPart then
			Fx.BarrelSmoke(muzzleFrame(activeModel, activeSpec), math.clamp(heat / 15, 0.2, 1))
		end
	end
	-- dynamic crosshair: opens with shots, movement and jumping, fades when aiming
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	local show = weapon ~= nil and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
	cross.Visible = show
	hudMark = hudMark and hudMark.Parent and hudMark or player.PlayerGui:FindFirstChild("AimMark", true)
	if hudMark and hudMark ~= cross then hudMark.Visible = not show end
	if show then
		bloom *= math.exp(-dt * 7)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local speed = root and (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude or 0
		local air = humanoid and humanoid.FloorMaterial == Enum.Material.Air and 10 or 0
		local aim = player:GetAttribute("FPSAiming") and 1 or 0
		local gap = 6 + bloom + math.min(speed, 24) * 0.45 + air
		for _, a in arms do
			a.Frame.Position = UDim2.fromOffset(a.Dir.X * (gap + 4.5), a.Dir.Y * (gap + 4.5))
			a.Frame.BackgroundTransparency = aim * 0.95
			a.Stroke.Transparency = 0.5 + aim * 0.5
		end
		dot.BackgroundTransparency = aim
		dotStroke.Transparency = 0.5 + aim * 0.5
	end
end)
]====],
[ [====[ServerScriptService.ClaudeAKServer.Logic]====] ]=[====[-- Server authority for Claude's guns: validates every shot, raycasts, applies damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package.Config)

local Logic = {}
local state = {}
local BODY = {Head = "Head", UpperTorso = "Body", LowerTorso = "Body", Torso = "Body", HumanoidRootPart = "Body"}

local function finiteVector(v)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 1e6 and math.abs(v.Y) < 1e6 and math.abs(v.Z) < 1e6
end

local function equippedWeapon(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	local id = tool and tool:GetAttribute("ReferenceWeaponId")
	return id and Config.Weapons[id], id
end

local function sameTeam(a, b)
	return a.Team ~= nil and a.Team == b.Team and not a.Neutral
end

local random = Random.new()

-- one ray: skips invisible non-solid parts, returns the hit and the humanoid/zone if it hit a character
local function castRay(character, origin, direction)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {character}
	local fx = workspace:FindFirstChild("ClaudeAKFx")
	if fx then table.insert(ignore, fx) end
	params.FilterDescendantsInstances = ignore
	local result
	local from = origin
	local remaining = Config.Range
	for _ = 1, 6 do
		result = workspace:Raycast(from, direction * remaining, params)
		if not result then break end
		local inst = result.Instance
		local m = inst:FindFirstAncestorOfClass("Model")
		if (m and m:FindFirstChildOfClass("Humanoid")) or inst.CanCollide or inst.Transparency < 0.9 then break end
		table.insert(ignore, inst)
		params.FilterDescendantsInstances = ignore
		remaining -= (result.Position - from).Magnitude
		from = result.Position
		result = nil
	end
	if not result then return origin + direction * Config.Range, Vector3.yAxis, "" end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local target = model and model:FindFirstChildOfClass("Humanoid")
	if not target or target.Health <= 0 or model == character then
		return result.Position, result.Normal, result.Material.Name
	end
	local partName = result.Instance.Name
	if result.Instance:FindFirstAncestorOfClass("Accessory") then partName = "Head" end
	return result.Position, result.Normal, result.Material.Name, target, BODY[partName] or "Limb", (result.Position - origin).Magnitude
end

local function onShoot(player, origin, direction)
	if not finiteVector(origin) or not finiteVector(direction) then return end
	if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end
	direction = direction.Unit
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end
	local weapon, weaponId = equippedWeapon(character)
	if not weapon then return end
	-- origin must be near the shooter's head (camera); otherwise use the head
	if (origin - head.Position).Magnitude > 7 then origin = head.Position end
	local now = os.clock()
	state[player] = state[player] or {}
	local s = state[player][weaponId]
	if not s then s = {Last = 0, Mag = weapon.MagazineSize}; state[player][weaponId] = s end
	if s.Mag <= 0 then
		if now - s.Last < weapon.ReloadTime * 0.75 then return end
		s.Mag = weapon.MagazineSize
	end
	if now - s.Last < 60 / weapon.RPM * 0.8 then return end
	s.Last = now
	s.Mag -= 1

	local pellets = weapon.Pellets or 1
	local totals = {}
	for i = 1, pellets do
		local dir = direction
		if pellets > 1 then
			local cf = CFrame.lookAlong(Vector3.zero, direction)
			local a = math.rad(weapon.PelletSpread or 4) * math.sqrt(random:NextNumber())
			dir = (cf * CFrame.Angles(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.Angles(a, 0, 0)).LookVector
		end
		local hitPos, normal, material, target, zone, dist = castRay(character, origin, dir)
		if target then
			local victim = Players:GetPlayerFromCharacter(target.Parent)
			if not (victim and sameTeam(player, victim)) then
				local falloff = 1 - math.clamp((dist - weapon.FalloffNear) / (weapon.FalloffFar - weapon.FalloffNear), 0, 1) * (1 - weapon.MinScale)
				local t = totals[target] or {Damage = 0, Head = false}
				t.Damage += weapon.Damage[zone] * falloff
				t.Head = t.Head or zone == "Head"
				totals[target] = t
			end
		end
		if i <= 4 then
			for _, other in Players:GetPlayers() do
				if other ~= player then
					package.Replicate:FireClient(other, player, hitPos, normal, material, target ~= nil, weaponId)
				end
			end
		end
	end
	for target, t in totals do
		if target.Health > 0 then
			local damage = math.floor(t.Damage + 0.5)
			target:TakeDamage(damage)
			package.HitConfirm:FireClient(player, t.Head, target.Health <= 0, damage)
		end
	end
end

-- third-person aim pitch, shared with every client for the arm pose
local lastPitch = {}
local function onAimPitch(player, pitch)
	if typeof(pitch) ~= "number" or pitch ~= pitch then return end
	local now = os.clock()
	if now - (lastPitch[player] or 0) < 0.05 then return end
	lastPitch[player] = now
	player:SetAttribute("AimPitch", math.clamp(pitch, -1.3, 1.3))
end

function Logic.Start()
	package.Shoot.OnServerEvent:Connect(onShoot)
	package.AimPitch.OnServerEvent:Connect(onAimPitch)
	Players.PlayerRemoving:Connect(function(p) state[p] = nil end)
end

return Logic
]====],
}
local changes={
[ [====[ReplicatedStorage.LobbySystem.Config]====] ]=[====[local C = {
    TeamName = "Survivors",
    TeamColor = BrickColor.new("Earth green"),
    LobbyCenter = Vector3.new(1000, 0, 0),
    LobbySpawn = CFrame.lookAt(Vector3.new(1000, 4.5, 20), Vector3.new(1000, 4.5, -5)),
    ArenaSpawn = CFrame.lookAt(Vector3.new(0, 4.6, 0), Vector3.new(0, 4.6, -15)),
    Countdown = 10,
    ScanInterval = .2,
    Modes = {
        {Id="Solos", Size=1, X=-63, Color=Color3.fromRGB(75,210,156)},
        {Id="Duos", Size=2, X=-21, Color=Color3.fromRGB(64,170,243)},
        {Id="Trios", Size=3, X=21, Color=Color3.fromRGB(180,125,249)},
        {Id="Squads", Size=4, X=63, Color=Color3.fromRGB(245,173,77)},
    },
}
C.Queues = {}
for _,mode in C.Modes do
    for slot=1,2 do
        table.insert(C.Queues, {
            Id=mode.Id.."_"..slot, Mode=mode.Id, Slot=slot, Size=mode.Size,
            X=mode.X, Z=slot==1 and -9 or 9, Radius=7, Color=mode.Color,
        })
    end
end
return C
]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementConfig]====] ]=[====[return {
    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=0, CrouchCameraDrop=.60, SlideSpeed=36, SlideEndSpeed=18,
    SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
    StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
    ExhaustionRecovery=15, HipDrop=1.05, CameraDrop=.65,
    SprintFov=8, SlideFov=10, CameraShakeScale=1,
    MinimapHeight=155, MinimapFov=70,
}
]====],
[ [====[ReplicatedStorage.GameplayPresentation.CharacterPose]====] ]=[====[-- Client-evaluated R15 pose. Server attributes remain the movement/aim authority.
-- Supports Avatar Joint Upgrade without changing rig attachments or asset IDs.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local C=require(script.Parent.MovementConfig)
local P={}
local started=false
local records={}
local localPlayer=Players.LocalPlayer
local rad=math.rad
local identity=CFrame.identity
local profiles={
    W1={Grip=Vector3.new(.12,.50,-.55),Support=Vector3.new(-.12,.08,-.62)},
    W2={Grip=Vector3.new(.12,.45,-.55),Support=Vector3.new(-.12,.10,-.55)},
    W3={Grip=Vector3.new(.15,.30,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
}
local crouch={Waist=8,LeftHip=-70,RightHip=-70,LeftKnee=140,RightKnee=140,LeftAnkle=-70,RightAnkle=-70}
local slide={
    Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
    Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
    RightHip=CFrame.Angles(rad(95),0,rad(-4)),RightKnee=CFrame.Angles(rad(-8),0,0),
    RightAnkle=CFrame.Angles(rad(-77),0,0),
    LeftHip=CFrame.Angles(rad(110),0,rad(8)),LeftKnee=CFrame.Angles(rad(-145),0,0),
    LeftAnkle=CFrame.Angles(rad(45),0,0),
    RightShoulder=CFrame.Angles(rad(30),0,rad(12)),RightElbow=CFrame.Angles(rad(-35),0,0),
    LeftShoulder=CFrame.Angles(rad(22),0,rad(-25)),LeftElbow=CFrame.Angles(rad(-55),0,0),
}
local function joint(c,name)
    local j=c:FindFirstChild(name,true)
    if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then return j end
end
local function reset(rec)
    for j,saved in rec.Applied do
        -- Do not undo an Animator/another system's newer evaluation.
        if j.Parent and j.Transform==saved.Value then j.Transform=saved.Base end
    end
    rec.Applied={}
end
local function set(rec,j,value)
    if not j or not j.Parent then return end
    local old=rec.Applied[j]
    rec.Applied[j]={Base=old and old.Base or j.Transform,Value=value}
    j.Transform=value
end
local function world(rec,part,cache)
    if cache[part] then return cache[part] end
    local j=rec.ByPart[part]
    local cf
    if j and j.Part0 then cf=world(rec,j.Part0,cache)*j.C0*j.Transform*j.C1:Inverse()
    else cf=part.CFrame end
    cache[part]=cf
    return cf
end
local function segment(localA,localB,worldA,worldB,normal)
    return CFrame.lookAt(worldA,worldB,normal)*CFrame.lookAt(localA,localB,Vector3.zAxis):Inverse()
end
local function arm(rec,side,torsoCF,handCF)
    local sh=rec.Joints[side.."Shoulder"]
    local el=rec.Joints[side.."Elbow"]
    local wr=rec.Joints[side.."Wrist"]
    if not sh or not el or not wr then return nil end
    local a=(torsoCF*sh.C0).Position
    local target=(handCF*wr.C1).Position
    local l1=(el.C0.Position-sh.C1.Position).Magnitude
    local l2=(wr.C0.Position-el.C1.Position).Magnitude
    local delta=target-a
    if l1<.01 or l2<.01 or delta.Magnitude<.01 then return nil end
    local dir=delta.Unit
    local length=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
    local wrist=a+dir*length
    local bend=torsoCF:VectorToWorldSpace(Vector3.new(side=="Right" and .7 or -.7,-1,.25))
    bend-=dir*bend:Dot(dir)
    if bend.Magnitude<.01 then bend=torsoCF.UpVector:Cross(dir) end
    bend=bend.Unit
    local x=(l1*l1-l2*l2+length*length)/(2*length)
    local elbow=a+dir*x+bend*math.sqrt(math.max(0,l1*l1-x*x))
    local normal=dir:Cross(bend).Unit
    local upper=segment(sh.C1.Position,el.C0.Position,a,elbow,normal)
    local lower=segment(el.C1.Position,wr.C0.Position,elbow,wrist,normal)
    -- If an unusual body scale exceeds reach, keep the chain connected.
    handCF=CFrame.new(wrist-target)*handCF
    set(rec,sh,sh.C0:Inverse()*torsoCF:ToObjectSpace(upper)*sh.C1)
    set(rec,el,el.C0:Inverse()*upper:ToObjectSpace(lower)*el.C1)
    set(rec,wr,wr.C0:Inverse()*lower:ToObjectSpace(handCF)*wr.C1)
    return handCF,(wrist-target).Magnitude
end
local function getRecord(plr,c)
    local rec=records[plr]
    if rec and rec.Char~=c then reset(rec);records[plr]=nil;rec=nil end
    if not rec then
        rec={Char=c,Joints={},ByPart={},Applied={},Slide=0,Crouch=0}
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
        records[plr]=rec
    end
    if os.clock()>(rec.ScanAt or 0) then
        rec.ScanAt=os.clock()+1
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
    end
    return rec
end
local function floorClearance(rec)
    local rootJoint=rec.Joints.Root
    local hrp=rec.Char:FindFirstChild("HumanoidRootPart")
    if not rootJoint or not hrp then return end
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={rec.Char}
    params.RespectCanCollide=true
    params.CollisionGroup=hrp.CollisionGroup
    local cache={}
    local lift=0
    for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LowerTorso"} do
        local part=rec.Char:FindFirstChild(name)
        if part then
            local cf=world(rec,part,cache)
            local hit=workspace:Raycast(Vector3.new(cf.X,hrp.Position.Y+1,cf.Z),Vector3.new(0,-7,0),params)
            if hit and hit.Normal.Y>.6 then
                local low=math.huge
                for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
                    low=math.min(low,(cf*Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)).Y)
                end end end
                lift=math.max(lift,hit.Position.Y+.14-low)
            end
        end
    end
    lift=math.clamp(lift,0,1.8)
    if lift>0 then
        local parentFrame=world(rec,rootJoint.Part0,{})*rootJoint.C0
        set(rec,rootJoint,CFrame.new(parentFrame:VectorToObjectSpace(Vector3.new(0,lift,0)))*rootJoint.Transform)
    end
    rec.ClearanceLift=lift
end
local function evaluate(dt)
    dt=math.min(dt,.05)
    for _,plr in Players:GetPlayers() do
        local c=plr.Character
        if c then
            local rec=getRecord(plr,c)
            local h=c:FindFirstChildOfClass("Humanoid")
            local live=h and h.Health>0 and not plr:GetAttribute("CutsceneActive")
            local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
            local crouched=live and plr:GetAttribute("MovementCrouched")==true
            rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
            rec.Crouch+=( (crouched and 1 or 0)-rec.Crouch)*(1-math.exp(-dt*16))
            if live then
                for name,angle in crouch do
                    local j=rec.Joints[name]
                    if j and rec.Crouch>.001 then set(rec,j,j.Transform:Lerp(CFrame.Angles(rad(angle),0,0),rec.Crouch)) end
                end
                if rec.Crouch>.001 and rec.Joints.Root then set(rec,rec.Joints.Root,rec.Joints.Root.Transform*CFrame.new(0,-1.05*rec.Crouch,0))end
                if rec.Slide>.001 then
                    for name,pose in slide do
                        local j=rec.Joints[name]
                        if j then set(rec,j,j.Transform:Lerp(pose,rec.Slide)) end
                    end
                end
                if sliding then rec.ClearanceUntil=os.clock()+.4 end
                if os.clock()<(rec.ClearanceUntil or 0) or rec.Crouch>.001 then floorClearance(rec) end
                local tool=c:FindFirstChildOfClass("Tool")
                local id=tool and tool:GetAttribute("ReferenceWeaponId")
                local profile=profiles[id]
                local torso=c:FindFirstChild("UpperTorso")
                local hand=c:FindFirstChild("RightHand")
                local handle=tool and tool:FindFirstChild("Handle")
                local model=tool and tool:FindFirstChild("WorldModel")
                local root=model and model:FindFirstChild("Root")
                local weld=hand and hand:FindFirstChild("RightGrip")
                if profile and torso and hand and root and handle and weld and not plr:GetAttribute("InLobby") then
                    local camera=workspace.CurrentCamera
                    local pitch=plr==localPlayer and camera and math.asin(math.clamp(camera.CFrame.LookVector.Y,-1,1)) or plr:GetAttribute("AimPitch") or 0
                    pitch=math.clamp(pitch,rad(-70),rad(70))
                    local waist=rec.Joints.Waist
                    local neck=rec.Joints.Neck
                    if waist then set(rec,waist,waist.Transform*CFrame.Angles(pitch*.35,0,0)) end
                    if neck then set(rec,neck,neck.Transform*CFrame.Angles(pitch*.4,0,0)) end
                    local torsoCF=world(rec,torso,{})
                    local bodyRoot=c:FindFirstChild("HumanoidRootPart")
                    local forward=bodyRoot and bodyRoot.CFrame.LookVector*Vector3.new(1,0,1) or torsoCF.LookVector*Vector3.new(1,0,1)
                    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) end
                    local aim=forward.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
                    local gunCF=CFrame.new(torsoCF:PointToWorldSpace(profile.Grip))*CFrame.lookAt(Vector3.zero,aim)
                    local handToRoot=weld.C0*weld.C1:Inverse()*handle.CFrame:ToObjectSpace(root.CFrame)
                    local rightCF=gunCF*handToRoot:Inverse()
                    local actualRight,rightError=arm(rec,"Right",torsoCF,rightCF)
                    if actualRight then
                        gunCF=actualRight*handToRoot
                        local leftCF=gunCF*CFrame.new(profile.Support)*handToRoot.Rotation:Inverse()
                        local _,leftError=arm(rec,"Left",torsoCF,leftCF)
                        rec.Weapon=id;rec.RightError=rightError;rec.LeftError=leftError
                        rec.Support=profile.Support
                    end
                else rec.Weapon=nil;rec.LeftError=nil;rec.RightError=nil end
            end
        end
    end
end
function P.State(plr)
    local rec=records[plr or localPlayer]
    if not rec then return {} end
    local count=0;for _ in rec.Joints do count+=1 end
    return {JointCount=count,Slide=rec.Slide,Crouch=rec.Crouch,Weapon=rec.Weapon,LeftError=rec.LeftError,RightError=rec.RightError,Support=rec.Support,ClearanceLift=rec.ClearanceLift}
end
function P.Start()
    if started then return P end;started=true
    RunService.PreAnimation:Connect(function()for _,rec in records do reset(rec)end end)
    -- One pose writer, after Animator, for aim + slide. No frame-order tug of war.
    RunService.PreSimulation:Connect(evaluate)
    Players.PlayerRemoving:Connect(function(plr)if records[plr]then reset(records[plr]);records[plr]=nil end end)
    return P
end
return P]====],
[ [====[ReplicatedStorage.GameplayPresentation.MovementClient]====] ]=[====[local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local C=require(script.Parent.MovementConfig)
local p=Players.LocalPlayer
local remote=script.Parent:WaitForChild('MovementRequest')
local M={}
local started=false
local held,toggled,sent,forced=false,false,false,false
local phase,fov,drop,amount=0,0,0,0
local lastOffset=CFrame.identity
local previousMode='Idle'
local slideAge=10
local oldGrounded=true
local landing=0
local char,hum,root
local baseCameraOffset=Vector3.zero
local queuedSlideUntil=0
local queuedSlideStamp,lastChainAttempt=0,-10
local function deployed()
    return char and char.Parent and hum and hum.Health>0 and not p:GetAttribute('CutsceneActive') and ((not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')) or p:GetAttribute('InLobby')==true)
end
local function sendSprint(value)
    if value~=sent then sent=value;remote:FireServer('Sprint',value)end
end
function M.Sprint(value)
    if value and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
    forced=value==true;held=forced
    if not value then toggled=false;sendSprint(false)end
    return true
end
function M.Slide()
    if not deployed() then return false end
    if p:GetAttribute('MovementState')=='Sliding' then
        queuedSlideUntil=os.clock()+C.SlideBuffer
        queuedSlideStamp=p:GetAttribute('SlideStartedAt') or 0
        return true
    end
    local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
    if v.Magnitude<C.SlideMinSpeed or hum.FloorMaterial==Enum.Material.Air then return false end
    remote:FireServer('Slide',v.Unit);return true
end
function M.Crouch(value)
    if not deployed()then return false end
    queuedSlideUntil=0
    if value then held,toggled,forced=false,false,false;sendSprint(false)end
    remote:FireServer('Crouch',value==true)
    return true
end
function M.Stance()
    local mode=p:GetAttribute('MovementState')
    if mode=='Sliding' or mode=='Sprinting'then return M.Slide()end
    return M.Crouch(not p:GetAttribute('MovementCrouched'))
end
function M.CancelSlide()queuedSlideUntil=0;remote:FireServer('CancelSlide');return true end
function M.GetState()
    return {Mode=p:GetAttribute('MovementState') or 'Idle',Stamina=p:GetAttribute('MovementStamina') or 100,
        FovOffset=fov,CameraDrop=drop,ShakeDegrees=amount,SlideReadyIn=p:GetAttribute('SlideReadyIn') or 0,
        WalkSpeed=hum and hum.WalkSpeed,Grounded=hum and hum.FloorMaterial~=Enum.Material.Air,
        Crouched=p:GetAttribute('MovementCrouched')==true,
        CameraOffsetY=hum and hum.CameraOffset.Y,SlideBuffered=queuedSlideUntil>os.clock(),
        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y,Pose=require(script.Parent.CharacterPose).State(p)}
end
local function hook(c)
    char=c;hum=c:WaitForChild('Humanoid');root=c:WaitForChild('HumanoidRootPart')
    held,toggled,sent,forced=false,false,false,false
    baseCameraOffset=hum.CameraOffset;queuedSlideUntil=0
    drop,fov,landing=0,0,0
end
function M.Start()
    if started then return M end;started=true
    if p.Character then task.spawn(hook,p.Character)end
    p.CharacterAdded:Connect(hook)
    require(script.Parent.CharacterPose).Start()
    p.CharacterRemoving:Connect(function(c)
        if char==c then
            if hum and hum.Parent then hum.CameraOffset=baseCameraOffset end
            queuedSlideUntil=0;char,hum,root=nil,nil,nil;sendSprint(false)
        end
    end)
    CAS:BindActionAtPriority('GameplaySprint',function(_,state,input)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin and p:GetAttribute('MovementCrouched')then M.Crouch(false)end
        if input.KeyCode==Enum.KeyCode.ButtonL3 and state==Enum.UserInputState.Begin then toggled=not toggled
        elseif state==Enum.UserInputState.Begin then held=true
        elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false;forced=false end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
    CAS:SetTitle('GameplaySprint','SPRINT');CAS:SetPosition('GameplaySprint',UDim2.fromScale(.72,.72))
    CAS:BindActionAtPriority('GameplaySlide',function(_,state)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin then M.Stance()end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.C,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB)
    CAS:SetTitle('GameplaySlide','CROUCH');CAS:SetPosition('GameplaySlide',UDim2.fromScale(.84,.72))
    UIS.InputBegan:Connect(function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.Space and p:GetAttribute('MovementState')=='Sliding'then M.CancelSlide()end
    end)
    UIS.WindowFocusReleased:Connect(function()held,toggled,forced=false,false,false;queuedSlideUntil=0;sendSprint(false)end)
    p:GetAttributeChangedSignal('MovementFireInterrupt'):Connect(function()sendSprint(false)end)
    local bridge=Instance.new('BindableFunction');bridge.Name='MovementControl'
    bridge.OnInvoke=function(action,value)
        if action=='Sprint'then return M.Sprint(value)
        elseif action=='Slide'then return M.Slide()
        elseif action=='Crouch'then return M.Crouch(value)
        elseif action=='CancelSlide'then return M.CancelSlide()end
        return M.GetState()
    end;bridge.Parent=p:WaitForChild('PlayerScripts')
    RunService:BindToRenderStep('GameplayMovementClean',Enum.RenderPriority.Camera.Value-1,function(dt)
        local camera=workspace.CurrentCamera
        if camera then camera.CFrame=camera.CFrame*lastOffset:Inverse()end
        lastOffset=CFrame.identity
        -- CameraOffset is consumed by Roblox's first-person camera this same frame.
        -- The later viewmodel pass sees the lowered camera without double-applying it.
        local live=deployed()
        local target=live and (p:GetAttribute('MovementState')=='Sliding' and C.CameraDrop or p:GetAttribute('MovementCrouched') and C.CrouchCameraDrop or 0) or 0
        local rate=target>drop and 24 or 14
        drop+=(target-drop)*(1-math.exp(-math.min(dt,.05)*rate))
        if not live then drop=0 end
        if hum and hum.Parent then hum.CameraOffset=baseCameraOffset+Vector3.new(0,-drop,0)end
        p:SetAttribute('MovementCameraDrop',drop)
    end)
    RunService:BindToRenderStep('GameplayMovementCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
        dt=math.min(dt,.05)
        local camera=workspace.CurrentCamera;if not camera or p:GetAttribute('CutsceneActive')then return end
        local live=deployed()
        local wants=live and (held or toggled or forced) and not UIS:GetFocusedTextBox()
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            and (p:GetAttribute('InLobby') or (not p:GetAttribute('FPSAiming') and not p:GetAttribute('FPSReloading'))) and not p:GetAttribute('MovementCrouched')
        sendSprint(wants==true)
        local state=live and p:GetAttribute('MovementState') or 'Idle'
        local sprint,slide=state=='Sprinting',state=='Sliding'
        if not live or not wants then queuedSlideUntil=0
        elseif queuedSlideUntil>0 and slide and (p:GetAttribute('SlideStartedAt') or 0)~=queuedSlideStamp then
            queuedSlideUntil=0
        elseif queuedSlideUntil>0 and not slide then
            if os.clock()<=queuedSlideUntil then
                local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
                if hum.FloorMaterial~=Enum.Material.Air and v.Magnitude>=C.SlideMinSpeed and os.clock()-lastChainAttempt>.12 then
                    lastChainAttempt=os.clock();remote:FireServer('Slide',v.Unit)
                end
            else queuedSlideUntil=0 end
        end
        if slide and previousMode~='Sliding'then slideAge=0 end
        slideAge+=dt
        local grounded=live and hum.FloorMaterial~=Enum.Material.Air
        if grounded and not oldGrounded and live then landing=.65 end
        oldGrounded=grounded;landing*=math.exp(-dt*12)
        previousMode=state
        local targetFov=slide and C.SlideFov or sprint and C.SprintFov or p:GetAttribute('MovementCrouched') and -2 or 0
        fov+=(targetFov-fov)*(1-math.exp(-dt*9))
        p:SetAttribute('MovementFovOffset',fov)
        if not live then amount=0;drop=0;fov=0;return end
        if camera.CameraType~=Enum.CameraType.Custom then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=hum end
        if not char:FindFirstChildOfClass('Tool')then camera.FieldOfView+=(72+fov-camera.FieldOfView)*(1-math.exp(-dt*10))end
        phase+=dt*(sprint and 13 or 9)
        local scale=math.clamp(p:GetAttribute('CameraShakeScale') or C.CameraShakeScale,0,1)
        local entry=slide and math.exp(-slideAge*9) or 0
        local pitch=(sprint and math.sin(phase*2)*.27 or 0)+(slide and math.sin(phase*3.4)*.14-entry*.85 or 0)-landing*.35
        local yaw=(sprint and math.sin(phase)*.15 or 0)+(slide and math.noise(os.clock()*18,2)*.28 or 0)
        local roll=(sprint and math.cos(phase)*.42 or 0)+(slide and entry*1.5+math.sin(phase*3)*.24 or 0)
        pitch,yaw,roll=pitch*scale,yaw*scale,roll*scale
        amount=math.sqrt(pitch*pitch+yaw*yaw+roll*roll)
        local bob=sprint and math.abs(math.sin(phase))*.025*scale or 0
        lastOffset=CFrame.new(0,-bob,0)*CFrame.Angles(math.rad(pitch),math.rad(yaw),math.rad(roll))
        camera.CFrame=camera.CFrame*lastOffset
        -- The weapon controller consumes MovementFovOffset before rendering its viewmodel.
    end)
    return M
end
return M
]====],
[ [====[ReplicatedStorage.LobbySystem.Client]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local p=Players.LocalPlayer
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local M={}
local started,third=false,true
local gui,panel,queueTitle,queueDetail,back,cameraButton,bridge
local links,parts={},{}
local characterLink
local original={Mode=p.CameraMode,Min=p.CameraMinZoomDistance,Max=p.CameraMaxZoomDistance}
local altered=setmetatable({},{__mode="k"})
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function new(class,props,parent)
    local o=Instance.new(class);for k,v in props do o[k]=v end;o.Parent=parent;return o
end
local function text(name,content,size,pos,parent)
    return new("TextLabel",{Name=name,Text=content,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=Color3.fromRGB(233,237,230),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function camera()
    local char=p.Character
    task.spawn(function()
        local h=char and char:WaitForChild("Humanoid",10)
        if not started or p.Character~=char or not h or p:GetAttribute("CutsceneActive")then return end
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h;cam.FieldOfView=72 end
        p.CameraMinZoomDistance=.5
        p.CameraMode=third and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        p.CameraMaxZoomDistance=p:GetAttribute("InLobby")and 12 or 6.2
        p.CameraMinZoomDistance=p:GetAttribute("InLobby")and 12 or 6.2
        UIS.MouseBehavior=third and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled=third
        p:SetAttribute("ThirdPersonView",third)
        cameraButton.Text=third and "CAM: THIRD  [V]" or "CAM: FIRST  [V]"
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not p:GetAttribute("InLobby")) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true) end)
    end)
end
-- Third person only (Cade, 2026-10-17). Claude's ClaudeThirdPerson script handles the shoulder cam + mouse lock.
function M.SetThirdPerson(value)
    third=true
    camera()
end
local function refresh()
    local lobby=p:GetAttribute("InLobby")==true
    back.Visible=not lobby and not p:GetAttribute("CutsceneActive") and p:GetAttribute("LobbyPhase")~="Teleporting"
    panel.Visible=lobby and (p:GetAttribute("QueuedQueueId") or "")~=""
end
local function hookCharacter(char)
    if characterLink then characterLink:Disconnect() end
    parts={}
    local function add(ob) if ob:IsA("BasePart") then table.insert(parts,ob) end end
    for _,ob in char:GetDescendants() do add(ob) end
    characterLink=char.DescendantAdded:Connect(add)
    camera();refresh()
end
function M.GetStats()
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
    return {ThirdPerson=third,Camera=p.CameraMode.Name,MinZoom=p.CameraMinZoomDistance,MaxZoom=p.CameraMaxZoomDistance,
        Banner=gui and gui:FindFirstChild("Status")~=nil,QueueId=p:GetAttribute("QueuedQueueId"),
        ViewmodelVisible=viewport and viewport.Visible,Connections=#links+(characterLink and 1 or 0)}
end
function M.Start()
    if started then return M end
    started=true
    require(RS.SurvivalRun.LobbyCamera).Start()
    gui=new("ScreenGui",{Name="SurvivorLobbyUI",ResetOnSpawn=false,DisplayOrder=42,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild("PlayerGui"))
    -- No title/status banner; queue information lives above each physical circle.
    panel=new("Frame",{Name="QueuePanel",Size=UDim2.new(.9,0,0,106),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-25),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.08,BorderSizePixel=0},gui)
    new("UISizeConstraint",{MaxSize=Vector2.new(560,106)},panel)
    new("UICorner",{CornerRadius=UDim.new(0,12)},panel)
    new("UIStroke",{Color=Color3.fromRGB(81,196,144),Transparency=.25},panel)
    queueTitle=text("Mode","",UDim2.new(1,-140,0,30),UDim2.fromOffset(16,13),panel)
    queueDetail=text("Countdown","",UDim2.new(1,-140,0,46),UDim2.fromOffset(16,43),panel);queueDetail.TextSize=12
    local leave=new("TextButton",{Name="LeaveQueue",Text="LEAVE",Size=UDim2.fromOffset(100,40),Position=UDim2.new(1,-116,.5,-20),BackgroundColor3=Color3.fromRGB(55,76,67),TextColor3=Color3.fromRGB(240,244,239),Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0},panel)
    new("UICorner",{CornerRadius=UDim.new(0,7)},leave)
    back=new("TextButton",{Name="ReturnToLobby",Text="LOBBY [M]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-212),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},back)
    cameraButton=new("TextButton",{Name="CameraMode",Text="CAM: THIRD  [V]",Size=UDim2.fromOffset(164,30),Position=UDim2.new(0,18,1,-174),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},cameraButton)
    connect(leave.Activated,function() package.Request:FireServer("Leave") end)
    connect(back.Activated,function() package.Request:FireServer("Return") end)
    cameraButton.Visible=false
    connect(UIS.InputBegan,function(input,processed)
        if processed or UIS:GetFocusedTextBox() then return end
        if input.KeyCode==Enum.KeyCode.M and not p:GetAttribute("InLobby") then package.Request:FireServer("Return")
        end
    end)
    RunService:BindToRenderStep("SurvivorLobbyCursor",Enum.RenderPriority.Last.Value+1,function()
        if third then
            -- Character/weapon initialization may request first person after our first camera setup.
            -- Reconcile the selected presentation mode after those render passes, without editing combat.
            local wanted=p:GetAttribute("InLobby")and 12 or p:GetAttribute("FPSAiming")and 4.2 or 6.2
            p.CameraMode=Enum.CameraMode.Classic
            if not p:GetAttribute("CutsceneActive")then p.CameraMaxZoomDistance=wanted;p.CameraMinZoomDistance=wanted end
            -- The weapon controller remains untouched. Reveal only this client's world avatar in third person.
            for _,ob in parts do if ob.Parent then
                if altered[ob]==nil then altered[ob]=ob.LocalTransparencyModifier end
                ob.LocalTransparencyModifier=0
            end end
        end
        local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
        local viewport=hud and hud:FindFirstChild("ViewmodelViewport")
        if viewport then viewport.Visible=not third end
    end)
    connect(p:GetAttributeChangedSignal("InLobby"),function() refresh();camera() end)
    connect(p:GetAttributeChangedSignal("QueuedQueueId"),refresh)
    connect(p:GetAttributeChangedSignal("CutsceneActive"),refresh)
    connect(p.CharacterAdded,hookCharacter)
    local world=workspace:WaitForChild("SurvivorLobby")
    local elapsed=0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;if elapsed<.1 then return end;elapsed=0
        for _,descriptor in C.Queues do
            local pad=world.Queues[descriptor.Id]
            local count=pad:GetAttribute("QueueCount") or 0
            local deadline=pad:GetAttribute("DepartureAt") or 0
            local remaining=deadline>0 and math.max(0,math.ceil(deadline-workspace:GetServerTimeNow())) or C.Countdown
            local label=pad.LabelAnchor.QueueLabel
            label.Count.Text=count.."/"..descriptor.Size
            label.Timer.Text=remaining.." (sec)"
            if p:GetAttribute("QueuedQueueId")==descriptor.Id then
                queueTitle.Text=string.upper(descriptor.Mode).." "..descriptor.Slot.."  •  "..count.."/"..descriptor.Size
                queueDetail.Text=(p:GetAttribute("LobbyNotice")or "")~="" and p:GetAttribute("LobbyNotice")or deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or "Step into a circle. The players inside leave together."
            end
        end
    end)
    bridge=new("BindableFunction",{Name="LobbyPresentationControl"},p:WaitForChild("PlayerScripts"))
    bridge.OnInvoke=function(action,value) if action=="ThirdPerson" then M.SetThirdPerson(value) end return M.GetStats() end
    refresh()
    if p.Character then hookCharacter(p.Character) end
    return M
end
function M.Destroy()
    started=false
    RunService:UnbindFromRenderStep("SurvivorLobbyCursor")
    for _,c in links do c:Disconnect() end;links={}
    if characterLink then characterLink:Disconnect();characterLink=nil end
    for ob,value in altered do if ob.Parent then ob.LocalTransparencyModifier=value end end
    local hud=p.PlayerGui:FindFirstChild("ReferenceWeaponHUD")
    local viewport=hud and hud:FindFirstChild("ViewmodelViewport");if viewport then viewport.Visible=true end
    p.CameraMinZoomDistance=.5;p.CameraMode=original.Mode;p.CameraMaxZoomDistance=original.Max;p.CameraMinZoomDistance=original.Min
    if gui then gui:Destroy() end;if bridge then bridge:Destroy() end
end
return M
]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson]====] ]=[====[-- Claude's third-person combat camera + aim pose.
-- Over-the-shoulder camera, mouse locked in matches, character faces where you look,
-- arms + torso aim at the camera pitch (other players' pitch comes from the server attribute AimPitch).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local aimRemote = package:WaitForChild("AimPitch")
local player = Players.LocalPlayer
local gameSettings = UserSettings():GetService("UserGameSettings")

local SHOULDER = Vector3.new(1.65, 0.30, 0)
local shoulderX = SHOULDER.X
local lastSent, lastSentAt = 0, 0

local function inMatch()
	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen") and not player:GetAttribute("CutsceneActive")
end

local function armed(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool and tool:GetAttribute("ReferenceWeaponId") ~= nil
end

local function cameraPitch()
	local cam = workspace.CurrentCamera
	return cam and math.asin(math.clamp(cam.CFrame.LookVector.Y, -1, 1)) or 0
end

-- camera: runs after the default camera, the gun controller and the lobby script
RunService:BindToRenderStep("ClaudeThirdPerson", Enum.RenderPriority.Last.Value + 2, function(dt)
	local cam = workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not cam or not humanoid or humanoid.Health <= 0 or not head then return end
	local combat = inMatch()
	UserInputService.MouseBehavior = combat and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = not combat
	gameSettings.RotationType = combat and Enum.RotationType.CameraRelative or Enum.RotationType.MovementRelative
	if not combat then return end
	-- shoulder offset, pulled in when a wall is on the right
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, workspace:FindFirstChild("ClaudeAKFx")}
	local right = cam.CFrame.RightVector
	local wall = workspace:Raycast(head.Position, right * (SHOULDER.X + 0.6), params)
	local wanted = wall and math.max(0, (wall.Position - head.Position).Magnitude - 0.7) or SHOULDER.X
	shoulderX += (wanted - shoulderX) * (1 - math.exp(-dt * 14))
	cam.CFrame = cam.CFrame * CFrame.new(shoulderX, SHOULDER.Y, 0)
	-- share pitch with the server (10x a second, only when it changed)
	local pitch = cameraPitch()
	local now = os.clock()
	if now - lastSentAt > 0.1 and math.abs(pitch - lastSent) > math.rad(1) then
		lastSent, lastSentAt = pitch, now
		aimRemote:FireServer(pitch)
	end
end)

-- Aim and movement now share GameplayPresentation.CharacterPose (bounded pose-only integration).
-- Camera, mouse lock and AimPitch network protocol above remain unchanged.
]====],
[ [====[ReplicatedStorage.ReferenceWeapons.Controller]====] ]=[====[-- Client-only presentation. Damage/hit authority remains outside this controller.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local ContextActionService = game:GetService('ContextActionService')
local StarterGui = game:GetService('StarterGui')
local Config = require(script.Parent.WeaponConfig)
local Controller = {}
-- Claude's AK hook: guns with CustomFx skip the stock effects and fire this signal instead.
local shotSignal = Instance.new('BindableEvent')
Controller.Shot = shotSignal.Event
local player = Players.LocalPlayer
local package = script.Parent
local camera
local started = false
local activeTool, spec, model, hud, nameText, ammoText, statusText
local parts, arms, connections = {}, {}, {}
local hooked = setmetatable({}, {__mode = 'k'})
local ammo = setmetatable({}, {__mode = 'k'})
local hidden = setmetatable({}, {__mode = 'k'})
local trigger, aiming, sprinting = false, false, false
local reloadStart, inspectStart, equipStart = nil, nil, 0
local lastShot, shotAt = -100, -100
local recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
local yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
local elapsed, crossBloom, generation = 0, 0, 0
local crossLines, casings, characterConnections = {}, {}, {}
local baseFov = 72
local controlBridge
local viewScene, viewCamera, testing = nil, nil, false
local skin = Color3.fromRGB(222, 172, 116)
local renderName = 'ReferenceFPS_Viewmodel'
local identity = CFrame.identity

local function smooth(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
local function mix(a, b, t) return a:Lerp(b, smooth(t)) end
local function bump(t, startTime, peakTime, endTime)
    if t < startTime or t > endTime then return 0 end
    if t <= peakTime then return smooth((t - startTime) / (peakTime - startTime)) end
    return 1 - smooth((t - peakTime) / (endTime - peakTime))
end
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function part(name, size, color, parent)
    local p = Instance.new('Part')
    p.Name, p.Size, p.Color = name, size, color
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.CastShadow, p.Material = false, Enum.Material.SmoothPlastic
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function label(name, size, pos, text, parent)
    local l = Instance.new('TextLabel')
    l.Name, l.Size, l.Position = name, size, pos
    l.BackgroundTransparency = 1
    l.TextColor3, l.Font, l.TextSize = Color3.fromRGB(235, 240, 245), Enum.Font.GothamMedium, 18
    l.TextStrokeTransparency = .65
    l.Text, l.TextXAlignment = text, Enum.TextXAlignment.Right
    l.Parent = parent
    return l
end
local function createHUD()
    local old = player.PlayerGui:FindFirstChild('ReferenceWeaponHUD')
    if old then old:Destroy() end
    hud = Instance.new('ScreenGui')
    hud.Name, hud.ResetOnSpawn, hud.IgnoreGuiInset = 'ReferenceWeaponHUD', false, true
    hud.DisplayOrder = 8
    hud.Parent = player:WaitForChild('PlayerGui')
    -- A transparent live 3D viewmodel pass keeps the Blender colors legible at night.
    local viewport = Instance.new('ViewportFrame')
    viewport.Name, viewport.Size, viewport.BackgroundTransparency = 'ViewmodelViewport', UDim2.fromScale(1, 1), 1
    viewport.BorderSizePixel = 0
    viewport.Ambient, viewport.LightColor = Color3.fromRGB(135, 135, 140), Color3.fromRGB(240, 235, 225)
    viewport.LightDirection = Vector3.new(-1, -1.5, -1)
    viewport.Parent = hud
    viewScene = Instance.new('WorldModel'); viewScene.Name, viewScene.Parent = 'WorldModel', viewport
    viewCamera = Instance.new('Camera'); viewCamera.Name, viewCamera.Parent = 'ViewmodelCamera', viewport
    viewport.CurrentCamera = viewCamera
    nameText = label('WeaponName', UDim2.fromOffset(300, 25), UDim2.new(1, -330, 1, -122), '', hud)
    nameText.TextSize = 15
    ammoText = label('Ammo', UDim2.fromOffset(250, 45), UDim2.new(1, -280, 1, -96), '', hud)
    ammoText.Font, ammoText.TextSize = Enum.Font.GothamBold, 32
    statusText = label('Status', UDim2.fromOffset(330, 25), UDim2.new(1, -360, 1, -49), '', hud)
    statusText.TextSize = 12
    statusText.TextColor3 = Color3.fromRGB(167, 184, 199)
    local center = Instance.new('Frame')
    center.Name, center.Size, center.Position = 'Reticle', UDim2.fromOffset(1, 1), UDim2.fromScale(.5, .5)
    center.BackgroundTransparency = 1
    center.Parent = hud
    local dot = Instance.new('Frame')
    dot.Name, dot.Size, dot.AnchorPoint = 'CenterDot', UDim2.fromOffset(3, 3), Vector2.new(.5, .5)
    dot.BorderSizePixel, dot.BackgroundColor3 = 0, Color3.fromRGB(255, 199, 94)
    dot.Parent = center
    local corner = Instance.new('UICorner'); corner.CornerRadius = UDim.new(1, 0); corner.Parent = dot
    for i, dir in ipairs({Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)}) do
        local f = Instance.new('Frame')
        f.Name, f.AnchorPoint, f.BorderSizePixel = 'Line' .. i, Vector2.new(.5, .5), 0
        f.Size = i % 2 == 0 and UDim2.fromOffset(7, 2) or UDim2.fromOffset(2, 7)
        f.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
        f.Parent = center
        local stroke = Instance.new('UIStroke'); stroke.Color = Color3.new(0, 0, 0); stroke.Transparency = .45; stroke.Parent = f
        table.insert(crossLines, {Frame = f, Direction = dir, Stroke = stroke})
    end
    if ReplicatedStorage:FindFirstChild('GameplayPresentation') then
        nameText.Visible=false;ammoText.Visible=false;statusText.Visible=false;center.Visible=false
    end
    if UserInputService.TouchEnabled then
        for i, action in ipairs({'FIRE', 'AIM', 'RELOAD'}) do
            local button = Instance.new('TextButton')
            button.Name, button.Text = action, action
            button.Size, button.Position = UDim2.fromOffset(78, 45), UDim2.new(1, -90, .50, (i - 1) * 53)
            button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(30, 40, 50), Color3.new(1, 1, 1)
            button.BackgroundTransparency = .25
            if action=='FIRE'then button.Text='FIRE';button.Size=UDim2.fromOffset(74,74);button.Position=UDim2.new(1,-102,1,-190);local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=button;local outline=Instance.new('UIStroke');outline.Color=Color3.new(1,1,1);outline.Thickness=2;outline.Parent=button end
            if action=='AIM'then button.Position=UDim2.new(1,-190,1,-135)elseif action=='RELOAD'then button.Position=UDim2.new(1,-102,1,-100)end
            button.Parent = hud
            connect(button.Activated, function()
                if action == 'FIRE' then Controller.Fire() elseif action == 'AIM' then Controller.SetAim(not aiming) else Controller.Reload() end
            end)
        end
    end
end
local function updateHUD()
    local function publish(key,value)if player:GetAttribute(key)~=value then player:SetAttribute(key,value)end end
    local current=activeTool and ammo[activeTool]
    publish('FPSWeaponId',spec and spec.Id or '')
    publish('FPSAmmo',current and current.Current or nil)
    publish('FPSReserve',current and current.Reserve or nil)
    publish('FPSReloading',reloadStart~=nil)
    publish('FPSInspecting',inspectStart~=nil)
    local a = activeTool and ammo[activeTool]
    if a and spec then
        nameText.Text = string.upper(spec.Name)
        ammoText.Text = string.format('%02d  /  %03d', a.Current, a.Reserve)
        statusText.Text = reloadStart and 'RELOADING' or (inspectStart and 'INSPECTING' or 'R  RELOAD    RMB  AIM    F  INSPECT')
    else
        nameText.Text, ammoText.Text, statusText.Text = '', '', ''
    end
end
local function clear()
    generation += 1
    if camera then camera.CFrame *= CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() end
    if model then model:Destroy() end
    model, activeTool, spec = nil, nil, nil
    parts, arms = {}, {}
    trigger, aiming, reloadStart, inspectStart = false, false, nil, nil
    recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
    yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
    if camera then camera.FieldOfView = baseFov end
    updateHUD()
end
local function armParts(side)
    local result = {}
    local handScale = spec and spec.Pistol and .82 or 1
    result.Upper = part(side .. 'UpperArm', Vector3.new(.39, 1, .40), skin, model)
    result.Lower = part(side .. 'Forearm', Vector3.new(.36, 1, .38), skin, model)
    result.Palm = part(side .. 'Hand', Vector3.new(.34, .43, .37) * handScale, skin, model)
    result.Cuff = part(side .. 'Sleeve', Vector3.new(.42, .35, .44), (player:GetAttribute('EquippedSleeveColor') or Color3.fromRGB(31, 38, 46)), model)
    result.Fingers = {}
    for i = 1, 4 do
        result.Fingers[i] = part(side .. 'Finger' .. i, Vector3.new(.105, .12, .28) * handScale, skin, model)
    end
    result.Thumb = part(side .. 'Thumb', Vector3.new(.15, .23, .20) * handScale, skin, model)
    return result
end
local function segment(ob, a, b, width)
    local length = (b - a).Magnitude
    ob.Size = Vector3.new(width, math.max(.02, length), width * 1.06)
    ob.CFrame = CFrame.lookAt((a + b) * .5, b) * CFrame.Angles(math.pi * .5, 0, 0)
end
local function solveArm(limb, shoulder, handFrame, pole, side)
    local target = handFrame.Position
    local delta = target - shoulder
    local distance = math.max(delta.Magnitude, .001)
    local direction = delta / distance
    local upper, lower = 1.22, 1.26
    local d = math.clamp(distance, .12, upper + lower - .005)
    local adjacent = (upper * upper - lower * lower + d * d) / (2 * d)
    local height = math.sqrt(math.max(0, upper * upper - adjacent * adjacent))
    local bend = pole - shoulder
    bend = bend - direction * bend:Dot(direction)
    if bend.Magnitude < .01 then bend = Vector3.yAxis:Cross(direction) end
    local elbow = shoulder + direction * adjacent + bend.Unit * height
    segment(limb.Upper, shoulder, elbow, .39)
    segment(limb.Lower, elbow, target, .36)
    limb.Cuff.CFrame = CFrame.lookAt(shoulder:Lerp(elbow, .22), elbow) * CFrame.Angles(math.pi / 2, 0, 0)
    limb.Palm.CFrame = handFrame
    local handScale = spec and spec.Pistol and .82 or 1
    for i, finger in ipairs(limb.Fingers) do
        finger.CFrame = handFrame * CFrame.new(Vector3.new((i - 2.5) * .075, -.03, -.18) * handScale) * CFrame.Angles(-.40, 0, 0)
    end
    limb.Thumb.CFrame = handFrame * CFrame.new(Vector3.new(side * .19, .04, -.07) * handScale) * CFrame.Angles(0, 0, side * .48)
end
local function equip(tool)
    if activeTool == tool then return end
    clear()
    spec = Config.Guns[tool:GetAttribute('ReferenceWeaponId')]
    if not spec then return end
    local template = package.Viewmodels:FindFirstChild(spec.Id)
    if not template then warn('Missing imported weapon template ' .. spec.Id); return end
    activeTool = tool
    if not ammo[tool] then ammo[tool] = {Current = spec.MagazineSize, Reserve = spec.Reserve} end
    camera = workspace.CurrentCamera
    model = template:Clone()
    model.Name = 'ReferenceFPS_Active'
    model.Parent = viewScene
    local menuPackage = ReplicatedStorage:FindFirstChild('MainMenu')
    if menuPackage and menuPackage:FindFirstChild('Cosmetics') then require(menuPackage.Cosmetics).ApplyWeapon(model, player:GetAttribute('CosmeticWrap') or 'ORIGINAL') end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
            if p ~= model.PrimaryPart then
                table.insert(parts, {Part = p, Rest = p.CFrame, Component = p:GetAttribute('Component') or 'Body'})
            end
        end
    end
    -- Claude's guns with CustomArms carry their own posed hand meshes.
    if not spec.CustomArms then arms.Left, arms.Right = armParts('Left'), armParts('Right') end
    equipStart = os.clock()
    model:SetAttribute('WeaponId', spec.Id)
    model:SetAttribute('Pose', 'Equip')
    updateHUD()
end
local function effectPart(name, size, color, frame)
    local p = part(name, size, color, workspace)
    p.CFrame = frame
    p.Material = Enum.Material.Neon
    return p
end
local function muzzleEffects()
    if not model then return end
    local root = model.PrimaryPart.CFrame
    local muzzle = root * CFrame.new(spec.Muzzle)
    local flash = effectPart('ReferenceMuzzleFlash', Vector3.new(.09, .09, .32), Color3.fromRGB(255, 210, 115), muzzle * CFrame.new(0, 0, -.09))
    flash.Shape = Enum.PartType.Ball
    local light = Instance.new('PointLight'); light.Brightness, light.Range, light.Color = 3, 8, flash.Color; light.Parent = flash
    Debris:AddItem(flash, .045)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, model}
    local origin, direction = camera.CFrame.Position, camera.CFrame.LookVector * 400
    local hit = workspace:Raycast(origin, direction, params)
    local target = hit and hit.Position or origin + direction
    local delta = target - muzzle.Position
    local trace = effectPart('ReferenceTracer', Vector3.new(.015, .015, math.min(delta.Magnitude, 150)), Color3.fromRGB(255, 220, 130), CFrame.lookAt(muzzle.Position, target) * CFrame.new(0, 0, -math.min(delta.Magnitude, 150) / 2))
    trace.Transparency = .3
    Debris:AddItem(trace, .045)
    local casing = part('ReferenceEjectedCasing', Vector3.new(.06, .13, .06), Color3.fromRGB(196, 145, 57), workspace)
    casing.Shape, casing.Material = Enum.PartType.Cylinder, Enum.Material.Metal
    casing.CFrame = root * CFrame.new(spec.Bolt + Vector3.new(.13, 0, 0))
    table.insert(casings, {Part = casing, Frame = casing.CFrame, Age = 0, Velocity = root.RightVector * 4 + Vector3.yAxis * 2.2})
    if #casings > 16 then table.remove(casings, 1).Part:Destroy() end
end
function Controller.Fire()
    if sprinting then player:SetAttribute('MovementFireInterrupt',os.clock());sprinting=false end
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return false end
    if not activeTool or not model or not spec or reloadStart or sprinting then return false end
    local now, a = os.clock(), ammo[activeTool]
    if now - equipStart < .40 or now - lastShot < 60 / spec.RPM then return false end
    if a.Current <= 0 then Controller.Reload(); return false end
    inspectStart = nil
    lastShot, shotAt = now, now
    a.Current -= 1
    recoilVelocity += spec.Kick * 65
    shotCounter += 1
    yawVelocity += math.rad(spec.RecoilYaw or .3) * math.sin(shotCounter * 2.399963) * 28
    crossBloom = math.min(crossBloom + 7, 22)
    if spec.CustomFx then shotSignal:Fire(spec, model, aiming) else muzzleEffects() end
    updateHUD()
    return true
end
function Controller.Trigger(value)
    if value then
        if trigger then return false end
        trigger=true
        return Controller.Fire()
    end
    trigger=false
    return true
end
function Controller.Reload()
    local a = activeTool and ammo[activeTool]
    if not a or not spec or reloadStart or a.Current == spec.MagazineSize or a.Reserve == 0 then return false end
    reloadStart, inspectStart, aiming, trigger = os.clock(), nil, false, false
    updateHUD()
    return true
end
function Controller.Inspect()
    if not activeTool or reloadStart then return false end
    inspectStart, aiming = os.clock(), false
    return true
end
function Controller.SetAim(value)
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then aiming = false; return end
    aiming = value == true and activeTool ~= nil and reloadStart == nil
    if aiming then sprinting, inspectStart = false, nil end
end
function Controller.GetState()
    local a = activeTool and ammo[activeTool]
    return {
        WeaponId = spec and spec.Id, Ammo = a and a.Current, Reserve = a and a.Reserve,
        Aiming = aiming, Reloading = reloadStart ~= nil, Inspecting = inspectStart ~= nil,
        Pose = model and model:GetAttribute('Pose'), FirstPerson = player.CameraMode.Name,
        Meshes = #parts, HasArms = arms.Left ~= nil and arms.Right ~= nil,
        CameraFov = camera and camera.FieldOfView,
        RecoilPitchDegrees = math.deg(lastCameraKick), RecoilYawDegrees = math.deg(lastCameraYaw),
        WeaponKick = recoil,TapOnly=true,TriggerHeld=trigger,
    }
end
local function render(dt)
    dt = math.min(dt, .05)
    elapsed += dt
    camera = workspace.CurrentCamera
    if not camera then return end
    local inMenu = player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen')
    if hud then hud.Enabled = not inMenu end
    if inMenu then trigger=false;aiming=false;player:SetAttribute('FPSAiming',false);return end
    sprinting=player:GetAttribute('MovementState')=='Sprinting'
    if player:GetAttribute('MovementState')=='Sliding' then aiming=false end
    if player:GetAttribute('FPSAiming')~=aiming then player:SetAttribute('FPSAiming',aiming)end
    if player:GetAttribute('FPSReloading')~=(reloadStart~=nil) then player:SetAttribute('FPSReloading',reloadStart~=nil)end
    if player:GetAttribute('FPSInspecting')~=(inspectStart~=nil) then player:SetAttribute('FPSInspecting',inspectStart~=nil)end
    -- Character and world-held weapon remain visible to other players, hidden only here.
    local character = player.Character
    if character then
        for _, ob in ipairs(character:GetDescendants()) do
            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = player:GetAttribute('ThirdPersonView')==false and 1 or 0 end
        end
    end
    for i = #casings, 1, -1 do
        local c = casings[i]; c.Age += dt
        if c.Age > .9 then c.Part:Destroy(); table.remove(casings, i) else
            c.Velocity -= Vector3.yAxis * dt * 18
            c.Frame += c.Velocity * dt
            c.Part.CFrame = c.Frame * CFrame.Angles(c.Age * 9, c.Age * 7, c.Age * 4)
            c.Part.Transparency = math.max(0, (c.Age - .55) / .35)
        end
    end
    if not model or not activeTool or not spec then return end
    if model.Parent ~= viewScene then model.Parent = viewScene end
    local now = os.clock()
    -- Tap-only input: holding a mouse, touch, or trigger never repeats shots.
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local moving = humanoid and humanoid.MoveDirection.Magnitude or 0
    local reloading = reloadStart ~= nil
    local r = reloading and math.clamp((now - reloadStart) / spec.ReloadTime, 0, 1) or 0
    if reloading and r >= 1 then
        local a = ammo[activeTool]
        local count = math.min(spec.MagazineSize - a.Current, a.Reserve)
        a.Current, a.Reserve = a.Current + count, a.Reserve - count
        reloadStart, reloading, r = nil, false, 0
        updateHUD()
    end
    local inspect = inspectStart and (now - inspectStart) / 2.2 or 0
    if inspect >= 1 then inspectStart, inspect = nil, 0; updateHUD() end
    aimAlpha += ((aiming and not reloading and not sprinting and 1 or 0) - aimAlpha) * (1 - math.exp(-dt * 15))
    camera.FieldOfView += ((baseFov + (player:GetAttribute('MovementFovOffset') or 0) * (1-aimAlpha) + (spec.AimFov - baseFov) * aimAlpha) - camera.FieldOfView) * (1 - math.exp(-dt * 18))
    recoilVelocity += (-150 * recoil - 20 * recoilVelocity) * dt
    recoil += recoilVelocity * dt
    yawVelocity += (-150 * yawRecoil - 20 * yawVelocity) * dt
    yawRecoil += yawVelocity * dt
    local kick = math.clamp(recoil * (spec.CameraRecoil or .75) * (1 - .18 * aimAlpha), 0, math.rad(7))
    local yaw = math.clamp(yawRecoil * (1 - .18 * aimAlpha), -math.rad(1.2), math.rad(1.2))
    camera.CFrame = camera.CFrame * CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() * CFrame.Angles(kick, yaw, 0)
    lastCameraKick, lastCameraYaw = kick, yaw
    local aimPosition = Vector3.new(-spec.Aim.X, -spec.Aim.Y, -(spec.SightDistance or .90) - spec.Aim.Z)
    local stance = spec.Hip:Lerp(CFrame.new(aimPosition), aimAlpha)
    local delta = UserInputService:GetMouseDelta()
    local sway = CFrame.Angles(math.clamp(-delta.Y * .00055, -.025, .025), math.clamp(-delta.X * .00055, -.025, .025), 0)
    local bob = CFrame.new(math.sin(elapsed * 8) * .018 * moving, math.cos(elapsed * 16) * .015 * moving, 0)
    local breathe = CFrame.new(0, math.sin(elapsed * 2) * .004, 0)
    local draw = 1 - smooth((now - equipStart) / .45)
    local reloadPose = math.sin(r * math.pi)
    local inspectPose = math.sin(math.pi * math.clamp(inspect, 0, 1))
    local sprintPose=sprinting and moving>.1 and 1 or 0
    if player:GetAttribute('MovementState')=='Sliding' then sprintPose=.7 end
    local visualKick = math.clamp(recoil, 0, .24)
    local pullback = (spec.Pullback or .1) * math.clamp(visualKick / .10, 0, 1.5)
    local action = CFrame.new(-.12 * reloadPose, -.12 * reloadPose - .9 * draw - .2 * sprintPose - .015 * visualKick, .12 * reloadPose + .28 * draw + pullback)
        * CFrame.Angles(-visualKick * 1.05 + .25 * draw - .3 * sprintPose, .09 * reloadPose + .32 * inspectPose + yawRecoil * .45, -.30 * reloadPose - .48 * inspectPose - visualKick * .12)
    local base = camera.CFrame * stance * breathe * bob * sway * action
    viewCamera.CFrame, viewCamera.FieldOfView = camera.CFrame, camera.FieldOfView
    model.PrimaryPart.CFrame = base
    local magDrop = bump(r, .10, .33, .72) * .90
    local boltPull = bump(r, .78, .84, .94) * .20
    local age = now - shotAt
    local fireBolt = age >= 0 and age < .11 and math.sin(age / .11 * math.pi) * .15 or 0
    local pumpPull = spec.Shotgun and bump(age, .10, .24, .48) * .29 or 0
    local motion = {
        Body = identity,
        Magazine = CFrame.new(.03 * magDrop, -magDrop, .08 * magDrop) * CFrame.Angles(0, 0, -.14 * magDrop),
        Bolt = CFrame.new(0, 0, boltPull + fireBolt),
        Trigger = CFrame.new(0, 0, age < .10 and .025 or 0),
        Pump = CFrame.new(0, 0, pumpPull + (spec.Shotgun and bump(r, .78, .87, .97) * .26 or 0)),
    }
    for _, p in ipairs(parts) do p.Part.CFrame = base * (motion[p.Component] or identity) * p.Rest end
    local left = spec.Support
    if spec.Shotgun then
        left += Vector3.new(0, 0, motion.Pump.Position.Z)
        if reloading then
            local insertion = bump(r, .10, .30, .76)
            left = mix(left, Vector3.new(.21, .23, -.21), insertion)
        end
    elseif reloading then
        local mag = motion.Magazine:PointToWorldSpace(spec.Magazine) + Vector3.new(-.12, -.10, 0)
        if r < .20 then left = mix(spec.Support, mag, r / .20)
        elseif r < .73 then left = mag
        elseif r < .85 then left = mix(mag, spec.Bolt + Vector3.new(.1, 0, boltPull), (r - .73) / .12)
        else left = mix(spec.Bolt, spec.Support, (r - .85) / .15) end
    end
    local rightFrame = base * CFrame.new(.02, -.01, 0) * CFrame.Angles(-.27, 0, 0)
    local leftFrame = base * CFrame.new(left) * CFrame.Angles(spec.Pistol and -.27 or .25, 0, spec.Pistol and -.4 or -.9)
    local cam = camera.CFrame
    if arms.Right then
        solveArm(arms.Right, cam:PointToWorldSpace(Vector3.new(.84, -.99, .19)), rightFrame, cam:PointToWorldSpace(Vector3.new(1.4, -1.6, -.3)), 1)
        solveArm(arms.Left, cam:PointToWorldSpace(Vector3.new(-.78, -.99, .19)), leftFrame, cam:PointToWorldSpace(Vector3.new(-.85, -1.7, -.4)), -1)
    end
    model:SetAttribute('Pose', reloading and 'Reload' or (inspectStart and 'Inspect' or (draw > .01 and 'Equip' or (aimAlpha > .8 and 'ADS' or (age < .13 and 'Fire' or 'Idle')))))
    model:SetAttribute('Ammo', ammo[activeTool].Current)
    crossBloom *= math.exp(-dt * 10)
    local gap = 8 + crossBloom + moving * 3
    for _, item in ipairs(crossLines) do
        item.Frame.Position = UDim2.fromOffset(item.Direction.X * gap, item.Direction.Y * gap)
        item.Frame.BackgroundTransparency = aimAlpha * .9
        item.Stroke.Transparency = .45 + aimAlpha * .5
    end
end
local function hookTool(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ReferenceWeaponId') or hooked[tool] then return end
    hooked[tool] = true
    connect(tool.Equipped, function() equip(tool) end)
    connect(tool.Unequipped, function() if activeTool == tool then clear() end end)
    connect(tool.Activated, function() if not testing then Controller.Fire() end end)
    connect(tool.Deactivated, function() trigger = false end)
    if tool.Parent == player.Character then equip(tool) end
end
local function hookCharacter(character)
    clear()
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
    -- Neutral tan bare arms match the supplied first-person reference instead of yellow test-avatar limbs.
    skin = player:GetAttribute('EquippedHandColor') or Color3.fromRGB(222, 172, 116)
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    characterConnections = {character.ChildAdded:Connect(hookTool)}
    for _, child in ipairs(character:GetChildren()) do hookTool(child) end
    task.spawn(function()
        local humanoid = character:WaitForChild('Humanoid', 10)
        local backpack = player:WaitForChild('Backpack', 10)
        if not humanoid or not backpack or character ~= player.Character then return end
        local preferred = Config.Guns[player:GetAttribute('PreferredWeapon') or 'W1'] or Config.Guns.W1
        local ak = backpack:FindFirstChild(preferred.Name) or backpack:WaitForChild(preferred.Name, 8)
        if ak and character == player.Character and humanoid.Health > 0 then humanoid:EquipTool(ak) end
        connect(humanoid.Died, clear)
    end)
end
function Controller.Start()
    if started then return Controller end
    started = true
    camera = workspace.CurrentCamera
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
    UserInputService.MouseIconEnabled = false
    createHUD()
    -- Local-only diagnostics/commands; no RemoteEvents or server damage authority.
    controlBridge = Instance.new('BindableFunction')
    controlBridge.Name = 'ReferenceFPSControl'
    controlBridge.OnInvoke = function(action, value)
        if action == 'TestMode' then
            testing, trigger, sprinting, aiming = value == true, false, false, false
            if testing then
                ContextActionService:BindActionAtPriority('ReferenceFPS_TestKeys', function() return Enum.ContextActionResult.Sink end, false, 4000,
                    Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five)
            else ContextActionService:UnbindAction('ReferenceFPS_TestKeys') end
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not testing)
            return true
        elseif action == 'Fire' then return Controller.Fire()
        elseif action == 'Press' then return Controller.Trigger(true)
        elseif action == 'Release' then return Controller.Trigger(false)
        elseif action == 'Reload' then return Controller.Reload()
        elseif action == 'Inspect' then return Controller.Inspect()
        elseif action == 'Aim' then Controller.SetAim(value); return true end
        return Controller.GetState()
    end
    controlBridge.Parent = player:WaitForChild('PlayerScripts')
    local backpack = player:WaitForChild('Backpack')
    for _, child in ipairs(backpack:GetChildren()) do hookTool(child) end
    connect(backpack.ChildAdded, hookTool)
    connect(player.CharacterAdded, hookCharacter)
    if player.Character then hookCharacter(player.Character) end
    connect(UserInputService.InputBegan, function(input, processed)
        if processed or testing or player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(true)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(true)
        elseif input.KeyCode == Enum.KeyCode.R then Controller.Reload()
        elseif input.KeyCode == Enum.KeyCode.F then Controller.Inspect()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(false)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(false)
        end
    end)
    connect(UserInputService.WindowFocusReleased, function() trigger, aiming, sprinting = false, false, false end)
    ContextActionService:BindActionAtPriority('SurvivalTapFire',function(_,state)if state==Enum.UserInputState.Begin then Controller.Trigger(true)elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then Controller.Trigger(false)end;return Enum.ContextActionResult.Sink end,false,2300,Enum.KeyCode.ButtonR2)
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 2, render)
    return Controller
end
function Controller.Destroy()
    clear()
    RunService:UnbindFromRenderStep(renderName)
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    for ob, transparency in pairs(hidden) do if ob.Parent then ob.LocalTransparencyModifier = transparency end end
    for _, c in ipairs(casings) do c.Part:Destroy() end
    if hud then hud:Destroy() end
    if controlBridge then controlBridge:Destroy(); controlBridge = nil end
    ContextActionService:UnbindAction('ReferenceFPS_TestKeys')
    ContextActionService:UnbindAction('SurvivalTapFire')
    if testing then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end
    testing = false
    UserInputService.MouseIconEnabled = true
    connections, crossLines, casings, hidden = {}, {}, {}, setmetatable({}, {__mode = 'k'})
    hooked = setmetatable({}, {__mode = 'k'})
    started = false
end
return Controller]====],
[ [====[StarterPlayer.StarterPlayerScripts.ClaudeAKClient]====] ]=[====[-- Claude's guns client: firing feel (recoil climb, shake, screen fuzz, smoke, shells, tracers, impacts,
-- dynamic crosshair, hit markers, reload sound). Visuals only. The server decides every hit.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package:WaitForChild("Config"))
local Fx = require(package:WaitForChild("Fx"))
local Controller = require(ReplicatedStorage:WaitForChild("ReferenceWeapons"):WaitForChild("Controller"))

local player = Players.LocalPlayer
local random = Random.new()

local pendingPitch, pendingYaw = 0, 0
local shake, lastShake = 0, CFrame.identity
local heat, lastShotAt, smokeTimer = 0, -10, 0
local fuzz, flash, bloom = 0, 0, 0
local activeModel, activeSpec

-- pre-made shot sounds per weapon so rapid fire overlaps cleanly
local shotSounds, shotIndex = {}, {}
for id, w in Config.Weapons do
	shotSounds[id], shotIndex[id] = {}, 0
	for i = 1, 4 do
		local s = Instance.new("Sound")
		s.Name = "ClaudeShot" .. id .. "_" .. i
		s.SoundId = w.Shot
		s.Volume = w.ShotVolume or 0.7
		s.Parent = SoundService
		shotSounds[id][i] = s
	end
end
local reloadSound = Instance.new("Sound")
reloadSound.Name = "ClaudeReload"
reloadSound.Volume = 0.6
reloadSound.Parent = SoundService

-- screen fuzz: world blurs and pops for a split second, the viewmodel (GUI) stays sharp
local blur = Instance.new("BlurEffect")
blur.Name = "ClaudeGunFuzz"
blur.Size = 0
blur.Parent = Lighting
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ClaudeGunFlash"
grade.Parent = Lighting

local function weaponFor(spec)
	return spec and Config.Weapons[spec.Id]
end

local function muzzleFrame(model, spec)
	local root = model.PrimaryPart.CFrame
	return CFrame.lookAlong((root * CFrame.new(spec.Muzzle)).Position, root.LookVector), root
end

local function spreadDirection(look, degrees)
	local cf = CFrame.lookAlong(Vector3.zero, look)
	local angle = math.rad(degrees) * math.sqrt(random:NextNumber())
	local spin = random:NextNumber(0, math.pi * 2)
	return (cf * CFrame.Angles(0, 0, spin) * CFrame.Angles(angle, 0, 0)).LookVector
end

local function rayParams()
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = {player.Character, Fx.GetFolder()}
	return p
end

-- hit marker + dynamic crosshair
local gui = Instance.new("ScreenGui")
gui.Name = "ClaudeGunHUD"
gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = true, false, 9
gui.Parent = player:WaitForChild("PlayerGui")
local function line(parent, w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(w, h)
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Parent = parent
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(0, 0, 0)
	st.Transparency = 0.5
	st.Parent = f
	return f, st
end
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.Size = UDim2.fromOffset(1, 1)
cross.BackgroundTransparency = 1
cross.Visible = false
cross.Parent = gui
local arms = {}
for i, dir in {Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)} do
	local f, st = line(cross, dir.X ~= 0 and 9 or 2, dir.Y ~= 0 and 9 or 2)
	arms[i] = {Frame = f, Stroke = st, Dir = dir}
end
local dot, dotStroke = line(cross, 2, 2)

local marker = Instance.new("Frame")
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Position = UDim2.fromScale(0.5, 0.5)
marker.Size = UDim2.fromOffset(28, 28)
marker.BackgroundTransparency = 1
marker.Parent = gui
local ticks = {}
for i = 1, 4 do
	local f = Instance.new("Frame")
	local a = math.rad(45 + 90 * i)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(9, 2)
	f.Position = UDim2.new(0.5, math.cos(a) * 9, 0.5, math.sin(a) * 9)
	f.Rotation = 45 + 90 * i
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 1
	f.Parent = marker
	ticks[i] = f
end
local markerTween
local function showHit(headshot, killed)
	local color = killed and Color3.fromRGB(255, 70, 60) or (headshot and Color3.fromRGB(255, 214, 90) or Color3.new(1, 1, 1))
	marker.Size = UDim2.fromOffset(killed and 40 or 28, killed and 40 or 28)
	for _, f in ticks do
		f.BackgroundColor3 = color
		f.BackgroundTransparency = 0
		TweenService:Create(f, TweenInfo.new(killed and 0.45 or 0.22), {BackgroundTransparency = 1}):Play()
	end
	if markerTween then markerTween:Cancel() end
	markerTween = TweenService:Create(marker, TweenInfo.new(0.12), {Size = UDim2.fromOffset(22, 22)})
	markerTween:Play()
end

local function onShot(spec, model, aiming)
	local weapon = weaponFor(spec)
	if not weapon or not model or not model.PrimaryPart then return end
	activeModel, activeSpec = model, spec
	local camera = workspace.CurrentCamera
	local camCF = camera.CFrame
	local third = player:GetAttribute("ThirdPersonView") ~= false
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local worldModel = tool and tool:FindFirstChild("WorldModel")
	local worldRoot = worldModel and worldModel:FindFirstChild("Root")
	-- aim point: from the camera through the crosshair
	local aimDir = spreadDirection(camCF.LookVector, (aiming and weapon.SpreadAim or weapon.SpreadHip) + bloom * 0.04)
	local camHit = workspace:Raycast(camCF.Position, aimDir * Config.Range, rayParams())
	local aimPoint = camHit and camHit.Position or camCF.Position + aimDir * Config.Range
	local origin, muzzle, root
	if third and head and worldRoot then
		-- third person: bullets leave from the head line toward the crosshair, effects at the gun in your hands
		origin = head.Position
		root = worldRoot.CFrame
		local m = worldRoot:FindFirstChild("Muzzle")
		muzzle = CFrame.lookAt(m and m.WorldPosition or root.Position, aimPoint)
	else
		origin = camCF.Position
		muzzle, root = muzzleFrame(model, spec)
	end
	local dir = (aimPoint - origin).Unit

	package.Shoot:FireServer(origin, dir)

	shotIndex[spec.Id] = shotIndex[spec.Id] % 4 + 1
	local snd = shotSounds[spec.Id][shotIndex[spec.Id]]
	snd.PlaybackSpeed = random:NextNumber(0.95, 1.05)
	snd.TimePosition = 0
	snd:Play()

	Fx.Muzzle(muzzle, not third, weapon.FlashScale)
	local pellets = weapon.Pellets or 1
	for i = 1, pellets do
		local d = pellets > 1 and spreadDirection(dir, weapon.PelletSpread or 4) or dir
		local hit = workspace:Raycast(origin, d * Config.Range, rayParams())
		local hitPos = hit and hit.Position or origin + d * Config.Range
		if i <= 4 then Fx.Tracer(muzzle.Position + muzzle.LookVector * 0.3, hitPos) end
		if hit then
			local m2 = hit.Instance:FindFirstAncestorOfClass("Model")
			local isChar = m2 and m2:FindFirstChildOfClass("Humanoid") ~= nil
			Fx.Impact(hit.Position, hit.Normal, hit.Material, hit.Instance.Color, isChar, i == 1)
		end
	end
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local port = root * CFrame.new(weapon.Eject)
	task.delay(0.02, Fx.Shell, port, root.RightVector + root.UpVector * 0.35, hrp and hrp.AssemblyLinearVelocity, weapon.ShellSize)

	local aimScale = aiming and 0.7 or 1
	pendingPitch += math.rad(weapon.ClimbPitch * aimScale * random:NextNumber(0.85, 1.15))
	pendingYaw += math.rad(weapon.ClimbYaw * aimScale * random:NextNumber(-1, 1.25))
	shake = math.min(shake + (aiming and 0.5 or 1) * weapon.Shake, 3)
	fuzz = math.min(fuzz + weapon.Fuzz * (third and 0.5 or 1), 1.6)
	flash = 1
	bloom = math.min(bloom + (spec.Pistol and 9 or 6), 26)
	heat = math.min(heat + 1, 20)
	lastShotAt = os.clock()
end
Controller.Shot:Connect(onShot)

package.HitConfirm.OnClientEvent:Connect(showHit)

-- reload sound, synced to the reload length
player:GetAttributeChangedSignal("FPSReloading"):Connect(function()
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	if player:GetAttribute("FPSReloading") and weapon and weapon.Reload then
		reloadSound.SoundId = weapon.Reload
		reloadSound.PlaybackSpeed = (weapon.ReloadClipLength or weapon.ReloadTime) / weapon.ReloadTime
		reloadSound.TimePosition = 0
		reloadSound:Play()
	else
		reloadSound:Stop()
	end
end)

local MATERIALS = {}
for _, m in Enum.Material:GetEnumItems() do MATERIALS[m.Name] = m end

-- other players' shots: flash at their gun, tracer, impact, 3D sound
package.Replicate.OnClientEvent:Connect(function(shooter, hitPos, normal, materialName, isChar, weaponId)
	local weapon = Config.Weapons[weaponId or "W1"] or Config.Weapons.W1
	local character = shooter and shooter.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local muzzleAttachment = tool and tool:FindFirstChild("Muzzle", true)
	local head = character and character:FindFirstChild("Head")
	local from = muzzleAttachment and muzzleAttachment.WorldPosition or (head and head.Position)
	if not from then return end
	local dir = (hitPos - from)
	if dir.Magnitude < 0.01 then return end
	local cf = CFrame.lookAlong(from, dir.Unit)
	Fx.Muzzle(cf, false, weapon.FlashScale)
	Fx.Tracer(from, hitPos)
	local soundParent = muzzleAttachment and muzzleAttachment.Parent or head
	Fx.Sound(weapon.Shot, soundParent, 0.9, random:NextNumber(0.95, 1.05))
	local color
	local probe = workspace:Raycast(hitPos + normal * 0.3, -normal * 0.6, rayParams())
	if probe then color = probe.Instance.Color end
	Fx.Impact(hitPos, normal, MATERIALS[materialName] or Enum.Material.Concrete, color, isChar, true)
	if tool and tool:FindFirstChild("Handle") then
		local h = tool.Handle.CFrame
		Fx.Shell(CFrame.lookAlong(h.Position, dir.Unit), CFrame.lookAlong(Vector3.zero, dir.Unit).RightVector, Vector3.zero, weapon.ShellSize)
	end
end)

-- blocky Roblox arms on Claude's guns take the player's skin and sleeve colors
local function paintArms()
	local skin = player:GetAttribute("EquippedHandColor")
	local sleeve = player:GetAttribute("EquippedSleeveColor")
	local character = player.Character
	local bodyColors = character and character:FindFirstChildOfClass("BodyColors")
	if not skin and bodyColors then skin = bodyColors.RightArmColor3 end
	for id in Config.Weapons do
		local template = ReplicatedStorage.ReferenceWeapons.Viewmodels:FindFirstChild(id)
		if template then
			for _, p in template:GetChildren() do
				local kind = p:GetAttribute("ArmPart")
				if kind == "Skin" and skin then p.Color = skin end
				if kind == "Sleeve" and sleeve then p.Color = sleeve end
			end
		end
	end
end
paintArms()
player:GetAttributeChangedSignal("EquippedHandColor"):Connect(paintArms)
player:GetAttributeChangedSignal("EquippedSleeveColor"):Connect(paintArms)
player.CharacterAdded:Connect(function() task.wait(1); paintArms() end)

local tapRing=Instance.new("Frame")
tapRing.Name="TapAimCircle";tapRing.AnchorPoint=Vector2.new(.5,.5);tapRing.Position=UDim2.fromScale(.5,.5)
tapRing.Size=UDim2.fromOffset(12,12);tapRing.BackgroundTransparency=1;tapRing.Parent=cross
local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=tapRing
local outline=Instance.new("UIStroke");outline.Color=Color3.fromRGB(240,242,235);outline.Thickness=1.4;outline.Parent=tapRing
local hudMark
RunService:BindToRenderStep("ClaudeGunFeel", Enum.RenderPriority.Camera.Value + 3, function(dt)
	dt = math.min(dt, 0.05)
	local camera = workspace.CurrentCamera
	if not camera then return end
	-- climb: eased in over a few frames, never undone
	local k = 1 - math.exp(-dt * 28)
	local p, y = pendingPitch * k, pendingYaw * k
	pendingPitch -= p
	pendingYaw -= y
	-- shake: random jitter that is undone next frame
	shake *= math.exp(-dt * 16)
	local amp = math.rad(0.18) * shake
	local newShake = CFrame.Angles(random:NextNumber(-amp, amp), random:NextNumber(-amp, amp), random:NextNumber(-amp, amp) * 1.6)
	camera.CFrame = camera.CFrame * lastShake:Inverse() * CFrame.Angles(p, y, 0) * newShake
	lastShake = newShake
	-- fuzz + flash pop
	fuzz *= math.exp(-dt * 11)
	flash *= math.exp(-dt * 32)
	blur.Size = math.clamp(fuzz * 3.2, 0, 5)
	grade.Brightness = 0.06 * flash
	grade.Contrast = 0.08 * flash
	grade.Saturation = -0.12 * math.min(fuzz, 1)
	-- barrel smoke after bursts
	local now = os.clock()
	if now - lastShotAt > 0.15 then heat = math.max(0, heat - dt * 6) end
	smokeTimer -= dt
	if heat > 4 and now - lastShotAt > 0.1 and smokeTimer <= 0 then
		smokeTimer = 0.07
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		local wm = tool and tool:FindFirstChild("WorldModel")
		local m = wm and wm:FindFirstChild("Muzzle", true)
		if player:GetAttribute("ThirdPersonView") ~= false and m then
			Fx.BarrelSmoke(m.WorldCFrame, math.clamp(heat / 15, 0.2, 1))
		elseif activeModel and activeModel.Parent and activeModel.PrimaryPart then
			Fx.BarrelSmoke(muzzleFrame(activeModel, activeSpec), math.clamp(heat / 15, 0.2, 1))
		end
	end
	-- dynamic crosshair: opens with shots, movement and jumping, fades when aiming
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	local show = weapon ~= nil and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
	cross.Visible = show
	hudMark = hudMark and hudMark.Parent and hudMark or player.PlayerGui:FindFirstChild("AimMark", true)
	if hudMark and hudMark ~= cross then hudMark.Visible = not show end
	if show then
		bloom *= math.exp(-dt * 7)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local speed = root and (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude or 0
		local air = humanoid and humanoid.FloorMaterial == Enum.Material.Air and 10 or 0
		local aim = player:GetAttribute("FPSAiming") and 1 or 0
		local gap = 6 + bloom + math.min(speed, 24) * 0.45 + air
		for _, a in arms do
			a.Frame.Position = UDim2.fromOffset(a.Dir.X * (gap + 4.5), a.Dir.Y * (gap + 4.5))
			a.Frame.Visible=false
            a.Frame.BackgroundTransparency = aim * 0.95
			a.Stroke.Transparency = 0.5 + aim * 0.5
		end
		local radius=aim==1 and 11 or 13+math.min(bloom,9)+math.min(speed,24)*.16
        tapRing.Size=UDim2.fromOffset(radius,radius)
        dot.BackgroundTransparency = 0
		dotStroke.Transparency = 0.5 + aim * 0.5
	end
end)
]====],
[ [====[ServerScriptService.ClaudeAKServer.Logic]====] ]=[====[-- Server authority for Claude's guns: validates every shot, raycasts, applies damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package.Config)

local Logic = {}
local state = {}
local BODY = {Head = "Head", UpperTorso = "Body", LowerTorso = "Body", Torso = "Body", HumanoidRootPart = "Body"}

local function finiteVector(v)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 1e6 and math.abs(v.Y) < 1e6 and math.abs(v.Z) < 1e6
end

local function equippedWeapon(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	local id = tool and tool:GetAttribute("ReferenceWeaponId")
	return id and Config.Weapons[id], id
end

local function sameTeam(a, b)
	return a.Team ~= nil and a.Team == b.Team and not a.Neutral
end

local random = Random.new()

-- one ray: skips invisible non-solid parts, returns the hit and the humanoid/zone if it hit a character
local function castRay(character, origin, direction)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {character}
	local fx = workspace:FindFirstChild("ClaudeAKFx")
	if fx then table.insert(ignore, fx) end
	params.FilterDescendantsInstances = ignore
	local result
	local from = origin
	local remaining = Config.Range
	for _ = 1, 6 do
		result = workspace:Raycast(from, direction * remaining, params)
		if not result then break end
		local inst = result.Instance
		local m = inst:FindFirstAncestorOfClass("Model")
		if (m and m:FindFirstChildOfClass("Humanoid")) or inst.CanCollide or inst.Transparency < 0.9 then break end
		table.insert(ignore, inst)
		params.FilterDescendantsInstances = ignore
		remaining -= (result.Position - from).Magnitude
		from = result.Position
		result = nil
	end
	if not result then return origin + direction * Config.Range, Vector3.yAxis, "" end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local target = model and model:FindFirstChildOfClass("Humanoid")
	if not target or target.Health <= 0 or model == character then
		return result.Position, result.Normal, result.Material.Name
	end
	local partName = result.Instance.Name
	if result.Instance:FindFirstAncestorOfClass("Accessory") then partName = "Head" end
	return result.Position, result.Normal, result.Material.Name, target, BODY[partName] or "Limb", (result.Position - origin).Magnitude
end

local function onShoot(player, origin, direction, ...)
    if select("#",...)~=0 or player:GetAttribute("InLobby") or player:GetAttribute("InMenu") or player:GetAttribute("CutsceneActive")then return end
	if not finiteVector(origin) or not finiteVector(direction) then return end
	if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end
	direction = direction.Unit
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end
	local weapon, weaponId = equippedWeapon(character)
	if not weapon then return end
	-- origin must be near the shooter's head (camera); otherwise use the head
	if (origin - head.Position).Magnitude > 7 then origin = head.Position end
	local now = os.clock()
	state[player] = state[player] or {}
	local s = state[player][weaponId]
	if not s then s = {Last = 0, Mag = weapon.MagazineSize}; state[player][weaponId] = s end
	if s.Mag <= 0 then
		if now - s.Last < weapon.ReloadTime * 0.75 then return end
		s.Mag = weapon.MagazineSize
	end
	if now - s.Last < 60 / weapon.RPM * 0.8 then return end
	s.Last = now
	s.Mag -= 1

	local pellets = weapon.Pellets or 1
	local totals = {}
	for i = 1, pellets do
		local dir = direction
		if pellets > 1 then
			local cf = CFrame.lookAlong(Vector3.zero, direction)
			local a = math.rad(weapon.PelletSpread or 4) * math.sqrt(random:NextNumber())
			dir = (cf * CFrame.Angles(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.Angles(a, 0, 0)).LookVector
		end
		local hitPos, normal, material, target, zone, dist = castRay(character, origin, dir)
		if target then
			local victim = Players:GetPlayerFromCharacter(target.Parent)
			if not (victim and sameTeam(player, victim)) then
				local falloff = 1 - math.clamp((dist - weapon.FalloffNear) / (weapon.FalloffFar - weapon.FalloffNear), 0, 1) * (1 - weapon.MinScale)
				local t = totals[target] or {Damage = 0, Head = false}
				t.Damage += weapon.Damage[zone] * falloff
				t.Head = t.Head or zone == "Head"
				totals[target] = t
			end
		end
		if i <= 4 then
			for _, other in Players:GetPlayers() do
				if other ~= player then
					package.Replicate:FireClient(other, player, hitPos, normal, material, target ~= nil, weaponId)
				end
			end
		end
	end
	for target, t in totals do
		if target.Health > 0 then
			local damage = math.floor(t.Damage + 0.5)
			if target.Parent:GetAttribute("SurvivalZombie")then target.Parent:SetAttribute("LastDamageUserId",player.UserId);target.Parent:SetAttribute("LastDamageClock",os.clock())end
			target:TakeDamage(damage)
			package.HitConfirm:FireClient(player, t.Head, target.Health <= 0, damage)
		end
	end
end

-- third-person aim pitch, shared with every client for the arm pose
local lastPitch = {}
local function onAimPitch(player, pitch)
	if typeof(pitch) ~= "number" or pitch ~= pitch then return end
	local now = os.clock()
	if now - (lastPitch[player] or 0) < 0.05 then return end
	lastPitch[player] = now
	player:SetAttribute("AimPitch", math.clamp(pitch, -1.3, 1.3))
end

function Logic.Start()
	package.Shoot.OnServerEvent:Connect(onShoot)
	package.AimPitch.OnServerEvent:Connect(onAimPitch)
	Players.PlayerRemoving:Connect(function(p) state[p] = nil;lastPitch[p]=nil end)
end

return Logic
]====],
[ [====[ServerScriptService.LobbySystem.Service]====] ]=[====[local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local PhysicsService=game:GetService("PhysicsService")
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local Queue=require(script.Parent.Queue)
local Session=require(game.ServerScriptService.SurvivalRun.Service)
local Transport=require(game.ServerScriptService.SurvivalRun.Transport)
local S={}
local states,links={},{}
local queue=Queue.new(C.Queues,C.Countdown)
local queueById={}
for _,descriptor in C.Queues do queueById[descriptor.Id]=descriptor end
local started=false
local world,team,toolRoot
local rejected,launched=0,0
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function charState(p)
    local char=p.Character
    local h=char and char:FindFirstChildOfClass("Humanoid")
    local r=char and char:FindFirstChild("HumanoidRootPart")
    return char,h,r
end
local function inPad(p,mode)
    local s=states[p]
    if not s or s.Phase~="Lobby" then return false end
    local _,h,r=charState(p)
    local pad=world.Queues:FindFirstChild(mode)
    if not h or h.Health<=0 or not r or not pad then return false end
    local point=pad.Zone.CFrame:PointToObjectSpace(r.Position)
    local radius=pad:GetAttribute("Radius") or 7
    return point.X*point.X+point.Z*point.Z<=radius*radius and point.Y>=-2 and point.Y<=10
end
local function region(p)
    for _,m in C.Queues do if inPad(p,m.Id) then return m.Id end end
end
local function setMode(p,id)
    local descriptor=id and queueById[id]
    p:SetAttribute("QueuedQueueId",id or "")
    p:SetAttribute("QueuedMode",descriptor and descriptor.Mode or "")
end
local function haltSlide(p)
    local movement=game.ServerScriptService:FindFirstChild("GameplayMovement")
    local control=movement and movement:FindFirstChild("MovementControl")
    if control then control:Invoke(p,"CancelSlide");control:Invoke(p,"Crouch",false) end
end
local function pivot(p,transform)
    haltSlide(p)
    local char,_,root=charState(p)
    char:PivotTo(transform)
    if root then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
end
local function strip(p,tool)
    local s=states[p]
    if s and s.Phase=="Lobby" and tool:IsA("Tool") then tool.Parent=s.Tools end
end
local function restoreTools(p)
    local s=states[p]
    local backpack=p:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    for _,t in s.Tools:GetChildren() do t.Parent=backpack end
    local char,h=charState(p)
    if char and h then
        local preferred
        for _,t in backpack:GetChildren() do if t:IsA("Tool") and t:GetAttribute("ReferenceWeaponId")==(p:GetAttribute("PreferredWeapon") or "W1") then preferred=t;break end end
        if preferred then h:EquipTool(preferred) end
    end
end
local function phase(p,value)
    local s=states[p];s.Phase=value
    p:SetAttribute("InLobby",value=="Lobby")
    p:SetAttribute("InMenu",value~="Deployed")
    p:SetAttribute("LobbyPhase",value)
    p:SetAttribute("MenuClientOpen",false)
    p.Team=team;p.Neutral=false
    p.RespawnLocation=world.Spawn
end
local function endSurvival(p,s)
    if s.RunStart then s.Best=math.max(s.Best,math.floor(os.clock()-s.RunStart));s.RunStart=nil end
    p:SetAttribute("BestSurvival",s.Best)
end
local function protectLobby(char)
    local force=char:FindFirstChild("LobbyShield")
    if not force then force=Instance.new("ForceField");force.Name="LobbyShield";force.Visible=false;force.Parent=char end
end
function S.Return(p,respawn)
    local s=states[p];if not s then return false end
    endSurvival(p,s)
    if not respawn and s.Phase=="Deployed" and not RunService:IsStudio() and game.PrivateServerId~=""then
        phase(p,"Teleporting")
        local function failed()
            if states[p]==s then phase(p,"Deployed");p:SetAttribute("LobbyNotice","Return teleport failed. Press M to retry.")end
        end
        if Transport.Return(p,failed)then return true end
        failed();return false
    end
    Session.Remove(p)
    queue:Remove(p.UserId);setMode(p,nil)
    s.Blocked=region(p)
    s.Generation+=1
    phase(p,"Lobby")
    p:SetAttribute("CoopPartyId","");p:SetAttribute("CoopPartySize",0);p:SetAttribute("CoopMode","");p:SetAttribute("CoopQueueId","")
    local char,h=charState(p)
    if respawn or not h or h.Health<=0 then
        if s.Busy then return false end
        s.Busy=true
        s.Tools:ClearAllChildren() -- Fresh characters receive a fresh StarterPack; never accumulate duplicates.
        local ok=pcall(function() p:LoadCharacterAsync() end)
        s.Busy=false
        if not ok then p:SetAttribute("LobbyNotice","Spawn retry in progress");task.delay(3,function() if states[p]==s then S.Return(p,true) end end) end
        return ok
    end
    h:UnequipTools()
    for _,t in char:GetChildren() do strip(p,t) end
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then for _,t in backpack:GetChildren() do strip(p,t) end end
    protectLobby(char)
    pivot(p,C.LobbySpawn)
    return true
end
local function startRun(p,party,index,size,mode)
    local s=states[p];if not s then return end
    s.Generation+=1;phase(p,"Intro");setMode(p,nil)
    p:SetAttribute("CoopMode",mode);p:SetAttribute("LobbyNotice","")
    p:SetAttribute("StudioSessionPreview",RunService:IsStudio())
    haltSlide(p)
    Session.Begin(p,party,index,size,function()
        if states[p]==s then phase(p,"Deployed");s.RunStart=os.clock();launched+=1 end
    end)
end
local function failedDeparture(members,notice)
    for _,p in members do
        local s=states[p]
        if s and p.Parent==Players and s.Phase=="Teleporting" then
            phase(p,"Lobby");s.Blocked=p:GetAttribute("CoopQueueId")
            local _,h,r=charState(p);if r then r.Anchored=false;r:SetNetworkOwnershipAuto()end
            if h then h.PlatformStand=false end
            p:SetAttribute("LobbyNotice",notice);setMode(p,nil);pivot(p,C.LobbySpawn)
        end
    end
end
local function deploy(group)
    local members={}
    for _,id in group.Members do
        local p=Players:GetPlayerByUserId(id)
        if p and inPad(p,group.Mode)then table.insert(members,p)end
    end
    local descriptor=queueById[group.Mode]
    if not descriptor or #members<1 or #members>descriptor.Size then return false end
    if RunService:IsStudio()then
        if not Session.CanPreview()then
            for _,p in members do states[p].Blocked=group.Mode;setMode(p,nil);p:SetAttribute("LobbyNotice","A Studio intro preview is already running. Return that player first.")end
            return false
        end
        local party=game.HttpService:GenerateGUID(false)
        for index,p in members do startRun(p,party,index,#members,descriptor.Mode)end
    else
        for _,p in members do
            phase(p,"Teleporting");setMode(p,nil);p:SetAttribute("CoopQueueId",group.Mode)
            haltSlide(p);local _,_,r=charState(p);if r then r.Anchored=true end
        end
        task.spawn(function()Transport.Depart(members,descriptor.Mode,failedDeparture)end)
    end
    return true
end
local function character(p,char)
    local s=states[p];if not s then return end
    s.Generation+=1
    phase(p,"Lobby");setMode(p,nil);queue:Remove(p.UserId)
    task.spawn(function()
        local h=char:WaitForChild("Humanoid",10)
        local root=char:WaitForChild("HumanoidRootPart",10)
        if not h or not root or states[p]~=s or p.Character~=char then return end
        local function child(o)
            if o:IsA("BasePart") then o.CollisionGroup="CoopSurvivors" end
            if o:IsA("Tool") then strip(p,o) end
        end
        for _,o in char:GetDescendants() do child(o) end
        char.DescendantAdded:Connect(child)
        protectLobby(char)
        pivot(p,C.LobbySpawn)
        h.WalkSpeed=14
        h.Died:Connect(function()
            if states[p]~=s or p.Character~=char then return end
            endSurvival(p,s)
            Session.Remove(p)
            queue:Remove(p.UserId);setMode(p,nil)
            phase(p,"Lobby")
            task.delay(2.5,function() if states[p]==s and p.Character==char then S.Return(p,true) end end)
        end)
        if s.Arrival then startRun(p,s.Arrival.PartyId,s.Arrival.Index,s.Arrival.Size,s.Arrival.Mode)end
    end)
end
local function added(p)
    if states[p] then return end
    local arrival=Transport.Validate(p)
    if arrival==false then p:Kick("This private session is only for its queued survivors.");return end
    local tools=Instance.new("Folder");tools.Name=tostring(p.UserId);tools.Parent=toolRoot
    local s={Phase="Lobby",Tools=tools,Best=0,Tokens=4,TokenTime=os.clock(),Generation=0,Links={},Arrival=arrival}
    states[p]=s
    local function link(signal,fn) local c=signal:Connect(fn);table.insert(s.Links,c);return c end
    p:SetAttribute("PreferredWeapon",p:GetAttribute("PreferredWeapon") or "W1")
    p:SetAttribute("BestSurvival",0);setMode(p,nil);phase(p,"Lobby")
    link(p:GetPropertyChangedSignal("Team"),function() if states[p] and p.Team~=team then p.Team=team;p.Neutral=false end end)
    link(p.CharacterAdded,function(char) character(p,char) end)
    local function backpackAdded(backpack)
        if not backpack:IsA("Backpack") or s.Backpack==backpack then return end
        s.Backpack=backpack
        if s.BackpackLink then s.BackpackLink:Disconnect() end
        s.BackpackLink=backpack.ChildAdded:Connect(function(t) strip(p,t) end)
        for _,t in backpack:GetChildren() do strip(p,t) end
    end
    link(p.ChildAdded,backpackAdded)
    local backpack=p:FindFirstChildOfClass("Backpack")
    if backpack then backpackAdded(backpack) end
    if p.Character then character(p,p.Character) else task.spawn(function() S.Return(p,true) end) end
end
function S.Handle(p,action,...)
    local s=states[p]
    if not s or p.Parent~=Players or type(action)~="string" or #action>12 or select("#",...)~=0 then rejected+=1;return false end
    local now=os.clock()
    s.Tokens=math.min(4,s.Tokens+(now-s.TokenTime)*2);s.TokenTime=now
    if s.Tokens<1 then rejected+=1;return false end
    s.Tokens-=1
    if action=="Leave" and s.Phase=="Lobby" then
        s.Blocked=queue.Membership[p.UserId] or region(p)
        queue:Remove(p.UserId);setMode(p,nil)
        return true
    elseif action=="Return" and s.Phase=="Deployed" then return S.Return(p,false) end
    rejected+=1;return false
end
local function scan()
    for p,s in states do
        local _,h,r=charState(p)
        if s.Phase=="Lobby" and h and h.Health>0 and r then
            local mode=region(p)
            if s.Blocked and mode~=s.Blocked then s.Blocked=nil end
            local old=queue.Membership[p.UserId]
            if old and old~=mode then queue:Remove(p.UserId);setMode(p,nil) end
            if mode and s.Blocked~=mode then
                if queue:Add(p.UserId,mode) then setMode(p,mode) end
            end
            local offset=r.Position-C.LobbyCenter
            if math.abs(offset.X)>110 or math.abs(offset.Z)>83 or r.Position.Y<-10 then pivot(p,C.LobbySpawn) end
        end
    end
    for _,group in queue:Step(workspace:GetServerTimeNow(),function(id,mode)
        local p=Players:GetPlayerByUserId(id);return p and inPad(p,mode) or false
    end) do deploy(group) end
    for _,m in C.Queues do
        local q=queue.Queues[m.Id]
        local pad=world.Queues[m.Id]
        pad:SetAttribute("QueueCount",#q.Members);pad:SetAttribute("DepartureAt",q.Deadline or 0)
    end
end
local function board()
    local rows={}
    for p,s in states do
        local kills=p:GetAttribute("ZombieKills")
        local stats=p:FindFirstChild("leaderstats")
        local stat=stats and stats:FindFirstChild("ZombieKills")
        if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then kills=stat.Value end
        if type(kills)~="number" or kills~=kills or math.abs(kills)>1e9 then kills=0 end
        local best=math.max(s.Best,s.RunStart and math.floor(os.clock()-s.RunStart) or 0)
        p:SetAttribute("BestSurvival",best)
        table.insert(rows,{Name=p.DisplayName,Kills=math.max(0,math.floor(kills)),Best=best,UserId=p.UserId})
    end
    table.sort(rows,function(a,b) if a.Kills~=b.Kills then return a.Kills>b.Kills end if a.Best~=b.Best then return a.Best>b.Best end return a.UserId<b.UserId end)
    local surface=world.Leaderboard.Board.SurfaceGui
    for i=1,10 do
        local row=surface.Rows:FindFirstChild("Row"..i);local data=rows[i]
        row.NameCell.Text=data and string.format("%02d   %s",i,data.Name) or string.format("%02d   —",i)
        row.Kills.Text=data and tostring(data.Kills) or "—"
        row.Best.Text=data and string.format("%02d:%02d",math.floor(data.Best/60),data.Best%60) or "—"
    end
    world:SetAttribute("LobbyPlayers",#rows)
end
function S.GetState(p)
    local s=p and states[p]
    return {Phase=s and s.Phase,Queued=s and queue.Membership[p.UserId],Queues=queue:Snapshot(),Rejected=rejected,Deployed=launched,LastSpawn=s and s.LastSpawn and tostring(s.LastSpawn),Players=world and world:GetAttribute("LobbyPlayers")}
end
function S.Start()
    if started then return end
    started=true
    Session.Start();Transport.Start()
    world=assert(workspace:FindFirstChild("SurvivorLobby"))
    team=assert(game.Teams:FindFirstChild(C.TeamName))
    pcall(function() PhysicsService:RegisterCollisionGroup("CoopSurvivors") end)
    PhysicsService:CollisionGroupSetCollidable("CoopSurvivors","CoopSurvivors",false)
    Players.CharacterAutoLoads=false
    toolRoot=Instance.new("Folder");toolRoot.Name="RuntimeTools";toolRoot.Parent=script.Parent
    for _,p in Players:GetPlayers() do added(p) end
    connect(Players.PlayerAdded,added)
    connect(Players.PlayerRemoving,function(p)
        queue:Remove(p.UserId)
        local s=states[p];if s then
            for _,c in s.Links do c:Disconnect() end
            if s.BackpackLink then s.BackpackLink:Disconnect() end
            s.Tools:Destroy()
        end
        states[p]=nil
    end)
    connect(package.Request.OnServerEvent,S.Handle)
    local elapsed,boardTime=0,0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;boardTime+=dt
        if elapsed>=C.ScanInterval then elapsed=0;scan() end
        if boardTime>=1 then boardTime=0;board() end
    end)
    local control=Instance.new("BindableFunction");control.Name="Control";control.Parent=script.Parent
    control.OnInvoke=function(p,action) if action=="State" then return S.GetState(p) elseif action=="Return" then return S.Return(p,false) end end
end
return S
]====],
[ [====[ServerScriptService.SurvivalRun.Service]====] ]=[====[local Players=game:GetService("Players")
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

]====],
[ [====[ReplicatedStorage.SurvivalRun.Config]====] ]=[====[return {
    Protocol=1, IntroDuration=12, StartingWeapon="W3",
    CrashSound="rbxassetid://9120828793", GrowlSound="rbxassetid://127809799844346",
    HouseCenters={Vector3.new(2000,0,0),Vector3.new(2034,0,0),Vector3.new(2068,0,0),Vector3.new(2102,0,0)},
    Porches={Vector3.new(-108,4,25),Vector3.new(-45,4,25),Vector3.new(21,4,25),Vector3.new(87,4,25)},
    ZombieHealth=90,ZombieSpeed=8.5,ZombieDamage=12,ZombieAttackRange=4.2,
    ZombieLimit=12,RegistryTTL=900,RegistryName="SurvivorRunSessionsV1",
}

]====],
[ [====[ReplicatedStorage.SurvivalRun.Client]====] ]=[====[local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local p=Players.LocalPlayer
local C=require(script.Parent.Config)
local M={}
local started=false
local gui,bars,subtitle,fade,objective,loading
local CAS=game:GetService("ContextActionService")
local controls
local introLast=false
local mobRecords={}
local function new(class,props,parent)local o=Instance.new(class);for k,v in props do o[k]=v end;o.Parent=parent;return o end
local function introControls(value)
    if not controls then local module=p.PlayerScripts:FindFirstChild("PlayerModule");if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then controls=result end end end
    if value then CAS:BindActionAtPriority("SurvivalIntroInput",function()return Enum.ContextActionResult.Sink end,false,5000,table.unpack(Enum.PlayerActions:GetEnumItems()))else CAS:UnbindAction("SurvivalIntroInput")end
    if controls then if value then controls:Disable()else controls:Enable()end end
end
local function beginIntro()
    introControls(true)
    pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)
    local porch=p:GetAttribute("PorchPosition")
    if porch then task.spawn(function()pcall(function()p:RequestStreamAroundAsync(porch,5)end)end)end
    local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
    local animator=h and h:FindFirstChildOfClass("Animator")
    if animator then for _,track in animator:GetPlayingAnimationTracks()do track:Stop(.1)end end
end
local function animateMobs()
    local world=workspace:FindFirstChild("SurvivalRun");local folder=world and world:FindFirstChild("Infected")
    if not folder then return end
    local now=workspace:GetServerTimeNow()
    for _,z in folder:GetChildren()do
        if not z:GetAttribute("SurvivalZombie")then continue end
        local rec=mobRecords[z]
        if not rec or now>(rec.ScanAt or 0)then
            rec=rec or {};rec.ScanAt=now+.5;for _,j in z:GetDescendants()do if j:IsA("Motor6D")or j:IsA("AnimationConstraint")then rec[j.Name]=j end end;mobRecords[z]=rec
        end
        local action=z:GetAttribute("ZombieAction")or "Idle"
        local root=z:FindFirstChild("HumanoidRootPart")
        local speed=root and (root.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude or 0
        local walk=action=="Walk" and math.clamp(speed/8,0,1)or 0
        local phase=now*5.2
        local attack=math.clamp((now-(z:GetAttribute("ZombieAttackAt")or -1e9))/1.1,0,1)
        local strike=attack<1 and math.sin(attack*math.pi)or 0
        local hitAge=now-(z:GetAttribute("ZombieHitAt")or -1e9)
        local flinch=hitAge<.3 and (1-hitAge/.3)or 0
        local function pose(name,x,y,roll,translation)
            local j=rec[name];if j and j.Parent then j.Transform=CFrame.new(translation or Vector3.zero)*CFrame.Angles(math.rad(x),math.rad(y or 0),math.rad(roll or 0))end
        end
        if action=="Dead"then
            local age=math.clamp((now-(z:GetAttribute("ZombieDeathAt")or now))/.65,0,1)
            pose("Root",-85*age,0,12*age,Vector3.new(0,-1.4*age,0))
            pose("RightShoulder",45*age);pose("LeftShoulder",70*age)
        else
            pose("Waist",11+walk*3+flinch*20,math.sin(phase*.5)*3,math.sin(phase)*2*walk)
            pose("Neck",-5-flinch*12,math.sin(phase*.35)*7,math.sin(phase*.65)*4)
            pose("RightHip",math.sin(phase)*24*walk);pose("LeftHip",-math.sin(phase)*24*walk)
            pose("RightKnee",math.max(0,-math.sin(phase))*28*walk);pose("LeftKnee",math.max(0,math.sin(phase))*28*walk)
            pose("RightShoulder",52+math.sin(phase)*9*walk+strike*65,0,8)
            pose("LeftShoulder",48-math.sin(phase)*11*walk+strike*55,0,-12)
            pose("RightElbow",-14-strike*18);pose("LeftElbow",-25-strike*12)
            pose("Root",0,0,math.sin(phase)*2*walk,Vector3.new(0,math.abs(math.sin(phase))*.035*walk,0))
        end
    end
    for z in mobRecords do if not z.Parent then mobRecords[z]=nil end end
end
function M.Start()
    if started then return M end;started=true
    gui=new("ScreenGui",{Name="SurvivalPresentation",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=60},p:WaitForChild("PlayerGui"))
    bars=new("Frame",{Name="Cinema",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
    new("Frame",{Name="TopBar",Size=UDim2.new(1,0,.12,0),BackgroundColor3=Color3.new(),BorderSizePixel=0},bars)
    new("Frame",{Name="BottomBar",Size=UDim2.new(1,0,.15,0),Position=UDim2.fromScale(0,.85),BackgroundColor3=Color3.new(),BorderSizePixel=0},bars)
    subtitle=new("TextLabel",{Name="Subtitle",Size=UDim2.fromScale(.9,.1),Position=UDim2.fromScale(.05,.87),BackgroundTransparency=1,TextColor3=Color3.fromRGB(239,235,220),Font=Enum.Font.GothamMedium,TextSize=19,TextWrapped=true},bars)
    fade=new("Frame",{Name="Fade",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),BorderSizePixel=0,Visible=false,ZIndex=5},gui)
    objective=new("TextLabel",{Name="Objective",AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.04),Size=UDim2.new(.80,0,0,56),BackgroundColor3=Color3.fromRGB(22,28,27),BackgroundTransparency=.12,TextColor3=Color3.fromRGB(222,229,218),Font=Enum.Font.GothamMedium,TextSize=14,TextWrapped=true,Visible=false},gui)
    new("UICorner",{CornerRadius=UDim.new(0,10)},objective)
    loading=new("TextLabel",{Name="LoadingSession",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(13,18,18),TextColor3=Color3.fromRGB(232,237,228),Font=Enum.Font.GothamBold,TextSize=24,Text="Opening your private session...",Visible=false},gui)
    RunService.PreSimulation:Connect(animateMobs)
    RunService:BindToRenderStep("SurvivalCinematic",Enum.RenderPriority.Last.Value+30,function()
        local intro=p:GetAttribute("CutsceneActive")==true
        if intro~=introLast then
            introLast=intro
            if intro then beginIntro()else
                introControls(false)
                local camera=workspace.CurrentCamera;local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                if camera and h then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=h end
            end
        end
        bars.Visible=intro;fade.Visible=intro
        loading.Visible=p:GetAttribute("LobbyPhase")=="Teleporting"
        local active=p:GetAttribute("SurvivalActive")and not intro and not p:GetAttribute("InLobby")
        objective.Visible=active==true
        if active then objective.Text=(p:GetAttribute("StudioSessionPreview")and "STUDIO PREVIEW  •  "or "")..((p:GetAttribute("LobbyNotice")or "")~="" and p:GetAttribute("LobbyNotice")or p:GetAttribute("SurvivalObjective")or "Survive together.")end
        if not intro then return end
        local center=p:GetAttribute("HouseCenter");local porch=p:GetAttribute("PorchPosition")
        local c=p.Character;local head=c and c:FindFirstChild("Head")
        local camera=workspace.CurrentCamera
        if not center or not porch or not head or not camera then return end
        local t=workspace:GetServerTimeNow()-(p:GetAttribute("IntroStartedAt")or workspace:GetServerTimeNow())
        camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=62
        UIS.MouseBehavior=Enum.MouseBehavior.Default;UIS.MouseIconEnabled=false
        fade.BackgroundTransparency=math.clamp(t/1.1,0,1)
        local position,target
        if t<2.4 then
            position=center+Vector3.new(3,7.4,6-t*.55);target=center+Vector3.new(-2,3.7,1)
            subtitle.Text="..."
        elseif t<4.2 then
            position=center+Vector3.new(6,7,7);target=head.Position
            subtitle.Text="What was that noise outside?"
        elseif t<7.2 then
            position=head.Position+Vector3.new(3,1.4,6);target=head.Position+Vector3.new(-1,0,-3)
            subtitle.Text="Something is moving in the street..."
        else
            local k=math.clamp((t-7.2)/4,0,1)
            position=porch+Vector3.new(1,4.4,4-k*2);target=porch+Vector3.new(0,-1,-12)
            subtitle.Text=t<10 and "Those are infected. They're everywhere."or "Find your pistol. Get outside and stay together."
        end
        camera.CFrame=CFrame.lookAt(position,target)*CFrame.Angles(0,0,math.sin(t*1.8)*.0015)
        camera.Focus=CFrame.new(target)
    end)
    return M
end
return M

]====],
[ [====[ReplicatedStorage.SurvivalRun.LobbyCamera]====] ]=[====[local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local p=Players.LocalPlayer
local M={}
local yaw,pitch,radius=0,.28,12
local dragging=false
local touch
local stick=Vector2.zero
local started=false
local function lobby()return p:GetAttribute("InLobby")==true and not p:GetAttribute("CutsceneActive")end
function M.Delta(delta)
    if not lobby()then return false end
    yaw-=delta.X*.006;pitch=math.clamp(pitch+delta.Y*.004,-.08,1.05);return true
end
function M.State()return {Yaw=yaw,Pitch=pitch,Radius=radius,Dragging=dragging,Active=lobby()}end
function M.Start()
    if started then return end;started=true
    UIS.InputBegan:Connect(function(input,processed)
        if processed or UIS:GetFocusedTextBox()or not lobby()then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=true
        elseif input.UserInputType==Enum.UserInputType.Touch and input.Position.X>workspace.CurrentCamera.ViewportSize.X*.45 then touch=input end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false end
        if input==touch then touch=nil end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(input.Position.X,-input.Position.Y)end
        if not lobby()then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then M.Delta(input.Delta)
        elseif input==touch then M.Delta(input.Delta)
        elseif input.UserInputType==Enum.UserInputType.MouseWheel then radius=math.clamp(radius-input.Position.Z*1.1,6,18)end
    end)
    UIS.WindowFocusReleased:Connect(function()dragging=false;touch=nil;stick=Vector2.zero end)
    RunService:BindToRenderStep("SurvivorLobbyOrbit",Enum.RenderPriority.Last.Value+12,function(dt)
        if not lobby()then dragging=false;touch=nil;return end
        if stick.Magnitude>.15 then M.Delta(stick*dt*220)end
        local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local head=c and c:FindFirstChild("Head");local cam=workspace.CurrentCamera
        if not h or h.Health<=0 or not head or not cam then return end
        local focus=head.Position+Vector3.new(0,-.3+h.CameraOffset.Y,0)
        local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),math.cos(yaw)*math.cos(pitch))*radius
        local params=RaycastParams.new();params.FilterDescendantsInstances={c};params.RespectCanCollide=true
        local hit=workspace:Spherecast(focus,.3,offset,params)
        local wanted=hit and focus+offset.Unit*math.max(1,(hit.Position-focus).Magnitude-.4)or focus+offset
        cam.CameraType=Enum.CameraType.Scriptable;cam.CFrame=CFrame.lookAt(wanted,focus);cam.Focus=CFrame.new(focus)
        UIS.MouseBehavior=dragging and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
        UIS.MouseIconEnabled=not dragging
    end)
    local bridge=Instance.new("BindableFunction");bridge.Name="LobbyCameraControl";bridge.OnInvoke=function(action,value)if action=="Delta"then M.Delta(value)end;return M.State()end;bridge.Parent=p.PlayerScripts
end
return M

]====],
[ [====[ServerScriptService.SurvivalRun.Transport]====] ]=[====[local Players=game:GetService("Players")
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

]====],
[ [====[ServerScriptService.SurvivalRun.World]====] ]=[====[local SS=game:GetService("ServerStorage")
local W={}
local function part(parent,name,size,cf,color,material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function W.House(parent,index,userId,center)
    local m=Instance.new("Model");m.Name="House_"..userId;m:SetAttribute("OwnerUserId",userId);m:SetAttribute("HouseIndex",index)
    m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
    local cf=CFrame.new(center)
    part(m,"Floor",Vector3.new(24,1,20),cf*CFrame.new(0,0,0),Color3.fromRGB(77,62,51),Enum.Material.WoodPlanks)
    part(m,"BackWall",Vector3.new(24,11,.6),cf*CFrame.new(0,5.5,10),Color3.fromRGB(93,97,90))
    part(m,"LeftWall",Vector3.new(.6,11,20),cf*CFrame.new(-12,5.5,0),Color3.fromRGB(93,97,90))
    part(m,"RightWall",Vector3.new(.6,11,20),cf*CFrame.new(12,5.5,0),Color3.fromRGB(93,97,90))
    part(m,"WindowWallLeft",Vector3.new(6,11,.6),cf*CFrame.new(-9,5.5,-10),Color3.fromRGB(93,97,90))
    part(m,"WindowWallRight",Vector3.new(10,11,.6),cf*CFrame.new(7,5.5,-10),Color3.fromRGB(93,97,90))
    part(m,"WindowSill",Vector3.new(8,3,.8),cf*CFrame.new(-2,1.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
    part(m,"WindowHeader",Vector3.new(8,3,.8),cf*CFrame.new(-2,9.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
    local glass=part(m,"Window",Vector3.new(8,5,.15),cf*CFrame.new(-2,5.5,-10),Color3.fromRGB(77,91,105),Enum.Material.Glass);glass.Transparency=.35
    part(m,"WindowMullion",Vector3.new(.15,5,.2),cf*CFrame.new(-2,5.5,-9.85),Color3.fromRGB(43,46,43))
    local ceiling=part(m,"Ceiling",Vector3.new(24,.5,20),cf*CFrame.new(0,11,0),Color3.fromRGB(91,92,85))
    local fill=Instance.new("PointLight");fill.Brightness=2.5;fill.Range=23;fill.Color=Color3.fromRGB(214,203,180);fill.Shadows=false;fill.Parent=ceiling
    for _,z in {-9.7,9.7}do part(m,"Skirting",Vector3.new(24,.5,.2),cf*CFrame.new(0,.8,z),Color3.fromRGB(45,41,35),Enum.Material.Wood)end
    local bed=SS.SurvivalBedAsset:Clone();bed.Name="Bed"
    local box=bed:GetBoundingBox();local relative=bed:GetPivot():ToObjectSpace(box)
    bed:PivotTo(cf*CFrame.new(-4,3,1)*relative:Inverse())
    for _,v in bed:GetDescendants()do
        if v:IsA("BasePart")then v.Anchored=true
        elseif v:IsA("LuaSourceContainer")then v:Destroy()end
    end
    bed.Parent=m
    local tableTop=part(m,"Nightstand",Vector3.new(2,2.2,2),cf*CFrame.new(3,1.6,1),Color3.fromRGB(52,39,29),Enum.Material.Wood)
    local lamp=part(m,"Lamp",Vector3.new(.8,1.5,.8),tableTop.CFrame*CFrame.new(0,1.8,0),Color3.fromRGB(205,169,104),Enum.Material.Neon)
    local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,194,119);light.Brightness=1.3;light.Range=18;light.Parent=lamp
    part(m,"Rug",Vector3.new(7,.08,5),cf*CFrame.new(5,.55,2),Color3.fromRGB(66,62,59),Enum.Material.Fabric)
    local door=part(m,"FrontDoor",Vector3.new(3.5,7,.3),cf*CFrame.new(8,4.1,9.5),Color3.fromRGB(53,41,31),Enum.Material.Wood)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="ExitHouse";prompt.ActionText="Go outside";prompt.ObjectText="Your front door";prompt.HoldDuration=.35;prompt.MaxActivationDistance=7;prompt.Parent=door
    local windowPoint=part(m,"WindowPoint",Vector3.new(.2,.2,.2),cf*CFrame.new(-2,4,-6),Color3.new());windowPoint.Transparency=1;windowPoint.CanCollide=false;windowPoint.CanQuery=false
    m.Parent=parent
    return {Model=m,Lie=cf*CFrame.new(-3,3.65,1)*CFrame.Angles(0,0,-math.pi/2),Stand=cf*CFrame.new(5,3.6,2),Window=cf*CFrame.new(-2,3.6,-6),Prompt=prompt,WindowPart=windowPoint}
end
local function attached(parent,name,size,localCF,body,color,shape)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=body.CFrame*localCF;p.Color=color
    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Material=Enum.Material.Fabric
    if shape then p.Shape=shape end
    p.Parent=parent;local weld=Instance.new("WeldConstraint");weld.Part0=body;weld.Part1=p;weld.Parent=p;return p
end
function W.Zombie(template,parent,position,party)
    local z=template:Clone();z.Name="HoodedInfected";z:SetAttribute("SurvivalZombie",true);z:SetAttribute("PartyId",party)
    z.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
    z.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    local head=z.Head;local torso=z.UpperTorso;local dark=Color3.fromRGB(25,29,31)
    for _,v in head:GetChildren()do if v:IsA("Decal")then v:Destroy()end end
    attached(z,"HoodBack",Vector3.new(head.Size.X+.2,head.Size.Y+.4,.35),CFrame.new(0,.05,head.Size.Z/2+.05),head,dark)
    attached(z,"HoodLeft",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(-head.Size.X/2-.06,.05,0),head,dark)
    attached(z,"HoodRight",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(head.Size.X/2+.06,.05,0),head,dark)
    attached(z,"HoodTop",Vector3.new(head.Size.X+.5,.6,head.Size.Z+.4),CFrame.new(0,head.Size.Y/2+.13,0),head,dark,Enum.PartType.Ball)
    attached(z,"HoodiePocket",Vector3.new(.9,.4,.12),CFrame.new(0,-.45,-.53),torso,Color3.fromRGB(39,43,44))
    for _,x in {-.28,.28}do
        attached(z,"Drawstring",Vector3.new(.05,.55,.05),CFrame.new(x,.2,-.55),torso,Color3.fromRGB(140,142,129))
        local eye=attached(z,"RedEye",Vector3.new(.14,.14,.10),CFrame.new(x,.14,-head.Size.Z/2-.06),head,Color3.fromRGB(255,38,40),Enum.PartType.Ball)
        eye.Material=Enum.Material.Neon
        local light=Instance.new("PointLight");light.Color=eye.Color;light.Range=4;light.Brightness=.6;light.Parent=eye
    end
    local a=Instance.new("Attachment");a.Name="InfectionGlow";a.Parent=torso
    local glow=Instance.new("ParticleEmitter");glow.Name="RedInfectionMotes";glow.Texture="rbxasset://textures/particles/sparkles_main.dds"
    glow.Rate=7;glow.Lifetime=NumberRange.new(.5,.9);glow.Speed=NumberRange.new(.2,.8);glow.SpreadAngle=Vector2.new(70,70)
    glow.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.10),NumberSequenceKeypoint.new(1,0)})
    glow.Color=ColorSequence.new(Color3.fromRGB(235,35,45));glow.LightEmission=.85;glow.Transparency=NumberSequence.new(.25,.95);glow.Parent=a
    for _,v in z:GetDescendants()do if v:IsA("BasePart")then v.Anchored=false elseif v:IsA("LuaSourceContainer")then v:Destroy()end end
    z.Humanoid.BreakJointsOnDeath=false;z:PivotTo(CFrame.lookAt(position,position+Vector3.zAxis));z.Parent=parent;z.HumanoidRootPart:SetNetworkOwner(nil)
    return z
end
return W

]====],
[ [====[ServerScriptService.LobbySystem.Queue]====] ]=[====[-- Capacity is a maximum, not a requirement. Deadline is stable while nonempty.
local Q={};Q.__index=Q
function Q.new(modes,countdown)
    local self=setmetatable({Queues={},Membership={},Countdown=countdown},Q)
    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0}end
    return self
end
function Q:Remove(id)
    local mode=self.Membership[id];if not mode then return false end
    local q=self.Queues[mode]
    for i,v in q.Members do if v==id then table.remove(q.Members,i);break end end
    if #q.Members==0 then q.Deadline=nil end
    q.Generation+=1;self.Membership[id]=nil;return true
end
function Q:Add(id,mode)
    local q=self.Queues[mode];if not q then return false,"Unknown queue"end
    if self.Membership[id]==mode then return true end
    if #q.Members>=q.Size then return false,"Queue full"end
    self:Remove(id);table.insert(q.Members,id);self.Membership[id]=mode;q.Generation+=1;return true
end
function Q:Step(now,eligible)
    local launches={}
    for mode,q in self.Queues do
        local remove={}
        for _,id in q.Members do if not eligible(id,mode)then table.insert(remove,id)end end
        for _,id in remove do self:Remove(id)end
        if #q.Members>0 then
            q.Deadline=q.Deadline or now+self.Countdown
            if now>=q.Deadline then
                local members=table.clone(q.Members)
                for _,id in members do self.Membership[id]=nil end
                q.Members={};q.Deadline=nil;q.Generation+=1
                table.insert(launches,{Mode=mode,Members=members})
            end
        else q.Deadline=nil end
    end
    return launches
end
function Q:Snapshot()
    local out={};for mode,q in self.Queues do out[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline}end;return out
end
return Q

]====],
[ [====[StarterPlayer.StarterPlayerScripts.SurvivalRun]====] ]=[====[require(game.ReplicatedStorage:WaitForChild("SurvivalRun"):WaitForChild("Client")).Start()
]====],
}

-- Run BUILD_ASSETS first; creator-store furniture is inserted/vetted through MCP.
local root=game
local function resolve(path,create)
 local o=root;local segments=string.split(path,".")
 for i,key in segments do local child=o:FindFirstChild(key)
  if not child and create then local class=i==#segments and (path=="StarterPlayer.StarterPlayerScripts.SurvivalRun" and "LocalScript" or "ModuleScript")or "Folder";child=Instance.new(class);child.Name=key;child.Parent=o end
  assert(child,"Missing "..path);o=child
 end;return o
end
for path,source in expected do assert(resolve(path).Source==source,"Concurrent edit: "..path)end
assert(not root.ReplicatedStorage:FindFirstChild("SurvivalRun"),"Existing run package")
assert(not root.ServerScriptService:FindFirstChild("SurvivalRun"),"Existing server run package")
assert(root.ServerStorage:FindFirstChild("SurvivalBedAsset") and root.ServerStorage:FindFirstChild("SurvivalZombieRig"),"Prepare vetted assets first")
local backup=root.ServerStorage:FindFirstChild("PrivateZombieSessionBackup_20261017")
if not backup then backup=Instance.new("Folder");backup.Name="PrivateZombieSessionBackup_20261017";backup.Parent=root.ServerStorage end
for path,source in expected do
 local saved=backup:FindFirstChild(path)
 if saved then assert(saved.Source==source,"Original backup differs")else saved=resolve(path):Clone();saved.Name=path;saved:SetAttribute("OriginalPath",path);saved.Parent=backup end
end
local count=0
for path,source in changes do resolve(path,true).Source=source;count+=1;if count%4==0 then task.wait()end end
local lobby=root.Workspace and root.Workspace:FindFirstChild("SurvivorLobby")
if lobby then for _,pad in lobby.Queues:GetChildren()do pad.LabelAnchor.QueueLabel.Timer.Text="10 (sec)"end end
return "PASS: 18 final sources installed; 12 originals preserved; eight10s labels"

end)()
for _,pad in pads:GetChildren()do assert(pad.LabelAnchor.QueueLabel.Timer.Text=="10 (sec)")end
local restore=(function()
return function(root,backup)
 root=root or game;backup=backup or root.ServerStorage:FindFirstChild("PrivateZombieSessionBackup_20261017")
 assert(backup,"Missing preserved originals")
 local function resolve(path)local o=root;for _,s in string.split(path,".")do o=o and o:FindFirstChild(s)end;return o end
 local count=0
 for _,saved in backup:GetChildren()do local path=saved:GetAttribute("OriginalPath")
  if path then local dest=resolve(path);assert(dest and dest:IsA("LuaSourceContainer"),"Missing "..path);dest.Source=saved.Source;count+=1 end
 end
 assert(count==12,"Expected 12 originals")
 for _,path in {"ReplicatedStorage.SurvivalRun","ServerScriptService.SurvivalRun","StarterPlayer.StarterPlayerScripts.SurvivalRun","Workspace.SurvivalRun","ServerStorage.SurvivalBedAsset","ServerStorage.SurvivalZombieRig"}do local o=resolve(path);if o then o:Destroy()end end
 local lobby=resolve("Workspace.SurvivorLobby")
 if lobby then for _,pad in lobby.Queues:GetChildren()do pad.LabelAnchor.QueueLabel.Timer.Text="15 (sec)"end end
 return "PASS: 12 original sources/15s labels restored; run packages and two new assets removed"
end

end)()
local result=restore(fixture)
for _,pad in pads:GetChildren()do assert(pad.LabelAnchor.QueueLabel.Timer.Text=="15 (sec)")end
for path,source in baseline do local o=fixture;for _,s in string.split(path,".")do o=o[s]end;assert(o.Source==source,"Mismatch "..path)end
assert(not fixture.ReplicatedStorage:FindFirstChild("SurvivalRun") and not fixture.ServerScriptService:FindFirstChild("SurvivalRun"))
assert(not fixture.ServerStorage:FindFirstChild("SurvivalZombieRig"))
fixture:Destroy()
return installed.."; "..result.."; isolated fixture deleted; live game retained"


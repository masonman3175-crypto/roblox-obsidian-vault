local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local PhysicsService=game:GetService("PhysicsService")
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local Queue=require(script.Parent.Queue)
local S={}
local states,links={},{}
local queue=Queue.new(C.Modes,C.Countdown)
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
    return math.abs(point.X)<=pad.Zone.Size.X/2 and math.abs(point.Z)<=pad.Zone.Size.Z/2 and point.Y>=-2 and point.Y<=10
end
local function region(p)
    for _,m in C.Modes do if inPad(p,m.Id) then return m.Id end end
end
local function setMode(p,mode) p:SetAttribute("QueuedMode",mode or "") end
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
    p:SetAttribute("CoopPartyId","");p:SetAttribute("CoopPartySize",0);p:SetAttribute("CoopMode","")
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
    char:PivotTo(C.LobbySpawn)
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
    local expected
    for _,m in C.Modes do if m.Id==group.Mode then expected=m.Size;break end end
    if #members~=expected then for _,p in members do setMode(p,nil) end return false end
    local party=game.HttpService:GenerateGUID(false)
    for _,p in members do
        local s=states[p];s.Generation+=1;s.RunStart=os.clock()
        phase(p,"Deployed");setMode(p,nil)
        p:SetAttribute("CoopPartyId",party);p:SetAttribute("CoopPartySize",#members);p:SetAttribute("CoopMode",group.Mode)
        local char=p.Character
        local shield=char:FindFirstChild("LobbyShield");if shield then shield:Destroy() end
        char:PivotTo(C.ArenaSpawn)
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
        char:PivotTo(C.LobbySpawn)
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
            if math.abs(offset.X)>110 or math.abs(offset.Z)>83 or r.Position.Y<-10 then p.Character:PivotTo(C.LobbySpawn) end
        end
    end
    for _,group in queue:Step(workspace:GetServerTimeNow(),function(id,mode)
        local p=Players:GetPlayerByUserId(id);return p and inPad(p,mode) or false
    end) do deploy(group) end
    for _,m in C.Modes do
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

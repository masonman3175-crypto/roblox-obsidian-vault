local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local p=Players.LocalPlayer
local package=RS:WaitForChild("LobbySystem")
local C=require(package.Config)
local M={}
local started=false
local gui,title,detail,panel,queueTitle,queueDetail,leave,back
local links={}
local function connect(signal,fn) local c=signal:Connect(fn);table.insert(links,c);return c end
local function new(class,props,parent)
    local o=Instance.new(class)
    for k,v in props do o[k]=v end
    o.Parent=parent
    return o
end
local function text(name,content,size,pos,parent)
    return new("TextLabel",{Name=name,Text=content,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=Color3.fromRGB(233,237,230),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function camera()
    local char=p.Character
    task.spawn(function()
        local h=char and char:WaitForChild("Humanoid",10)
        if not started or p.Character~=char or not h then return end
        local lobby=p:GetAttribute("InLobby")==true
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h;cam.FieldOfView=72 end
        p.CameraMode=lobby and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        p.CameraMinZoomDistance=lobby and 7 or .5
        p.CameraMaxZoomDistance=lobby and 17 or .5
        UIS.MouseBehavior=lobby and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled=lobby
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not lobby) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true) end)
    end)
end
local function refresh()
    local lobby=p:GetAttribute("InLobby")==true
    title.Text=lobby and "SURVIVOR HUB" or "CO-OP SURVIVORS"
    detail.Text=lobby and "Walk into a queue to deploy together • One team, one shared spawn" or ((p:GetAttribute("CoopMode") or "Co-op").." • All survivors share the same team")
    back.Visible=not lobby
    panel.Visible=lobby and (p:GetAttribute("QueuedMode") or "")~=""
end
function M.Start()
    if started then return M end
    started=true
    gui=new("ScreenGui",{Name="SurvivorLobbyUI",ResetOnSpawn=false,DisplayOrder=42,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild("PlayerGui"))
    local header=new("Frame",{Name="Status",Size=UDim2.new(.72,0,0,78),Position=UDim2.fromOffset(18,14),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.12,BorderSizePixel=0},gui)
    new("UISizeConstraint",{MaxSize=Vector2.new(650,78),MinSize=Vector2.new(240,78)},header)
    new("UICorner",{CornerRadius=UDim.new(0,10)},header)
    new("UIStroke",{Color=Color3.fromRGB(77,142,110),Transparency=.35,Thickness=1},header)
    title=text("Title","SURVIVOR HUB",UDim2.new(1,-28,0,25),UDim2.fromOffset(14,10),header);title.TextSize=20
    detail=text("Detail","",UDim2.new(1,-28,0,32),UDim2.fromOffset(14,37),header);detail.TextSize=12;detail.TextColor3=Color3.fromRGB(167,191,175)
    panel=new("Frame",{Name="QueuePanel",Size=UDim2.new(.9,0,0,106),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-25),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.08,BorderSizePixel=0},gui)
    new("UISizeConstraint",{MaxSize=Vector2.new(560,106)},panel)
    new("UICorner",{CornerRadius=UDim.new(0,12)},panel)
    new("UIStroke",{Color=Color3.fromRGB(81,196,144),Transparency=.25},panel)
    queueTitle=text("Mode","",UDim2.new(1,-140,0,30),UDim2.fromOffset(16,13),panel)
    queueDetail=text("Countdown","",UDim2.new(1,-140,0,46),UDim2.fromOffset(16,43),panel);queueDetail.TextSize=12
    leave=new("TextButton",{Name="LeaveQueue",Text="LEAVE",Size=UDim2.fromOffset(100,40),Position=UDim2.new(1,-116,.5,-20),BackgroundColor3=Color3.fromRGB(55,76,67),TextColor3=Color3.fromRGB(240,244,239),Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0},panel)
    new("UICorner",{CornerRadius=UDim.new(0,7)},leave)
    back=new("TextButton",{Name="ReturnToLobby",Text="LOBBY [M]",Size=UDim2.fromOffset(116,32),Position=UDim2.new(1,-134,0,18),BackgroundColor3=Color3.fromRGB(21,36,29),TextColor3=Color3.fromRGB(225,235,225),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
    new("UICorner",{CornerRadius=UDim.new(0,7)},back)
    connect(leave.Activated,function() package.Request:FireServer("Leave") end)
    connect(back.Activated,function() package.Request:FireServer("Return") end)
    connect(UIS.InputBegan,function(input,processed)
        if not processed and input.KeyCode==Enum.KeyCode.M and not p:GetAttribute("InLobby") then package.Request:FireServer("Return") end
    end)
    RunService:BindToRenderStep("SurvivorLobbyCursor",Enum.RenderPriority.Last.Value+1,function()
        if p:GetAttribute("InLobby") and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            UIS.MouseBehavior=Enum.MouseBehavior.Default;UIS.MouseIconEnabled=true
        end
    end)
    connect(p:GetAttributeChangedSignal("InLobby"),function() refresh();camera() end)
    connect(p:GetAttributeChangedSignal("QueuedMode"),refresh)
    connect(p:GetAttributeChangedSignal("CoopMode"),refresh)
    connect(p.CharacterAdded,function() camera();refresh() end)
    local world=workspace:WaitForChild("SurvivorLobby")
    local elapsed=0
    connect(RunService.Heartbeat,function(dt)
        elapsed+=dt;if elapsed<.1 then return end;elapsed=0
        for _,mode in C.Modes do
            local pad=world.Queues[mode.Id]
            local count=pad:GetAttribute("QueueCount") or 0
            local deadline=pad:GetAttribute("DepartureAt") or 0
            local remaining=math.max(0,math.ceil(deadline-workspace:GetServerTimeNow()))
            local board=pad.Sign.SurfaceGui
            board.Count.Text=count.." / "..mode.Size.." SURVIVORS"
            board.Status.Text=deadline>0 and ("DEPLOYING IN "..remaining) or ("STEP IN • "..mode.Size.." PLAYER"..(mode.Size>1 and "S" or ""))
            if p:GetAttribute("QueuedMode")==mode.Id then
                queueTitle.Text=string.upper(mode.Id).."  •  "..count.." / "..mode.Size
                queueDetail.Text=deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or ("Waiting for "..math.max(0,mode.Size-count).." more survivor(s)")
            end
        end
    end)
    refresh();camera()
    return M
end
function M.Destroy()
    started=false
    RunService:UnbindFromRenderStep("SurvivorLobbyCursor")
    for _,c in links do c:Disconnect() end;links={}
    if gui then gui:Destroy() end
end
return M

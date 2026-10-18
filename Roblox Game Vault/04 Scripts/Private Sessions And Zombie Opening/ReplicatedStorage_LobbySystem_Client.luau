local Players=game:GetService("Players")
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

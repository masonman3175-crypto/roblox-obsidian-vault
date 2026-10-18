local Players=game:GetService("Players")
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


local Players=game:GetService('Players')
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
    return char and char.Parent and hum and hum.Health>0 and not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')
end
local function sendSprint(value)
    if value~=sent then sent=value;remote:FireServer('Sprint',value)end
end
function M.Sprint(value)
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
function M.CancelSlide()queuedSlideUntil=0;remote:FireServer('CancelSlide');return true end
function M.GetState()
    return {Mode=p:GetAttribute('MovementState') or 'Idle',Stamina=p:GetAttribute('MovementStamina') or 100,
        FovOffset=fov,CameraDrop=drop,ShakeDegrees=amount,SlideReadyIn=p:GetAttribute('SlideReadyIn') or 0,
        WalkSpeed=hum and hum.WalkSpeed,Grounded=hum and hum.FloorMaterial~=Enum.Material.Air,
        CameraOffsetY=hum and hum.CameraOffset.Y,SlideBuffered=queuedSlideUntil>os.clock(),
        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y}
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
    p.CharacterRemoving:Connect(function(c)
        if char==c then
            if hum and hum.Parent then hum.CameraOffset=baseCameraOffset end
            queuedSlideUntil=0;char,hum,root=nil,nil,nil;sendSprint(false)
        end
    end)
    CAS:BindActionAtPriority('GameplaySprint',function(_,state,input)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if input.KeyCode==Enum.KeyCode.ButtonL3 and state==Enum.UserInputState.Begin then toggled=not toggled
        elseif state==Enum.UserInputState.Begin then held=true
        elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false;forced=false end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
    CAS:SetTitle('GameplaySprint','SPRINT');CAS:SetPosition('GameplaySprint',UDim2.fromScale(.72,.72))
    CAS:BindActionAtPriority('GameplaySlide',function(_,state)
        if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin then M.Slide()end
        return Enum.ContextActionResult.Sink
    end,true,2100,Enum.KeyCode.C,Enum.KeyCode.LeftControl,Enum.KeyCode.ButtonB)
    CAS:SetTitle('GameplaySlide','SLIDE');CAS:SetPosition('GameplaySlide',UDim2.fromScale(.84,.72))
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
        local target=live and p:GetAttribute('MovementState')=='Sliding' and C.CameraDrop or 0
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
            and not p:GetAttribute('FPSAiming') and not p:GetAttribute('FPSReloading')
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
        local targetFov=slide and C.SlideFov or sprint and C.SprintFov or 0
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

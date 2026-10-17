-- Edit-mode installer. Backups and optimistic guards preserve concurrent work.
local expected={
[ [====[ReplicatedStorage.GameplayPresentation.MovementConfig]====] ]=[====[return {
    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=.60, CrouchCameraDrop=.95, SlideSpeed=36, SlideEndSpeed=18,
    SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
    StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
    ExhaustionRecovery=15, HipDrop=.35, CameraDrop=1.45,
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
        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y}
end
local poses={}
local function clearPose(rec)
    for joint,offset in rec.Applied do
        if joint.Parent then joint.Transform=joint.Transform*offset:Inverse()end
    end
    rec.Applied={}
end
local function updatePoses(dt)
    for _,plr in Players:GetPlayers() do
        local c=plr.Character
        local rec=poses[plr]
        if rec and rec.Char~=c then clearPose(rec);poses[plr]=nil;rec=nil end
        if c then
            if not rec then
                rec={Char=c,Alpha=0,Applied={},Joints={}}
                for name,degrees in {Waist=8,LeftHip=-25,RightHip=-25,LeftKnee=55,RightKnee=55,LeftAnkle=-30,RightAnkle=-30}do
                    local joint=c:FindFirstChild(name,true)
                    if joint and joint:IsA('Motor6D')then table.insert(rec.Joints,{Joint=joint,Angle=math.rad(degrees)})end
                end
                poses[plr]=rec
            end
            local h=c:FindFirstChildOfClass('Humanoid')
            local target=h and h.Health>0 and plr:GetAttribute('MovementCrouched') and 1 or 0
            rec.Alpha+=(target-rec.Alpha)*(1-math.exp(-math.min(dt,.05)*14))
            if rec.Alpha>.001 then for _,j in rec.Joints do
                if j.Joint.Parent then
                    local offset=CFrame.Angles(j.Angle*rec.Alpha,0,0)
                    j.Joint.Transform*=offset
                    rec.Applied[j.Joint]=offset
                end
            end end
        end
    end
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
    RunService.PreAnimation:Connect(function()for _,rec in poses do clearPose(rec)end end)
    RunService.PreSimulation:Connect(updatePoses)
    Players.PlayerRemoving:Connect(function(plr)local rec=poses[plr];if rec then clearPose(rec);poses[plr]=nil end end)
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

-- aim pose for every armed character (runs after animations, before physics)
local function joint(character, partName, jointName)
	local part = character:FindFirstChild(partName)
	return part and part:FindFirstChild(jointName)
end

RunService.Stepped:Connect(function()
	for _, plr in Players:GetPlayers() do
		local character = plr.Character
		if character and armed(character) and not plr:GetAttribute("InLobby") then
			local pitch = plr == player and cameraPitch() or (plr:GetAttribute("AimPitch") or 0)
			pitch = math.clamp(pitch, math.rad(-70), math.rad(70))
			local waist = joint(character, "UpperTorso", "Waist")
			local neck = joint(character, "Head", "Neck")
			local rs = joint(character, "RightUpperArm", "RightShoulder")
			local ls = joint(character, "LeftUpperArm", "LeftShoulder")
			local re = joint(character, "RightLowerArm", "RightElbow")
			local le = joint(character, "LeftLowerArm", "LeftElbow")
			local rw = joint(character, "RightHand", "RightWrist")
			local lw = joint(character, "LeftHand", "LeftWrist")
			if waist then waist.Transform = CFrame.Angles(pitch * 0.35, 0, 0) end
			if neck then neck.Transform = CFrame.Angles(pitch * 0.4, 0, 0) end
			local armPitch = math.pi / 2 + pitch * 0.65
			if rs then rs.Transform = CFrame.Angles(0, 0.12, 0) * CFrame.Angles(armPitch, 0, 0) end
			if re then re.Transform = CFrame.identity end
			if rw then rw.Transform = CFrame.identity end
			if ls then ls.Transform = CFrame.Angles(0, -0.75, 0) * CFrame.Angles(armPitch + 0.1, 0, 0) end
			if le then le.Transform = CFrame.Angles(0.25, 0, 0) end
			if lw then lw.Transform = CFrame.identity end
		end
	end
end)
]====],
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
    local standing=math.max(0,h.HipHeight)+r.Size.Y/2+legHeight
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
}
local changes={
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
}
local function resolve(path,create)
 local obj=game;local segments=string.split(path,".")
 for i,key in segments do local child=obj:FindFirstChild(key)
 if not child and create then child=Instance.new(i==#segments and "ModuleScript" or "Folder");child.Name=key;child.Parent=obj end
 assert(child,"Missing "..path);obj=child end
 return obj
end
for path,source in expected do assert(resolve(path).Source==source,"Concurrent edit at "..path)end
assert(not game.ReplicatedStorage.GameplayPresentation:FindFirstChild("CharacterPose"),"Pose module already exists")
local backup=Instance.new("Folder");backup.Name="SlideAndGripBackup_20261017";assert(not game.ServerStorage:FindFirstChild(backup.Name),"Backup exists")
for path in expected do local original=resolve(path):Clone();original.Name=path;original:SetAttribute("OriginalPath",path);original.Parent=backup end
backup.Parent=game.ServerStorage
for path,source in changes do resolve(path,true).Source=source end
return "PASS: 4 sources patched + CharacterPose created; originals backed up"

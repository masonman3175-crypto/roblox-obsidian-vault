local Players=game:GetService('Players')
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
    if p:GetAttribute('InMenu') or not s.Hum or not s.Root or not s.Char.Parent or s.Hum.Health<=0 then return reject(p,s,'Not deployed')end
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
    if p:GetAttribute('InMenu') or not s.Hum or not s.Root or not s.Root.Parent or s.Hum.Health<=0 then
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


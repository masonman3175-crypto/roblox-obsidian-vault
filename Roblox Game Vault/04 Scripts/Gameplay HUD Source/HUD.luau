local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local TweenService=game:GetService('TweenService')
local StarterGui=game:GetService('StarterGui')
local CAS=game:GetService('ContextActionService')
local p=Players.LocalPlayer
local package=script.Parent
local C=require(package.MovementConfig)
local Weapons=require(RS.ReferenceWeapons.WeaponConfig)
local H={}
local gui,map,score,ammo,rail,stamina,feed,miniCam,miniWorld,weaponWorld,weaponCam
local redCount,blueCount,redGoal,blueGoal,standing,timer,ammoCount,reserveCount,actionLabel,energyBar,energyText
local squad,help,healthText,grenadeCount
local ready=false
local markers={}
local currentWeapon=''
local feedRows={}
local elapsed=0
local WHITE=Color3.fromRGB(249,246,239)
local RED=Color3.fromRGB(227,58,65)
local BLUE=Color3.fromRGB(51,175,211)
local font=Enum.Font.IndieFlower
local function make(class,props,parent)
    local o=Instance.new(class);for k,v in pairs(props)do o[k]=v end;o.Parent=parent;return o
end
local function frame(name,x,y,w,h,color,parent,alpha)
    return make('Frame',{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or WHITE,BackgroundTransparency=alpha or 0,BorderSizePixel=0},parent)
end
local function text(name,value,x,y,w,h,size,parent,color)
    local label=make('TextLabel',{Name=name,Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,TextColor3=color or WHITE,TextSize=size,Font=font,TextXAlignment=Enum.TextXAlignment.Left,TextStrokeTransparency=.78,TextStrokeColor3=Color3.fromRGB(16,20,24)},parent)
    make('UIStroke',{Color=color or WHITE,Thickness=.45,Transparency=.30,ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual},label)
    return label
end
local function stroke(ob,color,alpha,width)
    return make('UIStroke',{Color=color,Transparency=alpha or 0,Thickness=width or 1},ob)
end
local function line(parent,a,b,width,color)
    local delta=b-a
    local o=frame('Stroke',(a.X+b.X)/2,(a.Y+b.Y)/2,delta.Magnitude,width,color,parent)
    o.AnchorPoint=Vector2.new(.5,.5);o.Rotation=math.deg(math.atan2(delta.Y,delta.X));return o
end
local function triangle(parent,name,color)
    local o=frame(name,0,0,18,18,WHITE,parent,1);o.AnchorPoint=Vector2.new(.5,.5)
    line(o,Vector2.new(9,1),Vector2.new(16,16),1.6,color)
    line(o,Vector2.new(16,16),Vector2.new(9,12),1.6,color)
    line(o,Vector2.new(9,12),Vector2.new(2,16),1.6,color)
    line(o,Vector2.new(2,16),Vector2.new(9,1),1.6,color)
    return o
end
local function container(name,w,h,parent)
    local ob=frame(name,0,0,w,h,WHITE,parent,1)
    make('UIScale',{Name='ResponsiveScale',Scale=1},ob);return ob
end
local function setWeapon(id)
    if currentWeapon==id then return end;currentWeapon=id
    for _,o in ipairs(weaponWorld:GetChildren())do o:Destroy()end
    local src=RS.ReferenceWeapons.Viewmodels:FindFirstChild(id)
    if not src then return end
    local model=src:Clone();model.Name='WeaponSilhouette';model:PivotTo(CFrame.identity)
    for _,o in ipairs(model:GetDescendants())do
        if o:IsA('BasePart')then
            o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false;o.CastShadow=false
            o.Color=WHITE;o.Material=Enum.Material.SmoothPlastic
            if o:IsA('MeshPart')then o.TextureID=''end
        elseif o:IsA('SurfaceAppearance') or o:IsA('Decal') or o:IsA('Texture') or o:IsA('BaseScript')then o:Destroy()end
    end
    model.Parent=weaponWorld
    local cf,size=model:GetBoundingBox()
    local distance=math.max(4.7,size.Magnitude*1.7)
    weaponCam.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance,.2,.02),cf.Position)
    weaponCam.FieldOfView=24
    gui:SetAttribute('WeaponId',id)
end
local function squadText()
    local names={}
    for _,other in ipairs(Players:GetPlayers())do
        if other==p or (p.Team and not p.Neutral and other.Team==p.Team)then table.insert(names,other.DisplayName)end
    end
    squad.Names.Text=table.concat(names,'\n')
    squad.TeamNote.Text=p.Team and p.Team.Name:upper() or 'NO TEAM ASSIGNED'
end
function H.PushFeed(data)
    if typeof(data)~='table' or typeof(data.Attacker)~='string' or typeof(data.Victim)~='string' then return false end
    local row=frame('Elimination',0,0,440,26,WHITE,feed,1)
    local left=text('Attacker',data.Attacker:sub(1,24),0,0,174,26,17,row,RED);left.TextXAlignment=Enum.TextXAlignment.Right
    text('Symbol','>',186,0,32,26,21,row,WHITE).TextXAlignment=Enum.TextXAlignment.Center
    text('Victim',data.Victim:sub(1,24),232,0,194,26,17,row,BLUE)
    table.insert(feedRows,1,{Frame=row,Time=os.clock()})
    if #feedRows>4 then table.remove(feedRows).Frame:Destroy()end
    return true
end
local function build()
    gui=make('ScreenGui',{Name='ReferenceGameplayHUD',IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild('PlayerGui'))
    gui:SetAttribute('FontFamily','IndieFlower');gui:SetAttribute('FontMatch','Closest available; exact source font unverified')
    map=container('Minimap',285,285,gui)
    local disk=frame('Disk',0,0,285,285,Color3.fromRGB(27,32,34),map,.12)
    make('UICorner',{CornerRadius=UDim.new(1,0)},disk);stroke(disk,Color3.fromRGB(225,228,225),.58,2)
    local view=make('ViewportFrame',{Name='MapViewport',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(34,42,40),BackgroundTransparency=0,BorderSizePixel=0,Ambient=Color3.fromRGB(165,167,158),LightColor=Color3.fromRGB(230,226,205),LightDirection=Vector3.new(-1,-3,-1)},disk)
    make('UICorner',{CornerRadius=UDim.new(1,0)},view)
    miniWorld=make('WorldModel',{Name='MapWorld'},view)
    package.MinimapWorld:Clone().Parent=miniWorld
    miniCam=make('Camera',{Name='MapCamera',FieldOfView=C.MinimapFov},view);view.CurrentCamera=miniCam
    local centre=triangle(disk,'LocalPlayer',WHITE);centre.Position=UDim2.fromOffset(142.5,142.5);centre.ZIndex=3
    text('North','N',132,8,21,21,13,map,WHITE).TextXAlignment=Enum.TextXAlignment.Center
    score=container('TeamScore',285,184,gui);score.AnchorPoint=Vector2.new(0,1)
    standing=text('Standing','WARMUP',0,-4,235,32,26,score)
    local r=frame('RedPanel',0,32,234,61,Color3.fromRGB(83,19,27),score,.34);r.Rotation=-4
    make('UIGradient',{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(1,.65)})},r)
    local accent=frame('Slash',6,36,3,58,RED,score);accent.Rotation=16
    text('RedEmblem','R',20,30,60,66,55,score,RED).Rotation=-8
    redCount=text('RedScore','0',78,24,100,74,72,score)
    redGoal=text('RedTarget','/ 100',150,47,90,40,30,score)
    local b=frame('BluePanel',0,106,181,43,Color3.fromRGB(19,43,57),score,.35);b.Rotation=-4
    make('UIGradient',{Transparency=NumberSequence.new(0,.65)},b)
    local ba=frame('Slash',5,107,2,40,BLUE,score);ba.Rotation=16
    text('BlueEmblem','B',20,100,40,47,37,score,BLUE).Rotation=-5
    blueCount=text('BlueScore','0',57,98,75,52,47,score)
    blueGoal=text('BlueTarget','/ 100',110,113,80,34,24,score)
    timer=text('Timer','0:00',0,148,180,38,31,score)
    ammo=container('AmmoCluster',380,100,gui);ammo.AnchorPoint=Vector2.new(1,1)
    local gunView=make('ViewportFrame',{Name='GunIcon',Position=UDim2.fromOffset(0,23),Size=UDim2.fromOffset(155,57),BackgroundTransparency=1,Ambient=WHITE,LightColor=WHITE,LightDirection=Vector3.new(-1,-1,-1),BorderSizePixel=0},ammo)
    weaponWorld=make('WorldModel',{Name='IconWorld'},gunView)
    weaponCam=make('Camera',{Name='IconCamera'},gunView);gunView.CurrentCamera=weaponCam
    for i=1,4 do frame('Round'..i,165,34+i*6,5,3,WHITE,ammo,.08)end
    ammoCount=text('Magazine','--',191,6,100,85,78,ammo)
    reserveCount=text('Reserve','--',270,19,65,48,32,ammo)
    actionLabel=text('Action','',0,1,220,23,16,ammo)
    grenadeCount=text('Grenades','0',336,40,22,34,27,ammo)
    local grenade=frame('Grenade',364,53,10,13,WHITE,ammo,.25);make('UICorner',{CornerRadius=UDim.new(.45,0)},grenade)
    local pin=frame('Pin',367,47,7,6,WHITE,ammo,1);stroke(pin,WHITE,.25);pin.Rotation=15
    text('InventoryNote','',0,80,370,19,12,ammo)
    rail=container('UtilityRail',46,105,gui);rail.AnchorPoint=Vector2.new(1,.5)
    local function utility(name,y)
        return make('TextButton',{Name=name,Position=UDim2.fromOffset(0,y),Size=UDim2.fromOffset(46,46),Text='',BackgroundColor3=Color3.fromRGB(35,39,43),BackgroundTransparency=.6,AutoButtonColor=true,BorderSizePixel=0},rail)
    end
    local people=utility('Squad',0)
    for _,v in ipairs({{12,14,10},{25,14,10},{19,8,10}})do
        local dot=frame('Head',v[1],v[2],v[3],v[3],WHITE,people,.27);make('UICorner',{CornerRadius=UDim.new(1,0)},dot)
        local shoulders=frame('Shoulders',v[1]-3,v[2]+10,v[3]+6,9,WHITE,people,.27);make('UICorner',{CornerRadius=UDim.new(.4,0)},shoulders)
    end
    local inspect=utility('Inspect',57)
    local face=frame('Face',9,9,28,28,WHITE,inspect,1);make('UICorner',{CornerRadius=UDim.new(1,0)},face);stroke(face,WHITE,.35,2)
    frame('Eye',16,17,3,4,WHITE,inspect,.25);frame('Eye',27,17,3,4,WHITE,inspect,.25)
    line(inspect,Vector2.new(16,28),Vector2.new(23,31),1.5,WHITE);line(inspect,Vector2.new(23,31),Vector2.new(30,28),1.5,WHITE)
    people.Activated:Connect(function()squad.Visible=not squad.Visible;squadText()end)
    inspect.Activated:Connect(function()local bridge=p.PlayerScripts:FindFirstChild('ReferenceFPSControl');if bridge then bridge:Invoke('Inspect')end end)
    squad=container('SquadPanel',270,226,gui);squad.AnchorPoint=Vector2.new(1,0);squad.BackgroundTransparency=.16;squad.BackgroundColor3=Color3.fromRGB(22,27,32);squad.Visible=false
    text('Title','SQUAD',16,7,238,32,24,squad)
    text('TeamNote','NO TEAM ASSIGNED',16,42,238,25,15,squad,BLUE)
    local names=text('Names','',16,78,238,126,19,squad);names.TextYAlignment=Enum.TextYAlignment.Top
    healthText=text('Health','100 HP',0,0,125,25,17,gui);healthText.Visible=false
    stamina=container('MovementStatus',236,39,gui);stamina.AnchorPoint=Vector2.new(.5,1)
    energyText=text('State','',0,0,236,23,15,stamina);energyText.TextXAlignment=Enum.TextXAlignment.Center
    local track=frame('Track',24,30,188,3,Color3.fromRGB(45,48,50),stamina,.4)
    energyBar=frame('Energy',0,0,188,3,WHITE,track,.20)
    help=container('ControlsHint',470,28,gui);help.AnchorPoint=Vector2.new(.5,1)
    local hint=text('Hint','SHIFT  SPRINT   /   C  SLIDE   /   M  MENU',0,0,470,28,17,help);hint.TextXAlignment=Enum.TextXAlignment.Center
    local reticle=container('AimMark',3,9,gui);reticle.AnchorPoint=Vector2.new(.5,.5);reticle.Position=UDim2.fromScale(.5,.5)
    local mark=frame('Mark',1,0,1.3,7,WHITE,reticle,.1);stroke(mark,Color3.new(0,0,0),.65)
    feed=container('KillFeed',440,126,gui);feed.AnchorPoint=Vector2.new(1,0)
    -- Only server-published elimination notices enter this feed. No simulated kills.
    package.HUDEvent.OnClientEvent:Connect(function(kind,data)if kind=='Elimination'then H.PushFeed(data)end end)
    local bridge=make('BindableFunction',{Name='GameplayHUDControl'},p:WaitForChild('PlayerScripts'))
    bridge.OnInvoke=function()
        return {Visible=gui.Enabled,Font=font.Name,Weapon=currentWeapon,Ammo=ammoCount.Text,Reserve=reserveCount.Text,
            Red=redCount.Text,Blue=blueCount.Text,Timer=timer.Text,MapParts=#miniWorld:GetDescendants(),FeedRows=#feedRows}
    end
end
local function minimapUpdate(camera,root)
    local forward=camera.CFrame.LookVector*Vector3.new(1,0,1)
    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1)else forward=forward.Unit end
    local pos=root.Position
    miniCam.CFrame=CFrame.lookAt(pos+Vector3.yAxis*C.MinimapHeight,pos,forward)
    local right=Vector3.new(-forward.Z,0,forward.X)
    local half=C.MinimapHeight*math.tan(math.rad(C.MinimapFov/2))
    local live={}
    for _,other in ipairs(Players:GetPlayers())do
        if other~=p and p.Team and not p.Neutral and other.Team==p.Team and other.Character then
            local r=other.Character:FindFirstChild('HumanoidRootPart')
            if r then
                local delta=r.Position-pos;local xy=Vector2.new(delta:Dot(right),-delta:Dot(forward))*(142.5/half)
                local marker=markers[other]
                if not marker then marker=triangle(map.Disk,other.Name,Color3.fromRGB(103,231,239));markers[other]=marker end
                marker.Position=UDim2.fromOffset(142.5+xy.X,142.5+xy.Y);marker.Visible=xy.Magnitude<130;live[other]=true
            end
        end
    end
    for other,marker in pairs(markers)do if not live[other]then marker:Destroy();markers[other]=nil end end
end
local function attr(name,default)local value=workspace:GetAttribute(name);return value~=nil and value or default end
function H.Start()
    if ready then return H end;ready=true;build()
    local hintsUntil=os.clock()+15
    local coreClock=0
    CAS:BindActionAtPriority('GameplayWeaponSlots',function(_,state,input)
        if UIS:GetFocusedTextBox() or p:GetAttribute('InMenu') or p:GetAttribute('MenuClientOpen')then return Enum.ContextActionResult.Pass end
        if state==Enum.UserInputState.Begin then
            local keyIndex=table.find({Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five},input.KeyCode)
            local char=p.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
            if keyIndex and hum then
                local spec=Weapons.Guns[Weapons.Order[keyIndex]]
                local tool=p.Backpack:FindFirstChild(spec.Name) or char:FindFirstChild(spec.Name)
                if tool then hum:EquipTool(tool)end
            end
        end
        return Enum.ContextActionResult.Sink
    end,false,1800,Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five)
    p.CharacterAdded:Connect(function()hintsUntil=os.clock()+12 end)
    RunService:BindToRenderStep('ReferenceGameplayHUD',Enum.RenderPriority.Camera.Value+4,function(dt)
        local camera=workspace.CurrentCamera;if not camera then return end
        local char=p.Character;local root=char and char:FindFirstChild('HumanoidRootPart');local hum=char and char:FindFirstChildOfClass('Humanoid')
        local live=root and hum and hum.Health>0 and not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')
        gui.Enabled=live==true;if not live then return end
        elapsed+=dt;coreClock+=dt
        if coreClock>.25 then
            coreClock=0
            pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false);StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)end)
        end
        local scale=math.clamp(math.min(camera.ViewportSize.Y/1080,camera.ViewportSize.X/1280),.5,2)
        for _,ob in ipairs({map,score,ammo,rail,stamina,feed,squad,help,gui.AimMark})do ob.ResponsiveScale.Scale=scale end
        map.Position=UDim2.fromOffset(54*scale,54*scale)
        score.Position=UDim2.new(0,56*scale,1,-24*scale)
        ammo.Position=UDim2.new(1,-36*scale,1,-24*scale)
        rail.Position=UDim2.new(1,-30*scale,.59,0)
        feed.Position=UDim2.new(1,-30*scale,.275,0)
        squad.Position=UDim2.new(1,-88*scale,.55,0)
        stamina.Position=UDim2.new(.5,0,1,-69*scale)
        help.Position=UDim2.new(.5,0,1,-25*scale)
        help.Visible=os.clock()<hintsUntil
        local id=p:GetAttribute('FPSWeaponId') or ''
        setWeapon(id)
        local mag,reserve=p:GetAttribute('FPSAmmo'),p:GetAttribute('FPSReserve')
        ammoCount.Text=mag and tostring(mag) or '--';reserveCount.Text=reserve and tostring(reserve) or '--'
        reserveCount.Position=UDim2.fromOffset(191+math.max(42,ammoCount.TextBounds.X)+8,19)
        local reloading=p:GetAttribute('FPSReloading')
        actionLabel.Text=reloading and 'RELOADING' or p:GetAttribute('FPSInspecting') and 'INSPECTING' or ''
        ammoCount.TextColor3=mag and mag<=3 and RED or WHITE
        grenadeCount.Text=tostring(p:GetAttribute('GrenadeCount') or 0)
        local red=attr('ScoreRed',0);local blue=attr('ScoreBlue',0);local target=attr('ScoreTarget',100)
        redCount.Text=tostring(red);blueCount.Text=tostring(blue);redGoal.Text='/ '..target;blueGoal.Text='/ '..target
        redGoal.Position=UDim2.fromOffset(78+math.max(30,redCount.TextBounds.X)+5,47)
        blueGoal.Position=UDim2.fromOffset(57+math.max(24,blueCount.TextBounds.X)+5,113)
        local deadline=workspace:GetAttribute('MatchEndsAt')
        local seconds=deadline and math.max(0,math.ceil(deadline-workspace:GetServerTimeNow())) or attr('MatchSecondsRemaining',0)
        timer.Text=string.format('%d:%02d',math.floor(seconds/60),seconds%60)
        standing.Text=not workspace:GetAttribute('MatchActive') and 'WARMUP' or red==blue and 'TIED' or red>blue and 'RED LEADS' or 'BLUE LEADS'
        local state=p:GetAttribute('MovementState') or 'Idle';local energy=p:GetAttribute('MovementStamina') or 100
        stamina.Visible=state=='Sprinting' or state=='Sliding' or energy<99
        energyBar.Size=UDim2.fromOffset(188*math.clamp(energy/100,0,1),3)
        energyBar.BackgroundColor3=energy<20 and RED or WHITE
        local cooldown=p:GetAttribute('SlideReadyIn') or 0
        energyText.Text=state=='Sliding' and 'SLIDING' or state=='Sprinting' and 'SPRINTING' or energy<25 and 'CATCH YOUR BREATH' or cooldown>0 and 'RECOVERING' or ''
        gui.AimMark.Visible=not p:GetAttribute('FPSAiming') and state~='Sliding'
        if elapsed>.06 then minimapUpdate(camera,root);elapsed=0 end
        for i=#feedRows,1,-1 do
            local row=feedRows[i];local age=os.clock()-row.Time
            if age>5 then row.Frame:Destroy();table.remove(feedRows,i)
            else row.Frame.Position=UDim2.fromOffset(0,(i-1)*28);for _,t in ipairs(row.Frame:GetChildren())do if t:IsA('TextLabel')then t.TextTransparency=math.clamp((age-4)/1,0,1)end end end
        end
    end)
    return H
end
return H

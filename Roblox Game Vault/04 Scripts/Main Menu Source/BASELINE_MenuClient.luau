local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local TweenService=game:GetService('TweenService')
local StarterGui=game:GetService('StarterGui')
local Lighting=game:GetService('Lighting')
local player=Players.LocalPlayer
local package=script.Parent
local Config=require(package.MenuConfig)
local Cosmetics=require(package.Cosmetics)
local Weapons=require(RS.ReferenceWeapons.WeaponConfig)
local Menu={}
local state={Skin=Config.DefaultSkin,Wrap=Config.DefaultWrap,Weapon=Config.DefaultWeapon,InMenu=true}
local active,page,tab,busy=true,'HOME','SKINS',false
local gui,canvas,scaler,home,locker,preview,world,hero,previewCam,avatarName,wrapName,weaponName,status,playText,fade,ingame
local skinButtons,wrapButtons={},{}
local links={}
local started=false
local yaw,dragging,lastX=0,false,0
local spin,skinPanel,wrapPanel,skinTab,wrapTab,homeInfo,heroTop,blur
local palette={Ink=Color3.fromRGB(10,17,26),Panel=Color3.fromRGB(20,29,41),Line=Color3.fromRGB(60,74,87),Text=Color3.fromRGB(236,240,243),Muted=Color3.fromRGB(143,160,175),Amber=Color3.fromRGB(239,171,76)}
local function link(signal,fn)local c=signal:Connect(fn);table.insert(links,c);return c end
local function new(class,props,parent)
    local ob=Instance.new(class)
    for k,v in pairs(props)do ob[k]=v end
    ob.Parent=parent;return ob
end
local function frame(name,x,y,w,h,color,parent,transparency)
    return new('Frame',{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BorderSizePixel=0,BackgroundColor3=color,BackgroundTransparency=transparency or 0},parent)
end
local function text(name,body,x,y,w,h,size,color,parent,font)
    return new('TextLabel',{Name=name,Text=body,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,TextColor3=color or palette.Text,TextSize=size or 18,Font=font or Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center},parent)
end
local function stroke(ob,color,transparency)
    return new('UIStroke',{Color=color,Thickness=1,Transparency=transparency or 0},ob)
end
local function button(name,body,x,y,w,h,parent,color)
    local b=new('TextButton',{Name=name,Text=body,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),AutoButtonColor=false,BackgroundColor3=color or palette.Panel,BorderSizePixel=0,TextColor3=palette.Text,TextSize=16,Font=Enum.Font.GothamBold,Selectable=true},parent)
    link(b.MouseEnter,function()TweenService:Create(b,TweenInfo.new(.14),{BackgroundTransparency=.13}):Play()end)
    link(b.MouseLeave,function()TweenService:Create(b,TweenInfo.new(.14),{BackgroundTransparency=0}):Play()end)
    return b
end
local function message(value)
    if status then status.Text=value end
end
local function request(action,value)
    local ok,result=pcall(function()return package.Request:InvokeServer(action,value)end)
    if not ok or typeof(result)~='table' then return false,'Connection interrupted. Please try again.' end
    if result.Ok then if result.State then state=result.State end;return true end
    return false,result.Message or 'Please try again.'
end
local function setCore(show)
    pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,show)end)
    pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,show)end)
end
local function updateSelection()
    for id,b in pairs(skinButtons)do b.Selected.Visible=id==state.Skin;b.Border.Color=id==state.Skin and palette.Amber or palette.Line end
    for id,b in pairs(wrapButtons)do b.Selected.Visible=id==state.Wrap;b.Border.Color=id==state.Wrap and palette.Amber or palette.Line end
    avatarName.Text=Config.Skins[state.Skin].Name:upper()
    wrapName.Text=Config.Wraps[state.Wrap].Name:upper()..' FINISH'
    weaponName.Text=Weapons.Guns[state.Weapon].Name:upper()
    gui:SetAttribute('SelectedSkin',state.Skin);gui:SetAttribute('SelectedWrap',state.Wrap);gui:SetAttribute('SelectedWeapon',state.Weapon)
end
local function buildPreview()
    if hero then hero:Destroy()end
    hero=package.Assets.PreviewRig:Clone();hero.Name='AgentPreview'
    for _,ob in ipairs(hero:GetDescendants())do
        if ob:IsA('Motor6D') or ob:IsA('BaseScript') or ob:IsA('Animator') then ob:Destroy()
        elseif ob:IsA('BasePart')then ob.Anchored=true;ob.CanCollide=false;ob.CanTouch=false;ob.CanQuery=false end
    end
    hero.Parent=world
    local box,size=hero:GetBoundingBox()
    local shift=Vector3.new(-box.Position.X,-box.Position.Y+size.Y/2,-box.Position.Z)
    hero:PivotTo(CFrame.new(shift)*hero:GetPivot())
    local torso=hero:FindFirstChild('Torso') or hero:FindFirstChild('UpperTorso')
    local gun=RS.ReferenceWeapons.Viewmodels[state.Weapon]:Clone();gun.Name='WeaponPreview';gun.Parent=hero
    local grip=CFrame.new(.25,torso.Position.Y+.10,-.75)*CFrame.Angles(0,math.rad(65),math.rad(8))
    gun:PivotTo(grip)
    local function arm(name,shoulder,target)
        local a=hero:FindFirstChild(name);if not a then return end
        local length=(target-shoulder).Magnitude
        a.Size=Vector3.new(.86,length,.86)
        a.CFrame=CFrame.lookAt((shoulder+target)/2,target)*CFrame.Angles(math.pi/2,0,0)
    end
    arm('Right Arm',torso.Position+Vector3.new(1.05,.65,0),grip.Position)
    arm('Left Arm',torso.Position+Vector3.new(-1.05,.65,0),grip:PointToWorldSpace(Weapons.Guns[state.Weapon].Support))
    Cosmetics.ApplySkin(hero,state.Skin)
    Cosmetics.ApplyWeapon(gun,state.Wrap)
    for _,p in ipairs(hero:GetDescendants())do if p:IsA('BasePart')then p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false end end
    hero:SetAttribute('Skin',state.Skin);gun:SetAttribute('Wrap',state.Wrap)
    spin=hero:GetPivot()
    updateSelection()
end
function Menu.Select(action,value)
    if busy or not active then return false end
    local ok,err=request(action,value)
    if ok then buildPreview();message('EQUIPPED  /  '..(action=='Skin' and Config.Skins[value].Name or action=='Wrap' and Config.Wraps[value].Name or Weapons.Guns[value].Name):upper())
    else message(err)end
    return ok
end
function Menu.ShowPage(value)
    page=value=='LOCKER' and 'LOCKER' or 'HOME'
    home.Visible,locker.Visible=page=='HOME',page=='LOCKER'
    homeInfo.Visible=page=='HOME'
    heroTop.Text=page=='LOCKER' and 'YOUR STYLE. YOUR SIGNATURE.' or 'GEAR UP. DROP IN.'
    gui:SetAttribute('Page',page)
    message(page=='LOCKER' and 'Free starter cosmetics. Selections last for this server session.' or '')
end
function Menu.SetTab(value)
    tab=value=='WRAPS' and 'WRAPS' or 'SKINS'
    skinPanel.Visible,wrapPanel.Visible=tab=='SKINS',tab=='WRAPS'
    skinTab.TextColor3=tab=='SKINS' and palette.Amber or palette.Muted
    wrapTab.TextColor3=tab=='WRAPS' and palette.Amber or palette.Muted
    gui:SetAttribute('LockerTab',tab)
end
local function show(value)
    active=value;canvas.Visible=value;ingame.Visible=not value
    player:SetAttribute('MenuClientOpen',value)
    setCore(not value)
    if blur then blur.Size=value and 5 or 0 end
    if not value then
        local char=player.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=hum;cam.FieldOfView=72 end
        player.CameraMode=Enum.CameraMode.LockFirstPerson
    end
    UIS.MouseIconEnabled=value
    gui:SetAttribute('MenuOpen',value)
end
function Menu.Play()
    if busy or not active then return false end
    busy=true;playText.Text='DEPLOYING...';message('Connecting you to the city...')
    gui:SetAttribute('Deploying',true)
    local ok,err=request('Deploy')
    if ok then
        local deadline=os.clock()+10
        while (not player.Character or not player.Character:FindFirstChildOfClass('Humanoid')) and os.clock()<deadline do task.wait(.1)end
        if player.Character then
            fade.BackgroundTransparency=1
            TweenService:Create(fade,TweenInfo.new(.15),{BackgroundTransparency=0}):Play();task.wait(.15)
            show(false)
            TweenService:Create(fade,TweenInfo.new(.30),{BackgroundTransparency=1}):Play()
        else ok=false;err='Character is still loading. Try Play again.'end
    end
    if not ok then message(err)end
    busy=false;playText.Text='PLAY';gui:SetAttribute('Deploying',false)
    return ok
end
function Menu.Open()
    if active or busy then return false end
    busy=true;player:SetAttribute('MenuClientOpen',true)
    local ok,err=request('Menu')
    if ok then show(true);Menu.ShowPage('HOME');buildPreview()else player:SetAttribute('MenuClientOpen',false);message(err)end
    busy=false;return ok
end
function Menu.GetState()
    return {Open=active,Page=page,Tab=tab,Skin=state.Skin,Wrap=state.Wrap,Weapon=state.Weapon,Busy=busy,HasPreview=hero~=nil,HasCharacter=player.Character~=nil}
end
local function build()
    gui=new('ScreenGui',{Name='MainMenuUI',IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=50,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild('PlayerGui'))
    local backdrop=new('Frame',{Name='Backdrop',Size=UDim2.fromScale(1,1),BackgroundColor3=palette.Ink,BorderSizePixel=0,BackgroundTransparency=.20},gui)
    new('UIGradient',{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.45,.17),NumberSequenceKeypoint.new(1,.80)})},backdrop)
    canvas=frame('Canvas',0,0,1280,720,palette.Ink,gui,1)
    canvas.AnchorPoint,canvas.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
    scaler=new('UIScale',{Scale=1},canvas)
    text('BuildTag','OBW  /  FIELD TEST',76,30,500,24,12,palette.Muted,canvas,Enum.Font.Code)
    frame('TopLine',76,69,1128,1,palette.Line,canvas,.45)
    frame('BrandMark',76,90,34,4,palette.Amber,canvas)
    text('TitleTop','O BLAH',73,104,470,54,43,palette.Text,canvas,Enum.Font.GothamBlack)
    text('TitleBottom','WARFARE',72,152,480,76,65,palette.Amber,canvas,Enum.Font.GothamBlack)
    text('Tagline','MAKE YOUR MARK ON THE CITY.',77,228,430,24,12,palette.Muted,canvas,Enum.Font.GothamBold)
    local profile=frame('Profile',937,23,267,34,palette.Panel,canvas,.12)
    frame('Online',950-937,13,7,7,Color3.fromRGB(99,203,161),profile)
    local display=player.DisplayName or player.Name
    local user=text('PlayerName',display:upper(),30,0,222,34,12,palette.Text,profile,Enum.Font.GothamBold);user.TextTruncate=Enum.TextTruncate.AtEnd
    home=frame('Home',76,282,360,206,palette.Panel,canvas,1)
    local play=button('PlayButton','',0,0,360,78,home,palette.Amber)
    playText=text('PlayText','PLAY',24,8,230,44,32,palette.Ink,play,Enum.Font.GothamBlack)
    text('PlaySubtitle','DEPLOY TO MAIN STREET',25,47,285,20,10,palette.Ink,play,Enum.Font.GothamBold)
    text('PlayArrow','>',311,11,40,48,35,palette.Ink,play,Enum.Font.Gotham)
    link(play.Activated,function()Menu.Play()end)
    local lockerButton=button('LockerButton','',0,90,360,70,home,palette.Panel);stroke(lockerButton,palette.Line,.15)
    text('LockerTitle','LOCKER',24,7,270,34,25,palette.Text,lockerButton,Enum.Font.GothamBold)
    text('LockerSubtitle','CHARACTER SKINS  /  WEAPON WRAPS',25,39,290,20,10,palette.Muted,lockerButton,Enum.Font.GothamMedium)
    text('LockerArrow','>',316,17,30,34,24,palette.Muted,lockerButton)
    link(lockerButton.Activated,function()Menu.ShowPage('LOCKER')end)
    homeInfo=frame('FieldNotes',76,495,360,109,palette.Panel,canvas,.18);stroke(homeInfo,palette.Line,.6)
    text('FieldNotesTag','01  /  NO QUEUE. JUST PLAY.',17,10,325,22,11,palette.Amber,homeInfo,Enum.Font.Code)
    local desc=text('FieldNotesCopy','Five weapons. One city.\nPick your look, then drop straight in.',17,35,325,55,14,palette.Text,homeInfo)
    desc.TextWrapped=true;desc.TextYAlignment=Enum.TextYAlignment.Top
    locker=frame('Locker',76,270,386,348,palette.Panel,canvas,1)
    local back=button('BackButton','<  BACK',0,-24,104,28,locker,palette.Ink);back.TextSize=11
    link(back.Activated,function()Menu.ShowPage('HOME')end)
    skinTab=button('SkinsTab','CHARACTER',0,17,184,42,locker,palette.Panel)
    wrapTab=button('WrapsTab','GUN WRAPS',192,17,184,42,locker,palette.Panel)
    link(skinTab.Activated,function()Menu.SetTab('SKINS')end);link(wrapTab.Activated,function()Menu.SetTab('WRAPS')end)
    skinPanel=frame('SkinOptions',0,71,376,235,palette.Panel,locker,1)
    wrapPanel=frame('WrapOptions',0,71,376,235,palette.Panel,locker,1)
    for i,id in ipairs(Config.SkinOrder)do
        local def=Config.Skins[id]
        local b=button('Skin_'..id,'',0,(i-1)*56,376,48,skinPanel,palette.Panel)
        local border=stroke(b,palette.Line,.25);border.Name='Border'
        frame('Swatch',12,10,26,28,def.Torso,b)
        text('Name',def.Name:upper(),51,3,275,23,13,palette.Text,b,Enum.Font.GothamBold)
        text('Tag',def.Tag,51,24,275,17,9,palette.Muted,b,Enum.Font.Code)
        local selected=text('Selected','+',339,8,25,30,19,palette.Amber,b,Enum.Font.GothamBold)
        skinButtons[id]=b;link(b.Activated,function()Menu.Select('Skin',id)end)
    end
    for i,id in ipairs(Config.WrapOrder)do
        local def=Config.Wraps[id];local col=(i-1)%2;local row=math.floor((i-1)/2)
        local b=button('Wrap_'..id,'',col*192,row*77,184,67,wrapPanel,palette.Panel)
        local border=stroke(b,palette.Line,.25);border.Name='Border'
        frame('Swatch',12,12,32,43,def.Swatch,b)
        text('Name',def.Name:upper(),54,10,117,24,12,palette.Text,b,Enum.Font.GothamBold)
        text('Tag',id=='ORIGINAL' and 'FACTORY' or 'COSMETIC',54,35,116,17,9,palette.Muted,b,Enum.Font.Code)
        text('Selected','+',158,1,20,20,15,palette.Amber,b,Enum.Font.GothamBold)
        wrapButtons[id]=b;link(b.Activated,function()Menu.Select('Wrap',id)end)
    end
    text('LockerNote','WRAPS APPLY TO ALL FIVE WEAPONS.',0,309,380,21,10,palette.Muted,locker,Enum.Font.Code)
    heroTop=text('HeroOverline','GEAR UP. DROP IN.',604,102,585,26,11,palette.Muted,canvas,Enum.Font.Code)
    preview=new('ViewportFrame',{Name='AgentViewport',Position=UDim2.fromOffset(470,113),Size=UDim2.fromOffset(760,489),BackgroundTransparency=1,Ambient=Color3.fromRGB(135,146,158),LightColor=Color3.fromRGB(255,230,198),LightDirection=Vector3.new(-.7,-1,-1),BorderSizePixel=0},canvas)
    world=new('WorldModel',{Name='PreviewWorld'},preview)
    previewCam=new('Camera',{Name='PreviewCamera',CFrame=CFrame.lookAt(Vector3.new(4.5,3.8,-9.5),Vector3.new(0,2.95,0)),FieldOfView=42},preview)
    preview.CurrentCamera=previewCam
    local platform=new('Part',{Name='AgentPlatform',Shape=Enum.PartType.Cylinder,Size=Vector3.new(.1,5.8,5.8),CFrame=CFrame.new(0,-.08,0)*CFrame.Angles(0,0,math.pi/2),Color=Color3.fromRGB(29,43,57),Material=Enum.Material.Metal,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false},world)
    text('RotateHint','DRAG TO ROTATE',992,559,210,22,9,palette.Muted,canvas,Enum.Font.Code)
    frame('HeroAccent',602,590,36,3,palette.Amber,canvas)
    avatarName=text('SkinName','STREET PILOT',602,601,570,31,23,palette.Text,canvas,Enum.Font.GothamBold)
    wrapName=text('WrapName','ORIGINAL FINISH',603,635,300,22,10,palette.Amber,canvas,Enum.Font.Code)
    local prev=button('PreviousWeapon','<',1008,625,33,30,canvas,palette.Panel)
    local next=button('NextWeapon','>',1170,625,33,30,canvas,palette.Panel)
    weaponName=text('WeaponName','WALNUT AK',1046,626,120,28,10,palette.Text,canvas,Enum.Font.GothamBold)
    weaponName.TextXAlignment=Enum.TextXAlignment.Center;weaponName.TextScaled=true
    local function cycle(direction)
        local index=table.find(Weapons.Order,state.Weapon) or 1
        Menu.Select('Weapon',Weapons.Order[(index-1+direction)%#Weapons.Order+1])
    end
    link(prev.Activated,function()cycle(-1)end);link(next.Activated,function()cycle(1)end)
    frame('BottomLine',76,673,1128,1,palette.Line,canvas,.45)
    status=text('Status','',76,684,890,23,10,palette.Muted,canvas,Enum.Font.Code)
    text('Version','EARLY ACCESS  /  01',1017,684,185,23,10,palette.Muted,canvas,Enum.Font.Code)
    ingame=new('TextButton',{Name='OpenMenuButton',Position=UDim2.fromOffset(18,82),Size=UDim2.fromOffset(112,31),Text='MENU  [M]',TextSize=11,TextColor3=palette.Text,Font=Enum.Font.GothamBold,BackgroundColor3=palette.Ink,BackgroundTransparency=.18,BorderSizePixel=0,Visible=false},gui)
    link(ingame.Activated,function()Menu.Open()end)
    fade=new('Frame',{Name='Transition',Size=UDim2.fromScale(1,1),BackgroundColor3=palette.Ink,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20,Active=false},gui)
    local bridge=new('BindableFunction',{Name='MainMenuControl'},player:WaitForChild('PlayerScripts'))
    bridge.OnInvoke=function(action,value)
        if action=='Play'then return Menu.Play()elseif action=='Open'then return Menu.Open()
        elseif action=='Locker'then Menu.ShowPage('LOCKER');return true
        elseif action=='Tab'then Menu.SetTab(value);return true
        elseif action=='Skin' or action=='Wrap' or action=='Weapon'then return Menu.Select(action,value)end
        return Menu.GetState()
    end
    link(preview.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;lastX=input.Position.X end
    end)
    link(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    link(UIS.InputChanged,function(input)
        if dragging and active and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then yaw+= (input.Position.X-lastX)*.008;lastX=input.Position.X end
    end)
    -- The backdrop follows the same visibility as the logical canvas.
    link(canvas:GetPropertyChangedSignal('Visible'),function()backdrop.Visible=canvas.Visible end)
end
function Menu.Start()
    if started then return Menu end;started=true
    player:SetAttribute('MenuClientOpen',true)
    build();Menu.ShowPage('HOME');Menu.SetTab('SKINS');buildPreview();show(true)
    blur=new('BlurEffect',{Name='MainMenuBlur',Size=5},Lighting)
    task.spawn(function()
        local ok=request('State');if ok then buildPreview();if not state.InMenu then show(false)end end
    end)
    link(UIS.InputBegan,function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.M and not active then Menu.Open()
        elseif input.KeyCode==Enum.KeyCode.Escape and active and page=='LOCKER' then Menu.ShowPage('HOME')end
    end)
    RunService:BindToRenderStep('MainMenuPresentation',Enum.RenderPriority.Camera.Value+5,function()
        local cam=workspace.CurrentCamera;if not cam then return end
        scaler.Scale=math.min(cam.ViewportSize.X/1280,cam.ViewportSize.Y/720)
        if not active then return end
        UIS.MouseBehavior=Enum.MouseBehavior.Default;UIS.MouseIconEnabled=true
        cam.CameraType=Enum.CameraType.Scriptable
        local spawn=workspace:FindFirstChildWhichIsA('SpawnLocation')
        local origin=spawn and spawn.Position or Vector3.zero
        local t=os.clock()
        cam.CFrame=CFrame.lookAt(origin+Vector3.new(28+math.sin(t*.06)*4,12,28),origin+Vector3.new(0,5,-40))
        cam.FieldOfView=60
        if hero and spin then hero:PivotTo(CFrame.new(0,math.sin(t*1.6)*.025,0)*CFrame.Angles(0,yaw+math.sin(t*.4)*.025,0)*spin)end
    end)
    return Menu
end
return Menu

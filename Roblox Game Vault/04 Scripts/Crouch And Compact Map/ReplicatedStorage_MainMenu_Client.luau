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
    for id,b in pairs(skinButtons)do b:FindFirstChild('Selected').Visible=id==state.Skin;b:FindFirstChild('Border').Color=id==state.Skin and palette.Amber or palette.Line end
    for id,b in pairs(wrapButtons)do b:FindFirstChild('Selected').Visible=id==state.Wrap;b:FindFirstChild('Border').Color=id==state.Wrap and palette.Amber or palette.Line end
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
    local torso=hero:FindFirstChild('Torso') or hero:FindFirstChild('UpperTorso')
    -- Generated rigs can carry a 180-degree pivot. Canonical front is -Z.
    hero:PivotTo(CFrame.new(0,3,0)*torso.CFrame:Inverse()*hero:GetPivot())
    local gun=RS.ReferenceWeapons.Viewmodels[state.Weapon]:Clone();gun.Name='WeaponPreview';gun.Parent=hero
    local grip=CFrame.new(.66,torso.Position.Y-.22,-.95)*CFrame.Angles(0,math.rad(65),math.rad(8))
    gun:PivotTo(grip)
    local function segment(p,a,b,width)
        p.Size=Vector3.new(width,(b-a).Magnitude,width)
        p.CFrame=CFrame.lookAt((a+b)/2,b)*CFrame.Angles(math.pi/2,0,0)
    end
    local function arm(name,shoulder,elbow,target)
        local a=hero:FindFirstChild(name);if not a then return end
        segment(a,shoulder,elbow,.88)
        local fore=Instance.new('Part');fore.Name=name..' Forearm';fore.Material=Enum.Material.SmoothPlastic;fore.Parent=hero
        segment(fore,elbow,target,.82)
        local hand=Instance.new('Part');hand.Name=name..' Hand';hand.Size=Vector3.new(.72,.48,.72)
        hand.Material=Enum.Material.SmoothPlastic;hand.CFrame=grip*CFrame.new(grip:PointToObjectSpace(target));hand.Parent=hero
    end
    arm('Right Arm',torso.Position+Vector3.new(1.05,.65,0),torso.Position+Vector3.new(1.4,-.25,-.32),grip.Position)
    arm('Left Arm',torso.Position+Vector3.new(-1.05,.65,0),torso.Position+Vector3.new(-1.35,-.3,-.4),grip:PointToWorldSpace(Weapons.Guns[state.Weapon].Support))
    Cosmetics.ApplySkin(hero,state.Skin)
    -- R6 preview uses separate hands instead of the body skin's simple hand patches.
    for _,p in ipairs(hero.MenuSkinDetails:GetChildren())do if p.Name:find('HandPatch')then p:Destroy()end end
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
    heroTop.Text=page=='LOCKER' and 'LOCKER  /  LIVE PREVIEW' or 'YOUR LOADOUT'
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

-- Client-only presentation: restore the map's real lighting before deployment.
local lightingSnapshot
local lightingFields={'ClockTime','Brightness','Ambient','OutdoorAmbient','ExposureCompensation','FogEnd','FogStart'}
local function menuLighting(on)
    if on and not lightingSnapshot then
        lightingSnapshot={Properties={},Effects={}}
        for _,k in ipairs(lightingFields)do lightingSnapshot.Properties[k]=Lighting[k]end
        for _,o in ipairs(Lighting:GetChildren())do
            if o:IsA('Atmosphere')then
                lightingSnapshot.Effects[o]={Density=o.Density,Haze=o.Haze,Glare=o.Glare}
                o.Density=.14;o.Haze=.4;o.Glare=0
            elseif o:IsA('ColorCorrectionEffect') or o:IsA('DepthOfFieldEffect')then
                lightingSnapshot.Effects[o]={Enabled=o.Enabled};o.Enabled=false
            end
        end
        Lighting.ClockTime=14.5;Lighting.Brightness=2
        Lighting.Ambient=Color3.fromRGB(123,131,143);Lighting.OutdoorAmbient=Color3.fromRGB(145,150,160)
        Lighting.ExposureCompensation=.18;Lighting.FogStart=0;Lighting.FogEnd=100000
    elseif not on and lightingSnapshot then
        for k,v in pairs(lightingSnapshot.Properties)do Lighting[k]=v end
        for o,props in pairs(lightingSnapshot.Effects)do if o.Parent then for k,v in pairs(props)do o[k]=v end end end
        lightingSnapshot=nil
    end
end

local function show(value)
    menuLighting(value)
    active=value;canvas.Visible=value;ingame.Visible=not value
    player:SetAttribute('MenuClientOpen',value)
    setCore(not value)
    if blur then blur.Size=0 end
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
    return {Open=active,Page=page,Tab=tab,Skin=state.Skin,Wrap=state.Wrap,Weapon=state.Weapon,Busy=busy,HasPreview=hero~=nil,HasCharacter=player.Character~=nil and player.Character.Parent~=nil}
end

local function icon(parent,kind,x,y,size,color)
    local holder=frame('Icon_'..kind,x,y,size,size,palette.Ink,parent,1)
    local function line(name,px,py,w,h,angle)
        local l=frame(name,px*size,py*size,w*size,h*size,color,holder)
        l.Rotation=angle or 0;return l
    end
    if kind=='PLAY' then
        local t=text('Triangle','▶',0,-2,size,size+4,size*.9,color,holder,Enum.Font.GothamBold);t.TextXAlignment=Enum.TextXAlignment.Center
    elseif kind=='LOCKER' then
        local box=frame('Box',size*.16,size*.06,size*.67,size*.87,color,holder)
        frame('Inset',size*.25,size*.18,size*.49,size*.15,palette.Panel,holder)
        frame('Handle',size*.64,size*.46,size*.05,size*.2,palette.Panel,holder)
    elseif kind=='WRAPS' then
        line('Barrel',.12,.28,.76,.18,-30);line('Grip',.45,.45,.16,.48,28);line('Magazine',.66,.38,.12,.32,28)
    elseif kind=='HOME' then
        line('Roof',.15,.18,.5,.12,-38);line('Roof2',.43,.18,.5,.12,38);line('House',.25,.35,.52,.48)
        frame('Door',size*.44,size*.57,size*.15,size*.3,palette.Panel,holder)
    elseif kind=='TARGET' then
        local circle=frame('Circle',size*.14,size*.14,size*.72,size*.72,color,holder,1);new('UICorner',{CornerRadius=UDim.new(1,0)},circle);stroke(circle,color,0)
        line('Vertical',.47,0,.06,1);line('Horizontal',0,.47,1,.06)
    elseif kind=='PERSON' then
        local h=frame('Head',size*.35,size*.05,size*.3,size*.3,color,holder);new('UICorner',{CornerRadius=UDim.new(1,0)},h)
        local body=frame('Body',size*.17,size*.43,size*.66,size*.47,color,holder);new('UICorner',{CornerRadius=UDim.new(.25,0)},body)
    elseif kind=='SETTINGS' then
        for i=1,3 do line('Track'..i,.10,.15+i*.18,.8,.055);line('Knob'..i,i==2 and .32 or .64,.09+i*.18,.11,.18)end
    else
        local t=text('Glyph',kind=='HELP' and '?' or 'R',0,-1,size,size,size*.9,color,holder,Enum.Font.GothamBold);t.TextXAlignment=Enum.TextXAlignment.Center
    end
    return holder
end
local function build()
    gui=new('ScreenGui',{Name='MainMenuUI',IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=50,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild('PlayerGui'))
    -- Keep the live aerial map visible; shade just the left navigation for contrast.
    local backdrop=new('Frame',{Name='Backdrop',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,9,15),BorderSizePixel=0,BackgroundTransparency=.06},gui)
    new('UIGradient',{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.25),NumberSequenceKeypoint.new(.37,.70),NumberSequenceKeypoint.new(.65,1),NumberSequenceKeypoint.new(1,1)})},backdrop)
    canvas=frame('Canvas',0,0,1280,720,palette.Ink,gui,1)
    canvas.AnchorPoint,canvas.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
    scaler=new('UIScale',{Scale=1},canvas)
    local title=text('GameTitle','O BLAH WARFARE',69,68,665,61,43,palette.Text,canvas,Enum.Font.GothamBlack)
    title.TextStrokeColor3=Color3.fromRGB(8,11,15);title.TextStrokeTransparency=.12
    text('Edition','M A I N  S T R E E T   /   F I E L D  T E S T',74,124,570,20,11,palette.Text,canvas,Enum.Font.GothamBold).TextStrokeTransparency=.4
    local rank=frame('RankPanel',74,160,416,53,palette.Panel,canvas,.24);stroke(rank,Color3.fromRGB(157,169,179),.40)
    local badge=frame('Badge',10,8,36,36,palette.Amber,rank)
    local number=text('Rank','1',0,0,36,36,24,palette.Ink,badge,Enum.Font.GothamBlack);number.TextXAlignment=Enum.TextXAlignment.Center
    text('RankName','RECRUIT',57,5,185,21,13,palette.Text,rank,Enum.Font.GothamBold)
    text('RankNote','FIELD TEST  •  NO XP YET',230,7,175,18,9,palette.Muted,rank,Enum.Font.GothamBold)
    frame('RankTrack',57,33,347,5,Color3.fromRGB(69,78,86),rank)
    frame('RankAccent',57,33,8,5,palette.Amber,rank)
    local profile=frame('Profile',949,42,263,43,palette.Panel,canvas,.20);stroke(profile,palette.Line,.25)
    frame('Online',12,18,7,7,Color3.fromRGB(111,222,169),profile)
    local user=text('PlayerName',(player.DisplayName or player.Name):upper(),30,0,219,43,13,palette.Text,profile,Enum.Font.GothamBold);user.TextTruncate=Enum.TextTruncate.AtEnd
    home=frame('Home',74,239,416,222,palette.Panel,canvas,1)
    local function nav(name,label,kind,y,callback)
        local b=button(name,'',0,y,416,64,home,Color3.fromRGB(30,34,39));b.BackgroundTransparency=.12
        stroke(b,Color3.fromRGB(156,164,173),.45)
        new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(246,246,246),Color3.fromRGB(120,128,139)),Rotation=20},b)
        frame('Highlight',0,0,4,64,palette.Amber,b)
        icon(b,kind,20,15,32,palette.Text)
        local labelOb=text('Label',label,69,4,320,55,31,palette.Text,b,Enum.Font.GothamBold);labelOb.TextStrokeTransparency=.55
        text('Arrow','›',380,9,25,46,32,palette.Text,b)
        link(b.Activated,callback);return b,labelOb
    end
    local play
    play,playText=nav('PlayButton','PLAY','PLAY',0,function()Menu.Play()end)
    nav('LockerButton','LOCKER','LOCKER',75,function()Menu.ShowPage('LOCKER');Menu.SetTab('SKINS')end)
    nav('WrapsButton','GUN WRAPS','WRAPS',150,function()Menu.ShowPage('LOCKER');Menu.SetTab('WRAPS')end)
    homeInfo=button('FeatureCard','',74,481,416,142,canvas,Color3.fromRGB(9,34,74));stroke(homeInfo,Color3.fromRGB(114,193,244),.10)
    new('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(8,20,40),Color3.fromRGB(32,114,204)),Rotation=-18},homeInfo)
    for i=1,5 do
        local slash=frame('Diagonal'..i,224+i*23,-15,18,187,Color3.fromRGB(91,183,244),homeInfo,.72);slash.Rotation=28
    end
    homeInfo.ClipsDescendants=true
    local promo=new('ViewportFrame',{Name='FeatureWeapon',Position=UDim2.fromOffset(172,-8),Size=UDim2.fromOffset(258,153),BackgroundTransparency=1,Ambient=Color3.fromRGB(160,170,190),LightColor=Color3.fromRGB(225,241,255),LightDirection=Vector3.new(-1,-1,-1)},homeInfo)
    local pw=new('WorldModel',{Name='WeaponWorld'},promo)
    local pg=RS.ReferenceWeapons.Viewmodels.W1:Clone();pg.Parent=pw
    pg:PivotTo(CFrame.Angles(0,math.rad(67),math.rad(-18)))
    Cosmetics.ApplyWeapon(pg,'COBALT')
    for _,p in ipairs(pg:GetDescendants())do if p:IsA('BasePart')then p.Anchored=true;p.CanCollide=false end end
    local cf,sz=pg:GetBoundingBox()
    local pc=new('Camera',{CFrame=CFrame.lookAt(cf.Position+Vector3.new(1,1,-5),cf.Position),FieldOfView=38},promo);promo.CurrentCamera=pc
    local tag=frame('FeatureTag',14,11,119,21,palette.Amber,homeInfo)
    text('Tag','STARTER COLLECTION',8,0,112,21,9,palette.Ink,tag,Enum.Font.GothamBold)
    text('FeatureTitle','MAKE IT\nYOUR OWN.',14,39,222,63,25,palette.Text,homeInfo,Enum.Font.GothamBlack)
    text('FeatureCta','6 FREE FINISHES   ›',15,112,210,20,12,Color3.fromRGB(176,220,255),homeInfo,Enum.Font.GothamBold)
    link(homeInfo.Activated,function()Menu.ShowPage('LOCKER');Menu.SetTab('WRAPS')end)
    locker=frame('Locker',74,239,416,384,palette.Panel,canvas,.08);stroke(locker,palette.Line,.10)
    local back=button('BackButton','‹  BACK',12,9,97,30,locker,Color3.fromRGB(29,34,41));back.TextSize=12
    link(back.Activated,function()Menu.ShowPage('HOME')end)
    text('LockerTitle','YOUR LOCKER',132,9,268,30,20,palette.Text,locker,Enum.Font.GothamBold)
    skinTab=button('SkinsTab','CHARACTER',12,50,192,42,locker,palette.Ink)
    wrapTab=button('WrapsTab','GUN WRAPS',212,50,192,42,locker,palette.Ink)
    link(skinTab.Activated,function()Menu.SetTab('SKINS')end);link(wrapTab.Activated,function()Menu.SetTab('WRAPS')end)
    skinPanel=frame('SkinOptions',12,105,392,235,palette.Panel,locker,1)
    wrapPanel=frame('WrapOptions',12,105,392,235,palette.Panel,locker,1)
    for i,id in ipairs(Config.SkinOrder)do
        local def=Config.Skins[id]
        local b=button('Skin_'..id,'',0,(i-1)*56,392,48,skinPanel,palette.Ink)
        local border=stroke(b,palette.Line,.15);border.Name='Border'
        frame('Swatch',12,9,28,30,def.Torso,b)
        frame('Accent',33,9,7,30,def.Accent,b)
        text('Name',def.Name:upper(),53,3,275,23,13,palette.Text,b,Enum.Font.GothamBold)
        text('Tag',def.Tag,53,24,275,17,9,palette.Muted,b,Enum.Font.Code)
        text('Selected','✓',355,8,25,30,19,palette.Amber,b,Enum.Font.GothamBold)
        skinButtons[id]=b;link(b.Activated,function()Menu.Select('Skin',id)end)
    end
    for i,id in ipairs(Config.WrapOrder)do
        local def=Config.Wraps[id];local col=(i-1)%2;local row=math.floor((i-1)/2)
        local b=button('Wrap_'..id,'',col*200,row*77,192,67,wrapPanel,palette.Ink)
        local border=stroke(b,palette.Line,.15);border.Name='Border'
        frame('Swatch',12,12,33,43,def.Swatch,b)
        local strip=frame('Stripe',31,12,8,43,def.Secondary or palette.Ink,b);strip.Rotation=12
        text('Name',def.Name:upper(),55,12,117,24,12,palette.Text,b,Enum.Font.GothamBold)
        text('Tag',id=='ORIGINAL' and 'FACTORY' or 'FREE FINISH',55,35,116,17,9,palette.Muted,b,Enum.Font.Code)
        text('Selected','✓',167,0,20,22,15,palette.Amber,b,Enum.Font.GothamBold)
        wrapButtons[id]=b;link(b.Activated,function()Menu.Select('Wrap',id)end)
    end
    text('LockerNote','EQUIPPED IN GAME  /  SESSION COSMETICS',13,350,390,22,10,palette.Muted,locker,Enum.Font.Code)
    heroTop=text('HeroOverline','YOUR LOADOUT',647,89,460,26,12,palette.Text,canvas,Enum.Font.GothamBold);heroTop.TextStrokeTransparency=.3
    preview=new('ViewportFrame',{Name='AgentViewport',Position=UDim2.fromOffset(506,76),Size=UDim2.fromOffset(694,558),BackgroundTransparency=1,Ambient=Color3.fromRGB(151,157,168),LightColor=Color3.fromRGB(255,240,218),LightDirection=Vector3.new(-.6,-1,-1),BorderSizePixel=0},canvas)
    world=new('WorldModel',{Name='PreviewWorld'},preview)
    previewCam=new('Camera',{Name='PreviewCamera',CFrame=CFrame.lookAt(Vector3.new(3.4,3.8,-8.1),Vector3.new(0,2.95,0)),FieldOfView=43},preview)
    preview.CurrentCamera=previewCam
    text('RotateHint','DRAG CHARACTER TO ROTATE',829,605,358,22,10,palette.Text,canvas,Enum.Font.GothamBold).TextStrokeTransparency=.25
    local nameplate=frame('Nameplate',620,631,582,38,palette.Panel,canvas,.24);stroke(nameplate,palette.Line,.35)
    avatarName=text('SkinName','STREET PILOT',12,0,270,38,17,palette.Text,nameplate,Enum.Font.GothamBold)
    wrapName=text('WrapName','ORIGINAL FINISH',284,0,285,38,11,palette.Amber,nameplate,Enum.Font.GothamBold);wrapName.TextXAlignment=Enum.TextXAlignment.Right
    local prev=button('PreviousWeapon','‹',829,566,31,30,canvas,palette.Panel)
    local next=button('NextWeapon','›',1168,566,31,30,canvas,palette.Panel)
    weaponName=text('WeaponName','WALNUT AK',869,568,288,28,14,palette.Text,canvas,Enum.Font.GothamBold)
    weaponName.TextXAlignment=Enum.TextXAlignment.Center;weaponName.TextStrokeTransparency=.2
    local function cycle(direction)
        local index=table.find(Weapons.Order,state.Weapon) or 1
        Menu.Select('Weapon',Weapons.Order[(index-1+direction)%#Weapons.Order+1])
    end
    link(prev.Activated,function()cycle(-1)end);link(next.Activated,function()cycle(1)end)
    -- Functional right-side shortcuts, like the compact icon rail in the reference.
    for i,item in ipairs({{'PERSON','Character'}, {'WRAPS','Gun Wraps'}, {'ROTATE','Reset Pose'}})do
        local b=button('Rail'..i,'',1220,273+(i-1)*52,47,46,canvas,palette.Panel);b.BackgroundTransparency=.13;stroke(b,palette.Line,.3)
        icon(b,item[1],10,9,27,palette.Text)
        link(b.MouseEnter,function()message(item[2])end)
        link(b.Activated,function()
            if i==3 then yaw=0;message('PREVIEW ROTATION RESET')
            else Menu.ShowPage('LOCKER');Menu.SetTab(i==1 and 'SKINS' or 'WRAPS')end
        end)
    end
    local toolbar=frame('Toolbar',0,680,1280,40,Color3.fromRGB(22,24,28),canvas)
    frame('ToolbarTop',0,0,1280,1,Color3.fromRGB(154,159,166),toolbar,.6)
    local function tool(name,kind,x,fn)
        local b=button(name,'',x,4,43,32,toolbar,Color3.fromRGB(22,24,28))
        icon(b,kind,10,5,23,palette.Text);link(b.Activated,fn);return b
    end
    tool('Home','HOME',66,function()Menu.ShowPage('HOME')end)
    tool('Locker','LOCKER',114,function()Menu.ShowPage('LOCKER');Menu.SetTab('SKINS')end)
    tool('Loadout','WRAPS',162,function()Menu.ShowPage('LOCKER');Menu.SetTab('WRAPS')end)
    status=text('Status','MAIN STREET  /  READY TO DEPLOY',320,0,744,40,10,palette.Text,toolbar,Enum.Font.GothamBold)
    text('Version','BUILD 01',1122,0,102,40,10,palette.Muted,toolbar,Enum.Font.Code)
    local modal=frame('InfoModal',480,204,432,270,palette.Panel,canvas);modal.Visible=false;modal.ZIndex=8;stroke(modal,palette.Amber,.15)
    local modalTitle=text('Heading','CONTROLS',22,13,360,36,23,palette.Text,modal,Enum.Font.GothamBold)
    local modalBody=text('Body','',22,60,386,145,16,palette.Text,modal)
    modalBody.TextWrapped=true;modalBody.TextYAlignment=Enum.TextYAlignment.Top
    local close=button('Close','CLOSE',22,220,110,32,modal,palette.Ink);link(close.Activated,function()modal.Visible=false end)
    local toggle=button('CameraMotion','',147,220,262,32,modal,palette.Ink)
    local motion=true
    toggle.Text='CAMERA MOTION: ON'
    link(toggle.Activated,function()motion=not motion;gui:SetAttribute('CameraMotion',motion);toggle.Text='CAMERA MOTION: '..(motion and 'ON' or 'OFF')end)
    local function info(settings)
        modal.Visible=not modal.Visible;modalTitle.Text=settings and 'MENU SETTINGS' or 'CONTROLS'
        modalBody.Text=settings and 'Bird’s-eye view of the live Main Street map.\n\nTurn off camera movement for a still overview. Skin and wrap choices last for this server session.' or 'W A S D   Move     •     SPACE   Jump\nSHIFT   Sprint     •     C / CTRL   Crouch\nSHIFT + C   Slide\nLMB   Fire     •     RMB   Aim\nR   Reload     •     F   Inspect\n1–5   Switch weapons\nM   Return to menu'
        toggle.Visible=settings
    end
    tool('Controls','HELP',210,function()info(false)end)
    tool('Settings','SETTINGS',258,function()info(true)end)
    gui:SetAttribute('CameraMotion',true)
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
        if dragging and active and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then yaw+=(input.Position.X-lastX)*.008;lastX=input.Position.X end
    end)
    link(canvas:GetPropertyChangedSignal('Visible'),function()backdrop.Visible=canvas.Visible;if not canvas.Visible then modal.Visible=false end end)
end

function Menu.Start()
    if started then return Menu end;started=true
    player:SetAttribute('MenuClientOpen',true)
    build();Menu.ShowPage('HOME');Menu.SetTab('SKINS');buildPreview();show(true)
    blur=new('BlurEffect',{Name='MainMenuBlur',Size=0},Lighting)
    task.spawn(function()
        if workspace.StreamingEnabled then pcall(function()player:RequestStreamAroundAsync(Vector3.new(5,4,0),8)end)end
    end)
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
        local width=cam.ViewportSize.X/scaler.Scale
        canvas.AnchorPoint=Vector2.new(0,.5);canvas.Position=UDim2.fromScale(0,.5);canvas.Size=UDim2.fromOffset(width,720)
        canvas.Profile.Position=UDim2.fromOffset(width-331,42)
        preview.Position=UDim2.fromOffset(width-774,76)
        heroTop.Position=UDim2.fromOffset(width-633,89)
        canvas.Nameplate.Position=UDim2.fromOffset(width-660,631)
        canvas.RotateHint.Position=UDim2.fromOffset(width-451,605)
        canvas.PreviousWeapon.Position=UDim2.fromOffset(width-451,566)
        canvas.NextWeapon.Position=UDim2.fromOffset(width-112,566)
        weaponName.Position=UDim2.fromOffset(width-411,568)
        for i=1,3 do canvas['Rail'..i].Position=UDim2.fromOffset(width-60,273+(i-1)*52)end
        canvas.Toolbar.Size=UDim2.fromOffset(width,40);canvas.Toolbar.ToolbarTop.Size=UDim2.fromOffset(width,1)
        canvas.Toolbar.Version.Position=UDim2.fromOffset(width-158,0)
        status.Size=UDim2.fromOffset(width-530,40)
        canvas.InfoModal.Position=UDim2.fromOffset(width/2-216,204)
        if not active then return end
        UIS.MouseBehavior=Enum.MouseBehavior.Default;UIS.MouseIconEnabled=true
        cam.CameraType=Enum.CameraType.Scriptable
        local t=os.clock()
        local motion=gui:GetAttribute('CameraMotion')
        local orbit=motion and math.sin(t*.025)*.065 or 0
        local centre=Vector3.new(5,4,0)
        local offset=CFrame.Angles(0,orbit,0):VectorToWorldSpace(Vector3.new(35,210,145))
        cam.CFrame=CFrame.lookAt(centre+offset,centre)
        cam.FieldOfView=60
        gui:SetAttribute('BackgroundMode','LiveBirdsEye')
        if hero and spin then hero:PivotTo(CFrame.new(0,math.sin(t*1.6)*.025,0)*CFrame.Angles(0,yaw+math.sin(t*.4)*.025,0)*spin)end
    end)
    return Menu
end
return Menu

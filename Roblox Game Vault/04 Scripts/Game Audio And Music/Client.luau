-- Independent, client-only sound presentation. No gameplay authority or new remotes.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local C = require(script.Parent.Config)
local M = {}
local player = Players.LocalPlayer
local started = false
local connections, characters, voices, altered, counts, pending = {}, {}, {}, setmetatable({}, {__mode="k"}), {}, {}
local random = Random.new()
local effects, music, musicGroup, gui, bridge
local emit = script.Parent:WaitForChild("Emit",10)
local reloadVoice, reloadGeneration = nil, 0
local previousAmmo, previousWeapon, previousReload, previousAim, previousInspect
local weaponChangedAt = -10
local muted, musicVolume = false, C.MusicVolume
local templates, loadStatus = {}, {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function alive()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
end
local function count(name)
    counts[name] = (counts[name] or 0) + 1
end
local function stopVoice(s)
    if s then
        voices[s] = nil
        if s.Parent then s:Destroy() end
    end
end
local function trimVoices()
    local n, oldest, when = 0, nil, math.huge
    for s, t in voices do
        if not s.Parent then voices[s] = nil
        else
            n += 1
            if t < when then oldest, when = s, t end
        end
    end
    if n >= C.MaxVoices then stopVoice(oldest) end
end
local function play(name, parent, volume, pitch, duration, category)
    if not started or not templates[name] then return nil end
    trimVoices()
    local s = templates[name]:Clone()
    s.Name = "Audio_" .. (category or name)
    s:SetAttribute("AudioPresentation", true)
    s.SoundGroup = effects
    s.Volume = C.Assets[name].Volume * (volume or 1)
    s.PlaybackSpeed = pitch or random:NextNumber(.96, 1.04)
    s.RollOffMode = Enum.RollOffMode.InverseTapered
    s.RollOffMinDistance = 8
    s.RollOffMaxDistance = category == "Footstep" and C.FootstepDistance or C.GunshotDistance
    s.Parent = parent or SoundService
    voices[s] = os.clock()
    s:Play()
    count(category or name)
    local cleanup = task.delay(duration or math.clamp(s.TimeLength / s.PlaybackSpeed + .15, 1, 7), function()
        pending[s] = nil
        stopVoice(s)
    end)
    pending[s] = cleanup
    return s
end
local function cancelReload()
    reloadGeneration += 1
    stopVoice(reloadVoice)
    reloadVoice = nil
end
local function beginReload()
    cancelReload()
    local id = player:GetAttribute("FPSWeaponId")
    local w = C.Weapons[id]
    local specModule = RS:FindFirstChild("ReferenceWeapons")
    local specs = specModule and require(specModule.WeaponConfig).Guns
    local spec = specs and specs[id]
    if not w or not spec then return end
    if emit then emit:FireServer("Reload") end
    local generation = reloadGeneration
    local template = templates[w.Reload]
    local pitch = template and template.TimeLength > 0 and math.clamp(template.TimeLength / spec.ReloadTime, .65, 1.5) or 1
    if id == "W5" then
        reloadVoice = play(w.Reload, nil, 1, 1, nil, "Reload")
        -- Match the existing shell-insertion pose rather than looping after cancellation.
        for _,fraction in {.30, .52, .70} do
            task.delay(spec.ReloadTime * fraction, function()
                if started and reloadGeneration == generation and alive() and player:GetAttribute("FPSReloading") then
                    play(w.Reload, nil, .7, 1.04, nil, "ShellInsert")
                end
            end)
        end
    else
        reloadVoice = play(w.Reload, nil, 1, pitch, spec.ReloadTime, "Reload")
    end
    task.delay(spec.ReloadTime * .84, function()
        if started and reloadGeneration == generation and alive() and player:GetAttribute("FPSReloading") then
            play("Bolt", nil, .65, id == "W5" and .85 or 1.1, nil, "ReloadBolt")
        end
    end)
end
local function weaponChanged()
    cancelReload()
    previousWeapon = player:GetAttribute("FPSWeaponId")
    previousAmmo = player:GetAttribute("FPSAmmo")
    weaponChangedAt = os.clock()
    previousReload, previousAim, previousInspect = false, false, false
    if previousWeapon and previousWeapon ~= "" and alive() then
        play("Cloth", nil, 1, 1.15, .5, "Equip")
        if emit then emit:FireServer("Equip") end
    end
end
local function ammoChanged()
    local id = player:GetAttribute("FPSWeaponId")
    local ammo = player:GetAttribute("FPSAmmo")
    if id ~= previousWeapon then weaponChanged() end
    if type(ammo) ~= "number" then previousAmmo = nil; return end
    if previousAmmo and ammo < previousAmmo and os.clock()-weaponChangedAt>.25 and alive() then
        local w = C.Weapons[id]
        if w then
            if not w.ExistingShot then
                play(w.Shot, nil, 1, w.Pitch * random:NextNumber(.97, 1.03), nil, "Shot_" .. id)
                if emit then emit:FireServer("Shot") end
            end
            if id == "W5" then
                local char = player.Character
                task.delay(.20, function()
                    if started and alive() and player.Character == char and player:GetAttribute("FPSWeaponId") == id then
                        play("Bolt", nil, .9, .85, nil, "Pump")
                    end
                end)
            elseif not w.ExistingShot then
                task.delay(.18, function() if started and alive() then play("Shell", nil, .5, random:NextNumber(1.1, 1.3), nil, "Casing") end end)
            end
        end
    end
    previousAmmo = ammo
end
local function stashSound(s)
    if not altered[s] then altered[s] = {Id = s.SoundId, Volume = s.Volume, Group = s.SoundGroup} end
end
local nativeNames = {Running=true, Jumping=true, Landing=true, Climbing=true, FreeFalling=true, Died=true}
local function routeSound(s)
    if not s:IsA("Sound") or s:GetAttribute("AudioPresentation") then return end
    local replacement = C.Legacy[s.SoundId]
    if replacement then
        stashSound(s)
        s.SoundId = C.Assets[replacement].Id
        s.SoundGroup = effects
    elseif s.Name:match("^ClaudeAKShot") then
        stashSound(s)
        s.SoundId = C.Assets.RifleShot.Id
        s.SoundGroup = effects
    end
    if s.Name:match("^ClaudeAKShot") and not s:GetAttribute("AudioCountHook") then
        s:SetAttribute("AudioCountHook", true)
        connect(s.Played, function() if started then count("Shot_W1") end end)
    end
end
local function removeCharacter(p)
    local rec=characters[p]
    if not rec then return end
    rec.Active=false
    for _,c in rec.Links do c:Disconnect() end
    characters[p]=nil
end
local function addCharacter(p, char)
    removeCharacter(p)
    task.spawn(function()
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if not started or not root or not hum or p.Character ~= char then return end
        local rec = {Player=p, Char=char, Root=root, Hum=hum, Last=root.Position, Distance=0, LastStep=-10, Active=true, Slide=false, Links={}}
        characters[p] = rec
        local function link(signal,fn)
            local c=signal:Connect(fn);table.insert(rec.Links,c);return c
        end
        local function suppress(s)
            if s:IsA("Sound") and nativeNames[s.Name] then
                stashSound(s);s.Volume=0
                link(s:GetPropertyChangedSignal("Volume"),function() if started and rec.Active and s.Volume~=0 then s.Volume=0 end end)
            end
        end
        for _,s in root:GetChildren() do suppress(s) end
        link(root.ChildAdded, suppress)
        link(hum.StateChanged, function(_, state)
            if not started or not rec.Active then return end
            if p:GetAttribute("InMenu") or p:GetAttribute("MenuClientOpen") then return end
            if state == Enum.HumanoidStateType.Jumping then
                play("Cloth", root, .6, 1.2, .45, "Jump")
            elseif state == Enum.HumanoidStateType.Landed then
                play("StepConcrete", root, 1.6, .84, .65, "Land")
            end
        end)
        link(hum.Died, function()
            if rec.Active then play("Cloth", root, .8, .7, .9, "Death"); rec.Active=false end
        end)
    end)
end
local function observePlayer(p)
    connect(p.CharacterAdded, function(char) addCharacter(p, char) end)
    connect(p.CharacterRemoving, function() removeCharacter(p) end)
    if p.Character then addCharacter(p, p.Character) end
end
local function movementTick(dt)
    local camera=workspace.CurrentCamera
    if not camera then return end
    for p,rec in characters do
        local root,hum=rec.Root,rec.Hum
        if rec.Active and root.Parent and hum.Health>0 then
            local position=root.Position
            local delta=Vector3.new(position.X-rec.Last.X,0,position.Z-rec.Last.Z).Magnitude
            rec.Last=position
            local state=p:GetAttribute("MovementState")
            local inMenu=p:GetAttribute("InMenu") or p:GetAttribute("MenuClientOpen")
            local distance=(camera.CFrame.Position-position).Magnitude
            local slide=state=="Sliding" and not inMenu
            if slide and not rec.Slide and distance<100 then
                play("Cloth",root,1.7,.78,.82,"Slide")
            end
            rec.Slide=slide
            if not inMenu and not slide and distance<100 and delta>.01 and delta<8 then
                rec.Distance += delta
                local stride=state=="Sprinting" and 5.2 or state=="Crouching" and 5 or 4.5
                if rec.Distance>=stride and os.clock()-rec.LastStep>.17 then
                    local params=RaycastParams.new()
                    params.FilterType=Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances={rec.Char}
                    params.RespectCanCollide=true
                    local hit=workspace:Raycast(position,Vector3.new(0,-hum.HipHeight-3.7,0),params)
                    local humanoidState=hum:GetState()
                    local airborne=humanoidState==Enum.HumanoidStateType.Jumping or humanoidState==Enum.HumanoidStateType.Freefall
                    if hit and not airborne then
                        local material=hit.Material
                        local soft=material==Enum.Material.Grass or material==Enum.Material.Ground or material==Enum.Material.Mud or material==Enum.Material.Sand or material==Enum.Material.LeafyGrass
                        local pitch=material==Enum.Material.Metal and 1.25 or material==Enum.Material.WoodPlanks and .88 or 1
                        local volume=state=="Sprinting" and 1.2 or state=="Crouching" and .55 or 1
                        play(soft and "StepGrass" or "StepConcrete",root,volume,pitch*random:NextNumber(.94,1.06),.65,"Footstep")
                        rec.LastStep=os.clock()
                    end
                    rec.Distance=0
                end
            else rec.Distance=0 end
        end
    end
end
local function updateMusic()
    if not music then return end
    music.Volume = muted and 0 or musicVolume
    if gui then
        local button=gui:FindFirstChild("Music")
        if button then button.Text=muted and "MUSIC OFF  [F8]" or ("MUSIC "..math.floor(musicVolume*100+.5).."%  [F8]") end
    end
end
function M.SetMusicMuted(value)
    muted=value==true
    updateMusic()
end
function M.SetMusicVolume(value)
    if type(value)~="number" or value~=value then return end
    musicVolume=math.clamp(value,0,1)
    updateMusic()
end
function M.GetStats()
    local n=0;for s in voices do if s.Parent then n+=1 end end
    local links=#connections;for _,rec in characters do links+=#rec.Links end
    return {Started=started,Counts=table.clone(counts),Voices=n,Connections=links,Loaded=table.clone(loadStatus),
        MusicLoaded=music and music.IsLoaded,MusicPlaying=music and music.IsPlaying,MusicVolume=music and music.Volume,
        MusicId=music and music.SoundId,Muted=muted,ReloadActive=reloadVoice and reloadVoice.Parent~=nil}
end
function M.Start()
    if started then return M end
    started=true
    effects=SoundService:WaitForChild("GameAudioEffects",10)
    musicGroup=SoundService:WaitForChild("GameAudioMusic",10)
    music=SoundService:WaitForChild("BackgroundMusic",10)
    assert(effects and musicGroup and music,"Audio mix objects missing")
    local assets=script.Parent:WaitForChild("Assets")
    for name in C.Assets do
        local s=assets:FindFirstChild(name)
        if s and s:IsA("Sound") then templates[name]=s end
    end
    gui=Instance.new("ScreenGui");gui.Name="AudioPresentation";gui.ResetOnSpawn=false;gui.DisplayOrder=35
    local button=Instance.new("TextButton");button.Name="Music";button.Size=UDim2.fromOffset(148,28);button.Position=UDim2.new(0,14,0,70)
    button.BackgroundColor3=Color3.fromRGB(17,20,27);button.BackgroundTransparency=.18;button.BorderSizePixel=0
    button.TextColor3=Color3.fromRGB(210,216,224);button.Font=Enum.Font.GothamMedium;button.TextSize=11;button.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,6);corner.Parent=button
    gui.Parent=player:WaitForChild("PlayerGui")
    connect(button.Activated,function() M.SetMusicMuted(not muted) end)
    connect(UIS.InputBegan,function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.F8 then M.SetMusicMuted(not muted)
        elseif input.UserInputType==Enum.UserInputType.MouseButton1 and alive() and player:GetAttribute("FPSAmmo")==0 and not player:GetAttribute("FPSReloading") then
            play("Bolt",nil,.45,1.4,.12,"DryFire")
        end
    end)
    updateMusic()
    music.Looped=true
    music:Play()
    task.spawn(function()
        local list={};for _,s in templates do table.insert(list,s) end
        pcall(function() ContentProvider:PreloadAsync(list,function(id,status) loadStatus[id]=status.Name end) end)
        if not started then return end
        if not music.IsLoaded then
            music.SoundId=C.Assets[C.MusicFallback].Id
            music:Play()
        end
    end)
    weaponChanged()
    previousAmmo=player:GetAttribute("FPSAmmo")
    connect(player:GetAttributeChangedSignal("FPSWeaponId"),weaponChanged)
    connect(player:GetAttributeChangedSignal("FPSAmmo"),ammoChanged)
    connect(player:GetAttributeChangedSignal("FPSReloading"),function()
        local now=player:GetAttribute("FPSReloading")==true
        if now and not previousReload and alive() then beginReload() elseif not now then cancelReload() end
        previousReload=now
    end)
    connect(player:GetAttributeChangedSignal("FPSAiming"),function()
        local now=player:GetAttribute("FPSAiming")==true
        if now~=previousAim and alive() then play("Cloth",nil,.28,1.25,.26,"Aim") end
        previousAim=now
    end)
    connect(player:GetAttributeChangedSignal("FPSInspecting"),function()
        local now=player:GetAttribute("FPSInspecting")==true
        if now and not previousInspect and alive() then play("Cloth",nil,.6,.95,.7,"Inspect") end
        previousInspect=now
    end)
    for _,s in SoundService:GetDescendants() do routeSound(s) end
    connect(SoundService.DescendantAdded,routeSound)
    connect(workspace.DescendantAdded,routeSound)
    for _,p in Players:GetPlayers() do observePlayer(p) end
    connect(Players.PlayerAdded,observePlayer)
    connect(Players.PlayerRemoving,removeCharacter)
    local accumulator=0
    connect(RunService.Heartbeat,function(dt) accumulator+=dt;if accumulator>=.04 then movementTick(accumulator);accumulator=0 end end)
    if emit then
        connect(emit.OnClientEvent,function(shooter,kind,id)
            if shooter==player or typeof(shooter)~="Instance" or not shooter:IsA("Player") then return end
            local char=shooter.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            local w=C.Weapons[id]
            if not root or not w or (workspace.CurrentCamera and (workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude>300) then return end
            if kind=="Shot" and not w.ExistingShot then
                play(w.Shot,root,1,w.Pitch,nil,"RemoteShot_"..id)
            elseif kind=="Reload" then play(w.Reload,root,.7,1,nil,"RemoteReload")
            elseif kind=="Equip" then play("Cloth",root,.7,1.1,.5,"RemoteEquip") end
        end)
    end
    local ak=RS:FindFirstChild("ClaudeAK")
    if ak and ak:FindFirstChild("HitConfirm") then
        connect(ak.HitConfirm.OnClientEvent,function(headshot,killed)
            local pitch=killed and .75 or headshot and 1.6 or 1.3
            play("UIClick",nil,killed and 2.0 or 1.2,pitch,.32,killed and "Elimination" or headshot and "Headshot" or "Hit")
        end)
    end
    local pg=player:WaitForChild("PlayerGui")
    local buttons=setmetatable({},{__mode="k"})
    local function hookButton(b)
        if b:IsA("GuiButton") and not buttons[b] then
            buttons[b]=true
            connect(b.Activated,function() play("UIClick",nil,1,1,.2,"UI") end)
        end
    end
    for _,b in pg:GetDescendants() do hookButton(b) end
    connect(pg.DescendantAdded,hookButton)
    bridge=Instance.new("BindableFunction");bridge.Name="AudioPresentationControl"
    bridge.OnInvoke=function(action,value)
        if action=="Mute" then M.SetMusicMuted(value)
        elseif action=="Volume" then M.SetMusicVolume(value)
        elseif action=="Stop" then M.Destroy() end
        return M.GetStats()
    end
    bridge.Parent=player:WaitForChild("PlayerScripts")
    return M
end
function M.Destroy()
    if not started then return end
    started=false
    cancelReload()
    for _,c in connections do c:Disconnect() end
    connections={}
    for p in characters do removeCharacter(p) end
    characters={}
    for s in voices do stopVoice(s) end
    for s,t in pending do pcall(task.cancel,t) end
    pending={}
    for s,old in altered do
        if s.Parent then
            s.SoundId=old.Id;s.Volume=old.Volume;s.SoundGroup=old.Group
            s:SetAttribute("AudioCountHook",nil)
        end
    end
    altered=setmetatable({}, {__mode="k"})
    if music then music:Stop() end
    if gui then gui:Destroy();gui=nil end
    if bridge then bridge:Destroy();bridge=nil end
end
return M


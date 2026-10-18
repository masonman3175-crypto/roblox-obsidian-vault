-- Client-only presentation. Damage/hit authority remains outside this controller.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local ContextActionService = game:GetService('ContextActionService')
local StarterGui = game:GetService('StarterGui')
local Config = require(script.Parent.WeaponConfig)
local Controller = {}
-- Claude's AK hook: guns with CustomFx skip the stock effects and fire this signal instead.
local shotSignal = Instance.new('BindableEvent')
Controller.Shot = shotSignal.Event
local player = Players.LocalPlayer
local package = script.Parent
local camera
local started = false
local activeTool, spec, model, hud, nameText, ammoText, statusText
local parts, arms, connections = {}, {}, {}
local hooked = setmetatable({}, {__mode = 'k'})
local ammo = setmetatable({}, {__mode = 'k'})
local hidden = setmetatable({}, {__mode = 'k'})
local trigger, aiming, sprinting = false, false, false
local reloadStart, inspectStart, equipStart = nil, nil, 0
local lastShot, shotAt = -100, -100
local recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
local yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
local elapsed, crossBloom, generation = 0, 0, 0
local crossLines, casings, characterConnections = {}, {}, {}
local baseFov = 72
local controlBridge
local viewScene, viewCamera, testing = nil, nil, false
local skin = Color3.fromRGB(222, 172, 116)
local renderName = 'ReferenceFPS_Viewmodel'
local identity = CFrame.identity

local function smooth(t)
    t = math.clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end
local function mix(a, b, t) return a:Lerp(b, smooth(t)) end
local function bump(t, startTime, peakTime, endTime)
    if t < startTime or t > endTime then return 0 end
    if t <= peakTime then return smooth((t - startTime) / (peakTime - startTime)) end
    return 1 - smooth((t - peakTime) / (endTime - peakTime))
end
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function part(name, size, color, parent)
    local p = Instance.new('Part')
    p.Name, p.Size, p.Color = name, size, color
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.CastShadow, p.Material = false, Enum.Material.SmoothPlastic
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function label(name, size, pos, text, parent)
    local l = Instance.new('TextLabel')
    l.Name, l.Size, l.Position = name, size, pos
    l.BackgroundTransparency = 1
    l.TextColor3, l.Font, l.TextSize = Color3.fromRGB(235, 240, 245), Enum.Font.GothamMedium, 18
    l.TextStrokeTransparency = .65
    l.Text, l.TextXAlignment = text, Enum.TextXAlignment.Right
    l.Parent = parent
    return l
end
local function createHUD()
    local old = player.PlayerGui:FindFirstChild('ReferenceWeaponHUD')
    if old then old:Destroy() end
    hud = Instance.new('ScreenGui')
    hud.Name, hud.ResetOnSpawn, hud.IgnoreGuiInset = 'ReferenceWeaponHUD', false, true
    hud.DisplayOrder = 8
    hud.Parent = player:WaitForChild('PlayerGui')
    -- A transparent live 3D viewmodel pass keeps the Blender colors legible at night.
    local viewport = Instance.new('ViewportFrame')
    viewport.Name, viewport.Size, viewport.BackgroundTransparency = 'ViewmodelViewport', UDim2.fromScale(1, 1), 1
    viewport.BorderSizePixel = 0
    viewport.Ambient, viewport.LightColor = Color3.fromRGB(135, 135, 140), Color3.fromRGB(240, 235, 225)
    viewport.LightDirection = Vector3.new(-1, -1.5, -1)
    viewport.Parent = hud
    viewScene = Instance.new('WorldModel'); viewScene.Name, viewScene.Parent = 'WorldModel', viewport
    viewCamera = Instance.new('Camera'); viewCamera.Name, viewCamera.Parent = 'ViewmodelCamera', viewport
    viewport.CurrentCamera = viewCamera
    nameText = label('WeaponName', UDim2.fromOffset(300, 25), UDim2.new(1, -330, 1, -122), '', hud)
    nameText.TextSize = 15
    ammoText = label('Ammo', UDim2.fromOffset(250, 45), UDim2.new(1, -280, 1, -96), '', hud)
    ammoText.Font, ammoText.TextSize = Enum.Font.GothamBold, 32
    statusText = label('Status', UDim2.fromOffset(330, 25), UDim2.new(1, -360, 1, -49), '', hud)
    statusText.TextSize = 12
    statusText.TextColor3 = Color3.fromRGB(167, 184, 199)
    local center = Instance.new('Frame')
    center.Name, center.Size, center.Position = 'Reticle', UDim2.fromOffset(1, 1), UDim2.fromScale(.5, .5)
    center.BackgroundTransparency = 1
    center.Parent = hud
    local dot = Instance.new('Frame')
    dot.Name, dot.Size, dot.AnchorPoint = 'CenterDot', UDim2.fromOffset(3, 3), Vector2.new(.5, .5)
    dot.BorderSizePixel, dot.BackgroundColor3 = 0, Color3.fromRGB(255, 199, 94)
    dot.Parent = center
    local corner = Instance.new('UICorner'); corner.CornerRadius = UDim.new(1, 0); corner.Parent = dot
    for i, dir in ipairs({Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)}) do
        local f = Instance.new('Frame')
        f.Name, f.AnchorPoint, f.BorderSizePixel = 'Line' .. i, Vector2.new(.5, .5), 0
        f.Size = i % 2 == 0 and UDim2.fromOffset(7, 2) or UDim2.fromOffset(2, 7)
        f.BackgroundColor3 = Color3.fromRGB(240, 244, 248)
        f.Parent = center
        local stroke = Instance.new('UIStroke'); stroke.Color = Color3.new(0, 0, 0); stroke.Transparency = .45; stroke.Parent = f
        table.insert(crossLines, {Frame = f, Direction = dir, Stroke = stroke})
    end
    if ReplicatedStorage:FindFirstChild('GameplayPresentation') then
        nameText.Visible=false;ammoText.Visible=false;statusText.Visible=false;center.Visible=false
    end
    if UserInputService.TouchEnabled then
        for i, action in ipairs({'FIRE', 'AIM', 'RELOAD'}) do
            local button = Instance.new('TextButton')
            button.Name, button.Text = action, action
            button.Size, button.Position = UDim2.fromOffset(78, 45), UDim2.new(1, -90, .50, (i - 1) * 53)
            button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(30, 40, 50), Color3.new(1, 1, 1)
            button.BackgroundTransparency = .25
            if action=='FIRE'then button.Text='FIRE';button.Size=UDim2.fromOffset(74,74);button.Position=UDim2.new(1,-102,1,-190);local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=button;local outline=Instance.new('UIStroke');outline.Color=Color3.new(1,1,1);outline.Thickness=2;outline.Parent=button end
            if action=='AIM'then button.Position=UDim2.new(1,-190,1,-135)elseif action=='RELOAD'then button.Position=UDim2.new(1,-102,1,-100)end
            button.Parent = hud
            connect(button.Activated, function()
                if action == 'FIRE' then Controller.Fire() elseif action == 'AIM' then Controller.SetAim(not aiming) else Controller.Reload() end
            end)
        end
    end
end
local function updateHUD()
    local function publish(key,value)if player:GetAttribute(key)~=value then player:SetAttribute(key,value)end end
    local current=activeTool and ammo[activeTool]
    publish('FPSWeaponId',spec and spec.Id or '')
    publish('FPSAmmo',current and current.Current or nil)
    publish('FPSReserve',current and current.Reserve or nil)
    publish('FPSReloading',reloadStart~=nil)
    publish('FPSInspecting',inspectStart~=nil)
    local a = activeTool and ammo[activeTool]
    if a and spec then
        nameText.Text = string.upper(spec.Name)
        ammoText.Text = string.format('%02d  /  %03d', a.Current, a.Reserve)
        statusText.Text = reloadStart and 'RELOADING' or (inspectStart and 'INSPECTING' or 'R  RELOAD    RMB  AIM    F  INSPECT')
    else
        nameText.Text, ammoText.Text, statusText.Text = '', '', ''
    end
end
local function clear()
    generation += 1
    if camera then camera.CFrame *= CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() end
    if model then model:Destroy() end
    model, activeTool, spec = nil, nil, nil
    parts, arms = {}, {}
    trigger, aiming, reloadStart, inspectStart = false, false, nil, nil
    recoil, recoilVelocity, lastCameraKick, aimAlpha = 0, 0, 0, 0
    yawRecoil, yawVelocity, lastCameraYaw, shotCounter = 0, 0, 0, 0
    if camera then camera.FieldOfView = baseFov end
    updateHUD()
end
local function armParts(side)
    local result = {}
    local handScale = spec and spec.Pistol and .82 or 1
    result.Upper = part(side .. 'UpperArm', Vector3.new(.39, 1, .40), skin, model)
    result.Lower = part(side .. 'Forearm', Vector3.new(.36, 1, .38), skin, model)
    result.Palm = part(side .. 'Hand', Vector3.new(.34, .43, .37) * handScale, skin, model)
    result.Cuff = part(side .. 'Sleeve', Vector3.new(.42, .35, .44), (player:GetAttribute('EquippedSleeveColor') or Color3.fromRGB(31, 38, 46)), model)
    result.Fingers = {}
    for i = 1, 4 do
        result.Fingers[i] = part(side .. 'Finger' .. i, Vector3.new(.105, .12, .28) * handScale, skin, model)
    end
    result.Thumb = part(side .. 'Thumb', Vector3.new(.15, .23, .20) * handScale, skin, model)
    return result
end
local function segment(ob, a, b, width)
    local length = (b - a).Magnitude
    ob.Size = Vector3.new(width, math.max(.02, length), width * 1.06)
    ob.CFrame = CFrame.lookAt((a + b) * .5, b) * CFrame.Angles(math.pi * .5, 0, 0)
end
local function solveArm(limb, shoulder, handFrame, pole, side)
    local target = handFrame.Position
    local delta = target - shoulder
    local distance = math.max(delta.Magnitude, .001)
    local direction = delta / distance
    local upper, lower = 1.22, 1.26
    local d = math.clamp(distance, .12, upper + lower - .005)
    local adjacent = (upper * upper - lower * lower + d * d) / (2 * d)
    local height = math.sqrt(math.max(0, upper * upper - adjacent * adjacent))
    local bend = pole - shoulder
    bend = bend - direction * bend:Dot(direction)
    if bend.Magnitude < .01 then bend = Vector3.yAxis:Cross(direction) end
    local elbow = shoulder + direction * adjacent + bend.Unit * height
    segment(limb.Upper, shoulder, elbow, .39)
    segment(limb.Lower, elbow, target, .36)
    limb.Cuff.CFrame = CFrame.lookAt(shoulder:Lerp(elbow, .22), elbow) * CFrame.Angles(math.pi / 2, 0, 0)
    limb.Palm.CFrame = handFrame
    local handScale = spec and spec.Pistol and .82 or 1
    for i, finger in ipairs(limb.Fingers) do
        finger.CFrame = handFrame * CFrame.new(Vector3.new((i - 2.5) * .075, -.03, -.18) * handScale) * CFrame.Angles(-.40, 0, 0)
    end
    limb.Thumb.CFrame = handFrame * CFrame.new(Vector3.new(side * .19, .04, -.07) * handScale) * CFrame.Angles(0, 0, side * .48)
end
local function equip(tool)
    if activeTool == tool then return end
    clear()
    spec = Config.Guns[tool:GetAttribute('ReferenceWeaponId')]
    if not spec then return end
    local template = package.Viewmodels:FindFirstChild(spec.Id)
    if not template then warn('Missing imported weapon template ' .. spec.Id); return end
    activeTool = tool
    if not ammo[tool] then ammo[tool] = {Current = spec.MagazineSize, Reserve = spec.Reserve} end
    camera = workspace.CurrentCamera
    model = template:Clone()
    model.Name = 'ReferenceFPS_Active'
    model.Parent = viewScene
    local menuPackage = ReplicatedStorage:FindFirstChild('MainMenu')
    if menuPackage and menuPackage:FindFirstChild('Cosmetics') then require(menuPackage.Cosmetics).ApplyWeapon(model, player:GetAttribute('CosmeticWrap') or 'ORIGINAL') end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA('BasePart') then
            p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
            if p ~= model.PrimaryPart then
                table.insert(parts, {Part = p, Rest = p.CFrame, Component = p:GetAttribute('Component') or 'Body'})
            end
        end
    end
    -- Claude's guns with CustomArms carry their own posed hand meshes.
    if not spec.CustomArms then arms.Left, arms.Right = armParts('Left'), armParts('Right') end
    equipStart = os.clock()
    model:SetAttribute('WeaponId', spec.Id)
    model:SetAttribute('Pose', 'Equip')
    updateHUD()
end
local function effectPart(name, size, color, frame)
    local p = part(name, size, color, workspace)
    p.CFrame = frame
    p.Material = Enum.Material.Neon
    return p
end
local function muzzleEffects()
    if not model then return end
    local root = model.PrimaryPart.CFrame
    local muzzle = root * CFrame.new(spec.Muzzle)
    local flash = effectPart('ReferenceMuzzleFlash', Vector3.new(.09, .09, .32), Color3.fromRGB(255, 210, 115), muzzle * CFrame.new(0, 0, -.09))
    flash.Shape = Enum.PartType.Ball
    local light = Instance.new('PointLight'); light.Brightness, light.Range, light.Color = 3, 8, flash.Color; light.Parent = flash
    Debris:AddItem(flash, .045)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, model}
    local origin, direction = camera.CFrame.Position, camera.CFrame.LookVector * 400
    local hit = workspace:Raycast(origin, direction, params)
    local target = hit and hit.Position or origin + direction
    local delta = target - muzzle.Position
    local trace = effectPart('ReferenceTracer', Vector3.new(.015, .015, math.min(delta.Magnitude, 150)), Color3.fromRGB(255, 220, 130), CFrame.lookAt(muzzle.Position, target) * CFrame.new(0, 0, -math.min(delta.Magnitude, 150) / 2))
    trace.Transparency = .3
    Debris:AddItem(trace, .045)
    local casing = part('ReferenceEjectedCasing', Vector3.new(.06, .13, .06), Color3.fromRGB(196, 145, 57), workspace)
    casing.Shape, casing.Material = Enum.PartType.Cylinder, Enum.Material.Metal
    casing.CFrame = root * CFrame.new(spec.Bolt + Vector3.new(.13, 0, 0))
    table.insert(casings, {Part = casing, Frame = casing.CFrame, Age = 0, Velocity = root.RightVector * 4 + Vector3.yAxis * 2.2})
    if #casings > 16 then table.remove(casings, 1).Part:Destroy() end
end
function Controller.Fire()
    if sprinting then player:SetAttribute('MovementFireInterrupt',os.clock());sprinting=false end
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return false end
    if not activeTool or not model or not spec or reloadStart or sprinting then return false end
    local now, a = os.clock(), ammo[activeTool]
    if now - equipStart < .40 or now - lastShot < 60 / spec.RPM then return false end
    if a.Current <= 0 then Controller.Reload(); return false end
    inspectStart = nil
    lastShot, shotAt = now, now
    a.Current -= 1
    recoilVelocity += spec.Kick * 65
    shotCounter += 1
    yawVelocity += math.rad(spec.RecoilYaw or .3) * math.sin(shotCounter * 2.399963) * 28
    crossBloom = math.min(crossBloom + 7, 22)
    if spec.CustomFx then shotSignal:Fire(spec, model, aiming) else muzzleEffects() end
    updateHUD()
    return true
end
function Controller.Trigger(value)
    if value then
        if trigger then return false end
        trigger=true
        return Controller.Fire()
    end
    trigger=false
    return true
end
function Controller.Reload()
    local a = activeTool and ammo[activeTool]
    if not a or not spec or reloadStart or a.Current == spec.MagazineSize or a.Reserve == 0 then return false end
    reloadStart, inspectStart, aiming, trigger = os.clock(), nil, false, false
    updateHUD()
    return true
end
function Controller.Inspect()
    if not activeTool or reloadStart then return false end
    inspectStart, aiming = os.clock(), false
    return true
end
function Controller.SetAim(value)
    if player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then aiming = false; return end
    aiming = value == true and activeTool ~= nil and reloadStart == nil
    if aiming then sprinting, inspectStart = false, nil end
end
function Controller.GetState()
    local a = activeTool and ammo[activeTool]
    return {
        WeaponId = spec and spec.Id, Ammo = a and a.Current, Reserve = a and a.Reserve,
        Aiming = aiming, Reloading = reloadStart ~= nil, Inspecting = inspectStart ~= nil,
        Pose = model and model:GetAttribute('Pose'), FirstPerson = player.CameraMode.Name,
        Meshes = #parts, HasArms = arms.Left ~= nil and arms.Right ~= nil,
        CameraFov = camera and camera.FieldOfView,
        RecoilPitchDegrees = math.deg(lastCameraKick), RecoilYawDegrees = math.deg(lastCameraYaw),
        WeaponKick = recoil,TapOnly=true,TriggerHeld=trigger,
    }
end
local function render(dt)
    dt = math.min(dt, .05)
    elapsed += dt
    camera = workspace.CurrentCamera
    if not camera then return end
    local inMenu = player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen')
    if hud then hud.Enabled = not inMenu end
    if inMenu then trigger=false;aiming=false;player:SetAttribute('FPSAiming',false);return end
    sprinting=player:GetAttribute('MovementState')=='Sprinting'
    if player:GetAttribute('MovementState')=='Sliding' then aiming=false end
    if player:GetAttribute('FPSAiming')~=aiming then player:SetAttribute('FPSAiming',aiming)end
    if player:GetAttribute('FPSReloading')~=(reloadStart~=nil) then player:SetAttribute('FPSReloading',reloadStart~=nil)end
    if player:GetAttribute('FPSInspecting')~=(inspectStart~=nil) then player:SetAttribute('FPSInspecting',inspectStart~=nil)end
    -- Character and world-held weapon remain visible to other players, hidden only here.
    local character = player.Character
    if character then
        for _, ob in ipairs(character:GetDescendants()) do
            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = player:GetAttribute('ThirdPersonView')==false and 1 or 0 end
        end
    end
    for i = #casings, 1, -1 do
        local c = casings[i]; c.Age += dt
        if c.Age > .9 then c.Part:Destroy(); table.remove(casings, i) else
            c.Velocity -= Vector3.yAxis * dt * 18
            c.Frame += c.Velocity * dt
            c.Part.CFrame = c.Frame * CFrame.Angles(c.Age * 9, c.Age * 7, c.Age * 4)
            c.Part.Transparency = math.max(0, (c.Age - .55) / .35)
        end
    end
    if not model or not activeTool or not spec then return end
    if model.Parent ~= viewScene then model.Parent = viewScene end
    local now = os.clock()
    -- Tap-only input: holding a mouse, touch, or trigger never repeats shots.
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local moving = humanoid and humanoid.MoveDirection.Magnitude or 0
    local reloading = reloadStart ~= nil
    local r = reloading and math.clamp((now - reloadStart) / spec.ReloadTime, 0, 1) or 0
    if reloading and r >= 1 then
        local a = ammo[activeTool]
        local count = math.min(spec.MagazineSize - a.Current, a.Reserve)
        a.Current, a.Reserve = a.Current + count, a.Reserve - count
        reloadStart, reloading, r = nil, false, 0
        updateHUD()
    end
    local inspect = inspectStart and (now - inspectStart) / 2.2 or 0
    if inspect >= 1 then inspectStart, inspect = nil, 0; updateHUD() end
    aimAlpha += ((aiming and not reloading and not sprinting and 1 or 0) - aimAlpha) * (1 - math.exp(-dt * 15))
    camera.FieldOfView += ((baseFov + (player:GetAttribute('MovementFovOffset') or 0) * (1-aimAlpha) + (spec.AimFov - baseFov) * aimAlpha) - camera.FieldOfView) * (1 - math.exp(-dt * 18))
    recoilVelocity += (-150 * recoil - 20 * recoilVelocity) * dt
    recoil += recoilVelocity * dt
    yawVelocity += (-150 * yawRecoil - 20 * yawVelocity) * dt
    yawRecoil += yawVelocity * dt
    local kick = math.clamp(recoil * (spec.CameraRecoil or .75) * (1 - .18 * aimAlpha), 0, math.rad(7))
    local yaw = math.clamp(yawRecoil * (1 - .18 * aimAlpha), -math.rad(1.2), math.rad(1.2))
    camera.CFrame = camera.CFrame * CFrame.Angles(lastCameraKick, lastCameraYaw, 0):Inverse() * CFrame.Angles(kick, yaw, 0)
    lastCameraKick, lastCameraYaw = kick, yaw
    local aimPosition = Vector3.new(-spec.Aim.X, -spec.Aim.Y, -(spec.SightDistance or .90) - spec.Aim.Z)
    local stance = spec.Hip:Lerp(CFrame.new(aimPosition), aimAlpha)
    local delta = UserInputService:GetMouseDelta()
    local sway = CFrame.Angles(math.clamp(-delta.Y * .00055, -.025, .025), math.clamp(-delta.X * .00055, -.025, .025), 0)
    local bob = CFrame.new(math.sin(elapsed * 8) * .018 * moving, math.cos(elapsed * 16) * .015 * moving, 0)
    local breathe = CFrame.new(0, math.sin(elapsed * 2) * .004, 0)
    local draw = 1 - smooth((now - equipStart) / .45)
    local reloadPose = math.sin(r * math.pi)
    local inspectPose = math.sin(math.pi * math.clamp(inspect, 0, 1))
    local sprintPose=sprinting and moving>.1 and 1 or 0
    if player:GetAttribute('MovementState')=='Sliding' then sprintPose=.7 end
    local visualKick = math.clamp(recoil, 0, .24)
    local pullback = (spec.Pullback or .1) * math.clamp(visualKick / .10, 0, 1.5)
    local action = CFrame.new(-.12 * reloadPose, -.12 * reloadPose - .9 * draw - .2 * sprintPose - .015 * visualKick, .12 * reloadPose + .28 * draw + pullback)
        * CFrame.Angles(-visualKick * 1.05 + .25 * draw - .3 * sprintPose, .09 * reloadPose + .32 * inspectPose + yawRecoil * .45, -.30 * reloadPose - .48 * inspectPose - visualKick * .12)
    local base = camera.CFrame * stance * breathe * bob * sway * action
    viewCamera.CFrame, viewCamera.FieldOfView = camera.CFrame, camera.FieldOfView
    model.PrimaryPart.CFrame = base
    local magDrop = bump(r, .10, .33, .72) * .90
    local boltPull = bump(r, .78, .84, .94) * .20
    local age = now - shotAt
    local fireBolt = age >= 0 and age < .11 and math.sin(age / .11 * math.pi) * .15 or 0
    local pumpPull = spec.Shotgun and bump(age, .10, .24, .48) * .29 or 0
    local motion = {
        Body = identity,
        Magazine = CFrame.new(.03 * magDrop, -magDrop, .08 * magDrop) * CFrame.Angles(0, 0, -.14 * magDrop),
        Bolt = CFrame.new(0, 0, boltPull + fireBolt),
        Trigger = CFrame.new(0, 0, age < .10 and .025 or 0),
        Pump = CFrame.new(0, 0, pumpPull + (spec.Shotgun and bump(r, .78, .87, .97) * .26 or 0)),
    }
    for _, p in ipairs(parts) do p.Part.CFrame = base * (motion[p.Component] or identity) * p.Rest end
    local left = spec.Support
    if spec.Shotgun then
        left += Vector3.new(0, 0, motion.Pump.Position.Z)
        if reloading then
            local insertion = bump(r, .10, .30, .76)
            left = mix(left, Vector3.new(.21, .23, -.21), insertion)
        end
    elseif reloading then
        local mag = motion.Magazine:PointToWorldSpace(spec.Magazine) + Vector3.new(-.12, -.10, 0)
        if r < .20 then left = mix(spec.Support, mag, r / .20)
        elseif r < .73 then left = mag
        elseif r < .85 then left = mix(mag, spec.Bolt + Vector3.new(.1, 0, boltPull), (r - .73) / .12)
        else left = mix(spec.Bolt, spec.Support, (r - .85) / .15) end
    end
    local rightFrame = base * CFrame.new(.02, -.01, 0) * CFrame.Angles(-.27, 0, 0)
    local leftFrame = base * CFrame.new(left) * CFrame.Angles(spec.Pistol and -.27 or .25, 0, spec.Pistol and -.4 or -.9)
    local cam = camera.CFrame
    if arms.Right then
        solveArm(arms.Right, cam:PointToWorldSpace(Vector3.new(.84, -.99, .19)), rightFrame, cam:PointToWorldSpace(Vector3.new(1.4, -1.6, -.3)), 1)
        solveArm(arms.Left, cam:PointToWorldSpace(Vector3.new(-.78, -.99, .19)), leftFrame, cam:PointToWorldSpace(Vector3.new(-.85, -1.7, -.4)), -1)
    end
    model:SetAttribute('Pose', reloading and 'Reload' or (inspectStart and 'Inspect' or (draw > .01 and 'Equip' or (aimAlpha > .8 and 'ADS' or (age < .13 and 'Fire' or 'Idle')))))
    model:SetAttribute('Ammo', ammo[activeTool].Current)
    crossBloom *= math.exp(-dt * 10)
    local gap = 8 + crossBloom + moving * 3
    for _, item in ipairs(crossLines) do
        item.Frame.Position = UDim2.fromOffset(item.Direction.X * gap, item.Direction.Y * gap)
        item.Frame.BackgroundTransparency = aimAlpha * .9
        item.Stroke.Transparency = .45 + aimAlpha * .5
    end
end
local function hookTool(tool)
    if not tool:IsA('Tool') or not tool:GetAttribute('ReferenceWeaponId') or hooked[tool] then return end
    hooked[tool] = true
    connect(tool.Equipped, function() equip(tool) end)
    connect(tool.Unequipped, function() if activeTool == tool then clear() end end)
    connect(tool.Activated, function() if not testing then Controller.Fire() end end)
    connect(tool.Deactivated, function() trigger = false end)
    if tool.Parent == player.Character then equip(tool) end
end
local function hookCharacter(character)
    clear()
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
    -- Neutral tan bare arms match the supplied first-person reference instead of yellow test-avatar limbs.
    skin = player:GetAttribute('EquippedHandColor') or Color3.fromRGB(222, 172, 116)
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    characterConnections = {character.ChildAdded:Connect(hookTool)}
    for _, child in ipairs(character:GetChildren()) do hookTool(child) end
    task.spawn(function()
        local humanoid = character:WaitForChild('Humanoid', 10)
        local backpack = player:WaitForChild('Backpack', 10)
        if not humanoid or not backpack or character ~= player.Character then return end
        local preferred = Config.Guns[player:GetAttribute('PreferredWeapon') or 'W1'] or Config.Guns.W1
        local ak = backpack:FindFirstChild(preferred.Name) or backpack:WaitForChild(preferred.Name, 8)
        if ak and character == player.Character and humanoid.Health > 0 then humanoid:EquipTool(ak) end
        connect(humanoid.Died, clear)
    end)
end
function Controller.Start()
    if started then return Controller end
    started = true
    camera = workspace.CurrentCamera
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
    UserInputService.MouseIconEnabled = false
    createHUD()
    -- Local-only diagnostics/commands; no RemoteEvents or server damage authority.
    controlBridge = Instance.new('BindableFunction')
    controlBridge.Name = 'ReferenceFPSControl'
    controlBridge.OnInvoke = function(action, value)
        if action == 'TestMode' then
            testing, trigger, sprinting, aiming = value == true, false, false, false
            if testing then
                ContextActionService:BindActionAtPriority('ReferenceFPS_TestKeys', function() return Enum.ContextActionResult.Sink end, false, 4000,
                    Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five)
            else ContextActionService:UnbindAction('ReferenceFPS_TestKeys') end
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not testing)
            return true
        elseif action == 'Fire' then return Controller.Fire()
        elseif action == 'Press' then return Controller.Trigger(true)
        elseif action == 'Release' then return Controller.Trigger(false)
        elseif action == 'Reload' then return Controller.Reload()
        elseif action == 'Inspect' then return Controller.Inspect()
        elseif action == 'Aim' then Controller.SetAim(value); return true end
        return Controller.GetState()
    end
    controlBridge.Parent = player:WaitForChild('PlayerScripts')
    local backpack = player:WaitForChild('Backpack')
    for _, child in ipairs(backpack:GetChildren()) do hookTool(child) end
    connect(backpack.ChildAdded, hookTool)
    connect(player.CharacterAdded, hookCharacter)
    if player.Character then hookCharacter(player.Character) end
    connect(UserInputService.InputBegan, function(input, processed)
        if processed or testing or player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(true)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(true)
        elseif input.KeyCode == Enum.KeyCode.R then Controller.Reload()
        elseif input.KeyCode == Enum.KeyCode.F then Controller.Inspect()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(false)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(false)
        end
    end)
    connect(UserInputService.WindowFocusReleased, function() trigger, aiming, sprinting = false, false, false end)
    ContextActionService:BindActionAtPriority('SurvivalTapFire',function(_,state)if state==Enum.UserInputState.Begin then Controller.Trigger(true)elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then Controller.Trigger(false)end;return Enum.ContextActionResult.Sink end,false,2300,Enum.KeyCode.ButtonR2)
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 2, render)
    return Controller
end
function Controller.Destroy()
    clear()
    RunService:UnbindFromRenderStep(renderName)
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(characterConnections) do c:Disconnect() end
    for ob, transparency in pairs(hidden) do if ob.Parent then ob.LocalTransparencyModifier = transparency end end
    for _, c in ipairs(casings) do c.Part:Destroy() end
    if hud then hud:Destroy() end
    if controlBridge then controlBridge:Destroy(); controlBridge = nil end
    ContextActionService:UnbindAction('ReferenceFPS_TestKeys')
    ContextActionService:UnbindAction('SurvivalTapFire')
    if testing then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end
    testing = false
    UserInputService.MouseIconEnabled = true
    connections, crossLines, casings, hidden = {}, {}, {}, setmetatable({}, {__mode = 'k'})
    hooked = setmetatable({}, {__mode = 'k'})
    started = false
end
return Controller
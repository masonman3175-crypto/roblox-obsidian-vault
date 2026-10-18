-- Claude's guns client: firing feel (recoil climb, shake, screen fuzz, smoke, shells, tracers, impacts,
-- dynamic crosshair, hit markers, reload sound). Visuals only. The server decides every hit.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package:WaitForChild("Config"))
local Fx = require(package:WaitForChild("Fx"))
local Controller = require(ReplicatedStorage:WaitForChild("ReferenceWeapons"):WaitForChild("Controller"))

local player = Players.LocalPlayer
local random = Random.new()

local pendingPitch, pendingYaw = 0, 0
local shake, lastShake = 0, CFrame.identity
local heat, lastShotAt, smokeTimer = 0, -10, 0
local fuzz, flash, bloom = 0, 0, 0
local activeModel, activeSpec

-- pre-made shot sounds per weapon so rapid fire overlaps cleanly
local shotSounds, shotIndex = {}, {}
for id, w in Config.Weapons do
	shotSounds[id], shotIndex[id] = {}, 0
	for i = 1, 4 do
		local s = Instance.new("Sound")
		s.Name = "ClaudeShot" .. id .. "_" .. i
		s.SoundId = w.Shot
		s.Volume = w.ShotVolume or 0.7
		s.Parent = SoundService
		shotSounds[id][i] = s
	end
end
local reloadSound = Instance.new("Sound")
reloadSound.Name = "ClaudeReload"
reloadSound.Volume = 0.6
reloadSound.Parent = SoundService

-- screen fuzz: world blurs and pops for a split second, the viewmodel (GUI) stays sharp
local blur = Instance.new("BlurEffect")
blur.Name = "ClaudeGunFuzz"
blur.Size = 0
blur.Parent = Lighting
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ClaudeGunFlash"
grade.Parent = Lighting

local function weaponFor(spec)
	return spec and Config.Weapons[spec.Id]
end

local function muzzleFrame(model, spec)
	local root = model.PrimaryPart.CFrame
	return CFrame.lookAlong((root * CFrame.new(spec.Muzzle)).Position, root.LookVector), root
end

local function spreadDirection(look, degrees)
	local cf = CFrame.lookAlong(Vector3.zero, look)
	local angle = math.rad(degrees) * math.sqrt(random:NextNumber())
	local spin = random:NextNumber(0, math.pi * 2)
	return (cf * CFrame.Angles(0, 0, spin) * CFrame.Angles(angle, 0, 0)).LookVector
end

local function rayParams()
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = {player.Character, Fx.GetFolder()}
	return p
end

-- hit marker + dynamic crosshair
local gui = Instance.new("ScreenGui")
gui.Name = "ClaudeGunHUD"
gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = true, false, 9
gui.Parent = player:WaitForChild("PlayerGui")
local function line(parent, w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(w, h)
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Parent = parent
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(0, 0, 0)
	st.Transparency = 0.5
	st.Parent = f
	return f, st
end
local cross = Instance.new("Frame")
cross.Name = "Crosshair"
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.Size = UDim2.fromOffset(1, 1)
cross.BackgroundTransparency = 1
cross.Visible = false
cross.Parent = gui
local arms = {}
for i, dir in {Vector2.new(0, -1), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0)} do
	local f, st = line(cross, dir.X ~= 0 and 9 or 2, dir.Y ~= 0 and 9 or 2)
	arms[i] = {Frame = f, Stroke = st, Dir = dir}
end
local dot, dotStroke = line(cross, 2, 2)

local marker = Instance.new("Frame")
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Position = UDim2.fromScale(0.5, 0.5)
marker.Size = UDim2.fromOffset(28, 28)
marker.BackgroundTransparency = 1
marker.Parent = gui
local ticks = {}
for i = 1, 4 do
	local f = Instance.new("Frame")
	local a = math.rad(45 + 90 * i)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = UDim2.fromOffset(9, 2)
	f.Position = UDim2.new(0.5, math.cos(a) * 9, 0.5, math.sin(a) * 9)
	f.Rotation = 45 + 90 * i
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 1
	f.Parent = marker
	ticks[i] = f
end
local markerTween
local function showHit(headshot, killed)
	local color = killed and Color3.fromRGB(255, 70, 60) or (headshot and Color3.fromRGB(255, 214, 90) or Color3.new(1, 1, 1))
	marker.Size = UDim2.fromOffset(killed and 40 or 28, killed and 40 or 28)
	for _, f in ticks do
		f.BackgroundColor3 = color
		f.BackgroundTransparency = 0
		TweenService:Create(f, TweenInfo.new(killed and 0.45 or 0.22), {BackgroundTransparency = 1}):Play()
	end
	if markerTween then markerTween:Cancel() end
	markerTween = TweenService:Create(marker, TweenInfo.new(0.12), {Size = UDim2.fromOffset(22, 22)})
	markerTween:Play()
end

local function onShot(spec, model, aiming)
	local weapon = weaponFor(spec)
	if not weapon or not model or not model.PrimaryPart then return end
	activeModel, activeSpec = model, spec
	local camera = workspace.CurrentCamera
	local camCF = camera.CFrame
	local third = player:GetAttribute("ThirdPersonView") ~= false
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local worldModel = tool and tool:FindFirstChild("WorldModel")
	local worldRoot = worldModel and worldModel:FindFirstChild("Root")
	-- aim point: from the camera through the crosshair
	local aimDir = spreadDirection(camCF.LookVector, (aiming and weapon.SpreadAim or weapon.SpreadHip) + bloom * 0.04)
	local camHit = workspace:Raycast(camCF.Position, aimDir * Config.Range, rayParams())
	local aimPoint = camHit and camHit.Position or camCF.Position + aimDir * Config.Range
	local origin, muzzle, root
	if third and head and worldRoot then
		-- third person: bullets leave from the head line toward the crosshair, effects at the gun in your hands
		origin = head.Position
		root = worldRoot.CFrame
		local m = worldRoot:FindFirstChild("Muzzle")
		muzzle = CFrame.lookAt(m and m.WorldPosition or root.Position, aimPoint)
	else
		origin = camCF.Position
		muzzle, root = muzzleFrame(model, spec)
	end
	local dir = (aimPoint - origin).Unit

	package.Shoot:FireServer(origin, dir)

	shotIndex[spec.Id] = shotIndex[spec.Id] % 4 + 1
	local snd = shotSounds[spec.Id][shotIndex[spec.Id]]
	snd.PlaybackSpeed = random:NextNumber(0.95, 1.05)
	snd.TimePosition = 0
	snd:Play()

	Fx.Muzzle(muzzle, not third, weapon.FlashScale)
	local pellets = weapon.Pellets or 1
	for i = 1, pellets do
		local d = pellets > 1 and spreadDirection(dir, weapon.PelletSpread or 4) or dir
		local hit = workspace:Raycast(origin, d * Config.Range, rayParams())
		local hitPos = hit and hit.Position or origin + d * Config.Range
		if i <= 4 then Fx.Tracer(muzzle.Position + muzzle.LookVector * 0.3, hitPos) end
		if hit then
			local m2 = hit.Instance:FindFirstAncestorOfClass("Model")
			local isChar = m2 and m2:FindFirstChildOfClass("Humanoid") ~= nil
			Fx.Impact(hit.Position, hit.Normal, hit.Material, hit.Instance.Color, isChar, i == 1)
		end
	end
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local port = root * CFrame.new(weapon.Eject)
	task.delay(0.02, Fx.Shell, port, root.RightVector + root.UpVector * 0.35, hrp and hrp.AssemblyLinearVelocity, weapon.ShellSize)

	local aimScale = aiming and 0.7 or 1
	pendingPitch += math.rad(weapon.ClimbPitch * aimScale * random:NextNumber(0.85, 1.15))
	pendingYaw += math.rad(weapon.ClimbYaw * aimScale * random:NextNumber(-1, 1.25))
	shake = math.min(shake + (aiming and 0.5 or 1) * weapon.Shake, 3)
	fuzz = math.min(fuzz + weapon.Fuzz * (third and 0.5 or 1), 1.6)
	flash = 1
	bloom = math.min(bloom + (spec.Pistol and 9 or 6), 26)
	heat = math.min(heat + 1, 20)
	lastShotAt = os.clock()
end
Controller.Shot:Connect(onShot)

package.HitConfirm.OnClientEvent:Connect(showHit)

-- reload sound, synced to the reload length
player:GetAttributeChangedSignal("FPSReloading"):Connect(function()
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	if player:GetAttribute("FPSReloading") and weapon and weapon.Reload then
		reloadSound.SoundId = weapon.Reload
		reloadSound.PlaybackSpeed = (weapon.ReloadClipLength or weapon.ReloadTime) / weapon.ReloadTime
		reloadSound.TimePosition = 0
		reloadSound:Play()
	else
		reloadSound:Stop()
	end
end)

local MATERIALS = {}
for _, m in Enum.Material:GetEnumItems() do MATERIALS[m.Name] = m end

-- other players' shots: flash at their gun, tracer, impact, 3D sound
package.Replicate.OnClientEvent:Connect(function(shooter, hitPos, normal, materialName, isChar, weaponId)
	local weapon = Config.Weapons[weaponId or "W1"] or Config.Weapons.W1
	local character = shooter and shooter.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local muzzleAttachment = tool and tool:FindFirstChild("Muzzle", true)
	local head = character and character:FindFirstChild("Head")
	local from = muzzleAttachment and muzzleAttachment.WorldPosition or (head and head.Position)
	if not from then return end
	local dir = (hitPos - from)
	if dir.Magnitude < 0.01 then return end
	local cf = CFrame.lookAlong(from, dir.Unit)
	Fx.Muzzle(cf, false, weapon.FlashScale)
	Fx.Tracer(from, hitPos)
	local soundParent = muzzleAttachment and muzzleAttachment.Parent or head
	Fx.Sound(weapon.Shot, soundParent, 0.9, random:NextNumber(0.95, 1.05))
	local color
	local probe = workspace:Raycast(hitPos + normal * 0.3, -normal * 0.6, rayParams())
	if probe then color = probe.Instance.Color end
	Fx.Impact(hitPos, normal, MATERIALS[materialName] or Enum.Material.Concrete, color, isChar, true)
	if tool and tool:FindFirstChild("Handle") then
		local h = tool.Handle.CFrame
		Fx.Shell(CFrame.lookAlong(h.Position, dir.Unit), CFrame.lookAlong(Vector3.zero, dir.Unit).RightVector, Vector3.zero, weapon.ShellSize)
	end
end)

-- blocky Roblox arms on Claude's guns take the player's skin and sleeve colors
local function paintArms()
	local skin = player:GetAttribute("EquippedHandColor")
	local sleeve = player:GetAttribute("EquippedSleeveColor")
	local character = player.Character
	local bodyColors = character and character:FindFirstChildOfClass("BodyColors")
	if not skin and bodyColors then skin = bodyColors.RightArmColor3 end
	for id in Config.Weapons do
		local template = ReplicatedStorage.ReferenceWeapons.Viewmodels:FindFirstChild(id)
		if template then
			for _, p in template:GetChildren() do
				local kind = p:GetAttribute("ArmPart")
				if kind == "Skin" and skin then p.Color = skin end
				if kind == "Sleeve" and sleeve then p.Color = sleeve end
			end
		end
	end
end
paintArms()
player:GetAttributeChangedSignal("EquippedHandColor"):Connect(paintArms)
player:GetAttributeChangedSignal("EquippedSleeveColor"):Connect(paintArms)
player.CharacterAdded:Connect(function() task.wait(1); paintArms() end)

local tapRing=Instance.new("Frame")
tapRing.Name="TapAimCircle";tapRing.AnchorPoint=Vector2.new(.5,.5);tapRing.Position=UDim2.fromScale(.5,.5)
tapRing.Size=UDim2.fromOffset(12,12);tapRing.BackgroundTransparency=1;tapRing.Parent=cross
local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=tapRing
local outline=Instance.new("UIStroke");outline.Color=Color3.fromRGB(240,242,235);outline.Thickness=1.4;outline.Parent=tapRing
local hudMark
RunService:BindToRenderStep("ClaudeGunFeel", Enum.RenderPriority.Camera.Value + 3, function(dt)
	dt = math.min(dt, 0.05)
	local camera = workspace.CurrentCamera
	if not camera then return end
	-- climb: eased in over a few frames, never undone
	local k = 1 - math.exp(-dt * 28)
	local p, y = pendingPitch * k, pendingYaw * k
	pendingPitch -= p
	pendingYaw -= y
	-- shake: random jitter that is undone next frame
	shake *= math.exp(-dt * 16)
	local amp = math.rad(0.18) * shake
	local newShake = CFrame.Angles(random:NextNumber(-amp, amp), random:NextNumber(-amp, amp), random:NextNumber(-amp, amp) * 1.6)
	camera.CFrame = camera.CFrame * lastShake:Inverse() * CFrame.Angles(p, y, 0) * newShake
	lastShake = newShake
	-- fuzz + flash pop
	fuzz *= math.exp(-dt * 11)
	flash *= math.exp(-dt * 32)
	blur.Size = math.clamp(fuzz * 3.2, 0, 5)
	grade.Brightness = 0.06 * flash
	grade.Contrast = 0.08 * flash
	grade.Saturation = -0.12 * math.min(fuzz, 1)
	-- barrel smoke after bursts
	local now = os.clock()
	if now - lastShotAt > 0.15 then heat = math.max(0, heat - dt * 6) end
	smokeTimer -= dt
	if heat > 4 and now - lastShotAt > 0.1 and smokeTimer <= 0 then
		smokeTimer = 0.07
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		local wm = tool and tool:FindFirstChild("WorldModel")
		local m = wm and wm:FindFirstChild("Muzzle", true)
		if player:GetAttribute("ThirdPersonView") ~= false and m then
			Fx.BarrelSmoke(m.WorldCFrame, math.clamp(heat / 15, 0.2, 1))
		elseif activeModel and activeModel.Parent and activeModel.PrimaryPart then
			Fx.BarrelSmoke(muzzleFrame(activeModel, activeSpec), math.clamp(heat / 15, 0.2, 1))
		end
	end
	-- dynamic crosshair: opens with shots, movement and jumping, fades when aiming
	local weapon = Config.Weapons[player:GetAttribute("FPSWeaponId") or ""]
	local show = weapon ~= nil and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
	cross.Visible = show
	hudMark = hudMark and hudMark.Parent and hudMark or player.PlayerGui:FindFirstChild("AimMark", true)
	if hudMark and hudMark ~= cross then hudMark.Visible = not show end
	if show then
		bloom *= math.exp(-dt * 7)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local speed = root and (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude or 0
		local air = humanoid and humanoid.FloorMaterial == Enum.Material.Air and 10 or 0
		local aim = player:GetAttribute("FPSAiming") and 1 or 0
		local gap = 6 + bloom + math.min(speed, 24) * 0.45 + air
		for _, a in arms do
			a.Frame.Position = UDim2.fromOffset(a.Dir.X * (gap + 4.5), a.Dir.Y * (gap + 4.5))
			a.Frame.Visible=false
            a.Frame.BackgroundTransparency = aim * 0.95
			a.Stroke.Transparency = 0.5 + aim * 0.5
		end
		local radius=aim==1 and 11 or 13+math.min(bloom,9)+math.min(speed,24)*.16
        tapRing.Size=UDim2.fromOffset(radius,radius)
        dot.BackgroundTransparency = 0
		dotStroke.Transparency = 0.5 + aim * 0.5
	end
end)

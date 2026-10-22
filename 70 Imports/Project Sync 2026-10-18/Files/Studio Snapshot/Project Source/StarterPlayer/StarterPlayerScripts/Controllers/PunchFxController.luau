-- Visual only. Your own manual punch plays a short cutscene: wind up, punch,
-- freeze-frame impact, then the camera chases the dummy down the biome track
-- and shows the distance. Other players' punches just send the dummy flying.
-- The server already decided feet, Coins and the landing spot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local PunchConfig = require(ReplicatedStorage.Shared.Config.Punch)
local TrackExtension = require(script.Parent.TrackExtensionController)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local PunchFxController = {}

local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)
local flying = false
local inCutscene = false
local gui = nil

-- User-supplied ending only: audiomass-output.mp3 (1.93 seconds).
local MEME_CLIP_ASSET_ID = "rbxassetid://83363670294957"
local impactVoice = nil

local function getImpactVoice()
    if impactVoice and impactVoice.Parent then return impactVoice end
    local sound = Instance.new("Sound")
    sound.Name = "CharlieBrownPunchEnding"
    sound.SoundId = MEME_CLIP_ASSET_ID
    sound.Volume = 0.85
    sound.PlaybackSpeed = 1
    sound.Looped = false
    sound.Parent = SoundService
    impactVoice = sound
    return sound
end
local WHOOSH_ID = "rbxassetid://9120709477"
local HIT_ID = "rbxassetid://7468131335"
local BOING_ID = "rbxassetid://75314486373846"

local function playOneShot(assetId, volume, speed, maxSeconds)
    if assetId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = assetId
    sound.Volume = volume
    sound.PlaybackSpeed = speed
    sound.RollOffMaxDistance = 80
    sound.Parent = SoundService
    sound.Ended:Connect(function() sound:Destroy() end)
    sound:Play()
    task.delay(maxSeconds, function()
        if sound.Parent then sound:Stop(); sound:Destroy() end
    end)
end

local function impactAudio()
    -- Restart instead of stacking voices on rapid/automatic hits.
    local sound = getImpactVoice()
    if not sound.IsLoaded then
        playOneShot(HIT_ID, 0.5, 1, 2)
        return
    end
    sound:Stop()
    sound.TimePosition = 0
    sound:Play()
end

local function setVisible(model, visible)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = if visible then 0 else 1
		elseif d:IsA("Decal") then
			d.Transparency = if visible then 0 else 1
		elseif d:IsA("BillboardGui") or d:IsA("ProximityPrompt") then
			d.Enabled = visible
		end
	end
end

local function bigText(text, color, size, y)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, y)
	label.Size = UDim2.fromScale(0.9, size)
	label.BackgroundTransparency = 1
	label.FontFace = FONT
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 5
	stroke.Color = Color3.fromRGB(20, 20, 32)
	stroke.Parent = label
	local scale = Instance.new("UIScale")
	scale.Scale = 0.3
	scale.Parent = label
	label.Parent = gui
	TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	return label
end

local function fadeOut(label, delay)
	task.delay(delay, function()
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		local stroke = label:FindFirstChildOfClass("UIStroke")
		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
		task.wait(0.35)
		label:Destroy()
	end)
end

local function flash()
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 0
	f.BorderSizePixel = 0
	f.Parent = gui
	TweenService:Create(f, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
	task.delay(0.4, function()
		f:Destroy()
	end)
end

local function shoulder(character)
	local r15 = character:FindFirstChild("RightUpperArm")
	if r15 and r15:FindFirstChild("RightShoulder") and r15.RightShoulder:IsA("Motor6D") then
		return r15.RightShoulder, function(angle)
			return CFrame.Angles(angle, 0, 0)
		end
	end
	local torso = character:FindFirstChild("Torso")
	if torso and torso:FindFirstChild("Right Shoulder") and torso["Right Shoulder"]:IsA("Motor6D") then
		return torso["Right Shoulder"], function(angle)
			return CFrame.Angles(0, 0, angle)
		end
	end
	return nil, nil
end

-- Motor6D.C0 can't be tweened, so lerp it by hand (runs in the background)
local function animateJoint(joint, goal, duration)
	if not joint then
		return
	end
	local from = joint.C0
	task.spawn(function()
		local t0 = os.clock()
		while joint.Parent do
			local a = math.clamp((os.clock() - t0) / duration, 0, 1)
			joint.C0 = from:Lerp(goal, 1 - (1 - a) ^ 2)
			if a >= 1 then
				break
			end
			RunService.RenderStepped:Wait()
		end
	end)
end

local function makeGhost(dummy)
	local ghost = dummy:Clone()
	for _, d in ghost:GetDescendants() do
		if d:IsA("ProximityPrompt") or d:IsA("BillboardGui") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.CanCollide = false
			d.CanQuery = false
			d.Anchored = true
		end
	end
	local trail = Instance.new("ParticleEmitter")
	trail.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	trail.Rate = 60
	trail.Lifetime = NumberRange.new(0.4, 0.8)
	trail.Speed = NumberRange.new(0, 2)
	trail.Size = NumberSequence.new(1.5, 0)
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 80, 200))
	trail.Parent = ghost.PrimaryPart
	ghost.Parent = workspace
	return ghost
end

-- Flies the dummy from its stand to trackX. onStep(position) runs every frame.
local function fly(dummy, feet, trackX, onStep)
	flying = true
	TrackExtension.Prepare(trackX)
	local ghost = makeGhost(dummy)
	setVisible(dummy, false)
	local start = dummy:GetPivot()
	local decades = math.clamp(math.log10(math.max(feet, 10)) - 1, 0, 6)
	local duration = 1.6 + decades * 0.55
	local travel = trackX - start.Position.X
	local peak = math.clamp(18 + decades * 8, 18, 64)
	local t0 = os.clock()
	local done = false
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local a = math.clamp((os.clock() - t0) / duration, 0, 1)
		-- fast launch, slows down near the end
		local eased = 1 - (1 - a) ^ 2
		local pos = start.Position + Vector3.new(travel * eased, 4 * peak * a * (1 - a), 0)
		ghost:PivotTo(CFrame.new(pos) * start.Rotation * CFrame.Angles(0, 0, -a * math.pi * 10))
		TrackExtension.Focus(pos.X)
		if onStep then
			onStep(pos, a)
		end
		if a >= 1 then
			connection:Disconnect()
			done = true
		end
	end)
	while not done do
		task.wait()
	end
	return ghost, function()
		ghost:Destroy()
		setVisible(dummy, true)
		flying = false
		TrackExtension.Release()
	end
end

local function cutscene(dummy, feet, coins, trackX)
	inCutscene = true
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		inCutscene = false
		return
	end
	local camera = workspace.CurrentCamera
	local oldFov = camera.FieldOfView
	local scale = character:GetScale()
	local dummyPos = dummy:GetPivot().Position

	-- lock the player in place facing the dummy
	root.Anchored = true
	root.CFrame = CFrame.lookAt(root.Position, Vector3.new(dummyPos.X, root.Position.Y, dummyPos.Z))
	camera.CameraType = Enum.CameraType.Scriptable
	local mid = (root.Position + dummyPos) / 2
	local shot = CFrame.lookAt(mid + Vector3.new(-2, 3 + 2 * scale, 14 + 4 * scale), mid)
	TweenService:Create(camera, TweenInfo.new(0.25), {CFrame = shot, FieldOfView = 60}):Play()

	-- wind up
	local joint, rot = shoulder(character)
	local baseC0 = joint and joint.C0
	if joint then
		animateJoint(joint, baseC0 * rot(math.rad(-60)), 0.45)
	end
	TweenService:Create(camera, TweenInfo.new(0.5), {FieldOfView = 52}):Play()
	task.wait(0.5)

	-- PUNCH
	playOneShot(WHOOSH_ID, 0.32, 1.15, 1)
	if joint then
		animateJoint(joint, baseC0 * rot(math.rad(95)), 0.08)
	end
	TweenService:Create(root, TweenInfo.new(0.08), {CFrame = root.CFrame * CFrame.new(0, 0, -1.5)}):Play()
	task.wait(0.08)

	-- impact freeze frame
	impactAudio()
	flash()
	local pow = bigText("POW!", Color3.fromRGB(255, 230, 60), 0.28, 0.4)
	pow.Rotation = math.random(-12, 12)
	camera.FieldOfView = 40
	local shakeEnd = os.clock() + 0.4
	while os.clock() < shakeEnd do
		camera.CFrame = shot * CFrame.new(math.random(-10, 10) / 25, math.random(-10, 10) / 25, 0)
		task.wait()
	end
	fadeOut(pow, 0.1)
	if joint then
		animateJoint(joint, baseC0, 0.3)
	end

	-- chase cam
	camera.FieldOfView = 70
	local lastBiome = 0
	playOneShot(BOING_ID, 0.36, 1.05, 1.8)
	local ghost, cleanup = fly(dummy, feet, trackX, function(pos)
		local goal = CFrame.lookAt(pos + Vector3.new(-28, 12, 34), pos)
		camera.CFrame = camera.CFrame:Lerp(goal, 0.25)
		local index, name = PunchConfig.BiomeAt(pos.X)
		if index ~= lastBiome then
			lastBiome = index
			fadeOut(bigText(string.upper(name) .. "!", Color3.new(1, 1, 1), 0.1, 0.2), 0.6)
		end
	end)

	-- landing
	local banner = bigText(Format.Number(feet) .. " FT!", Color3.fromRGB(255, 220, 60), 0.2, 0.42)
	local reward = bigText("+" .. Format.Number(coins) .. " Coins", Color3.fromRGB(120, 255, 140), 0.09, 0.56)
	task.wait(1.6)
	fadeOut(banner, 0)
	fadeOut(reward, 0)
	cleanup()

	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = oldFov
	if root.Parent then
		root.Anchored = false
	end
	inCutscene = false
end

local function coinPopup(text)
	local label = bigText(text, Color3.fromRGB(255, 220, 60), 0.06, 0.3)
	fadeOut(label, 1)
end

function PunchFxController.IsBusy()
	return inCutscene
end

function PunchFxController.Start()
    local voice = getImpactVoice()
    task.spawn(function()
        local ok, err = pcall(function() ContentProvider:PreloadAsync({voice}) end)
        if not ok then warn("[PunchFx] voice preload: " .. tostring(err)) end
    end)
	TrackExtension.Start()
	gui = Instance.new("ScreenGui")
	gui.Name = "PunchFxGui"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local dummy = workspace:WaitForChild("Map"):WaitForChild("Gameplay"):WaitForChild("PunchLane"):WaitForChild("Dummy")
	local prompt = dummy:WaitForChild("Torso"):WaitForChild("PunchPrompt")
	while not dummy.PrimaryPart do
		task.wait()
	end

	Remotes.PunchFx.OnClientEvent:Connect(function(puncher, feet, coins, trackX, isAuto)
		if puncher == player and not isAuto and not inCutscene then
			prompt.Enabled = false
			task.spawn(function()
				local ok, err = pcall(cutscene, dummy, feet, coins, trackX)
				if not ok then
					warn("[PunchFx] cutscene failed: " .. tostring(err))
					-- never leave the player stuck
					local camera = workspace.CurrentCamera
					camera.CameraType = Enum.CameraType.Custom
					camera.FieldOfView = 70
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.Anchored = false
					end
					inCutscene = false
					flying = false
					setVisible(dummy, true)
					TrackExtension.Release()
				end
				prompt.Enabled = true
			end)
			return
		end
		if puncher == player then
			impactAudio()
			playOneShot(BOING_ID, 0.28, 1, 1.8)
			coinPopup("\u{1F44A} " .. Format.Number(feet) .. " FT  +" .. Format.Number(coins) .. " Coins")
		end
		if not flying and not inCutscene then
			task.spawn(function()
				local _, cleanup = fly(dummy, feet, trackX, nil)
				task.wait(0.8)
				cleanup()
			end)
		end
	end)
end

return PunchFxController


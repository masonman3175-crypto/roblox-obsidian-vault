-- Hatch animation: egg shakes, white flash, pets pop out spinning with name + rarity.
-- Legendary / Mythic add a rainbow burst, a banner and a UI shake. Driven by the HatchFx remote.
-- Never sinks input; full version < 3 s, auto-hatch version ~0.6 s.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EggsConfig = require(ReplicatedStorage.Shared.Config.Eggs)
local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)
local UiStyle = require(script.Parent.UiStyle)
local PetsController = require(script.Parent.PetsController)

local HatchController = {}

local C = UiStyle.Colors
local MAX_QUEUE = 2

local EGG_COLORS = {
	Starter = Color3.fromRGB(255, 240, 200),
	Buff = Color3.fromRGB(255, 120, 60),
	Candy = Color3.fromRGB(255, 130, 200),
	CandyPlus = Color3.fromRGB(255, 80, 170),
	Frost = Color3.fromRGB(150, 220, 255),
	FrostPlus = Color3.fromRGB(90, 170, 255),
	Inferno = Color3.fromRGB(255, 90, 30),
	InfernoPlus = Color3.fromRGB(200, 30, 30),
	Galaxy = Color3.fromRGB(120, 70, 220),
	GalaxyPlus = Color3.fromRGB(70, 30, 160),
	Mega = Color3.fromRGB(255, 200, 40),
}

local gui: ScreenGui? = nil
local stage: Frame? = nil
local queue = {}
local playing = false

local function tween(obj: Instance, t: number, props: { [string]: any }, style: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function scaled(frame: GuiObject)
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	local function update()
		local size = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(math.min(size.X / 1100, size.Y / 700), 0.55, 1)
	end
	update()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
end

-- Part-built egg (stretched sphere + spots) in a ViewportFrame
local function eggViewport(eggId: string): ViewportFrame
	local color = EGG_COLORS[eggId] or C.Gold
	local vp = Instance.new("ViewportFrame")
	vp.Name = "Egg"
	vp.BackgroundTransparency = 1
	vp.AnchorPoint = Vector2.new(0.5, 0.5)
	vp.Position = UDim2.fromScale(0.5, 0.5)
	vp.Size = UDim2.fromOffset(260, 260)
	vp.Ambient = Color3.fromRGB(190, 190, 190)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.ZIndex = 5
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, 7.5), Vector3.zero)
	camera.Parent = vp
	vp.CurrentCamera = camera
	local model = Instance.new("Model")
	local shell = Instance.new("Part")
	shell.Anchored = true
	shell.Size = Vector3.new(2.6, 3.3, 2.6)
	shell.Color = color
	shell.Material = Enum.Material.SmoothPlastic
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = shell
	shell.Parent = model
	local spot = UiStyle.Darken(color, 0.3)
	for i, offset in { Vector3.new(-0.7, 0.6, 1.05), Vector3.new(0.6, -0.3, 1.15), Vector3.new(-0.2, -1.1, 1.05), Vector3.new(0.5, 1.1, 0.9) } do
		local dot = Instance.new("Part")
		dot.Anchored = true
		dot.Shape = Enum.PartType.Ball
		local s = if i == 1 then 0.8 else 0.55
		dot.Size = Vector3.new(s, s, s)
		dot.Color = if i % 2 == 0 then C.White else spot
		dot.Material = Enum.Material.SmoothPlastic
		dot.Position = offset
		dot.Parent = model
	end
	model.Parent = vp
	return vp
end

local function rainbowBurst(parent: Instance, hold: boolean)
	local burst = Instance.new("Frame")
	burst.Name = "Burst"
	burst.AnchorPoint = Vector2.new(0.5, 0.5)
	burst.Position = UDim2.fromScale(0.5, 0.5)
	burst.Size = UDim2.fromScale(0.2, 0.2)
	burst.SizeConstraint = Enum.SizeConstraint.RelativeXX
	burst.BackgroundColor3 = C.White
	burst.BackgroundTransparency = 0.25
	burst.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = burst
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 70)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 40)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 60)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(80, 230, 90)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(60, 160, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 80, 255)),
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	grad.Parent = burst
	burst.Parent = parent
	tween(burst, 0.5, { Size = UDim2.fromScale(1.4, 1.4) }, Enum.EasingStyle.Back)
	local conn = RunService.RenderStepped:Connect(function(dt)
		grad.Rotation = (grad.Rotation + dt * 180) % 360
	end)
	burst.Destroying:Connect(function()
		conn:Disconnect()
	end)
	if not hold then
		task.delay(1, function()
			if burst.Parent then
				tween(burst, 0.4, { BackgroundTransparency = 1 })
			end
		end)
	end
end

local function shake(frame: GuiObject, duration: number, strength: number)
	task.spawn(function()
		local base = frame.Position
		local t0 = os.clock()
		while os.clock() - t0 < duration and frame.Parent do
			local k = 1 - (os.clock() - t0) / duration
			frame.Position = base + UDim2.fromOffset(math.random(-strength, strength) * k, math.random(-strength, strength) * k)
			task.wait()
		end
		frame.Position = base
	end)
end

local function petReveal(petId: string, index: number, count: number, parent: Instance, delayTime: number): Frame
	local pet = PetsConfig.List[petId] or { Name = tostring(petId), Rarity = "Common", Power = 0 }
	local rarity = PetsConfig.Rarities[pet.Rarity] or PetsConfig.Rarities.Common
	local holder = Instance.new("Frame")
	holder.Name = "Pet" .. index
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Position = UDim2.new(0.5, (index - (count + 1) / 2) * 240, 0.5, 0)
	holder.Size = UDim2.fromOffset(230, 300)
	holder.ZIndex = 6
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = holder

	-- soft rarity glow behind the pet
	local glow = Instance.new("Frame")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.36)
	glow.Size = UDim2.fromOffset(200, 200)
	glow.BackgroundColor3 = rarity.Color
	glow.ZIndex = 6
	local gc = Instance.new("UICorner")
	gc.CornerRadius = UDim.new(1, 0)
	gc.Parent = glow
	local gg = Instance.new("UIGradient")
	gg.Rotation = 90
	gg.Transparency = NumberSequence.new(0.15, 0.9)
	gg.Parent = glow
	local gs = Instance.new("UIStroke")
	gs.Thickness = 4
	gs.Color = C.Outline
	gs.Parent = glow
	glow.Parent = holder

	local vp = PetsController.Viewport(petId, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromOffset(210, 210),
		ZIndex = 7,
		Parent = holder,
	})
	local model = vp:FindFirstChildOfClass("Model")
	if model then
		local angle = math.pi
		local conn = RunService.RenderStepped:Connect(function(dt)
			angle += dt * 2.5
			model:PivotTo(CFrame.Angles(0, angle, 0))
		end)
		holder.Destroying:Connect(function()
			conn:Disconnect()
		end)
	end

	UiStyle.Label({
		Name = "PetName",
		Text = pet.Name,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.72),
		Size = UDim2.fromOffset(230, 38),
		MaxTextSize = 34,
		StrokeThickness = 4,
		ZIndex = 8,
		Parent = holder,
	})
	UiStyle.Label({
		Name = "Rarity",
		Text = pet.Rarity .. "  +" .. PetsController.Format(pet.Power),
		TextColor3 = rarity.Color,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.86),
		Size = UDim2.fromOffset(230, 28),
		MaxTextSize = 26,
		StrokeThickness = 3,
		ZIndex = 8,
		Parent = holder,
	})
	holder.Parent = parent
	task.delay(delayTime, function()
		tween(scale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	return holder
end

local function banner(text: string, color: Color3, parent: Instance)
	local label = UiStyle.Label({
		Name = "Banner",
		Text = text,
		TextColor3 = color,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -215),
		Size = UDim2.fromOffset(640, 92),
		MaxTextSize = 84,
		StrokeThickness = 6,
		ZIndex = 9,
		Parent = parent,
	})
	label.Rotation = -4
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = label
	tween(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function play(eggId: string, petIds: { string }, isAuto: boolean, hold: boolean?)
	local root = stage
	if not root then
		return
	end
	local scene = Instance.new("Frame")
	scene.Name = "Scene"
	scene.BackgroundTransparency = 1
	scene.Size = UDim2.fromScale(1, 1)
	scene.Parent = root

	local center = Instance.new("Frame")
	center.Name = "Center"
	center.BackgroundTransparency = 1
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.Position = UDim2.fromScale(0.5, 0.5)
	center.Size = UDim2.fromOffset(800, 600)
	center.ZIndex = 3
	center.Parent = scene
	scaled(center)

	-- 1. egg shakes harder and harder
	local shakeTime = if isAuto then 0.25 else 1.2
	local egg = eggViewport(eggId)
	egg.Parent = center
	local eggScale = Instance.new("UIScale")
	eggScale.Scale = 0.6
	eggScale.Parent = egg
	tween(eggScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
	local t0 = os.clock()
	while os.clock() - t0 < shakeTime do
		local k = (os.clock() - t0) / shakeTime
		egg.Rotation = math.sin(os.clock() * (18 + k * 30)) * (4 + k * 22)
		eggScale.Scale = 1 + k * 0.15
		task.wait()
	end

	-- 2. white flash, egg cracks open
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = C.White
	flash.ZIndex = 20
	flash.Parent = scene
	tween(flash, if isAuto then 0.2 else 0.45, { BackgroundTransparency = 1 })
	egg:Destroy()

	-- 3. reveal pets (best rarity decides the extras)
	local best = 0
	local bestRarity = "Common"
	for _, id in petIds do
		local pet = PetsConfig.List[id]
		local r = pet and PetsConfig.Rarities[pet.Rarity]
		if r and r.Order > best then
			best = r.Order
			bestRarity = pet.Rarity
		end
	end
	local count = math.min(#petIds, 3)
	for i = 1, count do
		petReveal(petIds[i], i, count, center, (i - 1) * (if isAuto then 0.03 else 0.12))
	end
	if bestRarity == "Legendary" or bestRarity == "Mythic" then
		rainbowBurst(scene, hold == true)
		local text = if bestRarity == "Mythic" then "MYTHIC!!" else "LEGENDARY!"
		banner(text, PetsConfig.Rarities[bestRarity].Color, center)
		shake(center, if isAuto then 0.3 else 0.6, if bestRarity == "Mythic" then 16 else 10)
	end
	if hold then
		return
	end

	-- 4. hold, then shrink away
	task.wait(if isAuto then 0.35 else 1.1)
	for _, child in center:GetChildren() do
		local s = child:FindFirstChildOfClass("UIScale")
		if s then
			tween(s, 0.2, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		end
	end
	task.wait(0.22)
	scene:Destroy()
end

local function pump()
	if playing then
		return
	end
	playing = true
	while #queue > 0 do
		local job = table.remove(queue, 1)
		local ok, err = pcall(play, job[1], job[2], job[3])
		if not ok then
			warn("HatchController:", err)
		end
	end
	playing = false
end

local function build(parent: Instance)
	local g = Instance.new("ScreenGui")
	g.Name = "HatchGui"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 30
	local s = Instance.new("Frame")
	s.Name = "Stage"
	s.BackgroundTransparency = 1
	s.Size = UDim2.fromScale(1, 1)
	s.Parent = g
	stage = s
	gui = g
	g.Parent = parent
end

-- Public so other UI (egg prompts, tests) can trigger the same animation
function HatchController.Play(eggId: string, petIds: { string }, isAuto: boolean?)
	if type(petIds) ~= "table" or #petIds == 0 then
		return
	end
	if #queue >= MAX_QUEUE then
		table.remove(queue, 1)
	end
	table.insert(queue, { eggId, petIds, isAuto == true })
	task.spawn(pump)
end

function HatchController.Start()
	local player = Players.LocalPlayer
	build(player:WaitForChild("PlayerGui"))
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	remotes:WaitForChild("HatchFx").OnClientEvent:Connect(function(eggId, petIds, isAuto)
		if type(eggId) == "string" and EggsConfig.List[eggId] then
			HatchController.Play(eggId, petIds, isAuto)
		end
	end)
end

-- Edit-mode visual check only: freezes on the reveal so it can be screenshotted
function HatchController.Preview(parent: Instance, eggId: string, petIds: { string }): ScreenGui?
	build(parent)
	task.spawn(play, eggId, petIds, true, true)
	return gui
end

return HatchController

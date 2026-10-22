-- Builds the HUD in code (UiStyle buttons) and keeps it in sync with player
-- attributes. Visual only: every stat, unlock and purchase is decided on the server.
-- Passive Strength arrives once a second but is shown as +gain popups every 0.1s
-- with a smooth counter, so it feels like it never stops going up.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Format = require(Shared:WaitForChild("Util"):WaitForChild("Format"))
local Purchase = require(Shared.Util:WaitForChild("Purchase"))
local Zones = require(Config:WaitForChild("Zones"))
local RebirthConfig = require(Config:WaitForChild("Rebirth"))
local Monetization = require(Config:WaitForChild("Monetization"))
local StatsConfig = require(Config:WaitForChild("Stats"))
local Gym = require(Config:WaitForChild("Gym"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UiStyle = require(script.Parent:WaitForChild("UiStyle"))

local player = Players.LocalPlayer
local HudController = {}

local FONT = Enum.Font.FredokaOne
local DARK = Color3.fromRGB(20, 20, 30)
local CLICK_LIMIT = 12

local ui = {}
local clickTimes = {}
local shownStrength = 0
local lastLevel = nil

local function make(className, props, children)
	local inst = Instance.new(className)
	for k, v in props do
		inst[k] = v
	end
	for _, child in children or {} do
		child.Parent = inst
	end
	return inst
end

local function corner(radius)
	return make("UICorner", {CornerRadius = UDim.new(0, radius or 12)})
end

local function label(props)
	local l = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = FONT,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromScale(1, 1),
	}, {make("UIStroke", {Thickness = 2.5, Color = DARK})})
	for k, v in props do
		l[k] = v
	end
	return l
end


local function button(name, text, color, size, parent, rainbow)
	local square = size.X.Offset > 0 and size.X.Offset == size.Y.Offset
	return UiStyle.Button({
		Name = name,
		Text = text,
		Color = color,
		Size = size,
		Shape = if square then "Square" else "Wide",
		Logo = if not square and size.X.Offset < 130 then nil else name,
		Rainbow = rainbow == true,
		Parent = parent,
	})
end

local function scaled(frame)
	local scale = make("UIScale", {Parent = frame})
	local function update()
		local size = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(math.min(size.X / 1100, size.Y / 700), 0.55, 1)
	end
	update()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
end

local function attr(name, default)
	local value = player:GetAttribute(name)
	if value == nil then
		return default
	end
	return value
end

local function optionalController(name)
	local module = script.Parent:FindFirstChild(name)
	if not module then
		return nil
	end
	local ok, result = pcall(require, module)
	return if ok then result else nil
end

-- toasts and popups
local function notify(text)
	local toast = label({
		Text = text,
		Size = UDim2.fromOffset(620, 40),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 118),
		TextColor3 = Color3.fromRGB(255, 240, 120),
		Parent = ui.Gui,
	})
	TweenService:Create(toast, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 128)}):Play()
	task.delay(2.5, function()
		TweenService:Create(toast, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
		task.wait(0.4)
		toast:Destroy()
	end)
end

local function popup(text, color, big)
	local size = if big then UDim2.fromOffset(240, 46) else UDim2.fromOffset(140, 30)
	local p = label({
		Text = text,
		Size = size,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5 + (math.random() - 0.5) * 0.3, 0, 0.42 + (math.random() - 0.5) * 0.18, 0),
		TextColor3 = color or Color3.new(1, 1, 1),
		Rotation = (math.random() - 0.5) * 16,
		Parent = ui.Gui,
	})
	local goal = {Position = p.Position - UDim2.fromScale(0, 0.07), TextTransparency = 1}
	TweenService:Create(p, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
	task.delay(0.7, function()
		p:Destroy()
	end)
end

local function buyPass(passKey)
	local ok, reason = Purchase.Pass(passKey)
	if not ok and reason then
		notify(reason)
	end
end

local function buyProduct(productKey)
	local ok, reason = Purchase.Product(productKey)
	if not ok and reason then
		notify(reason)
	end
end

-- owned auto pass = toggle it, not owned = buy it
local function autoButton(passKey, field, remote)
	return function()
		if attr("Pass_" .. passKey, false) then
			remote:FireServer(not attr(field, true))
		else
			buyPass(passKey)
		end
	end
end

local function train()
	local now = os.clock()
	while clickTimes[1] and now - clickTimes[1] > 1 do
		table.remove(clickTimes, 1)
	end
	if #clickTimes >= CLICK_LIMIT then
		return
	end
	table.insert(clickTimes, now)
	Remotes.Train:FireServer()
	popup("+" .. Format.Number(attr("Gain", 1) * StatsConfig.ClickValue) .. " \u{1F4AA}", Color3.fromRGB(255, 220, 90), true)
end

local function buildRebirthPanel()
	local panel = UiStyle.Panel({Name = "RebirthPanel", Title = "Rebirth", Color = UiStyle.Colors.Pink, Size = UDim2.fromOffset(480, 340), Parent = ui.Gui})
	panel.Visible = false
	panel.Body.ZIndex = 0
	scaled(panel)
	panel.Close.Activated:Connect(function()
		panel.Visible = false
	end)
	ui.RebirthFrom = label({Size = UDim2.fromOffset(180, 60), Position = UDim2.fromOffset(30, 76), ZIndex = 20, Parent = panel})
	label({Text = "\u{27A1}", Size = UDim2.fromOffset(60, 60), Position = UDim2.fromOffset(210, 76), ZIndex = 20, Parent = panel})
	ui.RebirthTo = label({Size = UDim2.fromOffset(180, 60), Position = UDim2.fromOffset(270, 76), TextColor3 = Color3.fromRGB(120, 255, 140), ZIndex = 20, Parent = panel})
	ui.RebirthNeed = label({Size = UDim2.new(1, -40, 0, 30), Position = UDim2.fromOffset(20, 146), TextColor3 = Color3.fromRGB(255, 140, 170), ZIndex = 20, Parent = panel})
	local bar = make("Frame", {Size = UDim2.new(1, -60, 0, 30), Position = UDim2.fromOffset(30, 184), BackgroundColor3 = DARK, ZIndex = 20, Parent = panel}, {corner(10)})
	ui.RebirthFill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(80, 220, 90), ZIndex = 21, Parent = bar}, {corner(10)})
	ui.RebirthBarText = label({ZIndex = 22, Parent = bar})
	local go = button("RebirthButton", "Rebirth!", UiStyle.Colors.Pink, UDim2.fromOffset(190, 60), panel)
	go.Position = UDim2.fromOffset(40, 236)
	go.ZIndex = 20
	go.Activated:Connect(function()
		Remotes.Rebirth:FireServer()
	end)
	ui.SkipButton = button("SkipButton", "Skip", UiStyle.Colors.Green, UDim2.fromOffset(190, 60), panel)
	ui.SkipButton.Position = UDim2.fromOffset(250, 236)
	ui.SkipButton.ZIndex = 20
	ui.SkipButton.Activated:Connect(function()
		buyProduct("RebirthSkip")
	end)
	label({Text = "Rebirth resets Strength and Level, keeps pets and Coins. Skip keeps everything (Robux).", Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(20, 306), TextColor3 = Color3.fromRGB(200, 200, 215), ZIndex = 20, Parent = panel})
	ui.RebirthPanel = panel
end

local function buildHud()
	local gui = make("ScreenGui", {Name = "Hud", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
	ui.Gui = gui

	-- top: world track
	local top = make("Frame", {Name = "Top", Size = UDim2.fromOffset(620, 96), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), BackgroundTransparency = 1, Parent = gui})
	scaled(top)
	local track = make("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = top}, {
		make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 30)}),
	})
	ui.WorldDots = {}
	for i, world in Zones.List do
		local dot = make("Frame", {Size = UDim2.fromOffset(46, 46), BackgroundColor3 = world.Color, LayoutOrder = i, Parent = track}, {corner(23), make("UIStroke", {Thickness = 3, Color = DARK, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})})
		label({Text = tostring(i), Parent = dot})
		ui.WorldDots[i] = dot
	end
	ui.WorldText = label({Size = UDim2.new(1, 0, 0, 32), Position = UDim2.fromOffset(0, 58), Parent = top})

	-- top left: wallet
	local wallet = make("Frame", {Name = "Wallet", Size = UDim2.fromOffset(260, 96), Position = UDim2.fromOffset(12, 60), BackgroundTransparency = 1, Parent = gui})
	scaled(wallet)
	ui.CoinsText = label({Size = UDim2.new(1, 0, 0, 44), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 220, 60), Parent = wallet})
	ui.BestText = label({Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 48), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 150, 150), Parent = wallet})

	-- left: progression
	local left = make("Frame", {Name = "Left", Size = UDim2.fromOffset(104, 340), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.55, 0), BackgroundTransparency = 1, Parent = gui}, {
		make("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	scaled(left)
	local rebirth = button("Rebirth", "Rebirth", UiStyle.Colors.Pink, UDim2.fromOffset(104, 104), left)
	rebirth.LayoutOrder = 1
	ui.RebirthBadge = rebirth.Badge
	rebirth.Activated:Connect(function()
		ui.RebirthPanel.Visible = not ui.RebirthPanel.Visible
	end)
	local pets = button("Pets", "Pets", UiStyle.Colors.Green, UDim2.fromOffset(104, 104), left)
	pets.LayoutOrder = 2
	pets.Activated:Connect(function()
		local controller = optionalController("PetsController")
		if controller and controller.Toggle then
			controller.Toggle()
		else
			notify("Pets menu is coming in the next update")
		end
	end)
	local shop = button("Shop", "Shop", UiStyle.Colors.Orange, UDim2.fromOffset(104, 104), left)
	shop.LayoutOrder = 3
	shop.Activated:Connect(function()
		local controller = optionalController("ShopController")
		if controller and controller.Toggle then
			controller.Toggle()
		else
			buyPass("Double")
		end
	end)

	-- right: money, everywhere
	local right = make("Frame", {Name = "Right", Size = UDim2.fromOffset(210, 420), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.55, 0), BackgroundTransparency = 1, Parent = gui}, {
		make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	scaled(right)
	local double = button("Double", "x2 Strength", Color3.new(1, 1, 1), UDim2.fromOffset(210, 60), right, true)
	double.LayoutOrder = 1
	double.Activated:Connect(function()
		buyPass("Double")
	end)
	ui.DoublePrice = label({Size = UDim2.fromOffset(210, 20), LayoutOrder = 2, TextColor3 = Color3.fromRGB(120, 255, 140), Parent = right})
	ui.AutoClick = button("AutoTrain", "Auto Click", UiStyle.Colors.Blue, UDim2.fromOffset(210, 52), right)
	ui.AutoClick.LayoutOrder = 3
	ui.AutoClick.Activated:Connect(autoButton("AutoTrain", "AutoTrainOn", Remotes.ToggleAutoTrain))
	ui.AutoPunch = button("AutoPunch", "Auto Punch", UiStyle.Colors.Red, UDim2.fromOffset(210, 52), right)
	ui.AutoPunch.LayoutOrder = 4
	ui.AutoPunch.Activated:Connect(autoButton("AutoPunch", "AutoPunchOn", Remotes.ToggleAutoPunch))
	local coins = button("DoubleCoins", "x2 Coins", UiStyle.Colors.Gold, UDim2.fromOffset(210, 52), right)
	coins.LayoutOrder = 5
	coins.Activated:Connect(function()
		buyPass("DoubleCoins")
	end)
	local vip = button("VIP", "VIP", UiStyle.Colors.Yellow, UDim2.fromOffset(210, 52), right)
	vip.LayoutOrder = 6
	vip.Activated:Connect(function()
		buyPass("VIP")
	end)
	ui.BoostButton = button("Boost", "x2 Boost 15m", UiStyle.Colors.Purple, UDim2.fromOffset(210, 52), right)
	ui.BoostButton.LayoutOrder = 7
	ui.BoostButton.Activated:Connect(function()
		buyProduct("Boost")
	end)

	-- bottom: the number going up
	local bottom = make("Frame", {Name = "Bottom", Size = UDim2.fromOffset(680, 184), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), BackgroundTransparency = 1, Parent = gui})
	scaled(bottom)
	ui.MultText = label({Size = UDim2.new(1, 0, 0, 22), RichText = true, Parent = bottom})
	ui.StrengthText = label({Size = UDim2.new(1, 0, 0, 42), Position = UDim2.fromOffset(0, 24), Parent = bottom})
	local bar = make("Frame", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 70), BackgroundColor3 = Color3.fromRGB(40, 40, 60), Parent = bottom}, {corner(10), make("UIStroke", {Thickness = 3, Color = DARK, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})})
	ui.LevelFill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(40, 200, 255), Parent = bar}, {corner(10)})
	ui.LevelText = label({Size = UDim2.new(0.5, -12, 1, -6), Position = UDim2.fromOffset(12, 3), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = bar})
	ui.XpText = label({Size = UDim2.new(0.5, -12, 1, -6), Position = UDim2.new(0.5, 0, 0, 3), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 2, Parent = bar})
	local row = make("Frame", {Size = UDim2.new(1, 0, 0, 60), Position = UDim2.fromOffset(0, 120), BackgroundTransparency = 1, Parent = bottom}, {
		make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	local trainButton = button("Train", "TRAIN", UiStyle.Colors.Orange, UDim2.fromOffset(150, 58), row)
	trainButton.Activated:Connect(train)
	ui.PackButtons = {}
	local packColors = {UiStyle.Colors.Green, UiStyle.Colors.Blue, UiStyle.Colors.Purple}
	for i, productKey in {"StrengthSmall", "StrengthMedium", "StrengthLarge"} do
		local b = button(productKey, "+", packColors[i], UDim2.fromOffset(122, 58), row)
		b.LayoutOrder = i
		b.Activated:Connect(function()
			buyProduct(productKey)
		end)
		ui.PackButtons[productKey] = b
	end
	local coinPack = button("CoinsSmall", "+Coins", UiStyle.Colors.Gold, UDim2.fromOffset(122, 58), row)
	coinPack.LayoutOrder = 4
	coinPack.Activated:Connect(function()
		buyProduct("CoinsSmall")
	end)

	gui.Parent = player:WaitForChild("PlayerGui")
	buildRebirthPanel()
end

local function multLine(name, value, color)
	return string.format("<font color=\"%s\">%s %s</font>", color, Format.Multiplier(value), name)
end

local function timeLeft(field)
	return attr(field, 0) - os.time()
end

local function refresh()
	local level = attr("Level", 1)
	local rebirths = attr("Rebirths", 0)
	local gain = attr("Gain", 1)
	local worldIndex = attr("Zone", 1)
	local allowed = attr("AllowedZone", 1)
	local gymTier = attr("GymTier", 0)
	local xp = attr("XP", 0)
	local xpNeeded = math.max(attr("XPNeeded", 1), 1)

	if lastLevel and level > lastLevel then
		popup("LEVEL UP!", Color3.fromRGB(120, 255, 140), true)
	end
	lastLevel = level

	ui.LevelText.Text = "Level " .. level
	ui.XpText.Text = Format.Number(xp) .. " / " .. Format.Number(xpNeeded)
	TweenService:Create(ui.LevelFill, TweenInfo.new(0.15), {Size = UDim2.fromScale(math.clamp(xp / xpNeeded, 0, 1), 1)}):Play()
	ui.MultText.Text = table.concat({
		multLine("World", attr("Mult_World", 1), "#9BFF8A"),
		multLine("Gym", attr("Mult_Gym", 1), "#FF9B5A"),
		multLine("Rebirth", attr("Mult_Rebirth", 1), "#7FD4FF"),
		multLine("Pass", attr("Mult_Gamepass", 1), "#FFD84A"),
		multLine("Pets", attr("Mult_Pets", 1), "#FF9BD2"),
		multLine("Boost", attr("Mult_Boost", 1), "#D59BFF"),
	}, "  ")
	ui.CoinsText.Text = "COINS  " .. Format.Number(attr("Coins", 0))
	ui.BestText.Text = "BEST PUNCH  " .. Format.Number(attr("BestPunch", 0)) .. " ft"

	for i, dot in ui.WorldDots do
		dot.BackgroundTransparency = if i <= allowed then 0 else 0.6
		dot.Size = if i == worldIndex then UDim2.fromOffset(52, 52) else UDim2.fromOffset(42, 42)
	end
	local world = Zones.List[worldIndex]
	local nextWorld = Zones.List[allowed + 1]
	local text = world.Name .. " World \u{2022} x" .. world.Multiplier
	if gymTier > 0 then
		text ..= " \u{2022} " .. Gym.Tiers[gymTier].Name .. " x" .. Gym.Tiers[gymTier].Multiplier
	end
	text ..= if nextWorld then "   Next: " .. nextWorld.Name .. " at " .. Format.Number(nextWorld.Required) else "   All worlds open!"
	ui.WorldText.Text = text

	local need = RebirthConfig.LevelRequired(rebirths)
	ui.RebirthBadge.Visible = level >= need
	ui.RebirthFrom.Text = Format.Multiplier(RebirthConfig.Multiplier(rebirths))
	ui.RebirthTo.Text = Format.Multiplier(RebirthConfig.Multiplier(rebirths + 1))
	ui.RebirthNeed.Text = "Rebirth " .. (rebirths + 1) .. " needs Level " .. need
	ui.RebirthFill.Size = UDim2.fromScale(math.clamp(level / need, 0, 1), 1)
	ui.RebirthBarText.Text = math.min(level, need) .. " / " .. need
	ui.SkipButton.Label.Text = "Skip " .. Purchase.PriceText("Product", "RebirthSkip")

	for productKey, b in ui.PackButtons do
		b.Label.Text = "+" .. Format.Number(gain * Monetization.Products[productKey].Clicks)
	end

	ui.DoublePrice.Text = if attr("Pass_Double", false) then "OWNED" else Purchase.PriceText("Pass", "Double")
	ui.AutoClick.Label.Text = if attr("Pass_AutoTrain", false) then (if attr("AutoTrainOn", true) then "Auto Click: ON" else "Auto Click: OFF") else "Auto Click"
	ui.AutoPunch.Label.Text = if attr("Pass_AutoPunch", false) then (if attr("AutoPunchOn", true) then "Auto Punch: ON" else "Auto Punch: OFF") else "Auto Punch"
	local boostLeft = timeLeft("BoostEnd")
	ui.BoostButton.Label.Text = if boostLeft > 0 then string.format("x2 Boost %d:%02d", boostLeft // 60, boostLeft % 60) else "x2 Boost 15m"
end

local function passivePerSecond()
	local clicks = StatsConfig.PassiveClicks
	if attr("Pass_AutoTrain", false) and attr("AutoTrainOn", true) then
		clicks += StatsConfig.AutoClicks
	end
	return attr("Gain", 1) * clicks
end

function HudController.Start()
	buildHud()
	shownStrength = attr("Strength", 0)
	player.AttributeChanged:Connect(function(name)
		if name ~= "Strength" then
			refresh()
		end
	end)
	refresh()
	Remotes.Notify.OnClientEvent:Connect(notify)

	-- smooth counter: always creeping toward the real (server) value
	RunService.RenderStepped:Connect(function(dt)
		local target = attr("Strength", 0)
		if target < shownStrength then
			shownStrength = target
		else
			shownStrength += (target - shownStrength) * math.min(1, dt * 6)
		end
		ui.StrengthText.Text = "STRENGTH  " .. Format.Number(shownStrength) .. "   +" .. Format.Number(passivePerSecond()) .. "/sec"
	end)

	-- the illusion: a +gain popup every 0.1s
	task.spawn(function()
		local step = 1 / StatsConfig.PassiveClicks
		while true do
			task.wait(step)
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if attr("Loaded", false) and humanoid and humanoid.Health > 0 then
				popup("+" .. Format.Number(passivePerSecond() * step), Color3.new(1, 1, 1), false)
			end
		end
	end)

	-- click or tap anywhere in the world to train
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			train()
		end
	end)

	-- live boost timer
	task.spawn(function()
		while true do
			task.wait(1)
			if timeLeft("BoostEnd") > -2 then
				refresh()
			end
		end
	end)
end

return HudController

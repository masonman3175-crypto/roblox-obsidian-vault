---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - StarterPlayer.StarterPlayerScripts.Controllers.ShopController

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `StarterPlayer.StarterPlayerScripts.Controllers.ShopController`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [ShopController.luau](../Files/Studio%20Snapshot/Project%20Source/StarterPlayer/StarterPlayerScripts/Controllers/ShopController.luau)

```luau
-- Robux shop: tabs from Monetization.Tabs, one card per pass / product with price button.
-- Paid random items (Mega Egg) show their odds on the card before buying. No fake timers or discounts.
-- Purchases go through Shared.Util.Purchase; the server grants everything.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Monetization = require(ReplicatedStorage.Shared.Config.Monetization)
local EggsConfig = require(ReplicatedStorage.Shared.Config.Eggs)
local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)
local UiStyle = require(script.Parent.UiStyle)

local ShopController = {}

local C = UiStyle.Colors
local CARD = Vector2.new(250, 230)

local TAB_STYLE = {
    Passes = { Color = C.Purple, Logo = "Passes" },
    Boosts = { Color = C.Red, Logo = "Boosts" },
    Coins = { Color = C.Gold, Logo = "Coins" },
    Eggs = { Color = C.Pink, Logo = "Eggs" },
    Gym = { Color = C.Blue, Logo = "Gym" },
}

local RIBBONS = {
	Double = { Text = "BEST VALUE", Color = C.Green },
	VIP = { Text = "HOT", Color = C.Red },
	AutoPunch = { Text = "HOT", Color = C.Red },
}

-- Robux eggs whose odds must be shown on the card
local ODDS_FOR = {
	MegaEgg = "Mega",
	UltraEgg = "Ultra",
}

local gui: ScreenGui? = nil
local panel: Frame? = nil
local pages: { [string]: ScrollingFrame } = {}
local tabButtons: { [string]: TextButton } = {}
local underline: Frame? = nil
local toastLabel: TextLabel? = nil
local current = "Passes"
local buyPass: (string) -> (boolean, string?) = function()
	return false, "Not started"
end
local buyProduct: (string) -> (boolean, string?) = function()
	return false, "Not started"
end
local priceText: (string, string) -> string = function()
	return "UNAVAILABLE"
end
local owns: (string) -> boolean = function()
	return false
end
local watchOwned: (string, () -> ()) -> () = function() end

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

local function recolor(button: any, color: Color3)
	button.Face.BackgroundColor3 = color
	button.Lip.BackgroundColor3 = UiStyle.Darken(color, 0.45)
end

local function toast(text: string)
	local label = toastLabel
	if not label then
		return
	end
	label.Text = text
	label.TextTransparency = 0
	local st = label:FindFirstChildOfClass("UIStroke")
	if st then
		st.Transparency = 0
	end
	task.delay(2, function()
		if label.Text == text then
			TweenService:Create(label, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
			if st then
				TweenService:Create(st, TweenInfo.new(0.4), { Transparency = 1 }):Play()
			end
		end
	end)
end

local function ribbon(card: Instance, info: { Text: string, Color: Color3 })
	local r = Instance.new("Frame")
	r.Name = "Ribbon"
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.new(1, -30, 0, 10)
	r.Size = UDim2.fromOffset(if #info.Text > 4 then 124 else 70, 30)
	r.Rotation = 12
	r.BackgroundColor3 = info.Color
	r.ZIndex = 24
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = r
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = C.Outline
	stroke.Parent = r
	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = ColorSequence.new(C.White, Color3.fromRGB(200, 200, 200))
	grad.Parent = r
	UiStyle.Label({
		Text = info.Text,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -8, 1, -6),
		MaxTextSize = 20,
		StrokeThickness = 2,
		ZIndex = 25,
		Parent = r,
	})
	r.Parent = card
end

local function oddsList(card: Instance, eggId: string)
	local egg = EggsConfig.List[eggId]
	if not egg then
		return
	end
	local box = Instance.new("Frame")
	box.Name = "Odds"
	box.Position = UDim2.fromOffset(12, 84)
	box.Size = UDim2.new(1, -24, 0, 76)
	box.BackgroundColor3 = Color3.new(0, 0, 0)
	box.BackgroundTransparency = 0.55
	box.ZIndex = 22
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = box
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 2)
	list.Parent = box
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = box
	for i, entry in egg.Pets do
		local pet = PetsConfig.List[entry.Id]
		local rarity = pet and PetsConfig.Rarities[pet.Rarity]
		UiStyle.Label({
			Name = "Odd" .. i,
			Text = string.format("%s  %s%%", if pet then pet.Name else entry.Id, tostring(entry.Chance)),
			TextColor3 = if rarity then rarity.Color else C.White,
			Size = UDim2.new(1, 0, 0, 21),
			TextXAlignment = Enum.TextXAlignment.Left,
			MaxTextSize = 19,
			StrokeThickness = 2,
			LayoutOrder = i,
			ZIndex = 23,
			Parent = box,
		})
	end
	box.Parent = card
end

local function makeCard(kind: string, key: string, item: any, color: Color3, order: number): TextButton
	local card = UiStyle.Button({
		Name = key,
		Text = "",
		Shape = "Square",
		Color = color,
		Size = UDim2.fromOffset(CARD.X, CARD.Y),
		LayoutOrder = order,
		ZIndex = 12,
	})
	UiStyle.Logo({
        Name = "BrandLogo", Key = key, Color = color,
        Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(76, 76),
        ZIndex = 21, Parent = card,
    })
	UiStyle.Label({
		Name = "Title",
		Text = item.Name,
		Position = UDim2.fromOffset(96, 14),
		Size = UDim2.new(1, -106, 0, 54),
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxTextSize = 28,
		StrokeThickness = 3,
		ZIndex = 21,
		Parent = card,
	})
	if ODDS_FOR[key] then
		oddsList(card, ODDS_FOR[key])
	else
		UiStyle.Label({
			Name = "Description",
			Text = item.Description or "",
			Position = UDim2.fromOffset(12, 84),
			Size = UDim2.new(1, -24, 0, 76),
			MaxTextSize = 22,
			StrokeThickness = 2,
			ZIndex = 21,
			Parent = card,
		})
	end
	if RIBBONS[key] then
		ribbon(card, RIBBONS[key])
	end

	local buy = UiStyle.Button({
		Name = "Buy",
		Text = "...",
		Color = C.Green,
		Studs = false,
		Size = UDim2.new(1, -28, 0, 48),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		MaxTextSize = 30,
		ZIndex = 21,
		Parent = card,
	})
	local function refresh()
		if kind == "Pass" and owns(key) then
			buy.Label.Text = "OWNED"
			recolor(buy, Color3.fromRGB(120, 120, 135))
		else
			recolor(buy, if item.Id == 0 then Color3.fromRGB(115, 115, 135) else C.Green)
			buy.Label.Text = "..."
			task.spawn(function()
				local text = priceText(kind, key)
				if buy.Label.Text == "..." then
					buy.Label.Text = text
				end
			end)
		end
	end
	refresh()
	if kind == "Pass" then
		watchOwned(key, refresh)
	end
	buy.Activated:Connect(function()
		if kind == "Pass" and owns(key) then
			toast("You already own " .. item.Name)
			return
		end
		local ok, reason = if kind == "Pass" then buyPass(key) else buyProduct(key)
		if not ok and reason then
			toast(reason)
		end
	end)
	return card
end

local function selectTab(name: string)
	current = name
	for tab, page in pages do
		page.Visible = tab == name
	end
	local button = tabButtons[name]
	if button and underline then
		underline.Parent = button
	end
end

local function build(parent: Instance)
	local g = Instance.new("ScreenGui")
	g.Name = "ShopGui"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 12

	local p = UiStyle.Panel({
		Name = "ShopPanel",
		Title = "SHOP",
		Color = C.Gold,
		Size = UDim2.fromOffset(860, 540),
		Parent = g,
	})
	p.Visible = false
	scaled(p)
	p.Close.Activated:Connect(function()
		p.Visible = false
	end)
	local body = p.Body

	-- tab row
	local row = Instance.new("Frame")
	row.Name = "Tabs"
	row.BackgroundTransparency = 1
	row.Position = UDim2.fromOffset(8, 8)
	row.Size = UDim2.new(1, -16, 0, 56)
	row.ZIndex = 12
	row.Parent = body
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = row

	local bar = Instance.new("Frame")
	bar.Name = "Selected"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 1, 4)
	bar.Size = UDim2.new(0.7, 0, 0, 5)
	bar.BackgroundColor3 = C.White
	bar.ZIndex = 30
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = bar
	underline = bar

	local items = {}
	for _, key in Monetization.PassOrder do
		local item = Monetization.Passes[key]
		if item then
			table.insert(items, { "Pass", key, item })
		end
	end
	for _, key in Monetization.ProductOrder do
		local item = Monetization.Products[key]
		if item then
			table.insert(items, { "Product", key, item })
		end
	end

	for i, tab in Monetization.Tabs do
		local style = TAB_STYLE[tab] or { Color = C.Blue, Logo = tab }
		local tb = UiStyle.Button({
			Name = tab,
			Text = tab,
			Logo = style.Logo,
			Color = style.Color,
			Size = UDim2.fromOffset(150, 50),
			LayoutOrder = i,
			ZIndex = 13,
			MaxTextSize = 26,
			Parent = row,
		})
		tb.Activated:Connect(function()
			selectTab(tab)
		end)
		tabButtons[tab] = tb

		local page = Instance.new("ScrollingFrame")
		page.Name = "Page_" .. tab
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Position = UDim2.fromOffset(6, 76)
		page.Size = UDim2.new(1, -12, 1, -82)
		page.CanvasSize = UDim2.new()
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollingDirection = Enum.ScrollingDirection.Y
		page.ScrollBarThickness = 8
		page.ScrollBarImageColor3 = C.White
		page.ZIndex = 12
		page.Visible = false
		page.Parent = body
		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.fromOffset(CARD.X, CARD.Y)
		grid.CellPadding = UDim2.fromOffset(16, 18)
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.Parent = page
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 14)
		pad.PaddingBottom = UDim.new(0, 14)
		pad.Parent = page
		pages[tab] = page

		local n = 0
		for _, entry in items do
			if entry[3].Tab == tab then
				n += 1
				makeCard(entry[1], entry[2], entry[3], UiStyle.Darken(style.Color, 0.15), n).Parent = page
			end
		end
	end

	toastLabel = UiStyle.Label({
		Name = "Toast",
		Text = "",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.fromOffset(560, 36),
		TextColor3 = C.Yellow,
		MaxTextSize = 28,
		ZIndex = 40,
		Parent = p,
	})

	panel = p
	gui = g
	selectTab(current)
	g.Parent = parent
end

function ShopController.Start()
	local player = Players.LocalPlayer
	local Purchase = require(ReplicatedStorage.Shared.Util.Purchase)
	buyPass = Purchase.Pass
	buyProduct = Purchase.Product
	priceText = Purchase.PriceText
	owns = function(key)
		return player:GetAttribute("Pass_" .. key) == true
	end
	watchOwned = function(key, fn)
		player:GetAttributeChangedSignal("Pass_" .. key):Connect(fn)
	end
	build(player:WaitForChild("PlayerGui"))
end

function ShopController.Toggle()
	if panel then
		panel.Visible = not panel.Visible
	end
end

-- Open straight to a tab, e.g. ShopController.Open("Eggs")
function ShopController.Open(tab: string?)
	if not panel then
		return
	end
	if tab and pages[tab] then
		selectTab(tab)
	end
	panel.Visible = true
end

return ShopController


```


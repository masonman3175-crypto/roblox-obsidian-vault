---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - StarterPlayer.StarterPlayerScripts.Controllers.PetsController

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `StarterPlayer.StarterPlayerScripts.Controllers.PetsController`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [PetsController.luau](../Files/Studio%20Snapshot/Project%20Source/StarterPlayer/StarterPlayerScripts/Controllers/PetsController.luau)

```luau
-- Pet inventory panel: grid of pet cards, click to equip/unequip, Equip Best.
-- Reads the "PetInv" / "PetSlots" / "Mult_Pets" player attributes; the server owns all changes.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)
local PetVisual = require(ReplicatedStorage.Shared.Util.PetVisual)
local PetDesigns = require(ReplicatedStorage.Shared.Config.PetDesigns)
local UiStyle = require(script.Parent.UiStyle)

local PetsController = {}

local C = UiStyle.Colors
local CARD = Vector2.new(112, 136)

local gui: ScreenGui? = nil
local panel: Frame? = nil
local grid: ScrollingFrame? = nil
local info: TextLabel? = nil
local emptyLabel: TextLabel? = nil
local dirty = true
local onEquip: (string, boolean) -> () = function() end
local onEquipBest: () -> () = function() end
local readState: () -> ({ any }, number, number) = function()
	return {}, PetsConfig.BaseSlots, 1
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

local function fmt(n: number): string
	if n >= 1000 then
		return (string.format("%.1fk", n / 1000):gsub("%.0k$", "k"))
	end
	local s = string.format("%.2f", n):gsub("0+$", "")
	return (s:gsub("%.$", ""))
end
PetsController.Format = fmt

-- Pet model posed in a ViewportFrame, facing the camera
function PetsController.Viewport(petId: string, props: { [string]: any }?): ViewportFrame
	local vp = Instance.new("ViewportFrame")
	vp.Name = "Viewport"
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(200, 200, 200)
	vp.LightColor = Color3.fromRGB(255, 255, 255)
	vp.LightDirection = Vector3.new(-1, -1, -1)
	for k, v in props or {} do
		(vp :: any)[k] = v
	end
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0.6, 6.2), Vector3.zero)
	camera.Parent = vp
	vp.CurrentCamera = camera
	local ok, model = pcall(PetVisual.Make, petId, {Preview = true})
	if ok and model then
		model:PivotTo(CFrame.Angles(0, math.pi, 0))
		model.Parent = vp
	end
	return vp
end

local function sortedInventory(inv: { any }): { any }
	local list = table.clone(inv)
	table.sort(list, function(a, b)
		if (a.e == true) ~= (b.e == true) then
			return a.e == true
		end
		local pa = PetsConfig.List[a.p]
		local pb = PetsConfig.List[b.p]
		local powA = if pa then pa.Power else 0
		local powB = if pb then pb.Power else 0
		if powA ~= powB then
			return powA > powB
		end
		return tostring(a.u) < tostring(b.u)
	end)
	return list
end

local function makeCard(entry: any, order: number): TextButton
	local pet = PetsConfig.List[entry.p] or { Name = tostring(entry.p), Rarity = "Common", Power = 0 }
	local rarity = PetsConfig.Rarities[pet.Rarity] or PetsConfig.Rarities.Common
	local modelMassive = PetDesigns.List[entry.p] and PetDesigns.List[entry.p].Size >= 10
	local card = UiStyle.Button({
		Name = "Pet_" .. tostring(entry.u),
		Text = pet.Name,
		Shape = "Square",
		Color = UiStyle.Darken(rarity.Color, 0.25),
		Size = UDim2.fromOffset(CARD.X, CARD.Y),
		LayoutOrder = order,
		MaxTextSize = 18,
		StrokeThickness = 2,
		ZIndex = 12,
	})
	-- green outline when equipped, rarity-tinted otherwise
	local lipStroke = card.Lip:FindFirstChildOfClass("UIStroke")
	if lipStroke then
		lipStroke.Color = if entry.e then C.Green else UiStyle.Darken(rarity.Color, 0.6)
		lipStroke.Thickness = if entry.e then 4 else 3
	end
	card.Label.AnchorPoint = Vector2.new(0.5, 1)
	card.Label.Position = UDim2.new(0.5, 0, 1, -8)
	card.Label.Size = UDim2.fromScale(0.92, 0.17)

	PetsController.Viewport(entry.p, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.1),
		Size = UDim2.fromScale(0.9, 0.6),
		ZIndex = 18,
		Parent = card,
	})

	UiStyle.Label({
		Name = "Power",
		Text = "+" .. fmt(pet.Power),
		TextColor3 = C.Yellow,
		Position = UDim2.fromOffset(6, 4),
		Size = UDim2.new(0.6, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxTextSize = 18,
		StrokeThickness = 2,
		ZIndex = 19,
		Parent = card,
	})
	UiStyle.Label({
		Name = "Rarity",
		Text = (if modelMassive then "HUGE · " else "") .. pet.Rarity,
		TextColor3 = rarity.Color,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -30),
		Size = UDim2.new(0.9, 0, 0, 14),
		MaxTextSize = 14,
		StrokeThickness = 2,
		ZIndex = 19,
		Parent = card,
	})

	-- equipped checkmark reuses the button badge
	local badge = card.Badge
	badge.BackgroundColor3 = C.Green
	badge.Size = UDim2.fromOffset(30, 30)
	badge.Text.Text = "✓"
	badge.Visible = entry.e == true

	local busy = false
	card.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		onEquip(entry.u, not entry.e)
		task.delay(0.3, function()
			busy = false
		end)
	end)
	return card
end

local function render()
	if not grid or not info or not emptyLabel then
		return
	end
	dirty = false
	local inv, slots, mult = readState()
	for _, child in grid:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local equipped = 0
	for i, entry in sortedInventory(inv) do
		if entry.e then
			equipped += 1
		end
		makeCard(entry, i).Parent = grid
	end
	info.Text = string.format("Equipped %d/%d   Pets x%s   %d/%d", equipped, slots, fmt(mult), #inv, PetsConfig.MaxInventory)
	emptyLabel.Visible = #inv == 0
end

local function build(parent: Instance)
	local g = Instance.new("ScreenGui")
	g.Name = "PetsGui"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 10

	local p = UiStyle.Panel({
		Name = "PetsPanel",
		Title = "🐾 Pets",
		Color = C.Purple,
		Size = UDim2.fromOffset(700, 470),
		Parent = g,
	})
	p.Visible = false
	scaled(p)
	p.Close.Activated:Connect(function()
		p.Visible = false
	end)
	local body = p.Body

	info = UiStyle.Label({
		Name = "Info",
		Text = "",
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -210, 0, 32),
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxTextSize = 24,
		ZIndex = 12,
		Parent = body,
	})
	local best = UiStyle.Button({
		Name = "EquipBest",
		Text = "Equip Best",
		Icon = "⭐",
		Color = C.Green,
		Size = UDim2.fromOffset(180, 46),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 4),
		Studs = false,
		ZIndex = 12,
		Parent = body,
	})
	best.Activated:Connect(function()
		onEquipBest()
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Grid"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(6, 58)
	scroll.Size = UDim2.new(1, -12, 1, -64)
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = C.White
	scroll.ZIndex = 12
	scroll.Parent = body
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(CARD.X, CARD.Y)
	layout.CellPadding = UDim2.fromOffset(12, 14)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = scroll
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = scroll
	grid = scroll

	emptyLabel = UiStyle.Label({
		Name = "Empty",
		Text = "Hatch eggs to get pets!",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromOffset(420, 44),
		MaxTextSize = 34,
		ZIndex = 13,
		Parent = body,
	})
	emptyLabel.Visible = false

	-- only rebuild cards while the panel is open
	p:GetPropertyChangedSignal("Visible"):Connect(function()
		if p.Visible and dirty then
			render()
		end
	end)

	panel = p
	gui = g
	g.Parent = parent
end

local function markDirty()
	dirty = true
	if panel and panel.Visible then
		render()
	end
end

function PetsController.Start()
	local player = Players.LocalPlayer
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local equipRemote = remotes:WaitForChild("EquipPet")
	local bestRemote = remotes:WaitForChild("EquipBest")
	onEquip = function(uid, equip)
		equipRemote:FireServer(uid, equip)
	end
	onEquipBest = function()
		bestRemote:FireServer()
	end
	readState = function()
		local inv = {}
		local raw = player:GetAttribute("PetInv")
		if type(raw) == "string" and raw ~= "" then
			local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
			if ok and type(decoded) == "table" then
				inv = decoded
			end
		end
		local slots = player:GetAttribute("PetSlots") or PetsConfig.BaseSlots
		local mult = player:GetAttribute("Mult_Pets")
		if type(mult) ~= "number" then
			local ids = {}
			for _, entry in inv do
				if entry.e then
					table.insert(ids, entry.p)
				end
			end
			mult = PetsConfig.Multiplier(ids)
		end
		return inv, slots, mult
	end
	build(player:WaitForChild("PlayerGui"))
	for _, name in { "PetInv", "PetSlots", "Mult_Pets" } do
		player:GetAttributeChangedSignal(name):Connect(markDirty)
	end
end

function PetsController.Toggle()
	if panel then
		panel.Visible = not panel.Visible
	end
end

function PetsController.Open()
	if panel then
		panel.Visible = true
	end
end

-- Edit-mode visual check only: builds the open panel with fake pets under parent
function PetsController.Preview(parent: Instance, inv: { any }): ScreenGui?
	readState = function()
		return inv, PetsConfig.BaseSlots, 7.45
	end
	build(parent)
	if panel then
		panel.Visible = true
	end
	render()
	return gui
end

return PetsController


```


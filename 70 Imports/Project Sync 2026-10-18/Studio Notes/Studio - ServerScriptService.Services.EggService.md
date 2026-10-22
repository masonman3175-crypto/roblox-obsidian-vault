---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Services.EggService

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Services.EggService`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [EggService.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Services/EggService.luau)

```luau
-- Egg stands, hatching (odds on the board), pet inventory and equipping.
-- Everything is decided here; the client only plays the hatch animation.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")

local Config = ReplicatedStorage.Shared.Config
local Eggs = require(Config.Eggs)
local PetsConfig = require(Config.Pets)
local Zones = require(Config.Zones)
local Monetization = require(Config.Monetization)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local EggService = {}

local HATCH_COOLDOWN = 2.5
local AUTO_INTERVAL = 3.5
local AUTO_RANGE = 22
local rng = Random.new()
local lastHatch = {}
local stands = {}

local function power(id)
	local p = PetsConfig.List[id]
	return if p then p.Power else 0
end

-- Equip the strongest pets up to the slot limit
function EggService.EquipBest(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local sorted = table.clone(profile.PetInv)
	table.sort(sorted, function(a, b)
		return power(a.p) > power(b.p)
	end)
	local slots = StatService.PetSlots(player)
	for _, entry in profile.PetInv do
		entry.e = false
	end
	for i = 1, math.min(slots, #sorted) do
		sorted[i].e = true
	end
	StatService.Refresh(player)
end

local function onEquip(player, uid, equip)
	local profile = DataService.Get(player)
	if not profile or typeof(uid) ~= "string" or typeof(equip) ~= "boolean" then
		return
	end
	local target = nil
	local equipped = 0
	for _, entry in profile.PetInv do
		if entry.u == uid then
			target = entry
		end
		if entry.e then
			equipped += 1
		end
	end
	if not target or target.e == equip then
		return
	end
	if equip and equipped >= StatService.PetSlots(player) then
		Remotes.Notify:FireClient(player, "All pet slots full! Unequip one or get +3 Pet Slots")
		return
	end
	target.e = equip
	StatService.Refresh(player)
end

-- free = true for the paid Mega Egg (already paid in Robux)
function EggService.Hatch(player, eggId, count, isAuto, free)
	local profile = DataService.Get(player)
	local egg = Eggs.List[eggId]
	if not profile or not egg then
		return false
	end
	if egg.World > StatService.AllowedWorld(profile) then
		Remotes.Notify:FireClient(player, "Unlock " .. Zones.List[egg.World].Name .. " World first")
		return false
	end
	if #profile.PetInv + count > PetsConfig.MaxInventory and not free then
		Remotes.Notify:FireClient(player, "Pet inventory full (" .. PetsConfig.MaxInventory .. ")")
		return false
	end
	-- Paid eggs must only be hatched after a processed receipt.
	if egg.ProductKey and not free then
		return false
	end
	if not free then
		local cost = egg.Cost * count
		if profile.Coins < cost then
			if not isAuto then
				Remotes.Notify:FireClient(player, "Need " .. Format.Number(cost) .. " Coins. Punch the dummy!")
			end
			return false
		end
		profile.Coins -= cost
	end
	local lucky = StatService.IsLucky(player)
	local hatched = {}
	for _ = 1, count do
		local id = Eggs.Roll(eggId, lucky, rng)
		table.insert(profile.PetInv, {u = tostring(profile.NextPetUid), p = id, e = false})
		profile.NextPetUid += 1
		table.insert(hatched, id)
	end
	EggService.EquipBest(player)
	Remotes.HatchFx:FireClient(player, eggId, hatched, isAuto)
	for _, id in hatched do
		local rarity = PetsConfig.List[id].Rarity
		if rarity == "Legendary" or rarity == "Mythic" then
			for _, other in Players:GetPlayers() do
				Remotes.Notify:FireClient(other, player.DisplayName .. " hatched a " .. string.upper(rarity) .. " " .. PetsConfig.List[id].Name .. "!")
			end
		end
	end
	return true
end

local function tryHatch(player, eggId, count)
	local now = os.clock()
	if lastHatch[player] and now - lastHatch[player] < HATCH_COOLDOWN then
		return
	end
	lastHatch[player] = now
	local requestedEgg = Eggs.List[eggId]
	if not requestedEgg or requestedEgg.ProductKey then
		return
	end
	if count>1 and not StatService.OwnsPass(player,"TripleHatch") then
		Remotes.Notify:FireClient(player,"Triple Hatch pass required; choose Hatch 1 or open the shop")
		return
	end
	EggService.Hatch(player, eggId, count, false, false)
end

-- Cosmetic factory only: hatching, currency, pass checks and odds are unchanged.
local function eggModel(eggId)
	return require(ReplicatedStorage.Shared.Util.EggVisual).Make(eggId)
end

local function oddsBoard(stand, eggId)
	local egg = Eggs.List[eggId]
	local price = if egg.ProductKey then "R$" .. tostring(Monetization.Products[egg.ProductKey].Price) else Format.Number(egg.Cost) .. " Coins"
	local bb = Instance.new("BillboardGui")
	bb.Name = "Odds"
	bb.Adornee = stand
	bb.Size = UDim2.fromOffset(224, 218)
	-- World-up positioning must not tilt into the portal frames with the camera.
	bb.StudsOffsetWorldSpace = Vector3.new(0, 12, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 70
	bb.LightInfluence = 0
	bb:SetAttribute("EggId", eggId)
	bb:SetAttribute("EggDisplayVersion", 2)
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromScale(1, 1)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0
	card.Parent = bb
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card
	local border = Instance.new("UIStroke")
	border.Color = Zones.List[egg.World].Color
	border.Thickness = 2
	border.Parent = card
	local function label(name, text, position, size, color, align)
		local t = Instance.new("TextLabel")
		t.Name = name
		t.BackgroundTransparency = 1
		t.Position = position
		t.Size = size
		t.Font = Enum.Font.FredokaOne
		t.TextColor3 = color
		t.TextStrokeColor3 = Color3.fromRGB(12, 12, 22)
		t.TextStrokeTransparency = 0.12
		t.Text = text
		t.TextScaled = true
		t.TextWrapped = false
		t.TextXAlignment = align or Enum.TextXAlignment.Center
		t.ZIndex = 2
		local limit = Instance.new("UITextSizeConstraint")
		limit.MinTextSize = 9
		limit.MaxTextSize = 23
		limit.Parent = t
		t.Parent = card
		return t
	end
	label("EggName", string.upper(egg.Name), UDim2.new(0, 8, 0, 8), UDim2.new(1, -16, 0, 28), Color3.new(1,1,1))
	label("Price", price, UDim2.new(0, 8, 0, 38), UDim2.new(1, -16, 0, 26), Color3.fromRGB(255,216,74))
	-- Separate plain-text rows avoid an all-or-nothing rich-text block on join.
	local rowHeight = 138 / #egg.Pets
	for i, entry in egg.Pets do
		local pet = PetsConfig.List[entry.Id]
		local y = 69 + (i-1)*rowHeight
		local color = PetsConfig.Rarities[pet.Rarity].Color
		label("Pet_"..i, pet.Name, UDim2.new(0,10,0,y), UDim2.new(.73,-12,0,rowHeight), color, Enum.TextXAlignment.Left)
		label("Chance_"..i, tostring(entry.Chance).."%", UDim2.new(.73,0,0,y), UDim2.new(.27,-10,0,rowHeight), Color3.new(1,1,1), Enum.TextXAlignment.Right)
	end
	bb.Parent = stand
end

local function prompt(stand, name, action, key, hold)
	local p = Instance.new("ProximityPrompt")
	p.Name = name
	p.ActionText = action
	p.ObjectText = ""
	p.HoldDuration = hold
	p.KeyboardKeyCode = key
	p.MaxActivationDistance = 14
	p.RequiresLineOfSight = false
	p.Parent = stand
	return p
end

local function setupStand(stand)
	local eggId = stand:GetAttribute("EggId")
	local egg = eggId and Eggs.List[eggId]
	if not egg then
		return
	end
	stands[stand] = eggId
	local color = if egg.ProductKey then Color3.fromRGB(255, 200, 40) else Zones.List[egg.World].Color
	for _, child in stand:GetChildren() do
		if child.Name == "EggPreview" or child.Name == "Egg" or child.Name == "Odds" or child:IsA("ProximityPrompt") then child:Destroy() end
	end
	local model = eggModel(eggId)
	model:PivotTo(stand.CFrame * CFrame.new(0, stand.Size.Y / 2 + 3.4, 0))
	model.Parent = stand
	game:GetService("CollectionService"):AddTag(model, "RemodeledEgg")
	oddsBoard(stand, eggId)
	-- Exactly one readable world prompt; batch hatching lives inside the egg menu.
	prompt(stand, "OpenEggPrompt", "Open Egg", Enum.KeyCode.E, 0).Triggered:Connect(function(player)
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and (root.Position-stand.Position).Magnitude<=18 then
			Remotes.OpenEgg:FireClient(player,eggId)
		end
	end)
end

local function nearestStand(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local best, bestDist = nil, AUTO_RANGE
	for stand, eggId in stands do
		if not Eggs.List[eggId].ProductKey then
			local d = (stand.Position - root.Position).Magnitude
			if d < bestDist then
				best, bestDist = eggId, d
			end
		end
	end
	return best
end

function EggService.Start()
	for _,name in {"OpenEgg","RequestHatch"} do
		if not Remotes:FindFirstChild(name) then local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=Remotes end
	end
	Remotes.RequestHatch.OnServerEvent:Connect(function(player,eggId,count)
		if typeof(eggId)~="string" or (count~=1 and count~=3) then return end
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for stand,id in stands do
			if id==eggId and (root.Position-stand.Position).Magnitude<=22 then tryHatch(player,eggId,count);return end
		end
	end)
	for _, stand in workspace:WaitForChild("Map"):WaitForChild("Gameplay"):GetDescendants() do
		if stand:IsA("BasePart") and stand:GetAttribute("EggId") then
			setupStand(stand)
		end
	end
	Remotes.EquipPet.OnServerEvent:Connect(onEquip)
	Remotes.EquipBest.OnServerEvent:Connect(EggService.EquipBest)
	Players.PlayerRemoving:Connect(function(player)
		lastHatch[player] = nil
	end)

	-- Auto Hatch pass: hatches the closest egg while you stand near it
	task.spawn(function()
		while true do
			task.wait(AUTO_INTERVAL)
			for _, player in Players:GetPlayers() do
				local profile = DataService.Get(player)
				if profile and profile.AutoHatchOn and StatService.OwnsPass(player, "AutoHatch") then
					local eggId = nearestStand(player)
					if eggId then
						local count = if StatService.OwnsPass(player, "TripleHatch") then 3 else 1
						EggService.Hatch(player, eggId, count, true, false)
					end
				end
			end
		end
	end)
end

return EggService



```


-- One saved profile per player. Never overwrites data after a failed load.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataService = {}

local STORE_NAME = "StatSim_v1"
local AUTOSAVE_SECONDS = 120
local MAX_RECEIPTS = 50

local store = nil
local profiles = {}
local canSave = {}
local loadedEvent = Instance.new("BindableEvent")
DataService.ProfileLoaded = loadedEvent.Event

local function defaults()
	return {
		Strength = 0,
		TotalStrength = 0,
		XP = 0,
		Level = 1,
		Rebirths = 0,
		BoostEnd = 0,
		AutoTrainOn = true,
		Coins = 0,
		BestPunch = 0,
		PetInv = {},
		NextPetUid = 1,
		CoinBoostEnd = 0,
		LuckEnd = 0,
		AutoPunchOn = true,
		AutoHatchOn = true,
		WorldUnlocked = 1,
		Receipts = {},
		ReceiptOrder = {},
	}
end

local function reconcile(data)
	for key, value in defaults() do
		if data[key] == nil then
			data[key] = value
		end
	end
	return data
end

local function withRetries(fn)
	local attempts = if RunService:IsStudio() then 1 else 3
	local lastErr = nil
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		if attempt < attempts then
			task.wait(2 ^ (attempt - 1))
		end
	end
	return false, lastErr
end

local function key(player)
	return "player_" .. player.UserId
end

function DataService.Load(player)
	local ok, data = false, nil
	if store then
		ok, data = withRetries(function()
			return store:GetAsync(key(player))
		end)
	end
	if not player.Parent then
		return
	end
	if ok then
		profiles[player] = reconcile(data or defaults())
		canSave[player] = true
	elseif RunService:IsStudio() then
		warn("[DataService] DataStore not available in Studio. Using temp data, nothing saves. Turn on Game Settings > Security > Studio API access to test saving.")
		profiles[player] = defaults()
		canSave[player] = false
	else
		warn("[DataService] Load failed for " .. player.UserId .. ": " .. tostring(data))
		player:Kick("Could not load your data. Please rejoin.")
		return
	end
	loadedEvent:Fire(player, profiles[player])
end

-- Returns true when the profile is safely stored (or saving is off in Studio)
function DataService.Save(player)
	local profile = profiles[player]
	if not profile then
		return false
	end
	if not canSave[player] then
		return true
	end
	local ok, err = withRetries(function()
		store:UpdateAsync(key(player), function()
			return profile
		end)
	end)
	if not ok then
		warn("[DataService] Save failed for " .. player.UserId .. ": " .. tostring(err))
	end
	return ok
end

function DataService.Get(player)
	return profiles[player]
end

function DataService.HasReceipt(profile, purchaseId)
	return profile.Receipts[purchaseId] == true
end

function DataService.AddReceipt(profile, purchaseId)
	profile.Receipts[purchaseId] = true
	table.insert(profile.ReceiptOrder, purchaseId)
	while #profile.ReceiptOrder > MAX_RECEIPTS do
		local old = table.remove(profile.ReceiptOrder, 1)
		profile.Receipts[old] = nil
	end
end

function DataService.Start()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)
	if ok then
		store = result
	end

	Players.PlayerAdded:Connect(DataService.Load)
	for _, player in Players:GetPlayers() do
		task.spawn(DataService.Load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		DataService.Save(player)
		profiles[player] = nil
		canSave[player] = nil
	end)

	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				DataService.Save(player)
				pending -= 1
			end)
		end
		while pending > 0 do
			task.wait()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for _, player in Players:GetPlayers() do
				task.spawn(DataService.Save, player)
			end
		end
	end)
end

return DataService

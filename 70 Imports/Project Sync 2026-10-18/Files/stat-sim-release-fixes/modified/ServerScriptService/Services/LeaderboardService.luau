-- Global top 10 by lifetime Strength on the board in Workspace.Map.Leaderboard.
-- Falls back to players in this server if the OrderedDataStore is not available.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Util.Format)
local DataService = require(script.Parent.DataService)

local LeaderboardService = {}

local REFRESH_SECONDS = 60
local TOP = 10
local names = {}

local function nameFor(userId)
	if names[userId] then
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = if ok then name else "Player"
	return names[userId]
end

local function getList()
	local board = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Leaderboard")
	local gui = board and board:FindFirstChild("Board") and board.Board:FindFirstChild("SurfaceGui")
	return gui and gui:FindFirstChild("List")
end

local function render(rows)
	local list = getList()
	if not list then
		return
	end
	for _, child in list:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	for rank, row in rows do
		local label = Instance.new("TextLabel")
		label.Name = "Row" .. rank
		label.LayoutOrder = rank
		label.Size = UDim2.new(1, 0, 0.085, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = if rank == 1 then Color3.fromRGB(255, 215, 60) elseif rank <= 3 then Color3.fromRGB(220, 230, 255) else Color3.new(1, 1, 1)
		label.Text = "#" .. rank .. "  " .. row.Name .. "  " .. Format.Number(row.Value)
		label.Parent = list
	end
end

local function serverRows()
	local rows = {}
	for _, player in Players:GetPlayers() do
		local profile = DataService.Get(player)
		if profile then
			table.insert(rows, {Name = player.Name, Value = profile.TotalStrength})
		end
	end
	table.sort(rows, function(a, b)
		return a.Value > b.Value
	end)
	while #rows > TOP do
		table.remove(rows)
	end
	return rows
end

local function refresh(store)
	if store then
		for _, player in Players:GetPlayers() do
			local profile = DataService.Get(player)
			if profile then
				pcall(store.SetAsync, store, tostring(player.UserId), math.floor(profile.TotalStrength))
			end
		end
		local ok, pages = pcall(store.GetSortedAsync, store, false, TOP)
		if ok then
			local rows = {}
			for _, entry in pages:GetCurrentPage() do
				table.insert(rows, {Name = nameFor(tonumber(entry.key)), Value = entry.value})
			end
			render(rows)
			return
		end
	end
	render(serverRows())
end

function LeaderboardService.Start()
	local ok, store = pcall(DataStoreService.GetOrderedDataStore, DataStoreService, "TopStrength_v1")
	if not ok then
		store = nil
	end
	task.spawn(function()
		task.wait(5)
		while true do
			refresh(store)
			task.wait(REFRESH_SECONDS)
		end
	end)
end

return LeaderboardService


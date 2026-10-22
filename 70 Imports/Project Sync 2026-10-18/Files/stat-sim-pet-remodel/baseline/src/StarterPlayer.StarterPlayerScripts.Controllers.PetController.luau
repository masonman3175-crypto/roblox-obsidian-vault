-- Draws every player's equipped pets floating around them (from "PetInv").
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetVisual = require(ReplicatedStorage.Shared.Util.PetVisual)

local PetController = {}

local folder = Instance.new("Folder")
folder.Name = "PetFollowers"
local followers = {}
local signatures = {}

local function clear(owner)
	for _, model in followers[owner] or {} do
		model:Destroy()
	end
	followers[owner] = {}
end

local function equippedIds(owner)
	local ok, inv = pcall(HttpService.JSONDecode, HttpService, owner:GetAttribute("PetInv") or "[]")
	local ids = {}
	if ok and type(inv) == "table" then
		for _, entry in inv do
			if entry.e then
				table.insert(ids, entry.p)
			end
		end
	end
	table.sort(ids)
	return ids
end

local function rebuild(owner)
	local ids = equippedIds(owner)
	local signature = table.concat(ids, ",")
	if signatures[owner] == signature then
		return
	end
	signatures[owner] = signature
	clear(owner)
	for _, id in ids do
		local model = PetVisual.Make(id)
		model.Parent = folder
		table.insert(followers[owner], model)
	end
end

local function track(owner)
	followers[owner] = {}
	rebuild(owner)
	owner:GetAttributeChangedSignal("PetInv"):Connect(function()
		rebuild(owner)
	end)
end

function PetController.Start()
	folder.Parent = workspace
	for _, owner in Players:GetPlayers() do
		track(owner)
	end
	Players.PlayerAdded:Connect(track)
	Players.PlayerRemoving:Connect(function(owner)
		clear(owner)
		followers[owner] = nil
		signatures[owner] = nil
	end)

	RunService.RenderStepped:Connect(function()
		local t = os.clock()
		for owner, models in followers do
			local character = owner.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local scale = character:GetScale()
				local count = #models
				for i, model in models do
					-- half circle behind the player, bobbing, facing forward
					local angle = math.rad(-70 + (i - 0.5) * (140 / math.max(count, 1)))
					local radius = 4.5 * scale + 1
					local offset = Vector3.new(math.sin(angle) * radius, 0.3 * scale + math.sin(t * 3 + i) * 0.5, math.cos(angle) * radius)
					local goal = root.CFrame * CFrame.new(offset)
					model:PivotTo(model:GetPivot():Lerp(goal, 0.15))
				end
			end
		end
	end)
end

return PetController

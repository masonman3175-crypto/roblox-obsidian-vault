-- Gamepass ownership + the ONE ProcessReceipt for the whole game.
-- Grants happen only here, on the server. The client only opens Roblox prompts.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage.Shared.Config
local Monetization = require(Config.Monetization)
local Zones = require(Config.Zones)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)
local RebirthService = require(script.Parent.RebirthService)
local PunchService = require(script.Parent.PunchService)
local EggService = require(script.Parent.EggService)

local MonetizationService = {}

local function grantStrength(player, product)
	StatService.AddStrength(player, StatService.Gain(player) * product.Clicks)
end

local function grantCoins(player, product)
	StatService.AddCoins(player, math.max(PunchService.CoinsPerPunch(player), 10) * product.Punches)
end

local function timed(field)
	return function(player, product)
		local profile = DataService.Get(player)
		profile[field] = math.max(profile[field], os.time()) + product.Seconds
		StatService.Refresh(player)
	end
end

local grants = {
	StrengthSmall = grantStrength,
	StrengthMedium = grantStrength,
	StrengthLarge = grantStrength,
	CoinsSmall = grantCoins,
	CoinsMedium = grantCoins,
	CoinsLarge = grantCoins,
	Boost = timed("BoostEnd"),
	CoinBoost = timed("CoinBoostEnd"),
	LuckBoost = timed("LuckEnd"),
	Level = function(player)
		StatService.AddLevels(player, 1)
	end,
	RebirthSkip = function(player)
		RebirthService.DoRebirth(player, false)
	end,
	WorldSkip = function(player)
		local profile = DataService.Get(player)
		profile.WorldUnlocked = math.min(StatService.AllowedWorld(profile) + 1, #Zones.List)
		StatService.Refresh(player)
	end,
	MegaEgg = function(player)
		EggService.Hatch(player, "Mega", 1, false, true)
	end,
}

local function processReceipt(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local profile = DataService.Get(player)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Already granted earlier: only confirm once it is saved
	if DataService.HasReceipt(profile, info.PurchaseId) then
		if DataService.Save(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productKey, product = Monetization.FindProduct(info.ProductId)
	if not productKey or not grants[productKey] then
		warn("[Monetization] Unknown product " .. tostring(info.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok, err = pcall(grants[productKey], player, product)
	if not ok then
		warn("[Monetization] Grant failed: " .. tostring(err))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	DataService.AddReceipt(profile, info.PurchaseId)
	Remotes.Notify:FireClient(player, "Thanks! " .. product.Name .. " received")

	if DataService.Save(player) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function checkPasses(player)
	for passKey, pass in Monetization.Passes do
		if pass.Id ~= 0 then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.Id)
			if ok and owns then
				StatService.SetPass(player, passKey, true)
			end
		end
	end
end

-- Studio only: buttons whose Id is still 0 grant for free so we can test them.
-- Live servers ignore this remote completely.
local function onStudioPurchase(player, kind, itemKey)
	if not RunService:IsStudio() then
		return
	end
	if typeof(kind) ~= "string" or typeof(itemKey) ~= "string" or not DataService.Get(player) then
		return
	end
	if kind == "Pass" then
		local pass = Monetization.Passes[itemKey]
		if pass and pass.Id == 0 then
			StatService.SetPass(player, itemKey, true)
			Remotes.Notify:FireClient(player, "[Studio test] " .. pass.Name .. " unlocked")
		end
	elseif kind == "Product" then
		local product = Monetization.Products[itemKey]
		if product and product.Id == 0 and grants[itemKey] then
			grants[itemKey](player, product)
			Remotes.Notify:FireClient(player, "[Studio test] " .. product.Name .. " received")
		end
	end
end

function MonetizationService.Start()
	MarketplaceService.ProcessReceipt = processReceipt
	Remotes.StudioPurchase.OnServerEvent:Connect(onStudioPurchase)
	DataService.ProfileLoaded:Connect(checkPasses)

	-- Fired by Roblox on the server, so the client cannot fake it
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if not purchased or passId == 0 then
			return
		end
		for passKey, pass in Monetization.Passes do
			if pass.Id == passId then
				StatService.SetPass(player, passKey, true)
				Remotes.Notify:FireClient(player, "Thanks! " .. pass.Name .. " unlocked")
			end
		end
	end)
end

return MonetizationService

-- Gamepass ownership + the ONE ProcessReceipt for the whole game.
-- Grants happen only here, on the server. The client only opens Roblox prompts.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		return RebirthService.DoRebirth(player, false)
	end,
	WorldSkip = function(player)
		local profile = DataService.Get(player)
		if StatService.AllowedWorld(profile) >= #Zones.List then return false end
		profile.WorldUnlocked = StatService.AllowedWorld(profile) + 1
		StatService.Refresh(player)
	end,
	MegaEgg = function(player)
		return EggService.Hatch(player, "Mega", 1, false, true)
	end,
	UltraEgg = function(player)
		return EggService.Hatch(player, "Ultra", 1, false, true)
	end,
}

local receiptBusy={}
local function processReceiptUnlocked(info)
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

	local ok, granted = pcall(grants[productKey], player, product)
	if not ok or granted == false then
		warn("[Monetization] Grant deferred: " .. tostring(granted))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	DataService.AddReceipt(profile, info.PurchaseId)
	Remotes.Notify:FireClient(player, "Thanks! " .. product.Name .. " received")

	if DataService.Save(player) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function processReceipt(info)
	local id=tostring(info.PlayerId)
	while receiptBusy[id] do task.wait() end
	receiptBusy[id]=true
	local ok,result=pcall(processReceiptUnlocked,info)
	receiptBusy[id]=nil
	if not ok then warn("[Monetization] Receipt deferred: "..tostring(result));return Enum.ProductPurchaseDecision.NotProcessedYet end
	return result
end

-- Ownership check with retries so a Roblox hiccup on join doesn't hide a pass
local function ownsPass(player, passId)
	for attempt = 1, 3 do
		local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, passId)
		if ok then
			return owns
		end
		if not player.Parent then
			return false
		end
		task.wait(attempt)
	end
	warn("[Monetization] Could not check pass " .. passId .. " for " .. player.UserId)
	return false
end

local function checkPasses(player)
	for passKey, pass in Monetization.Passes do
		if pass.Id ~= 0 then
			task.spawn(function()
				if ownsPass(player, pass.Id) and player.Parent then
					StatService.SetPass(player, passKey, true)
				end
			end)
		end
	end
end

function MonetizationService.Start()
	MarketplaceService.ProcessReceipt = processReceipt
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


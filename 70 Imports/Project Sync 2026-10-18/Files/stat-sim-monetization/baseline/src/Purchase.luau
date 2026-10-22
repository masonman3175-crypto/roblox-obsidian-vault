-- Client helper: open the right Roblox purchase prompt, or in Studio grant
-- Id-0 items through the StudioPurchase remote (the server re-checks IsStudio).
-- The server grants everything; this only opens prompts and reads prices.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Monetization = require(ReplicatedStorage.Shared.Config.Monetization)

local Purchase = {}

local ROBUX = utf8.char(0xE002)
local IS_STUDIO = RunService:IsStudio()
local prices = {}

local function remotes()
	return ReplicatedStorage:WaitForChild("Remotes")
end

-- Returns true if it did something, false + reason otherwise
function Purchase.Pass(passKey)
	local player = Players.LocalPlayer
	local pass = Monetization.Passes[passKey]
	if not pass then
		return false, "Unknown pass"
	end
	if player:GetAttribute("Pass_" .. passKey) then
		return false, "You already own " .. pass.Name
	end
	if pass.Id == 0 then
		if IS_STUDIO then
			remotes().StudioPurchase:FireServer("Pass", passKey)
			return true
		end
		return false, pass.Name .. " is coming soon"
	end
	MarketplaceService:PromptGamePassPurchase(player, pass.Id)
	return true
end

function Purchase.Product(productKey)
	local product = Monetization.Products[productKey]
	if not product then
		return false, "Unknown product"
	end
	if product.Id == 0 then
		if IS_STUDIO then
			remotes().StudioPurchase:FireServer("Product", productKey)
			return true
		end
		return false, product.Name .. " is coming soon"
	end
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, product.Id)
	return true
end

-- Price label: real price from Roblox, "TEST" in Studio for Id 0, "Soon" live
function Purchase.PriceText(kind, key)
	local item = if kind == "Pass" then Monetization.Passes[key] else Monetization.Products[key]
	if not item or item.Id == 0 then
		return if IS_STUDIO then "TEST" else "Soon"
	end
	local cacheKey = kind .. item.Id
	if prices[cacheKey] == nil then
		local infoType = if kind == "Pass" then Enum.InfoType.GamePass else Enum.InfoType.Product
		local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, item.Id, infoType)
		prices[cacheKey] = if ok and info.PriceInRobux then info.PriceInRobux else false
	end
	return if prices[cacheKey] then ROBUX .. prices[cacheKey] else "..."
end

return Purchase

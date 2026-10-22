-- Prompt only verified Creator Dashboard listings; receipts grant products on the server.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Monetization = require(ReplicatedStorage.Shared.Config.Monetization)
local Zones = require(ReplicatedStorage.Shared.Config.Zones)

local Purchase = {}
local listingCache = {}

local function listing(kind, item)
    if item.Id == 0 then return false, "Listing not set up" end
    local infoType = if kind == "Pass" then Enum.InfoType.GamePass else Enum.InfoType.Product
    local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, item.Id, infoType)
    if not ok or not info then return false, "Roblox price unavailable; try again" end
    local actual = info.PriceInRobux
    if type(actual) ~= "number" or actual > Monetization.MaxRobux or actual ~= item.Price then
        return false, "Listing price does not match the shop"
    end
    if info.IsForSale == false then return false, "Item is not on sale" end
    return true
end

function Purchase.Pass(key)
    local player = Players.LocalPlayer
    local item = Monetization.Passes[key]
    if not item then return false, "Unknown pass" end
    if player:GetAttribute("Pass_" .. key) then return false, "Already owned" end
    local ok, reason = listing("Pass", item)
    if not ok then return false, reason end
    local prompted,err=pcall(MarketplaceService.PromptGamePassPurchase,MarketplaceService,player,item.Id)
    if not prompted then return false,"Roblox purchase prompt unavailable; try again" end
    return true
end

function Purchase.Product(key)
    local player = Players.LocalPlayer
    local item = Monetization.Products[key]
    if not item then return false, "Unknown product" end
    if not player:GetAttribute("Loaded") then return false,"Progress is still loading" end
    if not player:GetAttribute("DataPersistent") then return false,"Purchases wait until progress saving is available" end
    if key == "WorldSkip" and (player:GetAttribute("AllowedZone") or 1) >= #Zones.List then
        return false, "All current worlds already unlocked"
    end
    if key == "MegaEgg" or key == "UltraEgg" then
        local ok, policy = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
        if not ok or policy.ArePaidRandomItemsRestricted then
            return false, "Paid random eggs are unavailable for this player"
        end
    end
    local ok, reason = listing("Product", item)
    if not ok then return false, reason end
    local prompted,err=pcall(MarketplaceService.PromptProductPurchase,MarketplaceService,player,item.Id)
    if not prompted then return false,"Roblox purchase prompt unavailable; try again" end
    return true
end

function Purchase.PriceText(kind, key)
    local item = if kind == "Pass" then Monetization.Passes[key] else Monetization.Products[key]
    if not item then return "UNAVAILABLE" end
    if item.Id == 0 then return "COMING SOON" end
    local cacheKey = kind .. tostring(item.Id)
    local cached = listingCache[cacheKey]
    if not cached or os.clock() - cached.time > 60 then
        local ok, reason = listing(kind, item)
        cached = {time = os.clock(), ok = ok, reason = reason}
        listingCache[cacheKey] = cached
    end
    return if cached.ok then "R$" .. item.Price else "UNAVAILABLE"
end

return Purchase


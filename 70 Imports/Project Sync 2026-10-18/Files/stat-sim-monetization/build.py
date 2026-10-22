from pathlib import Path
import re, shutil, hashlib, difflib, json

ROOT = Path(__file__).parent
BASE = ROOT / 'baseline' / 'src'
OUT = ROOT / 'modified' / 'src'
OUT.mkdir(parents=True, exist_ok=True)
for src in BASE.glob('*.luau'):
    shutil.copy2(src, OUT / src.name)

def edit(name, fn):
    p = OUT / name
    old = p.read_text(encoding='utf-8')
    new = fn(old)
    assert new != old, name
    p.write_text(new, encoding='utf-8', newline='\n')

def once(s, a, b):
    assert s.count(a) == 1, (a[:80], s.count(a))
    return s.replace(a, b)

prices = {
    'Double':79, 'AutoTrain':49, 'VIP':99, 'AutoPunch':59,
    'DoubleCoins':49, 'FastWalk':19, 'TripleHatch':39,
    'AutoHatch':69, 'Lucky':59, 'PetSlots':49,
    'GymVIP':19, 'GymMega':39, 'GymAdmin':79,
    'StrengthSmall':5, 'StrengthMedium':15, 'StrengthLarge':49,
    'CoinsSmall':5, 'CoinsMedium':15, 'CoinsLarge':49,
    'Boost':9, 'CoinBoost':9, 'LuckBoost':9, 'Level':9,
    'RebirthSkip':39, 'WorldSkip':59, 'MegaEgg':39, 'UltraEgg':99,
}
created_ids = {
    'StrengthSmall': 3719745475,
    'StrengthMedium': 3719749527,
    'StrengthLarge': 3719749718,
    'CoinsSmall': 3719749809,
}

def monetization(s):
    s = s[s.index('local Monetization = {}'):]
    for key, price in prices.items():
        if key == 'UltraEgg': continue
        pattern = r'\b' + re.escape(key) + r' = \{Id = 0, '
        assert len(re.findall(pattern,s)) == 1, key
        s = re.sub(pattern, f'{key} = {{Id = {created_ids.get(key, 0)}, Price = {price}, ', s)
    s = once(s, '\tMegaEgg = {Id = 0, Price = 39, Tab = "Eggs", Name = "Mega Egg", Description = "70% Diamond Dog, 25% Rainbow Dragon, 5% Golden Cerberus"},',
             '\tMegaEgg = {Id = 0, Price = 39, Tab = "Eggs", Name = "Mega Egg", Description = "One random pet; odds shown below"},\n\tUltraEgg = {Id = 0, Price = 99, Tab = "Eggs", Name = "Ultra Robux Egg", Description = "One random ultra pet; odds shown below"},')
    s = once(s, '"MegaEgg", "LuckBoost"}', '"MegaEgg", "UltraEgg", "LuckBoost"}')
    s = once(s, 'local Monetization = {}', 'local Monetization = {}\nMonetization.MaxRobux = 100')
    return '-- Catalog prices are the intended Creator Dashboard prices; Id=0 means not on sale.\n-- Never grant a purchase from an unbound listing.\n' + s
edit('Monetization.luau',monetization)

def eggs(s):
    return once(s, '\t-- Robux egg: bought with the MegaEgg dev product, odds shown before buying',
        '\tUltra = {Name = "Ultra Robux Egg", World = 1, Cost = 0, ProductKey = "UltraEgg", Pets = {\n\t\t{Id = "CandyHydra", Chance = 65},\n\t\t{Id = "BlizzardDragon", Chance = 25},\n\t\t{Id = "DemonKing", Chance = 10},\n\t}},\n\t-- Robux egg: bought with the MegaEgg dev product, odds shown before buying')
edit('Eggs.luau',eggs)

def eggvisual(s):
    return once(s, '\tMega={Color3.fromRGB(55,48,25),Color3.fromRGB(255,210,73),Color3.fromRGB(255,248,180)},',
        '\tMega={Color3.fromRGB(55,48,25),Color3.fromRGB(255,210,73),Color3.fromRGB(255,248,180)},\n\tUltra={Color3.fromRGB(31,21,69),Color3.fromRGB(169,92,255),Color3.fromRGB(95,255,229)},')
edit('EggVisual.luau',eggvisual)

edit('HatchController.luau', lambda s: once(s,'\tMega = Color3.fromRGB(255, 200, 40),', '\tMega = Color3.fromRGB(255, 200, 40),\n\tUltra = Color3.fromRGB(169, 92, 255),'))

def service(s):
    s = s.replace('local RunService = game:GetService("RunService")','local PolicyService = game:GetService("PolicyService")')
    s = once(s, '\tif not free then\n\t\tlocal cost = egg.Cost * count',
        '\t-- Paid eggs must only be hatched after a processed receipt.\n\tif egg.ProductKey and not free then\n\t\treturn false\n\tend\n\tif not free then\n\t\tlocal cost = egg.Cost * count')
    s = once(s, '\tlastHatch[player] = now\n\tif count > 1',
        '\tlastHatch[player] = now\n\tlocal requestedEgg = Eggs.List[eggId]\n\tif not requestedEgg or requestedEgg.ProductKey then\n\t\treturn\n\tend\n\tif count > 1')
    s = s.replace('\t\telseif RunService:IsStudio() then\n\t\t\tRemotes.Notify:FireClient(player, "Triple Hatch is a pass (free in Studio from the shop)")\n', '')
    a=s.index('local function promptMega(player)')
    b=s.index('\n-- Cosmetic factory',a)
    s=s[:a]+'''local function promptMega(player)
    local product = Monetization.Products.MegaEgg
    if product.Id == 0 then
        Remotes.Notify:FireClient(player, "Mega Egg is not on sale yet")
        return
    end
    local ok, policy = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
    if not ok or policy.ArePaidRandomItemsRestricted then
        Remotes.Notify:FireClient(player, "Paid random eggs are unavailable for this player")
        return
    end
    local infoOk, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, product.Id, Enum.InfoType.Product)
    if not infoOk or not info or type(info.PriceInRobux) ~= "number" or info.PriceInRobux ~= product.Price or info.PriceInRobux > Monetization.MaxRobux then
        Remotes.Notify:FireClient(player, "Mega Egg listing price is not ready")
        return
    end
    MarketplaceService:PromptProductPurchase(player, product.Id)
end
''' + s[b:]
    s=s.replace('"ROBUX EGG"', '"R$" .. tostring(Monetization.Products[egg.ProductKey].Price)')
    return s
edit('EggService.luau',service)

def monservice(s):
    s=s.replace('local RunService = game:GetService("RunService")\n','')
    s=once(s, '\t\tRebirthService.DoRebirth(player, false)', '\t\treturn RebirthService.DoRebirth(player, false)')
    s=once(s, '\t\tprofile.WorldUnlocked = math.min(StatService.AllowedWorld(profile) + 1, #Zones.List)',
        '\t\tif StatService.AllowedWorld(profile) >= #Zones.List then return false end\n\t\tprofile.WorldUnlocked = StatService.AllowedWorld(profile) + 1')
    s=once(s, '\t\tEggService.Hatch(player, "Mega", 1, false, true)', '\t\treturn EggService.Hatch(player, "Mega", 1, false, true)')
    s=once(s, '\tMegaEgg = function(player)\n\t\treturn EggService.Hatch(player, "Mega", 1, false, true)\n\tend,',
        '\tMegaEgg = function(player)\n\t\treturn EggService.Hatch(player, "Mega", 1, false, true)\n\tend,\n\tUltraEgg = function(player)\n\t\treturn EggService.Hatch(player, "Ultra", 1, false, true)\n\tend,')
    s=once(s, '\tlocal ok, err = pcall(grants[productKey], player, product)\n\tif not ok then\n\t\twarn("[Monetization] Grant failed: " .. tostring(err))',
        '\tlocal ok, granted = pcall(grants[productKey], player, product)\n\tif not ok or granted == false then\n\t\twarn("[Monetization] Grant deferred: " .. tostring(granted))')
    a=s.index('-- Studio only: buttons whose Id is still 0 grant for free')
    b=s.index('function MonetizationService.Start()',a)
    s=s[:a]+s[b:]
    s=s.replace('\tRemotes.StudioPurchase.OnServerEvent:Connect(onStudioPurchase)\n','')
    return s
edit('MonetizationService.luau',monservice)

purchase='''-- Prompt only verified Creator Dashboard listings; receipts grant products on the server.
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
    MarketplaceService:PromptGamePassPurchase(player, item.Id)
    return true
end

function Purchase.Product(key)
    local player = Players.LocalPlayer
    local item = Monetization.Products[key]
    if not item then return false, "Unknown product" end
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
    MarketplaceService:PromptProductPurchase(player, item.Id)
    return true
end

function Purchase.PriceText(kind, key)
    local item = if kind == "Pass" then Monetization.Passes[key] else Monetization.Products[key]
    if not item then return "UNAVAILABLE" end
    if item.Id == 0 then return "R$" .. item.Price .. " · SETUP" end
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
'''
(OUT/'Purchase.luau').write_text(purchase,encoding='utf-8',newline='\n')

def uistyle(s):
    at='local function makeBadge(z: number): Frame'
    logo='''-- Original typographic brand mark, built from GUI shapes rather than emoji stickers.
local MARKS = {
    Passes="PASS", Boosts="2X", Coins="C", Eggs="EGG", Gym="GYM",
    Rebirth="REB", Pets="PET", Shop="SHOP", Train="STR", Double="2X",
    AutoTrain="AUTO", VIP="VIP", AutoPunch="PUNCH", DoubleCoins="2X",
    FastWalk="SPD", TripleHatch="3X", AutoHatch="AUTO", Lucky="LUCK",
    PetSlots="+3", GymVIP="VIP", GymMega="25X", GymAdmin="99X",
    StrengthSmall="100", StrengthMedium="500", StrengthLarge="2.5K",
    CoinsSmall="10", CoinsMedium="50", CoinsLarge="250", Boost="2X",
    CoinBoost="2X", LuckBoost="2X", Level="+1", RebirthSkip="REB",
    WorldSkip="NEXT", MegaEgg="MEGA", UltraEgg="ULTRA",
}

function UiStyle.Logo(props: { [string]: any }): Frame
    local z = props.ZIndex or 10
    local color = props.Color or UiStyle.Colors.Gold
    local frame = new("Frame", {
        Name = props.Name or "Logo", Size = props.Size or UDim2.fromOffset(62, 62),
        Position = props.Position or UDim2.new(), AnchorPoint = props.AnchorPoint or Vector2.zero,
        BackgroundColor3 = darken(color, 0.48), ZIndex = z, Parent = props.Parent,
    }, {corner(15), stroke(3, UiStyle.Colors.Outline)})
    local face = new("Frame", {
        Name="Face", Size=UDim2.new(1,-8,1,-10), Position=UDim2.fromOffset(4,3),
        BackgroundColor3=color, ZIndex=z+1, Parent=frame,
    }, {corner(12), new("UIGradient", {Rotation=90, Color=ColorSequence.new(Color3.new(1,1,1), darken(color,0.1))})})
    new("Frame", {
        Name="Underline", AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-4),
        Size=UDim2.new(0.55,0,0,4), BackgroundColor3=UiStyle.Colors.White,
        ZIndex=z+2, Parent=face,
    }, {corner(2)})
    UiStyle.Label({Name="Mark", Text=MARKS[props.Key] or props.Key or "X",
        Size=UDim2.new(1,-6,0.7,0), Position=UDim2.new(0,3,0.12,0),
        MaxTextSize=if #(MARKS[props.Key] or props.Key or "X") > 3 then 22 else 32,
        StrokeThickness=2.5, ZIndex=z+3, Parent=face})
    return frame
end

'''
    s=once(s,at,logo+at)
    s=once(s, 'if props.Icon ~= nil and props.Icon ~= "" then\n\t\tlocal icon = makeIcon(props.Icon, z + 6)',
        'if props.Logo or (props.Icon ~= nil and props.Icon ~= "") then\n\t\tlocal icon = if props.Logo then UiStyle.Logo({Key=props.Logo, Color=color, ZIndex=z+6}) else makeIcon(props.Icon, z + 6)')
    return s
edit('UiStyle.luau',uistyle)

def shop(s):
    a=s.index('local TAB_STYLE = {'); b=s.index('\nlocal RIBBONS',a)
    s=s[:a]+'''local TAB_STYLE = {
    Passes = { Color = C.Purple, Logo = "Passes" },
    Boosts = { Color = C.Red, Logo = "Boosts" },
    Coins = { Color = C.Gold, Logo = "Coins" },
    Eggs = { Color = C.Pink, Logo = "Eggs" },
    Gym = { Color = C.Blue, Logo = "Gym" },
}
''' + s[b:]
    s=once(s,'\tMegaEgg = "Mega",','\tMegaEgg = "Mega",\n\tUltraEgg = "Ultra",')
    s=s.replace('return "TEST"','return "UNAVAILABLE"')
    a=s.index('\tUiStyle.Label({\n\t\tName = "IconText",'); b=s.index('\n\tUiStyle.Label({\n\t\tName = "Title",',a)
    s=s[:a]+'''\tUiStyle.Logo({
        Name = "BrandLogo", Key = key, Color = color,
        Position = UDim2.fromOffset(11, 9), Size = UDim2.fromOffset(62, 62),
        ZIndex = 21, Parent = card,
    })''' + s[b:]
    s=once(s, '\t\telse\n\t\t\trecolor(buy, C.Green)\n\t\t\tbuy.Label.Text = "..."',
        '\t\telse\n\t\t\trecolor(buy, if item.Id == 0 then Color3.fromRGB(115, 115, 135) else C.Green)\n\t\t\tbuy.Label.Text = "..."')
    s=s.replace('Title = "🛒 Shop"','Title = "SHOP"')
    s=s.replace('or { Color = C.Blue, Icon = "⭐" }','or { Color = C.Blue, Logo = tab }')
    s=s.replace('Icon = style.Icon,','Logo = style.Logo,')
    a=s.index('-- Edit-mode visual check only: builds the open shop on a tab under parent')
    b=s.index('return ShopController',a)
    s=s[:a]+s[b:]
    return s
edit('ShopController.luau',shop)

def hud(s):
    a=s.index('local ICONS = {'); b=s.index('\nlocal function button(',a)
    s=s[:a]+s[b:]
    s=s.replace('Icon = ICONS[name],','Logo = if not square and size.X.Offset < 130 then nil else name,')
    s=s.replace('"\\u{1FA99} " .. Format.Number(attr("Coins", 0)) .. " Coins"','"COINS  " .. Format.Number(attr("Coins", 0))')
    s=s.replace('"\\u{1F44A} Best: "','"BEST PUNCH  "')
    s=s.replace('"\\u{1F4AA} " .. Format.Number(shownStrength)','"STRENGTH  " .. Format.Number(shownStrength)')
    s=s.replace('Format.Number(shownStrength) .. " Strength   +"', 'Format.Number(shownStrength) .. "   +"')
    s=s.replace('"ONLY " .. Purchase.PriceText("Pass", "Double")','Purchase.PriceText("Pass", "Double")')
    return s
edit('HudController.luau',hud)

# One combined patch is easier to audit; baseline files remain byte-for-byte intact.
diff=[]
for p in sorted(OUT.glob('*.luau')):
    a=(BASE/p.name).read_text(encoding='utf-8').splitlines(True)
    b=p.read_text(encoding='utf-8').splitlines(True)
    if a!=b:
        diff.extend(difflib.unified_diff(a,b,fromfile='baseline/'+p.name,tofile='modified/'+p.name))
(ROOT/'DIFF_FILE.patch').write_text(''.join(diff),encoding='utf-8',newline='\n')
(ROOT/'catalog-prices.json').write_text(json.dumps(prices,indent=2)+'\n',encoding='utf-8',newline='\n')
(ROOT/'created-ids.json').write_text(json.dumps(created_ids,indent=2)+'\n',encoding='utf-8',newline='\n')
print('MODIFIED_FILES',sum((BASE/p.name).read_bytes()!=p.read_bytes() for p in OUT.glob('*.luau')))
print('MAX_PRICE',max(prices.values()))

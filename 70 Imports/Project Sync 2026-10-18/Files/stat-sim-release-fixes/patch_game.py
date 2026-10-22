from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parent
BASE=ROOT/'baseline'
OUT=ROOT/'modified'
def edit(rel, transform):
    p=OUT/rel
    p.parent.mkdir(parents=True,exist_ok=True)
    s=(BASE/rel).read_text(encoding='utf-8')
    p.write_text(transform(s),encoding='utf-8',newline='\n')

def eggs(s):
    # Receipted pets must be delivered even if the inventory filled after prompting.
    s=s.replace('if #profile.PetInv + count > PetsConfig.MaxInventory then','if #profile.PetInv + count > PetsConfig.MaxInventory and not free then')
    a=s.index('\tif egg.ProductKey then\n\t\tprompt(stand, "BuyPrompt"')
    b=s.index('\nend\n\nlocal function nearestStand',a)
    s=s[:a]+'''\t-- Exactly one readable world prompt; batch hatching lives inside the egg menu.
\tprompt(stand, "OpenEggPrompt", "Open Egg", Enum.KeyCode.E, 0).Triggered:Connect(function(player)
\t\tlocal root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
\t\tif root and (root.Position-stand.Position).Magnitude<=18 then
\t\t\tRemotes.OpenEgg:FireClient(player,eggId)
\t\tend
\tend)'''+s[b:]
    s=s.replace('function EggService.Start()','''function EggService.Start()
\tfor _,name in {"OpenEgg","RequestHatch"} do
\t\tif not Remotes:FindFirstChild(name) then local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=Remotes end
\tend
\tRemotes.RequestHatch.OnServerEvent:Connect(function(player,eggId,count)
\t\tif typeof(eggId)~="string" or (count~=1 and count~=3) then return end
\t\tlocal root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
\t\tif not root then return end
\t\tfor stand,id in stands do
\t\t\tif id==eggId and (root.Position-stand.Position).Magnitude<=22 then tryHatch(player,eggId,count);return end
\t\tend
\tend)''')
    # Remove obsolete world-purchase shortcut; all buyers use the policy-aware shared flow.
    a=s.index('local function promptMega(player)')
    b=s.index('-- Cosmetic factory only:',a)
    s=s[:a]+s[b:]
    s=s.replace('''\t\tfor _, child in stand:GetChildren() do''','''\t\tfor _, child in stand:GetChildren() do''')
    s=s.replace('if child.Name == "EggPreview" or child.Name == "Egg" then child:Destroy() end','if child.Name == "EggPreview" or child.Name == "Egg" or child.Name == "Odds" or child:IsA("ProximityPrompt") then child:Destroy() end')
    # Never open a server-side upsell just because R was pressed near an egg.
    a=s.index('\tif count > 1 and not StatService.OwnsPass')
    b=s.index('\n\tEggService.Hatch(player',a)
    s=s[:a]+'''\tif count>1 and not StatService.OwnsPass(player,"TripleHatch") then
\t\tRemotes.Notify:FireClient(player,"Triple Hatch pass required; choose Hatch 1 or open the shop")
\t\treturn
\tend'''+s[b:]
    return s
edit('ServerScriptService/Services/EggService.luau',eggs)

def zone(s):
    a=s.index('\tif pass.Id == 0 then')
    b=s.index('\n\tMarketplaceService:PromptGamePassPurchase',a)
    return s[:a]+'''\tif pass.Id==0 then
\t\tRemotes.Notify:FireClient(player,pass.Name.." is not listed yet")
\t\treturn
\tend'''+s[b:]
edit('ServerScriptService/Services/ZoneService.luau',zone)

def hud(s):
    marker='\n\t-- left: progression'
    s=s.replace(marker,'''
\tui.SaveText=label({Name="SaveStatus",Size=UDim2.new(1,0,0,22),Position=UDim2.fromOffset(0,78),TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(150,235,190),Parent=wallet})
'''+marker)
    marker='\n\tfor i, dot in ui.WorldDots do'
    s=s.replace(marker,'''
\tlocal saveStatus=attr("DataStatus","Loading")
\tui.SaveText.Text=if saveStatus=="Saved" then "PROGRESS SAVED" elseif saveStatus=="Saving" then "SAVING..." elseif attr("DataPersistent",false) then "SAVE RETRY PENDING" else "SESSION ONLY - NOT SAVING"
\tui.SaveText.TextColor3=if attr("DataPersistent",false) then Color3.fromRGB(150,235,190) else Color3.fromRGB(255,160,110)
'''+marker)
    return s
edit('StarterPlayer/StarterPlayerScripts/Controllers/HudController.luau',hud)

def purchase(s):
    s=s.replace('local Purchase = {}','local Purchase = {}\nlocal changed=Instance.new("BindableEvent")\nPurchase.ListingChanged=changed.Event')
    # Wrap prompt API errors so buttons always return clear feedback.
    s=s.replace('MarketplaceService:PromptGamePassPurchase(player, item.Id)','local prompted,err=pcall(MarketplaceService.PromptGamePassPurchase,MarketplaceService,player,item.Id)\n    if not prompted then return false,"Roblox purchase prompt unavailable; try again" end')
    s=s.replace('MarketplaceService:PromptProductPurchase(player, item.Id)','local prompted,err=pcall(MarketplaceService.PromptProductPurchase,MarketplaceService,player,item.Id)\n    if not prompted then return false,"Roblox purchase prompt unavailable; try again" end')
    s=s.replace('if item.Id == 0 then return "R$" .. item.Price .. " · SETUP" end','if item.Id == 0 then return "COMING SOON" end')
    a=s.index('    local cacheKey = kind .. tostring(item.Id)')
    b=s.index('\nend\n\nreturn Purchase',a)
    s=s[:a]+'''    local cacheKey=kind..tostring(item.Id)
    local cached=listingCache[cacheKey]
    if not cached or (not cached.loading and os.clock()-cached.time>60) then
        cached={time=os.clock(),loading=true}
        listingCache[cacheKey]=cached
        task.spawn(function()
            cached.ok,cached.reason=listing(kind,item)
            cached.loading=false
            changed:Fire(kind,key)
        end)
    end
    if cached.loading then return "CHECKING..." end
    return if cached.ok then "R$"..item.Price else "UNAVAILABLE"'''+s[b:]
    s=s.replace('    if not item then return false, "Unknown product" end','''    if not item then return false, "Unknown product" end
    if not player:GetAttribute("Loaded") then return false,"Progress is still loading" end
    if not player:GetAttribute("DataPersistent") then return false,"Purchases wait until progress saving is available" end''')
    return s
edit('ReplicatedStorage/Shared/Util/Purchase.luau',purchase)

def shop(s):
    s=s.replace('local ShopController = {}','local ShopController = {}\nlocal listingRefresh = {}')
    s=s.replace('\trefresh()\n\tif kind == "Pass" then','\tlistingRefresh[kind..":"..key]=refresh\n\trefresh()\n\tif kind == "Pass" then')
    s=s.replace('\tbuyPass = Purchase.Pass','\tPurchase.ListingChanged:Connect(function(kind,key)\n\t\tlocal fn=listingRefresh[kind..":"..key];if fn then fn() end\n\tend)\n\tbuyPass = Purchase.Pass')
    return s
edit('StarterPlayer/StarterPlayerScripts/Controllers/ShopController.luau',shop)

def monetization(s):
    # No parallel ProcessReceipt handlers can grant the same receipt twice.
    s=s.replace('local function processReceipt(info)','local receiptBusy={}\nlocal function processReceiptUnlocked(info)')
    pos=s.index('\nlocal function checkPasses')
    s=s[:pos]+'''
local function processReceipt(info)
\tlocal id=tostring(info.PlayerId)
\twhile receiptBusy[id] do task.wait() end
\treceiptBusy[id]=true
\tlocal ok,result=pcall(processReceiptUnlocked,info)
\treceiptBusy[id]=nil
\tif not ok then warn("[Monetization] Receipt deferred: "..tostring(result));return Enum.ProductPurchaseDecision.NotProcessedYet end
\treturn result
end
'''+s[pos:]
    return s
edit('ServerScriptService/Services/MonetizationService.luau',monetization)

ids=json.loads((ROOT.parent/'stat-sim-monetization'/'created-ids.json').read_text(encoding='utf-8-sig'))
ids.update(json.loads((ROOT/'created-ids.json').read_text()) if (ROOT/'created-ids.json').exists() else {})
def catalog(s):
    for key,id in ids.items():
        s=re.sub(r'(\b'+re.escape(key)+r' = \{Id = )\d+',lambda m:m[1]+str(id),s)
    return s
edit('ReplicatedStorage/Shared/Config/Monetization.luau',catalog)
print('PATCH PASS: ordered saving, single egg prompt, purchase feedback, receipt serialization, '+str(len(ids))+' bound listings')

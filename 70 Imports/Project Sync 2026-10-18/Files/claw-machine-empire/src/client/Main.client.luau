-- Build03: three-widget walking HUD; contextual crane controls and prize theatre.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild("ClawEmpire"):WaitForChild("Shared")
local Config=require(shared.Config); local Big=require(shared.BigNumber); local Economy=require(shared.Economy)
local remotes=shared.Parent:WaitForChild("Remotes")
local request=remotes:WaitForChild("Request"); local update=remotes:WaitForChild("Update")
local gui=Instance.new("ScreenGui"); gui.Name="ClawEmpireUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=10
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
local C={navy=Color3.fromRGB(64,43,84),white=Color3.fromRGB(255,250,237),pink=Color3.fromRGB(255,132,186),
    mint=Color3.fromRGB(137,239,184),yellow=Color3.fromRGB(255,218,107),cyan=Color3.fromRGB(146,211,255),purple=Color3.fromRGB(197,174,255)}
local latest,panelName,lastRoundId,offset=nil,nil,nil,Vector3.zero
local keys,held={},{}
local overview,reducedMotion,phone=false,false,false
local frozenHumanoid,previousSpeed
local revealModel,revealItem,revealTime=nil,nil,0
local controls
task.spawn(function()
    local module=player.PlayerScripts:WaitForChild("PlayerModule",2)
    if module then pcall(function() controls=require(module):GetControls() end) end
end)
local function tween(obj,time,props,style)
    local tw=TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    tw:Play(); return tw
end
local root=Instance.new("Frame"); root.Name="Canvas"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.Parent=gui
local function round(obj,radius)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius or 20); c.Parent=obj
end
local function stroke(obj,color,width)
    local s=Instance.new("UIStroke"); s.Color=color or C.navy; s.Thickness=width or 3; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=obj
end
local function frame(parent,name,pos,size,color)
    local f=Instance.new("Frame"); f.Name=name; f.Position=pos; f.Size=size; f.BackgroundColor3=color or C.white
    f.BorderSizePixel=0; f.Parent=parent; round(f); return f
end
local function text(parent,name,value,pos,size,fontSize,color)
    local l=Instance.new("TextLabel"); l.Name=name; l.Text=value; l.Position=pos; l.Size=size
    l.BackgroundTransparency=1; l.Font=Enum.Font.FredokaOne; l.TextSize=fontSize or 22
    l.TextColor3=color or C.navy; l.TextWrapped=true; l.Parent=parent; return l
end
local function button(parent,name,value,pos,size,color,callback)
    local b=Instance.new("TextButton"); b.Name=name; b.Position=pos; b.Size=size; b.Text=value
    b.BackgroundColor3=color; b.TextColor3=C.navy; b.TextStrokeTransparency=1; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.FredokaOne; b.TextSize=21; b.Parent=parent; round(b,18); stroke(b)
    local shine=Instance.new("UIGradient"); shine.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(220,226,240)); shine.Rotation=90; shine.Parent=b
    local s=Instance.new("UIScale"); s.Parent=b
    b.MouseEnter:Connect(function() if not reducedMotion then tween(s,.15,{Scale=1.035},Enum.EasingStyle.Back) end end)
    b.MouseLeave:Connect(function() tween(s,.12,{Scale=1}) end)
    b.MouseButton1Down:Connect(function() tween(s,.08,{Scale=.94}) end)
    b.MouseButton1Up:Connect(function() tween(s,.2,{Scale=1},Enum.EasingStyle.Back) end)
    if callback then b.Activated:Connect(callback) end
    return b
end
local wallet=frame(root,"Wallet",UDim2.fromOffset(18,16),UDim2.fromOffset(176,52),C.white); stroke(wallet)
local coin=frame(wallet,"Coin",UDim2.fromOffset(11,10),UDim2.fromOffset(30,30),C.yellow); stroke(coin,nil,2)
text(coin,"Symbol","$",UDim2.new(),UDim2.fromScale(1,1),23)
local money=text(wallet,"Value","0",UDim2.fromOffset(49,6),UDim2.new(1,-57,1,-12),26); money.TextXAlignment=Enum.TextXAlignment.Left
local open
local menu=button(root,"Menu","MY ARCADE",UDim2.new(1,-169,0,16),UDim2.fromOffset(151,52),C.pink,function() open("Home") end)
local play=button(root,"Play","PLAY CLAW",UDim2.new(.5,-100,1,-74),UDim2.fromOffset(200,54),C.mint,function()
    if latest and latest.round then
        if latest.round.phase=="aim" then request:FireServer("drop") end
    elseif latest then request:FireServer("start") end
end)
local hint=text(root,"ContextHint","",UDim2.new(.5,-160,1,-103),UDim2.fromOffset(320,23),15,C.white)
hint.TextStrokeColor3=C.navy; hint.TextStrokeTransparency=0
local status=frame(root,"Toast",UDim2.new(.5,0,0,82),UDim2.fromOffset(450,48),C.white)
status.AnchorPoint=Vector2.new(.5,0); status.Visible=false; stroke(status)
local statusText=text(status,"Message","",UDim2.fromOffset(10,4),UDim2.new(1,-20,1,-8),18)
local toastVersion=0
local function toast(message)
    toastVersion+=1; local v=toastVersion; statusText.Text=message; status.Visible=true
    task.delay(3.5,function() if v==toastVersion then status.Visible=false end end)
end
local shade=frame(root,"MenuShade",UDim2.new(),UDim2.fromScale(1,1),C.navy); shade.BackgroundTransparency=.45; shade.Visible=false
local panel=frame(shade,"Panel",UDim2.fromScale(.5,.5),UDim2.fromOffset(610,510),C.white)
panel.AnchorPoint=Vector2.new(.5,.5); stroke(panel,nil,4); panel.Visible=false
local panelTitle=text(panel,"PanelTitle","My arcade",UDim2.fromOffset(20,12),UDim2.new(1,-90,0,42),28)
panelTitle.TextXAlignment=Enum.TextXAlignment.Left
button(panel,"Close","X",UDim2.new(1,-60,0,12),UDim2.fromOffset(44,42),C.pink,function() panelName=nil; panel.Visible=false; shade.Visible=false end)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="Content"; scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.Position=UDim2.fromOffset(16,68); scroll.Size=UDim2.new(1,-32,1,-84); scroll.ScrollBarThickness=5
scroll.ScrollBarImageColor3=C.purple; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(); scroll.Parent=panel
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,12); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Parent=scroll
local function row(name,height,color)
    local f=frame(scroll,name,UDim2.new(),UDim2.new(1,-10,0,height),color or Color3.fromRGB(235,232,250))
    f.LayoutOrder=#scroll:GetChildren(); return f
end
local function rowText(f,value,y,size,color)
    local l=text(f,"Detail",value,UDim2.fromOffset(16,y),UDim2.new(1,-32,0,size+10),size,color or C.navy)
    l.TextStrokeTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; return l
end
local rebuild
open=function(name)
    if not latest or latest.round or revealItem then return end
    panelName=name; scroll.CanvasPosition=Vector2.zero; rebuild()
    if not reducedMotion then
        local s=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
        s.Scale=.91; tween(s,.26,{Scale=1},Enum.EasingStyle.Back)
    end
end
local function isDisplayed(id)
    for _,shown in ipairs(latest.state.display) do if shown==id then return true end end
    return false
end
local indexMode=false
rebuild=function()
    if not panelName or not latest then panel.Visible=false; shade.Visible=false; return end
    panel.Visible=true; shade.Visible=true; panelTitle.Text=if panelName=="Home" then "My arcade" else panelName
    for _,child in ipairs(scroll:GetChildren()) do if child~=list then child:Destroy() end end
    local state=latest.state
    if panelName~="Home" then
        local f=row("Back",44,C.white)
        button(f,"GoBack","<  BACK",UDim2.new(),UDim2.fromOffset(115,40),C.cyan,function() open("Home") end).TextSize=16
    end
    if panelName=="Home" then
        local f=row("Income",96,C.yellow)
        local bank=rowText(f,"Shelf bank  $"..Big.format(state.bank),8,23); bank.Name="Bank"
        rowText(f,"Earning $"..Big.format(Economy.rate(state)).." / sec",49,15)
        button(f,"Collect","COLLECT",UDim2.new(1,-145,0,45),UDim2.fromOffset(130,40),C.mint,function() request:FireServer("collect") end).TextSize=17
        for i,name in ipairs({"Plushies","Machines","Upgrades"}) do
            local f=row(name,60,C.white)
            button(f,"Open",name.."   >",UDim2.new(),UDim2.fromScale(1,1),({C.pink,C.cyan,C.purple})[i],function() open(name) end)
        end
        local f=row("Map",56,C.white)
        button(f,"Toggle",if overview then "RETURN TO WALKING" else "BIRD'S-EYE MAP",UDim2.new(),UDim2.fromScale(1,1),C.cyan,function() overview=not overview; panelName=nil; shade.Visible=false end).TextSize=18
        f=row("Motion",56,C.white)
        button(f,"Toggle","REDUCED MOTION: "..(if reducedMotion then "ON" else "OFF"),UDim2.new(),UDim2.fromScale(1,1),C.white,function() reducedMotion=not reducedMotion; rebuild() end).TextSize=17
        f=row("Demo",58,C.white)
        rowText(f,if latest.sessionOnly then "Studio demo  /  progress lasts until Play stops." else "Your arcade saves automatically.",7,14)
        rowText(f,"Catch. Display. Earn. Every claw has free plays.",32,13)
    elseif panelName=="Plushies" then
        local heading=row("CollectionTabs",54,C.navy)
        button(heading,"InventoryTab","INVENTORY",UDim2.fromOffset(6,4),UDim2.new(0.5,-9,0,46),C.pink,function() indexMode=false; rebuild() end).TextSize=16
        button(heading,"IndexTab","COLLECTION",UDim2.new(0.5,3,0,4),UDim2.new(0.5,-9,0,46),C.cyan,function() indexMode=true; rebuild() end).TextSize=16
        if indexMode then
            for _,spec in ipairs(Config.Plushies) do
                local known=state.discovered[spec.id]
                local f=row(spec.id,83,if known then Color3.fromRGB(table.unpack(spec.color)) else Color3.fromRGB(225,224,236))
                rowText(f,if known then spec.name else "???  -  UNDISCOVERED",9,21)
                rowText(f,if known then spec.rarity.."  /  $"..spec.income.." per second" else "Keep catching to complete your crew.",43,14)
            end
        else
            local info=row("ShelfCount",48); rowText(info,"SHELVES "..#state.display.." / 8   |   STORAGE "..#state.inventory.." / 40",9,if phone then 14 else 18)
            if #state.inventory==0 then local f=row("Empty",98); rowText(f,"Your crew starts with one catch!",12,20); rowText(f,"Close this panel and press PLAY CLAW.",52,15) end
            for _,item in ipairs(state.inventory) do
                local spec=Config.plushie(item.species); local displayed=isDisplayed(item.id)
                local f=row("Item"..item.id,128,Color3.fromRGB(table.unpack(spec.color)))
                local name=rowText(f,spec.name.."  #"..item.id,8,if phone then 19 else 23)
                name.Size=UDim2.new(1,-32,0,34)
                rowText(f,spec.rarity.."  /  $"..spec.income.." / sec",43,15)
                local b=button(f,"Display",if displayed then "STOW" else "DISPLAY",
                    UDim2.fromOffset(14,77),UDim2.fromOffset(135,44),if displayed then C.purple else C.mint,
                    function() request:FireServer(if displayed then "stow" else "display",item.id) end)
                b.TextSize=18
                if not displayed then
                    button(f,"Sell","SELL $"..spec.income*5,UDim2.new(1,-143,0,77),UDim2.fromOffset(129,44),C.yellow,
                        function() request:FireServer("sell",item.id) end).TextSize=17
                end
            end
        end
    elseif panelName=="Machines" then
        local info=row("MachineCount",72,C.navy)
        rowText(info,state.machine.." / 25 MACHINES OWNED",8,if phone then 18 else 23,C.yellow)
        rowText(info,"Walk up and press E, or jump to an owned machine.",42,if phone then 12 else 15,C.white)
        for i,spec in ipairs(Config.Machines) do
            local f=row(spec.id,140,Color3.fromRGB(table.unpack(spec.color)))
            rowText(f,spec.name,12,27)
            rowText(f,if i<=state.machine then "OWNED  /  FREE CLAW PLAYS" else "Unlock for $"..Big.format(Big.new(spec.cost)).." earned coins",52,16)
            if i==state.machine+1 then
                button(f,"Unlock","UNLOCK  $"..Big.format(Big.new(spec.cost)),UDim2.fromOffset(16,87),UDim2.new(1,-32,0,44),C.mint,function() request:FireServer("unlock") end).TextSize=20
            elseif i<=state.machine then
                button(f,"Travel","GO HERE",UDim2.fromOffset(16,87),UDim2.new(1,-32,0,44),C.cyan,function() request:FireServer("travel",i); panelName=nil; shade.Visible=false; overview=false end).TextSize=19
            else rowText(f,"UNLOCK EARLIER MACHINES FIRST",92,if phone then 13 else 17) end
        end
        local f=row("Next",95,C.navy); rowText(f,"25 THEMES. ALL EARNABLE.",10,if phone then 19 else 23,C.pink); rowText(f,"Every owned machine has free replenishing plays.",51,if phone then 13 else 15,C.white)
    elseif panelName=="Upgrades" then
        for _,key in ipairs({"speed","shelves"}) do
            local spec=Config.Upgrades[key]; local level=state.upgrades[key]
            local f=row(key,155,if key=="speed" then C.cyan else C.purple)
            rowText(f,spec.name.."  "..level.." / "..spec.max,10,24)
            rowText(f,spec.description,48,if phone then 14 else 16)
            local b=button(f,"BuyUpgrade",if level>=spec.max then "MAX LEVEL" else "UPGRADE  $"..spec.cost*2^level,
                UDim2.fromOffset(16,99),UDim2.new(1,-32,0,44),C.mint,function() request:FireServer("upgrade",key) end)
            b.TextSize=18
        end
    elseif panelName=="Shop" then
        local f=row("Closed",110,C.navy); rowText(f,"PURCHASES ARE DISABLED",10,if phone then 19 else 25,C.yellow)
        local l=rowText(f,"Alpha preview only. No Robux prompts, fake prices, or paid random catches.",49,16,C.white); l.Size=UDim2.new(1,-32,0,50)
        for _,spec in ipairs(Config.Catalog) do
            local card=row(spec.id,155,C.purple)
            rowText(card,spec.name,10,if phone then 20 else 25)
            local l=rowText(card,spec.benefit,49,15); l.Size=UDim2.new(1,-32,0,45)
            rowText(card,"NOT FOR SALE  /  ID NOT CONFIGURED",112,if phone then 12 else 16)
        end
    end
end

local timerPill=frame(root,"RoundTimer",UDim2.new(.5,-100,0,18),UDim2.fromOffset(200,48),C.white); stroke(timerPill); timerPill.Visible=false
local timer=text(timerPill,"Text","25s",UDim2.new(),UDim2.fromScale(1,1),24)
local exit=button(root,"LeaveClaw","X",UDim2.new(1,-65,0,18),UDim2.fromOffset(46,46),C.pink,function() request:FireServer("cancel") end); exit.Visible=false
local dpad=frame(root,"TouchControls",UDim2.new(0,18,1,-164),UDim2.fromOffset(150,140),C.white)
dpad.BackgroundTransparency=1; dpad.Visible=false
for _,spec in ipairs({{"Up","^",49,0},{"Left","<",0,47},{"Down","v",49,94},{"Right",">",98,47}}) do
    local b=button(dpad,spec[1],spec[2],UDim2.fromOffset(spec[3],spec[4]),UDim2.fromOffset(44,44),C.cyan)
    b.InputBegan:Connect(function(v) if v.UserInputType==Enum.UserInputType.Touch or v.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=true end end)
    b.InputEnded:Connect(function(v) if v.UserInputType==Enum.UserInputType.Touch or v.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=nil end end)
end
local guide=frame(root,"AimGuide",UDim2.new(1,-154,1,-185),UDim2.fromOffset(132,94),C.white)
guide.BackgroundTransparency=.15; stroke(guide,nil,2); guide.Visible=false
local cursor=text(guide,"Cursor","+",UDim2.fromScale(.5,.5),UDim2.fromOffset(28,28),28)
cursor.AnchorPoint=Vector2.new(.5,.5); cursor.ZIndex=2
local function drawTargets(targets)
    for _,c in ipairs(guide:GetChildren()) do if c.Name=="Dot" then c:Destroy() end end
    for _,t in ipairs(targets) do
        local spec=Config.plushie(t.species)
        local dot=frame(guide,"Dot",UDim2.fromScale(.1+(t.x+4)/8*.8,.12+(t.z+3)/6*.76),UDim2.fromOffset(13,13),Color3.fromRGB(table.unpack(spec.color)))
        dot.AnchorPoint=Vector2.new(.5,.5); stroke(dot,nil,1)
    end
end
local reveal=frame(root,"PrizeReveal",UDim2.new(),UDim2.fromScale(1,1),C.navy); reveal.BackgroundTransparency=.24; reveal.Visible=false
local burst=frame(reveal,"Sunburst",UDim2.fromScale(.5,.43),UDim2.fromOffset(1,1),C.white); burst.BackgroundTransparency=1
for i=1,12 do
    local ray=frame(burst,"Ray"..i,UDim2.fromOffset(-14,-425),UDim2.fromOffset(28,850),if i%2==0 then C.yellow else C.pink)
    ray.BackgroundTransparency=.72; ray.Rotation=i*15
end
local fit=frame(reveal,"Fit",UDim2.fromScale(.5,.5),UDim2.fromOffset(370,460),C.white)
fit.AnchorPoint=Vector2.new(.5,.5); fit.BackgroundTransparency=1
local fitScale=Instance.new("UIScale"); fitScale.Parent=fit
local prizeCard=frame(fit,"Card",UDim2.new(),UDim2.fromScale(1,1),C.white); stroke(prizeCard,nil,4)
local cardScale=Instance.new("UIScale"); cardScale.Parent=prizeCard
text(prizeCard,"Title","YOU GOT A PLUSHIE!",UDim2.fromOffset(10,12),UDim2.new(1,-20,0,35),25)
local rarity=text(prizeCard,"Rarity","COMMON",UDim2.fromOffset(10,50),UDim2.new(1,-20,0,26),16)
local viewport=Instance.new("ViewportFrame"); viewport.Name="PlushPreview"; viewport.BackgroundTransparency=1
viewport.Position=UDim2.fromOffset(30,77); viewport.Size=UDim2.new(1,-60,0,235); viewport.Ambient=Color3.fromRGB(220,220,220)
viewport.LightColor=Color3.new(1,1,1); viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.Parent=prizeCard
local modelWorld=Instance.new("WorldModel"); modelWorld.Parent=viewport
local vpCamera=Instance.new("Camera"); vpCamera.FieldOfView=35; vpCamera.CFrame=CFrame.lookAt(Vector3.new(0,0,5.5),Vector3.zero); vpCamera.Parent=viewport; viewport.CurrentCamera=vpCamera
local prizeName=text(prizeCard,"Name","Goofy Duck",UDim2.fromOffset(10,310),UDim2.new(1,-20,0,36),27)
local function closeReveal()
    revealItem=nil; reveal.Visible=false; modelWorld:ClearAllChildren(); revealModel=nil
end
button(prizeCard,"Display","DISPLAY",UDim2.fromOffset(20,361),UDim2.new(1,-40,0,46),C.mint,function()
    if revealItem then request:FireServer("display",revealItem.id) end; closeReveal()
end)
button(prizeCard,"Keep","KEEP IN BAG",UDim2.fromOffset(70,414),UDim2.new(1,-140,0,31),C.white,closeReveal).TextSize=15
local function showReward(item)
    if not item then return end
    modelWorld:ClearAllChildren(); revealModel=nil
    local plots=workspace:FindFirstChild("ClawEmpirePlots")
    local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
    if plot then for _,model in ipairs(plot:GetDescendants()) do
        if model:IsA("Model") and model:GetAttribute("Species")==item.species then
            revealModel=model:Clone()
            for _,p in ipairs(revealModel:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=true; p.LocalTransparencyModifier=0 end end
            local _,size=revealModel:GetBoundingBox(); revealModel:ScaleTo(2.65/math.max(size.X,size.Y,size.Z)); local box=revealModel:GetBoundingBox(); revealModel.PrimaryPart=nil; revealModel.WorldPivot=box; revealModel:PivotTo(CFrame.new()); revealModel.Parent=modelWorld; break
        end
    end end
    local spec=Config.plushie(item.species)
    revealItem=item; revealTime=os.clock(); reveal.Visible=true; shade.Visible=false; panelName=nil; status.Visible=false
    rarity.Text=string.upper(spec.rarity); prizeName.Text=spec.name; prizeCard.BackgroundColor3=Color3.fromRGB(table.unpack(spec.color)):Lerp(C.white,.65)
    prizeCard.Display.Text="DISPLAY  +$"..spec.income.."/s"
    cardScale.Scale=if reducedMotion then 1 else .15
    if not reducedMotion then tween(cardScale,.55,{Scale=1},Enum.EasingStyle.Back) end
    for i=1,(if reducedMotion then 0 else 32) do
        local conf=frame(reveal,"Confetti",UDim2.fromScale(.5,.45),UDim2.fromOffset(8,15),({C.pink,C.cyan,C.yellow,C.mint})[i%4+1])
        conf.Rotation=i*43
        tween(conf,1.3+i%4*.2,{Position=UDim2.fromScale((i*37%100)/100,1.15),Rotation=i*113,BackgroundTransparency=1})
        task.delay(2.1,function() conf:Destroy() end)
    end
end
local function homeCamera()
    return CFrame.lookAt(offset+(if gui.AbsoluteSize.X<gui.AbsoluteSize.Y then Vector3.new(240,610,720) else Vector3.new(245,305,385)),offset+Vector3.new(0,0,10))
end
local cameraState=Instance.new("CFrameValue"); cameraState.Value=homeCamera()
local function layout()
    local size=gui.AbsoluteSize; local compact=size.Y<500; phone=size.X<600
    wallet.Size=UDim2.fromOffset(if phone then 136 else 176,48); money.TextSize=if phone then 21 else 26
    menu.Position=UDim2.new(1,if phone then -143 else -169,0,16); menu.Size=UDim2.fromOffset(if phone then 125 else 151,48); menu.TextSize=if phone then 17 else 21
    panel.Size=UDim2.fromOffset(math.min(610,size.X-32),math.min(510,size.Y-32))
    local rh=math.min(460,size.Y-24)
    fit.Size=UDim2.fromOffset(math.min(370,size.X-28),rh); fitScale.Scale=1
    prizeCard.Title.TextSize=if compact then 21 else 25
    viewport.Position=UDim2.fromOffset(25,66); viewport.Size=UDim2.new(1,-50,0,rh-225)
    rarity.Position=UDim2.fromOffset(10,43)
    prizeName.Position=UDim2.fromOffset(10,rh-151)
    prizeCard.Display.Position=UDim2.fromOffset(20,rh-108); prizeCard.Display.Size=UDim2.new(1,-40,0,46)
    prizeCard.Keep.Position=UDim2.fromOffset(55,rh-54); prizeCard.Keep.Size=UDim2.new(1,-110,0,44)
    dpad.Position=UDim2.new(0,18,1,if compact then -151 else -164)
    hint.TextSize=if phone then 12 else 15
    guide.Size=UDim2.fromOffset(if phone then 90 else 132,if phone then 72 else 94)
    guide.Position=UDim2.new(1,if phone then -108 else -154,1,if compact then -173 else -185)
    status.Size=UDim2.fromOffset(math.min(450,size.X-32),48); statusText.TextSize=if phone then 15 else 18
    if not latest or not latest.round then cameraState.Value=homeCamera() end
end
local fxFolder,fxParts=nil,{}
local lastRoundSync=0
local function clearFX()
    if fxFolder then fxFolder:Destroy(); fxFolder=nil end; fxParts={}
end
local function setRoundMode(data)
    local id=data and data.id or nil
    if id==lastRoundId then return end
    clearFX()
    if id then
        fxFolder=Instance.new("Folder"); fxFolder.Name="CME_LocalCatchFX"; fxFolder.Parent=workspace
        for i=1,10 do
            local p=Instance.new("Part"); p.Name="StarMote"; p.Shape=Enum.PartType.Ball
            p.Size=Vector3.new(.14,.14,.14); p.Material=Enum.Material.Neon; p.Color=if i%2==0 then C.yellow else C.white
            p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false; p.Transparency=1; p.Parent=fxFolder
            fxParts[i]=p
        end
    end
    keys={}; held={}; panelName=nil; shade.Visible=false; overview=false
    if controls then if id then controls:Disable() else controls:Enable() end end
    if id then
        frozenHumanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if frozenHumanoid then previousSpeed=frozenHumanoid.WalkSpeed; frozenHumanoid.WalkSpeed=0 end
        drawTargets(data.targets)
    elseif frozenHumanoid and frozenHumanoid.Parent then frozenHumanoid.WalkSpeed=previousSpeed or 24; frozenHumanoid=nil end
    local plots=workspace:FindFirstChild("ClawEmpirePlots")
    local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
    if plot then for _,p in ipairs(plot:GetDescendants()) do
        if p:IsA("BasePart") and p:GetAttribute("AimOccluder") then
            p.LocalTransparencyModifier=if id then 1 else 0
            local sign=p:FindFirstChild("Sign"); if sign then sign.Enabled=id==nil end
        end
    end end
    if id then tween(cameraState,if reducedMotion then .01 else .65,{Value=CFrame.lookAt(data.origin+Vector3.new(0,26,14),data.origin+Vector3.new(0,8,0))},Enum.EasingStyle.Quint) end
    lastRoundId=id
end
local lastViewKey=""
update.OnClientEvent:Connect(function(data)
    latest=data; lastRoundSync=os.clock(); offset=data.offset; money.Text=Big.format(data.state.coins); setRoundMode(data.round)
    if data.round then
        timer.Text=if data.round.phase=="aim" then math.ceil(data.round.remaining).."s" else Config.clawPose(data.round.progress or 0,0,0,data.round.prize~=nil).stage
        play.Text=if data.round.phase=="aim" then "DROP!" else "GRABBING..."
        hint.Text=if data.round.phase=="aim" then "Aim with arrows  /  Space to drop" else "Here comes your plushie..."
        cursor.Position=UDim2.fromScale(.1+(data.round.x+4)/8*.8,.12+(data.round.z+3)/6*.76)
    else
        play.Text="PLAY "..Config.Machines[Economy.selected(data.state)].short
        hint.Text=if #data.state.inventory==0 then "Catch your first plushie!" else data.attempts.." free plays  /  explore your arcade"
    end
    if data.message and not revealItem and not data.round and data.kind~="catch" and data.kind~="drop" and data.kind~="welcome" then toast(data.message) end
    if data.kind=="catch" then showReward(data.reward) end
    local key=panelName and table.concat({panelName,#data.state.inventory,table.concat(data.state.display,","),data.state.machine,Economy.selected(data.state),data.state.upgrades.speed,data.state.upgrades.shelves},":") or ""
    if key~=lastViewKey then lastViewKey=key; rebuild() end
    local bank=scroll:FindFirstChild("Income")
    if panelName=="Home" and bank then bank.Bank.Text="Shelf bank  $"..Big.format(data.state.bank) end
end)
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.V and latest and not latest.round and not revealItem then overview=not overview; cameraState.Value=homeCamera() end
    if not latest or not latest.round then return end
    keys[input.KeyCode]=true
    if input.KeyCode==Enum.KeyCode.Space then request:FireServer("drop") end
    if input.KeyCode==Enum.KeyCode.Escape and latest.round.phase=="aim" then request:FireServer("cancel") end
end)
UIS.InputEnded:Connect(function(v) keys[v.KeyCode]=nil end)
UIS.WindowFocusReleased:Connect(function() keys={}; held={} end)
local elapsed=0
local touchOverride,touchWasEnabled=nil,nil
local ambientModel,ambientBase,ambientCheck=nil,nil,0
RunService:BindToRenderStep("ClawEmpireCamera",Enum.RenderPriority.Camera.Value+1,function(dt)
    local cam=workspace.CurrentCamera; local inRound=latest and latest.round
    if overview or inRound then
        cam.CameraType=Enum.CameraType.Scriptable
        if overview then cam.CFrame=homeCamera() else
            local cf=cameraState.Value; local p=inRound.progress or 0
            if inRound.phase=="drop" and not reducedMotion then cf=cf*CFrame.new(0,0,-math.sin(p*math.pi)*1.2) end
            cam.CFrame=cf
        end
        cam.FieldOfView=60
    else
        cam.CameraType=Enum.CameraType.Custom; cam.FieldOfView=70
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject=hum end
    end
    if inRound and #fxParts>0 then
        local progress=math.clamp((inRound.progress or 0)+(os.clock()-lastRoundSync)/Config.DropSeconds,0,1)
        local visible=inRound.phase=="drop" and inRound.prize and progress>.43 and progress<.97 and not reducedMotion
        local pose=Config.clawPose(progress,inRound.x,inRound.z,inRound.prize~=nil)
        for i,p in ipairs(fxParts) do
            p.Transparency=if visible then .12 else 1
            if visible then
                local a=os.clock()*5+i*math.pi/5; local radius=1.4+math.sin(a*2)*.25
                p.Position=inRound.origin+Vector3.new(pose.x+math.cos(a)*radius,pose.y-1.3+math.sin(a*1.7)*.7,pose.z+math.sin(a)*radius)
                local size=.1+.1*(.5+.5*math.sin(a*3)); p.Size=Vector3.new(size,size,size)
            end
        end
    end
    local busy=revealItem~=nil or shade.Visible
    local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
    if touchGui and (busy or inRound) then
        if touchOverride~=touchGui then touchOverride=touchGui; touchWasEnabled=touchGui.Enabled end
        touchGui.Enabled=false
    elseif touchOverride then
        if touchOverride.Parent then touchOverride.Enabled=touchWasEnabled end
        touchOverride=nil
    end
    wallet.Visible=not inRound and not busy; menu.Visible=not inRound and not busy
    play.Visible=not busy; hint.Visible=not busy
    timerPill.Visible=inRound and not busy or false
    exit.Visible=inRound and inRound.phase=="aim" and not busy or false
    dpad.Visible=inRound and inRound.phase=="aim" and not busy or false
    guide.Visible=dpad.Visible
    if revealItem and revealModel then
        local t=os.clock()-revealTime
        revealModel:PivotTo(CFrame.new(0,if reducedMotion then 0 else math.sin(t*2.8)*.12,0)*CFrame.Angles(0,if reducedMotion then 0 else math.sin(t*1.3)*.25+math.max(0,1-t/.7)*math.pi*2,0))
        if not reducedMotion then burst.Rotation=t*9 end
    end
    ambientCheck+=dt
    if ambientCheck>2 then
        ambientCheck=0; local plots=workspace:FindFirstChild("ClawEmpirePlots")
        local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
        local m=plot and plot:FindFirstChild("ParkLandmarks") and plot.ParkLandmarks:FindFirstChild("FloatingMascot")
        if m~=ambientModel then ambientModel=m; ambientBase=m and m:GetPivot() end
    end
    if ambientModel and ambientModel.Parent and ambientBase then
        local t=os.clock()
        ambientModel:PivotTo(ambientBase*CFrame.new(0,if reducedMotion then 0 else math.sin(t*1.8)*.65,0)*CFrame.Angles(0,if reducedMotion then 0 else t*.18,0))
    end
    elapsed+=dt
    if elapsed>=.1 then
        elapsed=0
        if inRound and inRound.phase=="aim" then
            local left=keys[Enum.KeyCode.A] or keys[Enum.KeyCode.Left] or held.Left
            local right=keys[Enum.KeyCode.D] or keys[Enum.KeyCode.Right] or held.Right
            local up=keys[Enum.KeyCode.W] or keys[Enum.KeyCode.Up] or held.Up
            local down=keys[Enum.KeyCode.S] or keys[Enum.KeyCode.Down] or held.Down
            request:FireServer("aim",{x=(if right then 1 else 0)-(if left then 1 else 0),z=(if down then 1 else 0)-(if up then 1 else 0)})
        end
    end
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
layout(); request:FireServer("sync")
task.spawn(function() while not latest do task.wait(1); request:FireServer("sync") end end)
print("CME_CLIENT_READY",Config.Build)


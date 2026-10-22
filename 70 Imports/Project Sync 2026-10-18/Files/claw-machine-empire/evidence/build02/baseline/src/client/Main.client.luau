local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild("ClawEmpire"):WaitForChild("Shared")
local Config=require(shared.Config); local Big=require(shared.BigNumber)
local Economy=require(shared.Economy)
local remotes=shared.Parent:WaitForChild("Remotes")
local request=remotes:WaitForChild("Request"); local update=remotes:WaitForChild("Update")
local gui=Instance.new("ScreenGui"); gui.Name="ClawEmpireUI"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.DisplayOrder=10; gui.Parent=player:WaitForChild("PlayerGui")
local C={navy=Color3.fromRGB(27,24,55),mint=Color3.fromRGB(64,242,185),pink=Color3.fromRGB(255,91,155),
    yellow=Color3.fromRGB(255,219,88),cyan=Color3.fromRGB(74,216,255),purple=Color3.fromRGB(163,128,255),
    white=Color3.fromRGB(251,250,255),muted=Color3.fromRGB(173,171,200)}
local latest,panelName,lastRoundId,offset=nil,nil,nil,Vector3.zero
local keys,held={},{}
local cameraState=Instance.new("CFrameValue")
cameraState.Value=CFrame.lookAt(Vector3.new(48,35,65),Vector3.new(0,9,-9))
local controls
task.spawn(function()
    local module=player.PlayerScripts:WaitForChild("PlayerModule",2)
    if module then pcall(function() controls=require(module):GetControls() end) end
end)
local root=Instance.new("Frame"); root.Name="Canvas"; root.BackgroundTransparency=1
root.AnchorPoint=Vector2.new(0.5,0.5); root.Position=UDim2.fromScale(0.5,0.5); root.Parent=gui
local scale=Instance.new("UIScale"); scale.Parent=root
local function round(obj,radius)
    local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,radius or 16); corner.Parent=obj
end
local function stroke(obj,color,width)
    local s=Instance.new("UIStroke"); s.Color=color or C.navy; s.Thickness=width or 3; s.Parent=obj; return s
end
local function frame(parent,name,pos,size,color)
    local f=Instance.new("Frame"); f.Name=name; f.Position=pos; f.Size=size
    f.BackgroundColor3=color or C.navy; f.BorderSizePixel=0; f.Parent=parent
    round(f); return f
end
local function text(parent,name,value,pos,size,fontSize,color)
    local l=Instance.new("TextLabel"); l.Name=name; l.Text=value; l.Position=pos; l.Size=size
    l.BackgroundTransparency=1; l.Font=Enum.Font.FredokaOne; l.TextSize=fontSize or 24
    l.TextColor3=color or C.white; l.TextStrokeColor3=C.navy; l.TextStrokeTransparency=0.15
    l.TextWrapped=true; l.Parent=parent; return l
end
local function button(parent,name,value,pos,size,color,callback)
    local b=Instance.new("TextButton"); b.Name=name; b.Text=value; b.Position=pos; b.Size=size
    b.BackgroundColor3=color; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.FredokaOne; b.TextSize=23; b.TextColor3=C.white
    b.TextStrokeColor3=C.navy; b.TextStrokeTransparency=0.05; b.Parent=parent
    round(b,15); stroke(b)
    local gradient=Instance.new("UIGradient"); gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(210,222,235)); gradient.Rotation=90; gradient.Parent=b
    local inset=Instance.new("UIStroke"); inset.ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual
    inset.Color=C.navy; inset.Thickness=1.5; inset.Parent=b
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=color:Lerp(C.white,0.18)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=color}):Play() end)
    if callback then b.Activated:Connect(callback) end
    return b
end
local title=text(root,"Title","CLAW MACHINE\nEMPIRE",UDim2.fromOffset(24,12),UDim2.fromOffset(330,92),34)
title.TextXAlignment=Enum.TextXAlignment.Left
local buildLabel=text(root,"BuildLabel","BUILD 01  /  FIRST CATCH",UDim2.fromOffset(26,104),UDim2.fromOffset(300,22),15,C.mint)
buildLabel.TextXAlignment=Enum.TextXAlignment.Left
local stats={}
for i,spec in ipairs({{"Coins","COINS",C.yellow},{"Bank","SHELF BANK",C.mint},{"Rate","PER SECOND",C.cyan}}) do
    local f=frame(root,spec[1],UDim2.new(1,-(4-i)*204-24,0,24),UDim2.fromOffset(190,70),C.navy)
    stroke(f,spec[3],2)
    text(f,"Label",spec[2],UDim2.fromOffset(10,7),UDim2.fromOffset(170,18),14,spec[3])
    stats[spec[1]]=text(f,"Value","$0",UDim2.fromOffset(10,28),UDim2.fromOffset(170,34),29)
end
local mode=text(root,"SaveMode","CONNECTING TO ARCADE...",UDim2.new(1,-470,0,102),UDim2.fromOffset(445,22),14,C.muted)
mode.TextXAlignment=Enum.TextXAlignment.Right
local nav=frame(root,"Navigation",UDim2.fromOffset(24,170),UDim2.fromOffset(166,296),C.navy)
nav.BackgroundTransparency=1
local panel=frame(root,"Panel",UDim2.fromScale(0.5,0.53),UDim2.fromOffset(750,510),C.white)
panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Visible=false; stroke(panel,C.navy,4); panel.ZIndex=5
local panelTitle=text(panel,"PanelTitle","MY PLUSHIES",UDim2.fromOffset(22,14),UDim2.new(1,-95,0,45),30,C.navy)
panelTitle.TextXAlignment=Enum.TextXAlignment.Left; panelTitle.TextStrokeTransparency=1
local close=button(panel,"Close","X",UDim2.new(1,-61,0,12),UDim2.fromOffset(48,44),C.pink,function() panelName=nil; panel.Visible=false end)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="Content"; scroll.Position=UDim2.fromOffset(18,70)
scroll.Size=UDim2.new(1,-36,1,-86); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.ScrollBarThickness=7; scroll.ScrollBarImageColor3=C.purple; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new(); scroll.Parent=panel
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,12); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Parent=scroll
local tutorial=frame(root,"Tutorial",UDim2.new(1,-282,1,-310),UDim2.fromOffset(258,164),C.navy)
stroke(tutorial,C.purple,2)
text(tutorial,"Heading","YOUR FIRST EMPIRE",UDim2.fromOffset(12,12),UDim2.fromOffset(234,27),18,C.yellow)
local tutorialBody=text(tutorial,"Steps","1  CATCH A PLUSHIE\n2  DISPLAY IT\n3  COLLECT YOUR INCOME\n4  UNLOCK CLASSIC",UDim2.fromOffset(14,49),UDim2.fromOffset(232,100),18)
tutorialBody.TextXAlignment=Enum.TextXAlignment.Left
local play=button(root,"Play","PLAY CLAW  >",UDim2.new(0.5,-168,1,-103),UDim2.fromOffset(336,70),C.mint,function()
    if latest and latest.round then request:FireServer("drop") else request:FireServer("start") end
end)
local attempts=text(root,"Attempts","3 FREE PLAYS  /  RECHARGE: 12s",UDim2.new(0.5,-210,1,-30),UDim2.fromOffset(420,22),16,C.white)
local collect=button(root,"Collect","COLLECT  $0",UDim2.new(1,-282,1,-112),UDim2.fromOffset(258,58),C.yellow,function() request:FireServer("collect") end)
local status=frame(root,"Toast",UDim2.new(0.5,0,0,137),UDim2.fromOffset(600,50),C.navy)
status.AnchorPoint=Vector2.new(0.5,0); stroke(status,C.mint,2)
local statusText=text(status,"Message","Ready for your first catch? Press PLAY CLAW!",UDim2.fromOffset(12,5),UDim2.new(1,-24,1,-10),19)
local toastVersion=0
local function toast(message,color)
    toastVersion+=1; local version=toastVersion
    status.Visible=true; statusText.Text=message
    status:FindFirstChildOfClass("UIStroke").Color=color or C.mint
    task.delay(7,function() if toastVersion==version then status.Visible=false end end)
end
local aimPanel=frame(root,"AimPanel",UDim2.new(1,-378,0,205),UDim2.fromOffset(354,300),C.navy)
stroke(aimPanel,C.cyan,2); aimPanel.Visible=false
local timer=text(aimPanel,"Timer","AIM  /  25s",UDim2.fromOffset(10,10),UDim2.fromOffset(334,32),23,C.cyan)
local board=frame(aimPanel,"AimBoard",UDim2.fromOffset(18,53),UDim2.fromOffset(318,170),Color3.fromRGB(50,45,79))
local cursor=text(board,"Cursor","+",UDim2.fromScale(0.5,0.5),UDim2.fromOffset(44,44),46,C.white)
cursor.AnchorPoint=Vector2.new(0.5,0.5); cursor.ZIndex=4
text(aimPanel,"AimHint","WASD / ARROWS TO AIM\nSPACE OR DROP TO GRAB",UDim2.fromOffset(10,234),UDim2.fromOffset(334,53),17,C.muted)
local exit=button(root,"LeaveClaw","LEAVE",UDim2.new(0.5,190,1,-90),UDim2.fromOffset(110,48),C.pink,function() request:FireServer("cancel") end)
exit.Visible=false
local dpad=frame(root,"TouchControls",UDim2.new(0,35,1,-220),UDim2.fromOffset(174,174),C.navy)
dpad.BackgroundTransparency=1; dpad.Visible=false
for _,spec in ipairs({{"Up","^",60,0},{"Left","<",0,60},{"Down","v",60,120},{"Right",">",120,60}}) do
    local b=button(dpad,spec[1],spec[2],UDim2.fromOffset(spec[3],spec[4]),UDim2.fromOffset(54,54),C.cyan)
    b.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=true end
    end)
    b.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=nil end
    end)
end
local w,h,phone=1440,800,false
local function homeCamera()
    return if phone then CFrame.lookAt(offset+Vector3.new(14,36,82),offset+Vector3.new(-8,9,-10))
        else CFrame.lookAt(offset+Vector3.new(48,35,65),offset+Vector3.new(0,9,-9))
end
local function layout()
    local viewport=gui.AbsoluteSize
    phone=viewport.X<850 and viewport.Y>500
    local short=viewport.Y<500
    local s=if phone or short then 1 else math.clamp(viewport.X/1440,0.85,1.3)
    scale.Scale=s; w,h=viewport.X/s,viewport.Y/s
    root.Size=UDim2.fromOffset(w,h)
    panel.Size=UDim2.fromOffset(if phone then w-20 else math.min(760,w-380),math.max(250,math.min(520,h-180)))
    status.Size=UDim2.fromOffset(if phone then w-24 else math.min(600,w-390),if phone then 56 else 50)
    if phone then
        title.Text="CLAW MACHINE EMPIRE"; title.TextSize=23; title.Position=UDim2.fromOffset(12,4); title.Size=UDim2.new(1,-24,0,36)
        buildLabel.Visible=false; mode.Position=UDim2.fromOffset(12,112); mode.Size=UDim2.new(1,-24,0,19); mode.TextSize=11
        for i,key in ipairs({"Coins","Bank","Rate"}) do
            local f=stats[key].Parent; f.Position=UDim2.new((i-1)/3,8,0,48); f.Size=UDim2.new(1/3,-16,0,58)
            f.Label.Size=UDim2.new(1,-10,0,16); f.Label.Position=UDim2.fromOffset(5,4); f.Label.TextSize=10
            stats[key].Position=UDim2.fromOffset(5,21); stats[key].Size=UDim2.new(1,-10,0,30); stats[key].TextSize=22
        end
        nav.Position=UDim2.new(0,8,1,-58); nav.Size=UDim2.new(1,-16,0,50)
        for _,b in ipairs(nav:GetChildren()) do
            if b:IsA("TextButton") then local i=b.LayoutOrder; b.Position=UDim2.new((i-1)/4,0,0,0); b.Size=UDim2.new(0.25,-7,0,48); b.TextSize=13 end
        end
        tutorial.Visible=false
        play.Position=UDim2.new(0,12,1,-129); play.Size=UDim2.new(0.57,-18,0,54); play.TextSize=19
        collect.Position=UDim2.new(0.57,0,1,-129); collect.Size=UDim2.new(0.43,-12,0,54); collect.TextSize=16
        attempts.Position=UDim2.new(0,12,1,-78); attempts.Size=UDim2.new(1,-24,0,18); attempts.TextSize=11
        status.Position=UDim2.new(0.5,0,0,137); statusText.TextSize=15
        local compact=h<700
        aimPanel.Position=UDim2.new(0.5,-150,0,199); aimPanel.Size=UDim2.fromOffset(300,if compact then 145 else 215)
        board.Size=UDim2.fromOffset(270,if compact then 90 else 150); board.Position=UDim2.fromOffset(15,43)
        timer.Size=UDim2.fromOffset(280,28); timer.TextSize=20
        aimPanel.AimHint.Visible=false
        dpad.Position=UDim2.new(0.5,-132,1,-200); dpad.Size=UDim2.fromOffset(264,54)
        for i,name in ipairs({"Left","Up","Down","Right"}) do dpad[name].Position=UDim2.fromOffset((i-1)*66,0) end
        exit.Position=UDim2.new(1,-112,1,-195); exit.Size=UDim2.fromOffset(96,48)
    else
        title.Text="CLAW MACHINE\nEMPIRE"; title.TextSize=34; title.Position=UDim2.fromOffset(24,12); title.Size=UDim2.fromOffset(330,92)
        buildLabel.Visible=true; mode.Position=UDim2.new(1,-470,0,102); mode.Size=UDim2.fromOffset(445,22); mode.TextSize=14
        for i,key in ipairs({"Coins","Bank","Rate"}) do
            local f=stats[key].Parent; f.Position=UDim2.new(1,-(4-i)*204-24,0,24); f.Size=UDim2.fromOffset(190,70)
            f.Label.Position=UDim2.fromOffset(10,7); f.Label.Size=UDim2.fromOffset(170,18); f.Label.TextSize=14
            stats[key].Position=UDim2.fromOffset(10,28); stats[key].Size=UDim2.fromOffset(170,34); stats[key].TextSize=29
        end
        nav.Position=UDim2.fromOffset(24,170); nav.Size=UDim2.fromOffset(166,296)
        for _,b in ipairs(nav:GetChildren()) do if b:IsA("TextButton") then b.Position=UDim2.fromOffset(0,(b.LayoutOrder-1)*72); b.Size=UDim2.fromOffset(166,58); b.TextSize=21 end end
        tutorial.Visible=true; status.Position=UDim2.new(0.5,0,0,137); statusText.TextSize=19
        play.Position=UDim2.new(0.5,-168,1,-103); play.Size=UDim2.fromOffset(336,70); play.TextSize=26
        collect.Position=UDim2.new(1,-282,1,-112); collect.Size=UDim2.fromOffset(258,58); collect.TextSize=23
        attempts.Position=UDim2.new(0.5,-210,1,-30); attempts.Size=UDim2.fromOffset(420,22); attempts.TextSize=16
        aimPanel.Position=UDim2.new(1,-378,0,205); aimPanel.Size=UDim2.fromOffset(354,300)
        board.Position=UDim2.fromOffset(18,53); board.Size=UDim2.fromOffset(318,170)
        timer.Size=UDim2.fromOffset(334,32); timer.TextSize=23
        aimPanel.AimHint.Position=UDim2.fromOffset(10,234); aimPanel.AimHint.Size=UDim2.fromOffset(334,53); aimPanel.AimHint.TextSize=17
        aimPanel.AimHint.Visible=true
        dpad.Position=UDim2.new(0,35,1,-220); dpad.Size=UDim2.fromOffset(174,174)
        for _,spec in ipairs({{"Up",60,0},{"Left",0,60},{"Down",60,120},{"Right",120,60}}) do dpad[spec[1]].Position=UDim2.fromOffset(spec[2],spec[3]) end
        exit.Position=UDim2.new(0.5,190,1,-90); exit.Size=UDim2.fromOffset(110,48)
        if short then
            title.Text="CLAW MACHINE\nEMPIRE"; title.Position=UDim2.fromOffset(12,8); title.Size=UDim2.fromOffset(240,58); title.TextSize=24
            buildLabel.Visible=false; tutorial.Visible=false
            mode.Position=UDim2.new(1,-470,0,73); mode.TextSize=11; mode.Size=UDim2.fromOffset(458,16)
            for i,key in ipairs({"Coins","Bank","Rate"}) do
                local f=stats[key].Parent; f.Position=UDim2.new(1,-(4-i)*156-12,0,10); f.Size=UDim2.fromOffset(144,58)
                f.Label.Position=UDim2.fromOffset(5,5); f.Label.Size=UDim2.fromOffset(134,16); f.Label.TextSize=11
                stats[key].Position=UDim2.fromOffset(5,23); stats[key].Size=UDim2.fromOffset(134,30); stats[key].TextSize=24
            end
            nav.Position=UDim2.fromOffset(12,95); nav.Size=UDim2.fromOffset(128,196)
            for _,b in ipairs(nav:GetChildren()) do if b:IsA("TextButton") then b.Position=UDim2.fromOffset(0,(b.LayoutOrder-1)*49); b.Size=UDim2.fromOffset(128,44); b.TextSize=17 end end
            status.Position=UDim2.new(0.5,0,0,92); status.Size=UDim2.fromOffset(math.min(440,w-300),40); statusText.TextSize=15
            play.Position=UDim2.new(0.5,-140,1,-70); play.Size=UDim2.fromOffset(240,50); play.TextSize=22
            collect.Position=UDim2.new(1,-242,1,-70); collect.Size=UDim2.fromOffset(230,50); collect.TextSize=20
            attempts.Position=UDim2.new(0.5,-180,1,-18); attempts.Size=UDim2.fromOffset(360,16); attempts.TextSize=12
            aimPanel.Position=UDim2.new(1,-294,0,137); aimPanel.Size=UDim2.fromOffset(282,145)
            board.Position=UDim2.fromOffset(10,40); board.Size=UDim2.fromOffset(262,94)
            timer.Size=UDim2.fromOffset(262,26); timer.TextSize=19; aimPanel.AimHint.Visible=false
            dpad.Position=UDim2.new(0,12,1,-136); dpad.Size=UDim2.fromOffset(264,54)
            for i,name in ipairs({"Left","Up","Down","Right"}) do dpad[name].Position=UDim2.fromOffset((i-1)*66,0) end
            exit.Position=UDim2.new(0,12,1,-70); exit.Size=UDim2.fromOffset(110,48)
        end
    end
    if not latest or not latest.round then cameraState.Value=homeCamera() end
end
local function row(name,height,color)
    local f=frame(scroll,name,UDim2.new(),UDim2.new(1,-10,0,height),color or Color3.fromRGB(235,232,250))
    f.LayoutOrder=#scroll:GetChildren(); return f
end
local function rowText(f,value,y,size,color)
    local l=text(f,"Detail",value,UDim2.fromOffset(16,y),UDim2.new(1,-32,0,size+10),size,color or C.navy)
    l.TextStrokeTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; return l
end
local rebuild
local function open(name)
    if latest and latest.round then toast("Finish your claw round first.",C.yellow); return end
    panelName=name; rebuild()
end
for i,spec in ipairs({{"Plushies",C.pink},{"Machines",C.cyan},{"Upgrades",C.purple},{"Shop",C.yellow}}) do
    local b=button(nav,spec[1],string.upper(spec[1]),UDim2.fromOffset(0,(i-1)*72),UDim2.fromOffset(166,58),spec[2],function() open(spec[1]) end)
    b.LayoutOrder=i
end
local function isDisplayed(id)
    for _,shown in ipairs(latest.state.display) do if shown==id then return true end end
    return false
end
local indexMode=false
rebuild=function()
    if not panelName or not latest then panel.Visible=false; return end
    panel.Visible=true; panelTitle.Text=string.upper(panelName)
    for _,child in ipairs(scroll:GetChildren()) do if child~=list then child:Destroy() end end
    local state=latest.state
    if panelName=="Plushies" then
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
        for i,spec in ipairs(Config.Machines) do
            local f=row(spec.id,140,Color3.fromRGB(table.unpack(spec.color)))
            rowText(f,spec.name,12,27)
            rowText(f,if i<=state.machine then "OWNED  /  FREE CLAW PLAYS" else "Unlock for $"..spec.cost.." earned coins",52,16)
            if i==state.machine+1 then
                button(f,"Unlock","UNLOCK  $"..spec.cost,UDim2.fromOffset(16,87),UDim2.new(1,-32,0,44),C.mint,function() request:FireServer("unlock") end).TextSize=20
            else rowText(f,if i==state.machine then "CURRENT MACHINE" else "COMPLETED",92,18) end
        end
        local f=row("Next",95,C.navy); rowText(f,"NEXT: NEON CLAW",10,23,C.pink); rowText(f,"Build 02 adds more tiers. Not playable yet.",51,15,C.white)
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
local function drawTargets(targets)
    for _,child in ipairs(board:GetChildren()) do if child.Name=="PrizeDot" then child:Destroy() end end
    for _,t in ipairs(targets) do
        local spec=Config.plushie(t.species)
        local dot=frame(board,"PrizeDot",UDim2.fromScale((t.x+4)/8,(t.z+3)/6),UDim2.fromOffset(38,30),Color3.fromRGB(table.unpack(spec.color)))
        dot.AnchorPoint=Vector2.new(0.5,0.5); round(dot,10)
        text(dot,"Species",string.upper(string.sub(spec.id,1,2)),UDim2.new(),UDim2.fromScale(1,1),13)
    end
end
local lastViewKey=""
update.OnClientEvent:Connect(function(data)
    latest=data; offset=data.offset
    local state=data.state
    stats.Coins.Text="$"..Big.format(state.coins); stats.Bank.Text="$"..Big.format(state.bank)
    stats.Rate.Text="$"..Big.format(Economy.rate(state))
    collect.Text="COLLECT  $"..Big.format(state.bank)
    mode.Text=if data.sessionOnly then "STUDIO DEMO  /  PROGRESS RESETS WHEN PLAY STOPS" else "PERSISTENT ARCADE  /  AUTOSAVE ON"
    local roundData=data.round
    aimPanel.Visible=roundData~=false; dpad.Visible=roundData~=false; exit.Visible=roundData~=false
    nav.Visible=roundData==false; collect.Visible=roundData==false
    tutorial.Visible=roundData==false and not phone and h>=650
    local newId=roundData and roundData.id or nil
    if newId~=lastRoundId then
        keys={}; held={}; panelName=nil; panel.Visible=false
        if controls then if newId then controls:Disable() else controls:Enable() end end
        if roundData then drawTargets(roundData.targets) end
        lastRoundId=newId
        local target
        if newId then
            local x=if state.machine==1 then -23 else -4
            target=CFrame.lookAt(offset+Vector3.new(x,33,2),offset+Vector3.new(x,7,-14))
        else target=homeCamera() end
        local plotFolder=workspace:FindFirstChild("ClawEmpirePlots")
        local ownPlot=plotFolder and plotFolder:FindFirstChild("Arcade_"..player.UserId)
        if ownPlot then
            for _,p in ipairs(ownPlot:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name=="TopCapOutline" or p.Name=="TopCap" or p.Name=="Header") then
                    p.LocalTransparencyModifier=if newId then 1 else 0
                end
            end
        end
        TweenService:Create(cameraState,TweenInfo.new(0.65,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Value=target}):Play()
    end
    if roundData then
        play.Text=if roundData.phase=="drop" then "CATCHING..." else "DROP CLAW!"
        play.Active=roundData.phase=="aim"
        timer.Text=if roundData.phase=="drop" then "FINGERS CROSSED!" else "AIM  /  "..math.ceil(roundData.remaining).."s"
        cursor.Position=UDim2.fromScale((roundData.x+4)/8,(roundData.z+3)/6)
    else play.Text="PLAY "..(if state.machine==1 then "RUSTY" else "CLASSIC").."  >"; play.Active=true end
    attempts.Text=data.attempts.." FREE PLAYS  /  "..(if data.attempts>=Config.FreeAttempts then "FULLY CHARGED" else "NEXT PLAY IN "..math.ceil(data.nextAttempt).."s")
    tutorialBody.Text=(if state.totalCatches>0 then "[OK]" else "1").."  CATCH A PLUSHIE\n"..
        (if #state.display>0 then "[OK]" else "2").."  DISPLAY IT\n3  COLLECT YOUR INCOME\n"..
        (if state.machine>1 then "[OK]  CLASSIC UNLOCKED!" else "4  UNLOCK CLASSIC  $250")
    if data.message then
        toast(data.message,if data.kind=="error" or data.kind=="miss" then C.pink else C.mint)
        if data.kind=="catch" then
            for i=1,20 do
                local f=frame(root,"CatchConfetti",UDim2.fromScale(0.5,0.45),UDim2.fromOffset(9,17),({C.mint,C.pink,C.yellow,C.cyan})[i%4+1])
                f.Rotation=i*21
                TweenService:Create(f,TweenInfo.new(1.4),{Position=UDim2.fromScale((i*37%100)/100,1.2),Rotation=i*113,BackgroundTransparency=1}):Play()
                task.delay(1.5,function() f:Destroy() end)
            end
            task.delay(0.9,function() if not (latest and latest.round) then indexMode=false; open("Plushies") end end)
        end
    end
    local viewKey=panelName and (panelName..":"..#state.inventory..":"..table.concat(state.display,",")..":"..state.machine..":"..state.upgrades.speed..":"..state.upgrades.shelves) or ""
    if viewKey~=lastViewKey then lastViewKey=viewKey; rebuild() end
end)
UIS.InputBegan:Connect(function(input,processed)
    if processed or not latest or not latest.round then return end
    keys[input.KeyCode]=true
    if input.KeyCode==Enum.KeyCode.Space then request:FireServer("drop") end
    if input.KeyCode==Enum.KeyCode.Escape and latest.round.phase=="aim" then request:FireServer("cancel") end
end)
UIS.InputEnded:Connect(function(input) keys[input.KeyCode]=nil end)
UIS.WindowFocusReleased:Connect(function() keys={}; held={} end)
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
    elapsed+=dt
    if elapsed<0.1 then return end; elapsed=0
    if latest and latest.round and latest.round.phase=="aim" then
        local left=keys[Enum.KeyCode.A] or keys[Enum.KeyCode.Left] or held.Left
        local right=keys[Enum.KeyCode.D] or keys[Enum.KeyCode.Right] or held.Right
        local up=keys[Enum.KeyCode.W] or keys[Enum.KeyCode.Up] or held.Up
        local down=keys[Enum.KeyCode.S] or keys[Enum.KeyCode.Down] or held.Down
        request:FireServer("aim",{x=(if right then 1 else 0)-(if left then 1 else 0),z=(if down then 1 else 0)-(if up then 1 else 0)})
    end
end)
local camera=workspace.CurrentCamera
RunService:BindToRenderStep("ClawEmpireCamera",Enum.RenderPriority.Camera.Value+1,function()
    local cam=workspace.CurrentCamera
    cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=cameraState.Value; cam.FieldOfView=60
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() layout(); if panelName then rebuild() end end)
layout()
request:FireServer("sync")
task.spawn(function()
    while not latest do task.wait(1); request:FireServer("sync") end
    if not lastRoundId then
        cameraState.Value=homeCamera()
    end
end)
print("CME_CLIENT_READY",Config.Build)

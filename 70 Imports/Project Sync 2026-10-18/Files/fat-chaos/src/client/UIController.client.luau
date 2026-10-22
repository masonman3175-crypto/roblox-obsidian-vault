local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local folder=RS:WaitForChild("FatChaos")
local C=require(folder:WaitForChild("Config"))
local action=folder:WaitForChild("Action");local state=folder:WaitForChild("State");local fx=folder:WaitForChild("FX")
local gui=Instance.new("ScreenGui");gui.Name="FatChaosHUD";gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets;gui.Parent=player:WaitForChild("PlayerGui")
local palette={Dark=Color3.fromRGB(20,17,40),Panel=Color3.fromRGB(33,27,61),Muted=Color3.fromRGB(163,158,188),Gold=Color3.fromRGB(255,204,76),Purple=Color3.fromRGB(155,87,255),Blue=Color3.fromRGB(57,200,255)}
local function round(x,r) local v=Instance.new("UICorner");v.CornerRadius=UDim.new(0,r or 14);v.Parent=x end
local function stroke(x,col) local v=Instance.new("UIStroke");v.Color=col or Color3.fromRGB(86,66,129);v.Thickness=1.5;v.Parent=x end
local function text(parent,value,size,color)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=value;t.TextColor3=color or Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextSize=size or 16;t.TextWrapped=true;t.Parent=parent;return t
end
local function frame(parent,size,pos,color)
 local f=Instance.new("Frame");f.Size=size;f.Position=pos;f.BackgroundColor3=color or palette.Panel;f.BorderSizePixel=0;f.Parent=parent;round(f);return f
end
local function button(parent,value,color,callback)
 local b=Instance.new("TextButton");b.Text=value;b.BackgroundColor3=color or palette.Purple;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=15;b.TextWrapped=true;b.AutoButtonColor=true;b.BorderSizePixel=0;b.Parent=parent;round(b,11)
 b.Activated:Connect(callback);return b
end
local function fmt(n) if n>=1e6 then return string.format("%.1fM",n/1e6) elseif n>=10000 then return string.format("%.1fK",n/1000) else return tostring(math.floor(n)) end end
local profile;local snapshot;local tab="POWERS";local menuOpen=false;local coolUntil=0
local top=frame(gui,UDim2.new(1,-28,0,85),UDim2.fromOffset(14,10),palette.Dark);stroke(top)
local brand=text(top,"FAT\nCHAOS",18,palette.Gold);brand.Position=UDim2.fromOffset(14,10);brand.Size=UDim2.fromOffset(75,65)
local icon=Instance.new("ImageLabel");icon.Name="ForgeBurgerIcon";icon.BackgroundTransparency=1;icon.Size=UDim2.fromOffset(52,52);icon.Position=UDim2.fromOffset(80,17);icon.Image=folder:GetAttribute("BurgerIcon") or "";icon.Visible=icon.Image~="";icon.Parent=top
local sizeText=text(top,"0 SIZE",27);sizeText.Position=UDim2.new(.22,0,0,10);sizeText.Size=UDim2.new(.29,0,0,35)
local growText=text(top,"+1 / sec • x1 growth",12,palette.Muted);growText.Position=UDim2.new(.22,0,0,48);growText.Size=UDim2.new(.29,0,0,24)
local coinText=text(top,"0 COINS",21,palette.Gold);coinText.Position=UDim2.new(.52,0,0,10);coinText.Size=UDim2.new(.27,0,0,35)
local rebText=text(top,"0 REBIRTHS",12,palette.Muted);rebText.Position=UDim2.new(.52,0,0,48);rebText.Size=UDim2.new(.27,0,0,24)
local menuBtn=button(top,"MENU",palette.Purple,function() menuOpen=not menuOpen end);menuBtn.Position=UDim2.new(1,-88,0,22);menuBtn.Size=UDim2.fromOffset(74,42)
local boss=frame(gui,UDim2.new(.6,0,0,62),UDim2.new(.2,0,0,104),palette.Dark);stroke(boss,palette.Purple)
local bossTitle=text(boss,"BUFFET BARON • arriving soon",13);bossTitle.Position=UDim2.fromOffset(8,5);bossTitle.Size=UDim2.new(1,-16,0,23)
local bossBack=frame(boss,UDim2.new(1,-24,0,15),UDim2.fromOffset(12,35),Color3.fromRGB(63,37,80))
local bossFill=frame(bossBack,UDim2.fromScale(1,1),UDim2.new(),Color3.fromRGB(255,95,132))
local notice=text(gui,"+1 SIZE EVERY SECOND • Eat burgers to get started!",18,palette.Gold);notice.Position=UDim2.new(.1,0,0,176);notice.Size=UDim2.new(.8,0,0,52)
local noticeSerial=0
local function ping()
 local s=Instance.new("Sound");s.SoundId="rbxasset://sounds/electronicpingshort.wav";s.Volume=.25;s.PlaybackSpeed=1.15;s.Parent=game:GetService("SoundService");s:Play();Debris:AddItem(s,2)
end
local function toast(value)
 noticeSerial+=1;local serial=noticeSerial;notice.Text=value;notice.TextTransparency=0
 task.delay(4,function() if serial==noticeSerial then Tween:Create(notice,TweenInfo.new(.5),{TextTransparency=1}):Play() end end)
end
local bottom=frame(gui,UDim2.new(1,-28,0,90),UDim2.new(0,14,1,-104),palette.Dark);stroke(bottom)
local equipped=text(bottom,"↑ SUPER JUMP",15,palette.Blue);equipped.Position=UDim2.new(.02,0,0,8);equipped.Size=UDim2.new(.28,0,0,34)
local cd=text(bottom,"READY • Q / TAP",12,palette.Muted);cd.Position=UDim2.new(.02,0,0,47);cd.Size=UDim2.new(.28,0,0,25)
local activate=button(bottom,"USE POWER",palette.Blue,function() action:FireServer("activate") end);activate.Position=UDim2.new(.31,0,0,15);activate.Size=UDim2.new(.29,-8,0,60)
local roll=button(bottom,"ROLL POWER\n15 earned Coins",palette.Purple,function() action:FireServer("roll") end);roll.Position=UDim2.new(.62,0,0,15);roll.Size=UDim2.new(.36,-12,0,60)
local hint=text(gui,"FREE TO PLAY • Powers cannot hurt other players",11,palette.Muted);hint.Position=UDim2.new(.08,0,1,-18);hint.Size=UDim2.new(.84,0,0,15)
local panel=frame(gui,UDim2.new(.92,0,.62,0),UDim2.new(.04,0,.22,0),palette.Dark);panel.Visible=false;panel.ZIndex=5;stroke(panel,palette.Purple)
local constraint=Instance.new("UISizeConstraint");constraint.MaxSize=Vector2.new(850,620);constraint.MinSize=Vector2.new(280,170);constraint.Parent=panel
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.49)
local heading=text(panel,"YOUR CHAOS COLLECTION",20,palette.Gold);heading.Position=UDim2.fromOffset(18,9);heading.Size=UDim2.new(1,-80,0,34)
local close=button(panel,"×",Color3.fromRGB(71,49,99),function() menuOpen=false end);close.Position=UDim2.new(1,-50,0,10);close.Size=UDim2.fromOffset(36,34)
local tabs=Instance.new("ScrollingFrame");tabs.Size=UDim2.new(1,-24,0,46);tabs.Position=UDim2.fromOffset(12,50);tabs.BackgroundTransparency=1;tabs.BorderSizePixel=0;tabs.ScrollBarThickness=2;tabs.AutomaticCanvasSize=Enum.AutomaticSize.X;tabs.CanvasSize=UDim2.new();tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.Parent=panel
local row=Instance.new("UIListLayout");row.FillDirection=Enum.FillDirection.Horizontal;row.Padding=UDim.new(0,6);row.Parent=tabs
local list=Instance.new("ScrollingFrame");list.Size=UDim2.new(1,-24,1,-138);list.Position=UDim2.fromOffset(12,102);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=5;list.ScrollBarImageColor3=palette.Purple;list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.Parent=panel
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.Parent=list
local save=text(panel,"Connecting…",11,palette.Muted);save.Position=UDim2.new(0,12,1,-29);save.Size=UDim2.new(1,-24,0,22)
local rebuild
for _,name in ipairs({"POWERS","ZONES","REBIRTH","DAILY","SHOP","RECORDS"}) do local b=button(tabs,name,Color3.fromRGB(67,46,104),function() tab=name;rebuild() end);b.Size=UDim2.fromOffset(104,38) end
local function card(title,description,color,btn,callback)
 local f=frame(list,UDim2.new(1,-8,0,94),UDim2.new(),palette.Panel)
 local a=text(f,title,16,color);a.TextXAlignment=Enum.TextXAlignment.Left;a.Position=UDim2.fromOffset(14,7);a.Size=UDim2.new(1,-150,0,30)
 local b=text(f,description,12,palette.Muted);b.TextXAlignment=Enum.TextXAlignment.Left;b.Position=UDim2.fromOffset(14,40);b.Size=UDim2.new(1,-150,0,46)
 if btn then local c=button(f,btn,color,callback);c.Position=UDim2.new(1,-125,0,23);c.Size=UDim2.fromOffset(110,49);c.TextColor3=palette.Dark end
end
rebuild=function()
 for _,v in ipairs(list:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
 if not profile then return end
 if tab=="POWERS" then
  local discovered=0;for _ in pairs(profile.Powers) do discovered+=1 end;heading.Text="POWER INDEX • "..discovered.." / "..#C.Powers
  for _,p in ipairs(C.Powers) do local owned=profile.Powers[p.Id];local r=C.Rarities[p.Rarity]
   card(p.Icon.." "..p.Name.." • "..r.Name,(owned and p.Description or "UNDISCOVERED • "..p.Description).." • "..p.Cooldown.."s cooldown",owned and r.Color or palette.Muted,owned and (profile.Equipped==p.Id and "EQUIPPED" or "EQUIP") or nil,function() action:FireServer("equip",p.Id) end)
  end
 elseif tab=="ZONES" then heading.Text="EXPLORE THE FOODVERSE"
  for i,z in ipairs(C.Zones) do card(i.." • "..z.Name,z.Size.." Size + "..z.Coins.." Coins • unlock in order",z.Color,i<=profile.Zone and "TRAVEL" or "UNLOCK",function() action:FireServer("zone",tostring(i)) end) end
  card("TRAINING SPRINT","Jump to the last platform in 35 seconds. +40 Coins, once per minute.",palette.Blue,"START",function() action:FireServer("challenge") end)
  card("COSMIC BOSS ARENA","Travel to Zone 4, then follow the north bridge. Dodge red circles, use Q to attack.",palette.Purple,"TRAVEL",function() action:FireServer("zone","4") end)
 elseif tab=="REBIRTH" then heading.Text="RESET SMALL. RETURN STRONGER."
  card("REBIRTH #"..(profile.Rebirths+1),"Requires "..snapshot.RebirthCost.." Size. Resets only Size; keeps Coins, zones, powers, cosmetics. +100 Coins.",palette.Gold,"REBIRTH",function() action:FireServer("rebirth") end)
  card("PERMANENT GROWTH","Current x"..snapshot.Multiplier.." → x"..C.Multiplier(profile.Rebirths+1).." after rebirth. Applies to passive and food growth.",palette.Blue)
 elseif tab=="DAILY" then heading.Text="DAILY GOALS • NO STREAK PRESSURE"
  for _,g in ipairs({{"growth","Grow 120 Size","Growth",120,75},{"food","Eat 20 burgers","Food",20,60},{"boss","Help defeat a boss","Boss",1,120}}) do local claimed=profile.Daily.Claimed[g[1]];card(g[2],math.floor(profile.Daily[g[3]]).." / "..g[4].." • +"..g[5].." Coins • resets at UTC midnight",palette.Blue,claimed and "CLAIMED" or "CLAIM",function() action:FireServer("claim",g[1]) end) end
 elseif tab=="SHOP" then heading.Text="STYLE SHOP • EARNED COINS ONLY"
  for _,item in ipairs(C.Cosmetics) do local owned=profile.Cosmetics[item.Id];card(item.Name,item.Kind.." • "..item.Cost.." earned Coins • no gameplay advantage",item.Color,owned and "EQUIP / USE" or "BUY",function() action:FireServer("cosmetic",item.Id) end) end
 else heading.Text="YOUR LEGITIMATE RECORDS"
  card(profile.Title,"Best Size: "..fmt(profile.Best).." • XP: "..fmt(profile.XP).." • Rebirths: "..profile.Rebirths,palette.Gold)
  card("THE COLLECTION","Burgers: "..profile.Food.." • Boss wins: "..profile.BossWins.." • Rolls: "..profile.Rolls,palette.Blue)
  card("SERVER LEADERBOARD","Press Tab / use Roblox player list to see live Size, personal Best, Rebirths and training Sprint scores.",palette.Purple)
  for k in pairs(profile.Achievements) do card("✓ "..string.upper(k),"Achievement unlocked",palette.Gold) end
 end
end
state.OnClientEvent:Connect(function(s)
 snapshot=s;profile=s.Profile;coolUntil=os.clock()+s.Cooldown
 sizeText.Text=fmt(profile.Size).." SIZE";growText.Text="+"..s.Multiplier.." / sec • x"..s.Multiplier.." growth";coinText.Text=fmt(profile.Coins).." COINS";rebText.Text=profile.Rebirths.." REBIRTHS • "..fmt(profile.XP).." XP"
 local p=C.Power(profile.Equipped);if p then equipped.Text=p.Icon.." "..string.upper(p.Name) end
 bossTitle.Text=s.Boss.Active and (s.Boss.Name.." • "..s.Boss.Health.." / "..s.Boss.MaxHealth) or ("BUFFET BARON RETURNS IN "..s.Boss.Next.."s")
 Tween:Create(bossFill,TweenInfo.new(.3),{Size=UDim2.fromScale(s.Boss.Active and s.Boss.Health/s.Boss.MaxHealth or 0,1)}):Play()
 save.Text=s.SaveStatus..(s.Challenge>0 and (" • Sprint: "..math.ceil(s.Challenge).."s") or "")
 if menuOpen then rebuild() end
end)
UIS.InputBegan:Connect(function(input,processed) if processed then return end;if input.KeyCode==Enum.KeyCode.Q or input.KeyCode==Enum.KeyCode.ButtonR2 then action:FireServer("activate") elseif input.KeyCode==Enum.KeyCode.M then menuOpen=not menuOpen end end)
local effectCount=0
local function sphere(pos,radius,color,duration)
 if effectCount>24 then return end;effectCount+=1
 local p=Instance.new("Part");p.Shape=Enum.PartType.Ball;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.5;p.Size=Vector3.one;p.Position=pos;p.Parent=workspace
 Tween:Create(p,TweenInfo.new(duration or .65),{Size=Vector3.one*radius*2,Transparency=1}):Play();Debris:AddItem(p,duration or .65);task.delay(duration or .65,function() effectCount-=1 end)
end
local function ring(data,warning)
 if effectCount>24 then return end;effectCount+=1
 local p=Instance.new("Part");p.Shape=Enum.PartType.Cylinder;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=warning and Color3.fromRGB(255,61,95) or data.Color;p.Transparency=.5;p.Size=Vector3.new(.18,data.Radius*2,data.Radius*2);p.CFrame=CFrame.new(data.Position.X,.5,data.Position.Z)*CFrame.Angles(0,0,math.pi/2);p.Parent=workspace
 local duration=warning and data.Duration or .7
 Tween:Create(p,TweenInfo.new(duration),{Transparency=1}):Play();Debris:AddItem(p,duration);task.delay(duration,function() effectCount-=1 end)
end
local reveal=frame(gui,UDim2.fromOffset(300,210),UDim2.fromScale(.5,.48),palette.Panel);reveal.AnchorPoint=Vector2.new(.5,.5);reveal.Visible=false;reveal.ZIndex=9;stroke(reveal,palette.Gold)
local revealTitle=text(reveal,"POWER UNLOCKED!",16,palette.Gold);revealTitle.Size=UDim2.new(1,0,0,45)
local revealName=text(reveal,"",26);revealName.Position=UDim2.fromOffset(15,50);revealName.Size=UDim2.new(1,-30,0,100)
local revealClose=button(reveal,"LET'S GO",palette.Purple,function() reveal.Visible=false end);revealClose.Position=UDim2.new(.15,0,1,-49);revealClose.Size=UDim2.new(.7,0,0,36)
local revealToken=0
fx.OnClientEvent:Connect(function(kind,data)
 if kind=="notice" then toast(data.Text)
 elseif kind=="food" then toast("+"..data.Amount.." SIZE • +3 COINS");sphere(data.Position,5,palette.Gold,.45);ping()
 elseif kind=="warning" then toast(data.Label);ring(data,true)
 elseif kind=="impact" or kind=="entrance" then ring(data,false);sphere(data.Position+Vector3.new(0,3,0),data.Radius*.3,data.Color,.8)
 elseif kind=="hit" or kind=="dummy" then sphere(data.Position,data.Radius,data.Color,.5)
 elseif kind=="shake" then local cam=workspace.CurrentCamera;if cam then local old=cam.FieldOfView;cam.FieldOfView=old+5;Tween:Create(cam,TweenInfo.new(.3),{FieldOfView=old}):Play() end
 elseif kind=="reveal" then
  local power=C.Power(data.Id);revealToken+=1;local token=revealToken
  reveal.Visible=true;revealTitle.Text="ROLLING…";revealName.Text="✦  ✦  ✦"
  task.delay(.55,function() if token~=revealToken then return end;revealTitle.Text=data.Duplicate and "DUPLICATE • +5 COINS" or "NEW POWER UNLOCKED!";revealName.Text=power.Icon.." "..power.Name.."\n"..C.Rarities[power.Rarity].Name;revealName.TextColor3=C.Rarities[power.Rarity].Color end)
  task.delay(4,function() if token==revealToken then reveal.Visible=false end end)
 elseif kind=="emote" then
  local target=Players:GetPlayerByUserId(data.UserId);local c=target and target.Character;local r=c and c:FindFirstChild("HumanoidRootPart")
  if r then sphere(r.Position,8,palette.Gold,1);if target==player then local h=c:FindFirstChildOfClass("Humanoid");if h then h.Jump=true end;r.AssemblyAngularVelocity=Vector3.new(0,15,0);task.delay(1,function() if r.Parent then r.AssemblyAngularVelocity=Vector3.zero end end) end end
 elseif kind=="power" then
  sphere(data.Position,data.Kind=="titan" and 18 or math.min(data.Radius,25),data.Color,.65)
  if data.Kind=="wave" then for i=1,5 do task.delay(i*.06,function() sphere(data.Position+data.Direction*i*7,7,data.Color,.4) end) end
  elseif data.Kind=="clone" then
   for i=1,3 do
    local m=Instance.new("Model");m.Name="ShadowDecoy";m.Parent=workspace
    local at=data.Position+Vector3.new((i-2)*5,0,5)
    for _,spec in ipairs({{Vector3.new(2,3,1),Vector3.zero},{Vector3.new(2,2,2),Vector3.new(0,2.5,0)},{Vector3.new(1,3,1),Vector3.new(-1.5,0,0)},{Vector3.new(1,3,1),Vector3.new(1.5,0,0)}}) do local p=Instance.new("Part");p.Size=spec[1];p.Position=at+spec[2];p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Transparency=.5;p.Color=data.Color;p.Material=Enum.Material.Neon;p.Parent=m end
    Debris:AddItem(m,4)
   end
  elseif data.Kind=="glitch" then
   local world=workspace:FindFirstChild("FatChaosWorld");if world then for _,p in ipairs(world:GetChildren()) do if p:GetAttribute("GlitchProp") then local old=p.Color;p.Color=data.Color;Tween:Create(p,TweenInfo.new(.2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out,5,true),{Position=p.Position+Vector3.new(0,4,0)}):Play();task.delay(3,function() if p.Parent then p.Color=old end end) end end end
  end
 end
end)
local wasOpen=false;local compact=false
Run.RenderStepped:Connect(function()
 panel.Visible=menuOpen
 if menuOpen and not wasOpen then rebuild() end;wasOpen=menuOpen
 local left=math.max(0,coolUntil-os.clock());cd.Text=left>0 and (string.format("COOLDOWN • %.1fs",left)) or "READY • Q / TAP";activate.Text=left>0 and string.format("%.1fs",left) or "USE POWER"
 local camera=workspace.CurrentCamera;local small=camera and camera.ViewportSize.X<600
 if small~=compact then compact=small;sizeText.TextSize=small and 19 or 27;coinText.TextSize=small and 15 or 21;brand.TextSize=small and 13 or 18;brand.Size=UDim2.fromOffset(small and 54 or 75,65);brand.Position=UDim2.fromOffset(6,10);icon.Visible=not small and icon.Image~="";menuBtn.Size=UDim2.fromOffset(small and 58 or 74,42);menuBtn.Position=UDim2.new(1,small and -66 or -88,0,22);growText.TextSize=small and 9 or 12;rebText.TextSize=small and 9 or 12;equipped.TextSize=small and 11 or 15;notice.TextSize=small and 14 or 18 end
end)
action:FireServer("sync")
print("FAT CHAOS HUD READY")

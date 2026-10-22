-- Generated installer. Run in Studio Edit mode, not during a play session.
assert(not game:GetService("RunService"):IsRunning(),"Stop play before installation")
local rs=game:GetService("ReplicatedStorage")
local ss=game:GetService("ServerScriptService")
local sp=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
assert(not rs:FindFirstChild("FatChaos") and not ss:FindFirstChild("FatChaosServer"),"Fat Chaos already installed")
local shared=Instance.new("Folder");shared.Name="FatChaos";shared.Parent=rs
local server=Instance.new("Folder");server.Name="FatChaosServer";server.Parent=ss
local targets={shared=shared,server=server,client=sp}
do local s=Instance.new("ModuleScript");s.Name="Config";s.Source=[====[
local C = {}
C.Version = 1
C.RollCost = 15
C.RebirthBase = 500
C.Boss = {Health=900, Duration=100, Rest=35, Radius=58}
C.Zones = {
 {Name="FOOD TOWN", Size=0, Coins=0, Color=Color3.fromRGB(255,166,66)},
 {Name="TRAINING GROUNDS", Size=35, Coins=30, Color=Color3.fromRGB(55,215,220)},
 {Name="GIANT FOOD CITY", Size=120, Coins=80, Color=Color3.fromRGB(255,106,145)},
 {Name="COSMIC ARENA", Size=280, Coins=160, Color=Color3.fromRGB(150,105,255)},
 {Name="COLOSSAL WORLD", Size=650, Coins=350, Color=Color3.fromRGB(255,216,85)},
}
C.Rarities = {{Name="COMMON",Weight=60,Color=Color3.fromRGB(175,212,235)}, {Name="RARE",Weight=25,Color=Color3.fromRGB(50,185,255)}, {Name="EPIC",Weight=11,Color=Color3.fromRGB(190,100,255)}, {Name="LEGENDARY",Weight=3.5,Color=Color3.fromRGB(255,199,60)}, {Name="MYTHIC",Weight=.5,Color=Color3.fromRGB(255,85,155)}}
C.Powers = {
 {Id="jump",Name="Super Jump",Rarity=1,Kind="jump",Cooldown=8,Icon="↑",Description="Launch upward. Land safely and reach training platforms."},
 {Id="speed",Name="Speed Burst",Rarity=1,Kind="speed",Cooldown=12,Icon="»",Description="Run faster for six seconds."},
 {Id="punch",Name="Energy Punch",Rarity=1,Kind="blast",Cooldown=5,Damage=25,Radius=18,Icon="✦",Description="A close-range pulse that knocks training props away."},
 {Id="dash",Name="Dash",Rarity=1,Kind="dash",Cooldown=6,Icon="➜",Description="Burst forward with a bright energy trail."},
 {Id="lightning",Name="Lightning Dash",Rarity=2,Kind="dash",Cooldown=7,Damage=35,Radius=24,Icon="ϟ",Description="An electric dash that strikes nearby arena targets."},
 {Id="gravity",Name="Gravity Flip",Rarity=2,Kind="gravity",Cooldown=16,Damage=35,Radius=30,Icon="↕",Description="Brief personal gravity reversal inside the boss arena."},
 {Id="wave",Name="Energy Wave",Rarity=2,Kind="wave",Cooldown=10,Damage=45,Radius=45,Icon="≈",Description="Send a forward energy wave through the arena."},
 {Id="clone",Name="Shadow Clone",Rarity=2,Kind="clone",Cooldown=14,Icon="◈",Description="Leave three short-lived glowing visual decoys."},
 {Id="meteor",Name="Meteor Slam",Rarity=3,Kind="slam",Cooldown=15,Damage=75,Radius=35,Icon="▼",Description="Rise, then slam down in a telegraphed shockwave."},
 {Id="dragon",Name="Dragon Aura",Rarity=3,Kind="aura",Cooldown=18,Damage=65,Radius=30,Icon="♨",Description="A fiery aura and a strong arena energy pulse."},
 {Id="time",Name="Time Bubble",Rarity=3,Kind="time",Cooldown=22,Damage=35,Radius=40,Icon="◷",Description="Extend boss attack warnings for six seconds."},
 {Id="titan",Name="Titan Mode",Rarity=3,Kind="titan",Cooldown=25,Damage=70,Radius=35,Icon="▲",Description="Grow temporarily for eight seconds. No player damage."},
 {Id="cosmic",Name="Cosmic Breaker",Rarity=4,Kind="blast",Cooldown=22,Damage=110,Radius=50,Icon="✺",Description="A huge violet energy explosion in the arena."},
 {Id="thunder",Name="Thunder God Mode",Rarity=4,Kind="speed",Cooldown=24,Damage=95,Radius=45,Icon="ϟ",Description="Lightning aura, boosted movement, and an arena strike."},
 {Id="glitch",Name="Reality Glitch",Rarity=4,Kind="glitch",Cooldown=24,Damage=110,Radius=48,Icon="▧",Description="Glitch the arena props and unleash a colored pulse."},
 {Id="colossal",Name="Colossal Awakening",Rarity=4,Kind="titan",Cooldown=28,Damage=120,Radius=48,Icon="◆",Description="A dramatic giant transformation for eight seconds."},
 {Id="universe",Name="Universe Burst",Rarity=5,Kind="blast",Cooldown=30,Damage=160,Radius=55,Icon="✹",Description="A brilliant arena-wide burst. Never damages other players."},
 {Id="infinite",Name="Infinite Growth",Rarity=5,Kind="growth",Cooldown=40,Icon="∞",Description="Triple automatic and food growth for twelve seconds."},
 {Id="celestial",Name="Celestial Titan",Rarity=5,Kind="titan",Cooldown=32,Damage=160,Radius=55,Icon="★",Description="Become a glowing cosmic giant for eight seconds."},
}
C.Cosmetics = {
 {Id="mint",Name="Mint Aura",Cost=70,Kind="Aura",Color=Color3.fromRGB(60,255,185)},
 {Id="gold",Name="Golden Aura",Cost=150,Kind="Aura",Color=Color3.fromRGB(255,206,70)},
 {Id="violet",Name="Violet Aura",Cost=70,Kind="Aura",Color=Color3.fromRGB(170,90,255)},
 {Id="burger",Name="Burger Crown",Cost=120,Kind="Hat",Color=Color3.fromRGB(245,163,62)},
 {Id="neon",Name="Neon Trail",Cost=90,Kind="Trail",Color=Color3.fromRGB(66,210,255)},
 {Id="dance",Name="Victory Spin",Cost=50,Kind="Emote",Color=Color3.fromRGB(255,120,190)},
 {Id="vip",Name="Chill Lounge Pass",Cost=250,Kind="Lounge",Color=Color3.fromRGB(255,218,90)},
}
function C.Power(id) for _,p in ipairs(C.Powers) do if p.Id==id then return p end end end
function C.RebirthCost(n) return C.RebirthBase*(n+1) end
function C.Scale(size) return math.clamp(.8+math.log(1+size)/3,.8,4) end
function C.Multiplier(n) return 1+n*.5 end
function C.Roll(rng)
 local x=rng:NextNumber(0,100); local rarity=1
 for i,r in ipairs(C.Rarities) do x-=r.Weight; if x<=0 then rarity=i; break end end
 local pool={} for _,p in ipairs(C.Powers) do if p.Rarity==rarity then table.insert(pool,p) end end
 return pool[rng:NextInteger(1,#pool)]
end
return C
]====];s.Parent=targets.shared end
do local s=Instance.new("ModuleScript");s.Name="BossService";s.Source=[====[
local B={Active=false,Health=0,Participants={},SlowUntil=0}
function B.State(ctx)
 return {Active=B.Active,Health=B.Health,MaxHealth=ctx.Config.Boss.Health,Next=math.max(0,math.ceil((B.Next or os.clock())-os.clock())),Name="THE BUFFET BARON"}
end
function B.Hit(ctx,player,damage,pos,radius,directional)
 if not B.Active or not ctx.World.InArena(pos) then return false end
 local center=ctx.World.ArenaCenter+Vector3.new(0,8,0)
 local delta=center-pos
 if delta.Magnitude>radius+12 then return false end
 if directional and delta.Magnitude>1 and directional:Dot(delta.Unit)<.15 then return false end
 B.Health=math.max(0,B.Health-math.clamp(damage,0,160));B.Participants[player]=true
 ctx.FX:FireAllClients("hit",{Position=center,Color=Color3.fromRGB(255,200,60),Radius=8})
 return true
end
function B.Spawn(ctx)
 B.Active=true;B.Health=ctx.Config.Boss.Health;B.Participants={};B.End=os.clock()+ctx.Config.Boss.Duration
 local m=Instance.new("Model");m.Name="BuffetBaron";m.Parent=ctx.World.Root;B.Model=m
 local center=ctx.World.ArenaCenter
 local function p(name,size,offset,color,shape)
  local v=Instance.new("Part");v.Name=name;v.Size=size;v.Position=center+offset;v.Anchored=true;v.CanCollide=false;v.Color=color;v.Material=Enum.Material.SmoothPlastic;if shape then v.Shape=shape end;v.Parent=m;return v
 end
 p("Body",Vector3.new(22,23,17),Vector3.new(0,18,0),Color3.fromRGB(115,65,210),Enum.PartType.Ball)
 p("Head",Vector3.new(13,12,12),Vector3.new(0,35,0),Color3.fromRGB(255,199,139),Enum.PartType.Ball)
 for _,sign in ipairs({-1,1}) do p("Arm",Vector3.new(7,18,7),Vector3.new(sign*14,20,0),Color3.fromRGB(255,199,139));p("Boot",Vector3.new(10,7,13),Vector3.new(sign*7,4,0),Color3.fromRGB(43,31,72));p("Eye",Vector3.new(1.5,2,1),Vector3.new(sign*2.5,36,-5.5),Color3.fromRGB(32,23,45)) end
 p("Grin",Vector3.new(6,1,1),Vector3.new(0,32,-5.8),Color3.new(1,1,1))
 ctx.World.Burger(m,center+Vector3.new(0,43,0),4)
 ctx.Notify(nil,"THE GIANT HAS ARRIVED! • Cosmic Arena");ctx.FX:FireAllClients("entrance",{Position=center,Radius=55,Color=Color3.fromRGB(175,90,255)})
end
function B.Finish(ctx,victory)
 if not B.Active then return end;B.Active=false
 if victory then
  for player in pairs(B.Participants) do local p=ctx.Data.Profiles[player];if p then
   ctx.Coins.Add(ctx,player,180,100);p.BossWins+=1;p.Daily.Boss+=1;p.Achievements.boss=true
   -- Guaranteed cosmetic for participation, with a rarity-free clear reward.
   p.Cosmetics.gold=true;ctx.Notify(player,"BOSS CLEARED! +180 Coins • +100 XP • Golden Aura")
  end end
 end
 ctx.Notify(nil,victory and "BUFFET BARON: I demand a snack rematch!" or "The Baron retreats to refill the buffet!")
 if B.Model then B.Model:Destroy();B.Model=nil end;B.Next=os.clock()+ctx.Config.Boss.Rest
end
function B.Attack(ctx)
 if not B.Active then return end
 local center=ctx.World.ArenaCenter;local attack=ctx.RNG:NextInteger(1,3);local target=center
 if attack==2 then
  local candidates={};for player in pairs(ctx.Data.Profiles) do local c=player.Character;local r=c and c:FindFirstChild("HumanoidRootPart");if r and ctx.World.InArena(r.Position) then table.insert(candidates,r.Position) end end
  if #candidates>0 then target=candidates[ctx.RNG:NextInteger(1,#candidates)]*Vector3.new(1,0,1) end
 end
 local radius=attack==1 and 50 or (attack==2 and 17 or 34)
 local delay=(os.clock()<B.SlowUntil) and 3 or 1.8
 ctx.FX:FireAllClients("warning",{Position=target,Radius=radius,Duration=delay,Label=attack==1 and "JUMP THE STOMP!" or "LEAVE THE RED CIRCLE!"})
 task.delay(delay,function()
  if not B.Active then return end
  ctx.FX:FireAllClients("impact",{Position=target,Radius=radius,Color=Color3.fromRGB(255,118,75)})
  for player in pairs(ctx.Data.Profiles) do
   local c=player.Character;local r=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid")
   if r and h and h.Health>0 and ctx.World.InArena(r.Position) then
    local delta=r.Position-target;local distance=Vector2.new(delta.X,delta.Z).Magnitude
    if distance<radius and (attack~=1 or r.Position.Y<8*c:GetScale()) then h:TakeDamage(20);ctx.FX:FireClient(player,"shake",{Strength=1}) else
     B.Participants[player]=true;ctx.Coins.Add(ctx,player,2,2)
    end
   end
  end
 end)
end
return B
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="CoinService";s.Source=[====[
local S={}
function S.Add(ctx,player,coins,xp)
 local p=ctx.Data.Profiles[player];if not p then return end
 p.Coins+=math.max(0,math.floor(coins));p.XP+=math.max(0,math.floor(xp or 0))
end
return S
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="DataService";s.Source=[====[
local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local D={Profiles={},Sessions={},Status={},Saving={}}
local store
pcall(function() store=DSS:GetDataStore("FatChaosProfiles_v1") end)
local token=game.JobId~="" and game.JobId or Http:GenerateGUID(false)
local function fresh()
 return {Size=0,Coins=0,XP=0,Rebirths=0,Best=0,Zone=1,Powers={jump=true},Equipped="jump",Cosmetics={},EquippedCosmetic="",Food=0,BossWins=0,Rolls=0,Achievements={},Daily={Day=0,Growth=0,Food=0,Boss=0,Claimed={}},Title="Tiny Menace"}
end
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e15 end
function D.Sanitize(raw)
 local p=fresh()
 if type(raw)~="table" then return p end
 for _,key in ipairs({"Size","Coins","XP","Rebirths","Best","Zone","Food","BossWins","Rolls","BestSprint"}) do if finite(raw[key]) then p[key]=math.max(0,raw[key]) end end
 p.Zone=math.clamp(p.Zone,1,5);p.Rebirths=math.min(p.Rebirths,10000)
 for _,key in ipairs({"Powers","Cosmetics","Achievements"}) do if type(raw[key])=="table" then for k,v in pairs(raw[key]) do if type(k)=="string" and v==true then p[key][k]=true end end end end
 if type(raw.Equipped)=="string" and p.Powers[raw.Equipped] then p.Equipped=raw.Equipped end
 if type(raw.EquippedCosmetic)=="string" and p.Cosmetics[raw.EquippedCosmetic] then p.EquippedCosmetic=raw.EquippedCosmetic end
 if type(raw.Daily)=="table" then
  for _,k in ipairs({"Day","Growth","Food","Boss"}) do if finite(raw.Daily[k]) then p.Daily[k]=math.max(0,raw.Daily[k]) end end
  if type(raw.Daily.Claimed)=="table" then for k,v in pairs(raw.Daily.Claimed) do if type(k)=="string" and v==true then p.Daily.Claimed[k]=true end end end
 end
 return p
end
function D.Load(player)
 local key="u"..player.UserId; local profile; local state="Guest session • saving unavailable"
 for attempt=1,store and 3 or 0 do
  local locked=false
  local ok,value=pcall(function() return store:UpdateAsync(key,function(old)
   if type(old)=="table" and type(old.Lock)=="table" and old.Lock.Token~=token and (old.Lock.Time or 0)>os.time()-180 then locked=true;return nil end
   local p=D.Sanitize(old);p.Lock={Token=token,Time=os.time()};return p
  end) end)
  if ok and locked then return nil,"Your profile is active on another server. Please rejoin shortly." end
  if ok and value then profile=D.Sanitize(value);D.Sessions[player]=true;state="Cloud save connected";break end
  if attempt<3 then task.wait(attempt) end
 end
 if not player.Parent then return nil,"Player left" end
 D.Profiles[player]=profile or fresh();D.Status[player]=state
 return D.Profiles[player]
end
function D.Save(player,release)
 if D.Saving[player] then
  if not release then return false end
  local untilTime=os.clock()+10;while D.Saving[player] and os.clock()<untilTime do task.wait(.1) end
  if D.Saving[player] then return false end
 end
 local p=D.Profiles[player];if not p or not D.Sessions[player] then return false end
 D.Saving[player]=true
 local snapshot=D.Sanitize(p)
 for attempt=1,3 do
  local lost=false
  local ok,result=pcall(function() return store:UpdateAsync("u"..player.UserId,function(old)
   if type(old)~="table" or type(old.Lock)~="table" or old.Lock.Token~=token then lost=true;return nil end
   snapshot.Lock=not release and {Token=token,Time=os.time()} or nil;return snapshot
  end) end)
  if lost then D.Sessions[player]=nil;D.Status[player]="Save lock lost • rejoin recommended";D.Saving[player]=nil;return false end
  if ok and result then D.Status[player]="Saved to cloud";D.Saving[player]=nil;return true end
  if attempt<3 then task.wait(attempt) end
 end
 D.Status[player]="Cloud retry pending";D.Saving[player]=nil;return false
end
function D.Remove(player) D.Save(player,true);D.Profiles[player]=nil;D.Sessions[player]=nil;D.Status[player]=nil end
return D
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="GrowthService";s.Source=[====[
local G={}
function G.Scale(ctx,player)
 local p=ctx.Data.Profiles[player];local c=player.Character
 if not p or not c or not c:FindFirstChild("HumanoidRootPart") then return end
 local factor=ctx.Config.Scale(p.Size)*((player:GetAttribute("TitanUntil") or 0)>os.clock() and 1.6 or 1)
 -- Model:ScaleTo supports R6 and R15 and keeps joints/collision aligned.
 if math.abs(c:GetScale()-factor)>.015 then c:ScaleTo(factor) end
 local h=c:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=(player:GetAttribute("SpeedUntil") or 0)>os.clock() and 30 or 18;h.UseJumpPower=true;h.JumpPower=55 end
 local tag=c:FindFirstChild("GrowthTag",true)
 if not tag then
  local b=Instance.new("BillboardGui");b.Name="GrowthTag";b.Size=UDim2.fromOffset(210,55);b.StudsOffsetWorldSpace=Vector3.new(0,4,0);b.AlwaysOnTop=true;b.MaxDistance=130;b.Parent=c:FindFirstChild("Head") or c.PrimaryPart
  tag=Instance.new("TextLabel");tag.Name="Text";tag.Size=UDim2.fromScale(1,1);tag.BackgroundTransparency=1;tag.Font=Enum.Font.GothamBold;tag.TextColor3=Color3.new(1,1,1);tag.TextStrokeTransparency=.35;tag.TextScaled=true;tag.Parent=b
 end
 if tag:IsA("BillboardGui") then tag=tag:FindFirstChild("Text") end
 if tag then tag.Text=string.format("%s\n%d SIZE",p.Title,math.floor(p.Size)) end
end
function G.Add(ctx,player,amount,food)
 local p=ctx.Data.Profiles[player];if not p then return end
 local multiplier=ctx.Config.Multiplier(p.Rebirths)*((player:GetAttribute("GrowthUntil") or 0)>os.clock() and 3 or 1)
 local gain=amount*multiplier;p.Size+=gain;p.Best=math.max(p.Best,p.Size);p.Daily.Growth+=gain
 if food then p.Food+=1;p.Daily.Food+=1;ctx.Coins.Add(ctx,player,3,2) end
 p.Title=p.Best>=650 and "Cosmic Giant" or (p.Best>=120 and "Burger Titan" or "Tiny Menace")
 for _,threshold in ipairs({25,100,500,1000,5000}) do
  local key="size"..threshold
  if p.Best>=threshold and not p.Achievements[key] then p.Achievements[key]=true;ctx.Coins.Add(ctx,player,math.floor(threshold/5)+10,20);ctx.Notify(player,"MILESTONE • "..threshold.." SIZE!") end
 end
 G.Scale(ctx,player)
end
return G
]====];s.Parent=targets.server end
do local s=Instance.new("Script");s.Name="Main";s.Source=[====[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local modules=script.Parent
local shared=RS:WaitForChild("FatChaos")
local ctx={Config=require(shared.Config),Data=require(modules.DataService),Coins=require(modules.CoinService),Growth=require(modules.GrowthService),Powers=require(modules.PowerService),Boss=require(modules.BossService),Rebirth=require(modules.RebirthService),Purchases=require(modules.PurchaseService),Round=require(modules.RoundService),World=require(modules.WorldService),RNG=Random.new()}
local function remote(name) local r=Instance.new("RemoteEvent");r.Name=name;r.Parent=shared;return r end
local action=remote("Action");local state=remote("State");ctx.FX=remote("FX")
function ctx.Notify(player,text) if player then ctx.FX:FireClient(player,"notice",{Text=text}) else ctx.FX:FireAllClients("notice",{Text=text}) end end
ctx.World.Build(ctx)
local rate={};local busy={}
local function send(player)
 local p=ctx.Data.Profiles[player];if not p then return end
 local ready=ctx.Powers.Cooldowns[player] or 0
 state:FireClient(player,{Profile=p,SaveStatus=ctx.Data.Status[player],Boss=ctx.Boss.State(ctx),Cooldown=math.max(0,ready-os.clock()),Multiplier=ctx.Config.Multiplier(p.Rebirths),RebirthCost=ctx.Config.RebirthCost(p.Rebirths),Challenge=ctx.Round.Challenge[player] and math.max(0,35-(os.clock()-ctx.Round.Challenge[player].Started)) or 0})
 local leader=player:FindFirstChild("leaderstats");if leader then leader.Size.Value=math.floor(p.Size);leader.Best.Value=math.floor(p.Best);leader.Rebirths.Value=p.Rebirths;leader.Sprint.Value=p.BestSprint or 0 end
end
local function loaded(player)
 local p,reason=ctx.Data.Load(player);if not p then if player.Parent then player:Kick(reason) end;return end
 local leader=Instance.new("Folder");leader.Name="leaderstats";leader.Parent=player
 for _,key in ipairs({"Size","Best","Rebirths","Sprint"}) do local v=Instance.new("IntValue");v.Name=key;v.Parent=leader end
 local function character(c)
  c:WaitForChild("HumanoidRootPart",10);if not c.Parent then return end
  player:SetAttribute("TitanUntil",0);player:SetAttribute("SpeedUntil",0)
  ctx.Growth.Scale(ctx,player);ctx.Purchases.Apply(ctx,player)
  task.defer(function() if c.Parent then c:PivotTo(CFrame.new(0,8,0)) end end)
 end
 player.CharacterAdded:Connect(character);if player.Character then task.spawn(character,player.Character) end
 ctx.Round.Daily(p);send(player);ctx.Notify(player,"Welcome! +1 Size every second. Eat burgers, then ROLL POWER!")
end
Players.PlayerAdded:Connect(function(p) task.spawn(loaded,p) end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(loaded,p) end
Players.PlayerRemoving:Connect(function(p)
 ctx.Data.Remove(p);rate[p]=nil;busy[p]=nil;ctx.Powers.Cooldowns[p]=nil;ctx.Round.Challenge[p]=nil;ctx.Round.NextClaim[p]=nil;ctx.Boss.Participants[p]=nil
end)
action.OnServerEvent:Connect(function(player,kind,arg)
 if type(kind)~="string" or (arg~=nil and (type(arg)~="string" or #arg>60)) then return end
 local now=os.clock();if now-(rate[player] or 0)<.18 or busy[player] then return end;rate[player]=now
 local p=ctx.Data.Profiles[player];if not p then return end
 local ok,message=false,"Unknown action"
 if kind=="roll" then ok,message=ctx.Powers.Roll(ctx,player)
 elseif kind=="equip" then ok,message=ctx.Powers.Equip(ctx,player,arg)
 elseif kind=="activate" then ok,message=ctx.Powers.Activate(ctx,player)
 elseif kind=="rebirth" then ok,message=ctx.Rebirth.Try(ctx,player)
 elseif kind=="cosmetic" then ok,message=ctx.Purchases.Try(ctx,player,arg)
 elseif kind=="claim" then ok,message=ctx.Round.Claim(ctx,player,arg)
 elseif kind=="challenge" then ok,message=ctx.Round.Start(ctx,player)
 elseif kind=="zone" then
  local index=tonumber(arg)
  if index and index%1==0 and index>=1 and index<=#ctx.Config.Zones then
   local z=ctx.Config.Zones[index]
   if index<=p.Zone then ok=true
   elseif index==p.Zone+1 and p.Size>=z.Size and p.Coins>=z.Coins then p.Coins-=z.Coins;p.Zone=index;ok=true end
   if ok and player.Character then player.Character:PivotTo(CFrame.new((index-1)*160,8,0));message=z.Name
   else message="Unlock in order • need "..z.Size.." Size + "..z.Coins.." Coins" end
  end
 elseif kind=="sync" then send(player);return
 end
 ctx.Notify(player,message);send(player)
end)
for hit,info in pairs(ctx.World.Pickups) do
 hit.Touched:Connect(function(touch)
  local c=touch:FindFirstAncestorOfClass("Model");local player=c and Players:GetPlayerFromCharacter(c);local p=player and ctx.Data.Profiles[player]
  local r=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid")
  if not p or not r or not h or h.Health<=0 or p.Zone<info.Zone or (r.Position-hit.Position).Magnitude>14 or os.clock()<info.Ready then return end
  info.Ready=os.clock()+8
  for _,v in ipairs(info.Model:GetChildren()) do if v:IsA("BasePart") and v~=hit then v.Transparency=1 end end
  ctx.Growth.Add(ctx,player,info.Bonus,true);ctx.FX:FireClient(player,"food",{Position=hit.Position,Amount=info.Bonus*ctx.Config.Multiplier(p.Rebirths)});send(player)
  task.delay(8,function() if info.Model.Parent then for _,v in ipairs(info.Model:GetChildren()) do if v:IsA("BasePart") and v~=hit then v.Transparency=0 end end end end)
 end)
end
ctx.Boss.Next=os.clock()+15
task.spawn(function()
 while task.wait(1) do
  ctx.Round.Tick(ctx)
  if ctx.Boss.Active then
   if ctx.Boss.Health<=0 then ctx.Boss.Finish(ctx,true)
   elseif os.clock()>ctx.Boss.End then ctx.Boss.Finish(ctx,false)
   elseif not ctx.Boss.LastAttack or os.clock()-ctx.Boss.LastAttack>5 then ctx.Boss.LastAttack=os.clock();ctx.Boss.Attack(ctx) end
  elseif os.clock()>ctx.Boss.Next then ctx.Boss.Spawn(ctx) end
  for p in pairs(ctx.Data.Profiles) do if p.Parent then send(p) end end
 end
end)
task.spawn(function() while task.wait(55) do for p in pairs(ctx.Data.Profiles) do task.spawn(ctx.Data.Save,p,false) end end end)
game:BindToClose(function()
 local remaining=0;for p in pairs(ctx.Data.Profiles) do remaining+=1;task.spawn(function() ctx.Data.Save(p,true);remaining-=1 end) end
 local limit=os.clock()+25;while remaining>0 and os.clock()<limit do task.wait(.1) end
end)
-- Exposes a test surface only to Studio, never to clients or public servers.
if game:GetService("RunService"):IsStudio() then _G.FatChaosTest=ctx end
print("FAT CHAOS READY • 5 zones • 19 powers • server authoritative")
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="PowerService";s.Source=[====[
local S={Cooldowns={},DummyRewards={}}
function S.Roll(ctx,player)
 local p=ctx.Data.Profiles[player]
 if p.Coins<ctx.Config.RollCost then return false,"Roll costs 15 earned Coins • eat 5 burgers!" end
 p.Coins-=ctx.Config.RollCost;local power=ctx.Config.Roll(ctx.RNG);local duplicate=p.Powers[power.Id]==true
 p.Powers[power.Id]=true;p.Equipped=power.Id;p.Rolls+=1
 if duplicate then ctx.Coins.Add(ctx,player,5,3) end
 ctx.FX:FireClient(player,"reveal",{Id=power.Id,Duplicate=duplicate})
 return true,duplicate and "Duplicate • +5 Coins refunded" or "New power discovered!"
end
function S.Equip(ctx,player,id)
 local p=ctx.Data.Profiles[player]
 if not p.Powers[id] or not ctx.Config.Power(id) then return false,"Power not unlocked" end
 p.Equipped=id;return true,"Power equipped"
end
function S.Activate(ctx,player)
 local p=ctx.Data.Profiles[player];local power=ctx.Config.Power(p.Equipped)
 local c=player.Character;local r=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid")
 if not power or not r or not h or h.Health<=0 then return false,"Respawn first" end
 if power.Kind=="gravity" and not ctx.World.InArena(r.Position) then return false,"Gravity Flip works inside the Cosmic Arena" end
 local now=os.clock();local ready=S.Cooldowns[player] or 0
 if now<ready then return false,"Cooling down • "..math.ceil(ready-now).."s" end
 S.Cooldowns[player]=now+power.Cooldown
 local kind=power.Kind;local pos=r.Position;local dir=r.CFrame.LookVector
 local color=ctx.Config.Rarities[power.Rarity].Color
 ctx.FX:FireAllClients("power",{UserId=player.UserId,Position=pos,Direction=dir,Kind=kind,Color=color,Radius=power.Radius or 12})
 if kind=="jump" then r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X,100,r.AssemblyLinearVelocity.Z)
 elseif kind=="dash" then r.AssemblyLinearVelocity=dir*85+Vector3.new(0,12,0)
 elseif kind=="speed" then player:SetAttribute("SpeedUntil",now+6);h.WalkSpeed=30
 elseif kind=="gravity" then
  local a=Instance.new("Attachment");a.Parent=r;local f=Instance.new("VectorForce");f.Attachment0=a;f.RelativeTo=Enum.ActuatorRelativeTo.World;f.Force=Vector3.new(0,r.AssemblyMass*workspace.Gravity*1.15,0);f.Parent=r
  game:GetService("Debris"):AddItem(f,.8);game:GetService("Debris"):AddItem(a,.8)
 elseif kind=="titan" then player:SetAttribute("TitanUntil",now+8);ctx.Growth.Scale(ctx,player)
 elseif kind=="growth" then player:SetAttribute("GrowthUntil",now+12)
 elseif kind=="time" then ctx.Boss.SlowUntil=now+6
 elseif kind=="slam" then
  r.AssemblyLinearVelocity=Vector3.new(0,80,0)
  task.delay(.7,function() if r.Parent then r.AssemblyLinearVelocity=Vector3.new(0,-105,0) end end)
 end
 local function strike()
  if not r.Parent then return end
  local at=r.Position
  if power.Damage then
   ctx.Boss.Hit(ctx,player,power.Damage,at,power.Radius,kind=="wave" and dir or nil)
   for index,dummy in ipairs(ctx.World.Dummies) do
    if (dummy.Position-at).Magnitude<(power.Radius or 18) then
     local key=player.UserId..":"..index;local previous=S.DummyRewards[key] or -100
     if now-previous>5 then S.DummyRewards[key]=now;ctx.Coins.Add(ctx,player,5,5);ctx.Notify(player,"TRAINING HIT • +5 Coins") end
     ctx.FX:FireAllClients("dummy",{Position=dummy.Position,Color=color,Radius=5})
    end
   end
  end
 end
 if kind=="slam" then task.delay(1,strike) else strike() end
 return true,power.Name.."!"
end
return S
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="PurchaseService";s.Source=[====[
local S={}
function S.Apply(ctx,player)
 local p=ctx.Data.Profiles[player];local c=player.Character;if not c or not p then return end
 local old=c:FindFirstChild("ChaosCosmetic");if old then old:Destroy() end
 local root=c:FindFirstChild("HumanoidRootPart");if not root then return end
 for _,item in ipairs(ctx.Config.Cosmetics) do if item.Id==p.EquippedCosmetic then
  local folder=Instance.new("Folder");folder.Name="ChaosCosmetic";folder.Parent=c
  if item.Kind=="Aura" then local h=Instance.new("Highlight");h.Adornee=c;h.FillColor=item.Color;h.FillTransparency=.72;h.OutlineColor=item.Color;h.Parent=folder
  elseif item.Kind=="Trail" then
   local a=Instance.new("Attachment");a.Position=Vector3.new(-1,0,0);a.Parent=root;local b=Instance.new("Attachment");b.Position=Vector3.new(1,0,0);b.Parent=root
   local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(item.Color);trail.Lifetime=.5;trail.Parent=folder
   folder.Destroying:Connect(function() a:Destroy();b:Destroy() end)
  elseif item.Kind=="Hat" then
   local head=c:FindFirstChild("Head");if head then
    for i,col in ipairs({Color3.fromRGB(223,145,55),Color3.fromRGB(92,57,35),Color3.fromRGB(90,220,80),item.Color}) do
     local part=Instance.new("Part");part.Name="BurgerCrown";part.Size=Vector3.new(2.3,.25,2.3)*c:GetScale();part.Color=col;part.Shape=Enum.PartType.Cylinder;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CFrame=head.CFrame*CFrame.new(0,(.7+i*.22)*c:GetScale(),0)*CFrame.Angles(0,0,math.pi/2);part.Parent=folder
     local weld=Instance.new("WeldConstraint");weld.Part0=head;weld.Part1=part;weld.Parent=part
    end
   end
  end
 end end
end
function S.Try(ctx,player,id)
 local p=ctx.Data.Profiles[player]
 for _,item in ipairs(ctx.Config.Cosmetics) do if item.Id==id then
  if not p.Cosmetics[id] then if p.Coins<item.Cost then return false,"Need "..item.Cost.." Coins" end;p.Coins-=item.Cost;p.Cosmetics[id]=true end
  p.EquippedCosmetic=id;S.Apply(ctx,player)
  if item.Kind=="Emote" then ctx.FX:FireAllClients("emote",{UserId=player.UserId}) end
  if item.Kind=="Lounge" and player.Character then player.Character:PivotTo(CFrame.new(0,8,76)) end
  return true,item.Name.." equipped"
 end end
 return false,"Unknown cosmetic"
end
return S
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="RebirthService";s.Source=[====[
local S={}
function S.Try(ctx,player)
 local p=ctx.Data.Profiles[player];local need=ctx.Config.RebirthCost(p.Rebirths)
 if p.Size<need then return false,"Rebirth requires "..need.." Size" end
 p.Size=0;p.Rebirths+=1;ctx.Coins.Add(ctx,player,100,50);ctx.Growth.Scale(ctx,player)
 return true,"REBIRTH! Permanent x"..ctx.Config.Multiplier(p.Rebirths).." growth"
end
return S
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="RoundService";s.Source=[====[
local R={Challenge={},NextClaim={}}
function R.Daily(p)
 local day=math.floor(os.time()/86400)
 if p.Daily.Day~=day then p.Daily={Day=day,Growth=0,Food=0,Boss=0,Claimed={}} end
end
function R.Claim(ctx,player,key)
 local p=ctx.Data.Profiles[player];R.Daily(p)
 local goals={growth={Field="Growth",Need=120,Reward=75},food={Field="Food",Need=20,Reward=60},boss={Field="Boss",Need=1,Reward=120}}
 local g=goals[key];if not g then return false,"Unknown daily challenge" end
 if p.Daily.Claimed[key] then return false,"Already claimed today" end
 if p.Daily[g.Field]<g.Need then return false,"Challenge in progress" end
 p.Daily.Claimed[key]=true;ctx.Coins.Add(ctx,player,g.Reward,25);return true,"DAILY COMPLETE • +"..g.Reward.." Coins"
end
function R.Start(ctx,player)
 local p=ctx.Data.Profiles[player];if p.Zone<2 then return false,"Unlock Training Grounds first" end
 local c=player.Character;if not c then return false,"Respawn first" end
 R.Challenge[player]={Started=os.clock(),Finished=false};c:PivotTo(CFrame.new(123,8,27));return true,"TRAINING SPRINT • Reach the highest platform in 35 seconds!"
end
function R.Tick(ctx)
 for player,p in pairs(ctx.Data.Profiles) do
  R.Daily(p);ctx.Growth.Add(ctx,player,1,false)
  local c=player.Character;local r=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid")
  if r and h and h.Health>0 then
   if r.Position.Y< -25 or ctx.World.ZoneAt(r.Position)>p.Zone then c:PivotTo(CFrame.new((p.Zone-1)*160,8,0)) end
   local run=R.Challenge[player]
   if run and not run.Finished then
    local elapsed=os.clock()-run.Started
    if elapsed>35 then R.Challenge[player]=nil;ctx.Notify(player,"Sprint ended • try again!")
    elseif (r.Position-Vector3.new(205,18,27)).Magnitude<11 then
     run.Finished=true
     if os.clock()>(R.NextClaim[player] or 0) then R.NextClaim[player]=os.clock()+60;ctx.Coins.Add(ctx,player,40,30);p.Achievements.sprint=true;p.BestSprint=math.max(p.BestSprint or 0,math.floor(350-elapsed*10));ctx.Notify(player,"SPRINT CLEAR • +40 Coins")
     else ctx.Notify(player,"Sprint cleared • reward refreshes in one minute") end
    end
   end
   if p.Zone==5 and (r.Position-Vector3.new(691,22,25)).Magnitude<18 and not p.Achievements.colossal then p.Achievements.colossal=true;ctx.Coins.Add(ctx,player,200,150);ctx.Notify(player,"COLOSSAL CLIMB • +200 Coins") end
  end
 end
end
return R
]====];s.Parent=targets.server end
do local s=Instance.new("ModuleScript");s.Name="WorldService";s.Source=[====[
local W={Pickups={},Dummies={}}
local function part(parent,name,size,pos,color,material)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function label(p,text)
 local b=Instance.new("BillboardGui");b.Name="Sign";b.Size=UDim2.fromOffset(310,90);b.StudsOffset=Vector3.new(0,p.Size.Y/2+3,0);b.MaxDistance=210;b.AlwaysOnTop=false;b.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(20,17,40);t.BackgroundTransparency=.12;t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Text=text;t.Parent=b;local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,12);c.Parent=t
end
function W.Burger(parent,pos,scale)
 local model=Instance.new("Model");model.Name="Burger";model.Parent=parent
 for i,spec in ipairs({{1,Color3.fromRGB(230,155,65)},{.45,Color3.fromRGB(89,48,30)},{.2,Color3.fromRGB(255,207,45)},{.25,Color3.fromRGB(96,219,73)},{1,Color3.fromRGB(245,174,83)}}) do
  local p=part(model,"Layer"..i,Vector3.new(spec[1]*scale,3*scale,3*scale),pos+Vector3.new(0,(i-1)*.55*scale,0),spec[2]);p.Shape=Enum.PartType.Cylinder;p.CFrame*=CFrame.Angles(0,0,math.pi/2)
 end
 return model
end
function W.Build(ctx)
 local root=Instance.new("Folder");root.Name="FatChaosWorld";root.Parent=workspace;W.Root=root
 local light=game:GetService("Lighting");light.ClockTime=14;light.Brightness=2;light.Ambient=Color3.fromRGB(150,145,190);light.OutdoorAmbient=Color3.fromRGB(170,165,200)
 local bloom=Instance.new("BloomEffect");bloom.Name="FatChaosBloom";bloom.Intensity=.3;bloom.Size=22;bloom.Threshold=1.2;bloom.Parent=light
 local spawn=Instance.new("SpawnLocation");spawn.Name="ChaosSpawn";spawn.Size=Vector3.new(14,1,14);spawn.Position=Vector3.new(0,2,0);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Color=Color3.fromRGB(255,213,75);spawn.Material=Enum.Material.Neon;spawn.Parent=root
 local welcome=part(root,"Welcome",Vector3.new(26,10,2),Vector3.new(0,10,-37),Color3.fromRGB(29,23,58));label(welcome,"+1 FAT EVERY SECOND\nEAT • ROLL • GROW • REBIRTH")
 local tutorial=part(root,"Tutorial",Vector3.new(12,5,1),Vector3.new(-24,5,-15),Color3.fromRGB(71,47,111));label(tutorial,"+1 SIZE / SECOND\nEat burgers • ROLL for 15 Coins\nQ / TAP to activate your power")
 for zone,z in ipairs(ctx.Config.Zones) do
  local x=(zone-1)*160
  local folder=Instance.new("Folder");folder.Name="Zone"..zone;folder.Parent=root
  part(folder,"Island",Vector3.new(145,4,135),Vector3.new(x,-2,0),z.Color)
  part(folder,"Walkway",Vector3.new(150,.2,17),Vector3.new(x,.15,0),Color3.fromRGB(245,235,218))
  for _,side in ipairs({-1,1}) do
   part(folder,"NeonBorder",Vector3.new(145,.5,.8),Vector3.new(x,.5,side*66),z.Color,Enum.Material.Neon)
   for i=1,5 do
    local px=x-60+i*21;local pz=side*50
    if zone==1 or zone==3 then
     local height=zone==3 and 18+i*5 or 10+i*2
     part(folder,"CandyBuilding",Vector3.new(12,height,12),Vector3.new(px,height/2,pz),i%2==0 and Color3.fromRGB(76,61,117) or Color3.fromRGB(255,224,151))
     W.Burger(folder,Vector3.new(px,height+1,pz),zone==3 and 3 or 1.3)
    else
     part(folder,"EnergyPillar",Vector3.new(4,15+zone*3,4),Vector3.new(px,7+zone*1.5,pz),Color3.fromRGB(50,40,88));part(folder,"PillarGlow",Vector3.new(4.3,1,4.3),Vector3.new(px,15+zone*3,pz),z.Color,Enum.Material.Neon)
    end
   end
  end
  local s=part(folder,"ZoneSign",Vector3.new(14,4,1),Vector3.new(x,4,-23),Color3.fromRGB(30,26,55));label(s,zone.." / "..z.Name)
  if zone>1 then
   part(folder,"Bridge",Vector3.new(20,2,22),Vector3.new(x-80,-1,0),Color3.fromRGB(70,56,105))
   local gate=part(folder,"Gate",Vector3.new(2,16,33),Vector3.new(x-72,8,0),z.Color,Enum.Material.Neon);gate.Transparency=.6;gate.CanCollide=false
   label(gate,z.Name.."\n"..z.Size.." Size + "..z.Coins.." Coins\nUse ZONES menu to unlock")
  end
  for i=1,16 do
   local px=x-55+((i*29)%110);local pz=-35+((i*23)%70)
   local food=W.Burger(folder,Vector3.new(px,1.3,pz),.6)
   local hit=part(food,"Pickup",Vector3.new(4,4,4),Vector3.new(px,2,pz),z.Color);hit.Transparency=1;hit.CanCollide=false
   W.Pickups[hit]={Model=food,Zone=zone,Ready=0,Bonus=zone*4+1}
  end
  if zone==2 then
   for i=1,5 do local pad=part(folder,"JumpPad"..i,Vector3.new(12,1,12),Vector3.new(x-45+i*18,i*3,27),z.Color,Enum.Material.Neon);if i==5 then pad:SetAttribute("ChallengeFinish",true) end end
   for i=1,3 do
    local d=part(folder,"TrainingDummy",Vector3.new(4,7,3),Vector3.new(x-35+i*18,3.5,-30),Color3.fromRGB(255,133,82));label(d,"TRAINING TARGET\nHit with any attack power");table.insert(W.Dummies,d)
   end
  elseif zone==5 then
   for i=1,6 do part(folder,"ColossalObstacle",Vector3.new(10,4+i*3,30),Vector3.new(x-60+i*18,2+i*1.5,25),z.Color) end
  end
  task.wait()
 end
 -- The arena is a separate arena-only damage region; all town zones are safe.
 local center=Vector3.new(480,0,175);W.ArenaCenter=center
 part(root,"ArenaBridge",Vector3.new(20,2,95),Vector3.new(480,-1,110),Color3.fromRGB(87,65,136))
 local floor=part(root,"CosmicArena",Vector3.new(5,125,125),center-Vector3.new(0,2.5,0),Color3.fromRGB(40,29,75));floor.Shape=Enum.PartType.Cylinder;floor.CFrame*=CFrame.Angles(0,0,math.pi/2)
 for i=1,20 do local a=i*math.pi/10;local p=center+Vector3.new(math.cos(a)*61,3,math.sin(a)*61);part(root,"ArenaRim",Vector3.new(5,6,5),p,Color3.fromRGB(168,96,255),Enum.Material.Neon) end
 for i=1,4 do local p=part(root,"SpectatorSeat",Vector3.new(18,3,9),center+Vector3.new(-45+i*18,5,78),Color3.fromRGB(255,184,77));label(p,"SPECTATOR DECK • SAFE") end
 for i=1,7 do local p=part(root,"ArenaProp",Vector3.new(5,5,5),center+Vector3.new(-42+i*11,2.5,25),Color3.fromRGB(255,167,65));p:SetAttribute("GlitchProp",true) end
 part(root,"Lounge",Vector3.new(40,3,24),Vector3.new(0,1,76),Color3.fromRGB(255,205,90));local l=part(root,"LoungeSign",Vector3.new(6,3,1),Vector3.new(0,7,85),Color3.fromRGB(65,42,91));label(l,"CHILL LOUNGE\n250 earned Coins • cosmetic only")
end
function W.ZoneAt(pos)
 if pos.Z>95 then return 4 end
 return math.clamp(math.floor((pos.X+80)/160)+1,1,5)
end
function W.InArena(pos) local d=pos-W.ArenaCenter;return Vector2.new(d.X,d.Z).Magnitude<58 and math.abs(d.Y)<100 end
return W
]====];s.Parent=targets.server end
do local s=Instance.new("LocalScript");s.Name="UIController";s.Source=[====[
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
]====];s.Parent=targets.client end
return "INSTALLED: 5 zones, 19 powers, server services and HUD"

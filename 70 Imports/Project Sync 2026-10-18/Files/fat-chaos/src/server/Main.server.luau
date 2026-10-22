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

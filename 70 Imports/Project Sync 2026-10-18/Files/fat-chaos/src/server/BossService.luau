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

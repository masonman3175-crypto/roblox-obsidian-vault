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

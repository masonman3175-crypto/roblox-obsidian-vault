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

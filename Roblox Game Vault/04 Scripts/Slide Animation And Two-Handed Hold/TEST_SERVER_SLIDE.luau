local p=game.Players:GetPlayers()[1]
local c=p.Character;local h=c.Humanoid;local r=c.HumanoidRootPart
local ctrl=game.ServerScriptService.GameplayMovement.MovementControl
local owner=r:GetNetworkOwner();r:SetNetworkOwner(nil)
task.delay(4,function()if r.Parent then r:SetNetworkOwner(owner)end end)
c:PivotTo(CFrame.new(0,4,25));r.AssemblyLinearVelocity=Vector3.zero;task.wait(.3)
local sprint
for i=1,8 do ctrl:Invoke(p,"Sprint",true);h:MoveTo(Vector3.new(0,4,-25));task.wait(.1)
 if ctrl:Invoke(p,"State").Mode=="Sprinting" then sprint=true;break end end
assert(sprint,"Did not sprint")
local v=r.AssemblyLinearVelocity*Vector3.new(1,0,1)
ctrl:Invoke(p,"Sprint",true)
local accepted,why=ctrl:Invoke(p,"Slide",v.Unit);assert(accepted,why)
local before=r.Position;task.wait(.45)
local mid=ctrl:Invoke(p,"State");local distance=(r.Position-before).Magnitude
task.wait(.9);ctrl:Invoke(p,"Sprint",false);h:MoveTo(r.Position);r:SetNetworkOwner(owner)
return game.HttpService:JSONEncode({Mid=mid,Distance=distance,Recovered=ctrl:Invoke(p,"State"),ConstraintsLeft=r:FindFirstChild("GameplaySlideVelocity")~=nil})

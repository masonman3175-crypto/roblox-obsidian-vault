local p=game.Players:GetPlayers()[1]
game.ServerScriptService.LobbySystem.Control:Invoke(p,"Return")
local char=p.Character;local h=char.Humanoid;local root=char.HumanoidRootPart
local control=game.ServerScriptService.GameplayMovement.MovementControl
local owner=root:GetNetworkOwner();root:SetNetworkOwner(nil)
task.delay(3,function() if root.Parent then root:SetNetworkOwner(owner) end end)
char:PivotTo(CFrame.new(1000,4.5,16));root.AssemblyLinearVelocity=Vector3.zero;task.wait(.3)
local sprint
for i=1,8 do
    control:Invoke(p,"Sprint",true)
    h:MoveTo(Vector3.new(1000,4,-18))
    task.wait(.1)
    local state=control:Invoke(p,"State")
    if state.Mode=="Sprinting" and state.WalkSpeed==24 then sprint=state;break end
end
assert(sprint,"No real sprint sample observed")
local v=root.AssemblyLinearVelocity*Vector3.new(1,0,1)
control:Invoke(p,"Sprint",true)
assert(control:Invoke(p,"Slide",v.Unit))
task.wait(.08)
local slide=control:Invoke(p,"State");assert(slide.Sliding)
task.wait(1)
control:Invoke(p,"Sprint",false)
local after=control:Invoke(p,"State")
root:SetNetworkOwner(owner)
assert(not after.Sliding and math.abs(after.Hip-after.BaseHip)<.001)
return game.HttpService:JSONEncode({result="CONTROLLED LOBBY MOVEMENT PASS",speed=sprint.WalkSpeed,slideHip=slide.Hip,standingHip=after.Hip,staminaUsed=100-slide.Stamina})

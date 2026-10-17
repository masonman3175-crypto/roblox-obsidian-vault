local p=game.Players.LocalPlayer;local c=p.Character;c:PivotTo(CFrame.new(1000,4,22))
task.wait(.4)
local bridge=p.PlayerScripts.MovementControl;local h=c.Humanoid;local r=c.HumanoidRootPart
bridge:Invoke("Sprint",true)
game.RunService:BindToRenderStep("PoseQAMove",Enum.RenderPriority.Last.Value+30,function()h:Move(Vector3.new(0,0,-1),false)end)
task.wait(.65)
local start=r.Position;assert(bridge:Invoke("Slide"),"Client slide not sent")
local rows={}
for i=1,8 do task.wait(.1);local state=bridge:Invoke("State")
 table.insert(rows,{Time=i*.1,Mode=state.Mode,Slide=state.Pose.Slide,Hip=h.HipHeight,Distance=(r.Position-start).Magnitude,Reason=p:GetAttribute("SlideEndReason"),Speed=(r.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude})
end
game.RunService:UnbindFromRenderStep("PoseQAMove");bridge:Invoke("Sprint",false);h:Move(Vector3.zero)
task.wait(.5)
assert(rows[3].Mode=="Sliding" and rows[6].Mode=="Sliding","Slide ended prematurely")
assert(rows[7].Distance>15,"No real travel")
assert(bridge:Invoke("State").Pose.Slide<.01,"Pose stuck")
return game.HttpService:JSONEncode({Rows=rows,Recovered=bridge:Invoke("State").Pose.Slide})

local p=game.Players.LocalPlayer;local c=p.Character
local bridge=p.PlayerScripts.MovementControl
local out={}
for i=1,4 do
 assert(bridge:Invoke("Crouch",true));task.wait(.25)
 local state=bridge:Invoke("State")
 assert(state.Crouched and state.WalkSpeed==8 and state.Pose.Crouch>.9,"Crouch failed")
 local t=c:FindFirstChildOfClass("Tool");local r=t.WorldModel.Root
 local supportError=(r.CFrame:PointToObjectSpace(c.LeftHand.Position)-state.Pose.Support).Magnitude
 assert(supportError<.25,"Crouched support hand")
 table.insert(out,{Cycle=i,Crouch=state.Pose.Crouch,Hip=c.Humanoid.HipHeight,CameraY=c.Humanoid.CameraOffset.Y,SupportError=supportError})
 assert(bridge:Invoke("Crouch",false));task.wait(.35)
 assert(not bridge:Invoke("State").Crouched,"Crouch release")
end
local final=bridge:Invoke("State")
assert(final.Pose.Crouch<.01 and final.Pose.Slide<.01,"Stuck pose")
return game.HttpService:JSONEncode({Cycles=out,FinalHip=c.Humanoid.HipHeight,FinalPose=final.Pose})

local p=game.Players.LocalPlayer
local m=p.PlayerScripts.MovementControl
local hum=p.Character.Humanoid
local baseline=hum.HipHeight
assert(not p:GetAttribute("MovementCrouched"))
for i=1,6 do
 assert(m:Invoke("Crouch",true));task.wait(.35)
 assert(p:GetAttribute("MovementCrouched"),"Crouch rejected cycle "..i)
 assert(m:Invoke("Crouch",false));task.wait(.35)
 assert(not p:GetAttribute("MovementCrouched"),"Stand rejected cycle "..i)
end
task.wait(.5)
local s=m:Invoke("State")
assert(math.abs(hum.HipHeight-baseline)<1e-5,"Hip drift")
assert(math.abs(s.CameraOffsetY)<.02,"Camera did not recover")
assert(s.WalkSpeed==14)
return game.HttpService:JSONEncode({result="CYCLE PASS",cycles=6,hipBefore=baseline,hipAfter=hum.HipHeight,state=s})


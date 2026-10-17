local p=game.Players.LocalPlayer
local m=p.PlayerScripts.MovementControl
local hum=p.Character.Humanoid
local RunService=game.RunService
task.wait(.6)
m:Invoke("Crouch",true);task.wait(.5)
RunService:BindToRenderStep("QA_Movement",Enum.RenderPriority.Input.Value+1,function() hum:Move(Vector3.xAxis,false)end)
task.wait(.6)
local crouchSpeed=(p.Character.HumanoidRootPart.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude
assert(crouchSpeed>6 and crouchSpeed<9.5,"Crouch speed mismatch")
m:Invoke("Crouch",false);task.wait(.4);m:Invoke("Sprint",true);task.wait(.7)
local sprintSpeed=(p.Character.HumanoidRootPart.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude
assert(sprintSpeed>20,"Sprint regression")
assert(m:Invoke("Slide"));task.wait(.22)
local first=p:GetAttribute("SlideStartedAt")
local dip=m:Invoke("State").CameraOffsetY
assert(dip< -1.3,"Slide dip regression")
assert(m:Invoke("Slide"));task.wait(.85)
local nextStamp=p:GetAttribute("SlideStartedAt")
assert(nextStamp~=first,"Slide chain regression")
task.wait(.9)
RunService:UnbindFromRenderStep("QA_Movement");hum:Move(Vector3.zero,false)
m:Invoke("Sprint",false);m:Invoke("CancelSlide")
task.wait(.7)
local final=m:Invoke("State")
assert(not final.Crouched and math.abs(final.CameraOffsetY)<.02)
assert(math.abs(hum.HipHeight-1.9980254)<.03)
return game.HttpService:JSONEncode({result="MOVEMENT PASS",crouchSpeed=crouchSpeed,sprintSpeed=sprintSpeed,slideOffset=dip,chained=true,final=final})


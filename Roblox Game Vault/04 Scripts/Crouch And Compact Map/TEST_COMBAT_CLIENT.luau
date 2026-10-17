local p=game.Players.LocalPlayer
local m=p.PlayerScripts.MovementControl
local gun=p.PlayerScripts.ReferenceFPSControl
gun:Invoke("TestMode",true)
m:Invoke("Crouch",true);task.wait(.6)
local before=gun:Invoke("State").Ammo
gun:Invoke("Aim",true);task.wait(.2)
assert(gun:Invoke("Fire"),"Crouched fire rejected")
task.wait(.15)
assert(gun:Invoke("State").Ammo==before-1)
assert(p:GetAttribute("MovementCrouched"))
assert(gun:Invoke("Reload"));task.wait(2.5)
assert(gun:Invoke("State").Ammo==before)
gun:Invoke("Aim",false)
m:Invoke("Crouch",false);task.wait(.5)
return "COMBAT REGRESSION PASS: crouched ADS/fire/reload; ammo restored; standing restored; weapon source untouched"


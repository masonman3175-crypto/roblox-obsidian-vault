local p=game.Players.LocalPlayer;local ctrl=p.PlayerScripts.ReferenceFPSControl
ctrl:Invoke("TestMode",true)
local before=ctrl:Invoke("State");ctrl:Invoke("Fire");task.wait(.2)
local after=ctrl:Invoke("State");assert(after.Ammo==before.Ammo-1,"Fire regression")
ctrl:Invoke("Reload");task.wait(3.5)
local reloaded=ctrl:Invoke("State");ctrl:Invoke("TestMode",false)
assert(reloaded.Ammo==30 and not reloaded.Reloading,"Reload regression")
return game.HttpService:JSONEncode({Before=before.Ammo,After=after.Ammo,Reloaded=reloaded.Ammo,Pose=p.PlayerScripts.MovementControl:Invoke("State").Pose.Weapon})

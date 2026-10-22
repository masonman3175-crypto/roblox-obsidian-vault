-- Run in Studio Edit mode. Removes only this build's named roots.
assert(not game:GetService("RunService"):IsRunning(),"Stop play before rollback")
for _,entry in ipairs({{game:GetService("ReplicatedStorage"),"FatChaos"},{game:GetService("ServerScriptService"),"FatChaosServer"},{game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"),"UIController"},{workspace,"FatChaosWorld"},{game:GetService("Lighting"),"FatChaosBloom"}}) do local v=entry[1]:FindFirstChild(entry[2]);if v then v:Destroy() end end
local l=game:GetService("Lighting");l.ClockTime=14.5;l.Brightness=3;l.Ambient=Color3.fromRGB(70,70,70);l.OutdoorAmbient=Color3.fromRGB(70,70,70)
return "ROLLBACK PASS: original baseplate and spawn retained; Fat Chaos roots removed"

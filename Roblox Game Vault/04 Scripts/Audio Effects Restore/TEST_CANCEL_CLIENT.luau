local p=game.Players.LocalPlayer
local control=p.PlayerScripts.ReferenceFPSControl
local audio=p.PlayerScripts.AudioPresentationControl
local hum=p.Character:FindFirstChildOfClass("Humanoid")
local function equip(id)
 for _,parent in {p.Character,p.Backpack} do for _,t in parent:GetChildren() do if t:IsA("Tool") and t:GetAttribute("ReferenceWeaponId")==id then hum:EquipTool(t);return end end end
 error("missing weapon")
end
equip("W2");task.wait(.7);assert(control:Invoke("Fire"));assert(control:Invoke("Reload"));task.wait(.2)
assert(audio:Invoke("Stats").ReloadActive)
local bolts=audio:Invoke("Stats").Counts.ReloadBolt
equip("W3");task.wait(.4)
assert(not audio:Invoke("Stats").ReloadActive)
task.wait(2)
assert(audio:Invoke("Stats").Counts.ReloadBolt==bolts,"Stale reload bolt sound")
return "CANCEL PASS: switching weapons stopped reload audio and canceled delayed bolt cue"

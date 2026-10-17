local p=game.Players.LocalPlayer
local control=assert(p.PlayerScripts:FindFirstChild("ReferenceFPSControl"))
local audio=assert(p.PlayerScripts:FindFirstChild("AudioPresentationControl"))
control:Invoke("TestMode",true)
local hum=assert(p.Character:FindFirstChildOfClass("Humanoid"))
local results={}
for _,id in {"W1","W2","W3","W4","W5"} do
 local tool
 for _,parent in {p.Character,p.Backpack} do for _,v in parent:GetChildren() do if v:IsA("Tool") and v:GetAttribute("ReferenceWeaponId")==id then tool=v end end end
 assert(tool,"Missing tool "..id)
 hum:EquipTool(tool)
 task.wait(.8)
 local before=audio:Invoke("Stats").Counts["Shot_"..id] or 0
 local fired=control:Invoke("Fire")
 assert(fired,"Fire rejected "..id)
 task.wait(.15)
 local after=audio:Invoke("Stats")
 assert((after.Counts["Shot_"..id] or 0)==before+1,"Missing/duplicate audio "..id.." "..game.HttpService:JSONEncode(after.Counts))
 local reloaded=control:Invoke("Reload")
 assert(reloaded,"Reload rejected "..id)
 task.wait(.1)
 assert(audio:Invoke("Stats").ReloadActive,"Reload audio absent "..id)
 local spec=require(game.ReplicatedStorage.ReferenceWeapons.WeaponConfig).Guns[id]
 task.wait(spec.ReloadTime+.15)
 assert(not audio:Invoke("Stats").ReloadActive,"Reload audio not cleaned "..id)
 control:Invoke("Aim",true);task.wait(.1);control:Invoke("Aim",false)
 local state=control:Invoke("State")
 assert(state.Ammo==spec.MagazineSize,"Reload ammo changed")
 table.insert(results,{weapon=id,shotAudio=true,reloadAudio=true,ammo=state.Ammo,reserve=state.Reserve,stats=audio:Invoke("Stats").Counts})
end
return game.HttpService:JSONEncode({results=results,audio=audio:Invoke("Stats")})

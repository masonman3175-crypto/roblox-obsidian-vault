local p=game.Players.LocalPlayer
assert(p:GetAttribute("QueuedQueueId")=="" and p:GetAttribute("QueuedMode")=="")
task.wait(.3);assert(p:GetAttribute("QueuedQueueId")=="")
p.Character:PivotTo(CFrame.new(937,4,9));task.wait(.5)
assert(p:GetAttribute("QueuedQueueId")=="Solos_2")
task.wait(15.2)
assert(p:GetAttribute("CoopQueueId")=="Solos_2" and p:GetAttribute("LobbyPhase")=="Deployed")
local camera=p.PlayerScripts.LobbyPresentationControl:Invoke("Stats")
assert(camera.ThirdPerson and camera.Camera=="Classic" and not camera.ViewmodelVisible)
local visible=0;for _,part in p.Character:GetDescendants() do if part:IsA("BasePart") and part.LocalTransparencyModifier==0 then visible+=1 end end
assert(visible>10,"Third-person body invisible")
local fps=p.PlayerScripts.ReferenceFPSControl local audio=p.PlayerScripts.AudioPresentationControl
fps:Invoke("TestMode",true)
task.wait(.4)
local shots=audio:Invoke("Stats").Counts.Shot_W1 or 0
assert(fps:Invoke("Fire"));task.wait(.15)
assert((audio:Invoke("Stats").Counts.Shot_W1 or 0)==shots+1)
fps:Invoke("TestMode",false)
assert(not p.PlayerGui.SurvivorLobbyUI:FindFirstChild("Status"))
return game.HttpService:JSONEncode({result="LIVE PRESENTATION PASS: actual leave, second circle deploy, visible third-person avatar, no viewmodel overlay, one shot cue",visibleParts=visible,camera=camera})

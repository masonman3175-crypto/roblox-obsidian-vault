local p=game.Players.LocalPlayer
local req=game.ReplicatedStorage.LobbySystem.Request
req:FireServer({});req:FireServer("Return","bad");req:FireServer("Join","Squads")
p.Character:PivotTo(CFrame.new(937,4,-3));task.wait(.5)
assert(p:GetAttribute("QueuedMode")=="Solos")
assert(workspace.SurvivorLobby.Queues.Solos:GetAttribute("DepartureAt")>0)
p.Character:PivotTo(CFrame.new(1000,4,20));task.wait(.5)
assert(p:GetAttribute("QueuedMode")=="" and workspace.SurvivorLobby.Queues.Solos:GetAttribute("DepartureAt")==0)
p.Character:PivotTo(CFrame.new(979,4,-3));task.wait(.5)
assert(p:GetAttribute("QueuedMode")=="Duos" and workspace.SurvivorLobby.Queues.Duos:GetAttribute("DepartureAt")==0)
return "CANCEL/WAIT PASS: Solo countdown cancels on step-out; Duos waits for 2; forged Join sent for rejection test"

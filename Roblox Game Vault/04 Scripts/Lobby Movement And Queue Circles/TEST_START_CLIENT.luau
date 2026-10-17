local p=game.Players.LocalPlayer
local gui=p:WaitForChild("PlayerGui"):WaitForChild("SurvivorLobbyUI",15)
local char=p.Character or p.CharacterAdded:Wait();char:WaitForChild("HumanoidRootPart",15)
local camera=p.PlayerScripts:WaitForChild("LobbyPresentationControl",15)
task.wait(.5)
assert(not gui:FindFirstChild("Status"),"Top title banner still exists")
assert(#workspace.SurvivorLobby.Queues:GetChildren()==8)
assert(camera:Invoke("Stats").ThirdPerson and p.CameraMode==Enum.CameraMode.Classic)
local cfg=require(game.ReplicatedStorage.LobbySystem.Config)
for _,mode in cfg.Modes do local n=0 for _,q in cfg.Queues do if q.Mode==mode.Id then n+=1 end end assert(n==2) end
return game.HttpService:JSONEncode({result="START PASS",queues=8,eachMode=2,topBanner=false,camera=camera:Invoke("Stats"),team=p.Team.Name})

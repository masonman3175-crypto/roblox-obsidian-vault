local p=game.Players.LocalPlayer
local gui=p:WaitForChild("PlayerGui"):WaitForChild("SurvivorLobbyUI",15)
local char=p.Character or p.CharacterAdded:Wait()
char:WaitForChild("HumanoidRootPart",15);task.wait(1)
assert(p:GetAttribute("InLobby") and p.Team.Name=="Survivors" and not p.Neutral)
assert(not p.PlayerGui:FindFirstChild("MainMenuUI"))
assert(not game.ReplicatedStorage:FindFirstChild("MainMenu"))
assert(not char:FindFirstChildOfClass("Tool") and #p.Backpack:GetChildren()==0)
assert(not game.SoundService:FindFirstChild("BackgroundMusic"))
return "LOBBY START PASS: no menu/locker; Survivors; shared lobby arrival; no weapons; music absent"

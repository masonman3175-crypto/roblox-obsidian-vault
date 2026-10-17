local p=game.Players.LocalPlayer
local menu=p:WaitForChild("PlayerGui"):WaitForChild("MainMenuUI",15)
assert(menu and not workspace:FindFirstChild("SurvivorLobby"))
return game.HttpService:JSONEncode({result="BASELINE PASS: old Play/locker menu active; no lobby queues",menu=menu.Name,teams=#game.Teams:GetTeams()})

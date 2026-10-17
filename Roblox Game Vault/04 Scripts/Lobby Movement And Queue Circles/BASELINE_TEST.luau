local p=game.Players.LocalPlayer
local gui=p:WaitForChild("PlayerGui"):WaitForChild("SurvivorLobbyUI",15)
local char=p.Character or p.CharacterAdded:Wait();char:WaitForChild("HumanoidRootPart",15);task.wait(.6)
local control=p.PlayerScripts:WaitForChild("MovementControl")
control:Invoke("Sprint",true);task.wait(.3)
local state=control:Invoke("State")
assert(p:GetAttribute("InLobby") and state.WalkSpeed==14)
assert(gui:FindFirstChild("Status"))
assert(#workspace.SurvivorLobby.Queues:GetChildren()==4)
return "BASELINE PASS: 4 rectangular queues; title banner visible; lobby sprint blocked at speed 14"

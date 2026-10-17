local p=game.Players.LocalPlayer
local deployed=game.ReplicatedStorage.MainMenu.Request:InvokeServer("Deploy")
assert(deployed.Ok,deployed.Message)
local char=assert(p.Character);local root=assert(char:WaitForChild("HumanoidRootPart",10))
task.wait(.25)
local team=assert(p.Team)
local expected=team.Name=="Crips" and Vector3.new(-235,0,-135) or Vector3.new(245,0,135)
local actual=root.Position
assert((Vector3.new(actual.X,0,actual.Z)-expected).Magnitude<10,"Wrong corner "..tostring(actual))
assert(char:FindFirstChildOfClass("ForceField"),"No spawn protection")
task.wait(3.2)
assert(not char:FindFirstChildOfClass("ForceField"),"Protection did not expire")
return "PLAYTEST PASS: "..team.Name.." deployed via live PLAY remote at "..tostring(actual).."; correct opposite corner; initial protection=true; expired=true"


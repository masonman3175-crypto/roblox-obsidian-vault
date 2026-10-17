local fixture=Instance.new("Folder")
local backup=game.ServerStorage.LobbyMovementEightQueuesBackup_20261017:Clone();backup.Parent=fixture
local lobby=Instance.new("Folder");lobby.Name="Lobby";lobby.Parent=fixture
workspace.SurvivorLobby.Queues:Clone().Parent=lobby
local targets={}
for _,src in backup.Sources:GetChildren() do
 local m=Instance.new("ModuleScript");m.Name=src.Name;m.Source="return {}";m.Parent=fixture;targets[src:GetAttribute("Path")]=m
end
local module=Instance.new("ModuleScript");module.Source="return function(env)\n    local backup=env and env.Backup or game.ServerStorage.LobbyMovementEightQueuesBackup_20261017\n    local lobby=env and env.Lobby or workspace.SurvivorLobby\n    local function resolve(path)\n        if env then return assert(env.Targets[path],\"Missing fixture source \"..path) end\n        local o=game for n in path:gmatch(\"[^.]+\") do o=assert(o:FindFirstChild(n)) end return o\n    end\n    for _,src in backup.Sources:GetChildren() do assert(resolve(src:GetAttribute(\"Path\")):IsA(\"LuaSourceContainer\")) end\n    local queues=backup.Queues:Clone()\n    for _,src in backup.Sources:GetChildren() do resolve(src:GetAttribute(\"Path\")).Source=src.Value end\n    lobby.Queues:Destroy();queues.Parent=lobby\n    return true\nend\n";module.Parent=fixture
assert(require(module)({Backup=backup,Lobby=lobby,Targets=targets}))
for _,src in backup.Sources:GetChildren() do assert(targets[src:GetAttribute("Path")].Source==src.Value) end
assert(#lobby.Queues:GetChildren()==4 and lobby.Queues:FindFirstChild("Solos") and not lobby.Queues:FindFirstChild("Solos_1"))
assert(targets["ReplicatedStorage.LobbySystem.Client"].Source:find('Name="Status"',1,true))
assert(targets["ReplicatedStorage.LobbySystem.Config"].Source:find("Countdown = 8",1,true))
fixture:Destroy()
assert(#workspace.SurvivorLobby.Queues:GetChildren()==8)
return "ROLLBACK PASS: original 4 queues, banner, camera and lobby movement gates restored on isolated copies; live 8-circle update retained"

local fixture=Instance.new("Folder")
local function folder(name) local f=Instance.new("Folder");f.Name=name;f.Parent=fixture;return f end
local env={RS=folder("RS"),Server=folder("Server"),Starter=folder("Starter"),World=folder("World"),Teams=folder("Teams"),Spawns=folder("Spawns"),Players={CharacterAutoLoads=false}}
env.Backup=game.ServerStorage.ZombieLobbyBackup_20261017:Clone();env.Backup.Parent=fixture
local expectedClient=env.Backup.OriginalObjects.MainMenu.Client.Source
local expectedService=env.Backup.OriginalObjects.MainMenuSystem.Service.Source
local expectedAudio=env.Backup.AudioClientSource.Value
local audio=Instance.new("Folder");audio.Name="AudioPresentation";audio.Parent=env.RS
local client=game.ReplicatedStorage.AudioPresentation.Client:Clone();client.Parent=audio
for _,pair in {{env.RS,"LobbySystem"},{env.Server,"LobbySystem"},{env.Starter,"SurvivorLobby"},{env.World,"SurvivorLobby"}} do local f=Instance.new("Folder");f.Name=pair[2];f.Parent=pair[1] end
local team=game.Teams.Survivors:Clone();team.Parent=env.Teams
for _,s in workspace.Map.Spawns:GetDescendants() do if s:IsA("SpawnLocation") then s:Clone().Parent=env.Spawns end end
local module=Instance.new("ModuleScript");module.Source="-- Run in Edit through Studio MCP; optional environment allows an isolated rollback fixture.\nreturn function(env)\n    env=env or {\n        RS=game.ReplicatedStorage, Server=game.ServerScriptService,\n        Starter=game.StarterPlayer.StarterPlayerScripts, World=workspace, Teams=game.Teams,\n        Spawns=workspace.Map.Spawns, Players=game.Players,\n        Backup=game.ServerStorage.ZombieLobbyBackup_20261017,\n    }\n    local b=assert(env.Backup)\n    local original=b.OriginalObjects\n    assert(original:FindFirstChild(\"MainMenu\") and original:FindFirstChild(\"MainMenuSystem\") and original:FindFirstChild(\"MainMenuClient\"),\"Original menu archive incomplete\")\n    assert(not env.RS:FindFirstChild(\"MainMenu\") and not env.Server:FindFirstChild(\"MainMenuSystem\") and not env.Starter:FindFirstChild(\"MainMenuClient\"),\"Restoration target changed; inspect before rollback\")\n    for _,pair in {{env.RS,\"LobbySystem\"},{env.Server,\"LobbySystem\"},{env.Starter,\"SurvivorLobby\"},{env.World,\"SurvivorLobby\"},{env.Teams,\"Survivors\"}} do local o=pair[1]:FindFirstChild(pair[2]);if o then o:Destroy() end end\n    original.MainMenu.Parent=env.RS\n    original.MainMenuSystem.Parent=env.Server\n    original.MainMenuClient.Parent=env.Starter\n    local focus=original:FindFirstChild(\"MainMenuStreamingFocus\");if focus then focus.Parent=env.World end\n    for _,t in b.Teams:GetChildren() do t.Parent=env.Teams end\n    for _,row in game.HttpService:JSONDecode(b.SpawnManifest.Value) do\n        local name=row.path:match(\"[^.]+$\")\n        local spawn=assert(env.Spawns:FindFirstChild(name,true),\"Original spawn missing: \"..name)\n        spawn.Enabled=row.enabled\n    end\n    env.RS.AudioPresentation.Client.Source=b.AudioClientSource.Value\n    env.Players.CharacterAutoLoads=b:GetAttribute(\"CharacterAutoLoads\")\n    return true\nend\n";module.Parent=fixture
assert(require(module)(env))
assert(env.RS.MainMenu.Client.Source==expectedClient)
assert(env.Server.MainMenuSystem.Service.Source==expectedService)
assert(env.RS.AudioPresentation.Client.Source==expectedAudio)
assert(env.Starter:FindFirstChild("MainMenuClient"))
assert(#env.Teams:GetChildren()==2)
for _,s in env.Spawns:GetChildren() do assert(s.Enabled) end
assert(not env.World:FindFirstChild("SurvivorLobby") and not env.RS:FindFirstChild("LobbySystem"))
fixture:Destroy()
assert(workspace:FindFirstChild("SurvivorLobby") and game.Teams:FindFirstChild("Survivors"))
assert(not game.ReplicatedStorage:FindFirstChild("MainMenu"))
return "ROLLBACK PASS: old menu/locker, two teams, original enabled spawns and audio source restored on isolated copy; live co-op lobby retained"

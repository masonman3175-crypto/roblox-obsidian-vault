-- Run in Edit through Studio MCP; optional environment allows an isolated rollback fixture.
return function(env)
    env=env or {
        RS=game.ReplicatedStorage, Server=game.ServerScriptService,
        Starter=game.StarterPlayer.StarterPlayerScripts, World=workspace, Teams=game.Teams,
        Spawns=workspace.Map.Spawns, Players=game.Players,
        Backup=game.ServerStorage.ZombieLobbyBackup_20261017,
    }
    local b=assert(env.Backup)
    local original=b.OriginalObjects
    assert(original:FindFirstChild("MainMenu") and original:FindFirstChild("MainMenuSystem") and original:FindFirstChild("MainMenuClient"),"Original menu archive incomplete")
    assert(not env.RS:FindFirstChild("MainMenu") and not env.Server:FindFirstChild("MainMenuSystem") and not env.Starter:FindFirstChild("MainMenuClient"),"Restoration target changed; inspect before rollback")
    for _,pair in {{env.RS,"LobbySystem"},{env.Server,"LobbySystem"},{env.Starter,"SurvivorLobby"},{env.World,"SurvivorLobby"},{env.Teams,"Survivors"}} do local o=pair[1]:FindFirstChild(pair[2]);if o then o:Destroy() end end
    original.MainMenu.Parent=env.RS
    original.MainMenuSystem.Parent=env.Server
    original.MainMenuClient.Parent=env.Starter
    local focus=original:FindFirstChild("MainMenuStreamingFocus");if focus then focus.Parent=env.World end
    for _,t in b.Teams:GetChildren() do t.Parent=env.Teams end
    for _,row in game.HttpService:JSONDecode(b.SpawnManifest.Value) do
        local name=row.path:match("[^.]+$")
        local spawn=assert(env.Spawns:FindFirstChild(name,true),"Original spawn missing: "..name)
        spawn.Enabled=row.enabled
    end
    env.RS.AudioPresentation.Client.Source=b.AudioClientSource.Value
    env.Players.CharacterAutoLoads=b:GetAttribute("CharacterAutoLoads")
    return true
end

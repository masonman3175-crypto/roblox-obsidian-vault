return function(env)
    local backup=env and env.Backup or game.ServerStorage.LobbyMovementEightQueuesBackup_20261017
    local lobby=env and env.Lobby or workspace.SurvivorLobby
    local function resolve(path)
        if env then return assert(env.Targets[path],"Missing fixture source "..path) end
        local o=game for n in path:gmatch("[^.]+") do o=assert(o:FindFirstChild(n)) end return o
    end
    for _,src in backup.Sources:GetChildren() do assert(resolve(src:GetAttribute("Path")):IsA("LuaSourceContainer")) end
    local queues=backup.Queues:Clone()
    for _,src in backup.Sources:GetChildren() do resolve(src:GetAttribute("Path")).Source=src.Value end
    lobby.Queues:Destroy();queues.Parent=lobby
    return true
end

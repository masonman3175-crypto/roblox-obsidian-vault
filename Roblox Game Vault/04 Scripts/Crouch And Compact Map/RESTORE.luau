-- Edit-time rollback. Accepts game or an isolated service-shaped root.
return function(root,backup)
    local ws=root:FindFirstChild("Workspace")
    local map=ws.Map
    local rs=root:FindFirstChild("ReplicatedStorage")
    local sound=root:FindFirstChild("SoundService")
    local function resolve(path)
        local v=root
        for _,name in string.split(path,".")do v=assert(v:FindFirstChild(name),path)end
        return v
    end
    for _,name in {"Ground","PerimeterBoundary","Spawns"}do
        local existing=map:FindFirstChild(name);if existing then existing:Destroy()end
        backup[name]:Clone().Parent=map
        task.wait()
    end
    ws.Baseplate.CFrame=backup.Baseplate.CFrame
    sound.BackgroundMusic.Volume=backup.MusicVolume.Value
    for _,saved in backup.Sources:GetChildren()do resolve(saved:GetAttribute("Path")).Source=saved.Value end
    local mini=rs.GameplayPresentation.MinimapWorld
    for _,p in mini:GetChildren()do if p.Name:match("^Boundary_")then p:Destroy()end end
    for _,p in backup.BoundaryProxies:GetChildren()do p:Clone().Parent=mini end
    return "ROLLBACK PASS: original movement/menu/audio sources, 25% music, full-size walls, ground and spawn transforms restored"
end


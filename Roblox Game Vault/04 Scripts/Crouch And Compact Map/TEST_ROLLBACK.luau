local backup=game.ServerStorage.CrouchCompactFloorBackup_20261017
local root=Instance.new("Folder");root.Name="CompactFloorRollbackFixture";root.Parent=game.ServerStorage
local function folder(parent,name)local v=Instance.new("Folder");v.Name=name;v.Parent=parent;return v end
local ws=folder(root,"Workspace");local rs=folder(root,"ReplicatedStorage");folder(root,"ServerScriptService");local sound=folder(root,"SoundService")
local map=folder(ws,"Map")
for _,name in {"Ground","PerimeterBoundary","Spawns"}do workspace.Map[name]:Clone().Parent=map;task.wait()end
workspace.Baseplate:Clone().Parent=ws
game.SoundService.BackgroundMusic:Clone().Parent=sound
local function resolve(parent,path)
    local v=parent
    for _,name in string.split(path,".")do v=assert(v:FindFirstChild(name),path)end
    return v
end
for _,saved in backup.Sources:GetChildren()do
    local path=saved:GetAttribute("Path");local segments=string.split(path,".");local parent=root
    for i=1,#segments-1 do parent=parent:FindFirstChild(segments[i]) or folder(parent,segments[i])end
    local m=resolve(game,path):Clone();m.Parent=parent
end
local gameplay=rs:FindFirstChild("GameplayPresentation")or folder(rs,"GameplayPresentation")
local mini=Instance.new("Model");mini.Name="MinimapWorld";mini.Parent=gameplay
for _,p in game.ReplicatedStorage.GameplayPresentation.MinimapWorld:GetChildren()do if p.Name:match("^Boundary_")then p:Clone().Parent=mini end end
local function fingerprint(container)
    local values={}
    for _,p in container:GetDescendants()do
        local s=p.Name.."|"..p.ClassName
        if p:IsA("BasePart")then s=s.."|"..tostring(p.CFrame).."|"..tostring(p.Size).."|"..tostring(p.Color).."|"..p.Material.Name.."|"..tostring(p.Transparency).."|"..tostring(p.CanCollide).."|"..tostring(p.CanQuery)end
        table.insert(values,s)
    end
    table.sort(values);return table.concat(values,"\n")
end
local module=Instance.new("ModuleScript");module.Name="Restore";module.Source="-- Edit-time rollback. Accepts game or an isolated service-shaped root.\nreturn function(root,backup)\n    local ws=root:FindFirstChild(\"Workspace\")\n    local map=ws.Map\n    local rs=root:FindFirstChild(\"ReplicatedStorage\")\n    local sound=root:FindFirstChild(\"SoundService\")\n    local function resolve(path)\n        local v=root\n        for _,name in string.split(path,\".\")do v=assert(v:FindFirstChild(name),path)end\n        return v\n    end\n    for _,name in {\"Ground\",\"PerimeterBoundary\",\"Spawns\"}do\n        local existing=map:FindFirstChild(name);if existing then existing:Destroy()end\n        backup[name]:Clone().Parent=map\n        task.wait()\n    end\n    ws.Baseplate.CFrame=backup.Baseplate.CFrame\n    sound.BackgroundMusic.Volume=backup.MusicVolume.Value\n    for _,saved in backup.Sources:GetChildren()do resolve(saved:GetAttribute(\"Path\")).Source=saved.Value end\n    local mini=rs.GameplayPresentation.MinimapWorld\n    for _,p in mini:GetChildren()do if p.Name:match(\"^Boundary_\")then p:Destroy()end end\n    for _,p in backup.BoundaryProxies:GetChildren()do p:Clone().Parent=mini end\n    return \"ROLLBACK PASS: original movement/menu/audio sources, 25% music, full-size walls, ground and spawn transforms restored\"\nend\n";module.Parent=root
local ok,result=pcall(function()
    local message=require(module)(root,backup)
    for _,name in {"Ground","PerimeterBoundary","Spawns"}do assert(fingerprint(map[name])==fingerprint(backup[name]),name.." restore mismatch")end
    for _,saved in backup.Sources:GetChildren()do assert(resolve(root,saved:GetAttribute("Path")).Source==saved.Value,"Source mismatch")end
    assert(ws.Baseplate.CFrame==backup.Baseplate.CFrame)
    assert(sound.BackgroundMusic.Volume==.25)
    assert(#mini:GetChildren()==8)
    assert(math.abs(game.SoundService.BackgroundMusic.Volume-.05)<1e-6)
    assert(workspace.Map.PerimeterBoundary.WestSolid.Position.X==-240)
    assert(#workspace.Map.Ground.SidewalkSlabs:GetChildren()==500)
    return message.."; isolated copy restored; live compact/crouch/floor update retained at 5%"
end)
root:Destroy()
assert(ok,tostring(result))
return result


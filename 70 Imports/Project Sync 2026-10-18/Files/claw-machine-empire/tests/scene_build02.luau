-- Run in Studio Server during Play. Isolated non-rendered fixture; no player grants.
local storage=game:GetService("ServerStorage")
local key="CME_Build02_SceneFixture"
assert(not storage:FindFirstChild(key),"Fixture namespace occupied")
local Config=require(game.ReplicatedStorage.ClawEmpire.Shared.Config)
local World=require(game.ServerScriptService.ClawEmpire.World)
local fixture=World.build(storage,key,Vector3.zero)
local ok,result=pcall(function()
    local signatures={}; local tested=0
    for i,machine in ipairs(fixture.machines) do
        local signature={}
        -- Ignore colors, text, species, and semantic part names: compare physical geometry.
        for _,p in ipairs(machine.root:GetChildren()) do
            if p:IsA("Part") then
                local position=p.Position-machine.origin
                table.insert(signature,string.format("%s:%.2f,%.2f,%.2f:%.2f,%.2f,%.2f:%.1f,%.1f,%.1f",
                    p.Shape.Name,p.Size.X,p.Size.Y,p.Size.Z,position.X,position.Y,position.Z,
                    p.Orientation.X,p.Orientation.Y,p.Orientation.Z))
            end
        end
        table.sort(signature); local encoded=table.concat(signature,";")
        assert(not signatures[encoded],"Geometry-only duplicate: "..i); signatures[encoded]=true
        World.targets(fixture,i,{{x=0,z=0,species=Config.Machines[i].mascot}})
        World.aim(fixture,i,0.5,-0.25,10)
        assert((machine.claw:GetPivot().Position-(machine.origin+Vector3.new(0.5,10,-0.25))).Magnitude<0.001)
        assert(#machine.prizes:GetChildren()==1,"Target replacement failed")
        World.unlock(fixture,i)
        assert(machine.prompt.ActionText=="Play free")
        tested+=1
        if i%5==0 then task.wait() end
    end
    assert(tested==25)
    local tiles=0
    for _,p in ipairs(fixture.root.HandbuiltStudFloor:GetChildren()) do
        if p.Name=="StuddedTile" then assert(p.TopSurface==Enum.SurfaceType.Studs); tiles+=1 end
    end
    assert(tiles==96)
    return "SCENE_PASS cabinets=25 geometry_unique=25 target_claw_prompt_checks=25 studded_tiles=96 live_player_data=unchanged"
end)
assert(fixture.root.Parent==storage and fixture.root.Name==key)
fixture.root:Destroy()
assert(not storage:FindFirstChild(key))
assert(ok,result)
return result

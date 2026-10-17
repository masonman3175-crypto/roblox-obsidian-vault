local fixture=Instance.new("Folder");fixture.Name="AudioRollbackFixture"
local t={}
for _,n in {"RS","SP","SSS","Sound"} do t[n]=Instance.new("Folder");t[n].Name=n;t[n].Parent=fixture end
game.ReplicatedStorage.AudioPresentation:Clone().Parent=t.RS
local a=game.StarterPlayer.StarterPlayerScripts.AudioPresentation:Clone();a.Enabled=false;a.Parent=t.SP
local b=game.ServerScriptService.AudioPresentation:Clone();b.Enabled=false;b.Parent=t.SSS
for _,n in {"BackgroundMusic","GameAudioMusic","GameAudioEffects"} do game.SoundService[n]:Clone().Parent=t.Sound end
local restore=Instance.new("ModuleScript");restore.Name="Restore";restore.Source="-- Run in Edit after stopping Play. No combat, map, menu or movement source is overwritten.\n-- Targets may be real services or isolated service-shaped fixture folders.\nreturn function(targets)\n    local function remove(parent,name)\n        local item=parent:FindFirstChild(name)\n        if item then item:Destroy() end\n    end\n    remove(targets.RS,\"AudioPresentation\")\n    remove(targets.SP,\"AudioPresentation\")\n    remove(targets.SSS,\"AudioPresentation\")\n    remove(targets.Sound,\"BackgroundMusic\")\n    remove(targets.Sound,\"GameAudioMusic\")\n    remove(targets.Sound,\"GameAudioEffects\")\n    return \"ROLLBACK PASS: audio package, boots, music and mix groups removed; baseline gameplay sources retained\"\nend\n";restore.Parent=fixture
fixture.Parent=game.ServerStorage
local ok,result=pcall(function()
    local message=require(restore)(t)
    for _,v in t do assert(#v:GetChildren()==0,"Audio did not restore to absent baseline") end
    assert(game.ReplicatedStorage:FindFirstChild("AudioPresentation"))
    assert(game.SoundService.BackgroundMusic.Volume==.25)
    assert(workspace.Baseplate.Texture.Transparency==1)
    assert(not workspace.Map.Spawns.Spawn_West.Neutral)
    return message.."; isolated fixture restored; live audio remains installed at 0.25"
end)
fixture:Destroy()
assert(ok,tostring(result))
return result


local backup=assert(game.ServerStorage:FindFirstChild("AudioSfxRestoreBackup_20261017"))
local fixture=Instance.new("Folder");fixture.Name="AudioRestoreIsolatedTest"
local package=game.ReplicatedStorage.AudioPresentation:Clone();package.Parent=fixture
local mix=Instance.new("Folder");mix.Name="Mix";mix.Parent=fixture
local group=game.SoundService.GameAudioEffects:Clone();group.Parent=mix
local module=Instance.new("ModuleScript");module.Source="-- Invoke only through Studio MCP; defaults target the live game in Edit.\nreturn function(package, mixRoot, backup)\n    package=package or game.ReplicatedStorage.AudioPresentation\n    mixRoot=mixRoot or game.SoundService\n    backup=backup or assert(game.ServerStorage:FindFirstChild(\"AudioSfxRestoreBackup_20261017\"))\n    for _,n in {\"Client\",\"Config\"} do package[n].Source=backup[n].Source end\n    package.Assets:Destroy()\n    backup.Assets:Clone().Parent=package\n    for _,n in {\"BackgroundMusic\",\"GameAudioMusic\",\"GameAudioEffects\"} do\n        local existing=mixRoot:FindFirstChild(n);if existing then existing:Destroy() end\n        if backup:GetAttribute(\"Had_\"..n) then local copy=assert(backup:FindFirstChild(n)):Clone();copy.Parent=mixRoot end\n    end\n    return true\nend\n";module.Parent=fixture
assert(require(module)(package,mix,backup))
assert(package.Client.Source==backup.Client.Source)
assert(package.Config.Source==backup.Config.Source)
assert(#package.Assets:GetChildren()==#backup.Assets:GetChildren())
for _,s in backup.Assets:GetChildren() do local copy=assert(package.Assets:FindFirstChild(s.Name));assert(copy.SoundId==s.SoundId and copy.Volume==s.Volume) end
assert(not mix:FindFirstChild("BackgroundMusic") and mix:FindFirstChild("GameAudioMusic"))
assert(package.Client.Source:find('WaitForChild("BackgroundMusic",10)',1,true))
fixture:Destroy()
assert(#game.ReplicatedStorage.AudioPresentation.Assets:GetChildren()==12)
assert(not game.SoundService:FindFirstChild("BackgroundMusic") and not game.SoundService:FindFirstChild("GameAudioMusic"))
return "ROLLBACK PASS: original broken music dependency and 14 assets restored on isolated copy; live 12 effects/no music retained"

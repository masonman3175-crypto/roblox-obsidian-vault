local p=assert(game.ReplicatedStorage:FindFirstChild("AudioPresentation"))
local C=require(p.Config)
assert(C.MusicVolume==.25)
assert(p.Assets and #p.Assets:GetChildren()==14)
local sounds,scripts=0,0
for _,v in p.Assets:GetDescendants() do
    if v:IsA("Sound") then sounds+=1 end
    if v:IsA("LuaSourceContainer") then scripts+=1 end
end
assert(sounds==14 and scripts==0)
assert(game.StarterPlayer.StarterPlayerScripts.AudioPresentation:IsA("LocalScript"))
assert(game.ServerScriptService.AudioPresentation:IsA("Script"))
assert(p.Client and p.Server and p.Emit:IsA("RemoteEvent"))
assert(game.SoundService.BackgroundMusic.Volume==.25 and game.SoundService.BackgroundMusic.Looped)
assert(game.SoundService.GameAudioMusic.Volume==1 and game.SoundService.GameAudioEffects.Volume==1)
assert(game.SoundService.BackgroundMusic.SoundGroup==game.SoundService.GameAudioMusic)
return "MODIFIED PASS: 14 sound assets; no imported scripts; independent audio modules and validated remote; background Volume=0.25; mix groups=1"


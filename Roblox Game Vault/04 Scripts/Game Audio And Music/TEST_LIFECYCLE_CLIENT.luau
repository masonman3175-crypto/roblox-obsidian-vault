local p=game.Players.LocalPlayer
local audio=p.PlayerScripts.AudioPresentationControl
local before=audio:Invoke("Stats")
local defaults={}
for _,s in p.Character.HumanoidRootPart:GetChildren() do if s:IsA("Sound") then defaults[s.Name]=s.Volume end end
local stopped=audio:Invoke("Stop")
assert(not stopped.Started and stopped.Connections==0 and stopped.Voices==0)
assert(not p.PlayerGui:FindFirstChild("AudioPresentation"))
assert(not p.PlayerScripts:FindFirstChild("AudioPresentationControl"))
assert(not game.SoundService.BackgroundMusic.IsPlaying)
local restored={}
for _,s in p.Character.HumanoidRootPart:GetChildren() do if s:IsA("Sound") then restored[s.Name]=s.Volume end end
assert(restored.Running and restored.Running>0,"Native footstep sound not restored")
local boot=p.PlayerScripts:FindFirstChild("AudioPresentation")
boot.Enabled=false;boot.Enabled=true
local nextBridge=p.PlayerScripts:WaitForChild("AudioPresentationControl",10)
task.wait(.5)
local after=nextBridge:Invoke("Stats")
assert(after.Started and after.Connections<=before.Connections and after.MusicPlaying and after.MusicVolume==.25)
return game.HttpService:JSONEncode({result="LIFECYCLE PASS: stopped all custom voices/connections; native Running volume restored; restart has no duplicate connections",connectionsBefore=before.Connections,connectionsAfter=after.Connections,defaultsMuted=defaults,defaultsRestored=restored})

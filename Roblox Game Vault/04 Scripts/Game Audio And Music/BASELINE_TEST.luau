assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("AudioPresentation"))
assert(not game.SoundService:FindFirstChild("BackgroundMusic"))
return "BASELINE PASS: no general audio bootstrap or background music; W1 had legacy-only sound calls"


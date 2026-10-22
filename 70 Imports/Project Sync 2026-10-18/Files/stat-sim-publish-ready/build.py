from pathlib import Path
import hashlib
import shutil

ROOT = Path(__file__).resolve().parent
BASE = ROOT / "baseline" / "PunchFxController.luau"
OUT = ROOT / "modified" / "PunchFxController.luau"
source = BASE.read_text(encoding="utf-8")

def replace_once(old: str, new: str) -> None:
    global source
    if source.count(old) != 1:
        raise RuntimeError(f"expected one source anchor, got {source.count(old)}: {old[:65]}")
    source = source.replace(old, new)

replace_once('local TweenService = game:GetService("TweenService")', '''local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")''')
replace_once('local gui = nil', '''local gui = nil

-- Replace this with an uploaded, experience-permitted two-second voice clip ID.
-- Until then, every punch uses the licensed Creator Store cartoon hit below.
local MEME_CLIP_ASSET_ID = ""
local WHOOSH_ID = "rbxassetid://9120709477"
local HIT_ID = "rbxassetid://7468131335"
local BOING_ID = "rbxassetid://75314486373846"

local function playOneShot(assetId, volume, speed, maxSeconds)
    if assetId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = assetId
    sound.Volume = volume
    sound.PlaybackSpeed = speed
    sound.RollOffMaxDistance = 80
    sound.Parent = SoundService
    sound.Ended:Connect(function() sound:Destroy() end)
    sound:Play()
    task.delay(maxSeconds, function()
        if sound.Parent then sound:Stop(); sound:Destroy() end
    end)
end

local function impactAudio()
    playOneShot(if MEME_CLIP_ASSET_ID ~= "" then MEME_CLIP_ASSET_ID else HIT_ID, 0.75, 1, 2)
end''')
replace_once('''	-- PUNCH
	if joint then''', '''	-- PUNCH
	playOneShot(WHOOSH_ID, 0.32, 1.15, 1)
	if joint then''')
replace_once('''	-- impact freeze frame
	flash()''', '''	-- impact freeze frame
	impactAudio()
	flash()''')
replace_once('''	local ghost, cleanup = fly(dummy, feet, trackX, function(pos)''', '''	playOneShot(BOING_ID, 0.36, 1.05, 1.8)
	local ghost, cleanup = fly(dummy, feet, trackX, function(pos)''')
replace_once('''		if puncher == player then
			coinPopup''', '''		if puncher == player then
			impactAudio()
			playOneShot(BOING_ID, 0.28, 1, 1.8)
			coinPopup''')
OUT.write_text(source, encoding="utf-8")
print("BUILD PASS: " + hashlib.sha256(BASE.read_bytes()).hexdigest() + " -> " + hashlib.sha256(OUT.read_bytes()).hexdigest())

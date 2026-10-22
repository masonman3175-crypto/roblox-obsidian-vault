--[[
	Local UI click/hover sounds
	Plays UI sounds locally (no replication) through SoundService:PlayLocalSound.
	Tags: sfx, gui, audio
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local SoundService = game:GetService("SoundService")

local uiSounds = {}

local function register(name: string, soundId: string, volume: number?)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = soundId
	s.Volume = volume or 0.5
	s.Parent = SoundService
	uiSounds[name] = s
end

local function play(name: string)
	local s = uiSounds[name]
	if s then SoundService:PlayLocalSound(s) end
end

return { register = register, play = play }

--[[
	Play an SFX with pitch/volume variation
	Clones a template Sound, randomises pitch and volume slightly so repeated hits do not sound identical.
	Tags: sfx, audio, variation
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local rng = Random.new()

local function playVaried(template: Sound, parent: Instance?, group: SoundGroup?)
	local s = template:Clone()
	s.PlaybackSpeed = rng:NextNumber(0.92, 1.08)
	s.Volume = template.Volume * rng:NextNumber(0.9, 1)
	if group then s.SoundGroup = group end -- parenting to a group is not enough
	s.Parent = parent or SoundService
	s:Play()
	Debris:AddItem(s, math.max(s.TimeLength, 0.1) / s.PlaybackSpeed + 0.2)
	return s
end

return playVaried

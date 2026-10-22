--[[
	3D positional sound with rolloff
	A sound attached to a part with a defined audible range.
	Tags: sfx, audio, 3d
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local function attach3DSound(part: BasePart, soundId: string, looped: boolean?)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Looped = looped or false
	s.RollOffMode = Enum.RollOffMode.InverseTapered
	s.RollOffMinDistance = 8   -- full volume inside this range
	s.RollOffMaxDistance = 80  -- silent beyond this range
	s.Volume = 0.8
	s.Parent = part
	return s
end

return attach3DSound

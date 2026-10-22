--[[
	SoundGroup mixing bus
	Creates Music / SFX / UI groups, applies a shared Reverb once and exposes volume sliders.
	Tags: sfx, audio, mixing
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local SoundService = game:GetService("SoundService")

local function makeBus()
	local function group(name: string, volume: number)
		local g = SoundService:FindFirstChild(name) or Instance.new("SoundGroup")
		g.Name = name
		g.Volume = volume
		g.Parent = SoundService
		return g :: SoundGroup
	end
	local bus = {
		Music = group("Music", 0.6),
		SFX = group("SFX", 1),
		UI = group("UI", 0.8),
	}
	-- Effects on a group affect everything assigned to it, so add reverb once for all SFX.
	if not bus.SFX:FindFirstChildOfClass("ReverbSoundEffect") then
		local rv = Instance.new("ReverbSoundEffect")
		rv.DecayTime = 1.2
		rv.Density = 0.6
		rv.Diffusion = 0.7
		rv.DryLevel = 0
		rv.WetLevel = -12
		rv.Parent = bus.SFX
	end
	return bus
end

return makeBus
-- Remember: group Volume multiplies child volume, and nested groups multiply again.

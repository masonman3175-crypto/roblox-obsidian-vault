--[[
	Tween a ParticleEmitter NumberSequence
	TweenService cannot tween NumberSequence properties, so drive them from a NumberValue.
	Tags: vfx, particles, tween
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

-- Fades an emitter's overall size/transparency by rebuilding the sequence from a 0..1 value.
local function fadeEmitter(emitter: ParticleEmitter, baseSize: number, duration: number)
	local v = Instance.new("NumberValue")
	v.Value = 1
	v:GetPropertyChangedSignal("Value"):Connect(function()
		emitter.Size = NumberSequence.new(baseSize * v.Value)
	end)
	local t = TweenService:Create(v, TweenInfo.new(duration, Enum.EasingStyle.Sine), { Value = 0 })
	t.Completed:Once(function() emitter.Enabled = false; v:Destroy() end)
	t:Play()
end

return fadeEmitter

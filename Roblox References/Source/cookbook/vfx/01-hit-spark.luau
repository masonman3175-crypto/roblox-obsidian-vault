--[[
	Hit spark burst
	One-shot spark burst at an impact point using ParticleEmitter:Emit and a short Lifetime.
	Tags: vfx, particles, combat
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local Debris = game:GetService("Debris")

local function hitSpark(position: Vector3, color: Color3?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.one * 0.2
	part.Position = position
	local e = Instance.new("ParticleEmitter")
	e.Rate = 0 -- emit manually
	e.Lifetime = NumberRange.new(0.15, 0.3)
	e.Speed = NumberRange.new(18, 34)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 6
	e.LightEmission = 1
	e.Color = ColorSequence.new(color or Color3.fromRGB(255, 220, 120))
	e.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	e.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	e.Parent = part
	part.Parent = workspace
	e:Emit(12)
	Debris:AddItem(part, 0.6)
end

return hitSpark

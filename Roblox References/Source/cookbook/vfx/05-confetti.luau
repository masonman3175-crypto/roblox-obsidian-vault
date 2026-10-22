--[[
	Confetti burst
	Multi-colour falling confetti using random ColorSequence keypoints and gravity.
	Tags: vfx, particles, reward
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local Debris = game:GetService("Debris")

local function confetti(position: Vector3)
	local part = Instance.new("Part")
	part.Anchored = true; part.CanCollide = false; part.CanQuery = false
	part.Transparency = 1; part.Size = Vector3.one; part.Position = position
	local e = Instance.new("ParticleEmitter")
	e.Rate = 0
	e.Lifetime = NumberRange.new(1.6, 2.4)
	e.Speed = NumberRange.new(20, 34)
	e.SpreadAngle = Vector2.new(60, 60)
	e.EmissionDirection = Enum.NormalId.Top
	e.Acceleration = Vector3.new(0, -40, 0)
	e.Drag = 2
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-300, 300)
	e.Size = NumberSequence.new(0.35)
	e.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 99, 132)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 205, 86)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(75, 192, 192)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(54, 162, 235)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(153, 102, 255)),
	})
	e.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	e.Parent = part
	part.Parent = workspace
	e:Emit(60)
	Debris:AddItem(part, 3)
end

return confetti

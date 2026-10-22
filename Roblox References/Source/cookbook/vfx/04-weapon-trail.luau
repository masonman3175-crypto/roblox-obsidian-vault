--[[
	Weapon swing Trail
	Adds a Trail between two attachments on a blade and toggles it during swings.
	Tags: vfx, trail, combat
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local function addTrail(blade: BasePart, tipOffset: Vector3, baseOffset: Vector3)
	local a0 = Instance.new("Attachment")
	a0.Name = "TrailBase"; a0.Position = baseOffset; a0.Parent = blade
	local a1 = Instance.new("Attachment")
	a1.Name = "TrailTip"; a1.Position = tipOffset; a1.Parent = blade
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.25
	trail.MinLength = 0.05
	trail.FaceCamera = true
	trail.LightEmission = 0.6
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 190, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	trail.Enabled = false -- enable only during the swing's active frames
	trail.Parent = blade
	return trail
end

return addTrail

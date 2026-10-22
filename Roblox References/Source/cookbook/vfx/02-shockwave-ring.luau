--[[
	Shockwave ring
	Expanding flat ring for landings and heavy hits, built from a Neon cylinder and a tween.
	Tags: vfx, impact, tween
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local function shockwave(position: Vector3, color: Color3?, radius: number?)
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = color or Color3.fromRGB(255, 255, 255)
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CastShadow = false
	ring.Size = Vector3.new(0.2, 1, 1) -- cylinder axis is X
	ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Transparency = 0.2
	ring.Parent = workspace
	local r = radius or 14
	TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.2, r, r),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ring, 0.6)
end

return shockwave

--[[
	Sprint FOV kick
	Widens field of view while sprinting and eases back.
	Tags: camera, animation
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function setSprinting(isSprinting: boolean)
	local camera = workspace.CurrentCamera
	TweenService:Create(camera, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = isSprinting and 82 or 70,
	}):Play()
end

return setSprinting

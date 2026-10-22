--[[
	Simple camera shake
	Decaying random camera offset applied each frame on top of the default camera.
	Tags: cutscene, camera, juice
	Status: Compiled in Studio 0.743. Not run: it needs RenderStepped, which does not tick in Edit mode.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local RunService = game:GetService("RunService")

local function shake(magnitude: number, duration: number)
	local camera = workspace.CurrentCamera
	local start = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local alpha = (os.clock() - start) / duration
		if alpha >= 1 then conn:Disconnect() return end
		local m = magnitude * (1 - alpha) ^ 2
		local offset = CFrame.Angles(
			math.rad((math.random() - 0.5) * 2 * m),
			math.rad((math.random() - 0.5) * 2 * m),
			math.rad((math.random() - 0.5) * m)
		)
		camera.CFrame = camera.CFrame * offset
	end)
end

return shake
-- For production-quality shake see the linked RbxCameraShaker library in libraries/LIBRARIES.md.

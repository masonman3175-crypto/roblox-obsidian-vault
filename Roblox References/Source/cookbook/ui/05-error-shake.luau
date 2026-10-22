--[[
	Error shake
	Short horizontal shake for invalid input or a failed purchase.
	Tags: gui, animation, feedback
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function shake(gui: GuiObject, strength: number?, steps: number?)
	local amp = strength or 6
	local n = steps or 6
	local origin = gui.Position
	task.spawn(function()
		for i = 1, n do
			local dir = (i % 2 == 0) and 1 or -1
			local falloff = 1 - (i - 1) / n
			local t = TweenService:Create(gui, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {
				Position = origin + UDim2.fromOffset(dir * amp * falloff, 0),
			})
			t:Play()
			t.Completed:Wait()
		end
		gui.Position = origin
	end)
end

return shake

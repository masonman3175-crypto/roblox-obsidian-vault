--[[
	Shine sweep across a button
	A diagonal white highlight sweeps across a button using a UIGradient transparency ramp and an Offset tween.
	Tags: gui, uigradient, polish
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function addShine(button: GuiObject, interval: number?)
	local holder = Instance.new("Frame")
	holder.Name = "Shine"
	holder.BackgroundColor3 = Color3.new(1, 1, 1)
	holder.BackgroundTransparency = 0
	holder.BorderSizePixel = 0
	holder.Size = UDim2.fromScale(1, 1)
	holder.ZIndex = button.ZIndex + 1
	local corner = button:FindFirstChildOfClass("UICorner")
	if corner then corner:Clone().Parent = holder end
	local g = Instance.new("UIGradient")
	g.Rotation = 25
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.42, 1),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(0.58, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	g.Offset = Vector2.new(-1, 0)
	g.Parent = holder
	holder.Parent = button
	local running = true
	task.spawn(function()
		while running and holder.Parent do
			g.Offset = Vector2.new(-1, 0)
			local t = TweenService:Create(g, TweenInfo.new(0.7, Enum.EasingStyle.Sine), { Offset = Vector2.new(1, 0) })
			t:Play()
			t.Completed:Wait()
			task.wait(interval or 2.5)
		end
	end)
	return function() running = false; holder:Destroy() end
end

return addShine

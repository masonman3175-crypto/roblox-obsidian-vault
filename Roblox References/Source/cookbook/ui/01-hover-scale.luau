--[[
	Button hover scale + press squash
	Grows a button on hover and squashes on press using UIScale, so layout is unaffected.
	Tags: gui, animation, tween, uiscale
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function attachHoverScale(button: GuiButton, hoverScale: number?, pressScale: number?)
	local hover = hoverScale or 1.06
	local press = pressScale or 0.94
	local scale = button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = button
	local function tweenTo(target: number, time: number, style: Enum.EasingStyle)
		TweenService:Create(scale, TweenInfo.new(time, style, Enum.EasingDirection.Out), { Scale = target }):Play()
	end
	local conns = {
		button.MouseEnter:Connect(function() tweenTo(hover, 0.12, Enum.EasingStyle.Quad) end),
		button.MouseLeave:Connect(function() tweenTo(1, 0.12, Enum.EasingStyle.Quad) end),
		button.MouseButton1Down:Connect(function() tweenTo(press, 0.06, Enum.EasingStyle.Quad) end),
		button.MouseButton1Up:Connect(function() tweenTo(hover, 0.18, Enum.EasingStyle.Back) end),
	}
	return function() for _, c in conns do c:Disconnect() end end -- call to clean up
end

return attachHoverScale

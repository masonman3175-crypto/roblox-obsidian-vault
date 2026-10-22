--[[
	Pop-in panel open/close
	Panel scales from 0.8 to 1 with a Back overshoot while fading in via a CanvasGroup.
	Tags: gui, animation, canvasgroup
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function setup(panel: CanvasGroup)
	local scale = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = panel
	local function open()
		panel.Visible = true
		scale.Scale = 0.8
		panel.GroupTransparency = 1
		TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	end
	local function close()
		local t = TweenService:Create(panel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
		TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.9 }):Play()
		t.Completed:Once(function() panel.Visible = false end)
		t:Play()
	end
	return { open = open, close = close }
end

return setup

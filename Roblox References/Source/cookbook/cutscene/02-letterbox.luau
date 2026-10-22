--[[
	Letterbox bars
	Two black bars slide in for cinematic mode and out afterwards.
	Tags: cutscene, gui, cinematic
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function createLetterbox(gui: ScreenGui, heightScale: number?)
	local h = heightScale or 0.12
	gui.IgnoreGuiInset = true
	local function bar(name: string, anchorY: number)
		local f = Instance.new("Frame")
		f.Name = name
		f.AnchorPoint = Vector2.new(0, anchorY)
		f.Position = UDim2.fromScale(0, anchorY)
		f.Size = UDim2.fromScale(1, 0)
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BorderSizePixel = 0
		f.ZIndex = 100
		f.Parent = gui
		return f
	end
	local top, bottom = bar("Top", 0), bar("Bottom", 1)
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	return {
		show = function()
			TweenService:Create(top, info, { Size = UDim2.fromScale(1, h) }):Play()
			TweenService:Create(bottom, info, { Size = UDim2.fromScale(1, h) }):Play()
		end,
		hide = function()
			TweenService:Create(top, info, { Size = UDim2.fromScale(1, 0) }):Play()
			TweenService:Create(bottom, info, { Size = UDim2.fromScale(1, 0) }):Play()
		end,
	}
end

return createLetterbox

--[[
	Responsive scale + safe area
	Scales a fixed-design ScreenGui to any viewport with UIScale and respects device safe insets.
	Tags: gui, mobile, responsive
	Status: Compiled in Studio 0.743. Not run: it needs a real ScreenGui LocalScript context.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
-- Place in a LocalScript under the ScreenGui. Design at 1920x1080.
local gui = script.Parent :: ScreenGui
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets -- keep UI out of notches/home bars

local DESIGN = Vector2.new(1920, 1080)
local scale = gui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
scale.Parent = gui

local function update()
	local size = gui.AbsoluteSize
	scale.Scale = math.clamp(math.min(size.X / DESIGN.X, size.Y / DESIGN.Y), 0.5, 2)
end
update()
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)

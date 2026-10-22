--[[
	Currency count-up
	Rolls a number to a new value by tweening a NumberValue (TweenService cannot tween text directly).
	Tags: gui, tween, hud
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local function countUp(label: TextLabel, from: number, to: number, duration: number?, format: ((number) -> string)?)
	local fmt = format or function(n) return tostring(math.floor(n + 0.5)) end
	local value = Instance.new("NumberValue")
	value.Value = from
	local conn = value:GetPropertyChangedSignal("Value"):Connect(function()
		label.Text = fmt(value.Value)
	end)
	local tween = TweenService:Create(value, TweenInfo.new(duration or 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = to })
	tween.Completed:Once(function()
		conn:Disconnect()
		label.Text = fmt(to)
		value:Destroy()
	end)
	tween:Play()
end

return countUp

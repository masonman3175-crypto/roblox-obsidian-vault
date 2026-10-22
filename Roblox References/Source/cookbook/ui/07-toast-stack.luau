--[[
	Pooled toast notifications
	Stacks up to N toasts with slide-in/out, auto-dismiss and a UIListLayout.
	Tags: gui, notifications, pooling
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")

local Toasts = {}
Toasts.__index = Toasts

function Toasts.new(container: Frame, maxVisible: number?)
	local layout = container:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = container
	return setmetatable({ container = container, max = maxVisible or 4, order = 0, live = {} }, Toasts)
end

function Toasts:push(text: string, lifetime: number?)
	self.order += 1
	local toast = Instance.new("CanvasGroup")
	toast.Size = UDim2.new(1, 0, 0, 44)
	toast.BackgroundColor3 = Color3.fromRGB(30, 34, 50)
	toast.LayoutOrder = self.order
	toast.GroupTransparency = 1
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamMedium
	Instance.new("UIPadding", label).PaddingLeft = UDim.new(0, 12)
	label.Parent = toast
	toast.Parent = self.container
	table.insert(self.live, toast)
	if #self.live > self.max then
		local old = table.remove(self.live, 1)
		if old then old:Destroy() end
	end
	TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	task.delay(lifetime or 3, function()
		if not toast.Parent then return end
		local t = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
		t.Completed:Once(function() toast:Destroy() end)
		t:Play()
	end)
end

return Toasts

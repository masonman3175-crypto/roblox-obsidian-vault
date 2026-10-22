--!strict
-- UiStyle: chunky homepage-sim buttons and panels built from plain instances.
-- See wiki/ui/Sim Button Anatomy.md for the layer breakdown.
-- Button layers (back to front): Lip (dark bevel + outline) > Face (fill) > Studs > Shade > Gloss > Dim > Icon > Label > Badge

local TweenService = game:GetService("TweenService")

local UiStyle = {}

UiStyle.Colors = {
	Red = Color3.fromRGB(235, 45, 50),
	Pink = Color3.fromRGB(255, 75, 145),
	Orange = Color3.fromRGB(255, 145, 25),
	Yellow = Color3.fromRGB(255, 215, 40),
	Green = Color3.fromRGB(70, 205, 60),
	Blue = Color3.fromRGB(30, 170, 255),
	Purple = Color3.fromRGB(165, 65, 255),
	Gold = Color3.fromRGB(255, 190, 30),
	Dark = Color3.fromRGB(35, 35, 50),
	Outline = Color3.fromRGB(20, 20, 32),
	White = Color3.fromRGB(255, 255, 255),
}

UiStyle.Font = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)

local OUTLINE = 3
local LIP = 5
local STUD = 12
local STUD_GAP = 6
local MAX_STUDS = 160

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 60)),
	ColorSequenceKeypoint.new(0.18, Color3.fromRGB(255, 50, 60)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 150, 30)),
	ColorSequenceKeypoint.new(0.36, Color3.fromRGB(255, 150, 30)),
	ColorSequenceKeypoint.new(0.38, Color3.fromRGB(255, 225, 40)),
	ColorSequenceKeypoint.new(0.52, Color3.fromRGB(255, 225, 40)),
	ColorSequenceKeypoint.new(0.54, Color3.fromRGB(70, 215, 70)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(70, 215, 70)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(40, 160, 255)),
	ColorSequenceKeypoint.new(0.84, Color3.fromRGB(40, 160, 255)),
	ColorSequenceKeypoint.new(0.86, Color3.fromRGB(170, 70, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 70, 255)),
})

local function darken(c: Color3, amount: number): Color3
	local h, s, v = c:ToHSV()
	return Color3.fromHSV(h, math.min(1, s + amount * 0.2), v * (1 - amount))
end
UiStyle.Darken = darken

local function new(className: string, props: { [string]: any }, children: { Instance }?): any
	local inst = Instance.new(className)
	for k, v in props do
		if k ~= "Parent" then
			(inst :: any)[k] = v
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(radius: number): UICorner
	return new("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(thickness: number, color: Color3?, transparency: number?): UIStroke
	return new("UIStroke", {
		Thickness = thickness,
		Color = color or UiStyle.Colors.Outline,
		Transparency = transparency or 0,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

-- Stud tile pattern: small rounded square outlines on a grid, refilled when the size changes
local function addStuds(parent: GuiObject, color: Color3, transparency: number, zIndex: number, inset: number): Frame
	local holder = new("Frame", {
		Name = "Studs",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(inset, inset),
		Size = UDim2.new(1, -inset * 2, 1, -inset * 2),
		ClipsDescendants = true,
		ZIndex = zIndex,
		Parent = parent,
	})
	new("UIGridLayout", {
		CellSize = UDim2.fromOffset(STUD, STUD),
		CellPadding = UDim2.fromOffset(STUD_GAP, STUD_GAP),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})
	local count = 0
	local function fill()
		local size = holder.AbsoluteSize
		local cell = STUD + STUD_GAP
		local want = math.min(MAX_STUDS, math.ceil(size.X / cell) * math.ceil(size.Y / cell))
		while count < want do
			count += 1
			new("Frame", {
				BackgroundTransparency = 1,
				ZIndex = zIndex,
				Parent = holder,
			}, { corner(3), stroke(1.5, color, transparency) })
		end
	end
	holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(fill)
	task.defer(fill)
	return holder
end

-- Chunky white text with a thick dark outline
function UiStyle.Label(props: { [string]: any }): TextLabel
	return new("TextLabel", {
		Name = props.Name or "Label",
		Text = props.Text or "",
		FontFace = UiStyle.Font,
		TextColor3 = props.TextColor3 or UiStyle.Colors.White,
		TextScaled = true,
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.new(),
		AnchorPoint = props.AnchorPoint or Vector2.zero,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = props.ZIndex or 1,
		Parent = props.Parent,
	}, {
		stroke(props.StrokeThickness or 3, props.StrokeColor),
		new("UITextSizeConstraint", { MaxTextSize = props.MaxTextSize or 48 }),
	})
end

local function makeIcon(icon: string, zIndex: number): GuiObject
	if icon:find("^rbxasset") or icon:find("^http") then
		return new("ImageLabel", {
			Name = "Icon",
			Image = icon,
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = zIndex,
		})
	end
	return new("TextLabel", {
		Name = "Icon",
		Text = icon,
		TextScaled = true,
		FontFace = UiStyle.Font,
		BackgroundTransparency = 1,
		ZIndex = zIndex,
	})
end

-- Original illustrated atlas: each key crops a distinct cartoon pictogram.
local ICON_ATLAS = "rbxassetid://101842589645723"
local ICON_OFFSETS = {
    Passes = Vector2.new(0, 0),
    Boosts = Vector2.new(128, 0),
    Coins = Vector2.new(256, 0),
    Eggs = Vector2.new(384, 0),
    Gym = Vector2.new(512, 0),
    Rebirth = Vector2.new(640, 0),
    Pets = Vector2.new(0, 128),
    Shop = Vector2.new(128, 128),
    Train = Vector2.new(256, 128),
    Double = Vector2.new(384, 128),
    AutoTrain = Vector2.new(512, 128),
    VIP = Vector2.new(640, 128),
    AutoPunch = Vector2.new(0, 256),
    DoubleCoins = Vector2.new(128, 256),
    FastWalk = Vector2.new(256, 256),
    TripleHatch = Vector2.new(384, 256),
    AutoHatch = Vector2.new(512, 256),
    Lucky = Vector2.new(640, 256),
    PetSlots = Vector2.new(0, 384),
    GymVIP = Vector2.new(128, 384),
    GymMega = Vector2.new(256, 384),
    GymAdmin = Vector2.new(384, 384),
    StrengthSmall = Vector2.new(512, 384),
    StrengthMedium = Vector2.new(640, 384),
    StrengthLarge = Vector2.new(0, 512),
    CoinsSmall = Vector2.new(128, 512),
    CoinsMedium = Vector2.new(256, 512),
    CoinsLarge = Vector2.new(384, 512),
    Boost = Vector2.new(512, 512),
    CoinBoost = Vector2.new(640, 512),
    LuckBoost = Vector2.new(0, 640),
    Level = Vector2.new(128, 640),
    RebirthSkip = Vector2.new(256, 640),
    WorldSkip = Vector2.new(384, 640),
    MegaEgg = Vector2.new(512, 640),
    UltraEgg = Vector2.new(640, 640),
    RebirthButton = Vector2.new(640, 0),
    SkipButton = Vector2.new(256, 640),
}

function UiStyle.Logo(props: { [string]: any }): Frame
    local z = props.ZIndex or 10
    local color = props.Color or UiStyle.Colors.Gold
    local frame = new("Frame", {
        Name = props.Name or "Logo", Size = props.Size or UDim2.fromOffset(62, 62),
        Position = props.Position or UDim2.new(), AnchorPoint = props.AnchorPoint or Vector2.zero,
        BackgroundColor3 = darken(color, 0.48), ZIndex = z, Parent = props.Parent,
    }, {corner(15), stroke(3, UiStyle.Colors.Outline)})
    local face = new("Frame", {
        Name="Face", Size=UDim2.new(1,-8,1,-10), Position=UDim2.fromOffset(4,3),
        BackgroundColor3=color, ZIndex=z+1, Parent=frame,
    }, {corner(12), new("UIGradient", {Rotation=90, Color=ColorSequence.new(Color3.new(1,1,1), darken(color,0.1))})})
    new("ImageLabel", {
        Name = "Picture",
        BackgroundTransparency = 1,
        Image = ICON_ATLAS,
        ImageRectOffset = ICON_OFFSETS[props.Key] or ICON_OFFSETS.Shop,
        ImageRectSize = Vector2.new(128, 128),
        ScaleType = Enum.ScaleType.Stretch,
        Position = UDim2.fromScale(0.04, 0.02),
        Size = UDim2.fromScale(0.92, 0.92),
        ZIndex = z + 3,
        Parent = face,
    })
    return frame
end

local function makeBadge(z: number): Frame
	local badge = new("Frame", {
		Name = "Badge",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -4, 0, 4),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = UiStyle.Colors.Red,
		ZIndex = z,
	}, {
		new("UICorner", { CornerRadius = UDim.new(1, 0) }),
		stroke(3),
		new("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 190)),
		}),
	})
	UiStyle.Label({
		Name = "Text",
		Text = "!",
		StrokeThickness = 2,
		Size = UDim2.fromScale(0.8, 0.8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = z + 1,
		Parent = badge,
	})
	return badge
end

-- Big chunky button. Stable children for other code: Label (TextLabel), Badge (Frame, hidden), Icon (when given)
function UiStyle.Button(props: { [string]: any }): TextButton
	local color: Color3 = props.Color or UiStyle.Colors.Blue
	local shape = props.Shape or "Wide"
	local z = props.ZIndex or 2
	local radius = props.CornerRadius or (if shape == "Square" then 12 else 8)

	local button = new("TextButton", {
		Name = props.Name or "Button",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = props.Size or (if shape == "Square" then UDim2.fromOffset(96, 96) else UDim2.fromOffset(200, 56)),
		Position = props.Position or UDim2.new(),
		AnchorPoint = props.AnchorPoint or Vector2.zero,
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = z,
	})
	local scale = new("UIScale", { Name = "Scale", Parent = button })

	-- Lip: darker copy of the fill under the face, carries the outer outline
	new("Frame", {
		Name = "Lip",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = if props.Rainbow then Color3.fromRGB(90, 40, 140) else darken(color, 0.45),
		ZIndex = z,
		Parent = button,
	}, { corner(radius), stroke(OUTLINE) })

	local face = new("Frame", {
		Name = "Face",
		Size = UDim2.new(1, 0, 1, -LIP),
		BackgroundColor3 = if props.Rainbow then Color3.new(1, 1, 1) else color,
		ZIndex = z + 1,
		Parent = button,
	}, { corner(radius) })
	if props.Rainbow then
		new("UIGradient", { Color = RAINBOW, Rotation = -30, Parent = face })
	end

	if props.Studs ~= false then
		addStuds(face, darken(color, 0.5), 0.55, z + 2, math.floor(radius / 2))
	end

	-- Shade: bottom of the face gets darker
	new("Frame", {
		Name = "Shade",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		ZIndex = z + 3,
		Parent = face,
	}, {
		corner(radius),
		new("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.55, 1),
				NumberSequenceKeypoint.new(1, 0.72),
			}),
		}),
	})

	-- Gloss: soft white band on the top half
	new("Frame", {
		Name = "Gloss",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 0.45, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = z + 4,
		Parent = face,
	}, {
		corner(math.max(radius - 3, 2)),
		new("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.55),
				NumberSequenceKeypoint.new(1, 0.92),
			}),
		}),
	})

	local dim = new("Frame", {
		Name = "Dim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = z + 5,
		Parent = face,
	}, { corner(radius) })

	local label = UiStyle.Label({
		Text = props.Text or "",
		ZIndex = z + 7,
		MaxTextSize = props.MaxTextSize,
		StrokeThickness = props.StrokeThickness or 3,
	})

	if props.Logo or (props.Icon ~= nil and props.Icon ~= "") then
		local icon = if props.Logo then UiStyle.Logo({Key=props.Logo, Color=color, ZIndex=z+6}) else makeIcon(props.Icon, z + 6)
		if shape == "Square" then
			-- big icon fills the top and pokes past the edge like the reference
			icon.AnchorPoint = Vector2.new(0.5, 0)
			icon.Position = UDim2.fromScale(0.5, -0.08)
			icon.Size = UDim2.fromScale(0.86, 0.78)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 1, -LIP - 2)
			label.Size = UDim2.fromScale(0.94, 0.3)
		else
			-- icon hangs off the left edge, label fills the rest
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, -10, 0.5, -LIP / 2)
			icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			icon.Size = UDim2.fromScale(1.1, 1.1)
			label.AnchorPoint = Vector2.new(1, 0.5)
			label.Position = UDim2.new(1, -8, 0.5, -LIP / 2)
			label.Size = UDim2.new(0.7, -8, 0.72, 0)
		end
		icon.Parent = button
	else
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.new(0.5, 0, 0.5, -LIP / 2)
		label.Size = UDim2.new(1, -16, 0.72, 0)
	end
	label.Parent = button

	local badge = makeBadge(z + 8)
	badge.Visible = props.Badge == true
	badge.Parent = button

	-- Hover / press feel: scale bump, face sinks into the lip, darkens
	local info = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local hovering = false
	local function setState(state: string)
		local s = if state == "press" then 0.93 elseif state == "hover" then 1.06 else 1
		local d = if state == "press" then 0.75 elseif state == "hover" then 0.92 else 1
		local y = if state == "press" then LIP - 1 else 0
		TweenService:Create(scale, info, { Scale = s }):Play()
		TweenService:Create(dim, info, { BackgroundTransparency = d }):Play()
		TweenService:Create(face, info, { Position = UDim2.fromOffset(0, y) }):Play()
	end
	button.MouseEnter:Connect(function()
		hovering = true
		setState("hover")
	end)
	button.MouseLeave:Connect(function()
		hovering = false
		setState("idle")
	end)
	button.MouseButton1Down:Connect(function()
		setState("press")
	end)
	button.MouseButton1Up:Connect(function()
		setState(if hovering then "hover" else "idle")
	end)

	if props.Parent then
		button.Parent = props.Parent
	end
	return button
end

-- Popup panel: colored header bar with title, red X button (child "Close"), dark stud body (child "Body")
function UiStyle.Panel(props: { [string]: any }): Frame
	local color: Color3 = props.Color or UiStyle.Colors.Pink
	local z = props.ZIndex or 10
	local header = props.HeaderHeight or 56

	local panel = new("Frame", {
		Name = props.Name or "Panel",
		Size = props.Size or UDim2.fromOffset(520, 380),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BodyColor or UiStyle.Colors.Dark,
		BackgroundTransparency = props.BodyTransparency or 0.08,
		ZIndex = z,
	}, { corner(16), stroke(4) })

	local shine = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200))
	local bar = new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, header),
		BackgroundColor3 = color,
		ZIndex = z + 1,
		Parent = panel,
	}, { corner(14), new("UIGradient", { Rotation = 90, Color = shine }) })
	-- squares off the header's bottom corners
	new("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = darken(color, 0.2),
		BorderSizePixel = 0,
		ZIndex = z + 1,
		Parent = bar,
	})
	new("Frame", {
		Name = "Gloss",
		Position = UDim2.fromOffset(6, 4),
		Size = UDim2.new(1, -12, 0.4, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = z + 2,
		Parent = bar,
	}, {
		corner(10),
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0.6, 0.95) }),
	})

	UiStyle.Label({
		Name = "Title",
		Text = props.Title or "",
		Position = UDim2.fromOffset(18, 4),
		Size = UDim2.new(1, -110, 1, -8),
		TextXAlignment = Enum.TextXAlignment.Left,
		StrokeThickness = 4,
		MaxTextSize = 44,
		ZIndex = z + 3,
		Parent = bar,
	})

	UiStyle.Button({
		Name = "Close",
		Text = "X",
		Color = UiStyle.Colors.Red,
		Shape = "Square",
		Studs = false,
		Size = UDim2.fromOffset(header + 8, header + 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -header / 2 + 4, 0, header / 2 - 6),
		MaxTextSize = 44,
		StrokeThickness = 4,
		ZIndex = z + 4,
		Parent = panel,
	})

	local body = new("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(12, header + 12),
		Size = UDim2.new(1, -24, 1, -header - 24),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		ZIndex = z + 1,
		Parent = panel,
	}, { corner(12) })
	-- ZIndex 0 keeps the pattern under anything put in Body (HUD uses Sibling ZIndexBehavior)
	addStuds(body, Color3.new(1, 1, 1), 0.9, 0, 6)

	if props.Parent then
		panel.Parent = props.Parent
	end
	return panel
end

return UiStyle



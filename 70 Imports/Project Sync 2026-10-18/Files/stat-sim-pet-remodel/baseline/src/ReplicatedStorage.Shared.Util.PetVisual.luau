-- Makes a pet model: a clone from ReplicatedStorage.PetModels.<petId> if it
-- exists, otherwise a cute placeholder ball (glowing for Epic and better). Visual only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)

local PetVisual = {}

local PET_SIZE = 3

local function placeholder(index)
	local pet = PetsConfig.List[index] or {Color = Color3.new(1, 1, 1), Rarity = "Common"}
	local rarity = PetsConfig.Rarities[pet.Rarity]
	local model = Instance.new("Model")
	model.Name = tostring(index)
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(2.6, 2.6, 2.6)
	body.Color = pet.Color
	body.Material = Enum.Material.SmoothPlastic
	body.Parent = model
	for _, side in {-1, 1} do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.6, 0.6, 0.6)
		eye.Color = Color3.fromRGB(20, 20, 30)
		eye.CFrame = body.CFrame * CFrame.new(side * 0.5, 0.35, -1.1)
		eye.Parent = model
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = body
		weld.Part1 = eye
		weld.Parent = eye
	end
	model.PrimaryPart = body
	if rarity and rarity.Order >= 4 then
		local glow = Instance.new("ParticleEmitter")
		glow.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		glow.Rate = 8
		glow.Lifetime = NumberRange.new(0.6, 1)
		glow.Speed = NumberRange.new(0.5, 1.5)
		glow.SpreadAngle = Vector2.new(180, 180)
		glow.Size = NumberSequence.new(0.5, 0)
		glow.Color = ColorSequence.new(rarity.Color)
		glow.Parent = body
		local light = Instance.new("PointLight")
		light.Color = rarity.Color
		light.Range = 8
		light.Parent = body
	end
	return model
end

function PetVisual.Make(index)
	local folder = ReplicatedStorage:FindFirstChild("PetModels")
	local source = folder and folder:FindFirstChild(tostring(index))
	local model = if source and source:IsA("Model") then source:Clone() else placeholder(index)
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart", true)
	end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.Anchored = false
		end
	end
	if model.PrimaryPart then
		model.PrimaryPart.Anchored = true
	end
	-- every pet is the same size no matter how the source model was built
	local _, size = model:GetBoundingBox()
	local biggest = math.max(size.X, size.Y, size.Z)
	if biggest > 0 then
		model:ScaleTo(model:GetScale() * PET_SIZE / biggest)
	end
	return model
end

return PetVisual

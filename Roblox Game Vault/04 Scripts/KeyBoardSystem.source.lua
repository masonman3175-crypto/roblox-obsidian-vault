local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local SoundFolder = ReplicatedStorage:WaitForChild("Sounds", 10) 

local keyVolume = 1
local randomGenerator = Random.new()
local cachedSoundIds = {}  
local activeKeys = {}       
local keyStates = {}        

local CONFIG = {
	BASE_DETECTION_SIZE = Vector3.new(2.5, 5, 2.5),
	LERP_SPEED_DOWN    = 20,   
	LERP_SPEED_UP      = 8,    
	HOLD_TIME          = 0.15, 
	VELOCITY_PADDING   = 1.2,  
	SOUND_COOLDOWN     = 0.03,
	PRESS_DEPTH        = 1.4 
}

local soundPool = table.create(40)
local currentSoundPoolIndex = 1
local lastSoundPlayTime = 0

for i = 1, 40 do
	local sound = Instance.new("Sound")
	sound.RollOffMaxDistance = 100
	sound.RollOffMinDistance = 10
	soundPool[i] = sound
end

local function getRandomSoundsFromFolder()
	if #cachedSoundIds > 0 then
		return cachedSoundIds
	end

	if SoundFolder then
		for _, child in ipairs(SoundFolder:GetChildren()) do
			if child:IsA("Sound") and child.SoundId ~= "" then
				table.insert(cachedSoundIds, child.SoundId)
			end
		end
	end

	return cachedSoundIds
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
if workspace:FindFirstChild("Keycaps") then
	overlapParams:AddToFilter(workspace.Keycaps)
end

RunService.RenderStepped:Connect(function(deltaTime)
	local currentTime = os.clock()
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if rootPart then
		local velocity = rootPart.AssemblyLinearVelocity
		local extraWidthX = math.abs(velocity.X) * deltaTime * CONFIG.VELOCITY_PADDING
		local extraWidthZ = math.abs(velocity.Z) * deltaTime * CONFIG.VELOCITY_PADDING
		local detectionBoxSize = CONFIG.BASE_DETECTION_SIZE + Vector3.new(extraWidthX, 0, extraWidthZ)

		local detectedParts = workspace:GetPartBoundsInBox(rootPart.CFrame * CFrame.new(0, -2.5, 0), detectionBoxSize, overlapParams)

		for _, part in ipairs(detectedParts) do
			local state = keyStates[part]

			if not state then
				state = {
					currentAlpha = 0,
					targetAlpha = 0,
					lastHit = 0,
					originalCF = part.CFrame,
					pressDepth = CONFIG.PRESS_DEPTH
				}
				keyStates[part] = state
			end

			if state.targetAlpha == 0 and (currentTime - lastSoundPlayTime) >= CONFIG.SOUND_COOLDOWN then
				if keyVolume > 0 then
					local soundList = getRandomSoundsFromFolder()
					if #soundList > 0 then
						local soundObject = soundPool[currentSoundPoolIndex]
						currentSoundPoolIndex = (currentSoundPoolIndex % 40) + 1

						soundObject.SoundId = soundList[randomGenerator:NextInteger(1, #soundList)]
						soundObject.Volume = keyVolume
						soundObject.Parent = part
						soundObject:Play()
					end
				end
				lastSoundPlayTime = currentTime
			end

			state.targetAlpha = 1
			state.lastHit = currentTime
			activeKeys[part] = true
		end
	end

	local partsToMove = {}
	local targetCFrames = {}

	for part, _ in pairs(activeKeys) do
		local state = keyStates[part]

		if currentTime - state.lastHit > CONFIG.HOLD_TIME then
			state.targetAlpha = 0
		end

		local lerpSpeed = (state.targetAlpha == 1) and CONFIG.LERP_SPEED_DOWN or CONFIG.LERP_SPEED_UP
		local difference = state.targetAlpha - state.currentAlpha
		state.currentAlpha = state.currentAlpha + (difference * math.clamp(deltaTime * lerpSpeed, 0, 1))

		local isBackToNormal = (state.targetAlpha == 0) and (state.currentAlpha < 0.01)
		local nextCFrame

		if isBackToNormal then
			state.currentAlpha = 0
			nextCFrame = state.originalCF
			activeKeys[part] = nil
		else
			nextCFrame = state.originalCF * CFrame.new(0, -state.currentAlpha * state.pressDepth, 0)
		end

		table.insert(partsToMove, part)
		table.insert(targetCFrames, nextCFrame)
	end

	workspace:BulkMoveTo(partsToMove, targetCFrames)
end)
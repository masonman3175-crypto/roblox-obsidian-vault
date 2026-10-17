-- Claude's third-person combat camera + aim pose.
-- Over-the-shoulder camera, mouse locked in matches, character faces where you look,
-- arms + torso aim at the camera pitch (other players' pitch comes from the server attribute AimPitch).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local aimRemote = package:WaitForChild("AimPitch")
local player = Players.LocalPlayer
local gameSettings = UserSettings():GetService("UserGameSettings")

local SHOULDER = Vector3.new(2.1, 0.55, 0)
local shoulderX = SHOULDER.X
local lastSent, lastSentAt = 0, 0

local function inMatch()
	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
end

local function armed(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool and tool:GetAttribute("ReferenceWeaponId") ~= nil
end

local function cameraPitch()
	local cam = workspace.CurrentCamera
	return cam and math.asin(math.clamp(cam.CFrame.LookVector.Y, -1, 1)) or 0
end

-- camera: runs after the default camera, the gun controller and the lobby script
RunService:BindToRenderStep("ClaudeThirdPerson", Enum.RenderPriority.Last.Value + 2, function(dt)
	local cam = workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not cam or not humanoid or humanoid.Health <= 0 or not head then return end
	local combat = inMatch()
	UserInputService.MouseBehavior = combat and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = not combat
	gameSettings.RotationType = combat and Enum.RotationType.CameraRelative or Enum.RotationType.MovementRelative
	if not combat then return end
	-- shoulder offset, pulled in when a wall is on the right
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, workspace:FindFirstChild("ClaudeAKFx")}
	local right = cam.CFrame.RightVector
	local wall = workspace:Raycast(head.Position, right * (SHOULDER.X + 0.6), params)
	local wanted = wall and math.max(0, (wall.Position - head.Position).Magnitude - 0.7) or SHOULDER.X
	shoulderX += (wanted - shoulderX) * (1 - math.exp(-dt * 14))
	cam.CFrame = cam.CFrame * CFrame.new(shoulderX, SHOULDER.Y, 0)
	-- share pitch with the server (10x a second, only when it changed)
	local pitch = cameraPitch()
	local now = os.clock()
	if now - lastSentAt > 0.1 and math.abs(pitch - lastSent) > math.rad(1) then
		lastSent, lastSentAt = pitch, now
		aimRemote:FireServer(pitch)
	end
end)

-- Aim and movement now share GameplayPresentation.CharacterPose (bounded pose-only integration).
-- Camera, mouse lock and AimPitch network protocol above remain unchanged.

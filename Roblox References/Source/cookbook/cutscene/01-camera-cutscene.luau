--[[
	Scriptable camera cutscene
	Plays a list of camera shots by tweening Camera.CFrame between marker parts, then restores control.
	Tags: cutscene, camera, tween
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

export type Shot = {
	from: CFrame,
	to: CFrame,
	duration: number,
	fov: number?,
	easing: Enum.EasingStyle?,
}

local function playCutscene(shots: { Shot }, onFinished: (() -> ())?)
	local camera = workspace.CurrentCamera
	local previousType, previousFov = camera.CameraType, camera.FieldOfView
	camera.CameraType = Enum.CameraType.Scriptable
	for _, shot in shots do
		camera.CFrame = shot.from
		if shot.fov then camera.FieldOfView = shot.fov end
		local tween = TweenService:Create(camera, TweenInfo.new(shot.duration, shot.easing or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = shot.to,
		})
		tween:Play()
		tween.Completed:Wait()
	end
	camera.FieldOfView = previousFov
	camera.CameraType = previousType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or previousType
	if onFinished then onFinished() end
end

return playCutscene
-- Usage (LocalScript): build Shots from invisible marker Parts' CFrames; lock player input while playing.

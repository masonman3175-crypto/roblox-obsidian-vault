--[[
	Play an animation and react to keyframe markers
	Loads an animation on the character's Animator and fires logic on named KeyframeMarkers (hit frames, footsteps).
	Tags: animation, combat, markers
	Status: Compiled in Studio 0.743. Not run: needs a character rig / RemoteEvent and an animation asset.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local function playWithMarkers(character: Model, animationId: string, handlers: { [string]: () -> () }?)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return nil end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	if handlers then
		for markerName, fn in handlers do
			track:GetMarkerReachedSignal(markerName):Connect(fn)
		end
	end
	track:Play(0.1)
	return track
end

return playWithMarkers
-- Hit detection triggered by a marker must still be validated on the server.

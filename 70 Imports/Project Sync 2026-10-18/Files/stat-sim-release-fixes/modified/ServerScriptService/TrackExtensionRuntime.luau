-- Only authoring previews are removed in Play. The original six biomes stay intact.
local track=workspace:WaitForChild("Map"):WaitForChild("Track")
local preview=track:FindFirstChild("ExtensionsPreview")
if preview then
 for _,world in ipairs(preview:GetChildren()) do world:Destroy();task.wait() end
 preview:Destroy()
end
print("[TrackExtension] original biomes=6; appended landscape catalog=60; extra runtime world budget=8")



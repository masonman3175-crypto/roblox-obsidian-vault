-- The sixty-level authoring preview is Edit-only. Each client draws a bounded route.
local track=workspace:WaitForChild("Map"):WaitForChild("Track")
local preview=track:FindFirstChild("EditorPreview")
if preview then
 for i,model in ipairs(preview:GetChildren()) do model:Destroy();if i%4==0 then task.wait() end end
 preview:Destroy()
end
track:SetAttribute("RuntimeMode","Local bounded milestone route")
track:SetAttribute("CatalogLevels",60)
print("[PunchExpansion] 60 original destinations + echo realms; no 10M endpoint; local stage budget=8")


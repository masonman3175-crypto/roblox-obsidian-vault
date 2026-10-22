-- Stop Play first. Removes ONLY Build 01 namespaces; restores captured lighting/camera.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
do local obj=game.ReplicatedStorage:FindFirstChild("ClawEmpire"); if obj then obj:Destroy() end end
do local obj=game.ServerScriptService:FindFirstChild("ClawEmpire"); if obj then obj:Destroy() end end
do local obj=game.StarterPlayer.StarterPlayerScripts:FindFirstChild("ClawEmpireClient"); if obj then obj:Destroy() end end
do local obj=workspace:FindFirstChild("ClawEmpirePreview"); if obj then obj:Destroy() end end
do local obj=workspace:FindFirstChild("ClawEmpirePlots"); if obj then obj:Destroy() end end
game:GetService("Lighting").ClockTime=14.5
game:GetService("Lighting").Brightness=3
game:GetService("Lighting").Ambient=Color3.new(0.27450981736183167,0.27450981736183167,0.27450981736183167)
game:GetService("Lighting").OutdoorAmbient=Color3.new(0.27450981736183167,0.27450981736183167,0.27450981736183167)
workspace.CurrentCamera.CFrame=CFrame.new(-41.3100471496582,29.611717224121094,-33.15898513793945,-0.7061503529548645,0.3129655718803406,-0.635141134262085,0,0.8970135450363159,0.4420031011104584,0.708061933517456,0.312120646238327,-0.6334264278411865)
workspace.CurrentCamera.CameraType=Enum.CameraType.Fixed
return "STUDIO_ROLLBACK_PASS namespaces=removed original-baseplate-and-spawn=preserved lighting-camera=restored"

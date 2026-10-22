local backup = game.ServerStorage:FindFirstChild("PublishReady_Backup_20261018")
assert(backup and backup:FindFirstChild("PunchFxController") and backup:FindFirstChild("CharacterVisual"), "publish-ready backup missing")
local fx = game.StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController
fx.Source = backup.PunchFxController.Source
local dummy = workspace.Map.Gameplay.PunchLane.Dummy
dummy.CharacterVisual:Destroy()
backup.CharacterVisual:Clone().Parent = dummy
dummy:SetAttribute("VisualStyle", nil)
return "STUDIO ROLLBACK PASS: original visual and silent punch cutscene restored"

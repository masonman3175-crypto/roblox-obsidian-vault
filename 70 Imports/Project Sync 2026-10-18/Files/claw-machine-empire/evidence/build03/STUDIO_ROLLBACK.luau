-- Restores the actual captured Build02 instances. Stop Play before running.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local backup=assert(game.ServerStorage:FindFirstChild("CME_Build02_Backup"),"Build02 backup missing")
local targets={
    {parent=game.ReplicatedStorage,name="ClawEmpire",source="Replicated"},
    {parent=game.ServerScriptService,name="ClawEmpire",source="Server"},
    {parent=game.StarterPlayer.StarterPlayerScripts,name="ClawEmpireClient",source="Client"},
    {parent=workspace,name="ClawEmpirePreview",source="Preview"},
}
for _,target in ipairs(targets) do assert(backup:FindFirstChild(target.source),"Incomplete backup") end
for _,target in ipairs(targets) do
    local live=target.parent:FindFirstChild(target.name)
    if live then live:Destroy() end
    local restored=backup[target.source]:Clone(); restored.Name=target.name; restored.Parent=target.parent
    task.wait()
end
workspace.CurrentCamera.CFrame=backup:GetAttribute("CameraCFrame")
return "BUILD03_STUDIO_ROLLBACK_PASS restored=Build02 cabinets=25 backup=retained"

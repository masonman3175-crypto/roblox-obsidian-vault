return function(root,backup)
 root=root or game;backup=backup or root.ServerStorage:FindFirstChild("PrivateZombieSessionBackup_20261017")
 assert(backup,"Missing preserved originals")
 local function resolve(path)local o=root;for _,s in string.split(path,".")do o=o and o:FindFirstChild(s)end;return o end
 local count=0
 for _,saved in backup:GetChildren()do local path=saved:GetAttribute("OriginalPath")
  if path then local dest=resolve(path);assert(dest and dest:IsA("LuaSourceContainer"),"Missing "..path);dest.Source=saved.Source;count+=1 end
 end
 assert(count==12,"Expected 12 originals")
 for _,path in {"ReplicatedStorage.SurvivalRun","ServerScriptService.SurvivalRun","StarterPlayer.StarterPlayerScripts.SurvivalRun","Workspace.SurvivalRun","ServerStorage.SurvivalBedAsset","ServerStorage.SurvivalZombieRig"}do local o=resolve(path);if o then o:Destroy()end end
 local lobby=resolve("Workspace.SurvivorLobby")
 if lobby then for _,pad in lobby.Queues:GetChildren()do pad.LabelAnchor.QueueLabel.Timer.Text="15 (sec)"end end
 return "PASS: 12 original sources/15s labels restored; run packages and two new assets removed"
end


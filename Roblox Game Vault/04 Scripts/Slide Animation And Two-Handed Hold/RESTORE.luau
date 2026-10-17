-- Pass an isolated fixture as target for QA; omit to restore the live Edit place.
return function(target,backup)
 target=target or game
 backup=backup or game.ServerStorage:FindFirstChild("SlideAndGripBackup_20261017")
 assert(backup,"Missing preserved backup")
 local function resolve(path)
  local obj=target
  for _,seg in string.split(path,".") do obj=obj and obj:FindFirstChild(seg)end
  return obj
 end
 local count=0
 for _,source in backup:GetChildren() do
  local path=source:GetAttribute("OriginalPath")
  if path then local dest=resolve(path);assert(dest and dest:IsA("LuaSourceContainer"),"Missing "..path)
   dest.Source=source.Source;count+=1
  end
 end
 assert(count==4,"Expected four original sources")
 local pose=resolve("ReplicatedStorage.GameplayPresentation.CharacterPose")
 if pose then pose:Destroy()end
 return "PASS: 4 original sources restored; CharacterPose removed"
end

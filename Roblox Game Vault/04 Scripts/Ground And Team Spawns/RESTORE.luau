-- Restore ONLY the touched ground/spawn/team fields.
-- For isolated testing pass {Baseplate=clone,Spawns=cloneFolder,Teams=cloneFolder}.
local function restore(targets,backup)
 local base=targets.Baseplate;local original=backup.Baseplate
 base.Material=original.Material;base.MaterialVariant=original.MaterialVariant;base.Color=original.Color
 for _,v in base:GetChildren() do
  if v:IsA("Texture") or v:IsA("Decal") then
   local saved=original:FindFirstChild(v.Name)
   if saved and saved.ClassName==v.ClassName then v.Transparency=saved.Transparency end
  end
 end
 for _,saved in backup.Spawns:GetChildren() do
  local live=assert(targets.Spawns:FindFirstChild(saved.Name))
  for _,field in {"CFrame","Size","TeamColor","Neutral","AllowTeamChangeOnTouch","Enabled","Duration","Transparency","CanCollide"} do live[field]=saved[field] end
 end
 for _,n in {"Crips","Bloods"} do
  local live=targets.Teams:FindFirstChild(n);local old=backup.Teams:FindFirstChild(n)
  if old then
   if not live then live=old:Clone();live.Parent=targets.Teams
   else live.TeamColor=old.TeamColor;live.AutoAssignable=old.AutoAssignable end
  elseif live then live:Destroy() end
 end
 return "ROLLBACK PASS: original checker texture, Plastic baseplate, neutral original spawn transforms, and prior teams restored"
end
return restore


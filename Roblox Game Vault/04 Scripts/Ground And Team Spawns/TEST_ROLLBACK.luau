local SS=game.ServerStorage
local backup=assert(SS:FindFirstChild("GroundTeamSpawnsBackup_20261017"))
local fixture=Instance.new("Folder");fixture.Name="IsolatedRollbackFixture"
local targets={Baseplate=workspace.Baseplate:Clone(),Spawns=workspace.Map.Spawns:Clone(),Teams=Instance.new("Folder")}
targets.Baseplate.Parent=fixture;targets.Spawns.Parent=fixture;targets.Teams.Name="Teams";targets.Teams.Parent=fixture
for _,team in game.Teams:GetTeams() do team:Clone().Parent=targets.Teams end
local module=Instance.new("ModuleScript");module.Name="Restore";module.Source="-- Restore ONLY the touched ground/spawn/team fields.\n-- For isolated testing pass {Baseplate=clone,Spawns=cloneFolder,Teams=cloneFolder}.\nlocal function restore(targets,backup)\n local base=targets.Baseplate;local original=backup.Baseplate\n base.Material=original.Material;base.MaterialVariant=original.MaterialVariant;base.Color=original.Color\n for _,v in base:GetChildren() do\n  if v:IsA(\"Texture\") or v:IsA(\"Decal\") then\n   local saved=original:FindFirstChild(v.Name)\n   if saved and saved.ClassName==v.ClassName then v.Transparency=saved.Transparency end\n  end\n end\n for _,saved in backup.Spawns:GetChildren() do\n  local live=assert(targets.Spawns:FindFirstChild(saved.Name))\n  for _,field in {\"CFrame\",\"Size\",\"TeamColor\",\"Neutral\",\"AllowTeamChangeOnTouch\",\"Enabled\",\"Duration\",\"Transparency\",\"CanCollide\"} do live[field]=saved[field] end\n end\n for _,n in {\"Crips\",\"Bloods\"} do\n  local live=targets.Teams:FindFirstChild(n);local old=backup.Teams:FindFirstChild(n)\n  if old then\n   if not live then live=old:Clone();live.Parent=targets.Teams\n   else live.TeamColor=old.TeamColor;live.AutoAssignable=old.AutoAssignable end\n  elseif live then live:Destroy() end\n end\n return \"ROLLBACK PASS: original checker texture, Plastic baseplate, neutral original spawn transforms, and prior teams restored\"\nend\nreturn restore\n";module.Parent=fixture
fixture.Parent=SS
local ok,result=pcall(function()
 local message=require(module)(targets,backup)
 assert(targets.Baseplate.Material==backup.Baseplate.Material and targets.Baseplate.Color==backup.Baseplate.Color)
 assert(targets.Baseplate.Texture.Transparency==backup.Baseplate.Texture.Transparency)
 for _,saved in backup.Spawns:GetChildren() do
  local restored=targets.Spawns[saved.Name]
  for _,field in {"CFrame","Size","TeamColor","Neutral","AllowTeamChangeOnTouch","Enabled","Duration","Transparency","CanCollide"} do assert(restored[field]==saved[field],"Restored "..field.." mismatch") end
 end
 assert(#targets.Teams:GetChildren()==#backup.Teams:GetChildren())
 assert(workspace.Baseplate.Material==Enum.Material.Asphalt and workspace.Baseplate.Texture.Transparency==1)
 assert(not workspace.Map.Spawns.Spawn_West.Neutral and #game.Teams:GetTeams()==2)
 return message.."; live modified objects retained"
end)
fixture:Destroy()
assert(ok,tostring(result))
return result


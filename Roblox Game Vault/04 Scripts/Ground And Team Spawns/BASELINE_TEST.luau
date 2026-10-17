local count=0
for _,t in workspace.Baseplate:GetChildren() do if (t:IsA("Texture") or t:IsA("Decal")) and t.Transparency<1 then count+=1 end end
local neutral=0
for _,s in workspace.Map.Spawns:GetChildren() do if s:IsA("SpawnLocation") and s.Neutral and s.Enabled then neutral+=1 end end
assert(count==1 and neutral==2 and #game.Teams:GetTeams()==0)
return "BASELINE PASS: visible checker textures=1; enabled neutral spawns=2; teams=0"


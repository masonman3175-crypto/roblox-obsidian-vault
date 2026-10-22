local backup=assert(game.ServerStorage:FindFirstChild("PunchExpansion_Backup"))
assert(#backup.Track:GetDescendants()==3754)
local count=0;local source
for _,s in ipairs(backup.Scripts:GetChildren()) do
 assert(loadstring(s.Source),s.Name);count+=1
 if s:GetAttribute("OriginalPath")=="ReplicatedStorage.Shared.Config.Punch" then source=s.Source end
end
assert(count==29)
local p=assert(loadstring(assert(source)))()
assert(p.TrackX(10)==40 and p.TrackX(100)==1040 and p.TrackX(1e15)==6040)
for _,name in ipairs({"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace","DistanceBoards","Finish"}) do assert(backup.Track:FindFirstChild(name)) end
return "BASELINE_ENGINE_PASS scripts=29 track_descendants=3754 original_max_x=6040 backup=preserved"

-- Ground texture and diagonally opposed team spawn update.
-- Run once in the Edit DataModel through Roblox Studio MCP.
local SS=game:GetService("ServerStorage")
local Teams=game:GetService("Teams")
local map=assert(workspace:FindFirstChild("Map"),"Expected Workspace.Map")
local base=assert(workspace:FindFirstChild("Baseplate"),"Expected Baseplate")
local spawns=assert(map:FindFirstChild("Spawns"),"Expected Map.Spawns")
local backupName="GroundTeamSpawnsBackup_20261017"
assert(not SS:FindFirstChild(backupName),"Backup already exists; inspect before rerunning")
local backup=Instance.new("Folder");backup.Name=backupName
base:Clone().Parent=backup
local savedSpawns=Instance.new("Folder");savedSpawns.Name="Spawns";savedSpawns.Parent=backup
for _,v in spawns:GetChildren() do if v:IsA("SpawnLocation") then v:Clone().Parent=savedSpawns end end
local savedTeams=Instance.new("Folder");savedTeams.Name="Teams";savedTeams.Parent=backup
for _,v in Teams:GetChildren() do if v:IsA("Team") then v:Clone().Parent=savedTeams end end
backup:SetAttribute("PlaceId",game.PlaceId)
backup:SetAttribute("Purpose","Restore original checker texture and neutral west/east spawns")
backup.Parent=SS
local road=map.Ground.Street:FindFirstChild("MainRoad")
base.Material=Enum.Material.Asphalt
base.MaterialVariant=""
base.Color=road and road.Color or Color3.fromRGB(88,88,90)
for _,v in base:GetChildren() do
 if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end
end
local specs={
 {name="Crips",color="Bright blue",spawn="Spawn_West",pos=Vector3.new(-235,.5,-135)},
 {name="Bloods",color="Bright red",spawn="Spawn_East",pos=Vector3.new(245,.5,135)}
}
for _,s in specs do
 local team=Teams:FindFirstChild(s.name)
 if not team then team=Instance.new("Team");team.Name=s.name;team.Parent=Teams end
 team.TeamColor=BrickColor.new(s.color);team.AutoAssignable=true
 local spawn=assert(spawns:FindFirstChild(s.spawn),"Missing legacy spawn")
 spawn.TeamColor=team.TeamColor;spawn.Neutral=false;spawn.AllowTeamChangeOnTouch=false
 spawn.Enabled=true;spawn.Duration=3;spawn.Transparency=1;spawn.CanCollide=false
 spawn.Size=Vector3.new(10,1,10)
 spawn.CFrame=CFrame.lookAt(s.pos,Vector3.new(5,s.pos.Y,0))
end
game:GetService("ChangeHistoryService"):SetWaypoint("Ground and opposite-corner team spawns")
return "MODIFIED PASS: checker hidden; Asphalt; Crips NW (-235,0.5,-135); Bloods SE (245,0.5,135); two automatic teams; legacy spawn paths retained"


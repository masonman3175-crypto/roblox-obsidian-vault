local root=Instance.new('Folder');root.Name='IsolatedMenuRollbackFixture'
local function folder(name,parent)local f=Instance.new('Folder');f.Name=name;f.Parent=parent;return f end
local services={}
for _,name in ipairs({'ReplicatedStorage','ServerScriptService','ServerStorage','StarterPlayer','Workspace'})do services[name]=folder(name,root)end
local players={CharacterAutoLoads=false};services.Players=players
local RS=services.ReplicatedStorage;local SS=services.ServerStorage
game.ServerStorage.MainMenuBackup_20261016:Clone().Parent=SS
game.ReplicatedStorage.ReferenceWeapons:Clone().Parent=RS
game.ReplicatedStorage.MainMenu:Clone().Parent=RS
game.ServerScriptService.MainMenuSystem:Clone().Parent=services.ServerScriptService
local scripts=folder('StarterPlayerScripts',services.StarterPlayer)
game.StarterPlayer.StarterPlayerScripts.MainMenuClient:Clone().Parent=scripts
local focus=Instance.new('Part');focus.Name='MainMenuStreamingFocus';focus.Parent=services.Workspace
local spawn=Instance.new('SpawnLocation');spawn.Name='SpawnSentinel';spawn.CFrame=CFrame.new(-190,.3,0);spawn.Parent=services.Workspace;local spawnCF=spawn.CFrame
local mock={GetService=function(_,name)return services[name]end}
local fn=assert(loadstring([====[-- Run in Edit mode to return to the pre-menu weapon presentation.
-- MainMenuBackup_20261016 is retained; map, spawn and weapon templates are untouched.
local RS=game:GetService('ReplicatedStorage')
local SSS=game:GetService('ServerScriptService')
local SS=game:GetService('ServerStorage')
local SP=game:GetService('StarterPlayer')
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local backup=SS:FindFirstChild('MainMenuBackup_20261016')
assert(backup and backup:FindFirstChild('Controller'),'Original menu backup missing')
RS.ReferenceWeapons.Controller.Source=backup.Controller.Source
for _,pair in ipairs({{RS,'MainMenu'},{SSS,'MainMenuSystem'},{SP.StarterPlayerScripts,'MainMenuClient'},{Workspace,'MainMenuStreamingFocus'}})do
    local ob=pair[1]:FindFirstChild(pair[2]);if ob then ob:Destroy()end
end
Players.CharacterAutoLoads=backup:GetAttribute('CharacterAutoLoads')
return 'ROLLBACK: auto-spawn restored; menu removed; original weapon controller restored; spawns untouched'
]====]))
setfenv(fn,setmetatable({game=mock},{__index=getfenv()}))
local result=fn()
assert(players.CharacterAutoLoads==true)
assert(not RS:FindFirstChild('MainMenu'))
assert(not services.ServerScriptService:FindFirstChild('MainMenuSystem'))
assert(not scripts:FindFirstChild('MainMenuClient'))
assert(not services.Workspace:FindFirstChild('MainMenuStreamingFocus'))
assert(RS.ReferenceWeapons.Controller.Source==SS.MainMenuBackup_20261016.Controller.Source)
assert(spawn.CFrame==spawnCF)
assert(game.ReplicatedStorage.MainMenu.Client.Source:find('LiveBirdsEye',1,true),'Live menu was changed')
root:Destroy()
return {Result=result,IsolatedFixture=true,LiveModifiedRetained=true,ExitStatus=0}

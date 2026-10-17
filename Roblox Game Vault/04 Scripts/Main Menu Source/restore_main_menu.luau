-- Run in Edit mode to return to the pre-menu weapon presentation.
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

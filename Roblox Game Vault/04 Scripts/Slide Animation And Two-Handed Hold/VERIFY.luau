local function hash(s)local h=5381;for i=1,#s do h=(h*33+s:byte(i))%4294967296 end;return {Length=#s,DJB2=h}end
local paths={"ReplicatedStorage.GameplayPresentation.CharacterPose","ReplicatedStorage.GameplayPresentation.MovementClient","ReplicatedStorage.GameplayPresentation.MovementConfig","ServerScriptService.GameplayMovement.Service","StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson","ServerScriptService.ClaudeAKServer.Logic","ReplicatedStorage.ReferenceWeapons.Controller","ReplicatedStorage.ReferenceWeapons.WeaponConfig","ReplicatedStorage.LobbySystem.Client"}
local out={};for _,path in paths do local o=game;for _,s in string.split(path,".")do o=o and o:FindFirstChild(s)end;out[path]=o and hash(o.Source)or false end
out.Backup={};for _,o in game.ServerStorage.SlideAndGripBackup_20261017:GetChildren()do out.Backup[o:GetAttribute("OriginalPath")]=hash(o.Source)end
out.PlaceId=game.PlaceId;out.ContractPresent=game.ServerStorage:FindFirstChild("README_CONTRACT")~=nil
return game.HttpService:JSONEncode(out)

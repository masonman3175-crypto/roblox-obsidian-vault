local lobby=assert(workspace:FindFirstChild("SurvivorLobby"))
assert(not game.ReplicatedStorage:FindFirstChild("MainMenu"))
assert(not game.ServerScriptService:FindFirstChild("MainMenuSystem"))
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("MainMenuClient"))
assert(#game.Teams:GetTeams()==1 and game.Teams.Survivors.AutoAssignable)
assert(lobby.Spawn.Enabled and not lobby.Spawn.Neutral and lobby.Spawn.TeamColor==game.Teams.Survivors.TeamColor)
for _,s in workspace.Map.Spawns:GetDescendants() do if s:IsA("SpawnLocation") then assert(not s.Enabled) end end
local c=require(game.ReplicatedStorage.LobbySystem.Config)
assert(#c.Modes==4)
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={lobby};ray.RespectCanCollide=true
local rays=0
for _,mode in c.Modes do
 local m=lobby.Queues[mode.Id];assert(m:GetAttribute("PartySize")==mode.Size)
 for x=-12,12,4 do for z=-8,8,4 do local p=Vector3.new(1000+mode.X+x,8,-3+z);local hit=workspace:Raycast(p,Vector3.new(0,-12,0),ray);assert(hit,"Queue floor gap");rays+=1 end end
end
assert(workspace:Raycast(c.LobbySpawn.Position,Vector3.new(0,-12,0),ray),"Lobby spawn floor missing")
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.Map.Ground};params.RespectCanCollide=true
assert(workspace:Raycast(c.ArenaSpawn.Position,Vector3.new(0,-10,0),params),"Shared arena spawn floor missing")
local scripts=0 for _,o in lobby:GetDescendants() do if o:IsA("LuaSourceContainer") then scripts+=1 end end assert(scripts==0)
assert(not game.SoundService:FindFirstChild("BackgroundMusic"))
local expected=game.HttpService:JSONDecode("{\"ReplicatedStorage.ReferenceWeapons.Controller\":{\"hash\":4175647005,\"length\":29148},\"ReplicatedStorage.ClaudeAK.Fx\":{\"hash\":2476032189,\"length\":11915},\"ServerScriptService.ClaudeAKServer.Logic\":{\"hash\":2406451786,\"length\":4422},\"ServerScriptService.ClaudeAKServer\":{\"hash\":780576766,\"length\":73},\"ServerScriptService.GameplayMovement.Boot\":{\"hash\":3508180744,\"length\":38},\"ServerScriptService.GameplayMovement.Service\":{\"hash\":1266461236,\"length\":11598},\"ReplicatedStorage.GameplayPresentation.HUD\":{\"hash\":2949681719,\"length\":17982},\"ReplicatedStorage.ClaudeAK.Config\":{\"hash\":589541962,\"length\":2429},\"ReplicatedStorage.GameplayPresentation.MovementClient\":{\"hash\":830334395,\"length\":11374},\"ReplicatedStorage.AudioPresentation.Client\":{\"hash\":909507250,\"length\":16926},\"ReplicatedStorage.ReferenceWeapons.WeaponConfig\":{\"hash\":3349456275,\"length\":3423},\"ReplicatedStorage.AudioPresentation.Config\":{\"hash\":3965092023,\"length\":2454},\"ReplicatedStorage.GameplayPresentation.MovementConfig\":{\"hash\":2989197432,\"length\":436},\"ReplicatedStorage.AudioPresentation.Server\":{\"hash\":2231895791,\"length\":2268},\"ReplicatedStorage.GameplayPresentation.MovementMath\":{\"hash\":2287219378,\"length\":739}}")
local function fp(s) local h=5381 for i=1,#s do h=bit32.bxor(bit32.lshift(h,5)+h,string.byte(s,i)) end return h end
local stable,changed=0,{}
for path,e in expected do
 local o=game for n in path:gmatch("[^.]+") do o=o and o:FindFirstChild(n) end
 if o and #o.Source==e.length and fp(o.Source)==e.hash then stable+=1 else table.insert(changed,path) end
end
return game.HttpService:JSONEncode({result="VERIFY PASS",coOpSizes={1,2,3,4},teams=1,queueFloorRays=rays,clonedAssets=#lobby.StreetAssets:GetChildren(),importedScripts=scripts,stableSources=stable,changedSources=changed,sharedSpawn=tostring(c.ArenaSpawn.Position),music=false})

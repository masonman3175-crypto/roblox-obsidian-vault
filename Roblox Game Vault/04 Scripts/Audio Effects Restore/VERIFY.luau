local p=game.ReplicatedStorage.AudioPresentation
local clone=p.Config:Clone();clone.Parent=p;local c=require(clone);clone:Destroy()
assert(#p.Assets:GetChildren()==12)
assert(not c.Assets.NightRouteDrill and not c.Assets.CrossedWires)
assert(not game.SoundService:FindFirstChild("BackgroundMusic") and not game.SoundService:FindFirstChild("GameAudioMusic"))
assert(not p.Client.Source:find('WaitForChild("BackgroundMusic"',1,true))
assert(not p.Client.Source:find("KeyCode.F8",1,true))
for n,spec in c.Assets do assert(p.Assets[n].SoundId==spec.Id);assert(math.abs(p.Assets[n].Volume-spec.Volume)<.00001) end
local expected=game.HttpService:JSONDecode("{\"ReplicatedStorage.GameplayPresentation.MovementConfig\":{\"hash\":2989197432,\"length\":436},\"ReplicatedStorage.GameplayPresentation.HUD\":{\"hash\":2949681719,\"length\":17982},\"ServerScriptService.GameplayMovement.Boot\":{\"hash\":3508180744,\"length\":38},\"ServerScriptService.ClaudeAKServer.Logic\":{\"hash\":2406451786,\"length\":4422},\"ServerScriptService.ClaudeAKServer\":{\"hash\":780576766,\"length\":73},\"StarterPlayer.StarterPlayerScripts.ClaudeAKClient\":{\"hash\":848464263,\"length\":7701},\"ServerScriptService.GameplayMovement.Service\":{\"hash\":1266461236,\"length\":11598},\"ReplicatedStorage.ReferenceWeapons.Controller\":{\"hash\":4175647005,\"length\":29148},\"ReplicatedStorage.ClaudeAK.Config\":{\"hash\":3171817980,\"length\":2428},\"ReplicatedStorage.MainMenu.Cosmetics\":{\"hash\":9625929,\"length\":6256},\"ReplicatedStorage.MainMenu.Client\":{\"hash\":2900178918,\"length\":29851},\"ReplicatedStorage.ReferenceWeapons.WeaponConfig\":{\"hash\":3125653453,\"length\":3133},\"ReplicatedStorage.MainMenu.MenuConfig\":{\"hash\":851978201,\"length\":2344},\"ReplicatedStorage.ClaudeAK.Fx\":{\"hash\":2476032189,\"length\":11915},\"ReplicatedStorage.GameplayPresentation.MovementClient\":{\"hash\":830334395,\"length\":11374},\"ReplicatedStorage.GameplayPresentation.MovementMath\":{\"hash\":2287219378,\"length\":739}}")
local function fp(s) local h=5381 for i=1,#s do h=bit32.bxor(bit32.lshift(h,5)+h,string.byte(s,i)) end return h end
local unchanged,changed=0,{}
for path,x in expected do local o=game for n in path:gmatch("[^.]+") do o=o and o:FindFirstChild(n) end
 if o and #o.Source==x.length and fp(o.Source)==x.hash then unchanged+=1 else table.insert(changed,path) end
end
return game.HttpService:JSONEncode({result="VERIFY PASS",effects=12,backgroundMusic=false,protectedUnchanged=unchanged,concurrentChanges=changed,nativeW1=c.Weapons.W1.ExistingShot})

-- Temporary Studio-only test harness. Never installed in Edit or shipped with the game.
assert(game:GetService("RunService"):IsStudio())
local DS=require(game.ServerScriptService.Services.DataService)
local Stats=require(game.ServerScriptService.Services.StatService)
local Http=game:GetService("HttpService")
local player=game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait()
local profile=DS.Get(player)
while not profile do task.wait(.1);profile=DS.Get(player) end
local saved=Http:JSONDecode(Http:JSONEncode(profile))
local function restore()
	for k,v in saved do profile[k]=v end
	Stats.Refresh(player)
end
local bridge=Instance.new("BindableFunction");bridge.Name="PetRemodel_QA_Server"
bridge.OnInvoke=function(command)
	if command=="prepare" then
		profile.AutoTrainOn=false;profile.AutoPunchOn=false;profile.AutoHatchOn=false
		profile.PetInv={{u="QA1",p="Doggy",e=true},{u="QA2",p="FrostTitan",e=true},{u="QA3",p="InfinityDragon",e=true}}
		profile.NextPetUid=900001;profile.Coins=100
		Stats.Refresh(player)
		return "PREPARED temporary_pets=3 coins=100"
	elseif command=="state" then
		return Http:JSONEncode({coins=profile.Coins,inventory=profile.PetInv,nextUid=profile.NextPetUid})
	elseif command=="restore" then
		restore();return "PROFILE_RESTORED original_pets="..#saved.PetInv.." original_coins="..saved.Coins
	end
end
bridge.Parent=game.ServerStorage
script.Destroying:Connect(function()restore();bridge:Destroy()end)
task.delay(180,function()if script.Parent then restore() end end)

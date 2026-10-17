local S=require(game.ReplicatedStorage.AudioPresentation.Server)
local t={}
assert(S.Validate("Shot",0,"W2",10,t))
assert(not S.Validate("Shot",0,"W2",10.001,t))
assert(not S.Validate("Shot",0,"W1",20,{}))
assert(not S.Validate({},0,"W2",20,{}))
assert(not S.Validate("Shot",1,"W2",20,{}))
assert(not S.Validate("Shot",0,"W99",20,{}))
assert(not S.Validate("arbitrarySoundId",0,"W2",20,{}))
assert(S.Validate("Reload",0,"W3",20,{}))
assert(S.Validate("Equip",0,"W4",20,{}))
local before=S.GetStats()
game.ReplicatedStorage.ClaudeAK.HitConfirm:FireClient(game.Players:GetPlayers()[1],false,false)
task.wait(.15)
game.ReplicatedStorage.ClaudeAK.HitConfirm:FireClient(game.Players:GetPlayers()[1],true,false)
task.wait(.15)
game.ReplicatedStorage.ClaudeAK.HitConfirm:FireClient(game.Players:GetPlayers()[1],true,true)
local out=Instance.new("StringValue");out.Name="AudioQAServerResult";out.Value=game.HttpService:JSONEncode({result="REMOTE PASS: action whitelist, payload arity, equipped ID whitelist, rate limiting, W1 duplicate prevention",liveStats=before});out.Parent=game.ServerStorage


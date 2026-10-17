local p=game.Players:GetPlayers()[1]
local remote=game.ReplicatedStorage.ClaudeAK.HitConfirm
remote:FireClient(p,false,false);task.wait(.2);remote:FireClient(p,true,false);task.wait(.2);remote:FireClient(p,true,true)
local m=require(game.ReplicatedStorage.AudioPresentation.Server)
assert(not m.Validate("bad",0,"W1",10,{}))
assert(not m.Validate("Shot",1,"W2",10,{}))
assert(not m.Validate("Shot",0,"W1",10,{}))
assert(not m.Validate("Shot",0,"W3",10,{}))
assert(m.Validate("Shot",0,"W2",10,{}))
local before=m.GetStats().Rejected
assert(not m.Handle(p,{},1));assert(not m.Handle(p,"Shot","bad"));assert(not m.Handle(p,"arbitrary"))
return game.HttpService:JSONEncode({result="VALIDATION PASS",rejectedDelta=m.GetStats().Rejected-before})

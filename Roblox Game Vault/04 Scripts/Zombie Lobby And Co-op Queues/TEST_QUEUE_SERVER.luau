local Queue=require(game.ServerScriptService.LobbySystem.Queue)
local modes=require(game.ReplicatedStorage.LobbySystem.Config).Modes
local tests=0
for _,mode in modes do
 local q=Queue.new(modes,8)
 for id=1,mode.Size do assert(q:Add(id,mode.Id)) end
 assert(not q:Add(99,mode.Id))
 assert(#q:Step(100,function()return true end)==0)
 assert(#q:Step(107.9,function()return true end)==0)
 local launch=q:Step(108,function()return true end)
 assert(#launch==1 and #launch[1].Members==mode.Size and launch[1].Mode==mode.Id)
 assert(#q:Step(109,function()return true end)==0)
 for id=1,mode.Size do assert(not q.Membership[id]) end
 tests+=1
end
local q=Queue.new(modes,8)
q:Add(1,"Duos");q:Add(2,"Duos");q:Step(0,function()return true end)
q:Remove(2);assert(#q:Step(9,function()return true end)==0)
q:Add(2,"Duos");q:Step(10,function()return true end);assert(#q:Step(17,function()return true end)==0)
assert(#q:Step(18,function()return true end)==1)
q:Add(1,"Solos");q:Step(20,function()return false end);assert(not q.Membership[1])
assert(not q:Add(7,"PvP"))
q:Add(1,"Duos");q:Add(1,"Trios");assert(q.Membership[1]=="Trios" and #q.Queues.Duos.Members==0)
return "QUEUE UNIT PASS: 1/2/3/4-person co-op launches, capacity, cancellation/restart, disconnect pruning, switch and no duplicate dispatch"

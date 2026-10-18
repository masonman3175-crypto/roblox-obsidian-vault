local fixture=Instance.new("Folder");fixture.Name="RunUnitFixtures";fixture.Parent=game.ServerStorage
local function fresh(o)local clone=o:Clone();clone.Parent=fixture;return require(clone)end
local Queue=fresh(game.ServerScriptService.LobbySystem.Queue)
local descriptors=fresh(game.ReplicatedStorage.LobbySystem.Config).Queues
local q=Queue.new(descriptors,10)
local eligible=function()return true end
assert(q:Add(1,"Squads_1"));q:Step(100,eligible);assert(q.Queues.Squads_1.Deadline==110)
q:Add(2,"Squads_1");q:Step(104,eligible);assert(q.Queues.Squads_1.Deadline==110)
q:Remove(1);assert(q.Queues.Squads_1.Deadline==110)
local launch=q:Step(110,eligible);assert(#launch==1 and #launch[1].Members==1 and launch[1].Members[1]==2)
assert(#q:Step(111,eligible)==0)
q:Add(3,"Duos_1");q:Step(200,eligible);q:Remove(3);assert(q.Queues.Duos_1.Deadline==nil)
q:Add(4,"Solos_1");q:Step(300,eligible);assert(#q:Step(310,function()return false end)==0)
q:Add(5,"Solos_1");assert(not q:Add(6,"Solos_1"));q:Add(6,"Solos_2");q:Step(400,eligible);assert(#q:Step(410,eligible)==2)
local T=fresh(game.ServerScriptService.SurvivalRun.Transport)
local record={Users={101,202},PartyId="unit-party",Mode="Squads",PlaceId=game.PlaceId,ExpiresAt=os.time()+100}
assert(T.CheckManifest(record,101,game.PlaceId).Index==1);assert(T.CheckManifest(record,202,game.PlaceId).Index==2)
assert(T.CheckManifest(record,303,game.PlaceId)==false)
assert(T.CheckManifest(record,101,1)==false)
local invalid=table.clone(record);invalid.Users={101,101};assert(T.CheckManifest(invalid,101,game.PlaceId)==false)
invalid=table.clone(record);invalid.ExpiresAt=0;assert(T.CheckManifest(invalid,101,game.PlaceId)==false)
local options=T.Options("00000000-0000-0000-0000-000000000001","server-only-access-code","party")
assert(options.ReservedServerId=="00000000-0000-0000-0000-000000000001" and options.ReservedServerAccessCode=="")
assert(options:GetTeleportData().PartyId=="party" and options:GetTeleportData().Users==nil)
options:Destroy();fixture:Destroy()
return "PASS: partial10s, stable deadline, empty cancellation, leave-at-zero, capacity, duplicate circles, one dispatch; manifest allowlist/expiry/place/duplicate rejection; reserved-id options contain no roster/access code"


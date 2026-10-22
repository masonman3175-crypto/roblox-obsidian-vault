-- The runner injects Big, Config, Economy, ProfileStore. No engine mutations.
local count=0
local function check(value,message) assert(value,message); count+=1 end
local function equal(a,b,message) check(a==b,message..": "..tostring(a).." ~= "..tostring(b)) end
local function near(a,b,message) check(math.abs(a-b)<1e-8,message) end
local s=Economy.new()
check(Economy.validate(s),"fresh profile")
equal(Big.format(Big.new(1,400)),"1.00e400","beyond float range")
check(Big.compare(Big.new(1,400),Big.new(9,399))>0,"exponent order")
equal(Big.format(Big.add(Big.new(9,400),Big.new(1,400))),"1.00e401","carry exponent")
near(Big.sub(Big.new(250),Big.new(60)).m,1.9,"spend math")
check(not pcall(Big.new,0/0),"reject nan")
check(not pcall(Big.new,math.huge),"reject infinity")
check(not pcall(Big.new,-1),"reject negative")
check(not pcall(Big.sub,Big.new(1),Big.new(2)),"reject overspend")
check(not Big.valid({m=math.huge,e=0}),"invalid serialized mantissa")
check(not Big.valid({m=1,e=math.huge}),"invalid serialized exponent")
equal(Economy.roll(s,0),"duck","first weighted bound")
equal(Economy.roll(s,0.999999),"frog","last weighted bound")
check(not pcall(Economy.roll,s,0/0),"reject invalid RNG input")
check(not Economy.unlock(s),"no free unlock")
local ok,item=Economy.grant(s,"duck"); check(ok,"grant")
check(s.discovered.duck,"discover")
check(not Economy.display(s,999),"foreign id rejected")
check(Economy.display(s,item.id),"display owned item")
check(not Economy.display(s,item.id),"duplicate display rejected")
equal(#s.display,1,"no duplicate slots")
Economy.tick(s,10)
near(s.bank.m*10^s.bank.e,50,"income from display only")
Economy.collect(s)
near(s.coins.m*10^s.coins.e,50,"collect")
Economy.collect(s)
near(s.coins.m*10^s.coins.e,50,"collect replay no double credit")
check(not Economy.upgrade(s,"speed"),"upgrade requires funds")
Economy.tick(s,40); Economy.collect(s)
check(Economy.unlock(s),"next machine from earned income")
equal(s.machine,2,"classic selected")
equal(s.coins.m,0,"price deducted")
check(not Economy.unlock(s),"next tier requires funds")
equal(Economy.roll(s,0.999999),"star","classic includes mythical")
check(Economy.stow(s,item.id),"stow")
equal(Economy.rate(s).m,0,"stow stops income")
check(not Economy.stow(s,item.id),"stow replay")
check(Economy.sell(s,item.id),"sell stored item")
check(not Economy.sell(s,item.id),"sell replay rejected")
check(s.discovered.duck,"sale keeps discovery")
Economy.grant(s,"duck")
check(not Economy.grant(s,"forged"),"catalog check")
for _=2,Config.Storage do Economy.grant(s,"mochi") end
equal(#s.inventory,40,"storage size")
check(not Economy.grant(s,"duck"),"bounded storage")
for i=1,8 do check(Economy.display(s,s.inventory[i].id),"fill shelf "..i) end
check(not Economy.display(s,s.inventory[9].id),"bounded shelves")
check(not Economy.sell(s,s.inventory[1].id),"displayed item sale rejected")
s.coins=Big.new(10000)
for _=1,4 do check(Economy.upgrade(s,"speed"),"upgrade level") end
check(not Economy.upgrade(s,"speed"),"upgrade cap")
check(not Economy.upgrade(s,"forged"),"unknown upgrade")
check(Economy.validate(s),"played profile valid")
local bad=Economy.new(); bad.display={777}
check(not Economy.validate(bad),"orphan display detected")
bad=Economy.new(); bad.schema=999
check(not Economy.validate(bad),"future schema fails closed")
local records={}; local fault=false; local now=1000
local backend={UpdateAsync=function(_,key,callback)
    if fault then error("injected outage") end
    local nextValue=callback(ProfileStore.copy(records[key]))
    if nextValue==nil then return nil end
    records[key]=ProfileStore.copy(nextValue); return ProfileStore.copy(nextValue)
end}
local store=ProfileStore.new(backend,function() return now end)
local session=store:load("u1","serverA")
check(session~=nil,"acquire profile")
check(not store:load("u1","serverB"),"second server excluded")
check(store:load("u1","serverA")~=nil,"same-token ambiguous load recoverable")
Economy.grant(session.data,"cat")
check(store:save(session,false),"durable save")
equal(#records.u1.data.inventory,1,"saved inventory")
fault=true
check(not store:save(session,false),"save outage reported")
check(not store:load("u2","serverC"),"failed load creates no fallback")
check(records.u2==nil,"failed load never overwrites")
fault=false
check(store:save(session,true),"release")
local rejoin=store:load("u1","serverB")
equal(rejoin.data.inventory[1].species,"cat","rejoin retained plushie")
check(not store:save(session,false),"closed session cannot overwrite")
now+=200
local replacement=store:load("u1","serverC")
check(replacement~=nil,"expired lease takeover")
check(not store:save(rejoin,false),"stale server rejected")
check(store:save(replacement,true),"replacement saves")
records.corrupt={data={schema=999}}
check(not store:load("corrupt","serverD"),"corrupt data not replaced")
equal(records.corrupt.data.schema,999,"corrupt record preserved")
check(Config.PurchasesEnabled==false,"purchases off")
for _,product in ipairs(Config.Catalog) do equal(product.productId,0,"placeholder ids") end
equal(#Config.Machines,25,"exactly 25 cabinets")
equal(#Config.Plushies,25,"25 original plushies")
local tour=Economy.new(); local ids,skins,locations={},{},{}
for i,spec in ipairs(Config.Machines) do
    check(not ids[spec.id],"unique machine id"); ids[spec.id]=true
    check(not skins[spec.skin],"unique authored silhouette"); skins[spec.skin]=true
    local location=table.concat(spec.position,",")
    check(not locations[location],"nonoverlapping machine position"); locations[location]=true
    check(Config.plushie(spec.mascot)~=nil,"valid cabinet mascot")
    if i>1 then
        check(spec.cost>Config.Machines[i-1].cost,"increasing unlock cost")
        tour.coins=Big.new(spec.cost)
        check(Economy.unlock(tour),"unlock machine "..i)
    end
    equal(tour.machine,i,"highest owned")
    equal(Economy.selected(tour),i,"new machine selected")
    for _,u in ipairs({0,0.25,0.5,0.999999}) do
        local prize=Economy.roll(tour,u); local allowed=false
        for _,species in ipairs(spec.pool) do if species==prize then allowed=true end end
        check(allowed,"machine "..i.." valid weighted pool")
    end
end
check(not Economy.unlock(tour),"all 25 tier cap")
check(Economy.select(tour,1),"return to starter")
equal(Economy.roll(tour,0),"duck","selected machine controls pool")
check(Economy.select(tour,25),"select last owned machine")
check(not Economy.select(tour,26),"reject nonexistent machine")
check(not Economy.select(tour,0/0),"reject NaN selection")
check(not Economy.select(tour,math.huge),"reject infinite selection")
check(not Economy.select(Economy.new(),2),"reject unowned selection")
check(Economy.validate(tour),"25-machine profile validates")
tour.selected=nil
check(Economy.validate(tour),"Build01 profile migration compatible")
equal(Economy.selected(tour),25,"legacy selected fallback")
return "CONTRACTS_PASS checks="..count.." machines=25 silhouettes=25 pools=25 legacy=compatible purchases=disabled"

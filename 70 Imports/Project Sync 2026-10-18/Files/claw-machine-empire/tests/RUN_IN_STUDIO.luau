local Big,Config,Economy,ProfileStore
Big=assert(loadstring([====[return function()
-- Non-negative scientific values. ~15 significant digits, NOT exact accounting.
-- A bounded exponent avoids native float overflow; tiny addends may round away.
local Big = {}
local LIMIT = 1000000
function Big.valid(a)
    return type(a)=="table" and type(a.m)=="number" and type(a.e)=="number"
        and a.m==a.m and a.e==a.e and a.m>=0 and a.m<10
        and a.e%1==0 and a.e>=-LIMIT and a.e<=LIMIT
        and ((a.m==0 and a.e==0) or a.m>=1)
end
function Big.new(m, e)
    e = e or 0
    assert(type(m)=="number" and m==m and m>=0 and m<math.huge, "invalid mantissa")
    assert(type(e)=="number" and e==e and e%1==0 and math.abs(e)<=LIMIT, "invalid exponent")
    if m==0 then return {m=0,e=0} end
    local shift = math.floor(math.log10(m))
    if 10^shift==0 then shift+=1 end
    m, e = m / 10^shift, e+shift
    if m>=10 then m,e=m/10,e+1 end
    if m<1 then m,e=m*10,e-1 end
    assert(math.abs(e)<=LIMIT, "number range exceeded")
    return {m=m,e=e}
end
function Big.copy(a) return {m=a.m,e=a.e} end
function Big.compare(a,b)
    if a.m==0 then return if b.m==0 then 0 else -1 end
    if b.m==0 then return 1 end
    if a.e~=b.e then return if a.e>b.e then 1 else -1 end
    if math.abs(a.m-b.m)<1e-12 then return 0 end
    return if a.m>b.m then 1 else -1
end
function Big.add(a,b)
    if a.m==0 then return Big.copy(b) end
    if b.m==0 then return Big.copy(a) end
    if a.e<b.e then a,b=b,a end
    if a.e-b.e>15 then return Big.copy(a) end
    return Big.new(a.m + b.m*10^(b.e-a.e), a.e)
end
function Big.sub(a,b)
    assert(Big.compare(a,b)>=0, "insufficient balance")
    if b.m==0 or a.e-b.e>15 then return Big.copy(a) end
    return Big.new(math.max(0,a.m-b.m*10^(b.e-a.e)), a.e)
end
function Big.mul(a,n)
    assert(type(n)=="number" and n==n and n>=0 and n<math.huge, "invalid multiplier")
    local b=Big.new(n)
    return Big.new(a.m*b.m,a.e+b.e)
end
function Big.format(a)
    if a.m==0 then return "0" end
    if a.e<3 then return string.format("%.0f",a.m*10^a.e) end
    local suffix={"K","M","B","T","Qa","Qi","Sx","Sp","Oc","No","Dc"}
    local group=math.floor(a.e/3)
    if suffix[group] then return string.format("%.1f%s",a.m*10^(a.e%3),suffix[group]) end
    return string.format("%.2fe%d",a.m,a.e)
end
return Big
end]====]))()()
Config=assert(loadstring([====[return function()
-- Build 03: spacious plushie park, deterministic crane choreography, simple toy UI.
local Config = {}
Config.Schema = 1
Config.Build = "03 - PLUSHIE PARK"
Config.StudioSessionOnly = true -- Never touches live player data from Studio.
Config.PurchasesEnabled = false
Config.MaxPlayers = 4
Config.Storage = 40
Config.ShelfSlots = 8
Config.FreeAttempts = 3
Config.AttemptRefillSeconds = 12
Config.RoundSeconds = 25
Config.DropSeconds = 4.2
Config.PlotSpacing = 360
Config.Bounds = {halfWidth=150, back=-210, front=230}
Config.Machines = {
    {id="rusty", name="Rusty Claw", short="RUSTY", cost=0, color={233,157,92}, skin="workshop", mascot="duck", pool={"duck","mochi","frog"}},
    {id="classic", name="Classic Arcade", short="CLASSIC", cost=250, color={249,78,117}, skin="classic", mascot="mochi", pool={"mochi","frog","dino","cat","star"}},
    {id="candy", name="Candy Cloud", short="CANDY", cost=600, color={255,156,212}, skin="cloud", mascot="dino", pool={"mochi","dino","bloom"}},
    {id="pond", name="Frog Pond", short="POND", cost=1200, color={126,224,151}, skin="frog", mascot="frog", pool={"frog","bloom","bee"}},
    {id="bloom", name="Bunny Bloom", short="BLOOM", cost=2200, color={232,175,255}, skin="bunny", mascot="bloom", pool={"mochi","bloom","bee"}},
    {id="shark", name="Shark Splash", short="SHARK", cost=3800, color={74,172,244}, skin="shark", mascot="shark", pool={"frog","shark","pearl"}},
    {id="lucky", name="Lucky Cat", short="LUCKY", cost=6000, color={255,202,116}, skin="cat", mascot="cat", pool={"cat","bee","mimic"}},
    {id="honey", name="Honey Hive", short="HONEY", cost=9000, color={255,209,74}, skin="hive", mascot="bee", pool={"bee","bloom","leaf"}},
    {id="dino", name="Dino Den", short="DINO", cost=14000, color={147,211,107}, skin="dino", mascot="tricera", pool={"dino","tricera","leaf"}},
    {id="rocket", name="Rocket Rally", short="ROCKET", cost=21000, color={250,119,107}, skin="rocket", mascot="rocket", pool={"cat","rocket","ufo"}},
    {id="soda", name="Cherry Soda", short="SODA", cost=32000, color={255,109,160}, skin="soda", mascot="cherry", pool={"bloom","cherry","pixel"}},
    {id="ufo", name="Cosmic UFO", short="UFO", cost=48000, color={111,226,210}, skin="ufo", mascot="ufo", pool={"star","ufo","rocket"}},
    {id="pearl", name="Ocean Pearl", short="PEARL", cost=72000, color={168,206,255}, skin="shell", mascot="pearl", pool={"shark","pearl","penguin"}},
    {id="treasure", name="Treasure Chest", short="TREASURE", cost=110000, color={198,132,82}, skin="treasure", mascot="mimic", pool={"mimic","lion","cherry"}},
    {id="pixel", name="Pixel Party", short="PIXEL", cost=165000, color={157,130,255}, skin="pixel", mascot="pixel", pool={"pixel","robot","unicorn"}},
    {id="ice", name="Ice Palace", short="ICE", cost=250000, color={129,231,255}, skin="ice", mascot="penguin", pool={"penguin","gemfox","pearl"}},
    {id="magma", name="Magma Forge", short="MAGMA", cost=380000, color={255,129,76}, skin="magma", mascot="ember", pool={"ember","lion","rocket"}},
    {id="jungle", name="Jungle Ruins", short="JUNGLE", cost=570000, color={100,187,135}, skin="jungle", mascot="leaf", pool={"leaf","tricera","gemfox"}},
    {id="rainbow", name="Rainbow Parade", short="RAINBOW", cost=850000, color={255,145,212}, skin="rainbow", mascot="unicorn", pool={"unicorn","star","gemfox"}},
    {id="royal", name="Golden Crown", short="ROYAL", cost=1300000, color={255,213,81}, skin="crown", mascot="lion", pool={"lion","unicorn","mimic"}},
    {id="diamond", name="Diamond Vault", short="DIAMOND", cost=2000000, color={121,199,255}, skin="diamond", mascot="gemfox", pool={"gemfox","penguin","robot"}},
    {id="galaxy", name="Galaxy Gate", short="GALAXY", cost=3000000, color={153,128,241}, skin="galaxy", mascot="star", pool={"star","ufo","voidbat"}},
    {id="cyber", name="Cyber Circuit", short="CYBER", cost=4500000, color={81,229,203}, skin="circuit", mascot="robot", pool={"robot","pixel","voidbat"}},
    {id="void", name="Void Reactor", short="VOID", cost=6800000, color={121,92,201}, skin="void", mascot="voidbat", pool={"voidbat","star","infinity"}},
    {id="infinity", name="Infinity Carnival", short="INFINITY", cost=10000000, color={247,164,238}, skin="carnival", mascot="infinity", pool={"infinity","unicorn","voidbat"}},
}
-- Five spacious districts, with a 36-stud pedestrian avenue between cabinet rows.
Config.Districts = {"WELCOME WOODS","CRITTER COVE","CANDY COSMOS","DREAM GARDENS","INFINITY PLAZA"}
for i,machine in ipairs(Config.Machines) do
    machine.position={-104+((i-1)%5)*52,0,120-math.floor((i-1)/5)*72}
end
-- Pure deterministic choreography. This never decides or grants a reward.
function Config.clawPose(t,x,z,hasPrize)
    t=math.clamp(t,0,1)
    local function ease(v) v=math.clamp(v,0,1); return v*v*(3-2*v) end
    local y,grip,stage=15,0,"READY"
    if t<0.12 then
        y=15+math.sin(t/0.12*math.pi)*0.45; stage="WIND UP"
    elseif t<0.38 then
        y=15-5*ease((t-0.12)/0.26); stage="LOWER"
    elseif t<0.49 then
        y=10; grip=ease((t-0.38)/0.11); stage="GRAB"
    elseif t<0.73 then
        y=10+5*ease((t-0.49)/0.24); grip=1; stage="LIFT"
    elseif t<0.9 then
        local u=ease((t-0.73)/0.17); x=x+(4.1-x)*u; z=z+(4.1-z)*u
        grip=1; stage="TO CHUTE"
    else
        x,z=4.1,4.1; grip=1-ease((t-0.9)/0.08); stage=if hasPrize then "PRIZE!" else "TRY AGAIN"
    end
    return {x=x,y=y,z=z,grip=grip,stage=stage}
end
Config.Plushies = {
    {id="duck", name="Goofy Duck", rarity="Common", income=5, weight=60, color={255,219,79}, shape="duck"},
    {id="mochi", name="Mochi Bunny", rarity="Uncommon", income=8, weight=30, color={255,171,209}, shape="bunny"},
    {id="frog", name="Disco Frog", rarity="Rare", income=14, weight=10, color={113,239,176}, shape="frog"},
    {id="dino", name="Bubblegum Dino", rarity="Epic", income=24, weight=10, color={177,137,255}, shape="dino"},
    {id="cat", name="Space Cat", rarity="Legendary", income=40, weight=4, color={109,218,255}, shape="cat"},
    {id="star", name="Pocket Supernova", rarity="Mythical", income=65, weight=1, color={255,139,96}, shape="star"},
    {id="bloom", name="Petal Puff", rarity="Rare", income=18, weight=18, color={239,183,255}, shape="bunny"},
    {id="shark", name="Snack Shark", rarity="Rare", income=25, weight=20, color={103,183,250}, shape="shark"},
    {id="bee", name="Bumble Bean", rarity="Epic", income=35, weight=12, color={255,216,82}, shape="bee"},
    {id="tricera", name="Tiny Tricera", rarity="Epic", income=50, weight=12, color={157,224,143}, shape="dino"},
    {id="rocket", name="Booster Bean", rarity="Legendary", income=75, weight=10, color={250,141,122}, shape="cat"},
    {id="cherry", name="Cherry Cheeks", rarity="Epic", income=100, weight=12, color={255,128,171}, shape="cherry"},
    {id="ufo", name="Sleepy Saucer", rarity="Legendary", income=150, weight=8, color={117,232,203}, shape="ufo"},
    {id="pearl", name="Pearl Pudding", rarity="Legendary", income=220, weight=10, color={193,210,255}, shape="shell"},
    {id="mimic", name="Treasure Tater", rarity="Legendary", income=330, weight=8, color={225,163,87}, shape="chest"},
    {id="pixel", name="Pixel Pancake", rarity="Legendary", income=500, weight=10, color={185,155,255}, shape="robot"},
    {id="penguin", name="Frosty Waddle", rarity="Legendary", income=750, weight=10, color={151,227,255}, shape="penguin"},
    {id="ember", name="Ember Dumpling", rarity="Mythical", income=1100, weight=8, color={255,151,98}, shape="dino"},
    {id="leaf", name="Leafy Loaf", rarity="Mythical", income=1700, weight=8, color={135,209,126}, shape="frog"},
    {id="unicorn", name="Prism Pony", rarity="Mythical", income=2500, weight=6, color={255,183,232}, shape="unicorn"},
    {id="lion", name="Royal Roar", rarity="Mythical", income=3800, weight=8, color={255,211,99}, shape="lion"},
    {id="gemfox", name="Crystal Foxlet", rarity="Secret", income=5600, weight=5, color={154,209,255}, shape="cat"},
    {id="robot", name="Circuit Sprout", rarity="Secret", income=8500, weight=6, color={113,234,205}, shape="robot"},
    {id="voidbat", name="Midnight Marshmallow", rarity="Divine", income=13000, weight=3, color={168,133,230}, shape="bat"},
    {id="infinity", name="Infinity Sundae", rarity="Infinity", income=20000, weight=2, color={255,189,234}, shape="unicorn"},
}
Config.Upgrades = {
    speed={name="Servo speed", cost=60, max=4, description="Faster aim movement. Earned coins only."},
    shelves={name="Shelf multiplier", cost=90, max=4, description="+25% display income per level."},
}
Config.Catalog = {
    {id="rainbow_skin", name="Rainbow cabinet skin", kind="Pass", productId=0, benefit="One cosmetic cabinet skin. No random reward."},
    {id="confetti", name="Confetti party", kind="Product", productId=0, benefit="One deterministic cosmetic celebration."},
    {id="nameplate", name="VIP nameplate", kind="Pass", productId=0, benefit="One cosmetic nameplate. No gameplay odds change."},
}
Config.FutureTiers = {}
function Config.plushie(id)
    for _, item in ipairs(Config.Plushies) do if item.id == id then return item end end
    return nil
end
return Config
end]====]))()()
Economy=assert(loadstring([====[return function(Config,Big)
-- Pure, non-yielding state transitions. Server alone owns these records.
local Economy = {}
function Economy.new()
    return {schema=Config.Schema,coins=Big.new(0),bank=Big.new(0),machine=1,selected=1,
        inventory={},display={},discovered={},nextId=1,upgrades={speed=0,shelves=0},totalCatches=0}
end
function Economy.validate(s)
    if type(s)~="table" or s.schema~=Config.Schema or not Big.valid(s.coins) or not Big.valid(s.bank)
        or type(s.inventory)~="table" or #s.inventory>Config.Storage or type(s.display)~="table"
        or #s.display>Config.ShelfSlots or type(s.discovered)~="table" or type(s.upgrades)~="table"
        or type(s.machine)~="number" or s.machine%1~=0 or s.machine<1 or s.machine>#Config.Machines
        or type(s.nextId)~="number" or s.nextId%1~=0 or s.nextId<1 or s.nextId>1e12
        or type(s.totalCatches)~="number" or s.totalCatches%1~=0 or s.totalCatches<0 or s.totalCatches>1e12 then return false end
    if s.selected~=nil and (type(s.selected)~="number" or s.selected%1~=0 or s.selected<1 or s.selected>s.machine) then return false end
    for key, spec in pairs(Config.Upgrades) do
        local level=s.upgrades[key]
        if type(level)~="number" or level%1~=0 or level<0 or level>spec.max then return false end
    end
    local ids={}
    for _,item in ipairs(s.inventory) do
        if type(item)~="table" or type(item.id)~="number" or item.id%1~=0 or item.id<1
            or item.id>=s.nextId or ids[item.id] or not Config.plushie(item.species) then return false end
        ids[item.id]=true
    end
    local shown={}
    for _,id in ipairs(s.display) do if not ids[id] or shown[id] then return false end; shown[id]=true end
    local count=0
    for id,value in pairs(s.discovered) do
        count+=1
        if not Config.plushie(id) or value~=true or count>#Config.Plushies then return false end
    end
    return true
end
function Economy.roll(s,u)
    assert(type(u)=="number" and u==u and u>=0 and u<1, "invalid random sample")
    local machine=Config.Machines[Economy.selected(s)]
    local total=0
    for _,id in ipairs(machine.pool) do total+=Config.plushie(id).weight end
    local needle=u*total
    for _,id in ipairs(machine.pool) do
        needle-=Config.plushie(id).weight
        if needle<0 then return id end
    end
    return machine.pool[#machine.pool]
end
function Economy.selected(s) return s.selected or s.machine end
function Economy.select(s,index)
    if type(index)~="number" or index~=index or index%1~=0 or index<1 or index>s.machine then return false,"Unlock this machine first." end
    s.selected=index
    return true,"Selected "..Config.Machines[index].name
end
function Economy.grant(s,species)
    if #s.inventory>=Config.Storage then return false,"Storage full. Display your collection; more storage comes later." end
    if not Config.plushie(species) then return false,"Unknown plushie" end
    local item={id=s.nextId,species=species}
    s.nextId+=1; s.totalCatches+=1
    table.insert(s.inventory,item); s.discovered[species]=true
    return true,item
end
function Economy.display(s,id)
    if #s.display>=Config.ShelfSlots then return false,"All 8 shelf spaces are occupied." end
    for _,existing in ipairs(s.display) do if existing==id then return false,"Already displayed" end end
    for _,item in ipairs(s.inventory) do
        if item.id==id then table.insert(s.display,id); return true,"Plushie placed! Your shelf now earns coins." end
    end
    return false,"Not your plushie"
end
function Economy.stow(s,id)
    for i,shown in ipairs(s.display) do if shown==id then table.remove(s.display,i); return true,"Returned to storage" end end
    return false,"Not displayed"
end
function Economy.sell(s,id)
    for _,shown in ipairs(s.display) do if shown==id then return false,"Stow this plushie before selling it." end end
    for i,item in ipairs(s.inventory) do
        if item.id==id then
            local amount=Config.plushie(item.species).income*5
            table.remove(s.inventory,i); s.coins=Big.add(s.coins,Big.new(amount))
            return true,"Sold for $"..amount..". Your collection discovery is kept."
        end
    end
    return false,"Not your plushie"
end
function Economy.rate(s)
    local total=0
    for _,id in ipairs(s.display) do
        for _,item in ipairs(s.inventory) do
            if item.id==id then total+=Config.plushie(item.species).income; break end
        end
    end
    return Big.new(total*(1+0.25*s.upgrades.shelves))
end
function Economy.tick(s,seconds)
    assert(type(seconds)=="number" and seconds==seconds and seconds>=0 and seconds<=120,"invalid tick")
    s.bank=Big.add(s.bank,Big.mul(Economy.rate(s),seconds))
end
function Economy.collect(s)
    local amount=Big.copy(s.bank)
    s.coins=Big.add(s.coins,amount); s.bank=Big.new(0)
    return true,"Collected $"..Big.format(amount)
end
function Economy.unlock(s)
    local target=Config.Machines[s.machine+1]
    if not target then return false,"All 25 machines unlocked. Welcome to the Infinity Carnival!" end
    local cost=Big.new(target.cost)
    if Big.compare(s.coins,cost)<0 then return false,"Collect $"..Big.format(cost).." to unlock "..target.name end
    s.coins=Big.sub(s.coins,cost); s.machine+=1; s.selected=s.machine
    return true,target.name.." unlocked! New plushies are inside."
end
function Economy.upgrade(s,key)
    local spec=Config.Upgrades[key]
    if not spec then return false,"Unknown upgrade" end
    local level=s.upgrades[key]
    if level>=spec.max then return false,"Maximum level" end
    local cost=Big.new(spec.cost*2^level)
    if Big.compare(s.coins,cost)<0 then return false,"You need $"..Big.format(cost)..". Collect your shelf income." end
    s.coins=Big.sub(s.coins,cost); s.upgrades[key]+=1
    return true,spec.name.." upgraded!"
end
return Economy
end]====]))()(Config,Big)
ProfileStore=assert(loadstring([====[return function(Economy)
-- Injected backend: UpdateAsync(key, transform). All calls per session are serialized.
local Store={}
Store.__index=Store
local function copy(t)
    if type(t)~="table" then return t end
    local out={}; for k,v in pairs(t) do out[k]=copy(v) end; return out
end
Store.copy=copy
function Store.new(backend,clock)
    return setmetatable({backend=backend,clock=clock or os.time,lease=180},Store)
end
function Store:load(key,token)
    local now=self.clock()
    local ok,record=pcall(function()
        return self.backend:UpdateAsync(key,function(old)
            if old~=nil and (type(old)~="table" or not Economy.validate(old.data)) then return nil end
            if old and old.lock and (type(old.lock)~="table" or type(old.lock.expires)~="number"
                or (old.lock.expires>now and old.lock.id~=token)) then return nil end
            return {data=if old then old.data else Economy.new(),lock={id=token,expires=now+self.lease}}
        end)
    end)
    if not ok then return nil,"Data service unavailable. Your saved arcade was not replaced." end
    if not record or not record.lock or record.lock.id~=token then return nil,"Profile busy or needs recovery. Please rejoin shortly." end
    return {key=key,token=token,data=copy(record.data),expires=record.lock.expires,saving=false,closed=false}
end
function Store:save(session,release)
    if session.closed or session.saving then return false,"busy" end
    session.saving=true
    local now=self.clock(); local snapshot=copy(session.data)
    if not Economy.validate(snapshot) then session.saving=false; return false,"invalid profile" end
    local ok,record=pcall(function()
        return self.backend:UpdateAsync(session.key,function(old)
            if not old or not old.lock or old.lock.id~=session.token or old.lock.expires<=now then return nil end
            return {data=snapshot,lock=if release then nil else {id=session.token,expires=now+self.lease}}
        end)
    end)
    session.saving=false
    -- UpdateAsync returns nil when a callback cancels. Never treat that as a save.
    if not ok or not record or (not release and (not record.lock or record.lock.id~=session.token)) then return false,"save failed or session ownership lost" end
    session.expires=now+self.lease; session.closed=release==true
    return true
end
return Store
end]====]))()(Economy)
return assert(loadstring([====[return function(Big,Config,Economy,ProfileStore)
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
check(Config.Bounds.halfWidth*2*(Config.Bounds.front-Config.Bounds.back)>=132000,"park floor area")
equal(#Config.Districts,5,"districts")
for _,machine in ipairs(Config.Machines) do
 check(math.abs(machine.position[1])+10<Config.Bounds.halfWidth,"machine within horizontal bounds")
 check(machine.position[3]-12>Config.Bounds.back and machine.position[3]+16<Config.Bounds.front,"machine within depth bounds")
end
for n=0,100 do
 local pose=Config.clawPose(n/100,0,0,true)
 check(pose.y>=10 and pose.y<=15.5,"claw vertical envelope")
 check(pose.grip>=0 and pose.grip<=1,"finger envelope")
end
near(Config.clawPose(0,0,0,true).y,15,"rest height")
near(Config.clawPose(.4,0,0,true).y,10,"grip height")
near(Config.clawPose(.8,0,0,true).grip,1,"carry closed")
near(Config.clawPose(1,0,0,true).grip,0,"release opened")
equal(Config.clawPose(1,0,0,true).stage,"PRIZE!","catch stage")
equal(Config.clawPose(1,0,0,false).stage,"TRY AGAIN","miss stage")
return "CONTRACTS_PASS checks="..count.." machines=25 silhouettes=25 pools=25 legacy=compatible purchases=disabled"

end]====]))()(Big,Config,Economy,ProfileStore)
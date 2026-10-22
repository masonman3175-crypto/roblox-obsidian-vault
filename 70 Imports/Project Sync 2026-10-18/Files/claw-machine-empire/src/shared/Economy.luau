-- Pure, non-yielding state transitions. Server alone owns these records.
local Config = require(script.Parent.Config)
local Big = require(script.Parent.BigNumber)
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

-- Generated from src by tools/build.py. Run in Studio EDIT Command Bar.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before installing")
assert(not game.ReplicatedStorage:FindFirstChild("ClawEmpire"),"ClawEmpire already installed; use UPDATE or rollback first")
assert(not game.ServerScriptService:FindFirstChild("ClawEmpire"),"Server namespace occupied")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("ClawEmpireClient"),"Client namespace occupied")
local src={}
src["Config"]=[====[-- Build 03: spacious plushie park, deterministic crane choreography, simple toy UI.
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
]====]
src["BigNumber"]=[====[-- Non-negative scientific values. ~15 significant digits, NOT exact accounting.
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
]====]
src["Economy"]=[====[-- Pure, non-yielding state transitions. Server alone owns these records.
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
]====]
src["World"]=[====[-- Hand-authored parts, cabinet silhouettes and toybox architecture. No Toolbox assets.
local Config=require(game.ReplicatedStorage.ClawEmpire.Shared.Config)
local Big=require(game.ReplicatedStorage.ClawEmpire.Shared.BigNumber)
local TweenService=game:GetService("TweenService")
local World={}
local C={ink=Color3.fromRGB(67,47,94),pink=Color3.fromRGB(244,167,211),lilac=Color3.fromRGB(174,163,231),
    mint=Color3.fromRGB(134,237,197),gold=Color3.fromRGB(255,218,103),white=Color3.fromRGB(255,250,242),
    blue=Color3.fromRGB(151,205,250),rose=Color3.fromRGB(248,111,166)}
local function rgb(t) return Color3.fromRGB(table.unpack(t)) end
local function part(parent,name,size,pos,color,material,shape)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
    p.Color=color; p.Material=material or Enum.Material.Plastic
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent; return p
end
local function cylinder(parent,name,size,pos,color,axis)
    local p=part(parent,name,size,pos,color,nil,Enum.PartType.Cylinder)
    p.Orientation=if axis=="z" then Vector3.new(0,90,0) else Vector3.new(0,0,90)
    return p
end
local function sign(parent,name,size,pos,value,bg,fg,face)
    local p=part(parent,name,size,pos,bg)
    local gui=Instance.new("SurfaceGui"); gui.Name="Sign"; gui.Face=face or Enum.NormalId.Back
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=32; gui.Parent=p
    local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
    label.Text=value; label.TextColor3=fg or C.white; label.Font=Enum.Font.FredokaOne
    label.TextScaled=true; label.TextStrokeColor3=C.ink; label.TextStrokeTransparency=0.15; label.Parent=gui
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0.04,0); pad.PaddingRight=UDim.new(0.04,0); pad.Parent=label
    return p,label
end
local function beam(parent,name,a,b,width,color)
    local p=part(parent,name,Vector3.new(width,width,(b-a).Magnitude),(a+b)/2,color)
    p.CFrame=CFrame.lookAt((a+b)/2,b); return p
end
local function folder(parent,name)
    local f=Instance.new("Model"); f.Name=name; f.Parent=parent; return f
end
function World.plush(parent,species,pos,scale,simple)
    scale=scale or 1
    local item=Config.plushie(species); local col=rgb(item.color)
    local model=Instance.new("Model"); model.Name=item.name; model:SetAttribute("Species",species)
    local function ball(n,s,v,c)
        local p=part(model,n,s*scale,pos+v*scale,c or col,nil,Enum.PartType.Ball); p.CanCollide=false; return p
    end
    local function block(n,s,v,c)
        local p=part(model,n,s*scale,pos+v*scale,c or col); p.CanCollide=false; return p
    end
    local body=ball("SoftBody",Vector3.new(2.2,2.2,1.8),Vector3.zero)
    if item.shape=="robot" or item.shape=="chest" then body.Shape=Enum.PartType.Block; body.Size=Vector3.new(2,1.8,1.6)*scale end
    if not simple then
        ball("CreamBelly",Vector3.new(1.45,1.3,0.25),Vector3.new(0,-0.25,0.82),C.white)
        for _,x in ipairs({-0.5,0.5}) do
            ball("Blush",Vector3.new(0.3,0.16,0.06),Vector3.new(x*1.45,0.03,0.94),C.rose)
            ball("Foot",Vector3.new(0.6,0.45,0.75),Vector3.new(x,-0.9,0.25))
        end
    end
    for _,x in ipairs({-0.48,0.48}) do ball("ButtonEye",Vector3.new(0.22,0.28,0.12),Vector3.new(x,0.3,0.94),C.ink) end
    ball("Smile",Vector3.new(0.24,0.12,0.1),Vector3.new(0,0.02,1),C.ink)
    local shape=item.shape
    if shape=="bunny" then
        for _,x in ipairs({-0.55,0.55}) do ball("Ear",Vector3.new(0.55,1.8,0.6),Vector3.new(x,1.35,0)) end
    elseif shape=="duck" or shape=="penguin" then
        ball("Beak",Vector3.new(0.6,0.28,0.5),Vector3.new(0,0.03,1.05),C.gold)
        if shape=="duck" then ball("Tuft",Vector3.new(0.4,0.55,0.4),Vector3.new(0,1,0)) end
    elseif shape=="frog" then
        for _,x in ipairs({-0.7,0.7}) do ball("EyeBulge",Vector3.new(0.8,0.8,0.7),Vector3.new(x,0.8,0.1)) end
    elseif shape=="cat" or shape=="bat" then
        for _,x in ipairs({-0.8,0.8}) do
            local ear=block("Ear",Vector3.new(0.65,0.85,0.6),Vector3.new(x,1,0)); ear.Orientation=Vector3.new(0,0,x*24)
            if shape=="bat" then ball("Wing",Vector3.new(1.5,0.65,0.3),Vector3.new(x*1.8,0.2,0),C.lilac) end
        end
    elseif shape=="dino" then
        for i=1,3 do ball("Spike",Vector3.new(0.55,0.7,0.5),Vector3.new(0,1.05-(i-1)*0.3,-(i-1)*0.4),C.mint) end
    elseif shape=="shark" then
        local fin=block("DorsalFin",Vector3.new(0.3,1.1,0.8),Vector3.new(0,1,0)); fin.Orientation=Vector3.new(25,0,0)
        block("SharkMouth",Vector3.new(1.2,0.24,0.15),Vector3.new(0,-0.18,0.99),C.white)
    elseif shape=="bee" then
        for _,x in ipairs({-1.05,1.05}) do ball("Wing",Vector3.new(0.8,1.2,0.3),Vector3.new(x,0.35,-0.2),C.white) end
        block("BeeStripe",Vector3.new(2.12,0.3,0.15),Vector3.new(0,-0.32,0.88),C.ink)
    elseif shape=="ufo" or shape=="shell" then
        ball("Rim",Vector3.new(2.8,0.45,2),Vector3.new(0,-0.4,0),C.mint)
    elseif shape=="cherry" then
        block("Stem",Vector3.new(0.16,0.7,0.16),Vector3.new(0,1.25,0),C.mint)
        ball("Leaf",Vector3.new(0.7,0.2,0.4),Vector3.new(0.3,1.4,0),C.mint)
    elseif shape=="unicorn" then
        local horn=block("Horn",Vector3.new(0.35,1.1,0.35),Vector3.new(0,1.3,0),C.gold); horn.Orientation=Vector3.new(0,0,12)
        for _,x in ipairs({-0.7,0.7}) do ball("Ear",Vector3.new(0.45,0.65,0.45),Vector3.new(x,0.9,0)) end
    elseif shape=="lion" then
        for i=1,7 do local a=i*math.pi*2/7; ball("Mane",Vector3.new(0.65,0.65,0.4),Vector3.new(math.sin(a)*1.05,math.cos(a)*1.05,-0.1),C.gold) end
    elseif shape=="robot" then
        block("Antenna",Vector3.new(0.1,0.65,0.1),Vector3.new(0,1.1,0),C.ink)
        ball("Signal",Vector3.new(0.4,0.4,0.4),Vector3.new(0,1.5,0),C.rose)
    elseif shape=="chest" then
        block("GoldLatch",Vector3.new(0.4,0.6,0.2),Vector3.new(0,-0.5,0.9),C.gold)
    else
        for i=1,5 do local a=i*math.pi*2/5; ball("StarPoint",Vector3.new(0.65,0.8,0.6),Vector3.new(math.sin(a),math.cos(a),0),C.gold) end
    end
    model.PrimaryPart=body; model.Parent=parent; return model
end

-- Twenty-five separately authored crown/trim assemblies. Shared playable mechanics,
-- different actual geometry, not random accessories or a palette-only variation.
local skins={}
function skins.workshop(p,b)
    p("CrankBase",Vector3.new(1.2,2,1),Vector3.new(6.7,5,0),C.ink)
    p("CrankArm",Vector3.new(0.3,3,0.3),Vector3.new(7.4,6,0),C.gold)
    for _,x in ipairs({-4.5,4.5}) do p("PatchPlate",Vector3.new(2.1,1.6,0.25),Vector3.new(x,2.5,5.8),C.gold) end
    for x=-4,4,2 do b("RoofBolt",Vector3.new(0.55,0.55,0.55),Vector3.new(x,20,0),C.ink) end
end
function skins.classic(p,b)
    for x=-5,5,2 do p("CandyStripe",Vector3.new(0.8,3.6,0.15),Vector3.new(x,3.4,5.85),C.white) end
    for x=-5,5,2 do b("MarqueeBulb",Vector3.new(0.6,0.6,0.5),Vector3.new(x,20,5.5),C.gold) end
    p("ScoreTower",Vector3.new(5,2,2),Vector3.new(0,21,0),C.gold)
end
function skins.cloud(p,b)
    for i=-2,2 do b("CloudPuff",Vector3.new(3.4,3.5-math.abs(i)*0.3,3),Vector3.new(i*2.1,20.3,0),C.white) end
    for _,x in ipairs({-6.6,6.6}) do p("CandyCane",Vector3.new(0.55,9,0.55),Vector3.new(x,11,5),C.rose) end
end
function skins.frog(p,b)
    b("FrogHead",Vector3.new(11,3.5,6),Vector3.new(0,20,0),C.mint)
    for _,x in ipairs({-3.5,3.5}) do
        b("FrogEye",Vector3.new(3.2,3.2,2.5),Vector3.new(x,22,0.8),C.mint)
        b("FrogPupil",Vector3.new(1,1.4,0.3),Vector3.new(x,22.2,2),C.ink)
    end
    p("LilyPad",Vector3.new(5,0.25,3),Vector3.new(0,1.3,7),C.mint)
end
function skins.bunny(p,b)
    for _,x in ipairs({-3.1,3.1}) do
        b("BunnyEar",Vector3.new(2.4,7,2.5),Vector3.new(x,22.5,0),C.white)
        b("EarInset",Vector3.new(1.1,4.8,0.2),Vector3.new(x,22.8,1.2),C.pink)
    end
    for _,x in ipairs({-4,4}) do b("FlowerPetal",Vector3.new(2,2,0.3),Vector3.new(x,3,6),C.pink) end
end
function skins.shark(p,b)
    local fin=p("DorsalFin",Vector3.new(0.7,5,4),Vector3.new(0,21.3,-1),C.blue); fin.Orientation=Vector3.new(25,0,0)
    for x=-5,5,2 do local tooth=p("SharkTooth",Vector3.new(0.9,1.6,0.8),Vector3.new(x,16.7,5.9),C.white); tooth.Orientation=Vector3.new(0,0,45) end
    for _,x in ipairs({-4.5,4.5}) do b("SharkEye",Vector3.new(1.3,1.3,0.3),Vector3.new(x,20,5.5),C.ink) end
end
function skins.cat(p,b)
    for _,x in ipairs({-4.7,4.7}) do local ear=p("CatEar",Vector3.new(2.8,3.8,2.5),Vector3.new(x,21.3,0),C.gold); ear.Orientation=Vector3.new(0,0,x*4) end
    b("Bell",Vector3.new(1.6,1.6,1),Vector3.new(0,3.8,6),C.gold)
    for _,x in ipairs({-3.3,3.3}) do for y=2,4 do p("Whisker",Vector3.new(2,0.12,0.2),Vector3.new(x,y,5.9),C.white) end end
end
function skins.hive(p,b)
    for y=2,5 do p("BeeStripe",Vector3.new(12.5,0.4,0.12),Vector3.new(0,y,5.8),C.ink) end
    for _,x in ipairs({-3.5,3.5}) do p("Antenna",Vector3.new(0.3,3,0.3),Vector3.new(x,21,0),C.ink); b("AntennaBall",Vector3.new(1.4,1.4,1.4),Vector3.new(x,23,0),C.gold) end
    for _,x in ipairs({-7,7}) do b("Wing",Vector3.new(2.4,5,0.6),Vector3.new(x,16,-1),C.white) end
end
function skins.dino(p,b)
    for z=-4,4,2 do local s=p("DinoSpine",Vector3.new(1,2.6,1.6),Vector3.new(0,21,z),C.gold); s.Orientation=Vector3.new(20,0,0) end
    b("DinoTail",Vector3.new(2,2,6),Vector3.new(0,3,-7),C.mint)
    for _,x in ipairs({-4.5,4.5}) do b("DinoNostril",Vector3.new(0.6,0.8,0.3),Vector3.new(x,20,5.7),C.ink) end
end
function skins.rocket(p,b)
    p("RocketTower",Vector3.new(3.4,5,3.4),Vector3.new(0,21,0),C.white)
    local nose=p("RocketNose",Vector3.new(2.8,2.8,2.8),Vector3.new(0,24,0),C.rose); nose.Orientation=Vector3.new(0,0,45)
    for _,x in ipairs({-3.8,3.8}) do local wing=p("RocketFin",Vector3.new(2,3.6,3),Vector3.new(x,19,0),C.rose); wing.Orientation=Vector3.new(0,0,x*6) end
    b("Porthole",Vector3.new(1.6,1.6,0.3),Vector3.new(0,21,1.8),C.blue)
end
function skins.soda(p,b)
    p("CanLid",Vector3.new(12,0.35,10),Vector3.new(0,20,0),C.white)
    local straw=p("DrinkingStraw",Vector3.new(0.6,6,0.6),Vector3.new(3,22,0),C.rose); straw.Orientation=Vector3.new(0,0,-15)
    b("Cherry",Vector3.new(3.3,3.3,3.3),Vector3.new(-2.6,21,0),C.rose)
    p("CherryStem",Vector3.new(0.2,2,0.2),Vector3.new(-2.6,23,0),C.mint)
    for x=-4,4,2 do b("SodaBubble",Vector3.new(0.6,0.6,0.2),Vector3.new(x,3+x%3,5.9),C.white) end
end
function skins.ufo(p,b)
    b("Saucer",Vector3.new(16,1.5,12),Vector3.new(0,20,0),C.mint)
    b("AlienCockpit",Vector3.new(6,4,5),Vector3.new(0,21,0),C.blue)
    for x=-5,5,2 do b("SaucerLight",Vector3.new(0.7,0.7,0.7),Vector3.new(x,19.7,5.5),C.gold) end
end
function skins.shell(p,b)
    for i=-3,3 do local rib=p("ShellRib",Vector3.new(1.5,6-math.abs(i)*0.7,1.6),Vector3.new(i*1.6,21-math.abs(i)*0.2,0),if i%2==0 then C.pink else C.white); rib.Orientation=Vector3.new(0,0,-i*12) end
    b("GiantPearl",Vector3.new(2.3,2.3,2.3),Vector3.new(0,20.5,2),C.white)
end
function skins.treasure(p,b)
    b("ChestLid",Vector3.new(13.5,4,10),Vector3.new(0,20,0),Color3.fromRGB(192,127,78))
    for _,x in ipairs({-4,4}) do p("GoldStrap",Vector3.new(0.65,4,10.5),Vector3.new(x,19,0),C.gold) end
    p("ChestLock",Vector3.new(1.5,2,0.6),Vector3.new(0,19,5.6),C.gold)
end
function skins.pixel(p,b)
    for x=-2,2 do for y=0,2 do if (x+y)%2==0 then p("PixelCrown",Vector3.new(1.5,1.5,1.5),Vector3.new(x*1.7,20+y*1.5,0),if y%2==0 then C.mint else C.rose) end end end
    p("DpadVertical",Vector3.new(0.5,2.1,0.3),Vector3.new(-3.8,3.4,6),C.ink)
    p("DpadHorizontal",Vector3.new(2.1,0.5,0.3),Vector3.new(-3.8,3.4,6),C.ink)
end
function skins.ice(p,b)
    for i=-2,2 do local ice=p("CrystalSpire",Vector3.new(1.5,5-math.abs(i),1.5),Vector3.new(i*2.2,21,0),C.blue); ice.Orientation=Vector3.new(0,0,i*10) end
    for _,x in ipairs({-6.8,6.8}) do p("Icicle",Vector3.new(0.4,10,0.4),Vector3.new(x,11,0),C.white) end
end
function skins.magma(p,b)
    for _,x in ipairs({-4,4}) do p("Chimney",Vector3.new(2.6,5,2.8),Vector3.new(x,21,0),C.ink); b("Ember",Vector3.new(2,2,2),Vector3.new(x,24,0),C.gold) end
    for i=-2,2 do local crack=p("LavaCrack",Vector3.new(0.25,3.2,0.18),Vector3.new(i*2,3.5,6),C.gold); crack.Orientation=Vector3.new(0,0,i*17) end
end
function skins.jungle(p,b)
    p("StoneLintel",Vector3.new(14.5,2.4,10),Vector3.new(0,20,0),Color3.fromRGB(157,174,153))
    for _,x in ipairs({-6.6,6.6}) do p("Vine",Vector3.new(0.4,15,0.4),Vector3.new(x,12,5),C.mint); for y=7,18,4 do b("Leaf",Vector3.new(2,0.6,1),Vector3.new(x,y,5.3),C.mint) end end
end
function skins.rainbow(p,b)
    local colors={C.rose,C.gold,C.mint,C.blue,C.lilac}
    for i=1,5 do
        p("RainbowStep",Vector3.new(13-i*1.5,0.7,3.5),Vector3.new(0,19.6+i*0.7,0),colors[i])
        b("RainbowCloud",Vector3.new(2.6,2,3),Vector3.new(-6+i*0.25,19.5,0),C.white)
    end
end
function skins.crown(p,b)
    p("CrownBand",Vector3.new(12,1.7,5),Vector3.new(0,20,0),C.gold)
    for x=-4,4,2 do local t=p("CrownPoint",Vector3.new(1.5,3,1.5),Vector3.new(x,22,0),C.gold); t.Orientation=Vector3.new(0,0,45); b("CrownJewel",Vector3.new(0.7,0.9,0.35),Vector3.new(x,20.2,2.6),C.rose) end
end
function skins.diamond(p,b)
    local gem=p("Diamond",Vector3.new(4.5,4.5,4.5),Vector3.new(0,22,0),C.blue); gem.Orientation=Vector3.new(0,45,45)
    for _,x in ipairs({-4.8,4.8}) do p("VaultBar",Vector3.new(0.5,4,0.6),Vector3.new(x,3.5,6),C.white) end
    p("VaultLock",Vector3.new(2.1,2.1,0.5),Vector3.new(0,3.4,6),C.white)
end
function skins.galaxy(p,b)
    for i=1,10 do local a=i*math.pi*2/10; b("GalaxyOrbit",Vector3.new(1.4,1.4,1.4),Vector3.new(math.sin(a)*5.2,21+math.cos(a)*3.3,0),if i%2==0 then C.gold else C.blue) end
    b("GalaxyPlanet",Vector3.new(3,3,3),Vector3.new(0,21,0),C.rose)
end
function skins.circuit(p,b)
    for i=-2,2 do p("CircuitTrace",Vector3.new(0.15,3.7,0.2),Vector3.new(i*2,3.5,6),C.mint); b("CircuitNode",Vector3.new(0.65,0.65,0.25),Vector3.new(i*2,5.1,6),C.gold) end
    for _,x in ipairs({-4,4}) do p("Aerial",Vector3.new(0.4,4,0.4),Vector3.new(x,21,0),C.ink); b("SignalOrb",Vector3.new(1.4,1.4,1.4),Vector3.new(x,23.5,0),C.mint) end
end
function skins.void(p,b)
    for i=1,8 do local a=i*math.pi/4; local seg=p("ReactorRing",Vector3.new(1.8,0.8,1.5),Vector3.new(math.sin(a)*4.5,21+math.cos(a)*3,0),C.lilac); seg.Orientation=Vector3.new(0,0,-i*45) end
    b("ReactorCore",Vector3.new(3.2,3.2,3.2),Vector3.new(0,21,0),C.rose)
    p("ReactorPedestal",Vector3.new(4,0.3,5),Vector3.new(0,1.4,6),C.lilac)
end
function skins.carnival(p,b)
    for i=-2,2 do p("CarouselStripe",Vector3.new(2.5,1.2,10.8),Vector3.new(i*2.5,20,0),({C.pink,C.gold,C.mint,C.blue,C.lilac})[i+3]) end
    for _,x in ipairs({-5,5}) do p("FinialStem",Vector3.new(0.4,3.5,0.4),Vector3.new(x,22,0),C.gold); b("Finial",Vector3.new(1.8,1.8,1.8),Vector3.new(x,24,0),C.gold) end
    p("InfinityLeft",Vector3.new(3.3,1.1,1),Vector3.new(-1.7,23,0),C.white).Orientation=Vector3.new(0,0,35)
    p("InfinityRight",Vector3.new(3.3,1.1,1),Vector3.new(1.7,23,0),C.white).Orientation=Vector3.new(0,0,-35)
end

local function cabinet(parent,origin,index)
    local spec=Config.Machines[index]; local color=rgb(spec.color)
    local model=folder(parent,spec.id); model:SetAttribute("MachineIndex",index); model:SetAttribute("Skin",spec.skin)
    local function p(n,s,v,c,m)
        local obj=part(model,n,s,origin+v,c or color,m)
        if v.Y>=17.5 then obj:SetAttribute("AimOccluder",true) end
        return obj
    end
    local function b(n,s,v,c) local obj=p(n,s,v,c); obj.Shape=Enum.PartType.Ball; return obj end
    p("Plinth",Vector3.new(14,0.8,13),Vector3.new(0,0.6,0),C.ink)
    p("BaseTrim",Vector3.new(13.5,0.25,12.4),Vector3.new(0,1.15,0),C.white)
    p("LowerCabinet",Vector3.new(12.5,4.8,11.3),Vector3.new(0,3.7,0),color).TopSurface=Enum.SurfaceType.Studs
    p("PrizeBed",Vector3.new(11.6,0.4,10.5),Vector3.new(0,6.3,0),C.white)
    p("CabinetBack",Vector3.new(12,11.4,0.3),Vector3.new(0,12,-5.5),color:Lerp(C.white,0.65))
    for _,x in ipairs({-6,6}) do
        for _,z in ipairs({-5.5,5.5}) do
            p("Frame",Vector3.new(0.55,12,0.55),Vector3.new(x,12,z),C.white)
            p("LED",Vector3.new(0.14,11.5,0.14),Vector3.new(x,12,z+0.3),C.gold,Enum.Material.Neon)
        end
        local glass=p("SideGlass",Vector3.new(0.1,10.8,10.5),Vector3.new(x,12,0),C.blue,Enum.Material.Glass)
        glass.Transparency=0.88; glass.CanCollide=false
    end
    p("TopCapOutline",Vector3.new(13.5,1.3,12),Vector3.new(0,18.3,0),C.white)
    p("TopCap",Vector3.new(13,0.7,11.6),Vector3.new(0,19.2,0),color)
    local header=sign(model,"Header",Vector3.new(12.6,1.65,0.3),origin+Vector3.new(0,18.4,6.1),string.upper(spec.name),color)
    header:SetAttribute("AimOccluder",true)
    sign(model,"NumberPlate",Vector3.new(1.8,1.1,0.2),origin+Vector3.new(-4.7,1.9,5.9),string.format("%02d",index),C.white,C.ink)
    sign(model,"Instructions",Vector3.new(9.5,0.9,0.2),origin+Vector3.new(0,5.3,5.9),"AIM  /  DROP  /  COLLECT",C.ink,C.white)
    p("ControlDeck",Vector3.new(12,0.45,3),Vector3.new(0,6.1,6.4),C.white)
    p("Joystick",Vector3.new(0.18,0.8,0.18),Vector3.new(-2.5,6.7,6.4),C.ink)
    b("JoystickBall",Vector3.new(0.75,0.75,0.75),Vector3.new(-2.5,7.2,6.4),color)
    local drop=cylinder(model,"DropButton",Vector3.new(0.25,1.3,1.3),origin+Vector3.new(2.5,6.5,6.4),C.mint)
    local prompt=Instance.new("ProximityPrompt"); prompt.Name="Operate"; prompt.ActionText=if index==1 then "Play free" else "Unlock $"..Big.format(Big.new(spec.cost))
    prompt.ObjectText=spec.name; prompt.MaxActivationDistance=14; prompt.RequiresLineOfSight=false
    prompt.HoldDuration=0.2; prompt.Parent=drop
    skins[spec.skin](p,b)
    p("CarriageRail",Vector3.new(10.8,0.16,0.16),Vector3.new(0,17.3,0),C.ink)
    local claw=folder(model,"Claw")
    local head=part(claw,"Head",Vector3.new(1.4,0.7,1.4),origin+Vector3.new(0,15,0),C.gold,Enum.Material.Metal)
    for i=1,3 do
        part(claw,"Finger"..i,Vector3.new(0.2,1.45,0.24),head.Position,C.white,Enum.Material.Metal).CanCollide=false
        part(claw,"Tip"..i,Vector3.new(0.22,0.65,0.3),head.Position,C.gold,Enum.Material.Metal).CanCollide=false
    end
    claw.PrimaryPart=head
    local cable=part(model,"CraneCable",Vector3.new(0.09,2,0.09),origin+Vector3.new(0,16.4,0),C.ink); cable.CanCollide=false
    local carriage=part(model,"Carriage",Vector3.new(1.8,0.45,1.8),origin+Vector3.new(0,17.1,0),C.mint); carriage.CanCollide=false
    p("PrizeChute",Vector3.new(2.6,0.2,2.6),Vector3.new(4.1,6.65,4.1),C.ink)
    local prizes=folder(model,"Prizes")
    for i,v in ipairs({Vector3.new(-3,7.5,-1.5),Vector3.new(0,7.5,1.5),Vector3.new(3,7.5,-1.5)}) do
        World.plush(prizes,if i==2 then spec.mascot else spec.pool[i%#spec.pool+1],origin+v,0.85,true)
    end
    local _,status=sign(model,"Status",Vector3.new(8.4,1.6,0.2),origin+Vector3.new(0,3.3,5.9),if index==1 then "FREE PLAYS!" else "$"..Big.format(Big.new(spec.cost)),C.white,C.ink)
    return {root=model,origin=origin,claw=claw,cable=cable,carriage=carriage,prizes=prizes,status=status,prompt=prompt}
end

local function architecture(root,offset)
    local floor=folder(root,"HandbuiltStudFloor")
    part(floor,"Foundation",Vector3.new(300,1,440),offset+Vector3.new(0,-0.5,10),C.lilac)
    for ix=0,14 do
        for iz=0,21 do
            local district=math.clamp(math.floor((iz*20)/72),0,4)
            local color=({C.lilac,C.blue,C.pink,C.mint,C.pink})[district+1]
            local tile=part(floor,"StuddedTile",Vector3.new(19.93,0.4,19.93),
                offset+Vector3.new(-140+ix*20,0.2,-200+iz*20),if (ix+iz)%2==0 then color else color:Lerp(C.white,0.23))
            tile.TopSurface=Enum.SurfaceType.Studs
        end
        if ix%5==0 then task.wait() end
    end
    -- White/gold avenues create readable, wide routes through the expanded park.
    for row=0,5 do
        local z=156-row*72
        local path=part(floor,"Promenade",Vector3.new(292,0.12,15),offset+Vector3.new(0,0.46,z),C.white)
        path.TopSurface=Enum.SurfaceType.Studs
        for _,dz in ipairs({-8,8}) do
            part(floor,"PromenadeEdge",Vector3.new(292,0.16,0.5),offset+Vector3.new(0,0.5,z+dz),C.gold)
        end
        for x=-140,140,10 do
            cylinder(floor,"RaisedFloorStud",Vector3.new(0.16,0.85,0.85),offset+Vector3.new(x,0.53,z+10),C.white)
        end
    end
    local walls=folder(root,"HandbuiltStudWalls")
    for _,side in ipairs({-1,1}) do
        for iz=0,10 do
            local z=-190+iz*40
            local w=part(walls,"SideWallPanel",Vector3.new(1.4,34,39.8),offset+Vector3.new(side*150,17,z),if iz%2==0 then C.lilac else C.pink)
            w[if side<0 then "RightSurface" else "LeftSurface"]=Enum.SurfaceType.Studs
            part(walls,"Pillar",Vector3.new(2.5,35,2.5),offset+Vector3.new(side*149,17.5,z-20),C.white)
            part(walls,"Cornice",Vector3.new(2,1,40),offset+Vector3.new(side*149,34,z),C.white)
            for _,y in ipairs({6,16,26}) do for dz=-12,12,12 do
                part(walls,"RaisedWallStud",Vector3.new(0.5,1,1),offset+Vector3.new(side*149,y,z+dz),C.white, nil,Enum.PartType.Cylinder)
            end end
            beam(walls,"CrossBrace",offset+Vector3.new(side*148.5,3,z-16),offset+Vector3.new(side*148.5,30,z+16),0.6,C.white)
            beam(walls,"CrossBrace",offset+Vector3.new(side*148.5,30,z-16),offset+Vector3.new(side*148.5,3,z+16),0.6,C.white)
        end
    end
    for i=0,9 do
        local x=-135+i*30
        for _,z in ipairs({-210,230}) do
            if z<0 or math.abs(x)>31 then
                local w=part(walls,"EndWallPanel",Vector3.new(29.8,34,1.4),offset+Vector3.new(x,17,z),C.lilac)
                w.BackSurface=Enum.SurfaceType.Studs; w.FrontSurface=Enum.SurfaceType.Studs
                part(walls,"EndPillar",Vector3.new(2,35,2),offset+Vector3.new(x-15,17.5,z),C.white)
            end
        end
    end
    sign(walls,"MainMarquee",Vector3.new(90,7,0.4),offset+Vector3.new(0,27,-208),"PLUSHIE PARK",C.rose)
    for row=1,5 do
        local z=143-(row-1)*72
        for _,x in ipairs({-141,141}) do
            part(walls,"DistrictColumn",Vector3.new(2,31,2),offset+Vector3.new(x,15.5,z),C.white)
            cylinder(walls,"ColumnButton",Vector3.new(0.6,3,3),offset+Vector3.new(x,31,z),C.gold)
        end
        part(walls,"DistrictArch",Vector3.new(284,0.7,1.3),offset+Vector3.new(0,30,z),C.white)
        sign(walls,"DistrictName",Vector3.new(40,3.5,0.3),offset+Vector3.new(0,29,z),Config.Districts[row],({C.rose,C.blue,C.lilac,C.mint,C.rose})[row])
    end
end
local function decorations(root,offset)
    offset+=Vector3.new(0,0,100)
    local decor=folder(root,"HandmadeDecorations")
    local function p(n,s,v,c,m,shape) return part(decor,n,s,offset+v,c,m,shape) end
    local function ball(n,s,v,c) return p(n,s,v,c,nil,Enum.PartType.Ball) end
    local function planter(x,z)
        cylinder(decor,"PlanterPot",Vector3.new(2.5,3,3),offset+Vector3.new(x,1.6,z),C.white)
        for i=1,4 do local a=i*math.pi/2; ball("TopiaryLeaf",Vector3.new(2.2,3.3,2.2),Vector3.new(x+math.sin(a)*0.8,4,z+math.cos(a)*0.8),C.mint) end
    end
    local function bench(x,z)
        p("BenchSeat",Vector3.new(4.5,0.5,10),Vector3.new(x,2,z),C.gold)
        for _,dz in ipairs({-3.7,3.7}) do p("BenchLeg",Vector3.new(2,2,0.5),Vector3.new(x,1,z+dz),C.white) end
        p("BenchBack",Vector3.new(0.5,2.5,10),Vector3.new(x+(if x<0 then -2 else 2),3.2,z),C.rose)
    end
    for _,x in ipairs({-138,138}) do for _,z in ipairs({20,-52,-124,-196,-268}) do planter(x,z) end end
    for _,x in ipairs({-135,135}) do for _,z in ipairs({-14,-86,-158,-230}) do bench(x,z) end end
    World.plush(decor,"duck",offset+Vector3.new(-59,5.2,94),2.6)
    World.plush(decor,"mochi",offset+Vector3.new(58,5.2,94),2.6)
    for _,x in ipairs({-59,58}) do cylinder(decor,"MascotPodium",Vector3.new(2,7,7),offset+Vector3.new(x,1.4,94),C.lilac) end
    -- A ticket counter, gumball dispenser and vending machine made from parts.
    p("TicketCounter",Vector3.new(19,5.5,6),Vector3.new(-37,3,94),C.rose)
    p("CounterTop",Vector3.new(20,0.5,6.6),Vector3.new(-37,6,94),C.white)
    sign(decor,"TicketSign",Vector3.new(16,2.5,0.2),offset+Vector3.new(-37,3.3,90.9),"WELCOME, COLLECTOR!",C.rose,C.white,Enum.NormalId.Front)
    p("Register",Vector3.new(3,2.5,2),Vector3.new(-38,7.5,94),C.lilac)
    p("RegisterScreen",Vector3.new(2.5,1.5,0.2),Vector3.new(-38,7.8,92.9),C.mint)
    cylinder(decor,"GumballBase",Vector3.new(3.5,2.5,2.5),offset+Vector3.new(-20,2,94),C.rose)
    local globe=ball("GumballGlobe",Vector3.new(4.8,4.8,4.8),Vector3.new(-20,5.5,94),C.blue); globe.Material=Enum.Material.Glass; globe.Transparency=0.65
    for i=1,12 do local a=i*2.4; ball("Gumball",Vector3.new(0.65,0.65,0.65),Vector3.new(-20+math.sin(a)*1.2,4.3+(i%3)*0.7,94+math.cos(a)*1.2),({C.rose,C.gold,C.mint,C.lilac})[i%4+1]) end
    p("GumballCap",Vector3.new(3.2,0.4,3.2),Vector3.new(-20,7.9,94),C.white)
    p("VendingCabinet",Vector3.new(6.5,11,4),Vector3.new(-6,5.8,95),C.lilac)
    p("VendingWindow",Vector3.new(4.7,6.3,0.2),Vector3.new(-6.5,6.9,92.8),C.ink)
    for i=1,6 do p("DrinkCarton",Vector3.new(1,1.5,0.8),Vector3.new(-7.8+(i%3)*1.3,5.5+math.floor((i-1)/3)*2.4,92.5),({C.rose,C.gold,C.mint})[i%3+1]) end
    sign(decor,"VendingHeader",Vector3.new(6,1.4,0.2),offset+Vector3.new(-6,10.4,92.8),"SODA POP",C.lilac,C.white,Enum.NormalId.Front)
    for i=1,3 do ball("VendingButton",Vector3.new(0.4,0.4,0.2),Vector3.new(-3.6,5+i,92.7),C.gold) end
    -- Wall poster graphics, cross-braced toy blocks and anchored balloon bouquets.
    for _,side in ipairs({-1,1}) do
        for j,z in ipairs({60,-8,-76}) do
            local art=sign(decor,"WallPoster",Vector3.new(0.35,6,11),offset+Vector3.new(side*148.2,19,z),({"CATCH\nSOMETHING CUTE","FREE PLAYS\nREFILL AUTOMATICALLY","BUILD YOUR\nDREAM ARCADE"})[j],if j%2==0 then C.blue else C.rose)
            art.Sign.Face=if side<0 then Enum.NormalId.Right else Enum.NormalId.Left
        end
        for j=1,3 do
            local x=side*58+(j-2)*1.6; local z=81+j*0.6
            ball("Balloon",Vector3.new(2.5,3.2,2.5),Vector3.new(x,13+j%2,z),({C.pink,C.gold,C.mint})[j])
            beam(decor,"BalloonString",offset+Vector3.new(side*58,0.6,83),offset+Vector3.new(x,11.6+j%2,z),0.06,C.white)
        end
    end
    -- Eight display positions live in the entrance lounge, away from the lanes.
    local shelf=folder(root,"DisplayPlushies")
    for row=0,1 do
        p("DisplayShelf",Vector3.new(22,0.65,5.5),Vector3.new(22,3.2+row*4.5,92),C.white)
        p("ShelfLip",Vector3.new(22,0.3,0.3),Vector3.new(22,3.6+row*4.5,89.2),C.mint)
    end
    for _,x in ipairs({11.5,32.5}) do p("ShelfUpright",Vector3.new(0.6,10,1),Vector3.new(x,5,94),C.lilac) end
    sign(decor,"ShelfHeading",Vector3.new(23,2.5,0.25),offset+Vector3.new(22,11.4,92),"YOUR CUTE CREW",C.rose,C.white,Enum.NormalId.Front)
    local _,income=sign(decor,"IncomeSign",Vector3.new(22,1.7,0.25),offset+Vector3.new(22,1.7,89.1),"DISPLAY PLUSHIES TO EARN!",C.lilac,C.white,Enum.NormalId.Front)
    local terminal=p("CollectTerminal",Vector3.new(5,3,4),Vector3.new(40,1.8,87),C.mint)
    sign(decor,"CollectLabel",Vector3.new(4.6,1.6,0.2),offset+Vector3.new(40,3,84.8),"COLLECT",C.mint,C.white,Enum.NormalId.Front)
    local prompt=Instance.new("ProximityPrompt"); prompt.Name="CollectIncome"; prompt.ActionText="Collect shelf bank"; prompt.ObjectText="Your arcade income"
    prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt.Parent=terminal
    return shelf,income,prompt
end
local function parkDecorations(root,offset)
    local decor=folder(root,"ParkLandmarks")
    local function p(n,size,v,c,shape) return part(decor,n,size,offset+v,c,nil,shape) end
    local function ball(n,size,v,c) return p(n,size,v,c,Enum.PartType.Ball) end
    -- Entrance fountain with a rotating, floating collectible mascot.
    cylinder(decor,"FountainBase",Vector3.new(1.2,28,28),offset+Vector3.new(0,0.8,212),C.lilac)
    cylinder(decor,"FountainWater",Vector3.new(0.25,24,24),offset+Vector3.new(0,1.5,212),C.blue)
    cylinder(decor,"FountainPedestal",Vector3.new(5,7,7),offset+Vector3.new(0,3.5,212),C.white)
    local mascot=World.plush(decor,"duck",offset+Vector3.new(0,10,212),3)
    mascot.Name="FloatingMascot"; mascot:SetAttribute("FloatAmplitude",0.65)
    for i=1,10 do
        local a=i*math.pi/5
        ball("FountainDroplet",Vector3.new(0.6,0.9,0.6),Vector3.new(math.cos(a)*8,3+(i%3),212+math.sin(a)*8),C.white)
    end
    for row=0,4 do
        local z=156-row*72
        -- Toy flower beds live between cabinet columns, never in front of controls.
        for _,x in ipairs({-78,-26,26,78}) do
            p("GardenBed",Vector3.new(7,0.8,5),Vector3.new(x,0.8,z-21),C.white).TopSurface=Enum.SurfaceType.Studs
            for j=-1,1 do
                p("FlowerStem",Vector3.new(0.16,2.5,0.16),Vector3.new(x+j*1.8,2,z-21),C.mint)
                ball("FlowerCenter",Vector3.new(0.8,0.8,0.8),Vector3.new(x+j*1.8,3.5,z-21),C.gold)
                for k=1,4 do
                    local a=k*math.pi/2
                    ball("FlowerPetal",Vector3.new(0.8,0.8,0.5),Vector3.new(x+j*1.8+math.cos(a)*0.55,3.5+math.sin(a)*0.55,z-21),if row%2==0 then C.rose else C.lilac)
                end
            end
        end
        for _,x in ipairs({-130,130}) do
            p("LampPost",Vector3.new(0.4,13,0.4),Vector3.new(x,6.5,z),C.white)
            ball("LampGlobe",Vector3.new(2.6,2.6,2.6),Vector3.new(x,14,z),C.gold).Material=Enum.Material.Neon
            local tree=p("ToyTreeTrunk",Vector3.new(1.6,7,1.6),Vector3.new(x,3.5,z-39),C.gold)
            for _,v in ipairs({Vector3.new(0,8,0),Vector3.new(-2,6.8,0),Vector3.new(2,7,0)}) do
                ball("ToyTreeCanopy",Vector3.new(5.5,5.5,5.5),Vector3.new(x,0,z-39)+v,C.mint)
            end
        end
        task.wait()
    end
    -- A festival entrance and two oversized toy sculptures frame the lounge.
    for _,x in ipairs({-80,80}) do
        p("EntrancePillar",Vector3.new(3,20,3),Vector3.new(x,10,215),C.rose)
        ball("EntranceStar",Vector3.new(7,7,7),Vector3.new(x,22,215),C.gold)
        local toy=World.plush(decor,if x<0 then "mochi" else "frog",offset+Vector3.new(x,6,190),3.2)
        toy.Name=if x<0 then "BunnyLandmark" else "FrogLandmark"
    end
    sign(decor,"EntranceBanner",Vector3.new(163,5,0.5),offset+Vector3.new(0,21,215),"WELCOME TO PLUSHIE PARK",C.rose,C.white,Enum.NormalId.Front)
    -- Back-of-park collector pavilion gives the full map an intentional destination.
    p("PavilionStage",Vector3.new(55,1,14),Vector3.new(0,1,-195),C.white)
    for i,species in ipairs({"gemfox","infinity","voidbat"}) do
        World.plush(decor,species,offset+Vector3.new((i-2)*16,5,-195),2.3)
    end
end
function World.build(parent,name,offset)
    local root=folder(parent,name); root:SetAttribute("Build",Config.Build)
    architecture(root,offset)
    local shelf,income,collectPrompt=decorations(root,offset)
    parkDecorations(root,offset)
    local machines={}
    for i,spec in ipairs(Config.Machines) do
        machines[i]=cabinet(root,offset+Vector3.new(table.unpack(spec.position)),i)
        if i%5==0 then task.wait() end
    end
    local spawn=Instance.new("SpawnLocation"); spawn.Name="ArcadeSpawn"; spawn.Size=Vector3.new(5,0.2,5)
    spawn.Position=offset+Vector3.new(-104,0.8,139); spawn.Anchored=true; spawn.Transparency=1
    spawn.CanCollide=false; spawn.Neutral=true; spawn.Duration=0; spawn.Parent=root
    return {root=root,offset=offset,machines=machines,shelf=shelf,income=income,spawn=spawn,collectPrompt=collectPrompt}
end
function World.shelves(plot,state)
    plot.shelf:ClearAllChildren()
    for i,id in ipairs(state.display) do for _,item in ipairs(state.inventory) do if item.id==id then
        local plush=World.plush(plot.shelf,item.species,plot.offset+Vector3.new(14.5+((i-1)%4)*5,4.7+math.floor((i-1)/4)*4.5,192),0.95)
        plush:PivotTo(plush:GetPivot()*CFrame.Angles(0,math.pi,0)); break
    end end end
end
function World.targets(plot,tier,targets)
    local machine=plot.machines[tier]; machine.prizes:ClearAllChildren()
    for i,t in ipairs(targets) do
        local plush=World.plush(machine.prizes,t.species,machine.origin+Vector3.new(t.x,7.6,t.z),0.75)
        plush.Name="Target"..i
    end
end
function World.aim(plot,tier,x,z,y,grip)
    local m=plot.machines[tier]; y=y or 15; grip=grip or 0
    local base=CFrame.new(m.origin+Vector3.new(x,y,z))
    m.claw:PivotTo(base)
    for i=1,3 do
        local a=(i-1)*math.pi*2/3
        local radius=1.1-0.63*grip
        local turn=CFrame.Angles(0,a,0)
        m.claw["Finger"..i].CFrame=base*turn*CFrame.new(radius,-0.75,0)*CFrame.Angles(0,0,-0.55+grip*0.7)
        m.claw["Tip"..i].CFrame=base*turn*CFrame.new(radius-0.18,-1.6,0)*CFrame.Angles(0,0,0.8)
    end
    m.cable.Size=Vector3.new(0.09,math.max(0.2,17.1-y),0.09)
    m.cable.Position=m.origin+Vector3.new(x,(17.1+y)/2,z)
    m.carriage.Position=m.origin+Vector3.new(x,17.1,z)
end
function World.animate(plot,round,progress)
    local pose=Config.clawPose(progress,round.x,round.z,round.prize~=nil)
    World.aim(plot,round.tier,pose.x,pose.z,pose.y,pose.grip)
    local machine=plot.machines[round.tier]
    local plush=round.targetIndex and machine.prizes:FindFirstChild("Target"..round.targetIndex)
    if plush and round.prize and progress>=0.49 then
        local pos=machine.origin+Vector3.new(pose.x,pose.y-1.7,pose.z)
        if progress>=0.92 then
            local u=math.clamp((progress-0.92)/0.08,0,1)
            pos=pos:Lerp(machine.origin+Vector3.new(4.1,5.9,4.1),u*u)
        end
        plush:PivotTo(CFrame.new(pos)*CFrame.Angles(0,math.sin(progress*16)*0.16,math.sin(progress*21)*0.08))
    end
end
function World.unlock(plot,tier)
    local machine=plot.machines[tier]
    machine.status.Text="FREE PLAYS!"; machine.status.TextColor3=C.ink; machine.prompt.ActionText="Play free"
    for _,p in ipairs(machine.root:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="LED" then
            TweenService:Create(p,TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,2,true),{Color=C.mint}):Play()
        end
    end
end
return World
]====]
src["ProfileStore"]=[====[-- Injected backend: UpdateAsync(key, transform). All calls per session are serialized.
local Economy=require(game.ReplicatedStorage.ClawEmpire.Shared.Economy)
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
]====]
src["Bootstrap"]=[====[local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local MarketplaceService=game:GetService("MarketplaceService")
local shared=game.ReplicatedStorage.ClawEmpire.Shared
local Config=require(shared.Config)
local Big=require(shared.BigNumber)
local Economy=require(shared.Economy)
local World=require(script.Parent.World)
local ProfileStore=require(script.Parent.ProfileStore)
local container=game.ReplicatedStorage.ClawEmpire
local remotes=Instance.new("Folder"); remotes.Name="Remotes"; remotes.Parent=container
local request=Instance.new("RemoteEvent"); request.Name="Request"; request.Parent=remotes
local update=Instance.new("RemoteEvent"); update.Name="Update"; update.Parent=remotes
local plots=Instance.new("Folder"); plots.Name="ClawEmpirePlots"; plots.Parent=workspace
local preview=workspace:FindFirstChild("ClawEmpirePreview"); if preview then preview:Destroy() end
local sessionOnly=RunService:IsStudio() and Config.StudioSessionOnly
local resumed={}
local backend
if sessionOnly then
    local records={}
    backend={UpdateAsync=function(_,key,transform)
        local previous=records[key]
        -- Optional explicit developer snapshot. Never consulted outside Studio.
        if previous==nil then
            local resume=game.ServerStorage:FindFirstChild("CME_StudioResume")
            local entry=resume and resume:GetAttribute("Enabled")==true and resume:FindFirstChild(key)
            if entry and entry:IsA("StringValue") then
                local ok,decoded=pcall(HttpService.JSONDecode,HttpService,entry.Value)
                if ok and Economy.validate(decoded) then previous={data=decoded}; resumed[key]=true end
            end
        end
        local nextValue=transform(ProfileStore.copy(previous))
        if nextValue==nil then return nil end
        records[key]=ProfileStore.copy(nextValue); return ProfileStore.copy(nextValue)
    end}
else backend=game:GetService("DataStoreService"):GetDataStore("ClawEmpire_Build01_v1") end
local store=ProfileStore.new(backend)
local active,occupied={},{}
local rng=Random.new()
-- Closed purchase gate: even stray unresolved receipts are not acknowledged.
MarketplaceService.ProcessReceipt=function() return Enum.ProductPurchaseDecision.NotProcessedYet end
local function send(player,message,kind,reward)
    local p=active[player]; if not p or player.Parent~=Players then return end
    update:FireClient(player,{state=p.session.data,attempts=p.attempts,
        nextAttempt=math.max(0,Config.AttemptRefillSeconds-(os.clock()-p.lastRefill)),
        round=p.round and {id=p.round.id,phase=p.round.phase,x=p.round.x,z=p.round.z,
            remaining=math.max(0,p.round.expires-os.clock()),targets=p.round.targets,
            started=p.round.started,progress=p.round.started and math.clamp((os.clock()-p.round.started)/Config.DropSeconds,0,1) or 0,prize=p.round.prize,machine=p.round.tier,origin=p.plot.machines[p.round.tier].origin} or false,
        reward=reward,offset=p.plot.offset,sessionOnly=sessionOnly,studioSnapshot=resumed["u_"..player.UserId]==true,message=message,kind=kind})
end
local function healthy(p)
    return not p.leaving and not p.session.closed and p.session.expires>os.time()+20
end
local function inside(player,p)
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then return false end
    local localPos=root.Position-p.plot.offset
    return math.abs(localPos.X)<Config.Bounds.halfWidth and localPos.Z>Config.Bounds.back
        and localPos.Z<Config.Bounds.front and localPos.Y>-4 and localPos.Y<45
end
local function shelf(p)
    World.shelves(p.plot,p.session.data)
    p.plot.income.Text="$"..Big.format(Economy.rate(p.session.data)).." / SEC"
end
local function startRound(player,p)
    if p.round then return false,"Finish or leave your current claw round." end
    if p.attempts<1 then return false,"Free plays refill every 12 seconds. No purchase needed." end
    if #p.session.data.inventory>=Config.Storage then return false,"Storage full (40). You can still rearrange your shelves." end
    p.attempts-=1
    local targets={}
    for z=-2,2,2 do for x=-3,3,3 do
        local species=Economy.roll(p.session.data,rng:NextNumber())
        if x==0 and z==0 and p.session.data.totalCatches==0 then species="duck" end
        table.insert(targets,{x=x,z=z,species=species})
    end end
    p.round={id=HttpService:GenerateGUID(false),phase="aim",x=0,z=0,dx=0,dz=0,
        expires=os.clock()+Config.RoundSeconds,targets=targets,tier=Economy.selected(p.session.data)}
    World.targets(p.plot,p.round.tier,targets); World.aim(p.plot,p.round.tier,0,0)
    return true,if p.session.data.totalCatches==0 then "Aim, then DROP! Your first duck is in the center."
        else "Aim over a plushie, then DROP! These plays are always free."
end
local function finishRound(player,p)
    local round=p.round
    if not round or round.phase~="aim" then return false,"No active claw" end
    if os.clock()>round.expires then p.round=nil; return false,"Round finished. Free plays recharge automatically." end
    round.phase="drop"; round.dx=0; round.dz=0
    local best,distance=nil,math.huge
    for index,t in ipairs(round.targets) do
        local d=Vector2.new(t.x-round.x,t.z-round.z).Magnitude
        if d<distance then best,distance=t,d; round.targetIndex=index end
    end
    round.prize=if distance<=1.4 then best.species else nil
    round.started=os.clock(); send(player,"Claw dropping...","drop")
    task.delay(Config.DropSeconds,function()
        if active[player]~=p or p.round~=round or not healthy(p) then return end
        p.round=nil; World.aim(p.plot,round.tier,0,0)
        if round.prize then
            local ok,item=Economy.grant(p.session.data,round.prize)
            if ok then send(player,"You caught "..Config.plushie(item.species).name.."! Place it on a shelf.","catch",item)
            else send(player,item,"error") end
        else send(player,"Just missed! Center the claw over a plushie and try again.","miss") end
    end)
    return true,nil
end
request.OnServerEvent:Connect(function(player,action,payload)
    local p=active[player]
    if not p or not healthy(p) or type(action)~="string" then return end
    -- A token bucket covers every action, including malformed/unknown requests.
    local now=os.clock(); p.tokens=math.min(24,p.tokens+(now-p.lastToken)*16); p.lastToken=now
    if p.tokens<1 then return end; p.tokens-=1
    if action=="sync" then send(player); return end
    if not inside(player,p) then send(player,"Return to your own arcade to interact.","error"); return end
    if action=="aim" then
        if not p.round or p.round.phase~="aim" or type(payload)~="table" then return end
        local x,z=payload.x,payload.z
        if type(x)~="number" or type(z)~="number" or x~=x or z~=z or math.abs(x)>1 or math.abs(z)>1 then return end
        p.round.dx=x; p.round.dz=z; p.round.inputAt=now; return
    end
    if now-p.lastAction<0.18 then return end; p.lastAction=now
    local ok,message=false,"Unknown action"
    if action=="start" then ok,message=startRound(player,p)
    elseif action=="drop" then ok,message=finishRound(player,p)
    elseif action=="cancel" then
        if p.round and p.round.phase=="drop" then return end
        p.round=nil; ok,message=true,"Claw round ended. Plays refill for free."
    elseif action=="collect" then ok,message=Economy.collect(p.session.data)
    elseif action=="display" or action=="stow" or action=="sell" then
        if type(payload)~="number" or payload~=payload or payload%1~=0 or payload<1 or payload>1e12 then return end
        ok,message=Economy[action](p.session.data,payload); if ok then shelf(p) end
    elseif action=="unlock" then
        if p.round then ok,message=false,"Finish your round before unlocking a machine."
        else ok,message=Economy.unlock(p.session.data); if ok then World.unlock(p.plot,p.session.data.machine) end end
    elseif action=="select" then
        if p.round then ok,message=false,"Finish this round before switching machines."
        else ok,message=Economy.select(p.session.data,payload) end
    elseif action=="travel" then
        if p.round then ok,message=false,"Finish this round first."
        else
            ok,message=Economy.select(p.session.data,payload)
            local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if ok and root then
                local origin=p.plot.machines[payload].origin
                player.Character:PivotTo(CFrame.lookAt(origin+Vector3.new(0,4,16),origin+Vector3.new(0,4,0)))
                message="Welcome to "..Config.Machines[payload].name.."!"
            end
        end
    elseif action=="upgrade" then
        if type(payload)~="string" or #payload>20 then return end
        ok,message=Economy.upgrade(p.session.data,payload); if ok then shelf(p) end
    end
    send(player,message,if ok then "success" else "error")
end)
local function join(player)
    local slot
    for i=1,Config.MaxPlayers do if not occupied[i] then occupied[i]=player; slot=i; break end end
    if not slot then player:Kick("This alpha has four arcade plots. Please join another server."); return end
    local session,err
    local token=HttpService:GenerateGUID(false) -- Reuse after an ambiguous committed load.
    for attempt=1,3 do
        session,err=store:load("u_"..player.UserId,token)
        if session then break end
        task.wait(attempt)
    end
    if not session or player.Parent~=Players then
        occupied[slot]=nil
        if session then store:save(session,true) end
        if player.Parent==Players then player:Kick(err or "Profile load interrupted") end
        return
    end
    local plot=World.build(plots,"Arcade_"..player.UserId,Vector3.new((slot-1)*Config.PlotSpacing,0,0))
    local p={session=session,plot=plot,slot=slot,attempts=Config.FreeAttempts,lastRefill=os.clock(),
        tokens=24,lastToken=os.clock(),lastAction=0,lastSave=os.clock(),tickAt=os.clock()}
    active[player]=p; player.RespawnLocation=plot.spawn
    for tier,machine in ipairs(plot.machines) do
        machine.prompt.Triggered:Connect(function(who)
            if who~=player or not healthy(p) or not inside(player,p) or p.round then return end
            local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
            if not root or (root.Position-(machine.origin+Vector3.new(0,4,7))).Magnitude>18 then return end
            local ok,message
            if tier<=p.session.data.machine then
                ok,message=Economy.select(p.session.data,tier)
                if ok then ok,message=startRound(player,p) end
            elseif tier==p.session.data.machine+1 then
                ok,message=Economy.unlock(p.session.data)
                if ok then World.unlock(plot,tier) end
            else ok,message=false,"Unlock the machines in gallery order first." end
            send(player,message,if ok then "success" else "error")
        end)
    end
    plot.collectPrompt.Triggered:Connect(function(who)
        if who~=player or not healthy(p) or not inside(player,p) then return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or (root.Position-plot.collectPrompt.Parent.Position).Magnitude>16 then return end
        local _,message=Economy.collect(p.session.data); send(player,message,"success")
    end)
    local function spawnCharacter(character)
        local root=character:WaitForChild("HumanoidRootPart",10)
        if root then character:PivotTo(CFrame.new(plot.spawn.Position+Vector3.new(0,4,0))) end
        local hum=character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=24 end
    end
    player.CharacterAdded:Connect(function(char)
        if p.round and p.round.phase~="drop" then p.round=nil end
        spawnCharacter(char)
    end)
    if player.Character then task.spawn(spawnCharacter,player.Character) end
    shelf(p)
    for i=2,session.data.machine do World.unlock(plot,i) end
    send(player,"Welcome! Catch your first plushie, then put it on display.","welcome")
    print("CME_PROFILE_READY",player.UserId,if sessionOnly then "STUDIO_SESSION_ONLY" else "PERSISTENT")
end
local function leave(player)
    local p=active[player]; if not p or p.leaving then return end
    p.leaving=true; p.round=nil
    local deadline=os.clock()+12
    while p.session.saving and os.clock()<deadline do task.wait(0.1) end
    local saved=false
    for attempt=1,3 do
        saved=store:save(p.session,true)
        if saved then break end; task.wait(attempt)
    end
    if not saved then warn("CME_FINAL_SAVE_FAILED",player.UserId) end
    active[player]=nil; occupied[p.slot]=nil; p.plot.root:Destroy()
end
Players.PlayerAdded:Connect(join); Players.PlayerRemoving:Connect(leave)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
RunService.Heartbeat:Connect(function()
    local now=os.clock()
    for _,p in pairs(active) do
        if p.round and p.round.phase=="drop" and not p.leaving then
            World.animate(p.plot,p.round,math.clamp((now-p.round.started)/Config.DropSeconds,0,1))
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.1)
        local now=os.clock()
        for player,p in pairs(active) do
            if p.leaving then continue end
            if not healthy(p) then
                player:Kick("Saving is paused; your last saved arcade is protected. Please rejoin."); continue
            end
            local dt=math.min(now-p.tickAt,1); p.tickAt=now
            Economy.tick(p.session.data,dt)
            if now-p.lastRefill>=Config.AttemptRefillSeconds then
                local refills=math.floor((now-p.lastRefill)/Config.AttemptRefillSeconds)
                p.attempts=math.min(Config.FreeAttempts,p.attempts+refills)
                p.lastRefill+=refills*Config.AttemptRefillSeconds
            end
            local round=p.round
            if round then
                if round.phase=="aim" then
                    if now>round.expires or not inside(player,p) then p.round=nil
                    else
                        local dx,dz=round.dx,round.dz
                        if not round.inputAt or now-round.inputAt>0.4 then dx,dz=0,0 end
                        local magnitude=math.max(1,Vector2.new(dx,dz).Magnitude)
                        local speed=2.5+0.5*p.session.data.upgrades.speed
                        round.x=math.clamp(round.x+dx/magnitude*speed*dt,-4,4)
                        round.z=math.clamp(round.z+dz/magnitude*speed*dt,-3,3)
                        World.aim(p.plot,round.tier,round.x,round.z)
                    end
                else
                    -- Heartbeat animates the crane; reward still commits exactly once above.
                end
            end
            p.lastPush=p.lastPush or 0
            if now-p.lastPush>=0.2 then p.lastPush=now; send(player) end
            if now-p.lastSave>=30 and not p.session.saving then
                p.lastSave=now
                task.spawn(function()
                    local ok,saveErr=store:save(p.session,false)
                    if not ok then warn("CME_AUTOSAVE",saveErr); send(player,"Save retry pending. Please stay connected.","error") end
                end)
            end
        end
    end
end)
game:BindToClose(function()
    local pending=0
    for player in pairs(active) do pending+=1; task.spawn(function() leave(player); pending-=1 end) end
    local deadline=os.clock()+25
    while pending>0 and os.clock()<deadline do task.wait(0.1) end
end)
print("CME_SERVER_READY",Config.Build)
]====]
src["ClawEmpireClient"]=[====[-- Build03: three-widget walking HUD; contextual crane controls and prize theatre.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild("ClawEmpire"):WaitForChild("Shared")
local Config=require(shared.Config); local Big=require(shared.BigNumber); local Economy=require(shared.Economy)
local remotes=shared.Parent:WaitForChild("Remotes")
local request=remotes:WaitForChild("Request"); local update=remotes:WaitForChild("Update")
local gui=Instance.new("ScreenGui"); gui.Name="ClawEmpireUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=10
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
local C={navy=Color3.fromRGB(64,43,84),white=Color3.fromRGB(255,250,237),pink=Color3.fromRGB(255,132,186),
    mint=Color3.fromRGB(137,239,184),yellow=Color3.fromRGB(255,218,107),cyan=Color3.fromRGB(146,211,255),purple=Color3.fromRGB(197,174,255)}
local latest,panelName,lastRoundId,offset=nil,nil,nil,Vector3.zero
local keys,held={},{}
local overview,reducedMotion,phone=false,false,false
local frozenHumanoid,previousSpeed
local revealModel,revealItem,revealTime=nil,nil,0
local controls
task.spawn(function()
    local module=player.PlayerScripts:WaitForChild("PlayerModule",2)
    if module then pcall(function() controls=require(module):GetControls() end) end
end)
local function tween(obj,time,props,style)
    local tw=TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    tw:Play(); return tw
end
local root=Instance.new("Frame"); root.Name="Canvas"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.Parent=gui
local function round(obj,radius)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius or 20); c.Parent=obj
end
local function stroke(obj,color,width)
    local s=Instance.new("UIStroke"); s.Color=color or C.navy; s.Thickness=width or 3; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=obj
end
local function frame(parent,name,pos,size,color)
    local f=Instance.new("Frame"); f.Name=name; f.Position=pos; f.Size=size; f.BackgroundColor3=color or C.white
    f.BorderSizePixel=0; f.Parent=parent; round(f); return f
end
local function text(parent,name,value,pos,size,fontSize,color)
    local l=Instance.new("TextLabel"); l.Name=name; l.Text=value; l.Position=pos; l.Size=size
    l.BackgroundTransparency=1; l.Font=Enum.Font.FredokaOne; l.TextSize=fontSize or 22
    l.TextColor3=color or C.navy; l.TextWrapped=true; l.Parent=parent; return l
end
local function button(parent,name,value,pos,size,color,callback)
    local b=Instance.new("TextButton"); b.Name=name; b.Position=pos; b.Size=size; b.Text=value
    b.BackgroundColor3=color; b.TextColor3=C.navy; b.TextStrokeTransparency=1; b.BorderSizePixel=0; b.AutoButtonColor=false
    b.Font=Enum.Font.FredokaOne; b.TextSize=21; b.Parent=parent; round(b,18); stroke(b)
    local shine=Instance.new("UIGradient"); shine.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(220,226,240)); shine.Rotation=90; shine.Parent=b
    local s=Instance.new("UIScale"); s.Parent=b
    b.MouseEnter:Connect(function() if not reducedMotion then tween(s,.15,{Scale=1.035},Enum.EasingStyle.Back) end end)
    b.MouseLeave:Connect(function() tween(s,.12,{Scale=1}) end)
    b.MouseButton1Down:Connect(function() tween(s,.08,{Scale=.94}) end)
    b.MouseButton1Up:Connect(function() tween(s,.2,{Scale=1},Enum.EasingStyle.Back) end)
    if callback then b.Activated:Connect(callback) end
    return b
end
local wallet=frame(root,"Wallet",UDim2.fromOffset(18,16),UDim2.fromOffset(176,52),C.white); stroke(wallet)
local coin=frame(wallet,"Coin",UDim2.fromOffset(11,10),UDim2.fromOffset(30,30),C.yellow); stroke(coin,nil,2)
text(coin,"Symbol","$",UDim2.new(),UDim2.fromScale(1,1),23)
local money=text(wallet,"Value","0",UDim2.fromOffset(49,6),UDim2.new(1,-57,1,-12),26); money.TextXAlignment=Enum.TextXAlignment.Left
local open
local menu=button(root,"Menu","MY ARCADE",UDim2.new(1,-169,0,16),UDim2.fromOffset(151,52),C.pink,function() open("Home") end)
local play=button(root,"Play","PLAY CLAW",UDim2.new(.5,-100,1,-74),UDim2.fromOffset(200,54),C.mint,function()
    if latest and latest.round then
        if latest.round.phase=="aim" then request:FireServer("drop") end
    elseif latest then request:FireServer("start") end
end)
local hint=text(root,"ContextHint","",UDim2.new(.5,-160,1,-103),UDim2.fromOffset(320,23),15,C.white)
hint.TextStrokeColor3=C.navy; hint.TextStrokeTransparency=0
local status=frame(root,"Toast",UDim2.new(.5,0,0,82),UDim2.fromOffset(450,48),C.white)
status.AnchorPoint=Vector2.new(.5,0); status.Visible=false; stroke(status)
local statusText=text(status,"Message","",UDim2.fromOffset(10,4),UDim2.new(1,-20,1,-8),18)
local toastVersion=0
local function toast(message)
    toastVersion+=1; local v=toastVersion; statusText.Text=message; status.Visible=true
    task.delay(3.5,function() if v==toastVersion then status.Visible=false end end)
end
local shade=frame(root,"MenuShade",UDim2.new(),UDim2.fromScale(1,1),C.navy); shade.BackgroundTransparency=.45; shade.Visible=false
local panel=frame(shade,"Panel",UDim2.fromScale(.5,.5),UDim2.fromOffset(610,510),C.white)
panel.AnchorPoint=Vector2.new(.5,.5); stroke(panel,nil,4); panel.Visible=false
local panelTitle=text(panel,"PanelTitle","My arcade",UDim2.fromOffset(20,12),UDim2.new(1,-90,0,42),28)
panelTitle.TextXAlignment=Enum.TextXAlignment.Left
button(panel,"Close","X",UDim2.new(1,-60,0,12),UDim2.fromOffset(44,42),C.pink,function() panelName=nil; panel.Visible=false; shade.Visible=false end)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="Content"; scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.Position=UDim2.fromOffset(16,68); scroll.Size=UDim2.new(1,-32,1,-84); scroll.ScrollBarThickness=5
scroll.ScrollBarImageColor3=C.purple; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(); scroll.Parent=panel
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,12); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Parent=scroll
local function row(name,height,color)
    local f=frame(scroll,name,UDim2.new(),UDim2.new(1,-10,0,height),color or Color3.fromRGB(235,232,250))
    f.LayoutOrder=#scroll:GetChildren(); return f
end
local function rowText(f,value,y,size,color)
    local l=text(f,"Detail",value,UDim2.fromOffset(16,y),UDim2.new(1,-32,0,size+10),size,color or C.navy)
    l.TextStrokeTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; return l
end
local rebuild
open=function(name)
    if not latest or latest.round or revealItem then return end
    panelName=name; scroll.CanvasPosition=Vector2.zero; rebuild()
    if not reducedMotion then
        local s=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
        s.Scale=.91; tween(s,.26,{Scale=1},Enum.EasingStyle.Back)
    end
end
local function isDisplayed(id)
    for _,shown in ipairs(latest.state.display) do if shown==id then return true end end
    return false
end
local indexMode=false
rebuild=function()
    if not panelName or not latest then panel.Visible=false; shade.Visible=false; return end
    panel.Visible=true; shade.Visible=true; panelTitle.Text=if panelName=="Home" then "My arcade" else panelName
    for _,child in ipairs(scroll:GetChildren()) do if child~=list then child:Destroy() end end
    local state=latest.state
    if panelName~="Home" then
        local f=row("Back",44,C.white)
        button(f,"GoBack","<  BACK",UDim2.new(),UDim2.fromOffset(115,40),C.cyan,function() open("Home") end).TextSize=16
    end
    if panelName=="Home" then
        local f=row("Income",96,C.yellow)
        local bank=rowText(f,"Shelf bank  $"..Big.format(state.bank),8,23); bank.Name="Bank"
        rowText(f,"Earning $"..Big.format(Economy.rate(state)).." / sec",49,15)
        button(f,"Collect","COLLECT",UDim2.new(1,-145,0,45),UDim2.fromOffset(130,40),C.mint,function() request:FireServer("collect") end).TextSize=17
        for i,name in ipairs({"Plushies","Machines","Upgrades"}) do
            local f=row(name,60,C.white)
            button(f,"Open",name.."   >",UDim2.new(),UDim2.fromScale(1,1),({C.pink,C.cyan,C.purple})[i],function() open(name) end)
        end
        local f=row("Map",56,C.white)
        button(f,"Toggle",if overview then "RETURN TO WALKING" else "BIRD'S-EYE MAP",UDim2.new(),UDim2.fromScale(1,1),C.cyan,function() overview=not overview; panelName=nil; shade.Visible=false end).TextSize=18
        f=row("Motion",56,C.white)
        button(f,"Toggle","REDUCED MOTION: "..(if reducedMotion then "ON" else "OFF"),UDim2.new(),UDim2.fromScale(1,1),C.white,function() reducedMotion=not reducedMotion; rebuild() end).TextSize=17
        f=row("Demo",58,C.white)
        rowText(f,if latest.sessionOnly then "Studio demo  /  progress lasts until Play stops." else "Your arcade saves automatically.",7,14)
        rowText(f,"Catch. Display. Earn. Every claw has free plays.",32,13)
    elseif panelName=="Plushies" then
        local heading=row("CollectionTabs",54,C.navy)
        button(heading,"InventoryTab","INVENTORY",UDim2.fromOffset(6,4),UDim2.new(0.5,-9,0,46),C.pink,function() indexMode=false; rebuild() end).TextSize=16
        button(heading,"IndexTab","COLLECTION",UDim2.new(0.5,3,0,4),UDim2.new(0.5,-9,0,46),C.cyan,function() indexMode=true; rebuild() end).TextSize=16
        if indexMode then
            for _,spec in ipairs(Config.Plushies) do
                local known=state.discovered[spec.id]
                local f=row(spec.id,83,if known then Color3.fromRGB(table.unpack(spec.color)) else Color3.fromRGB(225,224,236))
                rowText(f,if known then spec.name else "???  -  UNDISCOVERED",9,21)
                rowText(f,if known then spec.rarity.."  /  $"..spec.income.." per second" else "Keep catching to complete your crew.",43,14)
            end
        else
            local info=row("ShelfCount",48); rowText(info,"SHELVES "..#state.display.." / 8   |   STORAGE "..#state.inventory.." / 40",9,if phone then 14 else 18)
            if #state.inventory==0 then local f=row("Empty",98); rowText(f,"Your crew starts with one catch!",12,20); rowText(f,"Close this panel and press PLAY CLAW.",52,15) end
            for _,item in ipairs(state.inventory) do
                local spec=Config.plushie(item.species); local displayed=isDisplayed(item.id)
                local f=row("Item"..item.id,128,Color3.fromRGB(table.unpack(spec.color)))
                local name=rowText(f,spec.name.."  #"..item.id,8,if phone then 19 else 23)
                name.Size=UDim2.new(1,-32,0,34)
                rowText(f,spec.rarity.."  /  $"..spec.income.." / sec",43,15)
                local b=button(f,"Display",if displayed then "STOW" else "DISPLAY",
                    UDim2.fromOffset(14,77),UDim2.fromOffset(135,44),if displayed then C.purple else C.mint,
                    function() request:FireServer(if displayed then "stow" else "display",item.id) end)
                b.TextSize=18
                if not displayed then
                    button(f,"Sell","SELL $"..spec.income*5,UDim2.new(1,-143,0,77),UDim2.fromOffset(129,44),C.yellow,
                        function() request:FireServer("sell",item.id) end).TextSize=17
                end
            end
        end
    elseif panelName=="Machines" then
        local info=row("MachineCount",72,C.navy)
        rowText(info,state.machine.." / 25 MACHINES OWNED",8,if phone then 18 else 23,C.yellow)
        rowText(info,"Walk up and press E, or jump to an owned machine.",42,if phone then 12 else 15,C.white)
        for i,spec in ipairs(Config.Machines) do
            local f=row(spec.id,140,Color3.fromRGB(table.unpack(spec.color)))
            rowText(f,spec.name,12,27)
            rowText(f,if i<=state.machine then "OWNED  /  FREE CLAW PLAYS" else "Unlock for $"..Big.format(Big.new(spec.cost)).." earned coins",52,16)
            if i==state.machine+1 then
                button(f,"Unlock","UNLOCK  $"..Big.format(Big.new(spec.cost)),UDim2.fromOffset(16,87),UDim2.new(1,-32,0,44),C.mint,function() request:FireServer("unlock") end).TextSize=20
            elseif i<=state.machine then
                button(f,"Travel","GO HERE",UDim2.fromOffset(16,87),UDim2.new(1,-32,0,44),C.cyan,function() request:FireServer("travel",i); panelName=nil; shade.Visible=false; overview=false end).TextSize=19
            else rowText(f,"UNLOCK EARLIER MACHINES FIRST",92,if phone then 13 else 17) end
        end
        local f=row("Next",95,C.navy); rowText(f,"25 THEMES. ALL EARNABLE.",10,if phone then 19 else 23,C.pink); rowText(f,"Every owned machine has free replenishing plays.",51,if phone then 13 else 15,C.white)
    elseif panelName=="Upgrades" then
        for _,key in ipairs({"speed","shelves"}) do
            local spec=Config.Upgrades[key]; local level=state.upgrades[key]
            local f=row(key,155,if key=="speed" then C.cyan else C.purple)
            rowText(f,spec.name.."  "..level.." / "..spec.max,10,24)
            rowText(f,spec.description,48,if phone then 14 else 16)
            local b=button(f,"BuyUpgrade",if level>=spec.max then "MAX LEVEL" else "UPGRADE  $"..spec.cost*2^level,
                UDim2.fromOffset(16,99),UDim2.new(1,-32,0,44),C.mint,function() request:FireServer("upgrade",key) end)
            b.TextSize=18
        end
    elseif panelName=="Shop" then
        local f=row("Closed",110,C.navy); rowText(f,"PURCHASES ARE DISABLED",10,if phone then 19 else 25,C.yellow)
        local l=rowText(f,"Alpha preview only. No Robux prompts, fake prices, or paid random catches.",49,16,C.white); l.Size=UDim2.new(1,-32,0,50)
        for _,spec in ipairs(Config.Catalog) do
            local card=row(spec.id,155,C.purple)
            rowText(card,spec.name,10,if phone then 20 else 25)
            local l=rowText(card,spec.benefit,49,15); l.Size=UDim2.new(1,-32,0,45)
            rowText(card,"NOT FOR SALE  /  ID NOT CONFIGURED",112,if phone then 12 else 16)
        end
    end
end

local timerPill=frame(root,"RoundTimer",UDim2.new(.5,-100,0,18),UDim2.fromOffset(200,48),C.white); stroke(timerPill); timerPill.Visible=false
local timer=text(timerPill,"Text","25s",UDim2.new(),UDim2.fromScale(1,1),24)
local exit=button(root,"LeaveClaw","X",UDim2.new(1,-65,0,18),UDim2.fromOffset(46,46),C.pink,function() request:FireServer("cancel") end); exit.Visible=false
local dpad=frame(root,"TouchControls",UDim2.new(0,18,1,-164),UDim2.fromOffset(150,140),C.white)
dpad.BackgroundTransparency=1; dpad.Visible=false
for _,spec in ipairs({{"Up","^",49,0},{"Left","<",0,47},{"Down","v",49,94},{"Right",">",98,47}}) do
    local b=button(dpad,spec[1],spec[2],UDim2.fromOffset(spec[3],spec[4]),UDim2.fromOffset(44,44),C.cyan)
    b.InputBegan:Connect(function(v) if v.UserInputType==Enum.UserInputType.Touch or v.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=true end end)
    b.InputEnded:Connect(function(v) if v.UserInputType==Enum.UserInputType.Touch or v.UserInputType==Enum.UserInputType.MouseButton1 then held[spec[1]]=nil end end)
end
local guide=frame(root,"AimGuide",UDim2.new(1,-154,1,-185),UDim2.fromOffset(132,94),C.white)
guide.BackgroundTransparency=.15; stroke(guide,nil,2); guide.Visible=false
local cursor=text(guide,"Cursor","+",UDim2.fromScale(.5,.5),UDim2.fromOffset(28,28),28)
cursor.AnchorPoint=Vector2.new(.5,.5); cursor.ZIndex=2
local function drawTargets(targets)
    for _,c in ipairs(guide:GetChildren()) do if c.Name=="Dot" then c:Destroy() end end
    for _,t in ipairs(targets) do
        local spec=Config.plushie(t.species)
        local dot=frame(guide,"Dot",UDim2.fromScale(.1+(t.x+4)/8*.8,.12+(t.z+3)/6*.76),UDim2.fromOffset(13,13),Color3.fromRGB(table.unpack(spec.color)))
        dot.AnchorPoint=Vector2.new(.5,.5); stroke(dot,nil,1)
    end
end
local reveal=frame(root,"PrizeReveal",UDim2.new(),UDim2.fromScale(1,1),C.navy); reveal.BackgroundTransparency=.24; reveal.Visible=false
local burst=frame(reveal,"Sunburst",UDim2.fromScale(.5,.43),UDim2.fromOffset(1,1),C.white); burst.BackgroundTransparency=1
for i=1,12 do
    local ray=frame(burst,"Ray"..i,UDim2.fromOffset(-14,-425),UDim2.fromOffset(28,850),if i%2==0 then C.yellow else C.pink)
    ray.BackgroundTransparency=.72; ray.Rotation=i*15
end
local fit=frame(reveal,"Fit",UDim2.fromScale(.5,.5),UDim2.fromOffset(370,460),C.white)
fit.AnchorPoint=Vector2.new(.5,.5); fit.BackgroundTransparency=1
local fitScale=Instance.new("UIScale"); fitScale.Parent=fit
local prizeCard=frame(fit,"Card",UDim2.new(),UDim2.fromScale(1,1),C.white); stroke(prizeCard,nil,4)
local cardScale=Instance.new("UIScale"); cardScale.Parent=prizeCard
text(prizeCard,"Title","YOU GOT A PLUSHIE!",UDim2.fromOffset(10,12),UDim2.new(1,-20,0,35),25)
local rarity=text(prizeCard,"Rarity","COMMON",UDim2.fromOffset(10,50),UDim2.new(1,-20,0,26),16)
local viewport=Instance.new("ViewportFrame"); viewport.Name="PlushPreview"; viewport.BackgroundTransparency=1
viewport.Position=UDim2.fromOffset(30,77); viewport.Size=UDim2.new(1,-60,0,235); viewport.Ambient=Color3.fromRGB(220,220,220)
viewport.LightColor=Color3.new(1,1,1); viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.Parent=prizeCard
local modelWorld=Instance.new("WorldModel"); modelWorld.Parent=viewport
local vpCamera=Instance.new("Camera"); vpCamera.FieldOfView=35; vpCamera.CFrame=CFrame.lookAt(Vector3.new(0,0,5.5),Vector3.zero); vpCamera.Parent=viewport; viewport.CurrentCamera=vpCamera
local prizeName=text(prizeCard,"Name","Goofy Duck",UDim2.fromOffset(10,310),UDim2.new(1,-20,0,36),27)
local function closeReveal()
    revealItem=nil; reveal.Visible=false; modelWorld:ClearAllChildren(); revealModel=nil
end
button(prizeCard,"Display","DISPLAY",UDim2.fromOffset(20,361),UDim2.new(1,-40,0,46),C.mint,function()
    if revealItem then request:FireServer("display",revealItem.id) end; closeReveal()
end)
button(prizeCard,"Keep","KEEP IN BAG",UDim2.fromOffset(70,414),UDim2.new(1,-140,0,31),C.white,closeReveal).TextSize=15
local function showReward(item)
    if not item then return end
    modelWorld:ClearAllChildren(); revealModel=nil
    local plots=workspace:FindFirstChild("ClawEmpirePlots")
    local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
    if plot then for _,model in ipairs(plot:GetDescendants()) do
        if model:IsA("Model") and model:GetAttribute("Species")==item.species then
            revealModel=model:Clone()
            for _,p in ipairs(revealModel:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=true; p.LocalTransparencyModifier=0 end end
            local _,size=revealModel:GetBoundingBox(); revealModel:ScaleTo(2.65/math.max(size.X,size.Y,size.Z)); local box=revealModel:GetBoundingBox(); revealModel.PrimaryPart=nil; revealModel.WorldPivot=box; revealModel:PivotTo(CFrame.new()); revealModel.Parent=modelWorld; break
        end
    end end
    local spec=Config.plushie(item.species)
    revealItem=item; revealTime=os.clock(); reveal.Visible=true; shade.Visible=false; panelName=nil; status.Visible=false
    rarity.Text=string.upper(spec.rarity); prizeName.Text=spec.name; prizeCard.BackgroundColor3=Color3.fromRGB(table.unpack(spec.color)):Lerp(C.white,.65)
    prizeCard.Display.Text="DISPLAY  +$"..spec.income.."/s"
    cardScale.Scale=if reducedMotion then 1 else .15
    if not reducedMotion then tween(cardScale,.55,{Scale=1},Enum.EasingStyle.Back) end
    for i=1,(if reducedMotion then 0 else 32) do
        local conf=frame(reveal,"Confetti",UDim2.fromScale(.5,.45),UDim2.fromOffset(8,15),({C.pink,C.cyan,C.yellow,C.mint})[i%4+1])
        conf.Rotation=i*43
        tween(conf,1.3+i%4*.2,{Position=UDim2.fromScale((i*37%100)/100,1.15),Rotation=i*113,BackgroundTransparency=1})
        task.delay(2.1,function() conf:Destroy() end)
    end
end
local function homeCamera()
    return CFrame.lookAt(offset+(if gui.AbsoluteSize.X<gui.AbsoluteSize.Y then Vector3.new(240,610,720) else Vector3.new(245,305,385)),offset+Vector3.new(0,0,10))
end
local cameraState=Instance.new("CFrameValue"); cameraState.Value=homeCamera()
local function layout()
    local size=gui.AbsoluteSize; local compact=size.Y<500; phone=size.X<600
    wallet.Size=UDim2.fromOffset(if phone then 136 else 176,48); money.TextSize=if phone then 21 else 26
    menu.Position=UDim2.new(1,if phone then -143 else -169,0,16); menu.Size=UDim2.fromOffset(if phone then 125 else 151,48); menu.TextSize=if phone then 17 else 21
    panel.Size=UDim2.fromOffset(math.min(610,size.X-32),math.min(510,size.Y-32))
    local rh=math.min(460,size.Y-24)
    fit.Size=UDim2.fromOffset(math.min(370,size.X-28),rh); fitScale.Scale=1
    prizeCard.Title.TextSize=if compact then 21 else 25
    viewport.Position=UDim2.fromOffset(25,66); viewport.Size=UDim2.new(1,-50,0,rh-225)
    rarity.Position=UDim2.fromOffset(10,43)
    prizeName.Position=UDim2.fromOffset(10,rh-151)
    prizeCard.Display.Position=UDim2.fromOffset(20,rh-108); prizeCard.Display.Size=UDim2.new(1,-40,0,46)
    prizeCard.Keep.Position=UDim2.fromOffset(55,rh-54); prizeCard.Keep.Size=UDim2.new(1,-110,0,44)
    dpad.Position=UDim2.new(0,18,1,if compact then -151 else -164)
    hint.TextSize=if phone then 12 else 15
    guide.Size=UDim2.fromOffset(if phone then 90 else 132,if phone then 72 else 94)
    guide.Position=UDim2.new(1,if phone then -108 else -154,1,if compact then -173 else -185)
    status.Size=UDim2.fromOffset(math.min(450,size.X-32),48); statusText.TextSize=if phone then 15 else 18
    if not latest or not latest.round then cameraState.Value=homeCamera() end
end
local fxFolder,fxParts=nil,{}
local lastRoundSync=0
local function clearFX()
    if fxFolder then fxFolder:Destroy(); fxFolder=nil end; fxParts={}
end
local function setRoundMode(data)
    local id=data and data.id or nil
    if id==lastRoundId then return end
    clearFX()
    if id then
        fxFolder=Instance.new("Folder"); fxFolder.Name="CME_LocalCatchFX"; fxFolder.Parent=workspace
        for i=1,10 do
            local p=Instance.new("Part"); p.Name="StarMote"; p.Shape=Enum.PartType.Ball
            p.Size=Vector3.new(.14,.14,.14); p.Material=Enum.Material.Neon; p.Color=if i%2==0 then C.yellow else C.white
            p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false; p.Transparency=1; p.Parent=fxFolder
            fxParts[i]=p
        end
    end
    keys={}; held={}; panelName=nil; shade.Visible=false; overview=false
    if controls then if id then controls:Disable() else controls:Enable() end end
    if id then
        frozenHumanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if frozenHumanoid then previousSpeed=frozenHumanoid.WalkSpeed; frozenHumanoid.WalkSpeed=0 end
        drawTargets(data.targets)
    elseif frozenHumanoid and frozenHumanoid.Parent then frozenHumanoid.WalkSpeed=previousSpeed or 24; frozenHumanoid=nil end
    local plots=workspace:FindFirstChild("ClawEmpirePlots")
    local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
    if plot then for _,p in ipairs(plot:GetDescendants()) do
        if p:IsA("BasePart") and p:GetAttribute("AimOccluder") then
            p.LocalTransparencyModifier=if id then 1 else 0
            local sign=p:FindFirstChild("Sign"); if sign then sign.Enabled=id==nil end
        end
    end end
    if id then tween(cameraState,if reducedMotion then .01 else .65,{Value=CFrame.lookAt(data.origin+Vector3.new(0,26,14),data.origin+Vector3.new(0,8,0))},Enum.EasingStyle.Quint) end
    lastRoundId=id
end
local lastViewKey=""
update.OnClientEvent:Connect(function(data)
    latest=data; lastRoundSync=os.clock(); offset=data.offset; money.Text=Big.format(data.state.coins); setRoundMode(data.round)
    if data.round then
        timer.Text=if data.round.phase=="aim" then math.ceil(data.round.remaining).."s" else Config.clawPose(data.round.progress or 0,0,0,data.round.prize~=nil).stage
        play.Text=if data.round.phase=="aim" then "DROP!" else "GRABBING..."
        hint.Text=if data.round.phase=="aim" then "Aim with arrows  /  Space to drop" else "Here comes your plushie..."
        cursor.Position=UDim2.fromScale(.1+(data.round.x+4)/8*.8,.12+(data.round.z+3)/6*.76)
    else
        play.Text="PLAY "..Config.Machines[Economy.selected(data.state)].short
        hint.Text=if #data.state.inventory==0 then "Catch your first plushie!" else data.attempts.." free plays  /  explore your arcade"
    end
    if data.message and not revealItem and not data.round and data.kind~="catch" and data.kind~="drop" and data.kind~="welcome" then toast(data.message) end
    if data.kind=="catch" then showReward(data.reward) end
    local key=panelName and table.concat({panelName,#data.state.inventory,table.concat(data.state.display,","),data.state.machine,Economy.selected(data.state),data.state.upgrades.speed,data.state.upgrades.shelves},":") or ""
    if key~=lastViewKey then lastViewKey=key; rebuild() end
    local bank=scroll:FindFirstChild("Income")
    if panelName=="Home" and bank then bank.Bank.Text="Shelf bank  $"..Big.format(data.state.bank) end
end)
UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.V and latest and not latest.round and not revealItem then overview=not overview; cameraState.Value=homeCamera() end
    if not latest or not latest.round then return end
    keys[input.KeyCode]=true
    if input.KeyCode==Enum.KeyCode.Space then request:FireServer("drop") end
    if input.KeyCode==Enum.KeyCode.Escape and latest.round.phase=="aim" then request:FireServer("cancel") end
end)
UIS.InputEnded:Connect(function(v) keys[v.KeyCode]=nil end)
UIS.WindowFocusReleased:Connect(function() keys={}; held={} end)
local elapsed=0
local touchOverride,touchWasEnabled=nil,nil
local ambientModel,ambientBase,ambientCheck=nil,nil,0
RunService:BindToRenderStep("ClawEmpireCamera",Enum.RenderPriority.Camera.Value+1,function(dt)
    local cam=workspace.CurrentCamera; local inRound=latest and latest.round
    if overview or inRound then
        cam.CameraType=Enum.CameraType.Scriptable
        if overview then cam.CFrame=homeCamera() else
            local cf=cameraState.Value; local p=inRound.progress or 0
            if inRound.phase=="drop" and not reducedMotion then cf=cf*CFrame.new(0,0,-math.sin(p*math.pi)*1.2) end
            cam.CFrame=cf
        end
        cam.FieldOfView=60
    else
        cam.CameraType=Enum.CameraType.Custom; cam.FieldOfView=70
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject=hum end
    end
    if inRound and #fxParts>0 then
        local progress=math.clamp((inRound.progress or 0)+(os.clock()-lastRoundSync)/Config.DropSeconds,0,1)
        local visible=inRound.phase=="drop" and inRound.prize and progress>.43 and progress<.97 and not reducedMotion
        local pose=Config.clawPose(progress,inRound.x,inRound.z,inRound.prize~=nil)
        for i,p in ipairs(fxParts) do
            p.Transparency=if visible then .12 else 1
            if visible then
                local a=os.clock()*5+i*math.pi/5; local radius=1.4+math.sin(a*2)*.25
                p.Position=inRound.origin+Vector3.new(pose.x+math.cos(a)*radius,pose.y-1.3+math.sin(a*1.7)*.7,pose.z+math.sin(a)*radius)
                local size=.1+.1*(.5+.5*math.sin(a*3)); p.Size=Vector3.new(size,size,size)
            end
        end
    end
    local busy=revealItem~=nil or shade.Visible
    local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
    if touchGui and (busy or inRound) then
        if touchOverride~=touchGui then touchOverride=touchGui; touchWasEnabled=touchGui.Enabled end
        touchGui.Enabled=false
    elseif touchOverride then
        if touchOverride.Parent then touchOverride.Enabled=touchWasEnabled end
        touchOverride=nil
    end
    wallet.Visible=not inRound and not busy; menu.Visible=not inRound and not busy
    play.Visible=not busy; hint.Visible=not busy
    timerPill.Visible=inRound and not busy or false
    exit.Visible=inRound and inRound.phase=="aim" and not busy or false
    dpad.Visible=inRound and inRound.phase=="aim" and not busy or false
    guide.Visible=dpad.Visible
    if revealItem and revealModel then
        local t=os.clock()-revealTime
        revealModel:PivotTo(CFrame.new(0,if reducedMotion then 0 else math.sin(t*2.8)*.12,0)*CFrame.Angles(0,if reducedMotion then 0 else math.sin(t*1.3)*.25+math.max(0,1-t/.7)*math.pi*2,0))
        if not reducedMotion then burst.Rotation=t*9 end
    end
    ambientCheck+=dt
    if ambientCheck>2 then
        ambientCheck=0; local plots=workspace:FindFirstChild("ClawEmpirePlots")
        local plot=plots and plots:FindFirstChild("Arcade_"..player.UserId)
        local m=plot and plot:FindFirstChild("ParkLandmarks") and plot.ParkLandmarks:FindFirstChild("FloatingMascot")
        if m~=ambientModel then ambientModel=m; ambientBase=m and m:GetPivot() end
    end
    if ambientModel and ambientModel.Parent and ambientBase then
        local t=os.clock()
        ambientModel:PivotTo(ambientBase*CFrame.new(0,if reducedMotion then 0 else math.sin(t*1.8)*.65,0)*CFrame.Angles(0,if reducedMotion then 0 else t*.18,0))
    end
    elapsed+=dt
    if elapsed>=.1 then
        elapsed=0
        if inRound and inRound.phase=="aim" then
            local left=keys[Enum.KeyCode.A] or keys[Enum.KeyCode.Left] or held.Left
            local right=keys[Enum.KeyCode.D] or keys[Enum.KeyCode.Right] or held.Right
            local up=keys[Enum.KeyCode.W] or keys[Enum.KeyCode.Up] or held.Up
            local down=keys[Enum.KeyCode.S] or keys[Enum.KeyCode.Down] or held.Down
            request:FireServer("aim",{x=(if right then 1 else 0)-(if left then 1 else 0),z=(if down then 1 else 0)-(if up then 1 else 0)})
        end
    end
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
layout(); request:FireServer("sync")
task.spawn(function() while not latest do task.wait(1); request:FireServer("sync") end end)
print("CME_CLIENT_READY",Config.Build)

]====]
for name,source in pairs(src) do local fn,err=loadstring(source); assert(fn,name..": "..tostring(err)) end
local function folder(parent,name) local f=Instance.new("Folder"); f.Name=name; f.Parent=parent; return f end
local rs=folder(game.ReplicatedStorage,"ClawEmpire"); local shared=folder(rs,"Shared"); local server=folder(game.ServerScriptService,"ClawEmpire")
do local obj=Instance.new("ModuleScript"); obj.Name="Config"; obj.Source=src["Config"]; obj.Parent=shared end
do local obj=Instance.new("ModuleScript"); obj.Name="BigNumber"; obj.Source=src["BigNumber"]; obj.Parent=shared end
do local obj=Instance.new("ModuleScript"); obj.Name="Economy"; obj.Source=src["Economy"]; obj.Parent=shared end
do local obj=Instance.new("ModuleScript"); obj.Name="World"; obj.Source=src["World"]; obj.Parent=server end
do local obj=Instance.new("ModuleScript"); obj.Name="ProfileStore"; obj.Source=src["ProfileStore"]; obj.Parent=server end
do local obj=Instance.new("Script"); obj.Name="Bootstrap"; obj.Source=src["Bootstrap"]; obj.Parent=server end
do local obj=Instance.new("LocalScript"); obj.Name="ClawEmpireClient"; obj.Source=src["ClawEmpireClient"]; obj.Parent=game.StarterPlayer.StarterPlayerScripts end
game:GetService("Lighting").ClockTime=14.5; game:GetService("Lighting").Brightness=3
local world=require(server.World); world.build(workspace,"ClawEmpirePreview",Vector3.zero)
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable; workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(245,305,385),Vector3.new(0,0,10))
return "INSTALL_PASS scripts=7 preview=1 purchases=disabled existing-baseplate-and-spawn=preserved"

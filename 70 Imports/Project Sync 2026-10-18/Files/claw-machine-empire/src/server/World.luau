-- Hand-authored parts, cabinet silhouettes and toybox architecture. No Toolbox assets.
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

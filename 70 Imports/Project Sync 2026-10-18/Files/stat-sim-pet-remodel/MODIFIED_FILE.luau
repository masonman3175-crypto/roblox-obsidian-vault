-- Run in the authorized Studio EDIT DataModel. Makes no economy or global-lighting changes.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installation")
assert(game.PlaceId==98823628319724,"Wrong place")
assert(game.ServerStorage:FindFirstChild("PetRemodel_Backup"),"Create the original backup first")
local sources={
["ReplicatedStorage.Shared.Config.PetDesigns"]=[====[-- Appearance only. Pet ids, rarity, power, prices and hatch odds remain in their original configs.
local D = {}
local function d(species, theme, accent, size, feature)
	return {Species=species, Theme=theme, Accent=Color3.fromRGB(unpack(accent)), Size=size or 3.6, Feature=feature}
end
D.List = {
	Doggy=d("Dog","Meadow",{255,232,182}), Kitty=d("Cat","Meadow",{255,220,192}),
	Bunny=d("Bunny","Meadow",{255,160,190}), Fox=d("Fox","Meadow",{255,244,218}),
	Unicorn=d("Unicorn","Prism",{125,230,255},4.4), DemiDog=d("Dog","Royal",{255,105,90},5,"Crown"),
	Bear=d("Bear","Meadow",{243,199,139}), Gorilla=d("Gorilla","Stone",{164,169,194},4),
	Wolf=d("Wolf","Meadow",{221,234,255},3.9), Lion=d("Lion","Royal",{255,227,121},4.3),
	GoldenGorilla=d("Gorilla","Gold",{255,244,166},11,"Crown"), Cerberus=d("Cerberus","Ember",{255,120,55},6),
	GummyBear=d("Bear","Candy",{255,220,72}), LollipopCat=d("Cat","Candy",{105,242,232},3.8,"Lollipop"),
	CupcakePup=d("Dog","Candy",{255,246,225},4,"Cupcake"), CandyDragon=d("Dragon","Candy",{105,239,230},4.8),
	SugarDemon=d("Demon","Candy",{255,209,83},5), RainbowUnicorn=d("Unicorn","Prism",{169,132,255},6,"Wings"),
	ChocoBunny=d("Bunny","Candy",{255,210,170}), MarshmallowSheep=d("Sheep","Candy",{255,154,199},3.9),
	DonutDog=d("Dog","Candy",{255,96,177},4,"Donut"), CottonCandyFairy=d("Fairy","Candy",{255,144,226},4.8),
	CandyKing=d("Lion","Candy",{255,229,98},6,"Crown"), CandyHydra=d("Hydra","Candy",{111,255,219},14),
	Penguin=d("Penguin","Frost",{255,200,68}), SnowFox=d("Fox","Frost",{147,213,255}),
	IceWolf=d("Wolf","Frost",{180,250,255},4.2), Yeti=d("Yeti","Frost",{116,191,240},4.7),
	FrostPhoenix=d("Phoenix","Frost",{219,254,255},6), IceHydra=d("Hydra","Frost",{224,255,255},8),
	SnowOwl=d("Owl","Frost",{163,188,235}), Walrus=d("Walrus","Frost",{255,243,208},4.2),
	PolarBear=d("Bear","Frost",{162,220,244},4.4), IceGolem=d("Golem","Frost",{211,255,255},5),
	FrostTitan=d("Golem","Frost",{217,255,255},12,"Crown"), BlizzardDragon=d("Dragon","Frost",{207,255,255},8),
	MagmaSlime=d("Slime","Ember",{255,223,63}), FireBat=d("Bat","Ember",{255,180,68},4.2),
	LavaHound=d("Dog","Ember",{255,206,58},4.4), FlameGolem=d("Golem","Ember",{255,220,79},5.3),
	Hellhound=d("Wolf","Ember",{255,129,29},6), ThreeHeadedDragon=d("Hydra","Ember",{255,216,66},15),
	EmberFox=d("Fox","Ember",{255,222,113}), ObsidianTurtle=d("Turtle","Ember",{255,124,36},4.1),
	PhoenixChick=d("Phoenix","Ember",{255,235,115},4.4), MagmaTitan=d("Golem","Ember",{255,190,57},7),
	InfernoDemon=d("Demon","Ember",{255,192,56},7), DemonKing=d("Demon","Ember",{255,182,47},17,"Crown"),
	Alien=d("Alien","Cosmic",{189,131,255}), UFOCat=d("Cat","Cosmic",{112,255,221},4.6,"Saucer"),
	StarWolf=d("Wolf","Cosmic",{255,224,108},4.8), NebulaDragon=d("Dragon","Cosmic",{118,255,237},6),
	VoidTitan=d("Golem","Void",{199,119,255},13), CosmicGod=d("Alien","Cosmic",{135,219,255},19,"Halo"),
	MoonBunny=d("Bunny","Cosmic",{157,185,255},4.4), AstroDog=d("Dog","Cosmic",{100,224,255},4.8,"Helmet"),
	MeteorGolem=d("Golem","Cosmic",{255,163,95},5.8), BlackHoleBeast=d("Demon","Void",{181,107,255},7,"Halo"),
	GalaxyLeviathan=d("Dragon","Cosmic",{109,255,231},15), InfinityDragon=d("Dragon","Prism",{143,255,231},22,"Halo"),
	DiamondDog=d("Dog","Frost",{241,255,255},5,"Crown"), RainbowDragon=d("Dragon","Prism",{145,255,227},7),
	GoldenCerberus=d("Cerberus","Gold",{255,249,183},16,"Crown"),
}
D.Themes = {
	Meadow={Color3.fromRGB(157,242,167),"sparkles_main.dds"}, Stone={Color3.fromRGB(178,195,227),"sparkles_main.dds"},
	Royal={Color3.fromRGB(255,222,106),"sparkles_main.dds"}, Gold={Color3.fromRGB(255,216,74),"sparkles_main.dds"},
	Candy={Color3.fromRGB(255,133,214),"sparkles_main.dds"}, Prism={Color3.fromRGB(133,255,229),"sparkles_main.dds"},
	Frost={Color3.fromRGB(156,226,255),"sparkles_main.dds"}, Ember={Color3.fromRGB(255,160,61),"fire_main.dds"},
	Cosmic={Color3.fromRGB(179,143,255),"sparkles_main.dds"}, Void={Color3.fromRGB(174,101,255),"sparkles_main.dds"},
}
return D
]====],
["ReplicatedStorage.Shared.Util.PetModelBuilder"]=[====[-- Original block-creature kit. All geometry is native Roblox parts, no runtime mesh permissions.
local RS = game:GetService("ReplicatedStorage")
local Pets = require(RS.Shared.Config.Pets)
local Designs = require(RS.Shared.Config.PetDesigns)
local B = {}
local V, CF = Vector3.new, CFrame.new
local ink = Color3.fromRGB(25,30,52)
local white = Color3.fromRGB(255,249,239)
local pink = Color3.fromRGB(255,151,185)
local gold = Color3.fromRGB(255,210,68)
local function mix(a,b,t) return a:Lerp(b,t) end

function B.Build(id)
	local pet = assert(Pets.List[id], "Unknown pet "..tostring(id))
	local d = assert(Designs.List[id], "Missing design "..id)
	local model = Instance.new("Model")
	model.Name = id
	model:SetAttribute("PetRemodelVersion",1)
	model:SetAttribute("PetId",id)
	model:SetAttribute("Species",d.Species)
	model:SetAttribute("VisualTheme",d.Theme)
	model:SetAttribute("WorldSize",d.Size)
	model:SetAttribute("Massive",d.Size>=10)
	local base, accent = pet.Color, d.Accent
	local cream = mix(base,white,.78)
	local function part(name,size,cf,color,shape,parent,material)
		local p=Instance.new(if shape=="Wedge" then "WedgePart" else "Part")
		p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color
		p.Material=material or Enum.Material.SmoothPlastic
		p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
		if shape=="Ball" then
			-- SpecialMesh preserves flattened oval proportions (PartType.Ball can appear pin-sized).
			local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
		end
		p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
		p.CastShadow=false; p.Massless=true; p.Parent=parent or model
		return p
	end
	local body=part("Body",V(2.5,2.3,2.15),CF(),base)
	model.PrimaryPart=body
	local function block(n,x,y,z,sx,sy,sz,c) return part(n,V(sx,sy,sz),CF(x,y,z),c) end
	local function eyeFace(x,y,z,s,parent)
		for _,side in {-1,1} do
			part("Eye",V(.66,.78,.15)*s,CF(x+side*.59*s,y+.15*s,z),ink,"Ball",parent)
			part("EyeShine",V(.19,.23,.055)*s,CF(x+side*.59*s-.085*s,y+.29*s,z-.08*s),white,"Ball",parent)
			part("TinyShine",V(.075,.075,.04)*s,CF(x+side*.59*s+.10*s,y+.02*s,z-.082*s),white,"Ball",parent)
			part("Cheek",V(.4,.18,.06)*s,CF(x+side*.9*s,y-.29*s,z+.01*s),pink,"Ball",parent)
		end
		part("Nose",V(.24,.17,.10)*s,CF(x,y-.16*s,z-.05*s),ink,"Ball",parent)
		for _,side in {-1,1} do
			part("Smile",V(.25,.065,.065)*s,CF(x+side*.105*s,y-.36*s,z-.04*s)*CFrame.Angles(0,0,side*.32),ink,nil,parent)
		end
	end
	eyeFace(0,0,-1.12,1,model)
	-- Four little loaf feet retain the square silhouette.
	for _,x in {-1,1} do for _,z in {-.72,.72} do
		block("Paw",x*.83,-1.20,z,.65,.38,.58,cream)
	end end
	block("Belly",0,-.50,-1.082,1.15,.65,.055,cream)
	local function ears(kind)
		for _,side in {-1,1} do
			local x=side*.86
			if kind=="Bunny" then
				part("RabbitEar",V(.64,1.55,.48),CF(x,1.72,0)*CFrame.Angles(0,0,-side*.12),base)
				part("InnerEar",V(.32,1.12,.07),CF(x,1.77,-.255)*CFrame.Angles(0,0,-side*.12),accent)
			elseif kind=="Dog" or kind=="Cerberus" then
				part("FloppyEar",V(.58,1.35,.48),CF(side*1.27,.50,-.12)*CFrame.Angles(0,0,side*.14),mix(base,ink,.25))
			elseif kind=="Bear" or kind=="Gorilla" or kind=="Yeti" then
				part("RoundEar",V(.85,.85,.4),CF(x,1.18,0),base,"Ball")
				part("InnerEar",V(.48,.49,.08),CF(x,1.23,-.215),accent,"Ball")
			else
				part("PointEar",V(.78,1.02,.62),CF(x,1.38,0)*CFrame.Angles(0,side*-.13,side*-.12),base,"Wedge")
				part("EarInset",V(.44,.60,.065),CF(x,1.35,-.325),accent,"Wedge")
			end
		end
	end
	local function crown()
		block("CrownBand",0,1.37,0,1.85,.32,1.3,gold)
		for i=-1,1 do
			block("CrownPoint",i*.62,1.70,-.50,.3,.55,.29,gold)
			part("CrownGem",V(.21,.29,.08),CF(i*.62,1.45,-.68),accent,"Ball")
		end
	end
	local function horns()
		for _,s in {-1,1} do
			part("Horn",V(.52,1,.56),CF(s*.92,1.5,.15)*CFrame.Angles(0,0,-s*.30),accent,"Wedge")
			part("HornTip",V(.28,.65,.3),CF(s*1.08,2,.15)*CFrame.Angles(0,0,-s*.48),cream,"Wedge")
		end
	end
	local function wings(butterfly)
		for _,s in {-1,1} do
			local w=Instance.new("Model"); w.Name="Wing"; w:SetAttribute("Motion","Wing"); w:SetAttribute("Sign",s)
			w.WorldPivot=CF(s*1.08,.2,.45); w.Parent=model
			for j=1,3 do
				local color=if butterfly then mix(accent,white,j*.15) else mix(base,accent,.35+j*.15)
				part("WingFeather",V(.58,1.55-j*.18,.27),CF(s*(1.34+j*.42),.62-j*.12,.40+j*.17)*CFrame.Angles(0,s*-.14,s*(-.48-j*.1)),color,if butterfly then "Ball" else "Wedge",w)
			end
		end
	end
	local function tail()
		part("Tail",V(.58,.62,1.32),CF(.55,-.15,1.52)*CFrame.Angles(.42,.3,.15),base)
		part("TailTip",V(.65,.68,.55),CF(.75,.15,2.10)*CFrame.Angles(.42,.3,.15),accent)
	end
	local function crystal(x,y,z,s,c)
		part("Crystal",V(.45,1.15,.5)*s,CF(x,y,z)*CFrame.Angles(.15,.3,-.2),c,"Wedge")
	end
	local kind=d.Species
	if table.find({"Dog","Cat","Fox","Wolf","Bunny","Bear","Gorilla","Yeti","Unicorn","Lion","Cerberus"},kind) then ears(kind) end
	if kind=="Cat" or kind=="Fox" or kind=="Wolf" or kind=="Unicorn" then tail() end
	if kind=="Fox" or kind=="Wolf" or kind=="Dog" or kind=="Cerberus" then
		for _,s in {-1,1} do part("Muzzle",V(.65,.40,.13),CF(s*.28,-.32,-1.135),cream,"Ball") end
		-- Nose and smile remain in front of the pale muzzle.
		for _,p in model:GetChildren() do if p.Name=="Nose" or p.Name=="Smile" then p.CFrame+=V(0,0,-.10) end end
	end
	if kind=="Lion" then
		for i=1,10 do local a=i*math.pi/5
			part("ManeTuft",V(.62,.65,.50),CF(math.cos(a)*1.29,math.sin(a)*1.14,-.78)*CFrame.Angles(0,0,a),mix(base,accent,.50))
		end
	elseif kind=="Gorilla" or kind=="Golem" or kind=="Yeti" then
		for _,s in {-1,1} do
			block("ChunkyArm",s*1.48,-.20,.05,.73,1.50,1.0,mix(base,ink,.15))
			block("Knuckles",s*1.48,-.86,-.26,.80,.48,.76,accent)
		end
		if kind=="Golem" then for i=-1,1 do crystal(i*.7,1.35,.15,.85,accent) end end
	elseif kind=="Dragon" or kind=="Hydra" or kind=="Demon" or kind=="Bat" then
		horns(); wings(false); tail()
		for i=1,3 do crystal(0,.8-i*.20,.75+i*.40,.7,accent) end
	elseif kind=="Unicorn" then
		part("SpiralHorn",V(.45,1.4,.48),CF(0,1.75,-.52),gold,"Wedge")
		for i=1,4 do block("RainbowMane",.28*math.sin(i),1.18+(i%2)*.12,.15+i*.24,.6,.45,.34,Color3.fromHSV(i/6,.55,1)) end
	elseif kind=="Sheep" then
		for i=1,7 do local a=i*math.pi*2/7 part("WoolPuff",V(.85,.8,.65),CF(math.cos(a)*1.10,math.sin(a)*.94,-.63),white,"Ball") end
		for _,s in {-1,1} do block("SheepEar",s*1.30,.55,0,.6,.35,.55,accent) end
	elseif kind=="Penguin" or kind=="Owl" or kind=="Phoenix" then
		for _,s in {-1,1} do
			part("Flipper",V(.52,1.3,.72),CF(s*1.35,-.05,0)*CFrame.Angles(0,0,s*.3),accent,"Wedge")
			block("BirdFoot",s*.65,-1.35,-.55,.70,.24,.8,accent)
		end
		part("Beak",V(.52,.30,.45),CF(0,-.18,-1.26)*CFrame.Angles(math.pi/2,0,0),accent,"Wedge")
		if kind=="Owl" then
			for _,s in {-1,1} do part("Brow",V(.68,.15,.12),CF(s*.6,.65,-1.21)*CFrame.Angles(0,0,-s*.2),accent) end
		elseif kind=="Phoenix" then wings(false); for i=-1,1 do crystal(i*.45,1.35,0,1.1,accent) end end
	elseif kind=="Walrus" then
		for _,s in {-1,1} do part("Tusk",V(.26,.9,.26),CF(s*.40,-.76,-1.22)*CFrame.Angles(0,0,s*.08),white) end
	elseif kind=="Turtle" then
		block("Shell",0,.17,.40,2.80,2.35,2.25,mix(base,ink,.3))
		for x=-1,1 do for y=-1,1 do block("ShellPlate",x*.73,y*.60,1.55,.65,.52,.12,accent) end end
	elseif kind=="Slime" then
		body.Transparency=.15
		for i=1,4 do part("SlimeBubble",V(.35,.35,.35),CF((i%2-.5)*1.4,1.2+(i%3)*.22,.35),accent,"Ball") end
	elseif kind=="Alien" then
		for _,s in {-1,1} do
			part("Antenna",V(.13,.95,.13),CF(s*.7,1.52,0)*CFrame.Angles(0,0,-s*.3),accent)
			part("AntennaTip",V(.40,.4,.4),CF(s*.85,1.98,0),accent,"Ball")
		end
	elseif kind=="Fairy" then wings(true); part("FairyTiara",V(.7,.7,.3),CF(0,1.4,-.4)*CFrame.Angles(0,0,math.pi/4),gold)
	end
	if kind=="Hydra" or kind=="Cerberus" then
		for _,s in {-1,1} do
			block("SideHead",s*1.40,.36,-.2,1.15,1.15,1.1,base)
			eyeFace(s*1.40,.35,-.80,.43,model)
			part("SideHeadHorn",V(.3,.58,.35),CF(s*1.62,1.13,-.12),accent,"Wedge")
		end
	end
	local f=d.Feature
	if f=="Crown" then crown() end
	if f=="Wings" then wings(true) end
	if f=="Lollipop" then
		block("CandyStick",1.55,.6,.5,.14,1.8,.14,white)
		part("Lollipop",V(1,1,.22),CF(1.55,1.5,.5),accent,"Ball")
		part("CandyCenter",V(.55,.55,.24),CF(1.55,1.5,.36),pink,"Ball")
	elseif f=="Cupcake" then
		block("CupcakeLiner",0,1.35,0,1.3,.55,1.2,accent)
		for i=-1,1 do part("Frosting",V(.65,.6,.85),CF(i*.39,1.72,0),white,"Ball") end
		part("Cherry",V(.4,.4,.4),CF(0,2.08,0),Color3.fromRGB(246,72,110),"Ball")
	elseif f=="Donut" or f=="Saucer" or f=="Halo" or d.Theme=="Cosmic" or d.Theme=="Void" then
		local ring=Instance.new("Model");ring.Name="Orbit";ring:SetAttribute("Motion","Orbit");ring.WorldPivot=CF();ring.Parent=model
		for i=1,12 do local a=i*math.pi/6
			local y=if f=="Halo" then 2.25 else -.10
			part("OrbitTile",V(.34,.16,.56),CF(math.cos(a)*1.62,y,math.sin(a)*1.62)*CFrame.Angles(0,-a,0),if i%3==0 then white else accent,nil,ring)
		end
	end
	if f=="Helmet" then
		local helmet=part("GlassHelmet",V(2.92,2.88,2.7),CF(0,.2,-.08),Color3.fromRGB(177,231,255),"Ball")
		helmet.Transparency=.75
		block("HelmetRim",0,-1.08,0,2.9,.18,2.6,accent)
	end
	if d.Theme=="Frost" then
		for _,s in {-1,1} do crystal(s*.95,.9,.64,.65,accent) end
	elseif d.Theme=="Ember" then
		for _,s in {-1,1} do
			part("LavaSeam",V(.09,.9,.035),CF(s*.98,.05,-1.095)*CFrame.Angles(0,0,s*.30),accent,nil,nil,Enum.Material.Neon)
		end
	elseif d.Theme=="Candy" or d.Theme=="Prism" then
		for i=1,6 do local a=i*2.39
			part("Sprinkle",V(.09,.26,.06),CF(math.sin(a)*.95,.84-(i%3)*.15,-1.105)*CFrame.Angles(0,0,a),Color3.fromHSV(i/6,.55,1))
		end
	elseif d.Theme=="Gold" then
		block("GoldMedallion",0,-.7,-1.17,.48,.44,.12,gold)
	end
	local theme=Designs.Themes[d.Theme]
	local emitter=Instance.new("ParticleEmitter"); emitter.Name="AuraParticles"
	emitter.Texture="rbxasset://textures/particles/"..theme[2]
	emitter.Rate=if d.Size>=10 then 9 elseif Pets.Rarities[pet.Rarity].Order>=4 then 6 else 3
	emitter.Lifetime=NumberRange.new(.65,1.25);emitter.Speed=NumberRange.new(.5,1.4)
	emitter.SpreadAngle=Vector2.new(170,170);emitter.Acceleration=V(0,1.3,0)
	emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.25,.3),NumberSequenceKeypoint.new(1,0)})
	emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.2,.15),NumberSequenceKeypoint.new(1,1)})
	emitter.Color=ColorSequence.new(theme[1],accent);emitter.LightEmission=.35;emitter.LightInfluence=.5
	emitter.Shape=Enum.ParticleEmitterShape.Box;emitter.ShapeStyle=Enum.ParticleEmitterShapeStyle.Surface
	emitter.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
	emitter.Rotation=NumberRange.new(0,360);emitter.RotSpeed=NumberRange.new(-70,70);emitter.Parent=body
	return model
end
return B
]====],
["ReplicatedStorage.Shared.Util.EggVisual"]=[====[-- Studded mystery relics, original per-world palettes, wooden nests and orbiting shards.
local E={}
local V,CF=Vector3.new,CFrame.new
E.Palettes={
	Starter={Color3.fromRGB(35,86,65),Color3.fromRGB(128,255,120),Color3.fromRGB(255,225,120)},
	Buff={Color3.fromRGB(93,44,24),Color3.fromRGB(255,157,56),Color3.fromRGB(255,224,127)},
	Candy={Color3.fromRGB(102,30,94),Color3.fromRGB(255,112,212),Color3.fromRGB(121,255,224)},
	CandyPlus={Color3.fromRGB(66,31,92),Color3.fromRGB(194,140,255),Color3.fromRGB(255,202,101)},
	Frost={Color3.fromRGB(33,70,102),Color3.fromRGB(116,226,255),Color3.fromRGB(230,254,255)},
	FrostPlus={Color3.fromRGB(35,45,96),Color3.fromRGB(141,189,255),Color3.fromRGB(220,255,255)},
	Inferno={Color3.fromRGB(62,31,28),Color3.fromRGB(255,124,49),Color3.fromRGB(255,222,77)},
	InfernoPlus={Color3.fromRGB(48,24,37),Color3.fromRGB(255,75,102),Color3.fromRGB(255,180,64)},
	Galaxy={Color3.fromRGB(34,28,73),Color3.fromRGB(177,121,255),Color3.fromRGB(113,255,232)},
	GalaxyPlus={Color3.fromRGB(22,20,45),Color3.fromRGB(130,143,255),Color3.fromRGB(255,128,232)},
	Mega={Color3.fromRGB(55,48,25),Color3.fromRGB(255,210,73),Color3.fromRGB(255,248,180)},
}
local animations=setmetatable({}, {__mode="k"})
function E.Make(id,options)
	options=options or {}
	local palette=assert(E.Palettes[id],"Unknown egg visual "..tostring(id))
	local dark,glow,accent=table.unpack(palette)
	local m=Instance.new("Model");m.Name="Egg";m:SetAttribute("EggVisualId",id);m:SetAttribute("PetRemodelVersion",1)
	local function p(n,size,cf,color,parent,neon)
		local x=Instance.new("Part");x.Name=n;x.Size=size;x.CFrame=cf;x.Color=color
		x.Material=if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		x.TopSurface=if n=="StuddedShell" then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
		x.BottomSurface=Enum.SurfaceType.Smooth;x.Anchored=true;x.CanCollide=false;x.CanQuery=false;x.CanTouch=false;x.CastShadow=false;x.Parent=parent or m
		return x
	end
	local shell=Instance.new("Model");shell.Name="Shell";shell.WorldPivot=CF();shell.Parent=m
	local root=p("Core",V(5.6,4.8,5.6),CF(0,-.15,0),dark,shell)
	m.PrimaryPart=root
	for i,layer in {{6.25,-1.85,.9},{6.65,-.85,1.05},{5.8,.25,1.2},{4.75,1.35,1.05},{3.55,2.27,.85},{2.1,2.95,.55}} do
		p("StuddedShell",V(layer[1],layer[3],layer[1]),CF(0,layer[2],0),dark:Lerp(glow,.045*i),shell)
		local count=math.max(2,math.floor(layer[1]))
		for x=1,count do for z=1,count do
			if x==1 or z==1 or x==count or z==count then
				local stud=p("ShellStud",V(.13,.34,.34),CF((x-(count+1)/2)*(layer[1]-.6)/(count-1),layer[2]+layer[3]/2+.06,(z-(count+1)/2)*(layer[1]-.6)/(count-1))*CFrame.Angles(0,0,math.pi/2),dark:Lerp(glow,.14+i*.018),shell)
				stud.Shape=Enum.PartType.Cylinder
			end
		end end
	end
	local function segment(n,a,b,width,color,parent)
		return p(n,V(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,parent,true)
	end
	-- Jagged branching energy seams are geometry, not copied textures.
	for side=0,3 do
		local rot=CFrame.Angles(0,side*math.pi/2,0)
		local points={V(-2.2,-1.9,-3.39),V(-1.75,-.85,-3.39),V(-2.05,.15,-2.97),V(-1.2,.75,-2.97),V(-1.45,1.7,-2.45),V(-.8,2.65,-1.84)}
		for i=1,#points-1 do segment("EnergyCrack",rot:PointToWorldSpace(points[i]),rot:PointToWorldSpace(points[i+1]),.075,glow,shell) end
		segment("BranchCrack",rot:PointToWorldSpace(points[3]),rot:PointToWorldSpace(V(-.65,-.15,-2.98)),.055,glow,shell)
		local right={V(2.50,-1.7,-3.39),V(1.85,-1.1,-3.39),V(2.35,-.25,-3.39),V(1.9,.45,-2.97),V(2.1,1.50,-2.45)}
		for i=1,#right-1 do segment("EnergyCrack",rot:PointToWorldSpace(right[i]),rot:PointToWorldSpace(right[i+1]),.065,glow,shell) end
	end
	-- Bold beveled question-mark badge on the front AND back. Also visible in hatch viewports.
	for _,s in {-1,1} do
		local rot=if s==1 then CFrame.new() else CFrame.Angles(0,math.pi,0)
		local function q(a,b) segment("MysteryMark",rot:PointToWorldSpace(a),rot:PointToWorldSpace(b),.28,accent,shell) end
		p("BadgePlate",V(2.65,2.9,.12),rot*CF(0,-.16,-3.48),dark:Lerp(Color3.new(0,0,0),.35),shell)
		q(V(-.62,.82,-3.57),V(.53,.82,-3.57));q(V(.53,.82,-3.57),V(.74,.56,-3.57))
		q(V(.74,.56,-3.57),V(.74,.16,-3.57));q(V(.74,.16,-3.57),V(-.16,-.23,-3.57))
		q(V(-.16,-.23,-3.57),V(-.16,-.60,-3.57))
		p("MysteryDot",V(.33,.33,.15),rot*CF(-.16,-1.12,-3.57),accent,shell,true)
	end
	local nest=Instance.new("Model");nest.Name="WoodenNest";nest.WorldPivot=CF();nest.Parent=m
	for layer=0,1 do for i=1,8 do
		local a=i*math.pi/4+(layer%2)*.2
		local x=p("NestBeam",V(3.95,.48,.67),CF(math.sin(a)*3,-2.8+layer*.37,math.cos(a)*3)*CFrame.Angles(.06*(-1)^i,a+.2,(-1)^i*.07),Color3.fromRGB(139+layer*20,82+layer*12,48),nest)
		x.TopSurface=Enum.SurfaceType.Studs
	end end
	local orbit=Instance.new("Model");orbit.Name="Orbit";orbit.WorldPivot=CF();orbit.Parent=m
	for i=1,8 do
		local a=i*math.pi/4
		local shard=p("FloatingShard",V(.46,.8,.40),CF(math.sin(a)*4.0,.1+math.cos(a*2)*.65,math.cos(a)*4)*CFrame.Angles(.3,a,.55),glow:Lerp(dark,.35),orbit)
		local inset=p("ShardCore",V(.16,.45,.44),shard.CFrame,accent,orbit,true)
	end
	-- A broken double helix rather than a blinding solid ring.
	for i=1,16 do
		local a=i*math.pi/8
		local b=a+.24
		segment("OrbitArc",V(math.sin(a)*3.87,math.cos(a)*1.25,math.cos(a)*3.87),V(math.sin(b)*3.87,math.cos(b)*1.25,math.cos(b)*3.87),.055,glow,orbit)
	end
	for i=1,2 do
		local fx=Instance.new("ParticleEmitter");fx.Name=if i==1 then "RelicSparks" else "RisingMotes"
		fx.Texture="rbxasset://textures/particles/sparkles_main.dds";fx.Rate=if i==1 then 7 else 4
		fx.Lifetime=NumberRange.new(.8,1.5);fx.Speed=NumberRange.new(1,2.7);fx.SpreadAngle=Vector2.new(180,180)
		fx.Acceleration=V(0,2.0,0);fx.Color=ColorSequence.new(glow,accent);fx.LightEmission=.5;fx.LightInfluence=.4
		fx.Size=NumberSequence.new(if i==1 then .35 else .17,0)
		fx.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.15,.12),NumberSequenceKeypoint.new(1,1)})
		fx.Shape=Enum.ParticleEmitterShape.Box;fx.ShapeStyle=Enum.ParticleEmitterShapeStyle.Surface;fx.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
		fx.Rotation=NumberRange.new(0,360);fx.RotSpeed=NumberRange.new(-90,90);fx.Enabled=not options.Preview;fx.Parent=root
	end
	-- Keep the egg pivot on its center, not at the lower layer's center.
	root.PivotOffset=root.CFrame:Inverse()
	if options.Preview then
		nest:Destroy()
		local box,size=m:GetBoundingBox();m:ScaleTo(3/math.max(size.X,size.Y,size.Z))
		local box2=m:GetBoundingBox();root.PivotOffset=root.CFrame:ToObjectSpace(box2);m:PivotTo(CF())
	end
	return m
end
function E.Animate(m,t,visible)
	local a=animations[m]
	if not a then
		a={base=m:GetPivot(),shell=m:FindFirstChild("Shell"),orbit=m:FindFirstChild("Orbit"),fx={}}
		if a.shell then a.rest=a.base:ToObjectSpace(a.shell:GetPivot()) end
		if a.orbit then a.orbitRest=a.base:ToObjectSpace(a.orbit:GetPivot()) end
		for _,x in m:GetDescendants() do if x:IsA("ParticleEmitter") then table.insert(a.fx,x) end end
		animations[m]=a
	end
	for _,x in a.fx do x.Enabled=visible end
	if not visible then return end
	if a.shell then a.shell:PivotTo(a.base*CF(0,math.sin(t*1.6)*.14,0)*a.rest) end
	if a.orbit then a.orbit:PivotTo(a.base*a.orbitRest*CFrame.Angles(0,t*.35,math.sin(t*.5)*.08)) end
end
return E
]====],
["ReplicatedStorage.Shared.Util.PetVisual"]=[====[-- Shared world/preview factory. Size is cosmetic; never changes pet power.
local RS=game:GetService("ReplicatedStorage")
local Builder=require(RS.Shared.Util.PetModelBuilder)
local P={}
local motion=setmetatable({}, {__mode="k"})
function P.Make(id, options)
	options=options or {}
	local folder=RS:FindFirstChild("PetModels")
	local source=folder and folder:FindFirstChild(tostring(id))
	local m=if source and source:GetAttribute("PetRemodelVersion")==1 then source:Clone() else Builder.Build(id)
	local _,s=m:GetBoundingBox()
	local target=if options.Preview then 3 else (m:GetAttribute("WorldSize") or 3.6)
	m:ScaleTo(m:GetScale()*target/math.max(s.X,s.Y,s.Z))
	-- Center the bounding box on the model pivot for predictable UI framing and formations.
	local box,size=m:GetBoundingBox()
	m.PrimaryPart.PivotOffset=m.PrimaryPart.CFrame:ToObjectSpace(box)
	m:PivotTo(CFrame.new())
	m:SetAttribute("VisualExtent",target)
	m:SetAttribute("VisualHeight",size.Y)
	m:SetAttribute("Preview",options.Preview==true)
	for _,p in m:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Massless=true
		elseif p:IsA("ParticleEmitter") then
			p.Enabled=not options.Preview
			-- Large pets should not produce screen-filling particles.
			if target>=10 then p.Size=NumberSequence.new(.45,0);p.Speed=NumberRange.new(.8,2.2) end
		end
	end
	return m
end
function P.Animate(m,t)
	local entries=motion[m]
	if not entries then
		entries={}
		for _,x in m:GetChildren() do if x:IsA("Model") and x:GetAttribute("Motion") then
			table.insert(entries,{x,x:GetAttribute("Motion"),m:GetPivot():ToObjectSpace(x:GetPivot()),x:GetAttribute("Sign") or 1})
		end end
		motion[m]=entries
	end
	for _,e in entries do
		local delta=if e[2]=="Wing" then CFrame.Angles(0,0,math.sin(t*4)*.17*e[4]) else CFrame.Angles(0,t*.55,0)
		e[1]:PivotTo(m:GetPivot()*e[3]*delta)
	end
end
return P
]====],
["StarterPlayer.StarterPlayerScripts.Controllers.PetController"]=[====[-- Cosmetic client followers, size-aware rows, giant companions behind the small ones.
local Http=game:GetService("HttpService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local Visual=require(RS.Shared.Util.PetVisual)
local EggVisual=require(RS.Shared.Util.EggVisual)
local Controller={}
local folder=Instance.new("Folder");folder.Name="PetFollowers"
local followers,signatures,connections={},{},{}
local function clear(owner)
	for _,e in followers[owner] or {} do e.model:Destroy() end
	followers[owner]={}
end
local function rebuild(owner)
	local ok,inv=pcall(Http.JSONDecode,Http,owner:GetAttribute("PetInv") or "[]")
	local ids={}
	if ok and type(inv)=="table" then for _,e in inv do if e.e then table.insert(ids,e.p) end end end
	table.sort(ids)
	local signature=table.concat(ids,",")
	if signatures[owner]==signature then return end
	signatures[owner]=signature;clear(owner)
	for _,id in ids do
		local model=Visual.Make(id)
		local _,size=model:GetBoundingBox()
		local entry={model=model,size=size,fx={},ready=false}
		for _,x in model:GetDescendants() do if x:IsA("ParticleEmitter") then table.insert(entry.fx,x) end end
		model:SetAttribute("OwnerUserId",owner.UserId)
		-- Start at the owner, never flash pets at world origin.
		local root=owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
		if root then model:PivotTo(root.CFrame*CFrame.new(0,0,8+size.Z))
		else model:PivotTo(CFrame.new(0,-1000,0)) end
		model.Parent=folder;table.insert(followers[owner],entry)
	end
	table.sort(followers[owner],function(a,b) return a.size.X<b.size.X end)
	-- A row holds three normal pets OR two giant pets. Width/depth follow actual geometry.
	local rows={};local row={};local giant=nil
	for _,e in followers[owner] do
		local big=e.model:GetAttribute("Massive")==true
		if #row>0 and (big~=giant or #row>=(if big then 2 else 3)) then table.insert(rows,row);row={} end
		giant=big;table.insert(row,e)
	end
	if #row>0 then table.insert(rows,row) end
	local back=5
	for _,r in rows do
		local width,depth=0,0
		for _,e in r do width+=e.size.X+1.3;depth=math.max(depth,e.size.Z) end
		local x=-width/2
		for _,e in r do
			e.offset=Vector3.new(x+e.size.X/2+.65,0,back+depth/2)
			x+=e.size.X+1.3
		end
		back+=depth+2
	end
end
local function track(owner)
	followers[owner]={};rebuild(owner)
	connections[owner]=owner:GetAttributeChangedSignal("PetInv"):Connect(function()rebuild(owner)end)
end
function Controller.Start()
	folder.Parent=workspace
	for _,owner in Players:GetPlayers() do track(owner) end
	Players.PlayerAdded:Connect(track)
	Players.PlayerRemoving:Connect(function(owner)
		clear(owner);followers[owner]=nil;signatures[owner]=nil
		if connections[owner] then connections[owner]:Disconnect();connections[owner]=nil end
	end)
	local eggs={}
	local function addEgg(m) if m:IsA("Model") then eggs[m]=true end end
	for _,m in Tags:GetTagged("RemodeledEgg") do addEgg(m) end
	Tags:GetInstanceAddedSignal("RemodeledEgg"):Connect(addEgg)
	Tags:GetInstanceRemovedSignal("RemodeledEgg"):Connect(function(m) eggs[m]=nil end)
	local accumulator=0
	Run.RenderStepped:Connect(function(dt)
		accumulator+=dt;if accumulator<1/30 then return end
		local step=math.min(accumulator,.1);accumulator=0
		local t=os.clock();local camera=workspace.CurrentCamera
		local eye=if camera then camera.CFrame.Position else Vector3.zero
		for owner,entries in followers do
			local root=owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
			for i,e in entries do
				local visible=root and (root.Position-eye).Magnitude<180
				for _,fx in e.fx do fx.Enabled=visible==true end
				if root then
					local big=e.model:GetAttribute("Massive")
					local ground=root.Position.Y-root.Size.Y/2-(owner.Character:FindFirstChildOfClass("Humanoid") and owner.Character.Humanoid.HipHeight or 2)
					local xz=root.CFrame:PointToWorldSpace(e.offset)
					local y=ground+e.size.Y/2+.65+math.sin(t*(if big then 1.5 else 2.8)+i)*.22
					local goal=CFrame.new(xz.X,y,xz.Z)*root.CFrame.Rotation*CFrame.Angles(0,0,math.sin(t*2+i)*.025)
					if visible then
						e.model:PivotTo(if e.ready then e.model:GetPivot():Lerp(goal,1-math.exp(-8*step)) else goal)
						e.ready=true;Visual.Animate(e.model,t+i)
					else e.model:PivotTo(goal);e.ready=false end
				elseif e.ready then
					e.model:PivotTo(CFrame.new(0,-1000,0));e.ready=false
				end
			end
		end
		for m in eggs do if m.Parent then
			local visible=(m:GetPivot().Position-eye).Magnitude<150
			EggVisual.Animate(m,t,visible)
		else eggs[m]=nil end end
	end)
end
return Controller
]====],
["StarterPlayer.StarterPlayerScripts.Controllers.PetsController"]=[====[-- Pet inventory panel: grid of pet cards, click to equip/unequip, Equip Best.
-- Reads the "PetInv" / "PetSlots" / "Mult_Pets" player attributes; the server owns all changes.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)
local PetVisual = require(ReplicatedStorage.Shared.Util.PetVisual)
local PetDesigns = require(ReplicatedStorage.Shared.Config.PetDesigns)
local UiStyle = require(script.Parent.UiStyle)

local PetsController = {}

local C = UiStyle.Colors
local CARD = Vector2.new(112, 136)

local gui: ScreenGui? = nil
local panel: Frame? = nil
local grid: ScrollingFrame? = nil
local info: TextLabel? = nil
local emptyLabel: TextLabel? = nil
local dirty = true
local onEquip: (string, boolean) -> () = function() end
local onEquipBest: () -> () = function() end
local readState: () -> ({ any }, number, number) = function()
	return {}, PetsConfig.BaseSlots, 1
end

local function scaled(frame: GuiObject)
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	local function update()
		local size = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(math.min(size.X / 1100, size.Y / 700), 0.55, 1)
	end
	update()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
end

local function fmt(n: number): string
	if n >= 1000 then
		return (string.format("%.1fk", n / 1000):gsub("%.0k$", "k"))
	end
	local s = string.format("%.2f", n):gsub("0+$", "")
	return (s:gsub("%.$", ""))
end
PetsController.Format = fmt

-- Pet model posed in a ViewportFrame, facing the camera
function PetsController.Viewport(petId: string, props: { [string]: any }?): ViewportFrame
	local vp = Instance.new("ViewportFrame")
	vp.Name = "Viewport"
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(200, 200, 200)
	vp.LightColor = Color3.fromRGB(255, 255, 255)
	vp.LightDirection = Vector3.new(-1, -1, -1)
	for k, v in props or {} do
		(vp :: any)[k] = v
	end
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0.6, 6.2), Vector3.zero)
	camera.Parent = vp
	vp.CurrentCamera = camera
	local ok, model = pcall(PetVisual.Make, petId, {Preview = true})
	if ok and model then
		model:PivotTo(CFrame.Angles(0, math.pi, 0))
		model.Parent = vp
	end
	return vp
end

local function sortedInventory(inv: { any }): { any }
	local list = table.clone(inv)
	table.sort(list, function(a, b)
		if (a.e == true) ~= (b.e == true) then
			return a.e == true
		end
		local pa = PetsConfig.List[a.p]
		local pb = PetsConfig.List[b.p]
		local powA = if pa then pa.Power else 0
		local powB = if pb then pb.Power else 0
		if powA ~= powB then
			return powA > powB
		end
		return tostring(a.u) < tostring(b.u)
	end)
	return list
end

local function makeCard(entry: any, order: number): TextButton
	local pet = PetsConfig.List[entry.p] or { Name = tostring(entry.p), Rarity = "Common", Power = 0 }
	local rarity = PetsConfig.Rarities[pet.Rarity] or PetsConfig.Rarities.Common
	local modelMassive = PetDesigns.List[entry.p] and PetDesigns.List[entry.p].Size >= 10
	local card = UiStyle.Button({
		Name = "Pet_" .. tostring(entry.u),
		Text = pet.Name,
		Shape = "Square",
		Color = UiStyle.Darken(rarity.Color, 0.25),
		Size = UDim2.fromOffset(CARD.X, CARD.Y),
		LayoutOrder = order,
		MaxTextSize = 18,
		StrokeThickness = 2,
		ZIndex = 12,
	})
	-- green outline when equipped, rarity-tinted otherwise
	local lipStroke = card.Lip:FindFirstChildOfClass("UIStroke")
	if lipStroke then
		lipStroke.Color = if entry.e then C.Green else UiStyle.Darken(rarity.Color, 0.6)
		lipStroke.Thickness = if entry.e then 4 else 3
	end
	card.Label.AnchorPoint = Vector2.new(0.5, 1)
	card.Label.Position = UDim2.new(0.5, 0, 1, -8)
	card.Label.Size = UDim2.fromScale(0.92, 0.17)

	PetsController.Viewport(entry.p, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.1),
		Size = UDim2.fromScale(0.9, 0.6),
		ZIndex = 18,
		Parent = card,
	})

	UiStyle.Label({
		Name = "Power",
		Text = "+" .. fmt(pet.Power),
		TextColor3 = C.Yellow,
		Position = UDim2.fromOffset(6, 4),
		Size = UDim2.new(0.6, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxTextSize = 18,
		StrokeThickness = 2,
		ZIndex = 19,
		Parent = card,
	})
	UiStyle.Label({
		Name = "Rarity",
		Text = (if modelMassive then "HUGE · " else "") .. pet.Rarity,
		TextColor3 = rarity.Color,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -30),
		Size = UDim2.new(0.9, 0, 0, 14),
		MaxTextSize = 14,
		StrokeThickness = 2,
		ZIndex = 19,
		Parent = card,
	})

	-- equipped checkmark reuses the button badge
	local badge = card.Badge
	badge.BackgroundColor3 = C.Green
	badge.Size = UDim2.fromOffset(30, 30)
	badge.Text.Text = "✓"
	badge.Visible = entry.e == true

	local busy = false
	card.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		onEquip(entry.u, not entry.e)
		task.delay(0.3, function()
			busy = false
		end)
	end)
	return card
end

local function render()
	if not grid or not info or not emptyLabel then
		return
	end
	dirty = false
	local inv, slots, mult = readState()
	for _, child in grid:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local equipped = 0
	for i, entry in sortedInventory(inv) do
		if entry.e then
			equipped += 1
		end
		makeCard(entry, i).Parent = grid
	end
	info.Text = string.format("Equipped %d/%d   Pets x%s   %d/%d", equipped, slots, fmt(mult), #inv, PetsConfig.MaxInventory)
	emptyLabel.Visible = #inv == 0
end

local function build(parent: Instance)
	local g = Instance.new("ScreenGui")
	g.Name = "PetsGui"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 10

	local p = UiStyle.Panel({
		Name = "PetsPanel",
		Title = "🐾 Pets",
		Color = C.Purple,
		Size = UDim2.fromOffset(700, 470),
		Parent = g,
	})
	p.Visible = false
	scaled(p)
	p.Close.Activated:Connect(function()
		p.Visible = false
	end)
	local body = p.Body

	info = UiStyle.Label({
		Name = "Info",
		Text = "",
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -210, 0, 32),
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxTextSize = 24,
		ZIndex = 12,
		Parent = body,
	})
	local best = UiStyle.Button({
		Name = "EquipBest",
		Text = "Equip Best",
		Icon = "⭐",
		Color = C.Green,
		Size = UDim2.fromOffset(180, 46),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 4),
		Studs = false,
		ZIndex = 12,
		Parent = body,
	})
	best.Activated:Connect(function()
		onEquipBest()
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Grid"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(6, 58)
	scroll.Size = UDim2.new(1, -12, 1, -64)
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = C.White
	scroll.ZIndex = 12
	scroll.Parent = body
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(CARD.X, CARD.Y)
	layout.CellPadding = UDim2.fromOffset(12, 14)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = scroll
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = scroll
	grid = scroll

	emptyLabel = UiStyle.Label({
		Name = "Empty",
		Text = "Hatch eggs to get pets!",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromOffset(420, 44),
		MaxTextSize = 34,
		ZIndex = 13,
		Parent = body,
	})
	emptyLabel.Visible = false

	-- only rebuild cards while the panel is open
	p:GetPropertyChangedSignal("Visible"):Connect(function()
		if p.Visible and dirty then
			render()
		end
	end)

	panel = p
	gui = g
	g.Parent = parent
end

local function markDirty()
	dirty = true
	if panel and panel.Visible then
		render()
	end
end

function PetsController.Start()
	local player = Players.LocalPlayer
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local equipRemote = remotes:WaitForChild("EquipPet")
	local bestRemote = remotes:WaitForChild("EquipBest")
	onEquip = function(uid, equip)
		equipRemote:FireServer(uid, equip)
	end
	onEquipBest = function()
		bestRemote:FireServer()
	end
	readState = function()
		local inv = {}
		local raw = player:GetAttribute("PetInv")
		if type(raw) == "string" and raw ~= "" then
			local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
			if ok and type(decoded) == "table" then
				inv = decoded
			end
		end
		local slots = player:GetAttribute("PetSlots") or PetsConfig.BaseSlots
		local mult = player:GetAttribute("Mult_Pets")
		if type(mult) ~= "number" then
			local ids = {}
			for _, entry in inv do
				if entry.e then
					table.insert(ids, entry.p)
				end
			end
			mult = PetsConfig.Multiplier(ids)
		end
		return inv, slots, mult
	end
	build(player:WaitForChild("PlayerGui"))
	for _, name in { "PetInv", "PetSlots", "Mult_Pets" } do
		player:GetAttributeChangedSignal(name):Connect(markDirty)
	end
end

function PetsController.Toggle()
	if panel then
		panel.Visible = not panel.Visible
	end
end

function PetsController.Open()
	if panel then
		panel.Visible = true
	end
end

-- Edit-mode visual check only: builds the open panel with fake pets under parent
function PetsController.Preview(parent: Instance, inv: { any }): ScreenGui?
	readState = function()
		return inv, PetsConfig.BaseSlots, 7.45
	end
	build(parent)
	if panel then
		panel.Visible = true
	end
	render()
	return gui
end

return PetsController

]====],
["StarterPlayer.StarterPlayerScripts.Controllers.HatchController"]=[====[-- Hatch animation: egg shakes, white flash, pets pop out spinning with name + rarity.
-- Legendary / Mythic add a rainbow burst, a banner and a UI shake. Driven by the HatchFx remote.
-- Never sinks input; full version < 3 s, auto-hatch version ~0.6 s.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EggsConfig = require(ReplicatedStorage.Shared.Config.Eggs)
local PetsConfig = require(ReplicatedStorage.Shared.Config.Pets)
local UiStyle = require(script.Parent.UiStyle)
local PetsController = require(script.Parent.PetsController)

local HatchController = {}

local C = UiStyle.Colors
local MAX_QUEUE = 2

local EGG_COLORS = {
	Starter = Color3.fromRGB(255, 240, 200),
	Buff = Color3.fromRGB(255, 120, 60),
	Candy = Color3.fromRGB(255, 130, 200),
	CandyPlus = Color3.fromRGB(255, 80, 170),
	Frost = Color3.fromRGB(150, 220, 255),
	FrostPlus = Color3.fromRGB(90, 170, 255),
	Inferno = Color3.fromRGB(255, 90, 30),
	InfernoPlus = Color3.fromRGB(200, 30, 30),
	Galaxy = Color3.fromRGB(120, 70, 220),
	GalaxyPlus = Color3.fromRGB(70, 30, 160),
	Mega = Color3.fromRGB(255, 200, 40),
}

local gui: ScreenGui? = nil
local stage: Frame? = nil
local queue = {}
local playing = false

local function tween(obj: Instance, t: number, props: { [string]: any }, style: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function scaled(frame: GuiObject)
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	local function update()
		local size = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(math.min(size.X / 1100, size.Y / 700), 0.55, 1)
	end
	update()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
end

-- Uses the same mystery relic geometry as the world stand, normalized for UI.
local function eggViewport(eggId: string): ViewportFrame
	local vp=Instance.new("ViewportFrame")
	vp.Name="Egg";vp.BackgroundTransparency=1;vp.AnchorPoint=Vector2.new(.5,.5)
	vp.Position=UDim2.fromScale(.5,.5);vp.Size=UDim2.fromOffset(260,260)
	vp.Ambient=Color3.fromRGB(210,210,220);vp.LightColor=Color3.new(1,1,1)
	vp.LightDirection=Vector3.new(-1,-1,-1);vp.ZIndex=5
	local camera=Instance.new("Camera");camera.FieldOfView=40
	camera.CFrame=CFrame.lookAt(Vector3.new(1,.65,6.4),Vector3.zero)
	camera.Parent=vp;vp.CurrentCamera=camera
	local model=require(ReplicatedStorage.Shared.Util.EggVisual).Make(eggId,{Preview=true})
	model:PivotTo(CFrame.Angles(0,math.pi,0));model.Parent=vp
	return vp
end

local function rainbowBurst(parent: Instance, hold: boolean)
	local burst = Instance.new("Frame")
	burst.Name = "Burst"
	burst.AnchorPoint = Vector2.new(0.5, 0.5)
	burst.Position = UDim2.fromScale(0.5, 0.5)
	burst.Size = UDim2.fromScale(0.2, 0.2)
	burst.SizeConstraint = Enum.SizeConstraint.RelativeXX
	burst.BackgroundColor3 = C.White
	burst.BackgroundTransparency = 0.25
	burst.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = burst
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 70)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 40)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 60)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(80, 230, 90)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(60, 160, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 80, 255)),
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	grad.Parent = burst
	burst.Parent = parent
	tween(burst, 0.5, { Size = UDim2.fromScale(1.4, 1.4) }, Enum.EasingStyle.Back)
	local conn = RunService.RenderStepped:Connect(function(dt)
		grad.Rotation = (grad.Rotation + dt * 180) % 360
	end)
	burst.Destroying:Connect(function()
		conn:Disconnect()
	end)
	if not hold then
		task.delay(1, function()
			if burst.Parent then
				tween(burst, 0.4, { BackgroundTransparency = 1 })
			end
		end)
	end
end

local function shake(frame: GuiObject, duration: number, strength: number)
	task.spawn(function()
		local base = frame.Position
		local t0 = os.clock()
		while os.clock() - t0 < duration and frame.Parent do
			local k = 1 - (os.clock() - t0) / duration
			frame.Position = base + UDim2.fromOffset(math.random(-strength, strength) * k, math.random(-strength, strength) * k)
			task.wait()
		end
		frame.Position = base
	end)
end

local function petReveal(petId: string, index: number, count: number, parent: Instance, delayTime: number): Frame
	local pet = PetsConfig.List[petId] or { Name = tostring(petId), Rarity = "Common", Power = 0 }
	local rarity = PetsConfig.Rarities[pet.Rarity] or PetsConfig.Rarities.Common
	local holder = Instance.new("Frame")
	holder.Name = "Pet" .. index
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Position = UDim2.new(0.5, (index - (count + 1) / 2) * 240, 0.5, 0)
	holder.Size = UDim2.fromOffset(230, 300)
	holder.ZIndex = 6
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = holder

	-- soft rarity glow behind the pet
	local glow = Instance.new("Frame")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.36)
	glow.Size = UDim2.fromOffset(200, 200)
	glow.BackgroundColor3 = rarity.Color
	glow.ZIndex = 6
	local gc = Instance.new("UICorner")
	gc.CornerRadius = UDim.new(1, 0)
	gc.Parent = glow
	local gg = Instance.new("UIGradient")
	gg.Rotation = 90
	gg.Transparency = NumberSequence.new(0.15, 0.9)
	gg.Parent = glow
	local gs = Instance.new("UIStroke")
	gs.Thickness = 4
	gs.Color = C.Outline
	gs.Parent = glow
	glow.Parent = holder

	local vp = PetsController.Viewport(petId, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromOffset(210, 210),
		ZIndex = 7,
		Parent = holder,
	})
	local model = vp:FindFirstChildOfClass("Model")
	if model then
		local angle = math.pi
		local conn = RunService.RenderStepped:Connect(function(dt)
			angle += dt * 2.5
			model:PivotTo(CFrame.Angles(0, angle, 0))
		end)
		holder.Destroying:Connect(function()
			conn:Disconnect()
		end)
	end

	UiStyle.Label({
		Name = "PetName",
		Text = pet.Name,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.72),
		Size = UDim2.fromOffset(230, 38),
		MaxTextSize = 34,
		StrokeThickness = 4,
		ZIndex = 8,
		Parent = holder,
	})
	UiStyle.Label({
		Name = "Rarity",
		Text = pet.Rarity .. "  +" .. PetsController.Format(pet.Power),
		TextColor3 = rarity.Color,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.86),
		Size = UDim2.fromOffset(230, 28),
		MaxTextSize = 26,
		StrokeThickness = 3,
		ZIndex = 8,
		Parent = holder,
	})
	holder.Parent = parent
	task.delay(delayTime, function()
		tween(scale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	return holder
end

local function banner(text: string, color: Color3, parent: Instance)
	local label = UiStyle.Label({
		Name = "Banner",
		Text = text,
		TextColor3 = color,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -215),
		Size = UDim2.fromOffset(640, 92),
		MaxTextSize = 84,
		StrokeThickness = 6,
		ZIndex = 9,
		Parent = parent,
	})
	label.Rotation = -4
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = label
	tween(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function play(eggId: string, petIds: { string }, isAuto: boolean, hold: boolean?)
	local root = stage
	if not root then
		return
	end
	local scene = Instance.new("Frame")
	scene.Name = "Scene"
	scene.BackgroundTransparency = 1
	scene.Size = UDim2.fromScale(1, 1)
	scene.Parent = root

	local center = Instance.new("Frame")
	center.Name = "Center"
	center.BackgroundTransparency = 1
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.Position = UDim2.fromScale(0.5, 0.5)
	center.Size = UDim2.fromOffset(800, 600)
	center.ZIndex = 3
	center.Parent = scene
	scaled(center)

	-- 1. egg shakes harder and harder
	local shakeTime = if isAuto then 0.25 else 1.2
	local egg = eggViewport(eggId)
	egg.Parent = center
	local eggScale = Instance.new("UIScale")
	eggScale.Scale = 0.6
	eggScale.Parent = egg
	tween(eggScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
	local t0 = os.clock()
	while os.clock() - t0 < shakeTime do
		local k = (os.clock() - t0) / shakeTime
		egg.Rotation = math.sin(os.clock() * (18 + k * 30)) * (4 + k * 22)
		eggScale.Scale = 1 + k * 0.15
		task.wait()
	end

	-- 2. white flash, egg cracks open
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = C.White
	flash.ZIndex = 20
	flash.Parent = scene
	tween(flash, if isAuto then 0.2 else 0.45, { BackgroundTransparency = 1 })
	egg:Destroy()

	-- 3. reveal pets (best rarity decides the extras)
	local best = 0
	local bestRarity = "Common"
	for _, id in petIds do
		local pet = PetsConfig.List[id]
		local r = pet and PetsConfig.Rarities[pet.Rarity]
		if r and r.Order > best then
			best = r.Order
			bestRarity = pet.Rarity
		end
	end
	local count = math.min(#petIds, 3)
	for i = 1, count do
		petReveal(petIds[i], i, count, center, (i - 1) * (if isAuto then 0.03 else 0.12))
	end
	if bestRarity == "Legendary" or bestRarity == "Mythic" then
		rainbowBurst(scene, hold == true)
		local text = if bestRarity == "Mythic" then "MYTHIC!!" else "LEGENDARY!"
		banner(text, PetsConfig.Rarities[bestRarity].Color, center)
		shake(center, if isAuto then 0.3 else 0.6, if bestRarity == "Mythic" then 16 else 10)
	end
	if hold then
		return
	end

	-- 4. hold, then shrink away
	task.wait(if isAuto then 0.35 else 1.1)
	for _, child in center:GetChildren() do
		local s = child:FindFirstChildOfClass("UIScale")
		if s then
			tween(s, 0.2, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		end
	end
	task.wait(0.22)
	scene:Destroy()
end

local function pump()
	if playing then
		return
	end
	playing = true
	while #queue > 0 do
		local job = table.remove(queue, 1)
		local ok, err = pcall(play, job[1], job[2], job[3])
		if not ok then
			warn("HatchController:", err)
		end
	end
	playing = false
end

local function build(parent: Instance)
	local g = Instance.new("ScreenGui")
	g.Name = "HatchGui"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 30
	local s = Instance.new("Frame")
	s.Name = "Stage"
	s.BackgroundTransparency = 1
	s.Size = UDim2.fromScale(1, 1)
	s.Parent = g
	stage = s
	gui = g
	g.Parent = parent
end

-- Public so other UI (egg prompts, tests) can trigger the same animation
function HatchController.Play(eggId: string, petIds: { string }, isAuto: boolean?)
	if type(petIds) ~= "table" or #petIds == 0 then
		return
	end
	if #queue >= MAX_QUEUE then
		table.remove(queue, 1)
	end
	table.insert(queue, { eggId, petIds, isAuto == true })
	task.spawn(pump)
end

function HatchController.Start()
	local player = Players.LocalPlayer
	build(player:WaitForChild("PlayerGui"))
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	remotes:WaitForChild("HatchFx").OnClientEvent:Connect(function(eggId, petIds, isAuto)
		if type(eggId) == "string" and EggsConfig.List[eggId] then
			HatchController.Play(eggId, petIds, isAuto)
		end
	end)
end

-- Edit-mode visual check only: freezes on the reveal so it can be screenshotted
function HatchController.Preview(parent: Instance, eggId: string, petIds: { string }): ScreenGui?
	build(parent)
	task.spawn(play, eggId, petIds, true, true)
	return gui
end

return HatchController

]====],
["ServerScriptService.Services.EggService"]=[====[-- Egg stands, hatching (odds on the board), pet inventory and equipping.
-- Everything is decided here; the client only plays the hatch animation.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage.Shared.Config
local Eggs = require(Config.Eggs)
local PetsConfig = require(Config.Pets)
local Zones = require(Config.Zones)
local Monetization = require(Config.Monetization)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.Parent.DataService)
local StatService = require(script.Parent.StatService)

local EggService = {}

local HATCH_COOLDOWN = 2.5
local AUTO_INTERVAL = 3.5
local AUTO_RANGE = 22
local rng = Random.new()
local lastHatch = {}
local stands = {}

local function power(id)
	local p = PetsConfig.List[id]
	return if p then p.Power else 0
end

-- Equip the strongest pets up to the slot limit
function EggService.EquipBest(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local sorted = table.clone(profile.PetInv)
	table.sort(sorted, function(a, b)
		return power(a.p) > power(b.p)
	end)
	local slots = StatService.PetSlots(player)
	for _, entry in profile.PetInv do
		entry.e = false
	end
	for i = 1, math.min(slots, #sorted) do
		sorted[i].e = true
	end
	StatService.Refresh(player)
end

local function onEquip(player, uid, equip)
	local profile = DataService.Get(player)
	if not profile or typeof(uid) ~= "string" or typeof(equip) ~= "boolean" then
		return
	end
	local target = nil
	local equipped = 0
	for _, entry in profile.PetInv do
		if entry.u == uid then
			target = entry
		end
		if entry.e then
			equipped += 1
		end
	end
	if not target or target.e == equip then
		return
	end
	if equip and equipped >= StatService.PetSlots(player) then
		Remotes.Notify:FireClient(player, "All pet slots full! Unequip one or get +3 Pet Slots")
		return
	end
	target.e = equip
	StatService.Refresh(player)
end

-- free = true for the paid Mega Egg (already paid in Robux)
function EggService.Hatch(player, eggId, count, isAuto, free)
	local profile = DataService.Get(player)
	local egg = Eggs.List[eggId]
	if not profile or not egg then
		return false
	end
	if egg.World > StatService.AllowedWorld(profile) then
		Remotes.Notify:FireClient(player, "Unlock " .. Zones.List[egg.World].Name .. " World first")
		return false
	end
	if #profile.PetInv + count > PetsConfig.MaxInventory then
		Remotes.Notify:FireClient(player, "Pet inventory full (" .. PetsConfig.MaxInventory .. ")")
		return false
	end
	if not free then
		local cost = egg.Cost * count
		if profile.Coins < cost then
			if not isAuto then
				Remotes.Notify:FireClient(player, "Need " .. Format.Number(cost) .. " Coins. Punch the dummy!")
			end
			return false
		end
		profile.Coins -= cost
	end
	local lucky = StatService.IsLucky(player)
	local hatched = {}
	for _ = 1, count do
		local id = Eggs.Roll(eggId, lucky, rng)
		table.insert(profile.PetInv, {u = tostring(profile.NextPetUid), p = id, e = false})
		profile.NextPetUid += 1
		table.insert(hatched, id)
	end
	EggService.EquipBest(player)
	Remotes.HatchFx:FireClient(player, eggId, hatched, isAuto)
	for _, id in hatched do
		local rarity = PetsConfig.List[id].Rarity
		if rarity == "Legendary" or rarity == "Mythic" then
			for _, other in Players:GetPlayers() do
				Remotes.Notify:FireClient(other, player.DisplayName .. " hatched a " .. string.upper(rarity) .. " " .. PetsConfig.List[id].Name .. "!")
			end
		end
	end
	return true
end

local function tryHatch(player, eggId, count)
	local now = os.clock()
	if lastHatch[player] and now - lastHatch[player] < HATCH_COOLDOWN then
		return
	end
	lastHatch[player] = now
	if count > 1 and not StatService.OwnsPass(player, "TripleHatch") then
		local pass = Monetization.Passes.TripleHatch
		if pass.Id ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, pass.Id)
		elseif RunService:IsStudio() then
			Remotes.Notify:FireClient(player, "Triple Hatch is a pass (free in Studio from the shop)")
		else
			Remotes.Notify:FireClient(player, "Triple Hatch is coming soon")
		end
		return
	end
	EggService.Hatch(player, eggId, count, false, false)
end

local function promptMega(player)
	local product = Monetization.Products.MegaEgg
	if product.Id == 0 then
		if RunService:IsStudio() then
			EggService.Hatch(player, "Mega", 1, false, true)
		else
			Remotes.Notify:FireClient(player, "Mega Egg is coming soon")
		end
		return
	end
	MarketplaceService:PromptProductPurchase(player, product.Id)
end

-- Cosmetic factory only: hatching, currency, pass checks and odds are unchanged.
local function eggModel(eggId)
	return require(ReplicatedStorage.Shared.Util.EggVisual).Make(eggId)
end

local function oddsBoard(stand, eggId)
	local egg = Eggs.List[eggId]
	local lines = {}
	for _, entry in egg.Pets do
		local pet = PetsConfig.List[entry.Id]
		local color = PetsConfig.Rarities[pet.Rarity].Color
		table.insert(lines, string.format("<font color=\"#%s\">%s</font> %s%%", color:ToHex(), pet.Name, tostring(entry.Chance)))
	end
	local price = if egg.ProductKey then "ROBUX EGG" else Format.Number(egg.Cost) .. " Coins"
	local bb = Instance.new("BillboardGui")
	bb.Name = "Odds"
	bb.Size = UDim2.fromOffset(240, 200)
	bb.StudsOffset = Vector3.new(0, 12, 0)
	bb.MaxDistance = 90
	bb.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	t.BackgroundTransparency = 0.25
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.RichText = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Text = string.format("<b>%s</b>\n<font color=\"#FFD84A\">%s</font>\n%s", string.upper(egg.Name), price, table.concat(lines, "\n"))
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = t
	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Parent = t
	t.Parent = bb
	bb.Parent = stand
end

local function prompt(stand, name, action, key, hold)
	local p = Instance.new("ProximityPrompt")
	p.Name = name
	p.ActionText = action
	p.ObjectText = ""
	p.HoldDuration = hold
	p.KeyboardKeyCode = key
	p.MaxActivationDistance = 14
	p.RequiresLineOfSight = false
	p.Parent = stand
	return p
end

local function setupStand(stand)
	local eggId = stand:GetAttribute("EggId")
	local egg = eggId and Eggs.List[eggId]
	if not egg then
		return
	end
	stands[stand] = eggId
	local color = if egg.ProductKey then Color3.fromRGB(255, 200, 40) else Zones.List[egg.World].Color
	for _, child in stand:GetChildren() do
		if child.Name == "EggPreview" or child.Name == "Egg" then child:Destroy() end
	end
	local model = eggModel(eggId)
	model:PivotTo(stand.CFrame * CFrame.new(0, stand.Size.Y / 2 + 3.4, 0))
	model.Parent = stand
	game:GetService("CollectionService"):AddTag(model, "RemodeledEgg")
	oddsBoard(stand, eggId)
	if egg.ProductKey then
		prompt(stand, "BuyPrompt", "Buy Mega Egg", Enum.KeyCode.E, 0).Triggered:Connect(promptMega)
	else
		prompt(stand, "HatchPrompt", "Hatch (" .. Format.Number(egg.Cost) .. ")", Enum.KeyCode.E, 0.2).Triggered:Connect(function(player)
			tryHatch(player, eggId, 1)
		end)
		prompt(stand, "Hatch3Prompt", "Hatch x3", Enum.KeyCode.R, 0.2).Triggered:Connect(function(player)
			tryHatch(player, eggId, 3)
		end)
	end
end

local function nearestStand(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local best, bestDist = nil, AUTO_RANGE
	for stand, eggId in stands do
		if not Eggs.List[eggId].ProductKey then
			local d = (stand.Position - root.Position).Magnitude
			if d < bestDist then
				best, bestDist = eggId, d
			end
		end
	end
	return best
end

function EggService.Start()
	for _, stand in workspace:WaitForChild("Map"):WaitForChild("Gameplay"):GetDescendants() do
		if stand:IsA("BasePart") and stand:GetAttribute("EggId") then
			setupStand(stand)
		end
	end
	Remotes.EquipPet.OnServerEvent:Connect(onEquip)
	Remotes.EquipBest.OnServerEvent:Connect(EggService.EquipBest)
	Players.PlayerRemoving:Connect(function(player)
		lastHatch[player] = nil
	end)

	-- Auto Hatch pass: hatches the closest egg while you stand near it
	task.spawn(function()
		while true do
			task.wait(AUTO_INTERVAL)
			for _, player in Players:GetPlayers() do
				local profile = DataService.Get(player)
				if profile and profile.AutoHatchOn and StatService.OwnsPass(player, "AutoHatch") then
					local eggId = nearestStand(player)
					if eggId then
						local count = if StatService.OwnsPass(player, "TripleHatch") then 3 else 1
						EggService.Hatch(player, eggId, count, true, false)
					end
				end
			end
		end
	end)
end

return EggService

]====],
}

local function resolve(path)
 local x=game
 for n in path:gmatch("[^.]+") do x=x:FindFirstChild(n) assert(x,"Missing parent "..path) end
 return x
end
local order={"ReplicatedStorage.Shared.Config.PetDesigns","ReplicatedStorage.Shared.Util.PetModelBuilder","ReplicatedStorage.Shared.Util.EggVisual","ReplicatedStorage.Shared.Util.PetVisual","StarterPlayer.StarterPlayerScripts.Controllers.PetController","StarterPlayer.StarterPlayerScripts.Controllers.PetsController","StarterPlayer.StarterPlayerScripts.Controllers.HatchController","ServerScriptService.Services.EggService"}
-- Compile every source before touching the live place.
for path,source in sources do local fn,err=loadstring(source) assert(fn,path..": "..tostring(err)) end
for _,path in order do
 local parentPath,name=path:match("^(.*)%.([^.]+)$")
 local parent=resolve(parentPath)
 local old=parent:FindFirstChild(name)
 local m=Instance.new("ModuleScript");m.Name=name;m.Source=sources[path];m:SetAttribute("PetRemodelVersion",1)
 if old then old:Destroy() end
 m.Parent=parent
end
local pets=Instance.new("Folder");pets.Name="PetModels_RemodelStaging"
local Builder=require(game.ReplicatedStorage.Shared.Util.PetModelBuilder)
local ids={} for id in require(game.ReplicatedStorage.Shared.Config.Pets).List do table.insert(ids,id) end table.sort(ids)
for i,id in ids do Builder.Build(id).Parent=pets if i%7==0 then task.wait() end end
assert(#pets:GetChildren()==63)
local old=game.ReplicatedStorage:FindFirstChild("PetModels") if old then old:Destroy() end
pets.Name="PetModels";pets.Parent=game.ReplicatedStorage
local E=require(game.ReplicatedStorage.Shared.Util.EggVisual)
local n=0
for _,stand in workspace.Map.Gameplay:GetDescendants() do
 if stand:IsA("BasePart") and stand:GetAttribute("EggId") then
  for _,x in stand:GetChildren() do if x.Name=="EggPreview" or x.Name=="Egg" then x:Destroy() end end
  local model=E.Make(stand:GetAttribute("EggId"))
  model.Name="EggPreview";model:PivotTo(stand.CFrame*CFrame.new(0,stand.Size.Y/2+3.4,0));model.Parent=stand
  n+=1
 end
end
assert(n==11)
game.ServerStorage.PetRemodel_Backup:SetAttribute("InstalledVersion",1)
return "INSTALL_PASS pet_models=63 egg_previews=11 sources=8 economy=untouched"

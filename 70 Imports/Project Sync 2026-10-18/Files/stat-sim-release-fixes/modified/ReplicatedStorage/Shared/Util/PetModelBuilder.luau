-- Original block-creature kit. All geometry is native Roblox parts, no runtime mesh permissions.
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


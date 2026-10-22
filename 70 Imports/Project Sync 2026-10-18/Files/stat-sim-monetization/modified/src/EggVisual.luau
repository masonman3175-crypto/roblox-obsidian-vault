-- Studded mystery relics, original per-world palettes, wooden nests and orbiting shards.
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
	Ultra={Color3.fromRGB(31,21,69),Color3.fromRGB(169,92,255),Color3.fromRGB(95,255,229)},
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

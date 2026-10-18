local SS=game:GetService("ServerStorage")
local W={}
local function part(parent,name,size,cf,color,material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function W.House(parent,index,userId,center)
    local m=Instance.new("Model");m.Name="House_"..userId;m:SetAttribute("OwnerUserId",userId);m:SetAttribute("HouseIndex",index)
    m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
    local cf=CFrame.new(center)
    part(m,"Floor",Vector3.new(24,1,20),cf*CFrame.new(0,0,0),Color3.fromRGB(77,62,51),Enum.Material.WoodPlanks)
    part(m,"BackWall",Vector3.new(24,11,.6),cf*CFrame.new(0,5.5,10),Color3.fromRGB(93,97,90))
    part(m,"LeftWall",Vector3.new(.6,11,20),cf*CFrame.new(-12,5.5,0),Color3.fromRGB(93,97,90))
    part(m,"RightWall",Vector3.new(.6,11,20),cf*CFrame.new(12,5.5,0),Color3.fromRGB(93,97,90))
    part(m,"WindowWallLeft",Vector3.new(6,11,.6),cf*CFrame.new(-9,5.5,-10),Color3.fromRGB(93,97,90))
    part(m,"WindowWallRight",Vector3.new(10,11,.6),cf*CFrame.new(7,5.5,-10),Color3.fromRGB(93,97,90))
    part(m,"WindowSill",Vector3.new(8,3,.8),cf*CFrame.new(-2,1.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
    part(m,"WindowHeader",Vector3.new(8,3,.8),cf*CFrame.new(-2,9.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
    local glass=part(m,"Window",Vector3.new(8,5,.15),cf*CFrame.new(-2,5.5,-10),Color3.fromRGB(77,91,105),Enum.Material.Glass);glass.Transparency=.35
    part(m,"WindowMullion",Vector3.new(.15,5,.2),cf*CFrame.new(-2,5.5,-9.85),Color3.fromRGB(43,46,43))
    local ceiling=part(m,"Ceiling",Vector3.new(24,.5,20),cf*CFrame.new(0,11,0),Color3.fromRGB(91,92,85))
    local fill=Instance.new("PointLight");fill.Brightness=2.5;fill.Range=23;fill.Color=Color3.fromRGB(214,203,180);fill.Shadows=false;fill.Parent=ceiling
    for _,z in {-9.7,9.7}do part(m,"Skirting",Vector3.new(24,.5,.2),cf*CFrame.new(0,.8,z),Color3.fromRGB(45,41,35),Enum.Material.Wood)end
    local bed=SS.SurvivalBedAsset:Clone();bed.Name="Bed"
    local box=bed:GetBoundingBox();local relative=bed:GetPivot():ToObjectSpace(box)
    bed:PivotTo(cf*CFrame.new(-4,3,1)*relative:Inverse())
    for _,v in bed:GetDescendants()do
        if v:IsA("BasePart")then v.Anchored=true
        elseif v:IsA("LuaSourceContainer")then v:Destroy()end
    end
    bed.Parent=m
    local tableTop=part(m,"Nightstand",Vector3.new(2,2.2,2),cf*CFrame.new(3,1.6,1),Color3.fromRGB(52,39,29),Enum.Material.Wood)
    local lamp=part(m,"Lamp",Vector3.new(.8,1.5,.8),tableTop.CFrame*CFrame.new(0,1.8,0),Color3.fromRGB(205,169,104),Enum.Material.Neon)
    local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,194,119);light.Brightness=1.3;light.Range=18;light.Parent=lamp
    part(m,"Rug",Vector3.new(7,.08,5),cf*CFrame.new(5,.55,2),Color3.fromRGB(66,62,59),Enum.Material.Fabric)
    local door=part(m,"FrontDoor",Vector3.new(3.5,7,.3),cf*CFrame.new(8,4.1,9.5),Color3.fromRGB(53,41,31),Enum.Material.Wood)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="ExitHouse";prompt.ActionText="Go outside";prompt.ObjectText="Your front door";prompt.HoldDuration=.35;prompt.MaxActivationDistance=7;prompt.Parent=door
    local windowPoint=part(m,"WindowPoint",Vector3.new(.2,.2,.2),cf*CFrame.new(-2,4,-6),Color3.new());windowPoint.Transparency=1;windowPoint.CanCollide=false;windowPoint.CanQuery=false
    m.Parent=parent
    return {Model=m,Lie=cf*CFrame.new(-3,3.65,1)*CFrame.Angles(0,0,-math.pi/2),Stand=cf*CFrame.new(5,3.6,2),Window=cf*CFrame.new(-2,3.6,-6),Prompt=prompt,WindowPart=windowPoint}
end
local function attached(parent,name,size,localCF,body,color,shape)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=body.CFrame*localCF;p.Color=color
    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Material=Enum.Material.Fabric
    if shape then p.Shape=shape end
    p.Parent=parent;local weld=Instance.new("WeldConstraint");weld.Part0=body;weld.Part1=p;weld.Parent=p;return p
end
function W.Zombie(template,parent,position,party)
    local z=template:Clone();z.Name="HoodedInfected";z:SetAttribute("SurvivalZombie",true);z:SetAttribute("PartyId",party)
    z.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
    z.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    local head=z.Head;local torso=z.UpperTorso;local dark=Color3.fromRGB(25,29,31)
    for _,v in head:GetChildren()do if v:IsA("Decal")then v:Destroy()end end
    attached(z,"HoodBack",Vector3.new(head.Size.X+.2,head.Size.Y+.4,.35),CFrame.new(0,.05,head.Size.Z/2+.05),head,dark)
    attached(z,"HoodLeft",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(-head.Size.X/2-.06,.05,0),head,dark)
    attached(z,"HoodRight",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(head.Size.X/2+.06,.05,0),head,dark)
    attached(z,"HoodTop",Vector3.new(head.Size.X+.5,.6,head.Size.Z+.4),CFrame.new(0,head.Size.Y/2+.13,0),head,dark,Enum.PartType.Ball)
    attached(z,"HoodiePocket",Vector3.new(.9,.4,.12),CFrame.new(0,-.45,-.53),torso,Color3.fromRGB(39,43,44))
    for _,x in {-.28,.28}do
        attached(z,"Drawstring",Vector3.new(.05,.55,.05),CFrame.new(x,.2,-.55),torso,Color3.fromRGB(140,142,129))
        local eye=attached(z,"RedEye",Vector3.new(.14,.14,.10),CFrame.new(x,.14,-head.Size.Z/2-.06),head,Color3.fromRGB(255,38,40),Enum.PartType.Ball)
        eye.Material=Enum.Material.Neon
        local light=Instance.new("PointLight");light.Color=eye.Color;light.Range=4;light.Brightness=.6;light.Parent=eye
    end
    local a=Instance.new("Attachment");a.Name="InfectionGlow";a.Parent=torso
    local glow=Instance.new("ParticleEmitter");glow.Name="RedInfectionMotes";glow.Texture="rbxasset://textures/particles/sparkles_main.dds"
    glow.Rate=7;glow.Lifetime=NumberRange.new(.5,.9);glow.Speed=NumberRange.new(.2,.8);glow.SpreadAngle=Vector2.new(70,70)
    glow.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.10),NumberSequenceKeypoint.new(1,0)})
    glow.Color=ColorSequence.new(Color3.fromRGB(235,35,45));glow.LightEmission=.85;glow.Transparency=NumberSequence.new(.25,.95);glow.Parent=a
    for _,v in z:GetDescendants()do if v:IsA("BasePart")then v.Anchored=false elseif v:IsA("LuaSourceContainer")then v:Destroy()end end
    z.Humanoid.BreakJointsOnDeath=false;z:PivotTo(CFrame.lookAt(position,position+Vector3.zAxis));z.Parent=parent;z.HumanoidRootPart:SetNetworkOwner(nil)
    return z
end
return W


local Config = require(script.Parent.MenuConfig)
local Cosmetics = {}
local function accessoryPart(folder, target, name, size, offset, color, shape)
    local p=Instance.new('Part')
    p.Name,p.Size,p.Color,p.CFrame=name,size,color,target.CFrame*offset
    p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,false,true
    p.Material=Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p.Parent=folder
    local w=Instance.new('WeldConstraint');w.Part0,w.Part1,w.Parent=target,p,p
    return p
end
function Cosmetics.ApplySkin(rig,id)
    local s=Config.Skins[id] or Config.Skins[Config.DefaultSkin]
    local old=rig:FindFirstChild('MenuSkinDetails');if old then old:Destroy() end
    for _,ob in ipairs(rig:GetChildren()) do
        if ob:IsA('Shirt') or ob:IsA('Pants') or ob:IsA('ShirtGraphic') or ob:IsA('Accessory') then ob:Destroy()
        elseif ob:IsA('BodyColors') then ob:Destroy() end
    end
    for _,p in ipairs(rig:GetChildren())do
        if p:IsA('BasePart') and p.Name~='HumanoidRootPart' then
            p.Material=Enum.Material.SmoothPlastic
            if p.Name=='Head' or p.Name:find('Hand') then p.Color=s.Hands
            elseif p.Name:find('Torso') then p.Color=s.Torso
            elseif p.Name:find('Arm') then p.Color=s.Arms
            elseif p.Name:find('Leg') or p.Name:find('Foot') then p.Color=s.Legs end
        end
    end
    local folder=Instance.new('Folder');folder.Name,folder.Parent='MenuSkinDetails',rig
    local head=rig:FindFirstChild('Head')
    if head then
        accessoryPart(folder,head,'CapCrown',Vector3.new(1.08,.55,1.08),CFrame.new(0,.44,0),s.Cap,Enum.PartType.Ball)
        -- Original geometric expression, with no uploaded face or store character.
        if not head:FindFirstChildOfClass('Decal') then
        for _,x in ipairs({-.22,.22})do
            accessoryPart(folder,head,'Eye',Vector3.new(.105,.17,.065),CFrame.new(x,.10,-.50),Color3.fromRGB(23,26,30),Enum.PartType.Ball)
            accessoryPart(folder,head,'EyeGlint',Vector3.new(.027,.042,.025),CFrame.new(x-.014,.139,-.536),Color3.fromRGB(245,245,240),Enum.PartType.Ball)
        end
        accessoryPart(folder,head,'Smile',Vector3.new(.26,.043,.03),CFrame.new(0,-.21,-.507),Color3.fromRGB(35,29,26))
        for _,sign in ipairs({-1,1})do accessoryPart(folder,head,'SmileCorner',Vector3.new(.10,.04,.03),CFrame.new(sign*.16,-.18,-.507)*CFrame.Angles(0,0,sign*math.rad(30)),Color3.fromRGB(35,29,26))end
        end
        if id=='STREET' and not head:FindFirstChildOfClass('Decal') then
            for _,x in ipairs({-.22,.22})do accessoryPart(folder,head,'Sunglasses',Vector3.new(.33,.19,.055),CFrame.new(x,.10,-.54),Color3.fromRGB(19,24,30))end
            accessoryPart(folder,head,'GlassesBridge',Vector3.new(.15,.04,.055),CFrame.new(0,.12,-.54),Color3.fromRGB(19,24,30))
        end
        accessoryPart(folder,head,'CapBadge',Vector3.new(.23,.15,.035),CFrame.new(0,.55,-.532),s.Accent)
        accessoryPart(folder,head,'CapBrim',Vector3.new(.94,.09,.54),CFrame.new(0,.45,-.52),s.Cap)
    end
    local torso=rig:FindFirstChild('UpperTorso') or rig:FindFirstChild('Torso')
    if torso then
        local front=-torso.Size.Z/2-.035
        accessoryPart(folder,torso,'JacketInset',Vector3.new(torso.Size.X*.48,torso.Size.Y*.78,.07),CFrame.new(0,.02,front),id=='STREET' and Color3.fromRGB(222,206,174) or Color3.fromRGB(28,33,41))
        accessoryPart(folder,torso,'JacketStripe',Vector3.new(.09,torso.Size.Y*.80,.08),CFrame.new(-torso.Size.X*.3,.02,front-.01),s.Accent)
        accessoryPart(folder,torso,'ChestPatch',Vector3.new(.32,.20,.085),CFrame.new(torso.Size.X*.28,.25,front-.01),s.Accent)
    end
    if torso then
        local front=-torso.Size.Z/2-.09
        accessoryPart(folder,torso,'Zipper',Vector3.new(.035,1.62,.03),CFrame.new(0,0,front),s.Accent)
        for _,sign in ipairs({-1,1})do
            accessoryPart(folder,torso,'Pocket',Vector3.new(.42,.33,.10),CFrame.new(sign*.64,-.42,front),s.Arms)
            accessoryPart(folder,torso,'PocketSeam',Vector3.new(.38,.035,.025),CFrame.new(sign*.64,-.29,front-.06),s.Accent)
            accessoryPart(folder,torso,'Collar',Vector3.new(.37,.16,.13),CFrame.new(sign*.29,.83,front)*CFrame.Angles(0,0,sign*math.rad(20)),s.Torso)
        end
        accessoryPart(folder,torso,'WaistBand',Vector3.new(2.02,.12,1.02),CFrame.new(0,-.92,0),Color3.fromRGB(30,32,37))
    end
    for _,name in ipairs({'Left Leg','Right Leg'})do
        local leg=rig:FindFirstChild(name)
        if leg then
            accessoryPart(folder,leg,'Shoe',Vector3.new(1.02,.35,1.13),CFrame.new(0,-.84,-.05),Color3.fromRGB(27,30,35))
            accessoryPart(folder,leg,'Sole',Vector3.new(1.03,.09,1.15),CFrame.new(0,-1,-.05),Color3.fromRGB(163,169,174))
            accessoryPart(folder,leg,'TrouserSeam',Vector3.new(.035,1.45,.026),CFrame.new(.38,.13,-.51),s.Cap)
        end
    end
    for _,name in ipairs({'Left Arm','Right Arm'}) do
        local arm=rig:FindFirstChild(name)
        if arm then accessoryPart(folder,arm,name..'HandPatch',Vector3.new(.88,.36,.88),CFrame.new(0,-.79,0),s.Hands) end
    end
    return s
end
function Cosmetics.ApplyWeapon(model,id)
    local wrap=Config.Wraps[id] or Config.Wraps.ORIGINAL
    for _,p in ipairs(model:GetDescendants())do
        if p:IsA('BasePart') and p.Transparency<1 then
            if p:GetAttribute('CosmeticBaseColor')==nil then
                p:SetAttribute('CosmeticBaseColor',p.Color);p:SetAttribute('CosmeticBaseMaterial',p.Material.Name)
            end
            p.Color=p:GetAttribute('CosmeticBaseColor');p.Material=Enum.Material[p:GetAttribute('CosmeticBaseMaterial')]
            if wrap.Primary then
                local material=p.Name:match('^W%d+__%w+__(%w+)__')
                if material=='BluedSteel' or material=='BrushedSilver' or material=='CarbonBlack' or p.Name:find('Reflex') and p.Name~='ReflexDot' then p.Color=wrap.Primary
                elseif material=='HoneyWalnut' or material=='DarkWalnut' or material=='GripRubber' or material=='LimeGrip' then p.Color=wrap.Secondary
                elseif material=='SatinMachinedSteel' or p.Name=='SlideRearPlate' then p.Color=wrap.Accent end
            end
        end
    end
end
return Cosmetics

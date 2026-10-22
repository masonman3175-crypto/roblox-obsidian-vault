local Config=require(game.ReplicatedStorage.ClawEmpire.Shared.Config)
local TweenService=game:GetService("TweenService")
local World={}
local C={navy=Color3.fromRGB(24,23,55),floor=Color3.fromRGB(48,44,81),mint=Color3.fromRGB(80,255,201),
    pink=Color3.fromRGB(255,83,159),gold=Color3.fromRGB(255,216,89),white=Color3.fromRGB(247,246,255)}
local function part(parent,name,size,pos,color,material,shape)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
    p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent; return p
end
local function sign(parent,name,size,pos,text,bg,fg)
    local p=part(parent,name,size,pos,bg)
    local gui=Instance.new("SurfaceGui"); gui.Name="Sign"; gui.Face=Enum.NormalId.Back
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=45; gui.Parent=p
    local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
    label.Text=text; label.TextColor3=fg or C.white; label.Font=Enum.Font.FredokaOne
    label.TextScaled=true; label.TextStrokeColor3=C.navy; label.TextStrokeTransparency=0.1; label.Parent=gui
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0.04,0); pad.PaddingRight=UDim.new(0.04,0); pad.Parent=label
    return p,label
end
function World.plush(parent,species,pos,scale)
    local item=Config.plushie(species); scale=scale or 1
    local model=Instance.new("Model"); model.Name=item.name
    local color=Color3.fromRGB(table.unpack(item.color))
    local function ball(name,size,offset,col)
        local p=part(model,name,size*scale,pos+offset*scale,col or color,nil,Enum.PartType.Ball)
        p.CanCollide=false; return p
    end
    local body=ball("SoftBody",Vector3.new(2.2,2.2,1.8),Vector3.zero)
    ball("CreamBelly",Vector3.new(1.5,1.4,0.35),Vector3.new(0,-0.22,0.8),C.white)
    for _,x in ipairs({-0.48,0.48}) do
        ball("ButtonEye",Vector3.new(0.22,0.28,0.12),Vector3.new(x,0.3,0.91),C.navy)
        ball("EyeGlint",Vector3.new(0.075,0.09,0.06),Vector3.new(x-0.035,0.36,0.98),C.white)
        ball("Blush",Vector3.new(0.35,0.18,0.06),Vector3.new(x*1.48,0.04,0.9),C.pink)
        ball("Foot",Vector3.new(0.7,0.5,0.8),Vector3.new(x,-0.92,0.25))
    end
    ball("Smile",Vector3.new(0.23,0.12,0.1),Vector3.new(0,0.02,1),C.navy)
    if item.shape=="bunny" then
        for _,x in ipairs({-0.55,0.55}) do
            ball("Ear",Vector3.new(0.55,1.8,0.6),Vector3.new(x,1.35,0))
            ball("EarPatch",Vector3.new(0.25,1.1,0.1),Vector3.new(x,1.45,0.3),C.white)
        end
    elseif item.shape=="duck" then
        ball("Beak",Vector3.new(0.7,0.3,0.6),Vector3.new(0,0,1.05),Color3.fromRGB(255,141,58))
        ball("Quiff",Vector3.new(0.45,0.6,0.45),Vector3.new(0,1.05,0))
    elseif item.shape=="frog" then
        for _,x in ipairs({-0.7,0.7}) do
            ball("FrogEye",Vector3.new(0.85,0.85,0.7),Vector3.new(x,0.85,0.1))
            ball("TopPupil",Vector3.new(0.25,0.3,0.1),Vector3.new(x,0.93,0.47),C.navy)
        end
    elseif item.shape=="cat" then
        for _,x in ipairs({-0.75,0.75}) do ball("CatEar",Vector3.new(0.7,1,0.6),Vector3.new(x,0.98,0)) end
        local ring=part(model,"SpaceCollar",Vector3.new(2.5,0.15,2),pos+Vector3.new(0,-0.5,0)*scale,C.gold,Enum.Material.Neon)
        ring.Size*=scale; ring.CanCollide=false
    elseif item.shape=="dino" then
        for i=1,3 do ball("CandySpike",Vector3.new(0.6,0.8,0.5),Vector3.new(0,1.15-(i-1)*0.35,-0.15-(i-1)*0.4),C.mint) end
    else
        for i=1,5 do
            local angle=i*math.pi*2/5
            ball("StarPoint",Vector3.new(0.75,0.9,0.6),Vector3.new(math.sin(angle)*1.05,math.cos(angle)*1.05,0),C.gold)
        end
    end
    model.PrimaryPart=body; model.Parent=parent; return model
end
local function cabinet(parent,origin,index)
    local spec=Config.Machines[index]; local color=Color3.fromRGB(table.unpack(spec.color))
    local model=Instance.new("Model"); model.Name=spec.id; model.Parent=parent
    local function p(name,size,offset,col,material) return part(model,name,size,origin+offset,col,material) end
    p("OutlinePlinth",Vector3.new(14,1,13),Vector3.new(0,0.6,0),C.navy)
    p("NeonFoot",Vector3.new(13.4,0.25,12.4),Vector3.new(0,1.2,0),color,Enum.Material.Neon)
    p("LowerCabinet",Vector3.new(12.4,4.7,11.4),Vector3.new(0,3.7,0),color)
    p("PrizeBed",Vector3.new(11.6,0.5,10.5),Vector3.new(0,6.3,0),C.white)
    for _,x in ipairs({-6,6}) do
        for _,z in ipairs({-5.5,5.5}) do
            p("Frame",Vector3.new(0.6,12,0.6),Vector3.new(x,12,z),C.navy)
            p("LED",Vector3.new(0.16,11.5,0.16),Vector3.new(x,12,z+0.35),C.mint,Enum.Material.Neon)
        end
        local glass=p("SideGlass",Vector3.new(0.1,11,10.5),Vector3.new(x,12,0),Color3.fromRGB(156,238,255),Enum.Material.Glass)
        glass.Transparency=0.85; glass.CanCollide=false
    end
    p("TopCapOutline",Vector3.new(13.5,1.5,12.5),Vector3.new(0,18.3,0),C.navy)
    p("TopCap",Vector3.new(12.9,0.8,11.9),Vector3.new(0,19.25,0),color)
    sign(model,"Header",Vector3.new(12.5,2,0.35),origin+Vector3.new(0,18,6.1),string.upper(spec.name),color)
    sign(model,"Instructions",Vector3.new(9.8,1.1,0.2),origin+Vector3.new(0,5.3,5.9),"FREE PLAYS  /  BIG DREAMS",C.navy,C.mint)
    p("ControlDeck",Vector3.new(12,0.5,3),Vector3.new(0,6,6.5),C.navy)
    p("ControlAccent",Vector3.new(11.4,0.12,2.6),Vector3.new(0,6.28,6.5),color)
    p("Joystick",Vector3.new(0.2,0.8,0.2),Vector3.new(-2.5,6.8,6.7),C.white)
    local knob=p("JoystickBall",Vector3.new(0.8,0.8,0.8),Vector3.new(-2.5,7.3,6.7),C.navy); knob.Shape=Enum.PartType.Ball
    local button=p("DropButton",Vector3.new(1.5,0.22,1.5),Vector3.new(2.5,6.5,6.7),C.mint,Enum.Material.Neon); button.Shape=Enum.PartType.Cylinder
    button.Orientation=Vector3.new(0,0,90)
    local claw=Instance.new("Model"); claw.Name="Claw"; claw.Parent=model
    local head=part(claw,"Head",Vector3.new(1.2,0.6,1.2),origin+Vector3.new(0,15,0),C.gold,Enum.Material.Metal)
    for _,x in ipairs({-0.7,0.7}) do
        local arm=part(claw,"Finger",Vector3.new(0.2,1.2,0.25),origin+Vector3.new(x,14.4,0),C.white,Enum.Material.Metal)
        arm.Orientation=Vector3.new(0,0,x*22)
    end
    part(claw,"Cable",Vector3.new(0.12,2,0.12),origin+Vector3.new(0,16.1,0),C.navy)
    claw.PrimaryPart=head
    local prizes=Instance.new("Folder"); prizes.Name="Prizes"; prizes.Parent=model
    for i=1,6 do World.plush(prizes,Config.Plushies[math.min(i,spec.maxTier)].id,origin+Vector3.new((i-1)%3*3-3,7.55,math.floor((i-1)/3)*3-1.5),0.9) end
    local _,status=sign(model,"Status",Vector3.new(9,1.8,0.2),origin+Vector3.new(0,3.2,5.9),if index==1 then "READY TO PLAY!" else "UNLOCK  $250",C.navy,if index==1 then C.mint else C.gold)
    return {root=model,origin=origin,claw=claw,prizes=prizes,status=status}
end
function World.build(parent,name,offset)
    local root=Instance.new("Model"); root.Name=name; root.Parent=parent
    local function p(n,s,v,c,m) return part(root,n,s,offset+v,c,m) end
    p("Foundation",Vector3.new(94,1,78),Vector3.new(0,-0.5,0),C.navy)
    p("MainFloor",Vector3.new(90,0.2,74),Vector3.new(0,0.1,0),C.floor)
    for x=-4,4 do for z=-3,3 do
        if (x+z)%2==0 then p("FloorTile",Vector3.new(9.8,0.04,9.8),Vector3.new(x*10,0.23,z*10),Color3.fromRGB(56,52,94)) end
    end end
    p("BackWall",Vector3.new(92,29,1),Vector3.new(0,14,-36.5),C.navy)
    for _,x in ipairs({-44,44}) do
        p("LightRail",Vector3.new(0.25,0.16,73),Vector3.new(x,0.45,0),C.mint,Enum.Material.Neon)
        p("PortalPillar",Vector3.new(1.5,26,1.5),Vector3.new(x,13,-35),C.pink,Enum.Material.Neon)
    end
    for i=-4,4 do p("WallStripe",Vector3.new(0.3,21,0.2),Vector3.new(i*9,11,-35.8),if i%2==0 then C.pink else C.mint,Enum.Material.Neon) end
    sign(root,"MarqueeShadow",Vector3.new(71,6.5,0.5),offset+Vector3.new(0,24,-35.4),"CLAW MACHINE EMPIRE",C.navy,C.white)
    sign(root,"Subheading",Vector3.new(50,2.2,0.2),offset+Vector3.new(0,19.3,-35),"CATCH CUTE.  BUILD BIG.",C.navy,C.mint)
    p("HeroRugOutline",Vector3.new(61,0.12,13),Vector3.new(-10,0.4,9),C.navy)
    p("HeroRug",Vector3.new(60,0.12,12),Vector3.new(-10,0.48,9),Color3.fromRGB(102,69,151))
    for i=-2,2 do p("RugDash",Vector3.new(7,0.05,0.3),Vector3.new(i*11-10,0.57,14),C.gold,Enum.Material.Neon) end
    local machines={cabinet(root,offset+Vector3.new(-23,0,-14),1),cabinet(root,offset+Vector3.new(-4,0,-14),2)}
    -- A clearly labeled future bay, not an interactable unfinished button.
    p("FutureBay",Vector3.new(14,0.6,13),Vector3.new(15,0.5,-14),C.navy)
    sign(root,"FutureSign",Vector3.new(13,5,0.4),offset+Vector3.new(15,10,-16),"NEON CLAW\nBUILD 02",C.navy,C.pink)
    local shelf=Instance.new("Folder"); shelf.Name="DisplayPlushies"; shelf.Parent=root
    for row=0,1 do
        p("ShelfOutline",Vector3.new(21,0.9,6),Vector3.new(31,3+row*5,4),C.navy)
        p("Shelf",Vector3.new(20.5,0.3,5.8),Vector3.new(31,3.6+row*5,4),C.white)
        p("ShelfGlow",Vector3.new(20.5,0.2,0.2),Vector3.new(31,3.7+row*5,7),C.mint,Enum.Material.Neon)
    end
    sign(root,"ShelfHeader",Vector3.new(22,3.2,0.5),offset+Vector3.new(31,13,4),"THE CUTE CREW",C.navy,C.gold)
    local _,income=sign(root,"IncomeSign",Vector3.new(22,2.3,0.5),offset+Vector3.new(31,1.7,7),"DISPLAY PLUSHIES TO EARN!",C.navy,C.mint)
    for _,x in ipairs({21.5,40.5}) do p("ShelfLeg",Vector3.new(0.8,9,1),Vector3.new(x,4.5,3),C.navy) end
    p("CollectPedestal",Vector3.new(10,2,6),Vector3.new(29,1,16),C.navy)
    sign(root,"CollectSign",Vector3.new(9.5,2.3,0.2),offset+Vector3.new(29,2,19.1),"SHELF BANK",C.mint,C.navy)
    local spawn=Instance.new("SpawnLocation"); spawn.Name="ArcadeSpawn"; spawn.Size=Vector3.new(6,0.2,6)
    spawn.Position=offset+Vector3.new(0,0.6,27); spawn.Anchored=true; spawn.Transparency=1
    spawn.CanCollide=false; spawn.Neutral=true; spawn.Duration=0; spawn.Parent=root
    local confettiColors={C.mint,C.pink,C.gold}
    for i=1,12 do
        local disc=p("ConfettiTile",Vector3.new(0.7,0.03,1.8),Vector3.new((i*17)%70-35,0.38,(i*11)%24+11),confettiColors[i%3+1])
        disc.Orientation=Vector3.new(0,i*37,0)
    end
    return {root=root,offset=offset,machines=machines,shelf=shelf,income=income,spawn=spawn}
end
function World.shelves(plot,state)
    plot.shelf:ClearAllChildren()
    for i,id in ipairs(state.display) do
        for _,item in ipairs(state.inventory) do
            if item.id==id then
                World.plush(plot.shelf,item.species,plot.offset+Vector3.new(23.5+((i-1)%4)*5,5.1+math.floor((i-1)/4)*5,4),1)
                break
            end
        end
    end
end
function World.targets(plot,tier,targets)
    local machine=plot.machines[tier]; machine.prizes:ClearAllChildren()
    for i,t in ipairs(targets) do
        local plush=World.plush(machine.prizes,t.species,machine.origin+Vector3.new(t.x,7.6,t.z),0.75)
        plush.Name="Target"..i
    end
end
function World.aim(plot,tier,x,z,y)
    plot.machines[tier].claw:PivotTo(CFrame.new(plot.machines[tier].origin+Vector3.new(x,y or 15,z)))
end
function World.unlock(plot,tier)
    local machine=plot.machines[tier]
    machine.status.Text="READY TO PLAY!"; machine.status.TextColor3=C.mint
    for _,p in ipairs(machine.root:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="LED" then
            p.Color=C.gold
            TweenService:Create(p,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,2,true),{Color=C.pink}):Play()
        end
    end
end
return World

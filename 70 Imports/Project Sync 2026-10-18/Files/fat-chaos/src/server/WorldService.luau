local W={Pickups={},Dummies={}}
local function part(parent,name,size,pos,color,material)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.Position=pos;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function label(p,text)
 local b=Instance.new("BillboardGui");b.Name="Sign";b.Size=UDim2.fromOffset(310,90);b.StudsOffset=Vector3.new(0,p.Size.Y/2+3,0);b.MaxDistance=210;b.AlwaysOnTop=false;b.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(20,17,40);t.BackgroundTransparency=.12;t.TextColor3=Color3.new(1,1,1);t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Text=text;t.Parent=b;local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,12);c.Parent=t
end
function W.Burger(parent,pos,scale)
 local model=Instance.new("Model");model.Name="Burger";model.Parent=parent
 for i,spec in ipairs({{1,Color3.fromRGB(230,155,65)},{.45,Color3.fromRGB(89,48,30)},{.2,Color3.fromRGB(255,207,45)},{.25,Color3.fromRGB(96,219,73)},{1,Color3.fromRGB(245,174,83)}}) do
  local p=part(model,"Layer"..i,Vector3.new(spec[1]*scale,3*scale,3*scale),pos+Vector3.new(0,(i-1)*.55*scale,0),spec[2]);p.Shape=Enum.PartType.Cylinder;p.CFrame*=CFrame.Angles(0,0,math.pi/2)
 end
 return model
end
function W.Build(ctx)
 local root=Instance.new("Folder");root.Name="FatChaosWorld";root.Parent=workspace;W.Root=root
 local light=game:GetService("Lighting");light.ClockTime=14;light.Brightness=2;light.Ambient=Color3.fromRGB(150,145,190);light.OutdoorAmbient=Color3.fromRGB(170,165,200)
 local bloom=Instance.new("BloomEffect");bloom.Name="FatChaosBloom";bloom.Intensity=.3;bloom.Size=22;bloom.Threshold=1.2;bloom.Parent=light
 local spawn=Instance.new("SpawnLocation");spawn.Name="ChaosSpawn";spawn.Size=Vector3.new(14,1,14);spawn.Position=Vector3.new(0,2,0);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Color=Color3.fromRGB(255,213,75);spawn.Material=Enum.Material.Neon;spawn.Parent=root
 local welcome=part(root,"Welcome",Vector3.new(26,10,2),Vector3.new(0,10,-37),Color3.fromRGB(29,23,58));label(welcome,"+1 FAT EVERY SECOND\nEAT • ROLL • GROW • REBIRTH")
 local tutorial=part(root,"Tutorial",Vector3.new(12,5,1),Vector3.new(-24,5,-15),Color3.fromRGB(71,47,111));label(tutorial,"+1 SIZE / SECOND\nEat burgers • ROLL for 15 Coins\nQ / TAP to activate your power")
 for zone,z in ipairs(ctx.Config.Zones) do
  local x=(zone-1)*160
  local folder=Instance.new("Folder");folder.Name="Zone"..zone;folder.Parent=root
  part(folder,"Island",Vector3.new(145,4,135),Vector3.new(x,-2,0),z.Color)
  part(folder,"Walkway",Vector3.new(150,.2,17),Vector3.new(x,.15,0),Color3.fromRGB(245,235,218))
  for _,side in ipairs({-1,1}) do
   part(folder,"NeonBorder",Vector3.new(145,.5,.8),Vector3.new(x,.5,side*66),z.Color,Enum.Material.Neon)
   for i=1,5 do
    local px=x-60+i*21;local pz=side*50
    if zone==1 or zone==3 then
     local height=zone==3 and 18+i*5 or 10+i*2
     part(folder,"CandyBuilding",Vector3.new(12,height,12),Vector3.new(px,height/2,pz),i%2==0 and Color3.fromRGB(76,61,117) or Color3.fromRGB(255,224,151))
     W.Burger(folder,Vector3.new(px,height+1,pz),zone==3 and 3 or 1.3)
    else
     part(folder,"EnergyPillar",Vector3.new(4,15+zone*3,4),Vector3.new(px,7+zone*1.5,pz),Color3.fromRGB(50,40,88));part(folder,"PillarGlow",Vector3.new(4.3,1,4.3),Vector3.new(px,15+zone*3,pz),z.Color,Enum.Material.Neon)
    end
   end
  end
  local s=part(folder,"ZoneSign",Vector3.new(14,4,1),Vector3.new(x,4,-23),Color3.fromRGB(30,26,55));label(s,zone.." / "..z.Name)
  if zone>1 then
   part(folder,"Bridge",Vector3.new(20,2,22),Vector3.new(x-80,-1,0),Color3.fromRGB(70,56,105))
   local gate=part(folder,"Gate",Vector3.new(2,16,33),Vector3.new(x-72,8,0),z.Color,Enum.Material.Neon);gate.Transparency=.6;gate.CanCollide=false
   label(gate,z.Name.."\n"..z.Size.." Size + "..z.Coins.." Coins\nUse ZONES menu to unlock")
  end
  for i=1,16 do
   local px=x-55+((i*29)%110);local pz=-35+((i*23)%70)
   local food=W.Burger(folder,Vector3.new(px,1.3,pz),.6)
   local hit=part(food,"Pickup",Vector3.new(4,4,4),Vector3.new(px,2,pz),z.Color);hit.Transparency=1;hit.CanCollide=false
   W.Pickups[hit]={Model=food,Zone=zone,Ready=0,Bonus=zone*4+1}
  end
  if zone==2 then
   for i=1,5 do local pad=part(folder,"JumpPad"..i,Vector3.new(12,1,12),Vector3.new(x-45+i*18,i*3,27),z.Color,Enum.Material.Neon);if i==5 then pad:SetAttribute("ChallengeFinish",true) end end
   for i=1,3 do
    local d=part(folder,"TrainingDummy",Vector3.new(4,7,3),Vector3.new(x-35+i*18,3.5,-30),Color3.fromRGB(255,133,82));label(d,"TRAINING TARGET\nHit with any attack power");table.insert(W.Dummies,d)
   end
  elseif zone==5 then
   for i=1,6 do part(folder,"ColossalObstacle",Vector3.new(10,4+i*3,30),Vector3.new(x-60+i*18,2+i*1.5,25),z.Color) end
  end
  task.wait()
 end
 -- The arena is a separate arena-only damage region; all town zones are safe.
 local center=Vector3.new(480,0,175);W.ArenaCenter=center
 part(root,"ArenaBridge",Vector3.new(20,2,95),Vector3.new(480,-1,110),Color3.fromRGB(87,65,136))
 local floor=part(root,"CosmicArena",Vector3.new(5,125,125),center-Vector3.new(0,2.5,0),Color3.fromRGB(40,29,75));floor.Shape=Enum.PartType.Cylinder;floor.CFrame*=CFrame.Angles(0,0,math.pi/2)
 for i=1,20 do local a=i*math.pi/10;local p=center+Vector3.new(math.cos(a)*61,3,math.sin(a)*61);part(root,"ArenaRim",Vector3.new(5,6,5),p,Color3.fromRGB(168,96,255),Enum.Material.Neon) end
 for i=1,4 do local p=part(root,"SpectatorSeat",Vector3.new(18,3,9),center+Vector3.new(-45+i*18,5,78),Color3.fromRGB(255,184,77));label(p,"SPECTATOR DECK • SAFE") end
 for i=1,7 do local p=part(root,"ArenaProp",Vector3.new(5,5,5),center+Vector3.new(-42+i*11,2.5,25),Color3.fromRGB(255,167,65));p:SetAttribute("GlitchProp",true) end
 part(root,"Lounge",Vector3.new(40,3,24),Vector3.new(0,1,76),Color3.fromRGB(255,205,90));local l=part(root,"LoungeSign",Vector3.new(6,3,1),Vector3.new(0,7,85),Color3.fromRGB(65,42,91));label(l,"CHILL LOUNGE\n250 earned Coins • cosmetic only")
end
function W.ZoneAt(pos)
 if pos.Z>95 then return 4 end
 return math.clamp(math.floor((pos.X+80)/160)+1,1,5)
end
function W.InArena(pos) local d=pos-W.ArenaCenter;return Vector2.new(d.X,d.Z).Magnitude<58 and math.abs(d.Y)<100 end
return W

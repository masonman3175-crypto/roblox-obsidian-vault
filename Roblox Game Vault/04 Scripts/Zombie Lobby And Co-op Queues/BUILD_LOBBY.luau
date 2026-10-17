-- Compact original-map street slice, isolated from the combat map at X=1000.
local map=workspace.Map
local lobby=Instance.new("Model");lobby.Name="SurvivorLobby";lobby.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
local center=Vector3.new(1000,0,0)
local function part(name,size,pos,color,parent,material,cf)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf or CFrame.new(center+pos)
    p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.Concrete;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent;return p
end
local function label(parent,name,text,position,size,fontSize,color)
    local t=Instance.new("TextLabel");t.Name=name;t.Text=text;t.Position=position;t.Size=size;t.BackgroundTransparency=1
    t.TextColor3=color or Color3.fromRGB(236,240,228);t.Font=Enum.Font.GothamBold;t.TextSize=fontSize;t.TextWrapped=true;t.Parent=parent
    return t
end
local assets=Instance.new("Folder");assets.Name="StreetAssets";assets.Parent=lobby
local foundation=part("Foundation",Vector3.new(212,3,158),Vector3.new(0,-1.5,0),Color3.fromRGB(44,45,43),lobby,Enum.Material.Asphalt)
part("NorthSidewalk",Vector3.new(210,.5,13),Vector3.new(0,.25,26),Color3.fromRGB(121,116,104),lobby)
part("SouthSidewalk",Vector3.new(210,.5,13),Vector3.new(0,.25,-26),Color3.fromRGB(121,116,104),lobby)
for _,z in {-19.2,19.2} do part("Curb",Vector3.new(210,.65,.55),Vector3.new(0,.325,z),Color3.fromRGB(154,148,132),lobby) end
for x=-92,92,14 do part("StreetStripe",Vector3.new(6,.025,.16),Vector3.new(x,.02,16),Color3.fromRGB(180,165,120),lobby,Enum.Material.SmoothPlastic) end
local removed,cloned=0,0
local function cloneAsset(source,name,position)
    local copy=assert(source):Clone();copy.Name=name
    for _,o in copy:GetDescendants() do
        if o:IsA("LuaSourceContainer") then o:Destroy();removed+=1
        elseif o:IsA("ProximityPrompt") or o:IsA("ClickDetector") or o:IsA("Sound") then o:Destroy()
        elseif o:IsA("BasePart") then o.Anchored=true end
    end
    local cf,size=copy:GetBoundingBox()
    local target=CFrame.new(center+position+Vector3.new(0,size.Y/2,0))
    copy:PivotTo(target*cf:ToObjectSpace(copy:GetPivot()))
    copy.Parent=assets;cloned+=1
    task.wait()
    return copy
end
for i,n in {"Rowhouse_N5","Rowhouse_N6","Rowhouse_N7","Rowhouse_N8","Rowhouse_N9","Rowhouse_N10"} do
    cloneAsset(map.Buildings.NorthRow[n],n,Vector3.new(-65+(i-1)*22,0,53))
end
for i,n in {"Rowhouse_S4","Rowhouse_S5","Rowhouse_S6","Rowhouse_S7","Rowhouse_S8","Rowhouse_S9"} do
    cloneAsset(map.Buildings.SouthRow[n],n,Vector3.new(-65+(i-1)*22,0,-53))
end
cloneAsset(map.Buildings.Landmarks.CornerStore,"CornerStore",Vector3.new(81,0,51))
cloneAsset(map.Buildings.Landmarks.Laundromat,"Laundromat",Vector3.new(81,0,-51))
local tree
for _,o in map.Props.StreetTrees:GetChildren() do if o.Name=="StreetTreeLeafy" then tree=o;break end end
for _,position in {Vector3.new(-86,.5,57),Vector3.new(86,.5,26),Vector3.new(86,.5,-26)} do cloneAsset(tree,"LobbyOak",position) end
cloneAsset(map.Props.StreetProps:FindFirstChild("BusShelter"),"BusShelter",Vector3.new(-82,.5,-26))
for _,x in {-102,104} do part("Boundary",Vector3.new(2,12,158),Vector3.new(x,6,0),Color3.fromRGB(65,62,55),lobby,Enum.Material.Brick) end
for _,z in {-78,78} do part("Boundary",Vector3.new(208,12,2),Vector3.new(0,6,z),Color3.fromRGB(65,62,55),lobby,Enum.Material.Brick) end
lobby.Parent=workspace;task.wait()
local queues=Instance.new("Folder");queues.Name="Queues";queues.Parent=lobby
for _,mode in require(game.ReplicatedStorage.LobbySystem.Config).Modes do
    local pad=Instance.new("Model");pad.Name=mode.Id;pad:SetAttribute("PartySize",mode.Size);pad:SetAttribute("QueueCount",0);pad:SetAttribute("DepartureAt",0)
    local zone=part("Zone",Vector3.new(30,.3,21),Vector3.new(mode.X,.15,-3),Color3.fromRGB(36,51,45),pad,Enum.Material.Metal)
    for _,side in {-1,1} do
        part("LightStrip",Vector3.new(.18,.07,21),Vector3.new(mode.X+side*14.9,.34,-3),mode.Color,pad,Enum.Material.Neon)
        part("LightStrip",Vector3.new(30,.07,.18),Vector3.new(mode.X,.34,-3+side*10.4),mode.Color,pad,Enum.Material.Neon)
        part("GatePost",Vector3.new(.65,11,.65),Vector3.new(mode.X+side*14,5.5,-15),Color3.fromRGB(31,37,34),pad,Enum.Material.Metal)
    end
    local sign=part("Sign",Vector3.new(28,6,.65),Vector3.zero,Color3.fromRGB(15,24,21),pad,Enum.Material.Metal,CFrame.new(center+Vector3.new(mode.X,10,-15))*CFrame.Angles(0,math.pi,0))
    local surface=Instance.new("SurfaceGui");surface.Name="SurfaceGui";surface.Face=Enum.NormalId.Front;surface.CanvasSize=Vector2.new(840,180);surface.LightInfluence=0;surface.Parent=sign
    label(surface,"Title",string.upper(mode.Id),UDim2.fromScale(0,.02),UDim2.fromScale(1,.34),42,mode.Color)
    label(surface,"Count","0 / "..mode.Size.." SURVIVORS",UDim2.fromScale(0,.38),UDim2.fromScale(1,.28),24)
    label(surface,"Status","STEP IN • CO-OP",UDim2.fromScale(0,.70),UDim2.fromScale(1,.26),21,Color3.fromRGB(165,188,174))
    pad.Parent=queues;task.wait()
end
local spawn=Instance.new("SpawnLocation");spawn.Name="Spawn";spawn.Size=Vector3.new(8,.2,6);spawn.CFrame=CFrame.new(1000,.15,20)
spawn.Transparency=1;spawn.Anchored=true;spawn.CanCollide=false;spawn.Neutral=false;spawn.TeamColor=BrickColor.new("Earth green");spawn.Duration=0;spawn.AllowTeamChangeOnTouch=false;spawn.Parent=lobby
local boardModel=Instance.new("Model");boardModel.Name="Leaderboard";boardModel.Parent=lobby
local board=part("Board",Vector3.new(34,22,1),Vector3.zero,Color3.fromRGB(13,24,19),boardModel,Enum.Material.Metal,CFrame.new(906,13,0)*CFrame.Angles(0,-math.pi/2,0))
local surface=Instance.new("SurfaceGui");surface.Name="SurfaceGui";surface.Face=Enum.NormalId.Front;surface.CanvasSize=Vector2.new(1000,720);surface.LightInfluence=0;surface.Parent=board
label(surface,"Title","SURVIVOR LEADERBOARD",UDim2.fromScale(0,.025),UDim2.fromScale(1,.085),38,Color3.fromRGB(108,221,157))
label(surface,"Subtitle","THIS SERVER • SESSION RECORDS",UDim2.fromScale(0,.11),UDim2.fromScale(1,.055),20,Color3.fromRGB(155,180,159))
local headers=Instance.new("Frame");headers.Name="Columns";headers.Size=UDim2.fromScale(.94,.05);headers.Position=UDim2.fromScale(.03,.19);headers.BackgroundTransparency=1;headers.Parent=surface
label(headers,"Name","SURVIVOR",UDim2.fromScale(.01,0),UDim2.fromScale(.58,1),21)
label(headers,"Kills","ZOMBIE KILLS",UDim2.fromScale(.62,0),UDim2.fromScale(.20,1),21)
label(headers,"Best","BEST RUN",UDim2.fromScale(.84,0),UDim2.fromScale(.16,1),21)
local rows=Instance.new("Frame");rows.Name="Rows";rows.Size=UDim2.fromScale(.94,.61);rows.Position=UDim2.fromScale(.03,.26);rows.BackgroundTransparency=1;rows.Parent=surface
for i=1,10 do
 local row=Instance.new("Frame");row.Name="Row"..i;row.Position=UDim2.new(0,0,(i-1)/10,0);row.Size=UDim2.new(1,0,.095,0);row.BorderSizePixel=0
 row.BackgroundColor3=Color3.fromRGB(55,76,60);row.BackgroundTransparency=i%2==0 and .75 or .92;row.Parent=rows
 local name=label(row,"NameCell",string.format("%02d   —",i),UDim2.fromScale(.01,0),UDim2.fromScale(.58,1),23);name.TextXAlignment=Enum.TextXAlignment.Left;name.TextWrapped=false;name.TextTruncate=Enum.TextTruncate.AtEnd
 label(row,"Kills","—",UDim2.fromScale(.62,0),UDim2.fromScale(.20,1),23)
 label(row,"Best","—",UDim2.fromScale(.84,0),UDim2.fromScale(.16,1),23)
end
label(surface,"Footer","One team. One spawn. Survive together.",UDim2.fromScale(0,.91),UDim2.fromScale(1,.06),20,Color3.fromRGB(146,174,151))
local welcome=part("Welcome",Vector3.new(27,5,.5),Vector3.zero,Color3.fromRGB(20,31,24),lobby,Enum.Material.Metal,CFrame.new(1000,8,40))
local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(810,150);gui.LightInfluence=0;gui.Parent=welcome
label(gui,"Title","SURVIVOR HUB",UDim2.fromScale(0,.05),UDim2.fromScale(1,.5),40,Color3.fromRGB(118,223,153))
label(gui,"Info","CHOOSE YOUR CO-OP PARTY SIZE",UDim2.fromScale(0,.56),UDim2.fromScale(1,.35),21)
return game.HttpService:JSONEncode({result="LOBBY BUILD PASS",clonedAssets=cloned,removedScripts=removed,parts=#lobby:GetDescendants(),footprint="212x158"})

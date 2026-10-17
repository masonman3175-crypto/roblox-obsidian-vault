local lobby=assert(workspace:FindFirstChild("SurvivorLobby"))
local old=lobby:FindFirstChild("Queues");if old then old:Destroy() end
local clone=game.ReplicatedStorage.LobbySystem.Config:Clone()
local C=require(clone);clone:Destroy()
local folder=Instance.new("Folder");folder.Name="Queues";folder.Parent=lobby
local function piece(name,size,cf,color,parent,material,transparency)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Color=color
    p.Material=material or Enum.Material.Neon;p.Transparency=transparency or 0;p.Parent=parent
    return p
end
for _,q in C.Queues do
    local pad=Instance.new("Model");pad.Name=q.Id
    pad:SetAttribute("Mode",q.Mode);pad:SetAttribute("Slot",q.Slot);pad:SetAttribute("PartySize",q.Size)
    pad:SetAttribute("Radius",q.Radius);pad:SetAttribute("QueueCount",0);pad:SetAttribute("DepartureAt",0)
    local center=C.LobbyCenter+Vector3.new(q.X,0,q.Z)
    piece("Zone",Vector3.new(q.Radius*2,.2,q.Radius*2),CFrame.new(center+Vector3.new(0,.1,0)),q.Color,pad,Enum.Material.SmoothPlastic,1)
    local floor=piece("GlowDisc",Vector3.new(.10,q.Radius*2,q.Radius*2),CFrame.new(center+Vector3.new(0,.09,0))*CFrame.Angles(0,0,math.pi/2),q.Color,pad,Enum.Material.Neon,.72)
    floor.Shape=Enum.PartType.Cylinder
    local field=piece("LightColumn",Vector3.new(3,q.Radius*2,q.Radius*2),CFrame.new(center+Vector3.new(0,1.65,0))*CFrame.Angles(0,0,math.pi/2),q.Color,pad,Enum.Material.Neon,.92)
    field.Shape=Enum.PartType.Cylinder
    local light=Instance.new("PointLight");light.Color=q.Color;light.Range=12;light.Brightness=.45;light.Shadows=false;light.Parent=floor
    for i=0,47 do
        local angle=i*math.pi*2/48
        local cf=CFrame.new(center)*CFrame.Angles(0,angle,0)*CFrame.new(0,.18,-q.Radius)
        piece("Ring",Vector3.new(2*math.pi*q.Radius/48+.03,.10,.16),cf,q.Color,pad)
    end
    local anchor=piece("LabelAnchor",Vector3.one,CFrame.new(center+Vector3.new(0,q.Slot==1 and 11 or 6,0)),q.Color,pad,Enum.Material.SmoothPlastic,1)
    local gui=Instance.new("BillboardGui");gui.Name="QueueLabel";gui.Adornee=anchor;gui.Size=UDim2.fromOffset(142,114)
    gui.AlwaysOnTop=false;gui.MaxDistance=85;gui.LightInfluence=0;gui.Parent=anchor
    local function label(name,value,y,height,size,color)
        local t=Instance.new("TextLabel");t.Name=name;t.Text=value;t.BackgroundTransparency=1
        t.Size=UDim2.new(1,0,0,height);t.Position=UDim2.fromOffset(0,y);t.Font=Enum.Font.GothamBlack;t.TextSize=size
        t.TextColor3=color;t.TextStrokeColor3=Color3.new(0,0,0);t.TextStrokeTransparency=.12;t.Parent=gui
    end
    label("Title",string.upper(q.Mode).." "..q.Slot,0,28,19,q.Color)
    label("Count","0/"..q.Size,29,37,30,Color3.new(1,1,1))
    label("Timer",C.Countdown.." (sec)",70,34,24,Color3.new(1,1,1))
    pad.Parent=folder
    task.wait()
end
return "BUILD PASS: eight glowing circles, two per co-op mode, floating counts and 15-second timers"

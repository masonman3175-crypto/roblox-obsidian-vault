local mini=game.ReplicatedStorage.GameplayPresentation.MinimapWorld
local count=0
local function proxy(name,cf,size,color,shape)
    local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    if shape then p.Shape=shape end
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
    p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=mini;count+=1;if count%180==0 then task.wait()end
end
proxy('Surroundings',CFrame.new(0,-3,0),Vector3.new(1050,2,800),Color3.fromRGB(57,66,56))
for _,p in ipairs(workspace.Map.Ground:GetDescendants())do
 if p:IsA('BasePart') and p.Transparency<.8 and p.Size.X*p.Size.Z>2 then
    proxy(p.Name,p.CFrame,p.Size,p.Color)
 end
end
for _,p in ipairs(workspace.Map.Alleys:GetDescendants())do
 if p:IsA('BasePart') and p.Size.X*p.Size.Z>5 then proxy(p.Name,p.CFrame,p.Size,p.Color)end
end
for _,p in ipairs(workspace.Map.Buildings:GetDescendants())do
 if p:IsA('BasePart') and p.Size.X>7 and p.Size.Z>7 and p.Size.Y<5 and p.Position.Y>10 then proxy('Roof_'..p.Name,p.CFrame,p.Size,p.Color)end
end
for _,m in ipairs(workspace.Map.Props.ParkedCars:GetChildren())do
 if m:IsA('Model')then
 local cf,sz=m:GetBoundingBox()
 proxy('Car',cf,Vector3.new(math.min(sz.X,7),math.min(sz.Y,4),math.min(sz.Z,14)),Color3.fromRGB(100,113,123))
 end
end
for _,m in ipairs(workspace.Map.Props.StreetTrees:GetChildren())do
 if m:IsA('Model') and m.Name~='TreePit'then
 local cf,sz=m:GetBoundingBox()
 if m.Name:find('Leafy')then proxy('Canopy',CFrame.new(cf.Position),Vector3.new(math.min(sz.X,17),4,math.min(sz.Z,17)),Color3.fromRGB(73,91,48),Enum.PartType.Ball)
 else proxy('BareTree',CFrame.new(cf.Position),Vector3.new(2,math.min(sz.Y,25),2),Color3.fromRGB(72,64,51))end
 end
end
mini:SetAttribute('PartCount',count)
return {MinimapParts=count,LiveMapChanged=false}

local map=workspace:WaitForChild('Map')
assert(not map:FindFirstChild('PerimeterBoundary'),'Boundary already exists; inspect before replacing')
local model=Instance.new('Model');model.Name='PerimeterBoundary'
local minX,maxX,minZ,maxZ=-262,272,-150,150
local bottom,top,thickness=-14,84,8
for k,v in pairs({MinX=minX,MaxX=maxX,MinZ=minZ,MaxZ=maxZ,Bottom=bottom,Top=top,Thickness=thickness})do model:SetAttribute(k,v)end
model:SetAttribute('BuiltBy','Codex');model:SetAttribute('Purpose','Continuous playable-area boundary')
local function part(name,size,cf,color,collide,parent)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Material=Enum.Material.Concrete;p.Anchored=true;p.CanCollide=collide;p.CanTouch=collide;p.CanQuery=collide
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=true;p.Parent=parent or model
 return p
end
local height=top-bottom;local midY=(top+bottom)/2
local grey=Color3.fromRGB(86,84,79);local cap=Color3.fromRGB(48,51,51)
part('NorthSolid',Vector3.new(maxX-minX+thickness*2,height,thickness),CFrame.new((minX+maxX)/2,midY,minZ-thickness/2),grey,true)
part('SouthSolid',Vector3.new(maxX-minX+thickness*2,height,thickness),CFrame.new((minX+maxX)/2,midY,maxZ+thickness/2),grey,true)
part('WestSolid',Vector3.new(thickness,height,maxZ-minZ),CFrame.new(minX-thickness/2,midY,(minZ+maxZ)/2),grey,true)
part('EastSolid',Vector3.new(thickness,height,maxZ-minZ),CFrame.new(maxX+thickness/2,midY,(minZ+maxZ)/2),grey,true)
local details=Instance.new('Folder');details.Name='ArchitecturalDetails';details.Parent=model
for _,side in ipairs({{Axis='X',Edge=minZ,Sign=1},{Axis='X',Edge=maxZ,Sign=-1},{Axis='Z',Edge=minX,Sign=1},{Axis='Z',Edge=maxX,Sign=-1}})do
 local alongX=side.Axis=='X'
 local a,b=alongX and minX or minZ,alongX and maxX or maxZ
 local length=b-a
 local outer=side.Edge-side.Sign*thickness/2
 part('WallCap',alongX and Vector3.new(length+thickness*2,1.2,thickness+1) or Vector3.new(thickness+1,1.2,length+thickness*2),
  CFrame.new(alongX and (a+b)/2 or outer,top+.3,alongX and outer or (a+b)/2),cap,false,details)
 for x=a,b,28 do
  local cf=CFrame.new(alongX and x or side.Edge+side.Sign*.45,midY,alongX and side.Edge+side.Sign*.45 or x)
  part('VerticalButtress',alongX and Vector3.new(1.2,height,1.1) or Vector3.new(1.1,height,1.2),cf,Color3.fromRGB(69,71,69),false,details)
 end
 for _,y in ipairs({6,32,58})do
  part('HorizontalSeam',alongX and Vector3.new(length,.12,.18) or Vector3.new(.18,.12,length),
   CFrame.new(alongX and (a+b)/2 or side.Edge+side.Sign*.08,y,alongX and side.Edge+side.Sign*.08 or (a+b)/2),cap,false,details)
 end
 part('DarkPlinth',alongX and Vector3.new(length,5,.23) or Vector3.new(.23,5,length),
  CFrame.new(alongX and (a+b)/2 or side.Edge+side.Sign*.12,2,alongX and side.Edge+side.Sign*.12 or (a+b)/2),Color3.fromRGB(57,60,57),false,details)
end
local function ground(name,size,position)
 if model:FindFirstChild(name)then return end
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=position
 p.Anchored=true;p.CanCollide=true;p.CanQuery=true;p.CanTouch=true
 p.Material=Enum.Material.Concrete;p.Color=Color3.fromRGB(69,70,64)
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
end
ground('EastGroundApron',Vector3.new(26,2,300),Vector3.new(259,-1,0))
ground('WestGroundApron',Vector3.new(26,2,300),Vector3.new(-249,-1,0))
ground('NorthGroundApron',Vector3.new(482,2,20),Vector3.new(5,-1,-140))
ground('SouthGroundApron',Vector3.new(482,2,20),Vector3.new(5,-1,140))

model.Parent=map
-- Match the minimap without changing its existing terrain/building proxy geometry.
local mini=game.ReplicatedStorage.GameplayPresentation:FindFirstChild('MinimapWorld')
if mini then
 for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart')then
  local c=p:Clone();c.Name='Boundary_'..p.Name;c.CanCollide=false;c.CanTouch=false;c.CanQuery=false;c.Parent=mini
 end end
end
return {Path=model:GetFullName(),SolidWalls=4,Height=height,Top=top,Parts=#model:GetDescendants(),Bounds={minX,maxX,minZ,maxZ}}

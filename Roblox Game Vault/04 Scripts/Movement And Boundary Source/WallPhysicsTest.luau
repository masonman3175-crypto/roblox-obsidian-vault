local p=game.Players.LocalPlayer
p:RequestStreamAroundAsync(Vector3.new(266,4,0),4)
local boundary=workspace.Map:WaitForChild('PerimeterBoundary',5)
assert(boundary:WaitForChild('EastGroundApron',5),'Apron not streamed')
local char=p.Character;local hum=char.Humanoid;local root=char.HumanoidRootPart
char:PivotTo(CFrame.new(266,4,0));root.AssemblyLinearVelocity=Vector3.zero;task.wait(.35)
local m=p.PlayerScripts.MovementControl
game.RunService:BindToRenderStep('BoundaryCollisionQA',Enum.RenderPriority.Input.Value+3,function()hum:Move(Vector3.xAxis,false)end)
m:Invoke('Sprint',true)
local maxX=root.Position.X
for i=1,36 do task.wait(.025);maxX=math.max(maxX,root.Position.X)end
m:Invoke('Sprint',false);game.RunService:UnbindFromRenderStep('BoundaryCollisionQA');hum:Move(Vector3.zero,false)
assert(maxX<272,'Wall escaped')
return {Phase='WALL_PHYSICS',MaxX=maxX,InnerFace=272,Blocked=true,Grounded=hum.FloorMaterial~=Enum.Material.Air,ExitStatus=0}

local p=game.Players.LocalPlayer
local m=p.PlayerScripts.MovementControl
local w=p.PlayerScripts.ReferenceFPSControl
w:Invoke('TestMode',true)
local hum=p.Character.Humanoid;local root=p.Character.HumanoidRootPart
p:RequestStreamAroundAsync(Vector3.new(0,140,0),4)
local floor=workspace:WaitForChild('MovementTestFloor',5);assert(floor,'QA floor not streamed')
p.Character:PivotTo(CFrame.new(120,144,0));root.AssemblyLinearVelocity=Vector3.zero
task.wait(.65)
local initial={Y=root.Position.Y,Floor=hum.FloorMaterial.Name,Hip=hum.HipHeight,Offset=hum.CameraOffset.Y}
game.RunService:BindToRenderStep('BoundaryMovementQA',Enum.RenderPriority.Input.Value+3,function()hum:Move(Vector3.new(-1,0,0),false)end)
m:Invoke('Sprint',true)
task.wait(.85)
local sprint=m:Invoke('State')
local speed=(root.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude
local first=m:Invoke('Slide')
local entries=0
local seen=0
local queuedFor=0
local lowestOffset=0
local maxShake=0
local gaps={}
local lastExit
local prior='Walking'
local samples={}
for i=1,125 do
 task.wait(.025)
 local state=m:Invoke('State')
 local stamp=p:GetAttribute('SlideStartedAt') or 0
 if stamp~=seen and state.Mode=='Sliding' then
  if lastExit then table.insert(gaps,os.clock()-lastExit);lastExit=nil end
  seen=stamp;entries+=1;queuedFor=0
 end
 if state.Mode=='Sliding' and queuedFor~=stamp and entries<3 then
  m:Invoke('Slide');queuedFor=stamp
 end
 if prior=='Sliding' and state.Mode~='Sliding'then lastExit=os.clock()end
 prior=state.Mode
 lowestOffset=math.min(lowestOffset,hum.CameraOffset.Y)
 maxShake=math.max(maxShake,state.ShakeDegrees)
 if i%20==0 then table.insert(samples,{state.Mode,math.floor((root.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude),math.floor(state.Stamina),math.floor(hum.CameraOffset.Y*100)/100})end
end
m:Invoke('Sprint',false);game.RunService:UnbindFromRenderStep('BoundaryMovementQA');hum:Move(Vector3.zero,false)
task.wait(.7)
w:Invoke('TestMode',false)
return {Initial=initial,Sprint=sprint,PhysicalSprintSpeed=speed,FirstSlideRequested=first,
 SlideEntries=entries,LowestCameraOffset=lowestOffset,MaxShake=maxShake,Gaps=gaps,Samples=samples,
 Final=m:Invoke('State'),RestoredHip=hum.HipHeight,Reject=p:GetAttribute('MovementRejectReason')}

-- Rewards/true distance remain server-owned. The camera tours reached milestone worlds.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local Punch=require(RS.Shared.Config.Punch)
local Levels=require(RS.Shared.Config.PunchLevels)
local Format=require(RS.Shared.Util.Format)
local Track=require(script.Parent.PunchTrackController)
local Remotes=RS:WaitForChild("Remotes")
local player=Players.LocalPlayer
local Controller={}
local busy=false
local started=false
local skip=false
local gui,heading,subheading,meter,progress,skipButton
local white=Color3.fromRGB(255,249,234)
local ink=Color3.fromRGB(53,42,79)
local gold=Color3.fromRGB(255,220,108)
local function label(name,value,pos,size,color)
 local l=Instance.new("TextLabel");l.Name=name;l.Text=value;l.Position=pos;l.Size=size
 l.BackgroundTransparency=1;l.Font=Enum.Font.FredokaOne;l.TextColor3=color or white;l.TextScaled=true
 l.TextStrokeColor3=ink;l.TextStrokeTransparency=.12;l.Parent=gui;return l
end
local function setVisible(model,visible)
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") then p.LocalTransparencyModifier=if visible then 0 else 1
  elseif p:IsA("ProximityPrompt") or p:IsA("BillboardGui") then p.Enabled=visible end
 end
end
local function makeGhost(dummy)
 local ghost=dummy:Clone();ghost.Name="PunchJourneyGhost"
 for _,p in ipairs(ghost:GetDescendants()) do
  if p:IsA("ProximityPrompt") or p:IsA("BillboardGui") or p:IsA("BaseScript") then p:Destroy()
  elseif p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.LocalTransparencyModifier=0 end
 end
 local a=Instance.new("Attachment");a.Position=Vector3.new(0,1,0);a.Parent=ghost.PrimaryPart
 local b=Instance.new("Attachment");b.Position=Vector3.new(0,-1,0);b.Parent=ghost.PrimaryPart
 local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.28
 trail.Color=ColorSequence.new(gold,Color3.fromRGB(255,138,200));trail.Transparency=NumberSequence.new(.12,1);trail.Parent=ghost.PrimaryPart
 ghost.Parent=workspace;return ghost
end
local function impact(pos,color)
 local group=Instance.new("Folder");group.Name="PunchImpactLocal";group.Parent=workspace
 for i=1,14 do
  local a=i*math.pi/7
  local p=Instance.new("Part");p.Name="ComicSpark";p.Size=Vector3.new(.45,.45,2.5);p.Anchored=true
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=color;p.CFrame=CFrame.new(pos)
  p.Parent=group
  local target=pos+Vector3.new(math.cos(a)*12,math.sin(a)*12,2)
  TS:Create(p,TweenInfo.new(.4,Enum.EasingStyle.Quart),{CFrame=CFrame.lookAt(target,pos),Transparency=1}):Play()
 end
 Debris:AddItem(group,.5)
end
local function jointOf(character)
 local arm=character:FindFirstChild("RightUpperArm")
 if arm and arm:FindFirstChild("RightShoulder") then return arm.RightShoulder,true end
 local torso=character:FindFirstChild("Torso");return torso and torso:FindFirstChild("Right Shoulder"),false
end
local function stepFor(plan,x)
 local slot=math.clamp(math.floor((x-Punch.TrackStartX)/Punch.BiomeLength)+1,1,#plan.route)
 return plan.route[slot],slot
end
local function cutscene(dummy,feet,coins)
 local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local camera=workspace.CurrentCamera
 local saved={anchored=root.Anchored,fov=camera.FieldOfView,subject=camera.CameraSubject}
 local motor,r15=jointOf(character);local oldC0=motor and motor.C0
 local ghost=nil
 local function cleanup()
  if ghost then ghost:Destroy();ghost=nil end
  setVisible(dummy,true)
  if root.Parent then root.Anchored=saved.anchored end
  if motor and motor.Parent and oldC0 then motor.C0=oldC0 end
  camera.CameraType=Enum.CameraType.Custom;camera.FieldOfView=saved.fov
  if saved.subject and saved.subject.Parent then camera.CameraSubject=saved.subject end
  gui.Enabled=false;skip=false
  task.spawn(Track.Idle)
 end
 local ok,err=xpcall(function()
  gui.Enabled=true;skip=false;skipButton.Text="RETURN  /  ESC"
  local stage=Punch.StageAtFeet(feet);local info=Levels.Get(stage)
  heading.Text="CHARGING...";subheading.Text="Destination: WORLD "..stage.." / "..info.name
  progress.Size=UDim2.fromScale(0,1)
  root.Anchored=true
  local dummyPos=dummy:GetPivot().Position
  root.CFrame=CFrame.lookAt(root.Position,Vector3.new(dummyPos.X,root.Position.Y,dummyPos.Z))
  camera.CameraType=Enum.CameraType.Scriptable
  local mid=(root.Position+dummyPos)/2
  local shot=CFrame.lookAt(mid+Vector3.new(-5,6+character:GetScale(),22),mid)
  camera.CFrame=shot;camera.FieldOfView=58
  if motor then motor.C0=oldC0*CFrame.Angles(if r15 then -1.1 else 0,0,if r15 then 0 else -1.1) end
  local plan=Track.Prepare(feet)
  if skip then return end
  task.wait(.15)
  if motor then motor.C0=oldC0*CFrame.Angles(if r15 then 1.1 else 0,0,if r15 then 0 else 1.1) end
  impact(dummyPos,gold);heading.Text="POW!";subheading.Text="60 ORIGINAL WORLDS / KEEP GOING BEYOND"
  camera.FieldOfView=52;task.wait(.12)
  if motor then motor.C0=oldC0 end
  ghost=makeGhost(dummy);setVisible(dummy,false)
  local start=dummy:GetPivot();local travel=plan.landing-start.Position.X
  local duration=math.clamp(2.6+#plan.route*.48,3.1,6.5)
  local t0=os.clock();local last=0
  repeat
   local elapsed=os.clock()-t0
   local a=math.clamp(elapsed/duration,0,1)
   if skip or not root.Parent or not ghost.Parent then break end
   local eased=1-(1-a)^1.32
   local pos=start.Position+Vector3.new(travel*eased,math.sin(math.pi*a)*26,math.sin(math.pi*a*2)*2)
   ghost:PivotTo(CFrame.new(pos)*start.Rotation*CFrame.Angles(0,0,-a*math.pi*12))
   local entry,slot=stepFor(plan,pos.X)
   if entry.stage~=last then
    last=entry.stage;local spec=Levels.Get(last)
    heading.Text="WORLD "..last.." / "..string.upper(spec.name)
    heading.TextColor3=spec.accent
    subheading.Text=if entry.warp then "MILESTONE PORTAL / ADVANCING THROUGH REACHED WORLDS" else "YOUR DUMMY'S NEXT GREAT ADVENTURE"
    gui:SetAttribute("CurrentStage",last)
   end
   meter.Text=Format.Number(feet*eased).." FT"
   progress.Size=UDim2.fromScale(eased,1)
   camera.FieldOfView=70
   -- A wider three-quarter view keeps the giant stage landmarks in frame.
   camera.CFrame=CFrame.lookAt(pos+Vector3.new(-41,23,66),pos+Vector3.new(18,5,-28))
   RunService.RenderStepped:Wait()
  until a>=1
  if not skip and root.Parent and ghost and ghost.Parent then
   local target=Vector3.new(plan.landing,4,0)
   ghost:PivotTo(CFrame.new(target)*start.Rotation)
   impact(target,info.accent)
   heading.Text="WORLD "..stage.." / "..string.upper(info.name)
   subheading.Text="+"..Format.Number(coins).." COINS / NEXT WORLD AT "..Format.Number(Punch.Threshold(stage+1)).." FT"
   meter.Text=Format.Number(feet).." FT";progress.Size=UDim2.fromScale(1,1)
   gui:SetAttribute("CurrentStage",stage);gui:SetAttribute("LandingStage",stage);gui:SetAttribute("AwardedFeet",feet)
   camera.CFrame=CFrame.lookAt(target+Vector3.new(-45,28,83),target+Vector3.new(10,16,-70))
   local finish=os.clock()+1.35
   while not skip and root.Parent and os.clock()<finish do RunService.RenderStepped:Wait() end
  end
 end,debug.traceback)
 cleanup()
 if not ok then warn("[PunchExpansion] cutscene recovered: "..tostring(err)) end
end
local popupCount=0
local function popup(feet,coins)
 if popupCount>=3 then return end;popupCount+=1
 local toast=Instance.new("ScreenGui");toast.Name="PunchCoinToast";toast.ResetOnSpawn=false;toast.DisplayOrder=18;toast.Parent=player.PlayerGui
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(.4,.05);l.Position=UDim2.fromScale(.3,.22);l.BackgroundTransparency=1
 l.Font=Enum.Font.FredokaOne;l.TextScaled=true;l.TextColor3=gold;l.TextStrokeColor3=ink;l.TextStrokeTransparency=.1;l.Text=Format.Number(feet).." FT  +"..Format.Number(coins).." COINS";l.Parent=toast
 task.delay(1.1,function()toast:Destroy();popupCount-=1 end)
end
function Controller.IsBusy() return busy end
function Controller.Start()
 if started then return end;started=true;Track.Start()
 gui=Instance.new("ScreenGui");gui.Name="PunchFxGui";gui.ResetOnSpawn=false;gui.DisplayOrder=30;gui.Enabled=false;gui.Parent=player:WaitForChild("PlayerGui")
 heading=label("WorldTitle","",UDim2.fromScale(.05,.035),UDim2.fromScale(.9,.09),gold)
 subheading=label("JourneyHint","",UDim2.fromScale(.08,.13),UDim2.fromScale(.84,.045))
 meter=label("Distance","",UDim2.fromScale(.2,.76),UDim2.fromScale(.6,.09),gold)
 local rail=Instance.new("Frame");rail.Size=UDim2.fromScale(.56,.012);rail.Position=UDim2.fromScale(.22,.87);rail.BackgroundColor3=ink;rail.BorderSizePixel=0;rail.Parent=gui
 progress=Instance.new("Frame");progress.Size=UDim2.fromScale(0,1);progress.BackgroundColor3=gold;progress.BorderSizePixel=0;progress.Parent=rail
 skipButton=Instance.new("TextButton");skipButton.Name="Return";skipButton.AnchorPoint=Vector2.new(.5,1);skipButton.Position=UDim2.fromScale(.5,.98);skipButton.Size=UDim2.fromOffset(188,44)
 skipButton.BackgroundColor3=white;skipButton.TextColor3=ink;skipButton.Font=Enum.Font.FredokaOne;skipButton.TextSize=18;skipButton.BorderSizePixel=0;skipButton.Parent=gui
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,14);c.Parent=skipButton
 skipButton.Activated:Connect(function()skip=true end)
 UIS.InputBegan:Connect(function(input,processed) if not processed and busy and (input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.Backspace) then skip=true end end)
 local dummy=workspace:WaitForChild("Map"):WaitForChild("Gameplay"):WaitForChild("PunchLane"):WaitForChild("Dummy")
 while not dummy.PrimaryPart do task.wait() end
 local prompt=dummy.PrimaryPart:WaitForChild("PunchPrompt")
 Remotes.PunchFx.OnClientEvent:Connect(function(puncher,feet,coins,_virtualX,isAuto)
  if puncher~=player then return end -- each player sees their own bounded journey
  if isAuto or busy then popup(feet,coins);return end
  busy=true;prompt.Enabled=false
  task.spawn(function()
   local ok,err=pcall(cutscene,dummy,feet,coins)
   if not ok then
    warn("[PunchExpansion] cleanup recovered: "..tostring(err))
    gui.Enabled=false;setVisible(dummy,true)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored=false end
    workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
    task.spawn(Track.Idle)
   end
   busy=false;if prompt.Parent then prompt.Enabled=true end
  end)
 end)
 print("[PunchExpansion] client ready; 60-level catalog; eight-stage local budget")
end
return Controller


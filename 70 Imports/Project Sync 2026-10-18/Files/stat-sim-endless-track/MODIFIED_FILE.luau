assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local function resolve(path) local obj=game;for n in path:gmatch("[^%.]+") do obj=obj and obj:FindFirstChild(n) end;return obj end
local src={}
src["ServerScriptService.PunchExpansionRuntime"]={class="Script",source=[===[-- The sixty-level authoring preview is Edit-only. Each client draws a bounded route.
local track=workspace:WaitForChild("Map"):WaitForChild("Track")
local preview=track:FindFirstChild("EditorPreview")
if preview then
 for i,model in ipairs(preview:GetChildren()) do model:Destroy();if i%4==0 then task.wait() end end
 preview:Destroy()
end
track:SetAttribute("RuntimeMode","Local bounded milestone route")
track:SetAttribute("CatalogLevels",60)
print("[PunchExpansion] 60 original destinations + echo realms; no 10M endpoint; local stage budget=8")

]===]}
src["StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController"]={class="ModuleScript",source=[===[-- Rewards/true distance remain server-owned. The camera tours reached milestone worlds.
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

]===]}
src["StarterPlayer.StarterPlayerScripts.Controllers.PunchTrackController"]={class="ModuleScript",source=[===[-- Local-only, rebased journey scenery. Never awards coins or changes player progression.
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Punch=require(RS.Shared.Config.Punch)
local Builder=require(RS.Shared.Util.PunchTrackBuilder)
local Controller={}
local started=false
local generation=0
local active=nil
local ambient={}
local stageIds={}
local function render(route)
 generation+=1;local token=generation
 if active then active:Destroy() end
 active=Instance.new("Folder");active.Name="PunchJourneyLocal";active.Parent=workspace
 local root=active;ambient={};stageIds={}
 for _,entry in ipairs(route) do
  if token~=generation then root:Destroy();return nil end
  local model=Builder.Build(root,entry.stage,entry.x,{warp=entry.warp})
  table.insert(stageIds,entry.stage)
  for _,p in ipairs(model:GetDescendants()) do
   if #ambient>=28 then break end
   local spin=p:GetAttribute("AmbientSpin");local bob=p:GetAttribute("AmbientBob")
   if spin or bob then
    table.insert(ambient,{object=p,base=if p:IsA("Model") then p:GetPivot() else p.CFrame,spin=spin,bob=bob})
   end
  end
  task.wait()
 end
 if token~=generation then return nil end
 root:SetAttribute("RenderedStages",#route);root:SetAttribute("StageBudget",Punch.MaxVisibleStages)
 return root
end
function Controller.Prepare(feet)
 local route,landing=Punch.Route(feet)
 local root=render(route)
 assert(root,"Journey preparation cancelled")
 return {route=route,landing=landing,root=root}
end
function Controller.Idle()
 local route={}
 for i=1,6 do table.insert(route,{stage=i,x=Punch.TrackStartX+(i-1)*Punch.BiomeLength}) end
 return render(route)
end
function Controller.Audit()
 local count=0;if active then for _,p in ipairs(active:GetDescendants()) do if p:IsA("BasePart") then count+=1 end end end
 return {stages=table.clone(stageIds),parts=count,models=active and #active:GetChildren() or 0,budget=Punch.MaxVisibleStages,ambient=#ambient}
end
function Controller.Start()
 if started then return end;started=true
 Builder.MaskHub(workspace:WaitForChild("Map"):WaitForChild("Hub"))
 task.spawn(Controller.Idle)
 local elapsed=0
 RunService.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<.04 then return end;elapsed=0
  local now=os.clock()
  for i,item in ipairs(ambient) do
   if item.object.Parent then
    local cf=item.base*CFrame.new(0,if item.bob then math.sin(now*1.3+i)*item.bob else 0,0)
    if item.spin then cf*=CFrame.Angles(0,now*item.spin,0) end
    if item.object:IsA("Model") then item.object:PivotTo(cf) else item.object.CFrame=cf end
   end
  end
 end)
end
return Controller

]===]}
src["ServerScriptService.Services.StatService"]={class="ModuleScript",source=[===[-- Owns Strength, XP, Level, Coins and every multiplier. Replicates state as
-- player attributes (the client only reads them).
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage.Shared.Config
local StatsConfig = require(Config.Stats)
local PunchConfig = require(Config.Punch)
local Zones = require(Config.Zones)
local RebirthConfig = require(Config.Rebirth)
local PetsConfig = require(Config.Pets)
local Gym = require(Config.Gym)
local DataService = require(script.Parent.DataService)

local StatService = {}

local owned = {}
local currentWorld = {}
local currentGym = {}

function StatService.SetPass(player, passKey, value)
	owned[player] = owned[player] or {}
	owned[player][passKey] = value
	player:SetAttribute("Pass_" .. passKey, value)
	StatService.Refresh(player)
end

function StatService.OwnsPass(player, passKey)
	return owned[player] ~= nil and owned[player][passKey] == true
end

function StatService.SetLocation(player, world, gymTier)
	if currentWorld[player] == world and currentGym[player] == gymTier then
		return
	end
	currentWorld[player] = world
	currentGym[player] = gymTier
	StatService.Refresh(player)
end

function StatService.CurrentWorld(player)
	return currentWorld[player] or 1
end

-- Highest world the player may enter (Strength or the World Skip product)
function StatService.AllowedWorld(profile)
	local allowed = 1
	for i, world in Zones.List do
		if profile.Strength >= world.Required then
			allowed = i
		end
	end
	return math.max(allowed, math.min(profile.WorldUnlocked or 1, #Zones.List))
end

function StatService.GymUnlocked(player, tier)
	local profile = DataService.Get(player)
	local info = Gym.Tiers[tier]
	if not profile or not info then
		return false
	end
	if info.Pass then
		return StatService.OwnsPass(player, info.Pass)
	end
	return profile.Rebirths >= (info.Rebirths or 0)
end

function StatService.EquippedIds(profile)
	local ids = {}
	for _, entry in profile.PetInv do
		if entry.e then
			table.insert(ids, entry.p)
		end
	end
	return ids
end

function StatService.PetSlots(player)
	return PetsConfig.BaseSlots + (if StatService.OwnsPass(player, "PetSlots") then PetsConfig.ExtraSlotsPass else 0)
end

function StatService.Multipliers(player)
	local profile = DataService.Get(player)
	local world = Zones.List[currentWorld[player] or 1]
	local gymTier = currentGym[player]
	local gamepass = 1
	if StatService.OwnsPass(player, "Double") then
		gamepass *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		gamepass *= 1.5
	end
	return {
		World = world.Multiplier,
		Gym = if gymTier then Gym.Tiers[gymTier].Multiplier else 1,
		Rebirth = if profile then RebirthConfig.Multiplier(profile.Rebirths) else 1,
		Gamepass = gamepass,
		Pets = if profile then PetsConfig.Multiplier(StatService.EquippedIds(profile)) else 1,
		Boost = if profile and profile.BoostEnd > os.time() then 2 else 1,
	}
end

function StatService.Gain(player)
	local total = StatsConfig.BaseGain
	for _, value in StatService.Multipliers(player) do
		total *= value
	end
	return total
end

function StatService.CoinMultiplier(player)
	local profile = DataService.Get(player)
	local m = 1
	if StatService.OwnsPass(player, "DoubleCoins") then
		m *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		m *= 1.5
	end
	if profile and profile.CoinBoostEnd > os.time() then
		m *= 2
	end
	return m
end

function StatService.IsLucky(player)
	local profile = DataService.Get(player)
	return StatService.OwnsPass(player, "Lucky") or (profile ~= nil and profile.LuckEnd > os.time())
end

function StatService.Refresh(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local mults = StatService.Multipliers(player)
	player:SetAttribute("Strength", profile.Strength)
	player:SetAttribute("XP", profile.XP)
	player:SetAttribute("XPNeeded", StatsConfig.XpForLevel(profile.Level))
	player:SetAttribute("Level", profile.Level)
	player:SetAttribute("Rebirths", profile.Rebirths)
	player:SetAttribute("Gain", StatService.Gain(player))
	player:SetAttribute("Zone", currentWorld[player] or 1)
	player:SetAttribute("GymTier", currentGym[player] or 0)
	player:SetAttribute("AllowedZone", StatService.AllowedWorld(profile))
	player:SetAttribute("BoostEnd", profile.BoostEnd)
	player:SetAttribute("CoinBoostEnd", profile.CoinBoostEnd)
	player:SetAttribute("LuckEnd", profile.LuckEnd)
	player:SetAttribute("AutoTrainOn", profile.AutoTrainOn)
	player:SetAttribute("AutoPunchOn", profile.AutoPunchOn)
	player:SetAttribute("AutoHatchOn", profile.AutoHatchOn)
	player:SetAttribute("Coins", profile.Coins)
	player:SetAttribute("CoinMult", StatService.CoinMultiplier(player))
	player:SetAttribute("BestPunch", profile.BestPunch)
	player:SetAttribute("BestPunchStage", PunchConfig.StageAtFeet(profile.BestPunch))
	player:SetAttribute("PetSlots", StatService.PetSlots(player))
	player:SetAttribute("PetInv", HttpService:JSONEncode(profile.PetInv))
	for name, value in mults do
		player:SetAttribute("Mult_" .. name, value)
	end

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Strength.Value = math.min(math.floor(profile.Strength), 2 ^ 53)
		stats.Coins.Value = math.min(math.floor(profile.Coins), 2 ^ 53)
		stats.Rebirths.Value = profile.Rebirths
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local speed = StatsConfig.WalkSpeed(profile.Strength)
		if StatService.OwnsPass(player, "FastWalk") then
			speed *= 1.5
		end
		if not character:GetAttribute("Frozen") then
			humanoid.WalkSpeed = speed
		end
		local target = StatsConfig.BodyScale(profile.Strength)
		if math.abs(character:GetScale() - target) > 0.02 then
			character:ScaleTo(target)
		end
	end
end

function StatService.AddStrength(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Strength += amount
	profile.TotalStrength += amount
	profile.XP += amount
	while profile.XP >= StatsConfig.XpForLevel(profile.Level) do
		profile.XP -= StatsConfig.XpForLevel(profile.Level)
		profile.Level += 1
	end
	StatService.Refresh(player)
end

function StatService.AddLevels(player, count)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	profile.Level += count
	StatService.Refresh(player)
end

function StatService.AddCoins(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Coins += amount
	StatService.Refresh(player)
end

local function onLoaded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	for _, name in {"Strength", "Coins", "Rebirths"} do
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Parent = stats
	end
	stats.Parent = player
	player:SetAttribute("Loaded", true)
	StatService.Refresh(player)
end

function StatService.Start()
	DataService.ProfileLoaded:Connect(onLoaded)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.defer(StatService.Refresh, player)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		owned[player] = nil
		currentWorld[player] = nil
		currentGym[player] = nil
	end)
end

return StatService
]===]}
src["ReplicatedStorage.Shared.Config.Punch"]={class="ModuleScript",source=[===[-- Authoritative distance/reward math. No MAX wall or six-biome distance clamp.
local Levels=require(script.Parent.PunchLevels)
local Punch={}
Punch.Cooldown=2
Punch.AutoInterval=3
Punch.MaxRange=18
Punch.TrackStartX=40
Punch.BiomeLength=320
Punch.TrackZ=0
Punch.LevelsPerDecade=10
Punch.MaxVisibleStages=8
Punch.Biomes={}
for _,v in ipairs(Levels.List) do table.insert(Punch.Biomes,v[2]) end
local function finite(n) return type(n)=="number" and n==n and n<math.huge and n>-math.huge end
function Punch.Feet(strength)
 assert(finite(strength) and strength>=0,"Invalid strength")
 return math.floor(3.3*strength)+5
end
function Punch.Coins(feet,worldMultiplier,coinMultiplier)
 assert(finite(feet) and feet>=0,"Invalid distance")
 return math.floor(feet^.75*2*worldMultiplier*coinMultiplier)
end
function Punch.Progress(feet)
 assert(finite(feet) and feet>=0,"Invalid distance")
 return math.max(0,(math.log10(math.max(feet,10))-1)*Punch.LevelsPerDecade)
end
function Punch.StageAtFeet(feet) return math.floor(Punch.Progress(feet)+1e-9)+1 end
function Punch.Threshold(stage)
 assert(type(stage)=="number" and stage>=1 and stage%1==0,"Invalid stage")
 return 10^(1+(stage-1)/Punch.LevelsPerDecade)
end
function Punch.TrackX(feet) return Punch.TrackStartX+Punch.Progress(feet)*Punch.BiomeLength end
function Punch.BiomeAt(x)
 assert(finite(x),"Invalid virtual coordinate")
 local index=math.max(1,math.floor((x-Punch.TrackStartX)/Punch.BiomeLength+1e-9)+1)
 return index,Levels.Get(index).name
end
function Punch.Route(feet)
 local stage=Punch.StageAtFeet(feet)
 local count=math.min(stage,Punch.MaxVisibleStages)
 local route={}
 for i=1,count do
  local index=if count==1 then stage else 1+math.floor((stage-1)*(i-1)/(count-1)+.5)
  table.insert(route,{stage=index,x=Punch.TrackStartX+(i-1)*Punch.BiomeLength,warp=i>1 and index>route[i-1].stage+1})
 end
 -- Presentation is deliberately rebased near the hub, not a trillion-stud world.
 -- Reached stages/distance are not capped. Long flights use clearly marked portals
 -- between sampled milestones and always render the actual destination.
 local fraction=Punch.Progress(feet)%1
 local landing=route[#route].x+55+fraction*185
 return route,landing
end
return Punch
]===]}
src["ReplicatedStorage.Shared.Config.PunchLevels"]={class="ModuleScript",source=[===[-- Sixty original destinations. Past the catalog, seeded echo realms keep advancing.
local Levels={}
-- id, title, floor RGB, primary RGB, accent RGB, handcrafted landmark, dressing family
Levels.List={
 {"glove","Glove Grove",{115,215,133},{255,102,132},{255,224,104},"glove","forest"},
 {"mushroom","Mushroom Megalopolis",{157,213,150},{244,126,208},{182,157,255},"mushroom","forest"},
 {"boardwalk","Bubblegum Boardwalk",{255,184,215},{254,99,178},{111,235,239},"coaster","candy"},
 {"desert","Doodle Desert",{247,214,139},{245,157,98},{114,235,194},"pyramid","desert"},
 {"origami","Origami Oasis",{165,235,212},{250,240,205},{251,144,193},"origami","paper"},
 {"cactus","Cactus Carnival",{255,210,139},{118,207,144},{253,121,190},"cactus","desert"},
 {"snowcone","Snowcone Summit",{210,241,255},{147,210,252},{255,146,188},"snowcone","ice"},
 {"pinball","Polar Pinball",{179,231,247},{112,169,247},{255,225,110},"pinball","ice"},
 {"aurora","Aurora Observatory",{167,185,235},{140,238,221},{205,145,248},"observatory","space"},
 {"volcano","Toasted Volcano",{119,100,139},{249,131,93},{255,215,101},"volcano","lava"},
 {"laundry","Lava Laundry",{207,135,126},{255,153,83},{142,222,239},"washer","lava"},
 {"clockwork","Clockwork Canyon",{217,180,143},{181,133,216},{255,215,119},"clock","mechanical"},
 {"comet","Candy Comet",{237,168,227},{248,130,190},{142,224,255},"comet","candy"},
 {"mallow","Marshmallow Monastery",{249,211,226},{255,248,226},{188,160,239},"monastery","candy"},
 {"galleon","Gummy Galleon",{136,218,238},{250,147,176},{255,224,117},"ship","ocean"},
 {"cheese","Moon Cheese Mine",{201,204,223},{255,224,100},{154,172,247},"cheese","space"},
 {"ramen","Rocket Ramen",{236,198,154},{239,135,119},{148,233,208},"ramen","food"},
 {"skate","Starlight Skatepark",{158,165,226},{184,149,251},{255,217,117},"skatepark","space"},
 {"noodle","Neon Noodle District",{131,153,204},{255,122,198},{111,238,226},"pagoda","city"},
 {"lantern","Lantern Lagoon",{119,213,209},{255,190,127},{244,138,210},"lantern","ocean"},
 {"bamboo","Bamboo Beatforest",{158,224,160},{113,188,135},{255,219,124},"bamboo","forest"},
 {"paperport","Pirate Paperport",{170,221,239},{255,246,207},{252,149,152},"paperboat","paper"},
 {"coral","Coral Carousel",{144,220,239},{250,153,180},{240,221,134},"carousel","ocean"},
 {"jelly","Jellyfish Junction",{153,196,240},{205,150,244},{143,243,223},"jellyfish","ocean"},
 {"sunken","Sunken Arcade",{121,198,213},{239,152,224},{255,217,123},"arcade","ocean"},
 {"thunder","Thundercloud Transit",{173,181,227},{255,222,103},{179,230,255},"cloudtrain","sky"},
 {"repair","Rainbow Repairyard",{210,192,244},{250,158,210},{136,235,196},"crane","sky"},
 {"kite","Kite Kingdom",{196,231,251},{246,143,183},{255,223,113},"kite","sky"},
 {"bath","Bubble Bath Bay",{170,227,241},{253,245,228},{255,220,113},"bathtub","ocean"},
 {"pancake","Pancake Plateau",{237,207,160},{232,167,104},{255,229,134},"pancake","food"},
 {"waffle","Waffle Workshop",{229,201,161},{211,154,99},{244,198,113},"waffle","food"},
 {"teacup","Teacup Tornado",{227,195,234},{250,247,219},{243,141,193},"teacup","food"},
 {"toys","Toyblock Titans",{148,215,235},{244,129,156},{255,224,119},"robot","toy"},
 {"duck","Rubber Duck Dynasty",{187,225,189},{255,218,83},{250,152,195},"duck","toy"},
 {"plush","Plushie Playropolis",{246,188,219},{208,165,239},{255,237,176},"bear","toy"},
 {"bonsai","Bonsai Moon Garden",{161,212,205},{135,182,170},{244,212,173},"bonsai","forest"},
 {"cathedral","Crystal Cathedral",{178,207,241},{191,155,245},{138,242,233},"cathedral","crystal"},
 {"post","Prism Post Office",{203,191,244},{247,164,205},{255,227,133},"envelope","paper"},
 {"circuit","Circuit City",{135,181,210},{123,237,215},{244,162,230},"circuit","mechanical"},
 {"afterhours","Arcade Afterhours",{155,143,200},{240,137,217},{124,225,240},"joystick","city"},
 {"hologram","Hologram Highway",{145,179,220},{133,233,241},{233,165,247},"hologram","city"},
 {"glitch","Glitch Greenhouse",{174,219,172},{196,141,235},{124,241,209},"greenhouse","mechanical"},
 {"dino","Dino Disco",{182,215,146},{141,211,167},{240,155,220},"dinosaur","forest"},
 {"fossil","Fossil Ferris",{219,189,152},{250,238,205},{184,155,222},"ferris","desert"},
 {"dragon","Dragonfruit Dojo",{238,184,207},{244,128,176},{151,217,148},"dragon","forest"},
 {"firefly","Firefly Fairground",{145,171,190},{255,226,129},{160,225,202},"firefly","forest"},
 {"pumpkin","Pumpkin Planetarium",{192,164,205},{250,171,94},{163,223,203},"pumpkin","space"},
 {"ghost","Ghosttoast Hotel",{182,177,218},{255,240,203},{238,165,186},"hotel","toy"},
 {"marble","Moonlit Marbleworks",{167,191,224},{183,213,249},{248,190,220},"marble","crystal"},
 {"chess","Chessboard Cosmos",{173,177,213},{249,239,221},{130,124,174},"chess","space"},
 {"saturn","Saturn Station",{160,163,214},{241,204,145},{195,145,244},"saturn","space"},
 {"library","Gravity Library",{194,172,223},{241,191,143},{152,224,221},"library","paper"},
 {"bowling","Blackhole Bowling",{130,128,186},{226,171,239},{139,231,232},"bowling","space"},
 {"quilt","Quantum Quilt",{214,180,221},{245,174,199},{157,225,200},"quilt","paper"},
 {"aquarium","Dream Aquarium",{146,212,236},{170,233,234},{249,184,222},"aquarium","ocean"},
 {"castle","Cloud Castle",{200,218,248},{239,237,255},{240,181,225},"castle","sky"},
 {"icecream","Infinity Icecream",{235,195,222},{255,207,152},{183,235,205},"icecream","food"},
 {"symphony","Supernova Symphony",{180,164,224},{249,216,129},{248,154,216},"symphony","space"},
 {"cosmic","Cosmic Origami",{194,185,235},{161,225,238},{251,187,217},"cosmic","paper"},
 {"beyond","Beyond The Punch",{164,159,223},{245,188,239},{255,225,133},"beyond","space"},
}
Levels.Count=#Levels.List
function Levels.Get(stage)
 assert(type(stage)=="number" and stage==stage and stage>=1 and stage%1==0 and stage<math.huge,"Invalid stage")
 local index=(stage-1)%Levels.Count+1
 local cycle=math.floor((stage-1)/Levels.Count)
 local s=Levels.List[index]
 local function color(t,shift)
  local base=Color3.fromRGB(table.unpack(t))
  if cycle==0 then return base end
  local h,sat,v=base:ToHSV();return Color3.fromHSV((h+cycle*.071+shift)%1,sat,v)
 end
 return {id=s[1],name=s[2]..(if cycle>0 then " / Echo "..(cycle+1) else ""),ground=color(s[3],0),
  color=color(s[4],0),accent=color(s[5],.03),kind=s[6],family=s[7],stage=stage,index=index,cycle=cycle,
  seed=(stage*7919)%2147483647}
end
return Levels

]===]}
src["ReplicatedStorage.Shared.Util.Format"]={class="ModuleScript",source=[===[-- 1234 -> 1.2K, 5600000 -> 5.6M
local Format = {}

local SUFFIXES = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

function Format.Number(n)
	if n >= 1e36 and n < math.huge then
		local e=math.floor(math.log10(n));return string.format("%.2fe%d",n/10^e,e)
	end
	n = math.floor(n)
	if n < 1000 then
		return tostring(n)
	end
	local i = 1
	local v = n
	while v >= 1000 and i < #SUFFIXES do
		v /= 1000
		i += 1
	end
	if v >= 100 then
		return math.floor(v) .. SUFFIXES[i]
	end
	local s = string.format("%.1f", math.floor(v * 10) / 10)
	s = string.gsub(s, "%.0$", "")
	return s .. SUFFIXES[i]
end

function Format.Multiplier(m)
	local s = string.format("%.2f", m)
	s = string.gsub(s, "0+$", "")
	s = string.gsub(s, "%.$", "")
	return "x" .. s
end

return Format
]===]}
src["ReplicatedStorage.Shared.Util.PunchTrackBuilder"]={class="ModuleScript",source=[===[-- Original toy-diorama construction. Shared by Edit preview and bounded client renderer.
local Levels=require(script.Parent.Parent.Config.PunchLevels)
local Punch=require(script.Parent.Parent.Config.Punch)
local Builder={}
local v=Vector3.new
local white=Color3.fromRGB(255,248,230)
local ink=Color3.fromRGB(55,49,85)
local gold=Color3.fromRGB(255,219,112)
local mint=Color3.fromRGB(135,231,180)
local function raw(parent,name,size,pos,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true
 p.Material=Enum.Material.Plastic;p.Color=color;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 if shape then p.Shape=shape end;p.Parent=parent;return p
end
local Draw={};Draw.__index=Draw
function Draw:p(n,size,pos,c,shape) return raw(self.parent,n,size,self.origin+pos,c or self.color,shape) end
function Draw:ball(n,size,pos,c) return self:p(n,size,pos,c,Enum.PartType.Ball) end
function Draw:cyl(n,size,pos,c,axis)
 local p=self:p(n,size,pos,c,Enum.PartType.Cylinder)
 p.Orientation=if axis=="x" then v(0,0,0) elseif axis=="z" then v(0,90,0) else v(0,0,90)
 return p
end
function Draw:beam(n,a,b,width,c)
 local p=self:p(n,v(width,width,(b-a).Magnitude),(a+b)/2,c)
 p.CFrame=CFrame.lookAt(self.origin+(a+b)/2,self.origin+b);return p
end
function Draw:ring(n,pos,radius,c,axis,count)
 local m=Instance.new("Model");m.Name=n
 local steps=count or 16
 for i=1,steps do
  local a=i*2*math.pi/steps;local b=(i+1)*2*math.pi/steps
  local function point(t)
   if axis=="x" then return pos+v(0,math.sin(t)*radius,math.cos(t)*radius)
   elseif axis=="z" then return pos+v(math.cos(t)*radius,math.sin(t)*radius,0)
   else return pos+v(math.cos(t)*radius,0,math.sin(t)*radius) end
  end
  local old=self.parent;self.parent=m;self:beam(n,point(a),point(b),2.1,c);self.parent=old
 end
 m.WorldPivot=CFrame.new(self.origin+pos);m.Parent=self.parent;return m
end
function Draw:cone(n,pos,radius,height,c)
 for i=0,5 do self:cyl(n,v(height/6,radius*2*(1-i/7),radius*2*(1-i/7)),pos+v(0,i*height/6,0),c) end
end
function Draw:cloud(pos,s,c)
 for i=-2,2 do self:ball("CloudPuff",v(1.4,1,1)*s,pos+v(i*s*.65,math.cos(i)*s*.15,0),c or white) end
end
function Draw:flower(pos,s)
 self:p("FlowerStem",v(.5,s*3,.5),pos+v(0,s*1.5,0),mint)
 local p=pos+v(0,s*3,0)
 self:ball("FlowerHeart",v(s,s,s),p,gold)
 for i=1,6 do local a=i*math.pi/3;self:ball("Petal",v(s*1.2,s*1.2,s*.4),p+v(math.cos(a)*s,math.sin(a)*s,0),self.accent) end
end
function Draw:mushroom(pos,s)
 self:cyl("Stem",v(s*1.5,s*.65,s*.65),pos+v(0,s*.75,0),white)
 self:ball("MushroomCap",v(s*2,s*.85,s*1.8),pos+v(0,s*1.6,0),self.color)
 for i=1,5 do local a=i*1.25;self:ball("CapSpot",v(s*.28,s*.1,s*.28),pos+v(math.cos(a)*s*.55,s*1.96,math.sin(a)*s*.48),white) end
end
function Draw:gear(pos,r,c)
 self:cyl("Gear",v(3,r*1.6,r*1.6),pos,c,"z")
 for i=1,12 do
  local a=i*math.pi/6;local p=self:p("GearTooth",v(r*.35,r*.45,3),pos+v(math.cos(a)*r,math.sin(a)*r,0),c)
  p.Orientation=v(0,0,math.deg(a))
 end
 self:cyl("GearAxle",v(4,r*.35,r*.35),pos,white,"z")
end
function Draw:eyes(pos,s)
 for _,x in ipairs({-1,1}) do self:ball("Eye",v(s*.3,s*.42,s*.18),pos+v(x*s*.45,s*.2,s*.6),ink) end
 self:ball("Smile",v(s*.28,s*.12,s*.12),pos+v(0,-s*.15,s*.7),ink)
end
function Draw:tree(pos,s)
 self:cyl("Trunk",v(s*2,s*.7,s*.7),pos+v(0,s,0),gold)
 for i=1,3 do local a=i*math.pi*2/3;self:ball("Canopy",v(s*2,s*2,s*2),pos+v(math.cos(a)*s*.5,s*2.5,math.sin(a)*s*.5),self.color) end
end
local designs={}
function designs.glove(d)
 d:cyl("GlovePedestal",v(4,38,38),v(0,2,0),d.accent)
 d:p("Cuff",v(23,12,20),v(0,10,0),white).TopSurface=Enum.SurfaceType.Studs
 d:ball("BoxingGlove",v(35,31,30),v(0,30,0));d:ball("Thumb",v(15,19,18),v(17,25,5))
 for i=-1,1 do d:flower(v(i*24,0,17),3) end
end
function designs.mushroom(d)
 for i=1,5 do local a=i*1.26;d:mushroom(v(math.cos(a)*19,0,math.sin(a)*14),9+i%3*2) end
 d:beam("SkyBridge",v(-22,16,5),v(23,27,6),3,white);d:cloud(v(0,46,-6),7)
end
function designs.coaster(d)
 for j=0,1 do d:ring("CoasterLoop",v(-15+j*33,25,0),23,d.accent,"z") end
 for i=-2,2 do d:p("BoardwalkPier",v(2,18,2),v(i*13,9,8),white) end
 d:p("Car",v(16,7,11),v(-15,48,0));d:ball("Balloon",v(13,16,13),v(30,51,-5),d.accent)
end
function designs.pyramid(d)
 for i=0,6 do d:p("PyramidStep",v(68-i*8,5,54-i*6),v(0,2.5+i*5,0)) end
 d:p("Doorway",v(13,15,1),v(0,8,27.6),ink);d:ring("SunHalo",v(0,54,-8),14,d.accent,"z")
end
function designs.origami(d)
 for i=-2,2 do local p=d:p("FoldedFan",v(8,43,2),v(i*8,24,0),if i%2==0 then white else d.accent);p.Orientation=v(0,i*12,i*16) end
 for i=1,3 do d:beam("PaperSail",v(-18+i*10,0,20),v(-12+i*10,17,20),2,d.color) end
end
function designs.cactus(d)
 d:cyl("GiantCactus",v(46,15,15),v(0,23,0))
 for _,x in ipairs({-1,1}) do d:beam("CactusArm",v(x*6,19,0),v(x*24,19,0),7,d.color);d:cyl("ArmTip",v(19,8,8),v(x*24,27,0)) end
 for i=1,6 do local a=i*1.04;d:ball("CarnivalBulb",v(5,5,5),v(math.cos(a)*27,46+math.sin(a)*8,1),d.accent) end
 d:cone("CircusRoof",v(0,46,0),24,18,d.accent)
end
function designs.snowcone(d)
 d:cone("Cone",v(0,0,0),23,32,gold)
 d:ball("IceScoop",v(48,26,43),v(0,34,0),white);d:ball("Syrup",v(31,17,29),v(0,43,0))
 for i=-1,1 do d:p("IceCrystal",v(5,22+8*i,5),v(i*28,13,10),d.accent).Orientation=v(0,0,i*18) end
end
function designs.pinball(d)
 d:p("PinballTable",v(72,5,48),v(0,5,0),white)
 for i=1,5 do local a=i*1.25;d:cyl("Bumper",v(7,12,12),v(math.cos(a)*20,11,math.sin(a)*13)) end
 d:beam("Flipper",v(-20,9,19),v(-4,9,11),4,d.accent);d:beam("Flipper",v(20,9,19),v(4,9,11),4,d.accent)
 d:ball("Pinball",v(12,12,12),v(0,28,0),d.accent):SetAttribute("AmbientBob",2)
end
function designs.observatory(d)
 d:cyl("ObservatoryBase",v(20,46,46),v(0,10,0),white)
 d:ball("Dome",v(47,31,47),v(0,25,0))
 d:beam("Telescope",v(-2,32,0),v(26,49,0),10,white)
 d:cyl("Lens",v(3,14,14),v(26,49,0),d.accent,"x");d:ring("Orbit",v(0,37,-8),35,d.accent,"z")
end
function designs.volcano(d)
 for i=0,7 do d:cyl("VolcanoTier",v(5,68-i*6,68-i*6),v(0,2.5+i*5,0),d.color:Lerp(ink,.55)) end
 d:cyl("LavaCrater",v(1,25,25),v(0,40,0),d.accent).Material=Enum.Material.Neon
 for i=1,5 do local a=i*1.25;d:beam("LavaStream",v(math.cos(a)*10,39,math.sin(a)*10),v(math.cos(a)*34,1,math.sin(a)*34),2,d.accent) end
 d:cloud(v(0,57,0),10,white)
end
function designs.washer(d)
 d:p("WashingMachine",v(48,46,28),v(0,23,0),white)
 d:ring("WasherDoor",v(0,24,15),16,d.color,"z"):SetAttribute("AmbientSpin",.2)
 d:cyl("LavaWindow",v(1,29,29),v(0,24,15),d.accent,"z").Material=Enum.Material.Neon
 for i=1,4 do d:ball("Dial",v(4,4,2),v(-18+i*9,40,15),d.color) end
 d:beam("LaundryLine",v(-35,42,0),v(35,42,0),.8,ink)
end
function designs.clock(d)
 d:p("ClockTower",v(26,55,24),v(0,27.5,0),white)
 d:gear(v(0,43,14),17,d.accent);d:gear(v(-27,15,0),13,d.color)
 d:beam("MinuteHand",v(0,43,18),v(0,55,18),1.3,ink);d:beam("HourHand",v(0,43,19),v(9,43,19),1.5,ink)
 d:beam("Pendulum",v(0,31,15),v(0,9,15),1,d.color);d:ball("PendulumBob",v(8,8,4),v(0,9,15),gold)
end
function designs.comet(d)
 d:ball("CandyComet",v(36,36,36),v(0,31,0))
 for i=1,7 do d:ball("CometTail",v(16-i,16-i,16-i),v(i*8,31+i*2,-3),if i%2==0 then white else d.accent) end
 d:ring("CandyOrbit",v(0,31,0),29,d.accent,"y"):SetAttribute("AmbientSpin",.22)
end
function designs.monastery(d)
 for _,x in ipairs({-25,25}) do for _,z in ipairs({-15,15}) do
  d:cyl("MarshmallowColumn",v(30,11,11),v(x,15,z),white);d:ball("PillowCapital",v(17,9,17),v(x,32,z))
 end end
 for i=0,3 do d:p("TempleRoof",v(74-i*9,4,53-i*6),v(0,34+i*4,0),if i%2==0 then d.accent else white) end
end
function designs.ship(d)
 d:ball("GummyHull",v(74,22,31),v(0,11,0));d:p("Deck",v(65,3,27),v(0,19,0),gold)
 for _,x in ipairs({-18,14}) do
  d:p("Mast",v(2,51,2),v(x,39,0),white);d:p("Sail",v(23,22,1),v(x+3,45,0),d.accent).Orientation=v(0,0,10)
 end
 d:beam("Bowsprit",v(33,20,0),v(48,25,0),2,gold)
end
function designs.cheese(d)
 d:p("MoonCheese",v(51,35,35),v(0,17.5,0),gold)
 for i=1,6 do local x=(i%3-1)*16;local y=9+math.floor((i-1)/3)*16;d:cyl("CheeseHole",v(.7,8,8),v(x,y,18),d.color,"z") end
 d:beam("Drill",v(25,45,0),v(-5,32,0),8,white);d:gear(v(25,45,1),10,d.accent)
end
function designs.ramen(d)
 d:ball("RamenBowl",v(60,27,46),v(0,14,0))
 d:cyl("Broth",v(1,52,39),v(0,23,0),gold)
 for j=-2,2 do d:ring("Noodle",v(j*6,24,0),10,white,"y",10) end
 for _,x in ipairs({-12,12}) do d:beam("Chopstick",v(x,17,-4),v(x+18,66,-4),2,d.accent) end
 d:cloud(v(-5,49,0),5,white)
end
function designs.skatepark(d)
 for _,side in ipairs({-1,1}) do
  for i=0,7 do d:p("HalfpipeStep",v(5,2+i*i*.55,30),v(side*(12+i*4),1+i*i*.275,0),d.color) end
 end
 d:beam("GrindRail",v(-30,9,24),v(30,9,24),1.5,white)
 d:ring("SkatePlanet",v(0,50,-8),18,d.accent,"z")
 d:ball("Planet",v(20,20,20),v(0,50,-8))
end
function designs.pagoda(d)
 for i=0,3 do
  d:p("PagodaFloor",v(44-i*7,10,31-i*4),v(0,6+i*14,0),white)
  d:p("NeonEaves",v(58-i*8,3,42-i*5),v(0,12+i*14,0)).Material=Enum.Material.Neon
 end
 for _,x in ipairs({-24,24}) do d:p("NoodleSign",v(5,37,3),v(x,22,20),d.accent) end
end
function designs.lantern(d)
 for _,x in ipairs({-32,32}) do d:p("BridgeTower",v(4,49,4),v(x,24.5,0),white) end
 for i=-3,3 do
  local y=37+math.abs(i)*2;d:beam("LanternCable",v(i*10,y,0),v(i*10,25+math.abs(i)*2,0),.5,ink)
  d:ball("PaperLantern",v(8,11,8),v(i*10,25+math.abs(i)*2,0),if i%2==0 then d.color else d.accent)
 end
 d:p("LanternBridge",v(74,3,20),v(0,5,0),gold)
end
function designs.bamboo(d)
 for i=-3,3 do
  for j=0,4 do d:cyl("BambooNode",v(7,4,4),v(i*9,4+j*8+math.sin(i)*5,0),if j%2==0 then d.color else mint) end
  d:p("PianoKey",v(8,2,19),v(i*9,1,20),if i%2==0 then white else ink)
 end
 d:beam("ChimeBeam",v(-33,48,0),v(33,48,0),3,d.accent)
end
function designs.paperboat(d)
 d:p("PaperKeel",v(59,4,26),v(0,4,0),white)
 for _,x in ipairs({-1,1}) do d:beam("FoldedBow",v(0,3,0),v(x*36,17,0),8,white) end
 d:p("PaperMast",v(1.5,46,1.5),v(0,26,0),gold)
 for i=0,5 do d:p("FoldedSail",v(30-i*4,6,1),v(10-i*2,22+i*5,0),d.accent) end
end
function designs.carousel(d)
 d:cyl("CarouselBase",v(4,64,64),v(0,2,0),white)
 d:p("CarouselPole",v(5,44,5),v(0,25,0),gold)
 d:cone("Canopy",v(0,40,0),34,17)
 for i=1,6 do
  local a=i*math.pi/3;local p=v(math.cos(a)*24,0,math.sin(a)*24)
  d:p("RidePole",v(1,31,1),p+v(0,21,0),white);d:ball("SeaHorse",v(8,12,5),p+v(0,14,0),d.accent)
 end
end
function designs.jellyfish(d)
 d:ball("JellyDome",v(58,28,47),v(0,44,0))
 for i=1,9 do local a=i*math.pi*2/9
  for j=0,4 do d:ball("JellyTentacle",v(3,7,3),v(math.cos(a)*20+math.sin(j+a)*3,30-j*6,math.sin(a)*16),d.accent) end
 end
 d:eyes(v(0,41,21),8)
end
function designs.arcade(d)
 d:p("ArcadeCabinet",v(36,45,24),v(0,22.5,0))
 local p=d:p("Screen",v(27,22,1),v(0,30,12.6),ink)
 for i=1,5 do d:p("PixelFish",v(3+i,3,1),v(-12+i*4,25+math.sin(i)*5,13.2),d.accent).Material=Enum.Material.Neon end
 d:p("ControlDeck",v(37,3,12),v(0,15,15),white)
 d:ball("Joystick",v(5,5,5),v(-9,19,16),d.accent)
 for i=1,3 do d:cyl("Button",v(1,3,3),v(2+i*6,17,17),gold) end
end
function designs.cloudtrain(d)
 for i=-1,1 do
  d:cloud(v(i*23,8,0),8,white)
  d:p("TrainCar",v(21,18,18),v(i*23,22,0),if i==0 then d.accent else d.color)
  for j=-1,1,2 do d:cyl("Wheel",v(3,8,8),v(i*23+j*6,11,10),ink,"z") end
 end
 d:beam("Lightning",v(-9,45,0),v(4,58,0),5,gold);d:beam("Lightning",v(4,58,0),v(-5,58,0),5,gold)
end
function designs.crane(d)
 d:p("CraneBase",v(24,5,24),v(-20,2.5,0),white)
 d:p("CraneTower",v(9,58,9),v(-20,32,0))
 d:beam("CraneArm",v(-35,61,0),v(35,61,0),4,d.accent)
 d:beam("CraneBrace",v(-20,38,0),v(18,61,0),2,white)
 d:beam("HookCable",v(30,61,0),v(30,24,0),.7,ink)
 d:ring("Hook",v(30,22,0),5,gold,"z",10)
 for j=0,3 do d:ring("Rainbow",v(0,3,-12),34-j*5,({d.color,d.accent,gold,mint})[j+1],"z",12) end
end
function designs.kite(d)
 for i=-2,2 do
  local pos=v(i*15,28+math.cos(i)*12,0)
  local p=d:p("DiamondKite",v(16,22,1),pos,if i%2==0 then d.color else d.accent);p.Orientation=v(0,0,45)
  d:beam("KiteSpine",pos+v(0,-11,1),pos+v(0,11,1),.5,white)
  for j=1,4 do d:p("TailBow",v(5,3,1),pos+v(math.sin(j)*2,-11-j*5,0),gold).Orientation=v(0,0,j*40) end
 end
end
function designs.bathtub(d)
 d:ball("BathTub",v(74,28,43),v(0,14,0),white)
 d:ball("BathWater",v(65,6,34),v(0,24,0),d.color)
 d:ball("DuckBody",v(20,16,18),v(0,33,0),gold);d:ball("DuckHead",v(14,14,14),v(8,44,0),gold)
 d:ball("DuckBeak",v(7,3,7),v(16,43,1),d.accent)
 for i=1,7 do local p=d:ball("SoapBubble",v(6+i%3*2,6+i%3*2,6+i%3*2),v(math.cos(i)*24,30+i*3,math.sin(i)*15),white);p.Transparency=.5;p:SetAttribute("AmbientBob",1.3) end
end
function designs.pancake(d)
 for i=0,7 do d:cyl("Pancake",v(4,62-i*3,57-i*2),v(0,2+i*4,0),if i%2==0 then d.color else gold) end
 d:p("Butter",v(16,6,14),v(0,35,0),white).Orientation=v(0,24,0)
 for i=1,5 do d:ball("SyrupDrop",v(3,13,3),v(math.sin(i)*25,25,math.cos(i)*24),d.accent) end
end
function designs.waffle(d)
 d:p("Waffle",v(52,47,6),v(0,26,0),gold)
 for x=-2,2 do for y=0,3 do d:p("WafflePocket",v(7,7,1),v(x*10,11+y*10,3.6),d.color) end end
 d:gear(v(-36,17,0),12,d.accent);d:gear(v(36,17,0),12,d.accent)
 d:p("WaffleConveyor",v(78,5,18),v(0,3,0),white)
end
function designs.teacup(d)
 for i=1,6 do local a=i*1.5;local pos=v(math.cos(a)*24,6+i*7,math.sin(a)*10)
  d:cyl("Teacup",v(10,14,14),pos,white)
  d:ring("CupHandle",pos+v(9,0,0),4,d.accent,"z",8)
 end
 d:ring("TeaTornado",v(0,12,0),33,d.color,"y")
 d:cone("TeaSpout",v(0,1,0),12,46,d.accent)
end
function designs.robot(d)
 d:p("RobotBody",v(28,29,20),v(0,26,0))
 d:p("RobotHead",v(34,19,25),v(0,51,0),white);d:eyes(v(0,51,8),13)
 for _,x in ipairs({-1,1}) do d:p("Arm",v(12,26,12),v(x*24,26,0),d.accent);d:p("Foot",v(15,12,23),v(x*10,6,3),gold) end
 for i=-1,1 do d:cyl("HeadStud",v(3,5,5),v(i*9,62,0),d.accent) end
end
function designs.duck(d)
 d:cyl("RoyalPlinth",v(6,55,55),v(0,3,0),white)
 d:ball("Duck",v(45,31,35),v(0,22,0),gold)
 d:ball("Head",v(27,27,26),v(10,43,0),gold);d:ball("Beak",v(17,7,15),v(26,41,4))
 d:eyes(v(10,44,11),8)
 for i=-2,2 do d:cone("CrownPoint",v(10+i*5,57,0),3,9+3*(i%2),d.accent) end
end
function designs.bear(d)
 d:ball("BearBody",v(36,35,25),v(0,21,0));d:ball("BearHead",v(37,31,28),v(0,48,0))
 for _,x in ipairs({-1,1}) do
  d:ball("BearEar",v(15,15,12),v(x*16,61,0),d.accent)
  d:ball("BearFoot",v(16,12,20),v(x*12,6,8),white)
  d:ball("BearArm",v(14,23,14),v(x*23,28,0),d.accent)
 end
 d:ball("Belly",v(25,25,3),v(0,20,12),white);d:eyes(v(0,48,12),10)
end
function designs.bonsai(d)
 d:cyl("BonsaiPot",v(9,44,37),v(0,5,0),white)
 d:beam("BonsaiTrunk",v(0,8,0),v(-12,30,0),6,gold);d:beam("Branch",v(-12,30,0),v(16,44,0),4,gold)
 for i=-1,1 do d:ball("BonsaiCloud",v(35,12,24),v(i*16,36+i*7,0)) end
 d:ring("Moon",v(0,48,-13),23,d.accent,"z",20)
end
function designs.cathedral(d)
 for i=-2,2 do
  local h=50-math.abs(i)*8;d:p("CrystalSpire",v(9,h,14),v(i*13,h/2,0),if i%2==0 then d.color else d.accent).Orientation=v(0,0,i*6)
  d:cone("SpireTip",v(i*13,h,0),6,13,white)
 end
 d:ring("RoseWindow",v(0,27,10),13,gold,"z",12)
 for _,x in ipairs({-1,1}) do d:beam("FlyingButtress",v(x*20,33,0),v(x*42,0,7),5,white) end
end
function designs.envelope(d)
 d:p("Letter",v(64,39,7),v(0,25,0),white)
 d:beam("EnvelopeFold",v(-30,43,4),v(0,21,4),2,d.color);d:beam("EnvelopeFold",v(30,43,4),v(0,21,4),2,d.color)
 d:p("PrismStamp",v(15,17,1),v(20,33,4.5),d.accent).Orientation=v(0,0,8)
 for i=1,4 do d:p("FlyingLetter",v(15,9,2),v(-30+i*16,54+math.sin(i)*6,-4),d.color).Orientation=v(0,0,i*16) end
end
function designs.circuit(d)
 d:p("CircuitTower",v(40,54,8),v(0,27,0),ink)
 for i=-2,2 do
  d:p("CircuitTrace",v(2,15+math.abs(i)*7,1),v(i*8,20,5),d.color).Material=Enum.Material.Neon
  d:ball("Node",v(5,5,3),v(i*8,30+math.abs(i)*5,5),d.accent)
 end
 for _,x in ipairs({-1,1}) do d:beam("Antenna",v(x*20,51,0),v(x*30,66,0),2,white) end
 d:gear(v(0,10,10),9,gold)
end
function designs.joystick(d)
 d:cyl("ControllerDisc",v(7,66,44),v(0,4,0))
 d:p("JoystickShaft",v(5,35,5),v(-14,24,0),white)
 d:ball("JoystickBall",v(23,23,23),v(-14,45,0),d.accent)
 for i=1,4 do d:cyl("ArcadeButton",v(6,10,10),v(10+(i%2)*13,11,-10+math.floor((i-1)/2)*20),gold) end
 d:ring("PixelHalo",v(0,47,-14),33,d.accent,"z",8)
end
function designs.hologram(d)
 for _,x in ipairs({-28,28}) do d:p("Projector",v(13,7,23),v(x,4,0),white);d:beam("HologramRay",v(x,8,0),v(x,54,0),2,d.accent).Material=Enum.Material.Neon end
 for i=0,5 do local p=d:p("FloatingCityLayer",v(56-i*5,2,24-i*2),v(0,18+i*7,0));p.Transparency=.35;p.Material=Enum.Material.Neon end
 d:ring("HighwayRing",v(0,31,0),33,white,"z",12)
end
function designs.greenhouse(d)
 for _,x in ipairs({-25,25}) do for _,z in ipairs({-13,13}) do d:p("GreenhouseFrame",v(2,35,2),v(x,18,z),white) end end
 for _,z in ipairs({-13,13}) do d:beam("Roof",v(-25,36,z),v(0,54,z),2,d.accent);d:beam("Roof",v(25,36,z),v(0,54,z),2,d.accent) end
 for i=-2,2 do
  d:p("FloatingPlanter",v(10,7,10),v(i*12,9+math.abs(i)*7,0))
  d:flower(v(i*12,14+math.abs(i)*7,0),3)
 end
end
function designs.dinosaur(d)
 d:ball("DinoBody",v(44,24,26),v(0,21,0));d:beam("DinoNeck",v(14,22,0),v(25,49,0),12,d.color)
 d:ball("DinoHead",v(23,15,17),v(29,52,0))
 for _,x in ipairs({-13,12}) do for _,z in ipairs({-8,8}) do d:cyl("Leg",v(16,8,8),v(x,8,z)) end end
 d:beam("Tail",v(-19,21,0),v(-43,32,0),6,d.accent)
 d:ball("DiscoBall",v(18,18,18),v(-11,52,0),white)
 for i=1,6 do d:p("MirrorTile",v(5,5,1),v(-25+i*4,50+math.sin(i)*4,9),d.accent).Material=Enum.Material.Neon end
end
function designs.ferris(d)
 d:ring("FossilWheel",v(0,35,0),30,white,"z",18):SetAttribute("AmbientSpin",.08)
 for i=1,8 do local a=i*math.pi/4;local p=v(math.cos(a)*30,35+math.sin(a)*30,0)
  d:beam("BoneSpoke",v(0,35,0),p,2,white);d:ball("FossilGondola",v(10,8,8),p,d.accent)
 end
 for _,x in ipairs({-1,1}) do d:beam("Support",v(x*27,0,10),v(0,35,10),4,d.color) end
end
function designs.dragon(d)
 for i=0,6 do
  local pos=v(-33+i*11,25+math.sin(i)*13,0);d:ball("DragonFruitSegment",v(16,19,17),pos)
  d:cone("FruitSpine",pos+v(0,8,0),3,8,mint)
 end
 d:ball("DragonHead",v(23,19,21),v(39,25,0));d:eyes(v(40,26,8),7)
 for _,x in ipairs({-1,1}) do d:beam("Horn",v(37,33,x*6),v(35,48,x*11),3,d.accent) end
end
function designs.firefly(d)
 d:cyl("GiantJar",v(42,42,42),v(0,23,0),white).Transparency=.65
 d:cyl("JarLid",v(5,46,46),v(0,46,0))
 for i=1,13 do
  local a=i*2.3;local p=d:ball("FireflyGlow",v(3,3,3),v(math.sin(a)*14,8+i*2.6,math.cos(a)*14),gold);p.Material=Enum.Material.Neon;p:SetAttribute("AmbientBob",1)
 end
 d:beam("FairgroundBanner",v(-38,51,0),v(38,51,0),1,d.accent)
 for i=-3,3 do d:p("Pennant",v(8,10,1),v(i*11,47,0),if i%2==0 then d.accent else d.color).Orientation=v(0,0,45) end
end
function designs.pumpkin(d)
 d:ball("Pumpkin",v(55,43,43),v(0,23,0))
 for i=-2,2 do d:ball("PumpkinRib",v(12,43-math.abs(i)*3,42),v(i*8,23,0),d.color:Lerp(gold,.13)) end
 d:p("Stem",v(6,14,6),v(0,48,0),mint).Orientation=v(0,0,-15)
 for _,x in ipairs({-10,10}) do d:p("PumpkinEye",v(9,10,1),v(x,28,22),ink).Orientation=v(0,0,45) end
 d:ring("Planetarium",v(0,31,-10),39,d.accent,"y")
end
function designs.hotel(d)
 d:p("ToastHotel",v(53,54,20),v(0,27,0),gold)
 d:ball("ToastTop",v(54,24,21),v(0,52,0),white)
 for x=-1,1 do for y=0,2 do d:p("HotelWindow",v(9,10,1),v(x*16,16+y*15,10.8),d.color) end end
 d:ball("Ghost",v(23,29,15),v(-31,44,7),white);d:eyes(v(-31,46,13),7)
 d:beam("HotelKey",v(26,54,5),v(42,54,5),3,d.accent);d:ring("KeyRing",v(25,54,5),6,d.accent,"z",10)
end
function designs.marble(d)
 for j=0,2 do d:ring("MarbleRail",v(0,13+j*14,0),32-j*6,if j%2==0 then white else d.accent,"y") end
 for i=1,8 do local a=i*1.7;d:ball("Marble",v(10,10,10),v(math.cos(a)*28,13+(i%3)*14,math.sin(a)*28),if i%2==0 then d.color else d.accent) end
 for _,x in ipairs({-20,20}) do d:p("RailSupport",v(3,42,3),v(x,21,0),white) end
end
function designs.chess(d)
 for x=-2,2 do for z=-2,2 do d:p("ChessTile",v(13,.8,13),v(x*13,1,z*13),if (x+z)%2==0 then white else ink) end end
 d:cyl("KingBase",v(5,24,24),v(0,4,0),d.accent);d:cone("KingBody",v(0,7,0),10,30,white)
 d:ball("KingHead",v(18,12,18),v(0,41,0),white);d:p("CrownCross",v(4,16,4),v(0,53,0),gold);d:p("CrownCrossBar",v(13,4,4),v(0,55,0),gold)
end
function designs.saturn(d)
 d:ball("Saturn",v(46,46,46),v(0,38,0))
 local ring=d:ring("SaturnRings",v(0,38,0),39,d.accent,"y",24);ring:SetAttribute("AmbientSpin",.16)
 for i=1,5 do d:p("StationModule",v(12,14,15),v(-28+i*12,7,20),white) end
 d:beam("Antenna",v(0,11,20),v(0,28,20),1,ink)
end
function designs.library(d)
 for _,x in ipairs({-26,26}) do
  d:p("Bookcase",v(18,51,15),v(x,26,0),white)
  for j=0,3 do for k=0,2 do d:p("BookSpine",v(4,8,15),v(x-5+k*5,8+j*12,1),if (j+k)%2==0 then d.color else d.accent) end end
 end
 for i=1,6 do local p=d:p("FloatingBook",v(13,3,18),v(math.sin(i)*17,21+i*6,0),gold);p.Orientation=v(12,i*31,16);p:SetAttribute("AmbientBob",.8) end
end
function designs.bowling(d)
 d:p("BowlingLane",v(65,3,26),v(0,2,0),gold)
 for i=1,6 do
  local x=12+(i%3)*9;local z=-7+math.floor((i-1)/3)*14
  d:ball("PinBody",v(6,15,6),v(x,11,z),white);d:ball("PinHead",v(5,5,5),v(x,20,z),d.accent)
 end
 d:ball("BlackholeBall",v(23,23,23),v(-28,15,0),ink)
 d:ring("GravityVortex",v(-28,25,-8),28,d.color,"z",20):SetAttribute("AmbientSpin",.3)
end
function designs.quilt(d)
 for x=-2,2 do for y=0,3 do
  local p=d:p("QuiltPatch",v(12,12,2),v(x*12,8+y*12,math.sin(x+y)*5),if (x+y)%2==0 then d.color else d.accent)
  for j=-1,1,2 do d:p("Stitch",v(1,3,.6),p.Position-d.origin+v(j*4,0,1.4),white) end
 end end
 for i=-2,2 do d:beam("WarpThread",v(i*12,0,6),v(i*12,58,6),.5,gold) end
end
function designs.aquarium(d)
 d:ball("DreamTank",v(60,58,38),v(0,31,0),d.color).Transparency=.66
 d:cyl("TankStand",v(8,46,34),v(0,4,0),white)
 for i=1,6 do local pos=v(math.sin(i*2)*18,13+i*6,0);d:ball("Fish",v(12,7,5),pos,d.accent);d:p("FishTail",v(6,7,1),pos-v(8,0,0),gold).Orientation=v(0,0,45) end
 d:flower(v(-19,6,2),4);d:flower(v(18,6,-4),3)
end
function designs.castle(d)
 d:cloud(v(0,9,0),18,white)
 d:p("CastleHall",v(34,34,23),v(0,29,0),white)
 for _,x in ipairs({-28,28}) do d:cyl("CloudTower",v(46,16,16),v(x,29,0),white);d:cone("TowerRoof",v(x,52,0),13,17,d.accent) end
 for i=-2,2 do d:p("Battlement",v(6,7,9),v(i*8,49,8)) end
 d:p("Door",v(12,17,1),v(0,18,12),ink)
end
function designs.icecream(d)
 d:cone("Cone",v(0,0,0),23,27,gold)
 for i=0,3 do d:ball("IcecreamScoop",v(42-i*5,25,36-i*3),v(math.sin(i)*5,27+i*18,0),({white,d.color,d.accent,mint})[i+1]) end
 for i=1,13 do d:p("Sprinkle",v(1,4,1),v(math.cos(i)*16,35+(i%4)*15,15),if i%2==0 then gold else d.color).Orientation=v(0,0,i*27) end
end
function designs.symphony(d)
 for i=-3,3 do
  local h=25+math.cos(i)*19;d:cyl("OrganPipe",v(h,6,6),v(i*9,h/2,0),gold)
  d:cyl("PipeRim",v(2,9,9),v(i*9,h,0),white)
 end
 d:ring("Supernova",v(0,60,-8),24,d.accent,"z",16)
 for i=1,9 do local a=i*.7;d:beam("MusicRay",v(math.cos(a)*27,60+math.sin(a)*27,-8),v(math.cos(a)*36,60+math.sin(a)*36,-8),2,d.color) end
end
function designs.cosmic(d)
 for side=-1,1,2 do
  for i=0,4 do local p=d:p("OrigamiWing",v(11,40-i*4,2),v(side*(9+i*8),31+i*3,0),if i%2==0 then white else d.accent);p.Orientation=v(0,side*i*7,side*(20+i*8)) end
 end
 d:beam("ButterflyBody",v(0,9,0),v(0,57,0),4,d.color)
 for s=-1,1,2 do d:beam("Antenna",v(0,56,0),v(s*13,69,0),1,gold) end
end
function designs.beyond(d)
 for i=0,3 do d:ring("BeyondPortal",v(0,40,-i*7),34-i*6,({gold,d.color,white,d.accent})[i+1],"z",20) end
 d:p("GloveCuff",v(16,10,15),v(0,14,8),white)
 d:ball("FinalGlove",v(26,24,24),v(0,31,9),d.accent);d:ball("Thumb",v(11,14,12),v(13,27,13),d.accent)
 for s=-1,1,2 do d:ball("PocketUniverse",v(18,18,18),v(s*43,57,0));d:ring("UniverseOrbit",v(s*43,57,0),14,gold,"y",12) end
end
local function board(parent,name,size,pos,value,bg)
 local p=raw(parent,name,size,pos,bg)
 for _,face in ipairs({Enum.NormalId.Left,Enum.NormalId.Right}) do
  local g=Instance.new("SurfaceGui");g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=10;g.LightInfluence=0;g.Parent=p
  local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(.94,.9);l.Position=UDim2.fromScale(.03,.05);l.BackgroundTransparency=1;l.Font=Enum.Font.FredokaOne
  l.TextScaled=true;l.TextColor3=white;l.TextStrokeColor3=ink;l.TextStrokeTransparency=.1;l.Text=value;l.Parent=g
 end
 return p
end
function Builder.Build(parent,stage,x,options)
 options=options or {}
 local spec=Levels.Get(stage)
 local model=Instance.new("Model");model.Name=string.format("Level_%04d_%s",stage,spec.id)
 model:SetAttribute("VirtualStage",stage);model:SetAttribute("Theme",spec.id);model:SetAttribute("Kind",spec.kind)
 local L=Punch.BiomeLength
 local ground=raw(model,"Ground",v(L,2,280),v(x+L/2,-1,-55),spec.ground);ground.CanCollide=true;ground.CanQuery=true;ground.TopSurface=Enum.SurfaceType.Studs
 for i=0,7 do
  local p=raw(model,"Runway",v(L/8-.15,.3,82),v(x+(i+.5)*L/8,.2,4),if i%2==0 then spec.ground:Lerp(white,.4) else white)
  p.TopSurface=Enum.SurfaceType.Studs;p.CanCollide=true;p.CanQuery=true
 end
 for _,z in ipairs({-39,47}) do raw(model,"LaneEdge",v(L,.7,1.2),v(x+L/2,.5,z),spec.accent) end
 -- Oversized, studded theatrical scenery lives behind a completely clear flight lane.
 local back=raw(model,"StudBackdrop",v(L,74,2),v(x+L/2,35,-195),spec.color:Lerp(spec.ground,.5));back.FrontSurface=Enum.SurfaceType.Studs;back.BackSurface=Enum.SurfaceType.Studs
 for j=0,4 do
  local xx=x+j*L/4
  raw(model,"BackdropColumn",v(2.5,77,3),v(xx,36,-193),white)
  local a=v(xx,2,-191);local b=v(xx+L/4,69,-191)
  if j<4 then
   local p=raw(model,"Brace",v(1.4,1.4,(b-a).Magnitude),(a+b)/2,white);p.CFrame=CFrame.lookAt((a+b)/2,b)
  end
 end
 for _,z in ipairs({-56,65}) do
  local p=raw(model,"GatewayPillar",v(4,68,4),v(x+8,34,z),white);p.FrontSurface=Enum.SurfaceType.Studs
  raw(model,"GatewayLight",v(1.2,61,1),v(x+5.6,34,z),spec.accent).Material=Enum.Material.Neon
 end
 board(model,"LevelHeader",v(4,10,128),v(x+8,69,4),"WORLD "..stage.." / "..string.upper(spec.name),spec.color)
 board(model,"Milestone",v(1,9,43),v(x+L-36,8,67),Builder.Distance(Punch.Threshold(stage)).." FT",spec.color)
 if options.warp then board(model,"WarpMarker",v(1,8,100),v(x+12,55,4),"MILESTONE PORTAL / WORLD "..stage,spec.accent) end
 local hero=Instance.new("Model");hero.Name="Landmark";hero.Parent=model
 local d=setmetatable({parent=hero,origin=v(x+L*.54,0,-113),color=spec.color,accent=spec.accent},Draw)
 assert(designs[spec.kind],"Missing original landmark: "..spec.kind)(d)
 -- Theme-specific pocket scenery; never place tall props in the cinematic corridor.
 local decor=Instance.new("Model");decor.Name="PocketScenery";decor.Parent=model
 local e=setmetatable({parent=decor,origin=v(x,0,0),color=spec.color,accent=spec.accent},Draw)
 local rng=Random.new(spec.seed)
 for i=1,6 do
  local pos=v(28+(i-1)*51,0,-70-(i%2)*13)
  local family=spec.family
  if family=="forest" then e:tree(pos,4+i%3)
  elseif family=="ice" or family=="crystal" then
   local p=e:p("Crystal",v(3,12+i%3*5,3),pos+v(0,7,0));p.Orientation=v(0,i*35,(-1)^i*12);e:ball("Snowball",v(6,6,6),pos+v(4,2,3),white)
  elseif family=="desert" then
   e:cyl("Cactus",v(12,4,4),pos+v(0,6,0),mint);e:ball("Dune",v(15,6,11),pos, gold)
  elseif family=="candy" or family=="food" then
   e:p("CandyStick",v(1,15,1),pos+v(0,7.5,0),white);e:ball("CandyPop",v(8,8,4),pos+v(0,17,0),spec.accent)
  elseif family=="ocean" then
   for j=-1,1 do e:beam("Coral",pos,pos+v(j*4,10+3*j,0),2,spec.accent) end
  elseif family=="space" then
   e:ball("PlanetPebble",v(6+i,6+i,6+i),pos+v(0,9,0),spec.accent)
   if i%2==0 then e:ring("PlanetRing",pos+v(0,9,0),8,white,"y",8) end
  elseif family=="paper" then local p=e:p("PaperFold",v(9,14,1),pos+v(0,8,0),white);p.Orientation=v(0,0,30+i*15)
  elseif family=="lava" then
   e:cone("BasaltVent",pos,5,9,ink);e:ball("Ember",v(3,3,3),pos+v(0,12,0),spec.accent).Material=Enum.Material.Neon
  elseif family=="sky" then e:cloud(pos+v(0,19,0),5,white)
  elseif family=="toy" then
   local p=e:p("ToyBrick",v(10,7,8),pos+v(0,3.5,0),spec.accent);p.TopSurface=Enum.SurfaceType.Studs
   for j=-1,1 do e:cyl("BrickStud",v(1.2,2,2),pos+v(j*3,7.6,0),white) end
  else
   e:p("TechPylon",v(5,14,5),pos+v(0,7,0),white)
   e:ball("Signal",v(6,6,6),pos+v(0,16,0),spec.accent).Material=Enum.Material.Neon
  end
 end
 for i=1,5 do
  local p=e:ball("CloudPearl",v(8,5,5),v(30+i*52,57+rng:NextNumber()*15,-164),white);p:SetAttribute("AmbientBob",.6)
 end
 if spec.cycle>0 then
  -- Echo geometry is seeded, not only a recolor of the original destination.
  for i=1,3+(spec.cycle%4) do
   local p=e:p("EchoShard",v(3,9+i,3),v(20+i*37,13+i*4,-153),spec.accent);p.Orientation=v(0,spec.cycle*17+i*24,30)
  end
  e:ring("EchoConstellation",v(260,48,-147),15+spec.cycle%5*2,spec.accent,"z",10+spec.cycle%5)
 end
 model.WorldPivot=CFrame.new(x,0,0);model.Parent=parent
 return model
end
function Builder.Distance(n)
 if n>=1e12 then local exp=math.floor(math.log10(n));return string.format("%.2fe%d",n/10^exp,exp) end
 if n>=1e9 then return string.format("%.1fB",n/1e9) end
 if n>=1e6 then return string.format("%.1fM",n/1e6) end
 if n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n+.5))
end
-- Old decorative hub cliffs sit behind the first three track worlds. Mask only
-- those overlapping dressing parts locally; do not move/delete the hub or anchors.
function Builder.MaskHub(hub)
 local changed={}
 if not hub then return changed end
 for _,name in ipairs({"Cliffs","Hills","Trees"}) do
  local folder=hub:FindFirstChild(name)
  if folder then for _,p in ipairs(folder:GetDescendants()) do
   if p:IsA("BasePart") and p.Position.X+p.Size.X/2>=40 and p.Position.X-p.Size.X/2<1000
     and p.Position.Z+p.Size.Z/2>-197 and p.Position.Z-p.Size.Z/2< -43 then
    table.insert(changed,{part=p,previous=p.LocalTransparencyModifier})
    p.LocalTransparencyModifier=1
   end
  end end
 end
 return changed
end
function Builder.Preview(parent)
 local preview=Instance.new("Folder");preview.Name="EditorPreview";preview.Parent=parent
 for i=1,Levels.Count do
  Builder.Build(preview,i,Punch.TrackStartX+(i-1)*Punch.BiomeLength)
  if i%2==0 then task.wait() end
 end
 return preview
end
return Builder

]===]}
assert(not resolve("ServerScriptService.PunchExpansionRuntime"),"New namespace occupied: ServerScriptService.PunchExpansionRuntime")
assert(resolve("StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController").Source==[===[-- Visual only. Your own manual punch plays a short cutscene: wind up, punch,
-- freeze-frame impact, then the camera chases the dummy down the biome track
-- and shows the distance. Other players' punches just send the dummy flying.
-- The server already decided feet, Coins and the landing spot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PunchConfig = require(ReplicatedStorage.Shared.Config.Punch)
local Format = require(ReplicatedStorage.Shared.Util.Format)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local PunchFxController = {}

local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)
local flying = false
local inCutscene = false
local gui = nil

local function setVisible(model, visible)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = if visible then 0 else 1
		elseif d:IsA("Decal") then
			d.Transparency = if visible then 0 else 1
		elseif d:IsA("BillboardGui") or d:IsA("ProximityPrompt") then
			d.Enabled = visible
		end
	end
end

local function bigText(text, color, size, y)
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, y)
	label.Size = UDim2.fromScale(0.9, size)
	label.BackgroundTransparency = 1
	label.FontFace = FONT
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 5
	stroke.Color = Color3.fromRGB(20, 20, 32)
	stroke.Parent = label
	local scale = Instance.new("UIScale")
	scale.Scale = 0.3
	scale.Parent = label
	label.Parent = gui
	TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	return label
end

local function fadeOut(label, delay)
	task.delay(delay, function()
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		local stroke = label:FindFirstChildOfClass("UIStroke")
		if stroke then
			TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end
		task.wait(0.35)
		label:Destroy()
	end)
end

local function flash()
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.BackgroundTransparency = 0
	f.BorderSizePixel = 0
	f.Parent = gui
	TweenService:Create(f, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
	task.delay(0.4, function()
		f:Destroy()
	end)
end

local function shoulder(character)
	local r15 = character:FindFirstChild("RightUpperArm")
	if r15 and r15:FindFirstChild("RightShoulder") then
		return r15.RightShoulder, function(angle)
			return CFrame.Angles(angle, 0, 0)
		end
	end
	local torso = character:FindFirstChild("Torso")
	if torso and torso:FindFirstChild("Right Shoulder") then
		return torso["Right Shoulder"], function(angle)
			return CFrame.Angles(0, 0, angle)
		end
	end
	return nil, nil
end

-- Motor6D.C0 can't be tweened, so lerp it by hand (runs in the background)
local function animateJoint(joint, goal, duration)
	if not joint then
		return
	end
	local from = joint.C0
	task.spawn(function()
		local t0 = os.clock()
		while joint.Parent do
			local a = math.clamp((os.clock() - t0) / duration, 0, 1)
			joint.C0 = from:Lerp(goal, 1 - (1 - a) ^ 2)
			if a >= 1 then
				break
			end
			RunService.RenderStepped:Wait()
		end
	end)
end

local function makeGhost(dummy)
	local ghost = dummy:Clone()
	for _, d in ghost:GetDescendants() do
		if d:IsA("ProximityPrompt") or d:IsA("BillboardGui") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.CanCollide = false
			d.CanQuery = false
			d.Anchored = true
		end
	end
	local trail = Instance.new("ParticleEmitter")
	trail.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	trail.Rate = 60
	trail.Lifetime = NumberRange.new(0.4, 0.8)
	trail.Speed = NumberRange.new(0, 2)
	trail.Size = NumberSequence.new(1.5, 0)
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 80, 200))
	trail.Parent = ghost.PrimaryPart
	ghost.Parent = workspace
	return ghost
end

-- Flies the dummy from its stand to trackX. onStep(position) runs every frame.
local function fly(dummy, feet, trackX, onStep)
	flying = true
	local ghost = makeGhost(dummy)
	setVisible(dummy, false)
	local start = dummy:GetPivot()
	local decades = math.clamp(math.log10(math.max(feet, 10)) - 1, 0, 6)
	local duration = 1.6 + decades * 0.55
	local travel = trackX - start.Position.X
	local peak = math.clamp(18 + decades * 8, 18, 64)
	local t0 = os.clock()
	local done = false
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local a = math.clamp((os.clock() - t0) / duration, 0, 1)
		-- fast launch, slows down near the end
		local eased = 1 - (1 - a) ^ 2
		local pos = start.Position + Vector3.new(travel * eased, 4 * peak * a * (1 - a), 0)
		ghost:PivotTo(CFrame.new(pos) * start.Rotation * CFrame.Angles(0, 0, -a * math.pi * 10))
		if onStep then
			onStep(pos, a)
		end
		if a >= 1 then
			connection:Disconnect()
			done = true
		end
	end)
	while not done do
		task.wait()
	end
	return ghost, function()
		ghost:Destroy()
		setVisible(dummy, true)
		flying = false
	end
end

local function cutscene(dummy, feet, coins, trackX)
	inCutscene = true
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		inCutscene = false
		return
	end
	local camera = workspace.CurrentCamera
	local oldFov = camera.FieldOfView
	local scale = character:GetScale()
	local dummyPos = dummy:GetPivot().Position

	-- lock the player in place facing the dummy
	root.Anchored = true
	root.CFrame = CFrame.lookAt(root.Position, Vector3.new(dummyPos.X, root.Position.Y, dummyPos.Z))
	camera.CameraType = Enum.CameraType.Scriptable
	local mid = (root.Position + dummyPos) / 2
	local shot = CFrame.lookAt(mid + Vector3.new(-2, 3 + 2 * scale, 14 + 4 * scale), mid)
	TweenService:Create(camera, TweenInfo.new(0.25), {CFrame = shot, FieldOfView = 60}):Play()

	-- wind up
	local joint, rot = shoulder(character)
	local baseC0 = joint and joint.C0
	if joint then
		animateJoint(joint, baseC0 * rot(math.rad(-60)), 0.45)
	end
	TweenService:Create(camera, TweenInfo.new(0.5), {FieldOfView = 52}):Play()
	task.wait(0.5)

	-- PUNCH
	if joint then
		animateJoint(joint, baseC0 * rot(math.rad(95)), 0.08)
	end
	TweenService:Create(root, TweenInfo.new(0.08), {CFrame = root.CFrame * CFrame.new(0, 0, -1.5)}):Play()
	task.wait(0.08)

	-- impact freeze frame
	flash()
	local pow = bigText("POW!", Color3.fromRGB(255, 230, 60), 0.28, 0.4)
	pow.Rotation = math.random(-12, 12)
	camera.FieldOfView = 40
	local shakeEnd = os.clock() + 0.4
	while os.clock() < shakeEnd do
		camera.CFrame = shot * CFrame.new(math.random(-10, 10) / 25, math.random(-10, 10) / 25, 0)
		task.wait()
	end
	fadeOut(pow, 0.1)
	if joint then
		animateJoint(joint, baseC0, 0.3)
	end

	-- chase cam
	camera.FieldOfView = 70
	local lastBiome = 0
	local ghost, cleanup = fly(dummy, feet, trackX, function(pos)
		local goal = CFrame.lookAt(pos + Vector3.new(-28, 12, 34), pos)
		camera.CFrame = camera.CFrame:Lerp(goal, 0.25)
		local index, name = PunchConfig.BiomeAt(pos.X)
		if index ~= lastBiome then
			lastBiome = index
			fadeOut(bigText(string.upper(name) .. "!", Color3.new(1, 1, 1), 0.1, 0.2), 0.6)
		end
	end)

	-- landing
	local banner = bigText(Format.Number(feet) .. " FT!", Color3.fromRGB(255, 220, 60), 0.2, 0.42)
	local reward = bigText("+" .. Format.Number(coins) .. " Coins", Color3.fromRGB(120, 255, 140), 0.09, 0.56)
	task.wait(1.6)
	fadeOut(banner, 0)
	fadeOut(reward, 0)
	cleanup()

	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = oldFov
	if root.Parent then
		root.Anchored = false
	end
	inCutscene = false
end

local function coinPopup(text)
	local label = bigText(text, Color3.fromRGB(255, 220, 60), 0.06, 0.3)
	fadeOut(label, 1)
end

function PunchFxController.IsBusy()
	return inCutscene
end

function PunchFxController.Start()
	gui = Instance.new("ScreenGui")
	gui.Name = "PunchFxGui"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local dummy = workspace:WaitForChild("Map"):WaitForChild("Gameplay"):WaitForChild("PunchLane"):WaitForChild("Dummy")
	local prompt = dummy:WaitForChild("Torso"):WaitForChild("PunchPrompt")
	while not dummy.PrimaryPart do
		task.wait()
	end

	Remotes.PunchFx.OnClientEvent:Connect(function(puncher, feet, coins, trackX, isAuto)
		if puncher == player and not isAuto and not inCutscene then
			prompt.Enabled = false
			task.spawn(function()
				local ok, err = pcall(cutscene, dummy, feet, coins, trackX)
				if not ok then
					warn("[PunchFx] cutscene failed: " .. tostring(err))
					-- never leave the player stuck
					local camera = workspace.CurrentCamera
					camera.CameraType = Enum.CameraType.Custom
					camera.FieldOfView = 70
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.Anchored = false
					end
					inCutscene = false
					flying = false
					setVisible(dummy, true)
				end
				prompt.Enabled = true
			end)
			return
		end
		if puncher == player then
			coinPopup("\u{1F44A} " .. Format.Number(feet) .. " FT  +" .. Format.Number(coins) .. " Coins")
		end
		if not flying and not inCutscene then
			task.spawn(function()
				local _, cleanup = fly(dummy, feet, trackX, nil)
				task.wait(0.8)
				cleanup()
			end)
		end
	end)
end

return PunchFxController
]===],"Baseline changed: StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController")
assert(not resolve("StarterPlayer.StarterPlayerScripts.Controllers.PunchTrackController"),"New namespace occupied: StarterPlayer.StarterPlayerScripts.Controllers.PunchTrackController")
assert(resolve("ServerScriptService.Services.StatService").Source==[===[-- Owns Strength, XP, Level, Coins and every multiplier. Replicates state as
-- player attributes (the client only reads them).
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage.Shared.Config
local StatsConfig = require(Config.Stats)
local Zones = require(Config.Zones)
local RebirthConfig = require(Config.Rebirth)
local PetsConfig = require(Config.Pets)
local Gym = require(Config.Gym)
local DataService = require(script.Parent.DataService)

local StatService = {}

local owned = {}
local currentWorld = {}
local currentGym = {}

function StatService.SetPass(player, passKey, value)
	owned[player] = owned[player] or {}
	owned[player][passKey] = value
	player:SetAttribute("Pass_" .. passKey, value)
	StatService.Refresh(player)
end

function StatService.OwnsPass(player, passKey)
	return owned[player] ~= nil and owned[player][passKey] == true
end

function StatService.SetLocation(player, world, gymTier)
	if currentWorld[player] == world and currentGym[player] == gymTier then
		return
	end
	currentWorld[player] = world
	currentGym[player] = gymTier
	StatService.Refresh(player)
end

function StatService.CurrentWorld(player)
	return currentWorld[player] or 1
end

-- Highest world the player may enter (Strength or the World Skip product)
function StatService.AllowedWorld(profile)
	local allowed = 1
	for i, world in Zones.List do
		if profile.Strength >= world.Required then
			allowed = i
		end
	end
	return math.max(allowed, math.min(profile.WorldUnlocked or 1, #Zones.List))
end

function StatService.GymUnlocked(player, tier)
	local profile = DataService.Get(player)
	local info = Gym.Tiers[tier]
	if not profile or not info then
		return false
	end
	if info.Pass then
		return StatService.OwnsPass(player, info.Pass)
	end
	return profile.Rebirths >= (info.Rebirths or 0)
end

function StatService.EquippedIds(profile)
	local ids = {}
	for _, entry in profile.PetInv do
		if entry.e then
			table.insert(ids, entry.p)
		end
	end
	return ids
end

function StatService.PetSlots(player)
	return PetsConfig.BaseSlots + (if StatService.OwnsPass(player, "PetSlots") then PetsConfig.ExtraSlotsPass else 0)
end

function StatService.Multipliers(player)
	local profile = DataService.Get(player)
	local world = Zones.List[currentWorld[player] or 1]
	local gymTier = currentGym[player]
	local gamepass = 1
	if StatService.OwnsPass(player, "Double") then
		gamepass *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		gamepass *= 1.5
	end
	return {
		World = world.Multiplier,
		Gym = if gymTier then Gym.Tiers[gymTier].Multiplier else 1,
		Rebirth = if profile then RebirthConfig.Multiplier(profile.Rebirths) else 1,
		Gamepass = gamepass,
		Pets = if profile then PetsConfig.Multiplier(StatService.EquippedIds(profile)) else 1,
		Boost = if profile and profile.BoostEnd > os.time() then 2 else 1,
	}
end

function StatService.Gain(player)
	local total = StatsConfig.BaseGain
	for _, value in StatService.Multipliers(player) do
		total *= value
	end
	return total
end

function StatService.CoinMultiplier(player)
	local profile = DataService.Get(player)
	local m = 1
	if StatService.OwnsPass(player, "DoubleCoins") then
		m *= 2
	end
	if StatService.OwnsPass(player, "VIP") then
		m *= 1.5
	end
	if profile and profile.CoinBoostEnd > os.time() then
		m *= 2
	end
	return m
end

function StatService.IsLucky(player)
	local profile = DataService.Get(player)
	return StatService.OwnsPass(player, "Lucky") or (profile ~= nil and profile.LuckEnd > os.time())
end

function StatService.Refresh(player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	local mults = StatService.Multipliers(player)
	player:SetAttribute("Strength", profile.Strength)
	player:SetAttribute("XP", profile.XP)
	player:SetAttribute("XPNeeded", StatsConfig.XpForLevel(profile.Level))
	player:SetAttribute("Level", profile.Level)
	player:SetAttribute("Rebirths", profile.Rebirths)
	player:SetAttribute("Gain", StatService.Gain(player))
	player:SetAttribute("Zone", currentWorld[player] or 1)
	player:SetAttribute("GymTier", currentGym[player] or 0)
	player:SetAttribute("AllowedZone", StatService.AllowedWorld(profile))
	player:SetAttribute("BoostEnd", profile.BoostEnd)
	player:SetAttribute("CoinBoostEnd", profile.CoinBoostEnd)
	player:SetAttribute("LuckEnd", profile.LuckEnd)
	player:SetAttribute("AutoTrainOn", profile.AutoTrainOn)
	player:SetAttribute("AutoPunchOn", profile.AutoPunchOn)
	player:SetAttribute("AutoHatchOn", profile.AutoHatchOn)
	player:SetAttribute("Coins", profile.Coins)
	player:SetAttribute("CoinMult", StatService.CoinMultiplier(player))
	player:SetAttribute("BestPunch", profile.BestPunch)
	player:SetAttribute("PetSlots", StatService.PetSlots(player))
	player:SetAttribute("PetInv", HttpService:JSONEncode(profile.PetInv))
	for name, value in mults do
		player:SetAttribute("Mult_" .. name, value)
	end

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Strength.Value = math.min(math.floor(profile.Strength), 2 ^ 53)
		stats.Coins.Value = math.min(math.floor(profile.Coins), 2 ^ 53)
		stats.Rebirths.Value = profile.Rebirths
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local speed = StatsConfig.WalkSpeed(profile.Strength)
		if StatService.OwnsPass(player, "FastWalk") then
			speed *= 1.5
		end
		if not character:GetAttribute("Frozen") then
			humanoid.WalkSpeed = speed
		end
		local target = StatsConfig.BodyScale(profile.Strength)
		if math.abs(character:GetScale() - target) > 0.02 then
			character:ScaleTo(target)
		end
	end
end

function StatService.AddStrength(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Strength += amount
	profile.TotalStrength += amount
	profile.XP += amount
	while profile.XP >= StatsConfig.XpForLevel(profile.Level) do
		profile.XP -= StatsConfig.XpForLevel(profile.Level)
		profile.Level += 1
	end
	StatService.Refresh(player)
end

function StatService.AddLevels(player, count)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	profile.Level += count
	StatService.Refresh(player)
end

function StatService.AddCoins(player, amount)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.Coins += amount
	StatService.Refresh(player)
end

local function onLoaded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	for _, name in {"Strength", "Coins", "Rebirths"} do
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Parent = stats
	end
	stats.Parent = player
	player:SetAttribute("Loaded", true)
	StatService.Refresh(player)
end

function StatService.Start()
	DataService.ProfileLoaded:Connect(onLoaded)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.defer(StatService.Refresh, player)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		owned[player] = nil
		currentWorld[player] = nil
		currentGym[player] = nil
	end)
end

return StatService
]===],"Baseline changed: ServerScriptService.Services.StatService")
assert(resolve("ReplicatedStorage.Shared.Config.Punch").Source==[===[-- Punch the dummy. Distance is in FEET and scales hard with Strength
-- (10K Strength = 33K ft). The dummy flies along the biome track; track
-- position is log scale so every 10x more feet reaches the next biome.
local Punch = {}

Punch.Cooldown = 2
Punch.AutoInterval = 3
Punch.MaxRange = 18
Punch.TrackStartX = 40
Punch.BiomeLength = 1000
Punch.TrackZ = 0

Punch.Biomes = {"Grass Fields", "Desert", "Snow Mountains", "Volcano", "Candy Land", "Outer Space"}

function Punch.Feet(strength)
	return math.floor(3.3 * strength) + 5
end

-- Coins scale with feet, your best world and coin multipliers
function Punch.Coins(feet, worldMultiplier, coinMultiplier)
	return math.floor(feet ^ 0.75 * 2 * worldMultiplier * coinMultiplier)
end

-- Where on the track (x) a punch of this many feet lands
function Punch.TrackX(feet)
	local decades = math.clamp(math.log10(math.max(feet, 10)) - 1, 0, #Punch.Biomes)
	return Punch.TrackStartX + decades * Punch.BiomeLength
end

function Punch.BiomeAt(x)
	local index = math.clamp(math.floor((x - Punch.TrackStartX) / Punch.BiomeLength) + 1, 1, #Punch.Biomes)
	return index, Punch.Biomes[index]
end

return Punch
]===],"Baseline changed: ReplicatedStorage.Shared.Config.Punch")
assert(not resolve("ReplicatedStorage.Shared.Config.PunchLevels"),"New namespace occupied: ReplicatedStorage.Shared.Config.PunchLevels")
assert(resolve("ReplicatedStorage.Shared.Util.Format").Source==[===[-- 1234 -> 1.2K, 5600000 -> 5.6M
local Format = {}

local SUFFIXES = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

function Format.Number(n)
	n = math.floor(n)
	if n < 1000 then
		return tostring(n)
	end
	local i = 1
	local v = n
	while v >= 1000 and i < #SUFFIXES do
		v /= 1000
		i += 1
	end
	if v >= 100 then
		return math.floor(v) .. SUFFIXES[i]
	end
	local s = string.format("%.1f", math.floor(v * 10) / 10)
	s = string.gsub(s, "%.0$", "")
	return s .. SUFFIXES[i]
end

function Format.Multiplier(m)
	local s = string.format("%.2f", m)
	s = string.gsub(s, "0+$", "")
	s = string.gsub(s, "%.$", "")
	return "x" .. s
end

return Format
]===],"Baseline changed: ReplicatedStorage.Shared.Util.Format")
assert(not resolve("ReplicatedStorage.Shared.Util.PunchTrackBuilder"),"New namespace occupied: ReplicatedStorage.Shared.Util.PunchTrackBuilder")
for name,v in pairs(src) do local fn,err=loadstring(v.source);assert(fn,name..": "..tostring(err)) end
local backup=game.ServerStorage:FindFirstChild("PunchExpansion_Backup")
if not backup then
 backup=Instance.new("Folder");backup.Name="PunchExpansion_Backup";backup:SetAttribute("Camera",workspace.CurrentCamera.CFrame);backup.Parent=game.ServerStorage
 local t=workspace.Map.Track:Clone();t.Parent=backup
 local bag=Instance.new("Folder");bag.Name="Scripts";bag.Parent=backup
 local i=0
 for _,root in ipairs({game.ReplicatedStorage,game.ServerScriptService,game.StarterPlayer.StarterPlayerScripts}) do
  for _,v in ipairs(root:GetDescendants()) do if v:IsA("LuaSourceContainer") then
   local c=v:Clone();c:SetAttribute("OriginalPath",v:GetFullName());c.Name="Script"..i;c.Parent=bag;i+=1
  end end
 end
end
assert(backup:FindFirstChild("Track") and backup:FindFirstChild("Scripts"),"Incomplete backup")
for path,v in pairs(src) do
 local old=resolve(path);if old then old:Destroy() end
 local parentPath,name=path:match("^(.*)%.([^%.]+)$")
 local obj=Instance.new(v.class);obj.Name=name;obj.Source=v.source;obj.Parent=assert(resolve(parentPath),parentPath)
end
local track=workspace.Map.Track;track:Destroy()
track=Instance.new("Folder");track.Name="Track";track:SetAttribute("Build","PunchExpansion_60_v1");track.Parent=workspace.Map
local builder=require(game.ReplicatedStorage.Shared.Util.PunchTrackBuilder)
local masks=builder.MaskHub(workspace.Map.Hub);local records={}
for _,m in ipairs(masks) do table.insert(records,{path=m.part:GetFullName(),value=m.previous}) end
local value=Instance.new("StringValue");value.Name="HubMask";value.Value=game:GetService("HttpService"):JSONEncode(records);value.Parent=backup
builder.Preview(track)
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(195,105,160),Vector3.new(195,22,-90))
return "INSTALL_PASS scripts=33 original_worlds=60 old_max_wall=removed hub_and_economy=preserved"

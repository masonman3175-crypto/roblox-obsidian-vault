assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local function resolve(path)local p=game;for n in path:gmatch("[^%.]+") do p=p and p:FindFirstChild(n) end;return p end
local src={}
src["ServerScriptService.TrackExtensionRuntime"]={class="Script",source=[===[-- Only authoring previews are removed in Play. The original six biomes stay intact.
local track=workspace:WaitForChild("Map"):WaitForChild("Track")
local preview=track:FindFirstChild("ExtensionsPreview")
if preview then
 for _,world in ipairs(preview:GetChildren()) do world:Destroy();task.wait() end
 preview:Destroy()
end
print("[TrackExtension] original biomes=6; appended landscape catalog=60; extra runtime world budget=8")

]===]}
src["StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController"]={class="ModuleScript",source=[===[-- Visual only. Your own manual punch plays a short cutscene: wind up, punch,
-- freeze-frame impact, then the camera chases the dummy down the biome track
-- and shows the distance. Other players' punches just send the dummy flying.
-- The server already decided feet, Coins and the landing spot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PunchConfig = require(ReplicatedStorage.Shared.Config.Punch)
local TrackExtension = require(script.Parent.TrackExtensionController)
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
	if r15 and r15:FindFirstChild("RightShoulder") and r15.RightShoulder:IsA("Motor6D") then
		return r15.RightShoulder, function(angle)
			return CFrame.Angles(angle, 0, 0)
		end
	end
	local torso = character:FindFirstChild("Torso")
	if torso and torso:FindFirstChild("Right Shoulder") and torso["Right Shoulder"]:IsA("Motor6D") then
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
	TrackExtension.Prepare(trackX)
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
		TrackExtension.Focus(pos.X)
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
		TrackExtension.Release()
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
	TrackExtension.Start()
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
					TrackExtension.Release()
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
]===]}
src["StarterPlayer.StarterPlayerScripts.Controllers.TrackExtensionController"]={class="ModuleScript",source=[===[-- Streams only appended worlds; never rebuilds, hides or removes the six originals.
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Punch=require(RS.Shared.Config.Punch)
local Builder=require(RS.Shared.Util.TrackLandscapeBuilder)
local C={}
local started=false
local root
local loaded={}
local target=nil
local focus=7
local desired={}
local running=false
local journey=false
local generation=0
local function plan()
 local ids={}
 local function add(n) if n>=7 and not table.find(ids,n) then table.insert(ids,n) end end
 if target then add(target);add(target+1) end
 add(focus);add(focus+1);add(focus+2);add(focus-1);add(focus-2)
 while #ids>Punch.MaxExtraWorlds do table.remove(ids) end
 return ids
end
local function schedule()
 desired=plan();generation+=1
 if running then return end
 running=true
 task.spawn(function()
  local ok,err=pcall(function()
   while true do
    local version=generation
    local want=desired
    for n,m in pairs(loaded) do if not table.find(want,n) then m:Destroy();loaded[n]=nil end end
    for _,n in ipairs(want) do
     if version~=generation then break end
     if not loaded[n] then loaded[n]=Builder.Build(root,n,{lod=true});task.wait() end
    end
    if generation==version then break end
   end
  end)
  running=false
  if not ok then warn("[TrackExtension] stream: "..tostring(err)) end
 end)
end
function C.Start()
 if started then return end;started=true
 root=Instance.new("Folder");root.Name="LocalTrackExtensions";root.Parent=workspace:WaitForChild("Map"):WaitForChild("Track")
 schedule()
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.25 or journey then return end;elapsed=0
  local character=Players.LocalPlayer.Character
  local p=character and character:FindFirstChild("HumanoidRootPart")
  if p then C.Focus(p.Position.X) end
 end)
end
function C.Prepare(x)
 C.Start();journey=true
 while running do task.wait() end
 target=math.max(7,(Punch.BiomeAt(x)))
 -- Destination is ready before the punch camera departs. It is never an empty sky.
 for _,n in ipairs({target,target+1}) do
  if not loaded[n] then
   local count=0;for _ in pairs(loaded) do count+=1 end
   if count>=Punch.MaxExtraWorlds then
    for old,m in pairs(loaded) do if old~=target and old~=target+1 then m:Destroy();loaded[old]=nil;break end end
   end
   loaded[n]=Builder.Build(root,n,{lod=true});task.wait()
  end
 end
 schedule()
end
function C.Focus(x)
 local stage=math.max(7,(Punch.BiomeAt(x)))
 if stage~=focus then focus=stage;schedule() end
end
function C.Release()
 journey=false;target=nil;focus=7;schedule()
end
function C.Audit()
 local ids={};local parts=0
 for n,m in pairs(loaded) do table.insert(ids,n);for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then parts+=1 end end end
 table.sort(ids)
 return {stages=ids,extraWorlds=#ids,extraParts=parts,budget=Punch.MaxExtraWorlds,working=running}
end
return C

]===]}
src["ReplicatedStorage.Shared.Config.Punch"]={class="ModuleScript",source=[===[-- Punch the dummy. Distance is in FEET and scales hard with Strength
-- (10K Strength = 33K ft). The dummy flies along the biome track; track
-- position is log scale so every 10x more feet reaches the next biome.
local Catalog = require(script.Parent.TrackExtensionCatalog)
local Punch = {}

Punch.Cooldown = 2
Punch.AutoInterval = 3
Punch.MaxRange = 18
Punch.TrackStartX = 40
Punch.BiomeLength = 1000
Punch.TrackZ = 0

Punch.Biomes = table.clone(Catalog.Originals)
for _,entry in ipairs(Catalog.List) do table.insert(Punch.Biomes,entry[1]) end
Punch.MaxExtraWorlds=8

function Punch.Feet(strength)
	return math.floor(3.3 * strength) + 5
end

-- Coins scale with feet, your best world and coin multipliers
function Punch.Coins(feet, worldMultiplier, coinMultiplier)
	return math.floor(feet ^ 0.75 * 2 * worldMultiplier * coinMultiplier)
end

-- Where on the track (x) a punch of this many feet lands
function Punch.Progress(feet)
 assert(type(feet)=="number" and feet==feet and feet>=0 and feet<math.huge,"Invalid feet")
 local log=math.log10(math.max(feet,10))
 if log<=7 then return math.max(0,log-1) end
 return 6+(log-7)*10
end
function Punch.TrackX(feet)
 return Punch.TrackStartX+Punch.Progress(feet)*Punch.BiomeLength
end
function Punch.BiomeAt(x)
 local index=math.max(1,math.floor((x-Punch.TrackStartX)/Punch.BiomeLength+1e-8)+1)
 return index,Catalog.Get(index).name
end
function Punch.FeetAtX(x)
 local progress=math.max(0,(x-40)/1000)
 return if progress<=6 then 10^(1+progress) else 10^(7+(progress-6)/10)
end
function Punch.Threshold(stage)
 if stage<=7 then return 10^stage end
 return 10^(7+(stage-7)/10)
end
return Punch
]===]}
src["ReplicatedStorage.Shared.Config.TrackExtensionCatalog"]={class="ModuleScript",source=[===[-- Original worlds 1-6 remain untouched. Every entry below is appended after Outer Space.
local C={}
C.Originals={"Grass Fields","Desert","Snow Mountains","Volcano","Candy Land","Outer Space"}
C.Folders={"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}
-- name, original landscape template, terrain, foliage/stone, accent, primary/secondary landforms
C.List={
 {"Jungle Falls",1,{74,156,88},{40,122,71},{93,210,230},"waterfall","canopy"},
 {"Redrock Badlands",2,{185,91,56},{138,69,49},{241,155,77},"canyon","arches"},
 {"Aurora Glaciers",3,{166,215,235},{99,164,201},{99,229,211},"glacier","aurora"},
 {"Obsidian Highlands",4,{48,45,65},{72,60,90},{241,94,58},"basalt","rifts"},
 {"Crystal Caverns",3,{112,139,184},{107,92,166},{161,124,250},"cavern","crystals"},
 {"Ringworld Frontier",6,{89,84,141},{114,97,158},{224,191,106},"planet","outpost"},
 {"Cherry Blossom Valley",1,{133,187,113},{239,139,178},{248,189,211},"canopy","terraces"},
 {"Sunken Temple Coast",2,{185,184,129},{112,148,125},{72,189,211},"ruins","coast"},
 {"Emerald Canopy",1,{77,163,106},{36,114,74},{116,218,128},"canopy","vines"},
 {"Thunderstorm Peaks",3,{122,152,186},{110,121,151},{224,221,116},"peaks","storm"},
 {"Molten Foundry",4,{83,67,67},{111,89,84},{255,158,47},"foundry","lavafall"},
 {"Sugarpine Highlands",5,{184,153,199},{166,120,183},{245,175,210},"peaks","sugar"},
 {"Golden Savanna",1,{194,174,90},{133,151,71},{242,208,119},"savanna","mesas"},
 {"Moonlit Bamboo",1,{89,130,130},{55,110,109},{169,201,185},"bamboo","moon"},
 {"Sapphire Atolls",2,{189,210,172},{97,160,133},{72,164,222},"coast","islands"},
 {"Twilight Dunes",2,{174,130,137},{137,109,144},{225,168,117},"dunes","moon"},
 {"Polar Research Frontier",3,{190,226,238},{119,171,196},{244,171,89},"glacier","outpost"},
 {"Amethyst Chasm",3,{137,120,172},{100,83,139},{191,143,238},"canyon","crystals"},
 {"Ember Ashlands",4,{89,76,83},{110,90,96},{248,125,72},"basalt","ash"},
 {"Celestial Gardens",1,{124,181,157},{88,148,126},{229,202,139},"terraces","planet"},
 {"Mushroom Marsh",1,{109,160,131},{79,119,110},{200,130,220},"mushrooms","coast"},
 {"Gingerbread Grove",5,{171,123,87},{125,83,65},{245,212,173},"gingerbread","canopy"},
 {"Lunar Crater Basin",6,{131,140,163},{100,112,147},{180,202,223},"craters","outpost"},
 {"Meteor Wastes",6,{130,109,135},{102,85,112},{244,144,94},"meteors","basalt"},
 {"Cobalt Canyon",2,{100,137,173},{75,105,139},{128,207,221},"canyon","river"},
 {"Ancient Redwood Realm",1,{114,156,95},{74,117,72},{178,134,100},"redwoods","ruins"},
 {"Sandstorm Citadel",2,{214,172,112},{164,126,85},{228,202,143},"citadel","dunes"},
 {"Frozen Waterfall Reach",3,{181,219,232},{124,180,207},{151,232,243},"waterfall","glacier"},
 {"Dragonbone Plateau",2,{192,169,133},{149,125,110},{231,217,173},"bones","mesas"},
 {"Coral Sky Coast",1,{145,189,169},{101,160,145},{239,142,169},"coral","coast"},
 {"Lavafall Rift",4,{88,62,70},{119,76,87},{255,106,43},"lavafall","rifts"},
 {"Cotton Candy Mesa",5,{212,163,204},{171,128,191},{250,185,218},"mesas","sugar"},
 {"Cosmic Reef",6,{105,109,168},{107,83,153},{100,216,212},"coral","planet"},
 {"Neon Rainforest",1,{63,130,115},{51,101,104},{123,231,187},"canopy","crystals"},
 {"Titan Icefield",3,{162,203,222},{115,154,193},{190,217,241},"glacier","peaks"},
 {"Golden Ruins",2,{195,171,113},{163,142,100},{241,210,128},"ruins","arches"},
 {"Stormforge Ridge",4,{89,86,110},{100,101,129},{188,175,242},"foundry","storm"},
 {"Haunted Pine Basin",1,{92,125,111},{63,92,95},{157,190,169},"redwoods","mist"},
 {"Rainbow Crystal Desert",2,{207,181,148},{157,137,155},{185,141,225},"crystals","arches"},
 {"Starlit Tundra",3,{150,186,213},{110,148,185},{177,220,236},"peaks","moon"},
 {"Floating Mountain Sea",1,{135,179,166},{93,143,133},{172,215,208},"islands","waterfall"},
 {"Honeycomb Meadows",5,{211,179,103},{170,141,76},{247,212,115},"honey","terraces"},
 {"Alien Fungal Wilds",6,{98,130,137},{76,106,119},{163,221,138},"mushrooms","meteors"},
 {"Prism Snowfields",3,{186,205,225},{143,163,205},{202,163,231},"crystals","glacier"},
 {"Ruby Caldera",4,{116,65,84},{145,79,108},{255,112,132},"caldera","basalt"},
 {"Orchid Cloudforest",1,{115,160,137},{87,130,115},{217,143,192},"canopy","mist"},
 {"Clockwork Cliffs",2,{173,143,115},{130,108,99},{220,181,111},"gears","mesas"},
 {"Candy Cane Tundra",5,{215,202,215},{176,155,184},{238,137,162},"glacier","sugar"},
 {"Deep Space Outpost",6,{91,101,146},{78,86,126},{135,207,221},"outpost","planet"},
 {"Bluefire Gorge",4,{65,79,110},{77,103,133},{71,190,245},"canyon","lavafall"},
 {"Jade Terrace Valley",1,{121,170,122},{78,133,104},{187,213,155},"terraces","bamboo"},
 {"Sunstone Spires",2,{212,170,107},{169,125,82},{249,211,116},"crystals","dunes"},
 {"Comet Icebelt",3,{164,204,222},{117,159,188},{190,221,235},"meteors","glacier"},
 {"Midnight Obsidian",4,{48,49,79},{65,67,102},{148,131,230},"basalt","moon"},
 {"Emerald Moon",6,{92,144,131},{75,109,123},{132,218,169},"planet","craters"},
 {"Blossom Skylands",1,{152,190,149},{216,145,168},{241,187,206},"islands","canopy"},
 {"Spectral Dune Sea",2,{175,166,191},{128,123,167},{204,190,232},"dunes","mist"},
 {"Endless Aurora",3,{170,211,227},{122,171,196},{111,229,207},"aurora","glacier"},
 {"Galactic Rift",6,{94,85,147},{111,91,162},{180,148,239},"rifts","planet"},
 {"Supernova Horizon",6,{128,103,155},{145,111,174},{246,177,111},"supernova","meteors"},
}
C.Count=6+#C.List
function C.Get(stage)
 assert(type(stage)=="number" and stage%1==0 and stage>=1 and stage<math.huge,"Invalid world")
 if stage<=6 then return {stage=stage,name=C.Originals[stage],template=stage,original=true} end
 local index=(stage-7)%#C.List+1
 local cycle=math.floor((stage-7)/#C.List)
 local s=C.List[index]
 local function color(t)
  local c=Color3.fromRGB(table.unpack(t))
  if cycle==0 then return c end
  local h,sat,val=c:ToHSV();return Color3.fromHSV((h+cycle*.047)%1,sat,val)
 end
 return {stage=stage,index=index,name=s[1]..(if cycle>0 then " / Frontier "..(cycle+1) else ""),template=s[2],
  terrain=color(s[3]),foliage=color(s[4]),accent=color(s[5]),feature=s[6],secondary=s[7],cycle=cycle,seed=stage*7919%2147483647}
end
return C

]===]}
src["ReplicatedStorage.Shared.Util.TrackLandscapeBuilder"]={class="ModuleScript",source=[===[-- Append-only landscape extension. Uses the user's actual six biomes as style templates.
local RS=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.Parent.Config.TrackExtensionCatalog)
local Punch=require(script.Parent.Parent.Config.Punch)
local B={}
local v=Vector3.new
local white=Color3.fromRGB(228,239,245)
local function part(parent,name,size,pos,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color
 p.Anchored=true;p.Material=Enum.Material.Plastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
 if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function cyl(parent,name,size,pos,color)
 local p=part(parent,name,size,pos,color,Enum.PartType.Cylinder);p.Orientation=v(0,0,90);return p
end
local function beam(parent,name,a,b,width,color)
 local p=part(parent,name,v(width,width,(b-a).Magnitude),(a+b)/2,color);p.CFrame=CFrame.lookAt((a+b)/2,b);return p
end
local function ridge(ctx,x,z,h,w)
 for i=0,3 do
  local size=v(w-i*w*.13,h/4,w*.8-i*w*.1)
  local p=part(ctx.parent,"TerraceRock",size,ctx.origin+v(x,h/8+i*h/4,z),ctx.spec.terrain:Lerp(ctx.spec.foliage,i*.09))
  p.TopSurface=Enum.SurfaceType.Studs
 end
end
local function mountain(ctx,x,z,h,w)
 for _,angle in ipairs({0,90,180,270}) do
  local p=Instance.new("WedgePart");p.Name="MountainFace";p.Size=v(w,h,w*.65);p.Anchored=true;p.CanCollide=false
  p.Color=ctx.spec.foliage;p.CFrame=CFrame.new(ctx.origin+v(x,h/2,z))*CFrame.Angles(0,math.rad(angle),0);p.Parent=ctx.parent
  local cap=p:Clone();cap.Name="MountainCap";cap.Size=v(w*.5,h*.42,w*.33);cap.Position=ctx.origin+v(x,h*.8,z);cap.Color=white;cap.Parent=ctx.parent
 end
end
local function tree(ctx,x,z,h,redwood)
 local origin=ctx.origin+v(x,0,z)
 cyl(ctx.parent,"AncientTrunk",v(h*.65,h*.13,h*.13),origin+v(0,h*.32,0),Color3.fromRGB(119,82,55))
 if redwood then
  for i=0,4 do
   local width=h*(.75-i*.1)
   local p=cyl(ctx.parent,"EvergreenTier",v(h*.18,width,width),origin+v(0,h*.54+i*h*.1,0),ctx.spec.foliage)
   p.TopSurface=Enum.SurfaceType.Studs
  end
 else
  for i=1,4 do
   local a=i*math.pi/2
   part(ctx.parent,"Canopy",v(h*.65,h*.4,h*.6),origin+v(math.cos(a)*h*.17,h*.8,math.sin(a)*h*.17),ctx.spec.foliage,Enum.PartType.Ball)
  end
 end
end
local F={}
function F.waterfall(c)
 for i=1,3 do
  local x=130+i*215;local z=-205-(i%2)*90;local h=75+i*16
  ridge(c,x,z,h,100)
  for j=-1,1 do
   local p=part(c.parent,"Waterfall",v(11,h-8,3),c.origin+v(x+j*13,h/2,z+42),c.spec.accent)
   p.Material=Enum.Material.Glass;p.Transparency=.2
  end
  cyl(c.parent,"WaterfallPool",v(1,130,90),c.origin+v(x,.5,z+70),c.spec.accent).Material=Enum.Material.Glass
 end
end
function F.canyon(c)
 for i=1,6 do ridge(c,80+i*130,-130-(i%2)*150,65+c.rng:NextInteger(0,60),65+c.rng:NextInteger(0,30)) end
 for i=1,4 do beam(c.parent,"RockBridge",c.origin+v(i*195-55,48,-155),c.origin+v(i*195+55,48,-155),15,c.spec.foliage) end
end
function F.arches(c)
 for i=1,3 do
  local x=i*240;local z=-240;local h=80+i*8
  ridge(c,x-45,z,h,34);ridge(c,x+45,z,h,34)
  beam(c.parent,"NaturalRockArch",c.origin+v(x-52,h,z),c.origin+v(x+52,h,z),22,c.spec.terrain)
  part(c.parent,"ArchCrown",v(42,15,30),c.origin+v(x,h+8,z),c.spec.foliage)
 end
end
function F.glacier(c)
 for i=1,10 do
  local h=40+c.rng:NextInteger(0,90)
  local p=part(c.parent,"GlacierBlade",v(20+c.rng:NextInteger(0,20),h,35),c.origin+v(70+i*83,h/2,-155-(i%3)*90),c.spec.accent)
  p.Orientation=v(0,i*17,(-1)^i*8);p.Transparency=.12
 end
end
function F.aurora(c)
 F.glacier(c)
 for band=1,3 do for i=0,12 do
  local p=part(c.parent,"AuroraCurtain",v(65,27,1),c.origin+v(90+i*63,155+math.sin(i*.55+band)*20,-400+band*25),c.spec.accent:Lerp(c.spec.foliage,band*.18))
  p.Material=Enum.Material.Neon;p.Transparency=.65
 end end
end
function F.basalt(c)
 for i=1,14 do
  local h=25+c.rng:NextInteger(0,75)
  local p=cyl(c.parent,"BasaltColumn",v(h,25,25),c.origin+v(80+i*58,h/2,-110-(i%4)*70),c.spec.foliage)
  p.TopSurface=Enum.SurfaceType.Studs
 end
end
function F.rifts(c)
 for i=1,10 do
  local x=60+i*85;local z=-180+math.sin(i*.75)*35
  part(c.parent,"RiftGlow",v(105,1,15),c.origin+v(x,.2,z),c.spec.accent).Material=Enum.Material.Neon
  ridge(c,x,z-38,24+i%3*12,45)
 end
end
function F.crystals(c)
 for i=1,15 do
  local h=20+c.rng:NextInteger(0,80);local x=50+i*60;local z=-130-(i%4)*70
  local p=part(c.parent,"CrystalSpire",v(12,h,17),c.origin+v(x,h/2,z),c.spec.accent)
  p.Orientation=v(i%3*9,i*31,(-1)^i*16);p.Material=Enum.Material.Glass;p.Transparency=.12
  part(c.parent,"CrystalCluster",v(8,h*.6,10),c.origin+v(x+15,h*.3,z+8),c.spec.accent).Orientation=v(0,i*18,25)
 end
end
function F.cavern(c)
 F.crystals(c)
 for i=1,4 do
  local x=i*200
  ridge(c,x-55,-280,88,50);ridge(c,x+55,-280,95,50)
  beam(c.parent,"CavernCeiling",c.origin+v(x-68,95,-280),c.origin+v(x+68,95,-280),35,c.spec.foliage)
 end
end
function F.planet(c)
 part(c.parent,"DistantPlanet",v(180,180,180),c.origin+v(630,170,-410),c.spec.accent,Enum.PartType.Ball)
 for i=1,32 do
  local a=i*math.pi/16;local b=(i+1)*math.pi/16
  beam(c.parent,"PlanetRing",c.origin+v(630+math.cos(a)*135,170,-410+math.sin(a)*135),c.origin+v(630+math.cos(b)*135,170,-410+math.sin(b)*135),6,c.spec.foliage)
 end
end
function F.outpost(c)
 for i=1,3 do
  local x=150+i*210;local z=-150-(i%2)*100
  cyl(c.parent,"HabitatBase",v(4,64,64),c.origin+v(x,2,z),white)
  local dome=part(c.parent,"ResearchDome",v(60,43,60),c.origin+v(x,15,z),c.spec.accent,Enum.PartType.Ball);dome.Transparency=.4
  part(c.parent,"Airlock",v(17,20,18),c.origin+v(x,10,z+25),white)
  for j=0,3 do part(c.parent,"SolarArray",v(13,1,23),c.origin+v(x+50+j*15,13,z),c.spec.foliage).Orientation=v(0,0,12) end
 end
end
function F.canopy(c)
 for i=1,11 do tree(c,70+i*77,-160-(i%3)*90,65+c.rng:NextInteger(0,40),false) end
end
function F.terraces(c)
 for i=1,5 do
  local x=70+i*150
  for j=0,3 do
   local p=cyl(c.parent,"TerraceIsland",v(11,90-j*14,75-j*9),c.origin+v(x,5.5+j*11,-155-i%2*95),if j==3 then c.spec.foliage else c.spec.terrain)
   p.TopSurface=Enum.SurfaceType.Studs
  end
 end
end
function F.ruins(c)
 for i=1,4 do
  local x=i*205;local z=-220
  for _,dx in ipairs({-35,35}) do
   part(c.parent,"AncientPillar",v(14,55+i*5,14),c.origin+v(x+dx,28+i*2.5,z),c.spec.terrain)
   part(c.parent,"PillarCapital",v(23,7,23),c.origin+v(x+dx,58+i*5,z),c.spec.foliage)
  end
  part(c.parent,"RuinedLintel",v(100,12,24),c.origin+v(x,65+i*5,z),c.spec.terrain)
  for j=1,3 do part(c.parent,"Rubble",v(17,9,15),c.origin+v(x-35+j*20,4,-175),c.spec.terrain).Orientation=v(0,j*38,9) end
 end
end
function F.coast(c)
 for i=1,6 do
  cyl(c.parent,"CoastalPool",v(.6,120,90),c.origin+v(60+i*135,.35,-160-(i%2)*120),c.spec.accent).Material=Enum.Material.Glass
  ridge(c,60+i*135,-245-(i%2)*80,18,70)
 end
end
function F.vines(c)
 for i=1,6 do
  local x=80+i*130
  tree(c,x,-220,75,false)
  for j=1,4 do beam(c.parent,"HangingVine",c.origin+v(x+j*9-18,65,-200),c.origin+v(x+j*9-18,12+j*5,-200),1.8,c.spec.accent) end
 end
end
function F.peaks(c)
 for i=1,7 do mountain(c,45+i*125,-190-(i%2)*160,90+c.rng:NextInteger(0,90),100) end
end
function F.storm(c)
 F.peaks(c)
 for i=1,4 do
  local x=100+i*190
  for j=0,4 do part(c.parent,"StormCloud",v(55,26,35),c.origin+v(x+j*25,175+math.sin(j)*8,-280),c.spec.foliage,Enum.PartType.Ball) end
  beam(c.parent,"Lightning",c.origin+v(x+40,160,-275),c.origin+v(x+20,120,-275),3,c.spec.accent).Material=Enum.Material.Neon
  beam(c.parent,"Lightning",c.origin+v(x+20,120,-275),c.origin+v(x+55,85,-275),3,c.spec.accent).Material=Enum.Material.Neon
 end
end
function F.lavafall(c)
 F.waterfall(c)
 for _,p in ipairs(c.parent:GetChildren()) do if p:IsA("BasePart") and (p.Name=="Waterfall" or p.Name=="WaterfallPool") then p.Material=Enum.Material.Neon;p.Transparency=0 end end
end
function F.foundry(c)
 for i=1,4 do
  local x=100+i*180;ridge(c,x,-220,40,80)
  for _,dx in ipairs({-25,25}) do
   cyl(c.parent,"FoundryChimney",v(90,18,18),c.origin+v(x+dx,75,-220),c.spec.foliage)
   cyl(c.parent,"SmokestackRim",v(6,24,24),c.origin+v(x+dx,122,-220),c.spec.accent)
  end
  part(c.parent,"FoundryGlow",v(45,28,2),c.origin+v(x,25,-177),c.spec.accent).Material=Enum.Material.Neon
 end
end
function F.sugar(c)
 for i=1,9 do
  local x=65+i*93
  part(c.parent,"SugarCrystal",v(20,42,20),c.origin+v(x,24,-150-(i%3)*75),c.spec.accent).Orientation=v(0,i*29,16)
  tree(c,x,-310,55,false)
 end
end
function F.savanna(c)
 for i=1,10 do tree(c,65+i*85,-150-i%3*85,45+i%3*9,false) end
 F.mesas(c)
end
function F.mesas(c)
 for i=1,5 do ridge(c,50+i*165,-210-(i%2)*100,55+i%3*24,100) end
end
function F.bamboo(c)
 for cluster=1,3 do for i=1,12 do
  local x=cluster*260-50+math.sin(i*2)*45;local z=-170-cluster%2*90+math.cos(i*2)*30
  local h=55+i%4*12
  for j=0,4 do cyl(c.parent,"BambooSegment",v(h/5-1,4.5,4.5),c.origin+v(x,h/10+j*h/5,z),c.spec.foliage) end
 end end
end
function F.moon(c)
 part(c.parent,"Moon",v(105,105,105),c.origin+v(650,175,-420),c.spec.accent,Enum.PartType.Ball)
 for i=1,4 do ridge(c,i*210,-250,35+i*5,75) end
end
function F.islands(c)
 for i=1,6 do
  local h=25+i%3*24;local x=35+i*145;local z=-190-(i%2)*130
  cyl(c.parent,"FloatingRock",v(26,100,80),c.origin+v(x,h,z),c.spec.terrain)
  local p=cyl(c.parent,"FloatingGrass",v(3,102,82),c.origin+v(x,h+15,z),c.spec.foliage);p.TopSurface=Enum.SurfaceType.Studs
  part(c.parent,"HangingRock",v(29,35,26),c.origin+v(x,h-22,z),c.spec.terrain).Orientation=v(0,45,20)
 end
end
function F.dunes(c)
 for i=1,10 do
  local x=40+i*88;local h=15+i%3*8
  part(c.parent,"GreatDune",v(140,h*2,85),c.origin+v(x,0,-150-(i%3)*90),c.spec.terrain,Enum.PartType.Ball)
 end
end
function F.ash(c)
 F.basalt(c)
 for i=1,9 do part(c.parent,"AshCloud",v(65,20,35),c.origin+v(50+i*95,115+i%2*15,-300),c.spec.foliage,Enum.PartType.Ball) end
end
function F.mushrooms(c)
 for i=1,16 do
  local h=25+i%4*10;local p=c.origin+v(35+i*56,0,-140-(i%4)*65)
  cyl(c.parent,"MushroomStem",v(h,7,7),p+v(0,h/2,0),c.spec.terrain)
  part(c.parent,"MushroomCap",v(38,h*.4,33),p+v(0,h,0),c.spec.foliage,Enum.PartType.Ball)
  for j=1,3 do part(c.parent,"CapSpot",v(5,2,5),p+v(math.cos(j*2)*10,h+h*.16,math.sin(j*2)*8),c.spec.accent,Enum.PartType.Ball) end
 end
end
function F.gingerbread(c)
 for i=1,4 do
  local x=i*210;part(c.parent,"GingerbreadCottage",v(65,42,45),c.origin+v(x,21,-210),c.spec.terrain)
  for j=0,3 do part(c.parent,"IcingRoof",v(78-j*15,5,60-j*8),c.origin+v(x,45+j*5,-210),white) end
  part(c.parent,"CandyDoor",v(14,23,1),c.origin+v(x,12,-187),c.spec.accent)
 end
end
function F.craters(c)
 for i=1,7 do
  local pos=c.origin+v(60+i*120,0,-130-(i%3)*95)
  cyl(c.parent,"CraterRim",v(7,85,72),pos+v(0,3,0),c.spec.foliage)
  cyl(c.parent,"CraterFloor",v(1,65,53),pos+v(0,7,0),c.spec.terrain)
 end
end
function F.meteors(c)
 for i=1,10 do
  local s=18+i%4*7;local pos=c.origin+v(40+i*90,55+i%3*35,-180-i%2*100)
  part(c.parent,"Meteor",v(s,s,s),pos,c.spec.foliage,Enum.PartType.Ball)
  for j=1,3 do part(c.parent,"MeteorTail",v(s*.6-j,s*.6-j,s*.6-j),pos-v(j*22,-j*4,0),c.spec.accent,Enum.PartType.Ball) end
 end
end
function F.river(c)
 for i=0,9 do part(c.parent,"River",v(104,.6,35),c.origin+v(50+i*100,.4,-140-math.sin(i*.5)*25),c.spec.accent).Material=Enum.Material.Glass end
end
function F.redwoods(c)
 for i=1,10 do tree(c,50+i*90,-150-(i%3)*90,80+i%4*15,true) end
end
function F.citadel(c)
 F.ruins(c)
 for i=1,4 do
  local x=i*205;part(c.parent,"CitadelTower",v(38,86,38),c.origin+v(x,43,-330),c.spec.terrain)
  for j=-1,1 do part(c.parent,"Battlement",v(9,11,15),c.origin+v(x+j*12,90,-310),c.spec.foliage) end
 end
end
function F.bones(c)
 for i=1,8 do
  local x=65+i*105;local h=35+math.sin(i*.4)*18
  beam(c.parent,"FossilRib",c.origin+v(x,1,-190),c.origin+v(x,h,-240),7,white)
  part(c.parent,"BoneKnuckle",v(13,13,13),c.origin+v(x,h,-240),white,Enum.PartType.Ball)
 end
 beam(c.parent,"FossilSpine",c.origin+v(120,45,-245),c.origin+v(890,45,-245),8,white)
end
function F.coral(c)
 for i=1,15 do
  local pos=c.origin+v(30+i*61,0,-145-i%3*85);local h=20+i%4*10
  beam(c.parent,"CoralTrunk",pos,pos+v(0,h,0),6,c.spec.foliage)
  for j=-1,1 do beam(c.parent,"CoralBranch",pos+v(0,h*.6,0),pos+v(j*17,h*1.1,0),5,c.spec.accent) end
 end
end
function F.mist(c)
 for i=1,9 do
  local p=part(c.parent,"LowMist",v(100,12,40),c.origin+v(50+i*100,18,-200-i%3*75),c.spec.accent,Enum.PartType.Ball);p.Transparency=.8
 end
end
function F.honey(c)
 for i=1,15 do
  local h=20+i%4*10;local p=cyl(c.parent,"HoneyMesa",v(h,45,45),c.origin+v(35+i*60,h/2,-160-i%3*65),c.spec.terrain);p.TopSurface=Enum.SurfaceType.Studs
  cyl(c.parent,"HoneyCap",v(2,47,47),p.Position+v(0,h/2,0),c.spec.accent)
 end
end
function F.caldera(c)
 for j=0,6 do
  cyl(c.parent,"CalderaLayer",v(15,260-j*25,220-j*20),c.origin+v(520,7.5+j*15,-300),c.spec.foliage)
 end
 cyl(c.parent,"CalderaLake",v(2,90,80),c.origin+v(520,106,-300),c.spec.accent).Material=Enum.Material.Neon
end
function F.gears(c)
 F.mesas(c)
 for i=1,3 do
  local pos=c.origin+v(i*245,75,-220);local r=33+i*5
  for j=1,12 do
   local a=j*math.pi/6;local p=part(c.parent,"AncientGear",v(15,22,10),pos+v(math.cos(a)*r,math.sin(a)*r,0),c.spec.accent)
   p.Orientation=v(0,0,math.deg(a))
  end
  local axle=part(c.parent,"GearAxle",v(15,15,22),pos,c.spec.foliage,Enum.PartType.Cylinder);axle.Orientation=v(0,90,0)
 end
end
function F.supernova(c)
 F.planet(c)
 for i=1,28 do
  local a=i*math.pi/14;local center=c.origin+v(630,170,-410)
  beam(c.parent,"SupernovaRay",center+v(math.cos(a)*115,math.sin(a)*115,0),center+v(math.cos(a)*160,math.sin(a)*160,0),4,c.spec.accent).Material=Enum.Material.Neon
 end
end
function B.Build(parent,stage,options)
 options=options or {};local spec=Catalog.Get(stage);assert(not spec.original,"Never rebuild originals")
 local templates=RS:WaitForChild("TrackExtensionTemplates")
 local template=assert(templates:FindFirstChild(Catalog.Folders[spec.template]),"Missing landscape template")
 local start=40+(stage-1)*1000;local oldStart=40+(spec.template-1)*1000;local delta=v(start-oldStart,0,0)
 local model=Instance.new("Model");model.Name=string.format("World_%03d_%s",stage,spec.name:gsub("[^%w]",""))
 model:SetAttribute("Stage",stage);model:SetAttribute("OriginalStyle",Catalog.Folders[spec.template]);model:SetAttribute("Name",spec.name)
 local base=template:Clone();base.Name="LandscapeBase";base.Parent=model
 model:PivotTo(model:GetPivot()+delta)
 local serial=0
 for _,p in ipairs(base:GetDescendants()) do
  if p:IsA("LuaSourceContainer") then p:Destroy()
  elseif p:IsA("BasePart") then
   serial+=1
   if p.Name=="BackdropEnd" or p.Name=="Filler" then p:Destroy()
   elseif options.lod and (p.Name=="Star" or p.Name=="Rim" or p.Name=="Sprinkle") and serial%3~=0 then p:Destroy()
   else
    if p.Name=="Track" or p.Name=="SideFar" or p.Name=="SideNear" then p.Color=p.Color:Lerp(spec.terrain,.5)
    elseif p.Name:find("Leaves") or p.Name=="Puff" or p.Name=="Dune" or p.Name=="Rock" or p.Name=="Snow" then p.Color=p.Color:Lerp(spec.foliage,.45)
    elseif p.Name=="Lava" or p.Name=="Glow" or p.Name=="Crater" or p.Name=="Crystal" or p.Name=="SpikeGlow" then p.Color=spec.accent end
   end
  elseif p:IsA("TextLabel") and p:IsDescendantOf(base.Arch) then p.Text=string.upper(spec.name) end
 end
 if not base.Ground:FindFirstChild("SideFar") then
  local p=part(base.Ground,"SideFar",v(1000,2,440),v(start+500,-1,-280),spec.terrain);p.CanCollide=true;p.CanQuery=true
 end
 if not base.Ground:FindFirstChild("SideNear") then
  local p=part(base.Ground,"SideNear",v(1000,2,190),v(start+500,-1,155),spec.terrain);p.CanCollide=true;p.CanQuery=true
 end
 local landmarks=Instance.new("Folder");landmarks.Name="NaturalLandmarks";landmarks.Parent=model
 local context={parent=landmarks,origin=v(start,0,0),spec=spec,rng=Random.new(spec.seed)}
 assert(F[spec.feature],spec.feature)(context);assert(F[spec.secondary],spec.secondary)(context)
 if spec.cycle>0 then
  for i=1,3+spec.cycle%4 do ridge(context,100+i*130,-390,45+spec.cycle%7*9,60) end
 end
 -- Match the existing distance-board construction rather than introducing a new HUD style.
 local board=templates:FindFirstChild("DistanceBoard")
 if board then for i=0,3 do
  local m=Instance.new("Model");m.Name="DistanceBoard";local b=board:Clone();b.Parent=m
  local x=start+i*250;local pivot=m:GetPivot();m:PivotTo(pivot+v(x-40,0,0))
  local feet=Punch.FeetAtX(x)
  for _,l in ipairs(m:GetDescendants()) do if l:IsA("TextLabel") then l.Text=B.Number(feet).." FT" end end
  m.Parent=model
 end end
 model.WorldPivot=CFrame.new(start,0,0);model.Parent=parent
 return model
end
function B.Number(n)
 if n>=1e12 then local e=math.floor(math.log10(n));return string.format("%.2fe%d",n/10^e,e) end
 if n>=1e9 then return string.format("%.1fB",n/1e9) end
 if n>=1e6 then return string.format("%.1fM",n/1e6) end
 if n>=1e3 then return string.format("%.1fK",n/1e3) end
 return tostring(math.floor(n))
end
function B.Preview(parent,first,last)
 local f=Instance.new("Folder");f.Name="ExtensionsPreview";f.Parent=parent
 for stage=first or 7,last or Catalog.Count do
  B.Build(f,stage);task.wait()
 end
 return f
end
return B

]===]}
assert(not resolve("ServerScriptService.TrackExtensionRuntime"),"Namespace occupied: ServerScriptService.TrackExtensionRuntime")
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
]===],"Original source changed: StarterPlayer.StarterPlayerScripts.Controllers.PunchFxController")
assert(not resolve("StarterPlayer.StarterPlayerScripts.Controllers.TrackExtensionController"),"Namespace occupied: StarterPlayer.StarterPlayerScripts.Controllers.TrackExtensionController")
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
]===],"Original source changed: ReplicatedStorage.Shared.Config.Punch")
assert(not resolve("ReplicatedStorage.Shared.Config.TrackExtensionCatalog"),"Namespace occupied: ReplicatedStorage.Shared.Config.TrackExtensionCatalog")
assert(not resolve("ReplicatedStorage.Shared.Util.TrackLandscapeBuilder"),"Namespace occupied: ReplicatedStorage.Shared.Util.TrackLandscapeBuilder")
assert(not game.ReplicatedStorage:FindFirstChild("TrackExtensionTemplates"),"Templates already exist")
local originals={"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}
for _,n in ipairs(originals) do assert(workspace.Map.Track:FindFirstChild(n),"Original missing: "..n) end
for k,v in pairs(src) do local fn,err=loadstring(v.source);assert(fn,k..": "..tostring(err)) end
local backup=game.ServerStorage:FindFirstChild("TrackAppend_Backup")
if backup then
 assert(backup:FindFirstChild("Track") and backup.Track:FindFirstChild("Finish") and backup:FindFirstChild("Scripts") and #backup.Scripts:GetChildren()==2,"Incomplete original backup")
else
backup=Instance.new("Folder");backup.Name="TrackAppend_Backup";backup.Parent=game.ServerStorage;backup:SetAttribute("Camera",workspace.CurrentCamera.CFrame)
local track=workspace.Map.Track:Clone();track.Name="Track";track.Parent=backup
local bag=Instance.new("Folder");bag.Name="Scripts";bag.Parent=backup
for path,v in pairs(src) do local old=resolve(path);if old then local copy=old:Clone();copy:SetAttribute("OriginalPath",path);copy.Parent=bag end end
end
local templates=Instance.new("Folder");templates.Name="TrackExtensionTemplates";templates.Parent=game.ReplicatedStorage
for _,n in ipairs(originals) do backup.Track[n]:Clone().Parent=templates;task.wait() end
local board=backup.Track.DistanceBoards.Board_40:Clone();board.Name="DistanceBoard";board.Parent=templates
for path,v in pairs(src) do
 local old=resolve(path);if old then old:Destroy() end
 local parent,name=path:match("^(.*)%.([^%.]+)$")
 local script=Instance.new(v.class);script.Name=name;script.Source=v.source;script.Parent=assert(resolve(parent))
end
local live=workspace.Map.Track
-- Keep every original biome intact. Only the obsolete finish barrier is removed.
live.Finish:Destroy()
local endWall=live.OuterSpace.Scenery.SpaceBackdrop.BackdropEnd
backup:SetAttribute("BackdropTransparency",endWall.Transparency)
endWall.Transparency=1
-- Retain the old space backdrop around a flight-sized continuation opening.
local opening=Instance.new("Folder");opening.Name="HorizonOpening";opening.Parent=live
for _,s in ipairs({{479,-255.5,460,225},{185,172.5,460,225},{96,32,365,272.5}}) do
 local p=endWall:Clone();p.Name="BackdropContinuation";p.Transparency=0;p.Size=Vector3.new(6,s[3],s[1]);p.Position=Vector3.new(6125,s[4],s[2]);p.Parent=opening
end
live:SetAttribute("TrackAppendVersion","original-six-plus-sixty")
local builder=require(game.ReplicatedStorage.Shared.Util.TrackLandscapeBuilder)
builder.Preview(live,7,66)
return "APPEND_INSTALL_PASS originals=6 added=60 total=66 original_landscapes=retained"

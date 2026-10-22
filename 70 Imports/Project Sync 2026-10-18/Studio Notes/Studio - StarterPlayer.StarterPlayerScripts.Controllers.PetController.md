---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - StarterPlayer.StarterPlayerScripts.Controllers.PetController

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `StarterPlayer.StarterPlayerScripts.Controllers.PetController`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [PetController.luau](../Files/Studio%20Snapshot/Project%20Source/StarterPlayer/StarterPlayerScripts/Controllers/PetController.luau)

```luau
-- Cosmetic client followers, size-aware rows, giant companions behind the small ones.
local Http=game:GetService("HttpService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local Visual=require(RS.Shared.Util.PetVisual)
local EggVisual=require(RS.Shared.Util.EggVisual)
local Controller={}
local folder=Instance.new("Folder");folder.Name="PetFollowers"
local followers,signatures,connections={},{},{}
local function clear(owner)
	for _,e in followers[owner] or {} do e.model:Destroy() end
	followers[owner]={}
end
local function rebuild(owner)
	local ok,inv=pcall(Http.JSONDecode,Http,owner:GetAttribute("PetInv") or "[]")
	local ids={}
	if ok and type(inv)=="table" then for _,e in inv do if e.e then table.insert(ids,e.p) end end end
	table.sort(ids)
	local signature=table.concat(ids,",")
	if signatures[owner]==signature then return end
	signatures[owner]=signature;clear(owner)
	for _,id in ids do
		local model=Visual.Make(id)
		local _,size=model:GetBoundingBox()
		local entry={model=model,size=size,fx={},ready=false}
		for _,x in model:GetDescendants() do if x:IsA("ParticleEmitter") then table.insert(entry.fx,x) end end
		model:SetAttribute("OwnerUserId",owner.UserId)
		-- Start at the owner, never flash pets at world origin.
		local root=owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
		if root then model:PivotTo(root.CFrame*CFrame.new(0,0,8+size.Z))
		else model:PivotTo(CFrame.new(0,-1000,0)) end
		model.Parent=folder;table.insert(followers[owner],entry)
	end
	table.sort(followers[owner],function(a,b) return a.size.X<b.size.X end)
	-- A row holds three normal pets OR two giant pets. Width/depth follow actual geometry.
	local rows={};local row={};local giant=nil
	for _,e in followers[owner] do
		local big=e.model:GetAttribute("Massive")==true
		if #row>0 and (big~=giant or #row>=(if big then 2 else 3)) then table.insert(rows,row);row={} end
		giant=big;table.insert(row,e)
	end
	if #row>0 then table.insert(rows,row) end
	local back=5
	for _,r in rows do
		local width,depth=0,0
		for _,e in r do width+=e.size.X+1.3;depth=math.max(depth,e.size.Z) end
		local x=-width/2
		for _,e in r do
			e.offset=Vector3.new(x+e.size.X/2+.65,0,back+depth/2)
			x+=e.size.X+1.3
		end
		back+=depth+2
	end
end
local function track(owner)
	followers[owner]={};rebuild(owner)
	connections[owner]=owner:GetAttributeChangedSignal("PetInv"):Connect(function()rebuild(owner)end)
end
function Controller.Start()
	folder.Parent=workspace
	for _,owner in Players:GetPlayers() do track(owner) end
	Players.PlayerAdded:Connect(track)
	Players.PlayerRemoving:Connect(function(owner)
		clear(owner);followers[owner]=nil;signatures[owner]=nil
		if connections[owner] then connections[owner]:Disconnect();connections[owner]=nil end
	end)
	local eggs={}
	local function addEgg(m) if m:IsA("Model") then eggs[m]=true end end
	for _,m in Tags:GetTagged("RemodeledEgg") do addEgg(m) end
	Tags:GetInstanceAddedSignal("RemodeledEgg"):Connect(addEgg)
	Tags:GetInstanceRemovedSignal("RemodeledEgg"):Connect(function(m) eggs[m]=nil end)
	local accumulator=0
	Run.RenderStepped:Connect(function(dt)
		accumulator+=dt;if accumulator<1/30 then return end
		local step=math.min(accumulator,.1);accumulator=0
		local t=os.clock();local camera=workspace.CurrentCamera
		local eye=if camera then camera.CFrame.Position else Vector3.zero
		for owner,entries in followers do
			local root=owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
			for i,e in entries do
				local visible=root and (root.Position-eye).Magnitude<180
				for _,fx in e.fx do fx.Enabled=visible==true end
				if root then
					local big=e.model:GetAttribute("Massive")
					local ground=root.Position.Y-root.Size.Y/2-(owner.Character:FindFirstChildOfClass("Humanoid") and owner.Character.Humanoid.HipHeight or 2)
					local xz=root.CFrame:PointToWorldSpace(e.offset)
					local y=ground+e.size.Y/2+.65+math.sin(t*(if big then 1.5 else 2.8)+i)*.22
					local goal=CFrame.new(xz.X,y,xz.Z)*root.CFrame.Rotation*CFrame.Angles(0,0,math.sin(t*2+i)*.025)
					if visible then
						e.model:PivotTo(if e.ready then e.model:GetPivot():Lerp(goal,1-math.exp(-8*step)) else goal)
						e.ready=true;Visual.Animate(e.model,t+i)
					else e.model:PivotTo(goal);e.ready=false end
				elseif e.ready then
					e.model:PivotTo(CFrame.new(0,-1000,0));e.ready=false
				end
			end
		end
		for m in eggs do if m.Parent then
			local visible=(m:GetPivot().Position-eye).Magnitude<150
			EggVisual.Animate(m,t,visible)
		else eggs[m]=nil end end
	end)
end
return Controller

```


---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Util.PetVisual

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Util.PetVisual`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [PetVisual.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Util/PetVisual.luau)

```luau
-- Shared world/preview factory. Size is cosmetic; never changes pet power.
local RS=game:GetService("ReplicatedStorage")
local Builder=require(RS.Shared.Util.PetModelBuilder)
local P={}
local motion=setmetatable({}, {__mode="k"})
function P.Make(id, options)
	options=options or {}
	local folder=RS:FindFirstChild("PetModels")
	local source=folder and folder:FindFirstChild(tostring(id))
	local m=if source and source:GetAttribute("PetRemodelVersion")==1 then source:Clone() else Builder.Build(id)
	local _,s=m:GetBoundingBox()
	local target=if options.Preview then 3 else (m:GetAttribute("WorldSize") or 3.6)
	m:ScaleTo(m:GetScale()*target/math.max(s.X,s.Y,s.Z))
	-- Center the bounding box on the model pivot for predictable UI framing and formations.
	local box,size=m:GetBoundingBox()
	m.PrimaryPart.PivotOffset=m.PrimaryPart.CFrame:ToObjectSpace(box)
	m:PivotTo(CFrame.new())
	m:SetAttribute("VisualExtent",target)
	m:SetAttribute("VisualHeight",size.Y)
	m:SetAttribute("Preview",options.Preview==true)
	for _,p in m:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Massless=true
		elseif p:IsA("ParticleEmitter") then
			p.Enabled=not options.Preview
			-- Large pets should not produce screen-filling particles.
			if target>=10 then p.Size=NumberSequence.new(.45,0);p.Speed=NumberRange.new(.8,2.2) end
		end
	end
	return m
end
function P.Animate(m,t)
	local entries=motion[m]
	if not entries then
		entries={}
		for _,x in m:GetChildren() do if x:IsA("Model") and x:GetAttribute("Motion") then
			table.insert(entries,{x,x:GetAttribute("Motion"),m:GetPivot():ToObjectSpace(x:GetPivot()),x:GetAttribute("Sign") or 1})
		end end
		motion[m]=entries
	end
	for _,e in entries do
		local delta=if e[2]=="Wing" then CFrame.Angles(0,0,math.sin(t*4)*.17*e[4]) else CFrame.Angles(0,t*.55,0)
		e[1]:PivotTo(m:GetPivot()*e[3]*delta)
	end
end
return P

```


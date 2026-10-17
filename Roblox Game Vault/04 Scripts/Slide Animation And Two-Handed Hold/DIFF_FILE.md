# Slide Animation And Two-Handed Hold

Changed branch: rig guard accepts Motor6D and AnimationConstraint; one post-animation pose writer. Movement ground() probes with original standing height during the slide transition. HipDrop .35 -> 1.05; CameraDrop 1.45 -> .65. Weapon grips are profile targets solved through both arm chains. Camera and damage sources retained.

```diff
--- BASELINE/ReplicatedStorage.GameplayPresentation.MovementConfig
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.MovementConfig
@@ -2,7 +2,7 @@
     WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=.60, CrouchCameraDrop=.95, SlideSpeed=36, SlideEndSpeed=18,
     SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
     StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
-    ExhaustionRecovery=15, HipDrop=.35, CameraDrop=1.45,
+    ExhaustionRecovery=15, HipDrop=1.05, CameraDrop=.65,
     SprintFov=8, SlideFov=10, CameraShakeScale=1,
     MinimapHeight=155, MinimapFov=70,
 }
--- BASELINE/ReplicatedStorage.GameplayPresentation.MovementClient
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.MovementClient
@@ -60,41 +60,7 @@
         WalkSpeed=hum and hum.WalkSpeed,Grounded=hum and hum.FloorMaterial~=Enum.Material.Air,
         Crouched=p:GetAttribute('MovementCrouched')==true,
         CameraOffsetY=hum and hum.CameraOffset.Y,SlideBuffered=queuedSlideUntil>os.clock(),
-        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y}
-end
-local poses={}
-local function clearPose(rec)
-    for joint,offset in rec.Applied do
-        if joint.Parent then joint.Transform=joint.Transform*offset:Inverse()end
-    end
-    rec.Applied={}
-end
-local function updatePoses(dt)
-    for _,plr in Players:GetPlayers() do
-        local c=plr.Character
-        local rec=poses[plr]
-        if rec and rec.Char~=c then clearPose(rec);poses[plr]=nil;rec=nil end
-        if c then
-            if not rec then
-                rec={Char=c,Alpha=0,Applied={},Joints={}}
-                for name,degrees in {Waist=8,LeftHip=-25,RightHip=-25,LeftKnee=55,RightKnee=55,LeftAnkle=-30,RightAnkle=-30}do
-                    local joint=c:FindFirstChild(name,true)
-                    if joint and joint:IsA('Motor6D')then table.insert(rec.Joints,{Joint=joint,Angle=math.rad(degrees)})end
-                end
-                poses[plr]=rec
-            end
-            local h=c:FindFirstChildOfClass('Humanoid')
-            local target=h and h.Health>0 and plr:GetAttribute('MovementCrouched') and 1 or 0
-            rec.Alpha+=(target-rec.Alpha)*(1-math.exp(-math.min(dt,.05)*14))
-            if rec.Alpha>.001 then for _,j in rec.Joints do
-                if j.Joint.Parent then
-                    local offset=CFrame.Angles(j.Angle*rec.Alpha,0,0)
-                    j.Joint.Transform*=offset
-                    rec.Applied[j.Joint]=offset
-                end
-            end end
-        end
-    end
+        CameraY=workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Y,HeadY=char and char:FindFirstChild('Head') and char.Head.Position.Y,Pose=require(script.Parent.CharacterPose).State(p)}
 end
 local function hook(c)
     char=c;hum=c:WaitForChild('Humanoid');root=c:WaitForChild('HumanoidRootPart')
@@ -106,9 +72,7 @@
     if started then return M end;started=true
     if p.Character then task.spawn(hook,p.Character)end
     p.CharacterAdded:Connect(hook)
-    RunService.PreAnimation:Connect(function()for _,rec in poses do clearPose(rec)end end)
-    RunService.PreSimulation:Connect(updatePoses)
-    Players.PlayerRemoving:Connect(function(plr)local rec=poses[plr];if rec then clearPose(rec);poses[plr]=nil end end)
+    require(script.Parent.CharacterPose).Start()
     p.CharacterRemoving:Connect(function(c)
         if char==c then
             if hum and hum.Parent then hum.CameraOffset=baseCameraOffset end
--- BASELINE/StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson
+++ MODIFIED/StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson
@@ -59,35 +59,5 @@
 	end
 end)
 
--- aim pose for every armed character (runs after animations, before physics)
-local function joint(character, partName, jointName)
-	local part = character:FindFirstChild(partName)
-	return part and part:FindFirstChild(jointName)
-end
-
-RunService.Stepped:Connect(function()
-	for _, plr in Players:GetPlayers() do
-		local character = plr.Character
-		if character and armed(character) and not plr:GetAttribute("InLobby") then
-			local pitch = plr == player and cameraPitch() or (plr:GetAttribute("AimPitch") or 0)
-			pitch = math.clamp(pitch, math.rad(-70), math.rad(70))
-			local waist = joint(character, "UpperTorso", "Waist")
-			local neck = joint(character, "Head", "Neck")
-			local rs = joint(character, "RightUpperArm", "RightShoulder")
-			local ls = joint(character, "LeftUpperArm", "LeftShoulder")
-			local re = joint(character, "RightLowerArm", "RightElbow")
-			local le = joint(character, "LeftLowerArm", "LeftElbow")
-			local rw = joint(character, "RightHand", "RightWrist")
-			local lw = joint(character, "LeftHand", "LeftWrist")
-			if waist then waist.Transform = CFrame.Angles(pitch * 0.35, 0, 0) end
-			if neck then neck.Transform = CFrame.Angles(pitch * 0.4, 0, 0) end
-			local armPitch = math.pi / 2 + pitch * 0.65
-			if rs then rs.Transform = CFrame.Angles(0, 0.12, 0) * CFrame.Angles(armPitch, 0, 0) end
-			if re then re.Transform = CFrame.identity end
-			if rw then rw.Transform = CFrame.identity end
-			if ls then ls.Transform = CFrame.Angles(0, -0.75, 0) * CFrame.Angles(armPitch + 0.1, 0, 0) end
-			if le then le.Transform = CFrame.Angles(0.25, 0, 0) end
-			if lw then lw.Transform = CFrame.identity end
-		end
-	end
-end)
+-- Aim and movement now share GameplayPresentation.CharacterPose (bounded pose-only integration).
+-- Camera, mouse lock and AimPitch network protocol above remain unchanged.
--- BASELINE/ReplicatedStorage.GameplayPresentation.CharacterPose
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.CharacterPose
@@ -0,0 +1,219 @@
+-- Client-evaluated R15 pose. Server attributes remain the movement/aim authority.
+-- Supports Avatar Joint Upgrade without changing rig attachments or asset IDs.
+local Players=game:GetService("Players")
+local RunService=game:GetService("RunService")
+local C=require(script.Parent.MovementConfig)
+local P={}
+local started=false
+local records={}
+local localPlayer=Players.LocalPlayer
+local rad=math.rad
+local identity=CFrame.identity
+local profiles={
+    W1={Grip=Vector3.new(.12,.50,-.55),Support=Vector3.new(-.12,.08,-.62)},
+    W2={Grip=Vector3.new(.12,.45,-.55),Support=Vector3.new(-.12,.10,-.55)},
+    W3={Grip=Vector3.new(.15,.30,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
+    W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
+    W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
+}
+local crouch={Waist=8,LeftHip=-40,RightHip=-40,LeftKnee=80,RightKnee=80,LeftAnkle=-40,RightAnkle=-40}
+local slide={
+    Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
+    Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
+    RightHip=CFrame.Angles(rad(95),0,rad(-4)),RightKnee=CFrame.Angles(rad(-8),0,0),
+    RightAnkle=CFrame.Angles(rad(-77),0,0),
+    LeftHip=CFrame.Angles(rad(110),0,rad(8)),LeftKnee=CFrame.Angles(rad(-145),0,0),
+    LeftAnkle=CFrame.Angles(rad(45),0,0),
+    RightShoulder=CFrame.Angles(rad(30),0,rad(12)),RightElbow=CFrame.Angles(rad(-35),0,0),
+    LeftShoulder=CFrame.Angles(rad(22),0,rad(-25)),LeftElbow=CFrame.Angles(rad(-55),0,0),
+}
+local function joint(c,name)
+    local j=c:FindFirstChild(name,true)
+    if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then return j end
+end
+local function reset(rec)
+    for j,saved in rec.Applied do
+        -- Do not undo an Animator/another system's newer evaluation.
+        if j.Parent and j.Transform==saved.Value then j.Transform=saved.Base end
+    end
+    rec.Applied={}
+end
+local function set(rec,j,value)
+    if not j or not j.Parent then return end
+    local old=rec.Applied[j]
+    rec.Applied[j]={Base=old and old.Base or j.Transform,Value=value}
+    j.Transform=value
+end
+local function world(rec,part,cache)
+    if cache[part] then return cache[part] end
+    local j=rec.ByPart[part]
+    local cf
+    if j and j.Part0 then cf=world(rec,j.Part0,cache)*j.C0*j.Transform*j.C1:Inverse()
+    else cf=part.CFrame end
+    cache[part]=cf
+    return cf
+end
+local function segment(localA,localB,worldA,worldB,normal)
+    return CFrame.lookAt(worldA,worldB,normal)*CFrame.lookAt(localA,localB,Vector3.zAxis):Inverse()
+end
+local function arm(rec,side,torsoCF,handCF)
+    local sh=rec.Joints[side.."Shoulder"]
+    local el=rec.Joints[side.."Elbow"]
+    local wr=rec.Joints[side.."Wrist"]
+    if not sh or not el or not wr then return nil end
+    local a=(torsoCF*sh.C0).Position
+    local target=(handCF*wr.C1).Position
+    local l1=(el.C0.Position-sh.C1.Position).Magnitude
+    local l2=(wr.C0.Position-el.C1.Position).Magnitude
+    local delta=target-a
+    if l1<.01 or l2<.01 or delta.Magnitude<.01 then return nil end
+    local dir=delta.Unit
+    local length=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
+    local wrist=a+dir*length
+    local bend=torsoCF:VectorToWorldSpace(Vector3.new(side=="Right" and .7 or -.7,-1,.25))
+    bend-=dir*bend:Dot(dir)
+    if bend.Magnitude<.01 then bend=torsoCF.UpVector:Cross(dir) end
+    bend=bend.Unit
+    local x=(l1*l1-l2*l2+length*length)/(2*length)
+    local elbow=a+dir*x+bend*math.sqrt(math.max(0,l1*l1-x*x))
+    local normal=dir:Cross(bend).Unit
+    local upper=segment(sh.C1.Position,el.C0.Position,a,elbow,normal)
+    local lower=segment(el.C1.Position,wr.C0.Position,elbow,wrist,normal)
+    -- If an unusual body scale exceeds reach, keep the chain connected.
+    handCF=CFrame.new(wrist-target)*handCF
+    set(rec,sh,sh.C0:Inverse()*torsoCF:ToObjectSpace(upper)*sh.C1)
+    set(rec,el,el.C0:Inverse()*upper:ToObjectSpace(lower)*el.C1)
+    set(rec,wr,wr.C0:Inverse()*lower:ToObjectSpace(handCF)*wr.C1)
+    return handCF,(wrist-target).Magnitude
+end
+local function getRecord(plr,c)
+    local rec=records[plr]
+    if rec and rec.Char~=c then reset(rec);records[plr]=nil;rec=nil end
+    if not rec then
+        rec={Char=c,Joints={},ByPart={},Applied={},Slide=0,Crouch=0}
+        for _,j in c:GetDescendants() do
+            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
+                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
+            end
+        end
+        records[plr]=rec
+    end
+    if os.clock()>(rec.ScanAt or 0) then
+        rec.ScanAt=os.clock()+1
+        for _,j in c:GetDescendants() do
+            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
+                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
+            end
+        end
+    end
+    return rec
+end
+local function floorClearance(rec)
+    local rootJoint=rec.Joints.Root
+    local hrp=rec.Char:FindFirstChild("HumanoidRootPart")
+    if not rootJoint or not hrp then return end
+    local params=RaycastParams.new()
+    params.FilterDescendantsInstances={rec.Char}
+    params.RespectCanCollide=true
+    params.CollisionGroup=hrp.CollisionGroup
+    local cache={}
+    local lift=0
+    for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LowerTorso"} do
+        local part=rec.Char:FindFirstChild(name)
+        if part then
+            local cf=world(rec,part,cache)
+            local hit=workspace:Raycast(Vector3.new(cf.X,hrp.Position.Y+1,cf.Z),Vector3.new(0,-7,0),params)
+            if hit and hit.Normal.Y>.6 then
+                local low=math.huge
+                for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
+                    low=math.min(low,(cf*Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)).Y)
+                end end end
+                lift=math.max(lift,hit.Position.Y+.14-low)
+            end
+        end
+    end
+    lift=math.clamp(lift,0,1.8)
+    if lift>0 then
+        local parentFrame=world(rec,rootJoint.Part0,{})*rootJoint.C0
+        set(rec,rootJoint,CFrame.new(parentFrame:VectorToObjectSpace(Vector3.new(0,lift,0)))*rootJoint.Transform)
+    end
+    rec.ClearanceLift=lift
+end
+local function evaluate(dt)
+    dt=math.min(dt,.05)
+    for _,plr in Players:GetPlayers() do
+        local c=plr.Character
+        if c then
+            local rec=getRecord(plr,c)
+            local h=c:FindFirstChildOfClass("Humanoid")
+            local live=h and h.Health>0
+            local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
+            local crouched=live and plr:GetAttribute("MovementCrouched")==true
+            rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
+            rec.Crouch+=( (crouched and 1 or 0)-rec.Crouch)*(1-math.exp(-dt*16))
+            if live then
+                for name,angle in crouch do
+                    local j=rec.Joints[name]
+                    if j and rec.Crouch>.001 then set(rec,j,j.Transform*CFrame.Angles(rad(angle)*rec.Crouch,0,0)) end
+                end
+                if rec.Slide>.001 then
+                    for name,pose in slide do
+                        local j=rec.Joints[name]
+                        if j then set(rec,j,j.Transform:Lerp(pose,rec.Slide)) end
+                    end
+                end
+                if sliding then rec.ClearanceUntil=os.clock()+.4 end
+                if os.clock()<(rec.ClearanceUntil or 0) or rec.Crouch>.001 then floorClearance(rec) end
+                local tool=c:FindFirstChildOfClass("Tool")
+                local id=tool and tool:GetAttribute("ReferenceWeaponId")
+                local profile=profiles[id]
+                local torso=c:FindFirstChild("UpperTorso")
+                local hand=c:FindFirstChild("RightHand")
+                local handle=tool and tool:FindFirstChild("Handle")
+                local model=tool and tool:FindFirstChild("WorldModel")
+                local root=model and model:FindFirstChild("Root")
+                local weld=hand and hand:FindFirstChild("RightGrip")
+                if profile and torso and hand and root and handle and weld and not plr:GetAttribute("InLobby") then
+                    local camera=workspace.CurrentCamera
+                    local pitch=plr==localPlayer and camera and math.asin(math.clamp(camera.CFrame.LookVector.Y,-1,1)) or plr:GetAttribute("AimPitch") or 0
+                    pitch=math.clamp(pitch,rad(-70),rad(70))
+                    local waist=rec.Joints.Waist
+                    local neck=rec.Joints.Neck
+                    if waist then set(rec,waist,waist.Transform*CFrame.Angles(pitch*.35,0,0)) end
+                    if neck then set(rec,neck,neck.Transform*CFrame.Angles(pitch*.4,0,0)) end
+                    local torsoCF=world(rec,torso,{})
+                    local bodyRoot=c:FindFirstChild("HumanoidRootPart")
+                    local forward=bodyRoot and bodyRoot.CFrame.LookVector*Vector3.new(1,0,1) or torsoCF.LookVector*Vector3.new(1,0,1)
+                    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) end
+                    local aim=forward.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
+                    local gunCF=CFrame.new(torsoCF:PointToWorldSpace(profile.Grip))*CFrame.lookAt(Vector3.zero,aim)
+                    local handToRoot=weld.C0*weld.C1:Inverse()*handle.CFrame:ToObjectSpace(root.CFrame)
+                    local rightCF=gunCF*handToRoot:Inverse()
+                    local actualRight,rightError=arm(rec,"Right",torsoCF,rightCF)
+                    if actualRight then
+                        gunCF=actualRight*handToRoot
+                        local leftCF=gunCF*CFrame.new(profile.Support)*handToRoot.Rotation:Inverse()
+                        local _,leftError=arm(rec,"Left",torsoCF,leftCF)
+                        rec.Weapon=id;rec.RightError=rightError;rec.LeftError=leftError
+                        rec.Support=profile.Support
+                    end
+                else rec.Weapon=nil;rec.LeftError=nil;rec.RightError=nil end
+            end
+        end
+    end
+end
+function P.State(plr)
+    local rec=records[plr or localPlayer]
+    if not rec then return {} end
+    local count=0;for _ in rec.Joints do count+=1 end
+    return {JointCount=count,Slide=rec.Slide,Crouch=rec.Crouch,Weapon=rec.Weapon,LeftError=rec.LeftError,RightError=rec.RightError,Support=rec.Support,ClearanceLift=rec.ClearanceLift}
+end
+function P.Start()
+    if started then return P end;started=true
+    RunService.PreAnimation:Connect(function()for _,rec in records do reset(rec)end end)
+    -- One pose writer, after Animator, for aim + slide. No frame-order tug of war.
+    RunService.PreSimulation:Connect(evaluate)
+    Players.PlayerRemoving:Connect(function(plr)if records[plr]then reset(records[plr]);records[plr]=nil end end)
+    return P
+end
+return P--- BASELINE/ServerScriptService.GameplayMovement.Service
+++ MODIFIED/ServerScriptService.GameplayMovement.Service
@@ -19,7 +19,9 @@
     local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
     params.FilterDescendantsInstances={s.Char};params.RespectCanCollide=true
     local legHeight=h.RigType==Enum.HumanoidRigType.R6 and 2 or 0
-    local standing=math.max(0,h.HipHeight)+r.Size.Y/2+legHeight
+    -- A lower target HipHeight must not shorten the ground probe before physics settles.
+    local probeHip=s.Mode=="Sliding" and math.max(h.HipHeight,s.BaseHip or 0) or h.HipHeight
+    local standing=math.max(0,probeHip)+r.Size.Y/2+legHeight
     if r.AssemblyLinearVelocity.Y>6 then return nil end
     local hit=workspace:Raycast(r.Position,Vector3.new(0,-(standing+.8),0),params)
     return hit and hit.Normal.Y>.45 and hit or nil

```

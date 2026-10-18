-- Client-evaluated R15 pose. Server attributes remain the movement/aim authority.
-- Supports Avatar Joint Upgrade without changing rig attachments or asset IDs.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local C=require(script.Parent.MovementConfig)
local P={}
local started=false
local records={}
local localPlayer=Players.LocalPlayer
local rad=math.rad
local identity=CFrame.identity
local profiles={
    W1={Grip=Vector3.new(.12,.50,-.55),Support=Vector3.new(-.12,.08,-.62)},
    W2={Grip=Vector3.new(.12,.45,-.55),Support=Vector3.new(-.12,.10,-.55)},
    W3={Grip=Vector3.new(.15,.30,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
    W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
}
local crouch={Waist=8,LeftHip=-70,RightHip=-70,LeftKnee=140,RightKnee=140,LeftAnkle=-70,RightAnkle=-70}
local slide={
    Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
    Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
    RightHip=CFrame.Angles(rad(95),0,rad(-4)),RightKnee=CFrame.Angles(rad(-8),0,0),
    RightAnkle=CFrame.Angles(rad(-77),0,0),
    LeftHip=CFrame.Angles(rad(110),0,rad(8)),LeftKnee=CFrame.Angles(rad(-145),0,0),
    LeftAnkle=CFrame.Angles(rad(45),0,0),
    RightShoulder=CFrame.Angles(rad(30),0,rad(12)),RightElbow=CFrame.Angles(rad(-35),0,0),
    LeftShoulder=CFrame.Angles(rad(22),0,rad(-25)),LeftElbow=CFrame.Angles(rad(-55),0,0),
}
local function joint(c,name)
    local j=c:FindFirstChild(name,true)
    if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then return j end
end
local function reset(rec)
    for j,saved in rec.Applied do
        -- Do not undo an Animator/another system's newer evaluation.
        if j.Parent and j.Transform==saved.Value then j.Transform=saved.Base end
    end
    rec.Applied={}
end
local function set(rec,j,value)
    if not j or not j.Parent then return end
    local old=rec.Applied[j]
    rec.Applied[j]={Base=old and old.Base or j.Transform,Value=value}
    j.Transform=value
end
local function world(rec,part,cache)
    if cache[part] then return cache[part] end
    local j=rec.ByPart[part]
    local cf
    if j and j.Part0 then cf=world(rec,j.Part0,cache)*j.C0*j.Transform*j.C1:Inverse()
    else cf=part.CFrame end
    cache[part]=cf
    return cf
end
local function segment(localA,localB,worldA,worldB,normal)
    return CFrame.lookAt(worldA,worldB,normal)*CFrame.lookAt(localA,localB,Vector3.zAxis):Inverse()
end
local function arm(rec,side,torsoCF,handCF)
    local sh=rec.Joints[side.."Shoulder"]
    local el=rec.Joints[side.."Elbow"]
    local wr=rec.Joints[side.."Wrist"]
    if not sh or not el or not wr then return nil end
    local a=(torsoCF*sh.C0).Position
    local target=(handCF*wr.C1).Position
    local l1=(el.C0.Position-sh.C1.Position).Magnitude
    local l2=(wr.C0.Position-el.C1.Position).Magnitude
    local delta=target-a
    if l1<.01 or l2<.01 or delta.Magnitude<.01 then return nil end
    local dir=delta.Unit
    local length=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
    local wrist=a+dir*length
    local bend=torsoCF:VectorToWorldSpace(Vector3.new(side=="Right" and .7 or -.7,-1,.25))
    bend-=dir*bend:Dot(dir)
    if bend.Magnitude<.01 then bend=torsoCF.UpVector:Cross(dir) end
    bend=bend.Unit
    local x=(l1*l1-l2*l2+length*length)/(2*length)
    local elbow=a+dir*x+bend*math.sqrt(math.max(0,l1*l1-x*x))
    local normal=dir:Cross(bend).Unit
    local upper=segment(sh.C1.Position,el.C0.Position,a,elbow,normal)
    local lower=segment(el.C1.Position,wr.C0.Position,elbow,wrist,normal)
    -- If an unusual body scale exceeds reach, keep the chain connected.
    handCF=CFrame.new(wrist-target)*handCF
    set(rec,sh,sh.C0:Inverse()*torsoCF:ToObjectSpace(upper)*sh.C1)
    set(rec,el,el.C0:Inverse()*upper:ToObjectSpace(lower)*el.C1)
    set(rec,wr,wr.C0:Inverse()*lower:ToObjectSpace(handCF)*wr.C1)
    return handCF,(wrist-target).Magnitude
end
local function getRecord(plr,c)
    local rec=records[plr]
    if rec and rec.Char~=c then reset(rec);records[plr]=nil;rec=nil end
    if not rec then
        rec={Char=c,Joints={},ByPart={},Applied={},Slide=0,Crouch=0}
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
        records[plr]=rec
    end
    if os.clock()>(rec.ScanAt or 0) then
        rec.ScanAt=os.clock()+1
        for _,j in c:GetDescendants() do
            if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part1 then
                rec.Joints[j.Name]=j;rec.ByPart[j.Part1]=j
            end
        end
    end
    return rec
end
local function floorClearance(rec)
    local rootJoint=rec.Joints.Root
    local hrp=rec.Char:FindFirstChild("HumanoidRootPart")
    if not rootJoint or not hrp then return end
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={rec.Char}
    params.RespectCanCollide=true
    params.CollisionGroup=hrp.CollisionGroup
    local cache={}
    local lift=0
    for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LowerTorso"} do
        local part=rec.Char:FindFirstChild(name)
        if part then
            local cf=world(rec,part,cache)
            local hit=workspace:Raycast(Vector3.new(cf.X,hrp.Position.Y+1,cf.Z),Vector3.new(0,-7,0),params)
            if hit and hit.Normal.Y>.6 then
                local low=math.huge
                for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
                    low=math.min(low,(cf*Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)).Y)
                end end end
                lift=math.max(lift,hit.Position.Y+.14-low)
            end
        end
    end
    lift=math.clamp(lift,0,1.8)
    if lift>0 then
        local parentFrame=world(rec,rootJoint.Part0,{})*rootJoint.C0
        set(rec,rootJoint,CFrame.new(parentFrame:VectorToObjectSpace(Vector3.new(0,lift,0)))*rootJoint.Transform)
    end
    rec.ClearanceLift=lift
end
local function evaluate(dt)
    dt=math.min(dt,.05)
    for _,plr in Players:GetPlayers() do
        local c=plr.Character
        if c then
            local rec=getRecord(plr,c)
            local h=c:FindFirstChildOfClass("Humanoid")
            local live=h and h.Health>0 and not plr:GetAttribute("CutsceneActive")
            local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
            local crouched=live and plr:GetAttribute("MovementCrouched")==true
            rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
            rec.Crouch+=( (crouched and 1 or 0)-rec.Crouch)*(1-math.exp(-dt*16))
            if live then
                for name,angle in crouch do
                    local j=rec.Joints[name]
                    if j and rec.Crouch>.001 then set(rec,j,j.Transform:Lerp(CFrame.Angles(rad(angle),0,0),rec.Crouch)) end
                end
                if rec.Crouch>.001 and rec.Joints.Root then set(rec,rec.Joints.Root,rec.Joints.Root.Transform*CFrame.new(0,-1.05*rec.Crouch,0))end
                if rec.Slide>.001 then
                    for name,pose in slide do
                        local j=rec.Joints[name]
                        if j then set(rec,j,j.Transform:Lerp(pose,rec.Slide)) end
                    end
                end
                if sliding then rec.ClearanceUntil=os.clock()+.4 end
                if os.clock()<(rec.ClearanceUntil or 0) or rec.Crouch>.001 then floorClearance(rec) end
                local tool=c:FindFirstChildOfClass("Tool")
                local id=tool and tool:GetAttribute("ReferenceWeaponId")
                local profile=profiles[id]
                local torso=c:FindFirstChild("UpperTorso")
                local hand=c:FindFirstChild("RightHand")
                local handle=tool and tool:FindFirstChild("Handle")
                local model=tool and tool:FindFirstChild("WorldModel")
                local root=model and model:FindFirstChild("Root")
                local weld=hand and hand:FindFirstChild("RightGrip")
                if profile and torso and hand and root and handle and weld and not plr:GetAttribute("InLobby") then
                    local camera=workspace.CurrentCamera
                    local pitch=plr==localPlayer and camera and math.asin(math.clamp(camera.CFrame.LookVector.Y,-1,1)) or plr:GetAttribute("AimPitch") or 0
                    pitch=math.clamp(pitch,rad(-70),rad(70))
                    local waist=rec.Joints.Waist
                    local neck=rec.Joints.Neck
                    if waist then set(rec,waist,waist.Transform*CFrame.Angles(pitch*.35,0,0)) end
                    if neck then set(rec,neck,neck.Transform*CFrame.Angles(pitch*.4,0,0)) end
                    local torsoCF=world(rec,torso,{})
                    local bodyRoot=c:FindFirstChild("HumanoidRootPart")
                    local forward=bodyRoot and bodyRoot.CFrame.LookVector*Vector3.new(1,0,1) or torsoCF.LookVector*Vector3.new(1,0,1)
                    if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) end
                    local aim=forward.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
                    local gunCF=CFrame.new(torsoCF:PointToWorldSpace(profile.Grip))*CFrame.lookAt(Vector3.zero,aim)
                    local handToRoot=weld.C0*weld.C1:Inverse()*handle.CFrame:ToObjectSpace(root.CFrame)
                    local rightCF=gunCF*handToRoot:Inverse()
                    local actualRight,rightError=arm(rec,"Right",torsoCF,rightCF)
                    if actualRight then
                        gunCF=actualRight*handToRoot
                        local leftCF=gunCF*CFrame.new(profile.Support)*handToRoot.Rotation:Inverse()
                        local _,leftError=arm(rec,"Left",torsoCF,leftCF)
                        rec.Weapon=id;rec.RightError=rightError;rec.LeftError=leftError
                        rec.Support=profile.Support
                    end
                else rec.Weapon=nil;rec.LeftError=nil;rec.RightError=nil end
            end
        end
    end
end
function P.State(plr)
    local rec=records[plr or localPlayer]
    if not rec then return {} end
    local count=0;for _ in rec.Joints do count+=1 end
    return {JointCount=count,Slide=rec.Slide,Crouch=rec.Crouch,Weapon=rec.Weapon,LeftError=rec.LeftError,RightError=rec.RightError,Support=rec.Support,ClearanceLift=rec.ClearanceLift}
end
function P.Start()
    if started then return P end;started=true
    RunService.PreAnimation:Connect(function()for _,rec in records do reset(rec)end end)
    -- One pose writer, after Animator, for aim + slide. No frame-order tug of war.
    RunService.PreSimulation:Connect(evaluate)
    Players.PlayerRemoving:Connect(function(plr)if records[plr]then reset(records[plr]);records[plr]=nil end end)
    return P
end
return P
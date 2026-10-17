local p=game.Players.LocalPlayer
local c=p.Character
local output=Instance.new("Folder");output.Name="SlidePoseQA";output.Parent=p.PlayerScripts
local function bottom(part)
 local y=math.huge;for x=-1,1,2 do for dy=-1,1,2 do for z=-1,1,2 do
 y=math.min(y,(part.CFrame*Vector3.new(x*part.Size.X/2,dy*part.Size.Y/2,z*part.Size.Z/2)).Y)
 end end end;return y
end
local conn
conn=p:GetAttributeChangedSignal("MovementState"):Connect(function()
 if p:GetAttribute("MovementState")~="Sliding" then return end
 conn:Disconnect()
 task.spawn(function()
 local rows={};local start=os.clock();local initial=c.HumanoidRootPart.Position;local snapped=false
 while os.clock()-start<1.3 and c.Parent do
 local r=c.HumanoidRootPart;local params=RaycastParams.new();params.FilterDescendantsInstances={c};params.RespectCanCollide=true
 local hit=workspace:Raycast(r.Position,Vector3.new(0,-20,0),params)
 local row={Time=os.clock()-start,Mode=p:GetAttribute("MovementState"),Hip=c.Humanoid.HipHeight,Distance=(r.Position-initial).Magnitude,RootY=r.Position.Y,FloorY=hit and hit.Position.Y,Parts={}}
 for _,name in {"Head","UpperTorso","LowerTorso","RightFoot","LeftFoot","LeftLowerLeg","RightLowerLeg"} do local b=c:FindFirstChild(name);if b then row.Parts[name]=bottom(b) end end
 table.insert(rows,row)
 if not snapped and row.Time>.23 then
  snapped=true
  local old=c.Archivable;c.Archivable=true;local copy=c:Clone();c.Archivable=old;copy.Name="SlidePoseSnapshot"
  for _,v in copy:GetDescendants() do if v:IsA("BasePart")then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false
  elseif v:IsA("LuaSourceContainer")or v:IsA("JointInstance")or v:IsA("Constraint")or v:IsA("Humanoid")or v:IsA("Animator") then v:Destroy()end end
  copy.Parent=workspace
 end
 task.wait(.04)
 end
 local value=Instance.new("StringValue");value.Name="Samples";value.Value=game.HttpService:JSONEncode(rows);value.Parent=output
 end)
end)
return "ARMED: record real slide floor clearance, displacement, pose and recovery"

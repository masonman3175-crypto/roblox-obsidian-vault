local p=game.Players.LocalPlayer
local c=p.Character;local h=c.Humanoid;local root=c.HumanoidRootPart
local move=p.PlayerScripts.MovementControl
local cam=workspace.CurrentCamera
local pitch=0
game.RunService:BindToRenderStep("PoseQACamera",Enum.RenderPriority.Last.Value+20,function()
 local f=root.CFrame.LookVector*Vector3.new(1,0,1);f=f.Unit*math.cos(pitch)+Vector3.yAxis*math.sin(pitch)
 local pos=root.Position+Vector3.new(0,2,0)-root.CFrame.LookVector*8
 cam.CFrame=CFrame.lookAt(pos,pos+f)
end)
local results={}
local list={}
for _,v in c:GetChildren()do if v:IsA("Tool")then table.insert(list,v)end end
for _,v in p.Backpack:GetChildren()do if v:IsA("Tool")then table.insert(list,v)end end
table.sort(list,function(a,b)return a:GetAttribute("ReferenceWeaponId")<b:GetAttribute("ReferenceWeaponId")end)
for _,tool in list do
 h:EquipTool(tool);task.wait(.2)
 local r=tool.WorldModel.Root
 for _,degrees in {-35,0,35} do
  pitch=math.rad(degrees);task.wait(.25)
  local state=move:Invoke("State")
  local support=state.Pose.Support
  local error=(r.CFrame:PointToObjectSpace(c.LeftHand.Position)-support).Magnitude
  local barrelPitch=math.deg(math.asin(math.clamp(r.CFrame.LookVector.Y,-1,1)))
  table.insert(results,{Weapon=tool:GetAttribute("ReferenceWeaponId"),Pitch=degrees,SupportError=error,BarrelPitch=barrelPitch,Pose=state.Pose})
  assert(error<.25,"Support-hand reach error "..tool.Name.." "..error)
  assert(math.abs(barrelPitch-degrees)<2,"Barrel pitch error")
 end
end
game.RunService:UnbindFromRenderStep("PoseQACamera")
return game.HttpService:JSONEncode(results)

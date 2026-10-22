-- Local-only, rebased journey scenery. Never awards coins or changes player progression.
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


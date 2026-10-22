-- Streams only appended worlds; never rebuilds, hides or removes the six originals.
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


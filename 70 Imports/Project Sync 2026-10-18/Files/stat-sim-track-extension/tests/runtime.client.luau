-- Temporary test LocalScript: installed only for Play QA and removed afterward.
local RS=game:GetService("ReplicatedStorage")
local p=game.Players.LocalPlayer
local Http=game:GetService("HttpService")
local logs={};local manual=0;local automatic=0
game:GetService("LogService").MessageOut:Connect(function(message,kind)
 if kind==Enum.MessageType.MessageError and (message:find("TrackExtension") or message:find("PunchFx")) then table.insert(logs,message) end
end)
RS.Remotes.PunchFx.OnClientEvent:Connect(function(_,_,_,_,isAuto) if isAuto then automatic+=1 else manual+=1 end end)
while not p:GetAttribute("Loaded") do task.wait() end
p:SetAttribute("TrackQA_BeforeCoins",p:GetAttribute("Coins"))
p:SetAttribute("TrackQA_Ready",true)
while not p:GetAttribute("TrackQA_Start") do task.wait() end
local ok,result=pcall(function()
 local controller=require(script.Parent.Controllers.TrackExtensionController)
 local punch=require(RS.Shared.Config.Punch)
 local maxWorlds=0;local maxParts=0
 for _,stage in ipairs({7,8,12,66,67,126,1000}) do
  local x=40+(stage-1)*1000+500
  controller.Prepare(x);controller.Focus(x)
  repeat task.wait() until not controller.Audit().working
  local a=controller.Audit();maxWorlds=math.max(maxWorlds,a.extraWorlds);maxParts=math.max(maxParts,a.extraParts)
  assert(a.extraWorlds<=8 and table.find(a.stages,stage) and table.find(a.stages,stage+1),"Destination/budget failed "..stage)
  local world
  for _,m in ipairs(workspace.Map.Track.LocalTrackExtensions:GetChildren()) do if m:GetAttribute("Stage")==stage then world=m end end
  assert(world and world.LandscapeBase.Ground:FindFirstChild("Track"))
  assert(punch.BiomeAt(x)==stage)
 end
 controller.Release();repeat task.wait() until not controller.Audit().working
 local camera=workspace.CurrentCamera
 assert(camera.CameraType==Enum.CameraType.Custom and camera.CameraSubject==p.Character:FindFirstChildOfClass("Humanoid"),"Camera did not restore")
 local dummy=workspace.Map.Gameplay.PunchLane.Dummy
 assert(dummy.PrimaryPart.Transparency==0 and dummy.PrimaryPart.PunchPrompt.Enabled,"Dummy/prompt not restored")
 assert(not workspace.Map.Track:FindFirstChild("ExtensionsPreview"),"Editor previews leaked into runtime")
 for _,name in ipairs({"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}) do assert(workspace.Map.Track:FindFirstChild(name)) end
 assert(manual>0 and p:GetAttribute("BestPunch")>0 and p:GetAttribute("Coins")>p:GetAttribute("TrackQA_BeforeCoins"),"Manual punch/rewards not observed")
 assert(#logs==0,table.concat(logs,";"))
 return "RUNTIME_PASS original_worlds=6 streamed_stages=7,8,12,66,67,126,1000 max_extra_worlds="..maxWorlds.." max_extra_parts="..maxParts.." manual_punch=true coins_increased=true camera_dummy_prompt=restored extension_errors=0"
end)
p:SetAttribute("TrackQA_Result",ok and result or "RUNTIME_FAIL "..tostring(result))
p:SetAttribute("TrackQA_Details",Http:JSONEncode({manual=manual,automatic=automatic,coins=p:GetAttribute("Coins"),best=p:GetAttribute("BestPunch"),errors=logs}))

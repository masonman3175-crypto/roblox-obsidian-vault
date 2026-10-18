local p=game.Players.LocalPlayer;local folder=Instance.new("Folder");folder.Name="RunQAEvidence";folder.Parent=p.PlayerScripts
local conn;conn=p:GetAttributeChangedSignal("CutsceneActive"):Connect(function()
 if not p:GetAttribute("CutsceneActive")then return end;conn:Disconnect()
 task.spawn(function()
 local rows={};local start=p:GetAttribute("IntroStartedAt")
 for i=1,26 do
  local sounds={};local house=workspace:FindFirstChild("SurvivalRun")and workspace.SurvivalRun.Houses:FindFirstChild("House_"..p.UserId)
  if house then for _,v in house:GetDescendants()do if v:IsA("Sound")then table.insert(sounds,{Id=v.SoundId,Loaded=v.IsLoaded,Length=v.TimeLength})end end end
  table.insert(rows,{At=workspace:GetServerTimeNow()-start,Stage=p:GetAttribute("IntroStage"),CameraType=workspace.CurrentCamera.CameraType.Name,CameraPosition=tostring(workspace.CurrentCamera.CFrame.Position),Subtitle=p.PlayerGui.SurvivalPresentation.Cinema.Subtitle.Text,InMenu=p:GetAttribute("InMenu"),Root=tostring(p.Character:GetPivot()),Sounds=sounds})
  task.wait(.5)
 end
 local value=Instance.new("StringValue");value.Name="IntroSamples";value.Value=game.HttpService:JSONEncode(rows);value.Parent=folder
 end)
end)
p.Character:PivotTo(CFrame.new(979,4,9));task.wait(18)
return game.HttpService:JSONEncode({Phase=p:GetAttribute("LobbyPhase"),Stage=p:GetAttribute("IntroStage"),Elapsed=workspace:GetServerTimeNow()-(p:GetAttribute("IntroStartedAt")or 0)})

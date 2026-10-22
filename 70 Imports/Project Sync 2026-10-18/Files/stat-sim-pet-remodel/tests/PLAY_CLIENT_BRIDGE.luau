-- Temporary camera/UI/remote harness. Removed before leaving Play.
local Run=game:GetService("RunService")
local player=game.Players.LocalPlayer
local controllers=player.PlayerScripts:WaitForChild("Controllers")
local pets=require(controllers.PetsController)
local bridge=Instance.new("BindableFunction");bridge.Name="PetRemodel_QA_Client"
local locked=false
local function unlock()
	Run:UnbindFromRenderStep("PetRemodel_QA_Camera")
	workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;locked=false
end
bridge.OnInvoke=function(command,a,b)
	if command=="pets" then pets.Open();return "PETS_PANEL_OPEN"
	elseif command=="close" then
		player.PlayerGui.PetsGui.PetsPanel.Visible=false;return "PETS_PANEL_CLOSED"
	elseif command=="camera" then
		unlock();locked=true
		Run:BindToRenderStep("PetRemodel_QA_Camera",Enum.RenderPriority.Camera.Value+20,function()
			workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
			workspace.CurrentCamera.FieldOfView=55;workspace.CurrentCamera.CFrame=CFrame.lookAt(a,b)
		end)
		return "QA_CAMERA_LOCKED"
	elseif command=="unlock" then unlock();return "QA_CAMERA_RESTORED"
	elseif command=="unequip" then game.ReplicatedStorage.Remotes.EquipPet:FireServer(a,false);return "UNEQUIP_SENT"
	elseif command=="best" then game.ReplicatedStorage.Remotes.EquipBest:FireServer();return "EQUIP_BEST_SENT"
	end
end
bridge.Parent=player.PlayerScripts
script.Destroying:Connect(function()unlock();bridge:Destroy()end)

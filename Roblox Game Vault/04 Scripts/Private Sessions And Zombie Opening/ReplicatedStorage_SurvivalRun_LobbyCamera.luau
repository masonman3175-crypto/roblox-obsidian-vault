local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local p=Players.LocalPlayer
local M={}
local yaw,pitch,radius=0,.28,12
local dragging=false
local touch
local stick=Vector2.zero
local started=false
local function lobby()return p:GetAttribute("InLobby")==true and not p:GetAttribute("CutsceneActive")end
function M.Delta(delta)
    if not lobby()then return false end
    yaw-=delta.X*.006;pitch=math.clamp(pitch+delta.Y*.004,-.08,1.05);return true
end
function M.State()return {Yaw=yaw,Pitch=pitch,Radius=radius,Dragging=dragging,Active=lobby()}end
function M.Start()
    if started then return end;started=true
    UIS.InputBegan:Connect(function(input,processed)
        if processed or UIS:GetFocusedTextBox()or not lobby()then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=true
        elseif input.UserInputType==Enum.UserInputType.Touch and input.Position.X>workspace.CurrentCamera.ViewportSize.X*.45 then touch=input end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false end
        if input==touch then touch=nil end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(input.Position.X,-input.Position.Y)end
        if not lobby()then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then M.Delta(input.Delta)
        elseif input==touch then M.Delta(input.Delta)
        elseif input.UserInputType==Enum.UserInputType.MouseWheel then radius=math.clamp(radius-input.Position.Z*1.1,6,18)end
    end)
    UIS.WindowFocusReleased:Connect(function()dragging=false;touch=nil;stick=Vector2.zero end)
    RunService:BindToRenderStep("SurvivorLobbyOrbit",Enum.RenderPriority.Last.Value+12,function(dt)
        if not lobby()then dragging=false;touch=nil;return end
        if stick.Magnitude>.15 then M.Delta(stick*dt*220)end
        local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local head=c and c:FindFirstChild("Head");local cam=workspace.CurrentCamera
        if not h or h.Health<=0 or not head or not cam then return end
        local focus=head.Position+Vector3.new(0,-.3+h.CameraOffset.Y,0)
        local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),math.cos(yaw)*math.cos(pitch))*radius
        local params=RaycastParams.new();params.FilterDescendantsInstances={c};params.RespectCanCollide=true
        local hit=workspace:Spherecast(focus,.3,offset,params)
        local wanted=hit and focus+offset.Unit*math.max(1,(hit.Position-focus).Magnitude-.4)or focus+offset
        cam.CameraType=Enum.CameraType.Scriptable;cam.CFrame=CFrame.lookAt(wanted,focus);cam.Focus=CFrame.new(focus)
        UIS.MouseBehavior=dragging and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
        UIS.MouseIconEnabled=not dragging
    end)
    local bridge=Instance.new("BindableFunction");bridge.Name="LobbyCameraControl";bridge.OnInvoke=function(action,value)if action=="Delta"then M.Delta(value)end;return M.State()end;bridge.Parent=p.PlayerScripts
end
return M


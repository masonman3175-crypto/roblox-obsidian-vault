local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local viewmodels=ReplicatedStorage:WaitForChild("Viewmodels")
local activeTool=nil
local viewmodel=nil
local animTime=0
local recoil=0
local reloadProgress=0
local ammo=0
local lastShot=0

local gui=Instance.new("ScreenGui")
gui.Name="FPSPrototypeCrosshair"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.Parent=player:WaitForChild("PlayerGui")
local function line(name,size,pos)
    local f=Instance.new("Frame")
    f.Name=name; f.Size=UDim2.fromOffset(size.X,size.Y); f.Position=pos; f.AnchorPoint=Vector2.new(0.5,0.5)
    f.BackgroundColor3=Color3.fromRGB(235,235,220); f.BorderSizePixel=0; f.Parent=gui
end
line("Top",Vector2.new(2,9),UDim2.fromScale(0.5,0.5)-UDim2.fromOffset(0,14))
line("Bottom",Vector2.new(2,9),UDim2.fromScale(0.5,0.5)+UDim2.fromOffset(0,14))
line("Left",Vector2.new(9,2),UDim2.fromScale(0.5,0.5)-UDim2.fromOffset(14,0))
line("Right",Vector2.new(9,2),UDim2.fromScale(0.5,0.5)+UDim2.fromOffset(14,0))
local dot=Instance.new("Frame")
dot.Name="CenterDot"; dot.Size=UDim2.fromOffset(3,3); dot.Position=UDim2.fromScale(0.5,0.5); dot.AnchorPoint=Vector2.new(0.5,0.5)
dot.BackgroundColor3=Color3.fromRGB(255,190,80); dot.BorderSizePixel=0; dot.Parent=gui

local function clearViewmodel()
    if viewmodel then viewmodel:Destroy(); viewmodel=nil end
end
local function setArmVisibility(show)
    if not viewmodel then return end
    for _,p in ipairs(viewmodel:GetChildren()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier=show and 0 or 1 end
    end
end
local function muzzleFlash()
    if not viewmodel then return end
    local muzzle=viewmodel:FindFirstChild("Muzzle",true)
    if not muzzle then return end
    local flash=Instance.new("Part")
    flash.Name="MuzzleFlash"; flash.Shape=Enum.PartType.Ball; flash.Size=Vector3.new(0.35,0.35,0.35)
    flash.Color=Color3.fromRGB(255,190,70); flash.Material=Enum.Material.Neon; flash.Anchored=true; flash.CanCollide=false
    flash.CFrame=muzzle.CFrame; flash.Parent=viewmodel
    task.delay(0.045,function() if flash then flash:Destroy() end end)
end
local function fire()
    if not activeTool or reloadProgress>0 then return end
    local rpm=activeTool:GetAttribute("RPM") or 450
    local interval=60/rpm
    if os.clock()-lastShot<interval then return end
    if ammo<=0 then return end
    lastShot=os.clock(); ammo-=1; recoil=math.min(recoil+0.11,0.3); muzzleFlash()
end
local function reload()
    if not activeTool or reloadProgress>0 then return end
    reloadProgress=1
    task.spawn(function()
        local duration=activeTool:GetAttribute("ReloadTime") or 1.5
        local start=os.clock()
        while reloadProgress>0 and os.clock()-start<duration do
            reloadProgress=math.clamp((os.clock()-start)/duration,0,1)
            task.wait()
        end
        ammo=activeTool:GetAttribute("MagazineSize") or 30
        reloadProgress=0
    end)
end
local function equip(tool)
    clearViewmodel()
    activeTool=tool
    local name=tool:GetAttribute("ViewmodelName")
    local source=viewmodels:FindFirstChild(name)
    if not source then return end
    viewmodel=source:Clone()
    viewmodel.Name="ActiveViewmodel"
    viewmodel.Parent=camera
    ammo=tool:GetAttribute("MagazineSize") or 30
    setArmVisibility(true)
end
local function unequip(tool)
    if activeTool==tool then activeTool=nil; reloadProgress=0; clearViewmodel() end
end
local function hookTool(tool)
    if not tool:IsA("Tool") or not tool:GetAttribute("FPSPrototype") then return end
    tool.Equipped:Connect(function() equip(tool) end)
    tool.Unequipped:Connect(function() unequip(tool) end)
    tool.Activated:Connect(fire)
end
local function hookCharacter(character)
    for _,child in ipairs(character:GetChildren()) do hookTool(child) end
    character.ChildAdded:Connect(hookTool)
end
if player.Character then hookCharacter(player.Character) end
player.CharacterAdded:Connect(hookCharacter)
UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.R then reload() end
end)
RunService.RenderStepped:Connect(function(dt)
    if not viewmodel or not activeTool then return end
    animTime+=dt
    recoil=recoil*math.exp(-dt*13)
    local moving=0
    local character=player.Character
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then moving=math.clamp(humanoid.MoveDirection.Magnitude,0,1) end
    local bob=math.sin(animTime*8)*0.018*moving
    local sway=math.cos(animTime*4)*0.012
    local reloadDrop=reloadProgress>0 and math.sin(reloadProgress*math.pi)*0.38 or 0
    local reloadRoll=reloadProgress>0 and math.sin(reloadProgress*math.pi)*0.22 or 0
    local base=camera.CFrame*CFrame.new(0.5+bob,-0.48+reloadDrop,-1.35)
    local pose=CFrame.Angles(math.rad(-2)-recoil*1.8,reloadRoll,sway)
    viewmodel:PivotTo(base*pose)
end)


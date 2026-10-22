-- Replaces only the dummy's visual. The invisible Torso, prompt, and punch contract stay intact.
local dummy = workspace.Map.Gameplay.PunchLane.Dummy
local torso = dummy:FindFirstChild("Torso")
assert(torso and dummy.PrimaryPart == torso and torso:FindFirstChild("PunchPrompt"))
local backupFolder = game.ServerStorage:FindFirstChild("PublishReady_Backup_20261018")
if not backupFolder then
    backupFolder = Instance.new("Folder")
    backupFolder.Name = "PublishReady_Backup_20261018"
    backupFolder.Parent = game.ServerStorage
end
if not backupFolder:FindFirstChild("CharacterVisual") then
    dummy.CharacterVisual:Clone().Parent = backupFolder
end
dummy.CharacterVisual:Destroy()
local visual = Instance.new("Model")
visual.Name = "CharacterVisual"
visual.Parent = dummy

local skin = Color3.fromRGB(246, 190, 145)
local yellow = Color3.fromRGB(255, 207, 47)
local black = Color3.fromRGB(25, 22, 31)
local brown = Color3.fromRGB(103, 58, 35)
local white = Color3.fromRGB(255, 250, 234)
local base = torso.CFrame

local function make(name, size, offset, color, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = base * offset
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = visual
    return p
end

make("Oversized expressive head", Vector3.new(2.35, 2.35, 2.15), CFrame.new(0, 1.52, 0), skin, Enum.PartType.Ball)
make("Left ear", Vector3.new(.44, .56, .35), CFrame.new(-1.12, 1.5, 0), skin, Enum.PartType.Ball)
make("Right ear", Vector3.new(.44, .56, .35), CFrame.new(1.12, 1.5, 0), skin, Enum.PartType.Ball)
make("Yellow shirt", Vector3.new(1.75, 1.63, 1.14), CFrame.new(0, -.33, .02), yellow)
make("Collar", Vector3.new(.62, .18, 1.15), CFrame.new(0, .55, .02), white)
make("Black shorts", Vector3.new(1.62, .58, 1.05), CFrame.new(0, -1.38, .02), black)
for _, side in ipairs({-1, 1}) do
    make("Arm", Vector3.new(.45, 1.31, .48), CFrame.new(side * 1.09, -.29, 0) * CFrame.Angles(0, 0, math.rad(side * 12)), skin, Enum.PartType.Cylinder)
    make("Hand", Vector3.new(.5, .5, .5), CFrame.new(side * 1.19, -1.0, -.04), skin, Enum.PartType.Ball)
    make("Leg", Vector3.new(.52, 1.12, .55), CFrame.new(side * .47, -2.02, .06), skin, Enum.PartType.Cylinder)
    make("Sock", Vector3.new(.56, .25, .59), CFrame.new(side * .47, -2.48, .06), white)
    make("Shoe", Vector3.new(.76, .38, 1.1), CFrame.new(side * .47, -2.75, -.22), brown, Enum.PartType.Ball)
    make("White eye", Vector3.new(.58, .71, .17), CFrame.new(side * .48, 1.68, -1.01), white, Enum.PartType.Ball)
    make("Pupil", Vector3.new(.17, .29, .12), CFrame.new(side * .48, 1.67, -1.16), black, Enum.PartType.Ball)
    make("Eyebrow", Vector3.new(.57, .1, .11), CFrame.new(side * .48, 2.18, -1.02) * CFrame.Angles(0, 0, math.rad(-side * 9)), black)
end
make("Open surprised mouth", Vector3.new(.52, .68, .13), CFrame.new(0, .95, -1.09), black, Enum.PartType.Ball)
make("Tongue", Vector3.new(.31, .15, .06), CFrame.new(0, .73, -1.18), Color3.fromRGB(234, 103, 113), Enum.PartType.Ball)
make("Nose", Vector3.new(.31, .27, .3), CFrame.new(0, 1.39, -1.12), skin, Enum.PartType.Ball)
make("Hair curl", Vector3.new(.48, .15, .28), CFrame.new(-.18, 2.75, -.49) * CFrame.Angles(0, 0, math.rad(27)), black, Enum.PartType.Ball)
make("Hair tuft", Vector3.new(.17, .37, .18), CFrame.new(-.29, 2.91, -.35) * CFrame.Angles(0, 0, math.rad(-20)), black, Enum.PartType.Ball)

local points = {
    Vector3.new(-.9, -.42, -.58), Vector3.new(-.52, -.63, -.58),
    Vector3.new(-.16, -.42, -.58), Vector3.new(.2, -.63, -.58),
    Vector3.new(.56, -.42, -.58), Vector3.new(.9, -.63, -.58),
}
for i = 1, #points - 1 do
    local a, b = points[i], points[i + 1]
    local segment = make("Shirt zigzag " .. i, Vector3.new((b-a).Magnitude, .16, .08), CFrame.new((a+b)/2) * CFrame.Angles(0, 0, math.atan2(b.Y-a.Y, b.X-a.X)), black)
    segment.Material = Enum.Material.SmoothPlastic
end

dummy:SetAttribute("VisualStyle", "CartoonBoy2026")
return "VISUAL PASS: cartoon boy installed, " .. tostring(#visual:GetChildren()) .. " parts; prompt preserved"

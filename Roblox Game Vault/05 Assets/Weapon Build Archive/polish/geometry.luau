local package = game.ReplicatedStorage.ReferenceWeapons
assert(not package:GetAttribute('SightAndPistolPolish'), 'Polish already applied')
local function detail(model, name, size, cf, color, component, material)
    local p = Instance.new('Part')
    p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
    p.Material = material or Enum.Material.Metal
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
    p:SetAttribute('Component', component or 'Body')
    p:SetAttribute('RestCFrame', cf)
    p.Parent = model
    return p
end
local black = Color3.fromRGB(26, 31, 37)
local compact = package.Viewmodels.W2
-- An unobstructed reflex aperture sits above the pre-existing rail, not inside it.
detail(compact, 'ReflexMount', Vector3.new(.25, .055, .29), CFrame.new(0, .665, -.40), black)
detail(compact, 'ReflexBase', Vector3.new(.31, .055, .15), CFrame.new(0, .722, -.40), black)
detail(compact, 'ReflexLeft', Vector3.new(.036, .292, .105), CFrame.new(-.157, .90, -.40), black)
detail(compact, 'ReflexRight', Vector3.new(.036, .292, .105), CFrame.new(.157, .90, -.40), black)
detail(compact, 'ReflexTop', Vector3.new(.25, .036, .105), CFrame.new(0, 1.058, -.40), black)
for _, side in ipairs({-1, 1}) do
    detail(compact, 'ReflexShoulder' .. side, Vector3.new(.075, .035, .105), CFrame.new(side * .133, 1.039, -.40) * CFrame.Angles(0, 0, -side * math.rad(40)), black)
end
local dot = detail(compact, 'ReflexDot', Vector3.new(.013, .013, .013), CFrame.new(0, .90, -.435), Color3.fromRGB(255, 78, 38), 'Body', Enum.Material.Neon)
dot.Shape = Enum.PartType.Ball
compact.PrimaryPart.Aim.Position = Vector3.new(0, .90, -.40)
for _, id in ipairs({'W3', 'W4'}) do
    local m = package.Viewmodels[id]
    for _, p in ipairs(m:GetChildren()) do
        if p:IsA('MeshPart') then
            p.Size *= Vector3.new(1, 1, .82)
            local pos = p.Position
            p.CFrame = CFrame.new(pos.X * .82, pos.Y, pos.Z) * p.CFrame.Rotation
            p:SetAttribute('RestCFrame', p.CFrame)
        end
    end
    -- A machined rear cap breaks up the formerly blank, oversized slide face.
    detail(m, 'SlideRearPlate', Vector3.new(.160, .125, .018), CFrame.new(0, .584, .097), Color3.fromRGB(38, 43, 49), 'Bolt')
    detail(m, 'SlideRearInset', Vector3.new(.096, .073, .008), CFrame.new(0, .584, .111), Color3.fromRGB(68, 75, 83), 'Bolt')
    for _, side in ipairs({-1, 1}) do
        local pin = detail(m, 'RearPlatePin' .. side, Vector3.new(.018, .018, .010), CFrame.new(side * .057, .579, .111), Color3.fromRGB(117, 127, 136), 'Bolt')
        pin.Shape = Enum.PartType.Ball
    end
end
-- Keep remote players' held models consistent with the adjusted templates.
for _, tool in ipairs(game.StarterPack:GetChildren()) do
    local id = tool:GetAttribute('ReferenceWeaponId')
    if id == 'W2' or id == 'W3' or id == 'W4' then
        local old = tool:FindFirstChild('WorldModel'); if old then old:Destroy() end
        for _, child in ipairs(tool.Handle:GetChildren()) do if child:IsA('WeldConstraint') then child:Destroy() end end
        local world = package.Viewmodels[id]:Clone()
        world.Name, world.Parent = 'WorldModel', tool
        for _, p in ipairs(world:GetDescendants()) do
            if p:IsA('BasePart') then
                p.Anchored, p.Massless = false, true
                local weld = Instance.new('WeldConstraint')
                weld.Part0, weld.Part1, weld.Parent = tool.Handle, p, tool.Handle
            end
        end
    end
end
package:SetAttribute('SightAndPistolPolish', true)
return 'GEOMETRY PASS compact=open reflex optic; pistols=82% slide width + rear plates; world models=updated'

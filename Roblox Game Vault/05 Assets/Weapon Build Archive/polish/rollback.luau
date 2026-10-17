local rs, ss = game:GetService('ReplicatedStorage'), game:GetService('ServerStorage')
local live = assert(rs:FindFirstChild('ReferenceWeapons'))
local backup = assert(ss:FindFirstChild('WeaponPolishBackup_20261016'))
live:ClearAllChildren()
for name in pairs(live:GetAttributes()) do live:SetAttribute(name, nil) end
for name, value in pairs(backup:GetAttributes()) do live:SetAttribute(name, value) end
for _, child in ipairs(backup:GetChildren()) do child:Clone().Parent = live end
for _, tool in ipairs(game.StarterPack:GetChildren()) do
    local id = tool:GetAttribute('ReferenceWeaponId')
    if id == 'W2' or id == 'W3' or id == 'W4' then
        local old = tool:FindFirstChild('WorldModel'); if old then old:Destroy() end
        for _, child in ipairs(tool.Handle:GetChildren()) do if child:IsA('WeldConstraint') then child:Destroy() end end
        local world = live.Viewmodels[id]:Clone(); world.Name, world.Parent = 'WorldModel', tool
        for _, part in ipairs(world:GetDescendants()) do
            if part:IsA('BasePart') then
                part.Anchored, part.Massless = false, true
                local weld = Instance.new('WeldConstraint')
                weld.Part0, weld.Part1, weld.Parent = tool.Handle, part, tool.Handle
            end
        end
    end
end
return 'ROLLBACK PASS original controller/config/three weapon templates restored'

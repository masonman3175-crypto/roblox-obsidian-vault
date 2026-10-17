local function gun(id, name, clip, reserve, rpm, reload, automatic, scale, grip, support, muzzle, aim)
    local function point(x, y, z)
        return Vector3.new(y - grip.Y, z - grip.Z, x - grip.X) * scale
    end
    return {
        Id = id, Name = name, MagazineSize = clip, Reserve = reserve, RPM = rpm,
        ReloadTime = reload, Automatic = automatic, Scale = scale, SourceGrip = grip,
        Support = point(support.X, support.Y, support.Z),
        Muzzle = point(muzzle.X, muzzle.Y, muzzle.Z),
        Aim = point(aim.X, aim.Y, aim.Z),
        Magazine = point((id == 'W3' or id == 'W4') and .5 or -.64, 0, .5),
        Bolt = point(-.15, -.36, 1.75),
        Hip = CFrame.new(.48, -.78, -.83), AimFov = 58,
        Kick = .035, Shotgun = false, Pistol = false,
    }
end
local guns = {
    W1 = gun('W1', 'Walnut AK', 30, 150, 600, 2.15, true, .37,
        Vector3.new(.85, 0, .65), Vector3.new(-2.15, -.12, 1.19),
        Vector3.new(-5.32, 0, 1.64), Vector3.new(-.93, 0, 2.23)),
    W2 = gun('W2', 'Compact AK', 30, 150, 720, 1.85, true, .39,
        Vector3.new(.85, 0, .65), Vector3.new(-2.00, -.12, 1.19),
        Vector3.new(-3.89, 0, 1.64), Vector3.new(-.93, 0, 2.23)),
    W3 = gun('W3', 'Silver 9mm', 15, 90, 420, 1.65, false, .50,
        Vector3.new(.50, 0, .65), Vector3.new(.08, -.20, .62),
        Vector3.new(-2.06, 0, 1.89), Vector3.new(.48, 0, 2.22)),
    W4 = gun('W4', 'Lime 9mm', 17, 102, 450, 1.65, false, .50,
        Vector3.new(.50, 0, .65), Vector3.new(.08, -.20, .62),
        Vector3.new(-2.06, 0, 1.89), Vector3.new(.48, 0, 2.22)),
    W5 = gun('W5', 'Pump Shotgun', 8, 40, 75, 2.65, false, .37,
        Vector3.new(1.12, 0, .65), Vector3.new(-3.5, -.12, 1.10),
        Vector3.new(-6.34, 0, 1.83), Vector3.new(.8, 0, 2.08)),
}
for _, id in ipairs({'W3', 'W4'}) do
    local g = guns[id]
    g.Pistol = true
    g.Hip = CFrame.new(.48, -.80, -1.55) * CFrame.Angles(math.rad(-2), math.rad(22), math.rad(-3))
    g.Magazine = Vector3.new(0, -.12, 0)
    g.Bolt = Vector3.new(0, .58, -.30)
    g.AimFov = 62
    g.Kick = .095
    g.CameraRecoil = .72
    g.RecoilYaw = .55
    g.SightDistance = 1.40
    g.Pullback = .16
    g.Support = Vector3.new(g.Support.X * .82, g.Support.Y, g.Support.Z)
end
-- Calibrate to the actual open optic, above the compact rail teeth.
guns.W2.Aim = Vector3.new(0, .90, -.40)
guns.W1.Kick, guns.W1.CameraRecoil, guns.W1.RecoilYaw, guns.W1.Pullback = .055, .75, .30, .105
guns.W2.Kick, guns.W2.CameraRecoil, guns.W2.RecoilYaw, guns.W2.Pullback = .052, .75, .40, .09
guns.W5.Shotgun = true
guns.W5.Kick, guns.W5.CameraRecoil, guns.W5.RecoilYaw, guns.W5.Pullback = .145, .80, .60, .20
guns.W5.Hip = CFrame.new(.50, -.80, -.72)
guns.W5.AimFov = 62
return {Order = {'W1', 'W2', 'W3', 'W4', 'W5'}, Guns = guns}

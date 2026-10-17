local C = {
    TeamName = "Survivors",
    TeamColor = BrickColor.new("Earth green"),
    LobbyCenter = Vector3.new(1000, 0, 0),
    LobbySpawn = CFrame.lookAt(Vector3.new(1000, 4.5, 20), Vector3.new(1000, 4.5, -5)),
    ArenaSpawn = CFrame.lookAt(Vector3.new(0, 4.6, 0), Vector3.new(0, 4.6, -15)),
    Countdown = 15,
    ScanInterval = .2,
    Modes = {
        {Id="Solos", Size=1, X=-63, Color=Color3.fromRGB(75,210,156)},
        {Id="Duos", Size=2, X=-21, Color=Color3.fromRGB(64,170,243)},
        {Id="Trios", Size=3, X=21, Color=Color3.fromRGB(180,125,249)},
        {Id="Squads", Size=4, X=63, Color=Color3.fromRGB(245,173,77)},
    },
}
C.Queues = {}
for _,mode in C.Modes do
    for slot=1,2 do
        table.insert(C.Queues, {
            Id=mode.Id.."_"..slot, Mode=mode.Id, Slot=slot, Size=mode.Size,
            X=mode.X, Z=slot==1 and -9 or 9, Radius=7, Color=mode.Color,
        })
    end
end
return C

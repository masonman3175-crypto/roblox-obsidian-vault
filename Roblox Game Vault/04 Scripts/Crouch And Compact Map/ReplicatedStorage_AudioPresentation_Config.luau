-- Presentation only. All asset IDs were discovered in Creator Store and load-tested in Play.
return {
    MusicVolume = .05,
    Music = "NightRouteDrill",
    MusicFallback = "CrossedWires",
    MaxVoices = 48,
    GunshotDistance = 240,
    FootstepDistance = 65,
    Assets = {
        NightRouteDrill = {Id = "rbxassetid://107491422176664", Volume = 1},
        CrossedWires = {Id = "rbxassetid://9042281328", Volume = 1},
        RifleShot = {Id = "rbxassetid://6975483207", Volume = .66},
        PistolShot = {Id = "rbxassetid://3102797479", Volume = .58},
        ShotgunShot = {Id = "rbxassetid://136216209294970", Volume = .80},
        RifleReload = {Id = "rbxassetid://139048584127232", Volume = .36},
        PistolReload = {Id = "rbxassetid://127374386997069", Volume = .38},
        ShotgunReload = {Id = "rbxassetid://139827026287805", Volume = .30},
        StepConcrete = {Id = "rbxassetid://87061775498714", Volume = .32},
        StepGrass = {Id = "rbxassetid://135037154891351", Volume = .34},
        Cloth = {Id = "rbxassetid://9113824230", Volume = .22},
        Bolt = {Id = "rbxassetid://138244068", Volume = .30},
        UIClick = {Id = "rbxassetid://82845990304289", Volume = .16},
        Shell = {Id = "rbxassetid://9116714473", Volume = .14},
    },
    Weapons = {
        W1 = {Shot = "RifleShot", Reload = "RifleReload", Pitch = 1, ExistingShot = true},
        W2 = {Shot = "RifleShot", Reload = "RifleReload", Pitch = 1.12},
        W3 = {Shot = "PistolShot", Reload = "PistolReload", Pitch = 1.14},
        W4 = {Shot = "PistolShot", Reload = "PistolReload", Pitch = 1.05},
        W5 = {Shot = "ShotgunShot", Reload = "ShotgunReload", Pitch = .94},
    },
    -- Local remapping of existing effects, without edits to the combat owner's source.
    Legacy = {
        ["rbxassetid://1112730119"] = "RifleShot",
        ["rbxassetid://6850980505"] = "Shell",
    },
}


-- Effects only; music is intentionally absent.
-- Native per-weapon shot support follows the current combat configuration.
local native = {}
local ak = game:GetService("ReplicatedStorage"):FindFirstChild("ClaudeAK")
local nativeConfig = ak and ak:FindFirstChild("Config")
if nativeConfig and nativeConfig:IsA("ModuleScript") then
    local ok, value = pcall(require, nativeConfig)
    if ok and type(value) == "table" then
        if type(value.Weapons) == "table" then
            for id, weapon in value.Weapons do
                if type(weapon) == "table" and type(weapon.Shot) == "string" and weapon.Shot ~= "" then native[id] = true end
            end
        elseif type(value.Sounds) == "table" and type(value.Sounds.Shot) == "string" and value.Sounds.Shot ~= "" then
            native.W1 = true
        end
    end
end
return {
    MaxVoices = 48,
    GunshotDistance = 240,
    FootstepDistance = 65,
    Assets = {
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
        W1 = {Shot = "RifleShot", Reload = "RifleReload", Pitch = 1, ExistingShot = native.W1 == true},
        W2 = {Shot = "RifleShot", Reload = "RifleReload", Pitch = 1.12},
        W3 = {Shot = "PistolShot", Reload = "PistolReload", Pitch = 1.14, ExistingShot = native.W3 == true},
        W4 = {Shot = "PistolShot", Reload = "PistolReload", Pitch = 1.05},
        W5 = {Shot = "ShotgunShot", Reload = "ShotgunReload", Pitch = .94},
    },
    -- Local remapping of existing effects, without edits to the combat owner's source.
    Legacy = {
        ["rbxassetid://1112730119"] = "RifleShot",
        ["rbxassetid://6850980505"] = "Shell",
    },
}

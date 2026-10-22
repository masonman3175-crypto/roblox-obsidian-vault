-- Run in the Edit DataModel only if the whole monetization update must be reverted.
local backup = assert(game.ServerStorage:FindFirstChild("MonetizationRollback_20261018"))
local restored = 0
for _, copy in backup:GetChildren() do
    local path = copy:GetAttribute("OriginalPath")
    if path then
        local target = game
        for segment in string.gmatch(path, "[^%.]+") do
            target = assert(target:FindFirstChild(segment), "Missing " .. path)
        end
        assert(target:IsA("LuaSourceContainer"))
        target.Source = copy.Source
        restored += 1
    end
end
local remote = backup:FindFirstChild("Remote__StudioPurchase")
if remote and not game.ReplicatedStorage.Remotes:FindFirstChild("StudioPurchase") then
    local restoredRemote = remote:Clone()
    restoredRemote.Name = "StudioPurchase"
    restoredRemote.Parent = game.ReplicatedStorage.Remotes
end
return "STUDIO_ROLLBACK: restored " .. restored .. " sources and original remote"

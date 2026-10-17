-- Run in Edit after stopping Play. No combat, map, menu or movement source is overwritten.
-- Targets may be real services or isolated service-shaped fixture folders.
return function(targets)
    local function remove(parent,name)
        local item=parent:FindFirstChild(name)
        if item then item:Destroy() end
    end
    remove(targets.RS,"AudioPresentation")
    remove(targets.SP,"AudioPresentation")
    remove(targets.SSS,"AudioPresentation")
    remove(targets.Sound,"BackgroundMusic")
    remove(targets.Sound,"GameAudioMusic")
    remove(targets.Sound,"GameAudioEffects")
    return "ROLLBACK PASS: audio package, boots, music and mix groups removed; baseline gameplay sources retained"
end


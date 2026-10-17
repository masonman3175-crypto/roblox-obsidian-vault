-- Invoke only through Studio MCP; defaults target the live game in Edit.
return function(package, mixRoot, backup)
    package=package or game.ReplicatedStorage.AudioPresentation
    mixRoot=mixRoot or game.SoundService
    backup=backup or assert(game.ServerStorage:FindFirstChild("AudioSfxRestoreBackup_20261017"))
    for _,n in {"Client","Config"} do package[n].Source=backup[n].Source end
    package.Assets:Destroy()
    backup.Assets:Clone().Parent=package
    for _,n in {"BackgroundMusic","GameAudioMusic","GameAudioEffects"} do
        local existing=mixRoot:FindFirstChild(n);if existing then existing:Destroy() end
        if backup:GetAttribute("Had_"..n) then local copy=assert(backup:FindFirstChild(n)):Clone();copy.Parent=mixRoot end
    end
    return true
end

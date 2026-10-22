local controllers = game.StarterPlayer.StarterPlayerScripts.Controllers
local function check(source, modified)
    source = source:gsub('\r', '')
    local block = assert(source:match('(local MEME_CLIP_ASSET_ID.-)\nlocal function setVisible'))
    local sounds = {}
    local mockInstance = {}
    function mockInstance.new(class)
        assert(class == 'Sound')
        local s = {IsLoaded=true, TimePosition=0, plays=0, stops=0, Ended={Connect=function() end}}
        function s:Play() self.plays += 1; self.IsPlaying=true end
        function s:Stop() self.stops += 1; self.IsPlaying=false end
        function s:Destroy() self.Parent=nil end
        table.insert(sounds,s)
        return s
    end
    local fn=assert(loadstring('local SoundService, Instance, task = ...\n'..block..'\nreturn impactAudio'))
    local impact=fn({},mockInstance,{delay=function() end})
    impact(); impact()
    if modified then
        assert(#sounds==1,'voices must not stack')
        local s=sounds[1]
        assert(s.SoundId=='rbxassetid://83363670294957')
        assert(s.plays==2 and s.stops==2 and s.TimePosition==0,'restart every hit')
        assert(s.Looped==false and s.PlaybackSpeed==1,'play ending once, normal speed')
        s.IsLoaded=false; impact()
        assert(#sounds==2 and sounds[2].SoundId=='rbxassetid://7468131335','unavailable audio fallback')
        s.IsLoaded=true; impact()
        assert(#sounds==2 and s.plays==3,'voice recovers without stacking')
        local _, count=source:gsub('impactAudio%(%)','')
        assert(count==3,'definition plus manual and auto impact call sites')
        assert(source:find('ContentProvider:PreloadAsync({voice})',1,true),'preload on start')
    else
        assert(#sounds==2 and sounds[1].SoundId=='rbxassetid://7468131335')
    end
end
check(game.ServerStorage.PunchVoiceOriginal_20261018.Source,false)
check(controllers.PunchFxController.Source,true)
return 'BASELINE PASS: generic hit only. MODIFIED PASS: ending ID, restart, no overlap, normal speed, one-shot, preload, fallback/recovery, manual+auto branches.'

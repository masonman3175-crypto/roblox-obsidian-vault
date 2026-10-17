local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local package=RS:WaitForChild('MainMenu')
local Config=require(package.MenuConfig)
local Cosmetics=require(package.Cosmetics)
local Weapons=require(RS.ReferenceWeapons.WeaponConfig)
local Service={}
local states={}
local started=false
local focus
local function menuFocus(p)
    if focus then p.ReplicationFocus=focus end
end
local function public(s) return {Skin=s.Skin,Wrap=s.Wrap,Weapon=s.Weapon,InMenu=s.InMenu} end
local function applyTool(p,t)
    if t:IsA('Tool') and t:GetAttribute('ReferenceWeaponId') then Cosmetics.ApplyWeapon(t,p:GetAttribute('CosmeticWrap') or Config.DefaultWrap) end
end
local function skinCharacter(p,char)
    if not char.Parent then return end
    local s=states[p];if not s then return end
    Cosmetics.ApplySkin(char,s.Skin)
    for _,t in ipairs(char:GetChildren()) do applyTool(p,t) end
    char.ChildAdded:Connect(function(t) applyTool(p,t) end)
    local hum=char:FindFirstChildOfClass('Humanoid')
    if hum then hum.Died:Connect(function()
        task.delay(3,function()
            if p.Parent and states[p]==s and not s.InMenu and not s.Busy then Service.Deploy(p) end
        end)
    end) end
end
function Service.Deploy(p)
    local s=states[p];if not s then return {Ok=false,Message='Player not ready'} end
    if s.Busy then return {Ok=false,Message='Deployment already in progress'} end
    if p.Character and p.Character:FindFirstChildOfClass('Humanoid') and p.Character.Humanoid.Health>0 and not s.InMenu then return {Ok=true,State=public(s)} end
    s.Busy=true
    local ok,err=pcall(function() p:LoadCharacterAsync() end)
    s.Busy=false
    if not ok or not p.Character then return {Ok=false,Message='Spawn failed. Try Play again.'} end
    s.InMenu=false;p:SetAttribute('InMenu',false);p.ReplicationFocus=nil
    skinCharacter(p,p.Character)
    return {Ok=true,State=public(s)}
end
function Service.Handle(p,action,payload)
    local s=states[p]
    if not s or typeof(action)~='string' or #action>24 then return {Ok=false,Message='Invalid request'} end
    if action=='State' then return {Ok=true,State=public(s)} end
    local now=os.clock()
    if now-(s.Last or -10)<.08 then return {Ok=false,Message='Please wait a moment'} end
    s.Last=now
    if action=='Deploy' then return Service.Deploy(p) end
    if action=='Menu' then
        if s.Busy then return {Ok=false,Message='Wait for deployment'} end
        s.InMenu=true;p:SetAttribute('InMenu',true);menuFocus(p)
        if p.Character then p.Character:Destroy();p.Character=nil end
        return {Ok=true,State=public(s)}
    end
    if not s.InMenu or s.Busy then return {Ok=false,Message='Open the locker from the menu'} end
    if typeof(payload)~='string' or #payload>24 then return {Ok=false,Message='Invalid cosmetic'} end
    if action=='Skin' and Config.Skins[payload] then s.Skin=payload;p:SetAttribute('CosmeticSkin',payload)
        p:SetAttribute('EquippedHandColor',Config.Skins[payload].Hands);p:SetAttribute('EquippedSleeveColor',Config.Skins[payload].Arms)
    elseif action=='Wrap' and Config.Wraps[payload] then s.Wrap=payload;p:SetAttribute('CosmeticWrap',payload)
    elseif action=='Weapon' and Weapons.Guns[payload] then s.Weapon=payload;p:SetAttribute('PreferredWeapon',payload)
    else return {Ok=false,Message='Unknown selection'} end
    return {Ok=true,State=public(s)}
end
local function added(p)
    if states[p] then return end
    states[p]={Skin=Config.DefaultSkin,Wrap=Config.DefaultWrap,Weapon=Config.DefaultWeapon,InMenu=true,Busy=false}
    menuFocus(p)
    p:SetAttribute('InMenu',true);p:SetAttribute('CosmeticSkin',Config.DefaultSkin);p:SetAttribute('CosmeticWrap',Config.DefaultWrap)
    p:SetAttribute('PreferredWeapon',Config.DefaultWeapon)
    p:SetAttribute('EquippedHandColor',Config.Skins[Config.DefaultSkin].Hands);p:SetAttribute('EquippedSleeveColor',Config.Skins[Config.DefaultSkin].Arms)
    task.spawn(function()
        local backpack=p:WaitForChild('Backpack',20)
        if backpack then backpack.ChildAdded:Connect(function(t) applyTool(p,t) end) end
    end)
end
function Service.Start()
    if started then return end;started=true
    Players.CharacterAutoLoads=false
    focus=workspace:FindFirstChild('MainMenuStreamingFocus')
    if not focus then
        focus=Instance.new('Part');focus.Name='MainMenuStreamingFocus'
        focus.Size=Vector3.one;focus.CFrame=CFrame.new(5,4,0)
        focus.Anchored=true;focus.Transparency=1;focus.CanCollide=false;focus.CanTouch=false;focus.CanQuery=false
        focus.Parent=workspace
    end
    package.Request.OnServerInvoke=Service.Handle
    for _,p in ipairs(Players:GetPlayers())do added(p) end
    Players.PlayerAdded:Connect(added)
    Players.PlayerRemoving:Connect(function(p)states[p]=nil end)
end
return Service

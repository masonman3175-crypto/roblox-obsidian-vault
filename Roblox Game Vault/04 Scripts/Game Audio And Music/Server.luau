-- Audio-only fanout. Never grants hits, ammunition, damage, kills, currency or inventory.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local package=RS:WaitForChild("AudioPresentation")
local C=require(package.Config)
local guns=require(RS:WaitForChild("ReferenceWeapons").WeaponConfig).Guns
local M={}
local connections, states={},{}
local started=false
local accepted,rejected=0,0
function M.Validate(kind,extra,id,now,state)
    if type(kind)~="string" or #kind>8 or extra~=0 then return false end
    if kind~="Shot" and kind~="Reload" and kind~="Equip" then return false end
    local gun=guns[id]
    if not gun or not C.Weapons[id] then return false end
    if kind=="Shot" and C.Weapons[id].ExistingShot then return false end
    local previous=state[kind] or -100
    local interval=kind=="Shot" and 60/gun.RPM*.90 or kind=="Reload" and gun.ReloadTime*.80 or .25
    if now-previous<interval then return false end
    state[kind]=now
    return true
end
function M.Handle(p,kind,...)
    local char=p.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local tool=char and char:FindFirstChildOfClass("Tool")
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health<=0 or not root or not tool or p:GetAttribute("InMenu") then rejected+=1;return false end
    local id=tool:GetAttribute("ReferenceWeaponId")
    local state=states[p]
    if not state then state={};states[p]=state end
    if not M.Validate(kind,select("#",...),id,os.clock(),state) then rejected+=1;return false end
    accepted+=1
    -- Only the server-selected tool ID and enum-like action are broadcast.
    -- No arbitrary SoundIds, positions or volumes come from clients.
    package.Emit:FireAllClients(p,kind,id)
    return true
end
function M.GetStats() return {Accepted=accepted,Rejected=rejected} end
function M.Start()
    if started then return M end
    started=true
    table.insert(connections,package.Emit.OnServerEvent:Connect(M.Handle))
    table.insert(connections,Players.PlayerRemoving:Connect(function(p) states[p]=nil end))
    return M
end
function M.Destroy()
    for _,c in connections do c:Disconnect() end
    connections={};states={};started=false
end
return M


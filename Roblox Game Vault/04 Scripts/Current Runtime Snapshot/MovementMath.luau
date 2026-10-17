local C=require(script.Parent.MovementConfig)
local M={}
function M.Finite(n)return typeof(n)=='number' and n==n and math.abs(n)<1e6 end
function M.Direction(v)
    if typeof(v)~='Vector3' or not M.Finite(v.X) or not M.Finite(v.Y) or not M.Finite(v.Z) then return nil end
    if math.abs(v.Y)>.35 or v.Magnitude<.1 or v.Magnitude>1.15 then return nil end
    local flat=Vector3.new(v.X,0,v.Z)
    return flat.Magnitude>.1 and flat.Unit or nil
end
function M.SlideSpeed(t)
    local a=math.clamp(t/C.SlideDuration,0,1)
    return C.SlideEndSpeed+(C.SlideSpeed-C.SlideEndSpeed)*(1-a)^1.45
end
function M.Stamina(value,sprinting,dt)
    return math.clamp(value+(sprinting and -C.SprintDrain or C.StaminaRegen)*dt,0,C.StaminaMax)
end
return M


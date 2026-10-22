local S={}
function S.Add(ctx,player,coins,xp)
 local p=ctx.Data.Profiles[player];if not p then return end
 p.Coins+=math.max(0,math.floor(coins));p.XP+=math.max(0,math.floor(xp or 0))
end
return S

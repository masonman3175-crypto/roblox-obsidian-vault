local S={}
function S.Try(ctx,player)
 local p=ctx.Data.Profiles[player];local need=ctx.Config.RebirthCost(p.Rebirths)
 if p.Size<need then return false,"Rebirth requires "..need.." Size" end
 p.Size=0;p.Rebirths+=1;ctx.Coins.Add(ctx,player,100,50);ctx.Growth.Scale(ctx,player)
 return true,"REBIRTH! Permanent x"..ctx.Config.Multiplier(p.Rebirths).." growth"
end
return S

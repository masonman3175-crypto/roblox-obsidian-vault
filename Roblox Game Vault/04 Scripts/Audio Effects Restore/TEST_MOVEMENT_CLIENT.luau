local p=game.Players.LocalPlayer local a=p.PlayerScripts.AudioPresentationControl local root=p.Character.HumanoidRootPart
local old=root.Anchored;root.Anchored=true
task.wait(.4)
local before=a:Invoke("Stats");task.wait(1);local after=a:Invoke("Stats")
root.Anchored=old
assert((after.Counts.Footstep or 0)==(before.Counts.Footstep or 0),"Stationary footfalls")
assert((after.Counts.Footstep or 0)>0 and (after.Counts.Slide or 0)>0 and (after.Counts.Jump or 0)>0 and (after.Counts.Land or 0)>0)
return game.HttpService:JSONEncode({result="MOVEMENT PASS: footstep/slide/jump/land; anchored stationary idle silent; music absent",stats=after})

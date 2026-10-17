local p=game.Players:GetPlayers()[1]
local b=game.ServerScriptService.GameplayMovement.MovementControl
local ok,why=b:Invoke(p,"Crouch","invalid")
assert(not ok and why=="Invalid crouch payload")
local ok2,why2=b:Invoke(p,"Slide",Vector3.new(0/0,0,0))
assert(not ok2 and why2=="Invalid slide direction")
local s=b:Invoke(p,"State")
assert(not s.Crouched)
return game.HttpService:JSONEncode({result="VALIDATION PASS",crouchReject=why,slideReject=why2,state=s})


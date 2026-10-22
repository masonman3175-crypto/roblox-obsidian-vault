-- Run in Client after game startup. Does not alter the player profile or inventory.
local RS=game.ReplicatedStorage
local P=require(RS.Shared.Util.PetVisual)
local Pets=require(RS.Shared.Config.Pets)
local n=0
for id in Pets.List do
	local m=P.Make(id)
	local fx=m:FindFirstChildWhichIsA("ParticleEmitter",true)
	assert(fx and fx.Parent:IsA("BasePart") and fx.Enabled)
	assert(fx.ShapeStyle==Enum.ParticleEmitterShapeStyle.Surface)
	assert(fx.ShapeInOut==Enum.ParticleEmitterShapeInOut.Outward)
	n+=1;m:Destroy()
end
assert(n==63)
local eggs=game.CollectionService:GetTagged("RemodeledEgg")
assert(#eggs==11)
local emitterCount=0
for _,m in eggs do
	assert(m:IsA("Model"))
	for _,x in m:GetDescendants() do if x:IsA("ParticleEmitter") then
		emitterCount+=1
		assert(x.Parent:IsA("BasePart") and x.ShapeStyle==Enum.ParticleEmitterShapeStyle.Surface)
	end end
end
assert(emitterCount==22)
assert(game.Players.LocalPlayer.PlayerGui:FindFirstChild("PetsGui"))
assert(game.Players.LocalPlayer.PlayerGui:FindFirstChild("HatchGui"))
return "PLAY_PARTICLES_PASS pet_emitters=63 egg_emitters=22 shape=surface_outward gui=loaded native_geometry=replicated"

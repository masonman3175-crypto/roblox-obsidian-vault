-- Gym pads in the hub (Workspace.Map.Gameplay.GymPads.GymPad<Tier>).
-- Standing on an unlocked pad multiplies Strength gain. Unlock by rebirths or a pass.
local Gym = {}

Gym.Tiers = {
	{Name = "Bench", Multiplier = 2, Rebirths = 0},
	{Name = "Squat Rack", Multiplier = 3, Rebirths = 1},
	{Name = "Golden Dumbbells", Multiplier = 5, Rebirths = 3},
	{Name = "VIP Bench", Multiplier = 10, Pass = "GymVIP"},
	{Name = "Mega Machine", Multiplier = 25, Pass = "GymMega"},
	{Name = "Admin Throne", Multiplier = 99, Pass = "GymAdmin"},
}

return Gym


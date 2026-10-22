-- Punch the dummy. Distance is in FEET and scales hard with Strength
-- (10K Strength = 33K ft). The dummy flies along the biome track; track
-- position is log scale so every 10x more feet reaches the next biome.
local Punch = {}

Punch.Cooldown = 2
Punch.AutoInterval = 3
Punch.MaxRange = 18
Punch.TrackStartX = 40
Punch.BiomeLength = 1000
Punch.TrackZ = 0

Punch.Biomes = {"Grass Fields", "Desert", "Snow Mountains", "Volcano", "Candy Land", "Outer Space"}

function Punch.Feet(strength)
	return math.floor(3.3 * strength) + 5
end

-- Coins scale with feet, your best world and coin multipliers
function Punch.Coins(feet, worldMultiplier, coinMultiplier)
	return math.floor(feet ^ 0.75 * 2 * worldMultiplier * coinMultiplier)
end

-- Where on the track (x) a punch of this many feet lands
function Punch.TrackX(feet)
	local decades = math.clamp(math.log10(math.max(feet, 10)) - 1, 0, #Punch.Biomes)
	return Punch.TrackStartX + decades * Punch.BiomeLength
end

function Punch.BiomeAt(x)
	local index = math.clamp(math.floor((x - Punch.TrackStartX) / Punch.BiomeLength) + 1, 1, #Punch.Biomes)
	return index, Punch.Biomes[index]
end

return Punch

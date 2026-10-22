-- Punch the dummy. Distance is in FEET and scales hard with Strength
-- (10K Strength = 33K ft). The dummy flies along the biome track; track
-- position is log scale so every 10x more feet reaches the next biome.
local Catalog = require(script.Parent.TrackExtensionCatalog)
local Punch = {}

Punch.Cooldown = 2
Punch.AutoInterval = 3
Punch.MaxRange = 18
Punch.TrackStartX = 40
Punch.BiomeLength = 1000
Punch.TrackZ = 0

Punch.Biomes = table.clone(Catalog.Originals)
for _,entry in ipairs(Catalog.List) do table.insert(Punch.Biomes,entry[1]) end
Punch.MaxExtraWorlds=8

function Punch.Feet(strength)
	return math.floor(3.3 * strength) + 5
end

-- Coins scale with feet, your best world and coin multipliers
function Punch.Coins(feet, worldMultiplier, coinMultiplier)
	return math.floor(feet ^ 0.75 * 2 * worldMultiplier * coinMultiplier)
end

-- Where on the track (x) a punch of this many feet lands
function Punch.Progress(feet)
 assert(type(feet)=="number" and feet==feet and feet>=0 and feet<math.huge,"Invalid feet")
 local log=math.log10(math.max(feet,10))
 if log<=7 then return math.max(0,log-1) end
 return 6+(log-7)*10
end
function Punch.TrackX(feet)
 return Punch.TrackStartX+Punch.Progress(feet)*Punch.BiomeLength
end
function Punch.BiomeAt(x)
 local index=math.max(1,math.floor((x-Punch.TrackStartX)/Punch.BiomeLength+1e-8)+1)
 return index,Catalog.Get(index).name
end
function Punch.FeetAtX(x)
 local progress=math.max(0,(x-40)/1000)
 return if progress<=6 then 10^(1+progress) else 10^(7+(progress-6)/10)
end
function Punch.Threshold(stage)
 if stage<=7 then return 10^stage end
 return 10^(7+(stage-7)/10)
end
return Punch

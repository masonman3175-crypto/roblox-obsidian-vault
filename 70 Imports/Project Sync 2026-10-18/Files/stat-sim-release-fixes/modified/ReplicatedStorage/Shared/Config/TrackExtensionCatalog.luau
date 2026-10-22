-- Original worlds 1-6 remain untouched. Every entry below is appended after Outer Space.
local C={}
C.Originals={"Grass Fields","Desert","Snow Mountains","Volcano","Candy Land","Outer Space"}
C.Folders={"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}
-- name, original landscape template, terrain, foliage/stone, accent, primary/secondary landforms
C.List={
 {"Jungle Falls",1,{74,156,88},{40,122,71},{93,210,230},"waterfall","canopy"},
 {"Redrock Badlands",2,{185,91,56},{138,69,49},{241,155,77},"canyon","arches"},
 {"Aurora Glaciers",3,{166,215,235},{99,164,201},{99,229,211},"glacier","aurora"},
 {"Obsidian Highlands",4,{48,45,65},{72,60,90},{241,94,58},"basalt","rifts"},
 {"Crystal Caverns",3,{112,139,184},{107,92,166},{161,124,250},"cavern","crystals"},
 {"Ringworld Frontier",6,{89,84,141},{114,97,158},{224,191,106},"planet","outpost"},
 {"Cherry Blossom Valley",1,{133,187,113},{239,139,178},{248,189,211},"canopy","terraces"},
 {"Sunken Temple Coast",2,{185,184,129},{112,148,125},{72,189,211},"ruins","coast"},
 {"Emerald Canopy",1,{77,163,106},{36,114,74},{116,218,128},"canopy","vines"},
 {"Thunderstorm Peaks",3,{122,152,186},{110,121,151},{224,221,116},"peaks","storm"},
 {"Molten Foundry",4,{83,67,67},{111,89,84},{255,158,47},"foundry","lavafall"},
 {"Sugarpine Highlands",5,{184,153,199},{166,120,183},{245,175,210},"peaks","sugar"},
 {"Golden Savanna",1,{194,174,90},{133,151,71},{242,208,119},"savanna","mesas"},
 {"Moonlit Bamboo",1,{89,130,130},{55,110,109},{169,201,185},"bamboo","moon"},
 {"Sapphire Atolls",2,{189,210,172},{97,160,133},{72,164,222},"coast","islands"},
 {"Twilight Dunes",2,{174,130,137},{137,109,144},{225,168,117},"dunes","moon"},
 {"Polar Research Frontier",3,{190,226,238},{119,171,196},{244,171,89},"glacier","outpost"},
 {"Amethyst Chasm",3,{137,120,172},{100,83,139},{191,143,238},"canyon","crystals"},
 {"Ember Ashlands",4,{89,76,83},{110,90,96},{248,125,72},"basalt","ash"},
 {"Celestial Gardens",1,{124,181,157},{88,148,126},{229,202,139},"terraces","planet"},
 {"Mushroom Marsh",1,{109,160,131},{79,119,110},{200,130,220},"mushrooms","coast"},
 {"Gingerbread Grove",5,{171,123,87},{125,83,65},{245,212,173},"gingerbread","canopy"},
 {"Lunar Crater Basin",6,{131,140,163},{100,112,147},{180,202,223},"craters","outpost"},
 {"Meteor Wastes",6,{130,109,135},{102,85,112},{244,144,94},"meteors","basalt"},
 {"Cobalt Canyon",2,{100,137,173},{75,105,139},{128,207,221},"canyon","river"},
 {"Ancient Redwood Realm",1,{114,156,95},{74,117,72},{178,134,100},"redwoods","ruins"},
 {"Sandstorm Citadel",2,{214,172,112},{164,126,85},{228,202,143},"citadel","dunes"},
 {"Frozen Waterfall Reach",3,{181,219,232},{124,180,207},{151,232,243},"waterfall","glacier"},
 {"Dragonbone Plateau",2,{192,169,133},{149,125,110},{231,217,173},"bones","mesas"},
 {"Coral Sky Coast",1,{145,189,169},{101,160,145},{239,142,169},"coral","coast"},
 {"Lavafall Rift",4,{88,62,70},{119,76,87},{255,106,43},"lavafall","rifts"},
 {"Cotton Candy Mesa",5,{212,163,204},{171,128,191},{250,185,218},"mesas","sugar"},
 {"Cosmic Reef",6,{105,109,168},{107,83,153},{100,216,212},"coral","planet"},
 {"Neon Rainforest",1,{63,130,115},{51,101,104},{123,231,187},"canopy","crystals"},
 {"Titan Icefield",3,{162,203,222},{115,154,193},{190,217,241},"glacier","peaks"},
 {"Golden Ruins",2,{195,171,113},{163,142,100},{241,210,128},"ruins","arches"},
 {"Stormforge Ridge",4,{89,86,110},{100,101,129},{188,175,242},"foundry","storm"},
 {"Haunted Pine Basin",1,{92,125,111},{63,92,95},{157,190,169},"redwoods","mist"},
 {"Rainbow Crystal Desert",2,{207,181,148},{157,137,155},{185,141,225},"crystals","arches"},
 {"Starlit Tundra",3,{150,186,213},{110,148,185},{177,220,236},"peaks","moon"},
 {"Floating Mountain Sea",1,{135,179,166},{93,143,133},{172,215,208},"islands","waterfall"},
 {"Honeycomb Meadows",5,{211,179,103},{170,141,76},{247,212,115},"honey","terraces"},
 {"Alien Fungal Wilds",6,{98,130,137},{76,106,119},{163,221,138},"mushrooms","meteors"},
 {"Prism Snowfields",3,{186,205,225},{143,163,205},{202,163,231},"crystals","glacier"},
 {"Ruby Caldera",4,{116,65,84},{145,79,108},{255,112,132},"caldera","basalt"},
 {"Orchid Cloudforest",1,{115,160,137},{87,130,115},{217,143,192},"canopy","mist"},
 {"Clockwork Cliffs",2,{173,143,115},{130,108,99},{220,181,111},"gears","mesas"},
 {"Candy Cane Tundra",5,{215,202,215},{176,155,184},{238,137,162},"glacier","sugar"},
 {"Deep Space Outpost",6,{91,101,146},{78,86,126},{135,207,221},"outpost","planet"},
 {"Bluefire Gorge",4,{65,79,110},{77,103,133},{71,190,245},"canyon","lavafall"},
 {"Jade Terrace Valley",1,{121,170,122},{78,133,104},{187,213,155},"terraces","bamboo"},
 {"Sunstone Spires",2,{212,170,107},{169,125,82},{249,211,116},"crystals","dunes"},
 {"Comet Icebelt",3,{164,204,222},{117,159,188},{190,221,235},"meteors","glacier"},
 {"Midnight Obsidian",4,{48,49,79},{65,67,102},{148,131,230},"basalt","moon"},
 {"Emerald Moon",6,{92,144,131},{75,109,123},{132,218,169},"planet","craters"},
 {"Blossom Skylands",1,{152,190,149},{216,145,168},{241,187,206},"islands","canopy"},
 {"Spectral Dune Sea",2,{175,166,191},{128,123,167},{204,190,232},"dunes","mist"},
 {"Endless Aurora",3,{170,211,227},{122,171,196},{111,229,207},"aurora","glacier"},
 {"Galactic Rift",6,{94,85,147},{111,91,162},{180,148,239},"rifts","planet"},
 {"Supernova Horizon",6,{128,103,155},{145,111,174},{246,177,111},"supernova","meteors"},
}
C.Count=6+#C.List
function C.Get(stage)
 assert(type(stage)=="number" and stage%1==0 and stage>=1 and stage<math.huge,"Invalid world")
 if stage<=6 then return {stage=stage,name=C.Originals[stage],template=stage,original=true} end
 local index=(stage-7)%#C.List+1
 local cycle=math.floor((stage-7)/#C.List)
 local s=C.List[index]
 local function color(t)
  local c=Color3.fromRGB(table.unpack(t))
  if cycle==0 then return c end
  local h,sat,val=c:ToHSV();return Color3.fromHSV((h+cycle*.047)%1,sat,val)
 end
 return {stage=stage,index=index,name=s[1]..(if cycle>0 then " / Frontier "..(cycle+1) else ""),template=s[2],
  terrain=color(s[3]),foliage=color(s[4]),accent=color(s[5]),feature=s[6],secondary=s[7],cycle=cycle,seed=stage*7919%2147483647}
end
return C



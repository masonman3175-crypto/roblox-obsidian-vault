-- Appearance only. Pet ids, rarity, power, prices and hatch odds remain in their original configs.
local D = {}
local function d(species, theme, accent, size, feature)
	return {Species=species, Theme=theme, Accent=Color3.fromRGB(unpack(accent)), Size=size or 3.6, Feature=feature}
end
D.List = {
	Doggy=d("Dog","Meadow",{255,232,182}), Kitty=d("Cat","Meadow",{255,220,192}),
	Bunny=d("Bunny","Meadow",{255,160,190}), Fox=d("Fox","Meadow",{255,244,218}),
	Unicorn=d("Unicorn","Prism",{125,230,255},4.4), DemiDog=d("Dog","Royal",{255,105,90},5,"Crown"),
	Bear=d("Bear","Meadow",{243,199,139}), Gorilla=d("Gorilla","Stone",{164,169,194},4),
	Wolf=d("Wolf","Meadow",{221,234,255},3.9), Lion=d("Lion","Royal",{255,227,121},4.3),
	GoldenGorilla=d("Gorilla","Gold",{255,244,166},11,"Crown"), Cerberus=d("Cerberus","Ember",{255,120,55},6),
	GummyBear=d("Bear","Candy",{255,220,72}), LollipopCat=d("Cat","Candy",{105,242,232},3.8,"Lollipop"),
	CupcakePup=d("Dog","Candy",{255,246,225},4,"Cupcake"), CandyDragon=d("Dragon","Candy",{105,239,230},4.8),
	SugarDemon=d("Demon","Candy",{255,209,83},5), RainbowUnicorn=d("Unicorn","Prism",{169,132,255},6,"Wings"),
	ChocoBunny=d("Bunny","Candy",{255,210,170}), MarshmallowSheep=d("Sheep","Candy",{255,154,199},3.9),
	DonutDog=d("Dog","Candy",{255,96,177},4,"Donut"), CottonCandyFairy=d("Fairy","Candy",{255,144,226},4.8),
	CandyKing=d("Lion","Candy",{255,229,98},6,"Crown"), CandyHydra=d("Hydra","Candy",{111,255,219},14),
	Penguin=d("Penguin","Frost",{255,200,68}), SnowFox=d("Fox","Frost",{147,213,255}),
	IceWolf=d("Wolf","Frost",{180,250,255},4.2), Yeti=d("Yeti","Frost",{116,191,240},4.7),
	FrostPhoenix=d("Phoenix","Frost",{219,254,255},6), IceHydra=d("Hydra","Frost",{224,255,255},8),
	SnowOwl=d("Owl","Frost",{163,188,235}), Walrus=d("Walrus","Frost",{255,243,208},4.2),
	PolarBear=d("Bear","Frost",{162,220,244},4.4), IceGolem=d("Golem","Frost",{211,255,255},5),
	FrostTitan=d("Golem","Frost",{217,255,255},12,"Crown"), BlizzardDragon=d("Dragon","Frost",{207,255,255},8),
	MagmaSlime=d("Slime","Ember",{255,223,63}), FireBat=d("Bat","Ember",{255,180,68},4.2),
	LavaHound=d("Dog","Ember",{255,206,58},4.4), FlameGolem=d("Golem","Ember",{255,220,79},5.3),
	Hellhound=d("Wolf","Ember",{255,129,29},6), ThreeHeadedDragon=d("Hydra","Ember",{255,216,66},15),
	EmberFox=d("Fox","Ember",{255,222,113}), ObsidianTurtle=d("Turtle","Ember",{255,124,36},4.1),
	PhoenixChick=d("Phoenix","Ember",{255,235,115},4.4), MagmaTitan=d("Golem","Ember",{255,190,57},7),
	InfernoDemon=d("Demon","Ember",{255,192,56},7), DemonKing=d("Demon","Ember",{255,182,47},17,"Crown"),
	Alien=d("Alien","Cosmic",{189,131,255}), UFOCat=d("Cat","Cosmic",{112,255,221},4.6,"Saucer"),
	StarWolf=d("Wolf","Cosmic",{255,224,108},4.8), NebulaDragon=d("Dragon","Cosmic",{118,255,237},6),
	VoidTitan=d("Golem","Void",{199,119,255},13), CosmicGod=d("Alien","Cosmic",{135,219,255},19,"Halo"),
	MoonBunny=d("Bunny","Cosmic",{157,185,255},4.4), AstroDog=d("Dog","Cosmic",{100,224,255},4.8,"Helmet"),
	MeteorGolem=d("Golem","Cosmic",{255,163,95},5.8), BlackHoleBeast=d("Demon","Void",{181,107,255},7,"Halo"),
	GalaxyLeviathan=d("Dragon","Cosmic",{109,255,231},15), InfinityDragon=d("Dragon","Prism",{143,255,231},22,"Halo"),
	DiamondDog=d("Dog","Frost",{241,255,255},5,"Crown"), RainbowDragon=d("Dragon","Prism",{145,255,227},7),
	GoldenCerberus=d("Cerberus","Gold",{255,249,183},16,"Crown"),
}
D.Themes = {
	Meadow={Color3.fromRGB(157,242,167),"sparkles_main.dds"}, Stone={Color3.fromRGB(178,195,227),"sparkles_main.dds"},
	Royal={Color3.fromRGB(255,222,106),"sparkles_main.dds"}, Gold={Color3.fromRGB(255,216,74),"sparkles_main.dds"},
	Candy={Color3.fromRGB(255,133,214),"sparkles_main.dds"}, Prism={Color3.fromRGB(133,255,229),"sparkles_main.dds"},
	Frost={Color3.fromRGB(156,226,255),"sparkles_main.dds"}, Ember={Color3.fromRGB(255,160,61),"fire_main.dds"},
	Cosmic={Color3.fromRGB(179,143,255),"sparkles_main.dds"}, Void={Color3.fromRGB(174,101,255),"sparkles_main.dds"},
}
return D

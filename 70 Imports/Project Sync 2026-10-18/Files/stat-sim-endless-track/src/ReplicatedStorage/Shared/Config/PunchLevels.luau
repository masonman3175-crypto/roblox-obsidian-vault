-- Sixty original destinations. Past the catalog, seeded echo realms keep advancing.
local Levels={}
-- id, title, floor RGB, primary RGB, accent RGB, handcrafted landmark, dressing family
Levels.List={
 {"glove","Glove Grove",{115,215,133},{255,102,132},{255,224,104},"glove","forest"},
 {"mushroom","Mushroom Megalopolis",{157,213,150},{244,126,208},{182,157,255},"mushroom","forest"},
 {"boardwalk","Bubblegum Boardwalk",{255,184,215},{254,99,178},{111,235,239},"coaster","candy"},
 {"desert","Doodle Desert",{247,214,139},{245,157,98},{114,235,194},"pyramid","desert"},
 {"origami","Origami Oasis",{165,235,212},{250,240,205},{251,144,193},"origami","paper"},
 {"cactus","Cactus Carnival",{255,210,139},{118,207,144},{253,121,190},"cactus","desert"},
 {"snowcone","Snowcone Summit",{210,241,255},{147,210,252},{255,146,188},"snowcone","ice"},
 {"pinball","Polar Pinball",{179,231,247},{112,169,247},{255,225,110},"pinball","ice"},
 {"aurora","Aurora Observatory",{167,185,235},{140,238,221},{205,145,248},"observatory","space"},
 {"volcano","Toasted Volcano",{119,100,139},{249,131,93},{255,215,101},"volcano","lava"},
 {"laundry","Lava Laundry",{207,135,126},{255,153,83},{142,222,239},"washer","lava"},
 {"clockwork","Clockwork Canyon",{217,180,143},{181,133,216},{255,215,119},"clock","mechanical"},
 {"comet","Candy Comet",{237,168,227},{248,130,190},{142,224,255},"comet","candy"},
 {"mallow","Marshmallow Monastery",{249,211,226},{255,248,226},{188,160,239},"monastery","candy"},
 {"galleon","Gummy Galleon",{136,218,238},{250,147,176},{255,224,117},"ship","ocean"},
 {"cheese","Moon Cheese Mine",{201,204,223},{255,224,100},{154,172,247},"cheese","space"},
 {"ramen","Rocket Ramen",{236,198,154},{239,135,119},{148,233,208},"ramen","food"},
 {"skate","Starlight Skatepark",{158,165,226},{184,149,251},{255,217,117},"skatepark","space"},
 {"noodle","Neon Noodle District",{131,153,204},{255,122,198},{111,238,226},"pagoda","city"},
 {"lantern","Lantern Lagoon",{119,213,209},{255,190,127},{244,138,210},"lantern","ocean"},
 {"bamboo","Bamboo Beatforest",{158,224,160},{113,188,135},{255,219,124},"bamboo","forest"},
 {"paperport","Pirate Paperport",{170,221,239},{255,246,207},{252,149,152},"paperboat","paper"},
 {"coral","Coral Carousel",{144,220,239},{250,153,180},{240,221,134},"carousel","ocean"},
 {"jelly","Jellyfish Junction",{153,196,240},{205,150,244},{143,243,223},"jellyfish","ocean"},
 {"sunken","Sunken Arcade",{121,198,213},{239,152,224},{255,217,123},"arcade","ocean"},
 {"thunder","Thundercloud Transit",{173,181,227},{255,222,103},{179,230,255},"cloudtrain","sky"},
 {"repair","Rainbow Repairyard",{210,192,244},{250,158,210},{136,235,196},"crane","sky"},
 {"kite","Kite Kingdom",{196,231,251},{246,143,183},{255,223,113},"kite","sky"},
 {"bath","Bubble Bath Bay",{170,227,241},{253,245,228},{255,220,113},"bathtub","ocean"},
 {"pancake","Pancake Plateau",{237,207,160},{232,167,104},{255,229,134},"pancake","food"},
 {"waffle","Waffle Workshop",{229,201,161},{211,154,99},{244,198,113},"waffle","food"},
 {"teacup","Teacup Tornado",{227,195,234},{250,247,219},{243,141,193},"teacup","food"},
 {"toys","Toyblock Titans",{148,215,235},{244,129,156},{255,224,119},"robot","toy"},
 {"duck","Rubber Duck Dynasty",{187,225,189},{255,218,83},{250,152,195},"duck","toy"},
 {"plush","Plushie Playropolis",{246,188,219},{208,165,239},{255,237,176},"bear","toy"},
 {"bonsai","Bonsai Moon Garden",{161,212,205},{135,182,170},{244,212,173},"bonsai","forest"},
 {"cathedral","Crystal Cathedral",{178,207,241},{191,155,245},{138,242,233},"cathedral","crystal"},
 {"post","Prism Post Office",{203,191,244},{247,164,205},{255,227,133},"envelope","paper"},
 {"circuit","Circuit City",{135,181,210},{123,237,215},{244,162,230},"circuit","mechanical"},
 {"afterhours","Arcade Afterhours",{155,143,200},{240,137,217},{124,225,240},"joystick","city"},
 {"hologram","Hologram Highway",{145,179,220},{133,233,241},{233,165,247},"hologram","city"},
 {"glitch","Glitch Greenhouse",{174,219,172},{196,141,235},{124,241,209},"greenhouse","mechanical"},
 {"dino","Dino Disco",{182,215,146},{141,211,167},{240,155,220},"dinosaur","forest"},
 {"fossil","Fossil Ferris",{219,189,152},{250,238,205},{184,155,222},"ferris","desert"},
 {"dragon","Dragonfruit Dojo",{238,184,207},{244,128,176},{151,217,148},"dragon","forest"},
 {"firefly","Firefly Fairground",{145,171,190},{255,226,129},{160,225,202},"firefly","forest"},
 {"pumpkin","Pumpkin Planetarium",{192,164,205},{250,171,94},{163,223,203},"pumpkin","space"},
 {"ghost","Ghosttoast Hotel",{182,177,218},{255,240,203},{238,165,186},"hotel","toy"},
 {"marble","Moonlit Marbleworks",{167,191,224},{183,213,249},{248,190,220},"marble","crystal"},
 {"chess","Chessboard Cosmos",{173,177,213},{249,239,221},{130,124,174},"chess","space"},
 {"saturn","Saturn Station",{160,163,214},{241,204,145},{195,145,244},"saturn","space"},
 {"library","Gravity Library",{194,172,223},{241,191,143},{152,224,221},"library","paper"},
 {"bowling","Blackhole Bowling",{130,128,186},{226,171,239},{139,231,232},"bowling","space"},
 {"quilt","Quantum Quilt",{214,180,221},{245,174,199},{157,225,200},"quilt","paper"},
 {"aquarium","Dream Aquarium",{146,212,236},{170,233,234},{249,184,222},"aquarium","ocean"},
 {"castle","Cloud Castle",{200,218,248},{239,237,255},{240,181,225},"castle","sky"},
 {"icecream","Infinity Icecream",{235,195,222},{255,207,152},{183,235,205},"icecream","food"},
 {"symphony","Supernova Symphony",{180,164,224},{249,216,129},{248,154,216},"symphony","space"},
 {"cosmic","Cosmic Origami",{194,185,235},{161,225,238},{251,187,217},"cosmic","paper"},
 {"beyond","Beyond The Punch",{164,159,223},{245,188,239},{255,225,133},"beyond","space"},
}
Levels.Count=#Levels.List
function Levels.Get(stage)
 assert(type(stage)=="number" and stage==stage and stage>=1 and stage%1==0 and stage<math.huge,"Invalid stage")
 local index=(stage-1)%Levels.Count+1
 local cycle=math.floor((stage-1)/Levels.Count)
 local s=Levels.List[index]
 local function color(t,shift)
  local base=Color3.fromRGB(table.unpack(t))
  if cycle==0 then return base end
  local h,sat,v=base:ToHSV();return Color3.fromHSV((h+cycle*.071+shift)%1,sat,v)
 end
 return {id=s[1],name=s[2]..(if cycle>0 then " / Echo "..(cycle+1) else ""),ground=color(s[3],0),
  color=color(s[4],0),accent=color(s[5],.03),kind=s[6],family=s[7],stage=stage,index=index,cycle=cycle,
  seed=(stage*7919)%2147483647}
end
return Levels


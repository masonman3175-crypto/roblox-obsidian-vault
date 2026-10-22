-- Build 02: hand-authored toybox arcade, deliberately fast early alpha balance.
local Config = {}
Config.Schema = 1
Config.Build = "02 - TOYBOX ARCADE"
Config.StudioSessionOnly = true -- Never touches live player data from Studio.
Config.PurchasesEnabled = false
Config.MaxPlayers = 4
Config.Storage = 40
Config.ShelfSlots = 8
Config.FreeAttempts = 3
Config.AttemptRefillSeconds = 12
Config.RoundSeconds = 25
Config.DropSeconds = 2.6
Config.PlotSpacing = 190
Config.Bounds = {halfWidth=70, back=-94, front=105}
Config.Machines = {
    {id="rusty", name="Rusty Claw", short="RUSTY", cost=0, color={233,157,92}, skin="workshop", mascot="duck", pool={"duck","mochi","frog"}},
    {id="classic", name="Classic Arcade", short="CLASSIC", cost=250, color={249,78,117}, skin="classic", mascot="mochi", pool={"mochi","frog","dino","cat","star"}},
    {id="candy", name="Candy Cloud", short="CANDY", cost=600, color={255,156,212}, skin="cloud", mascot="dino", pool={"mochi","dino","bloom"}},
    {id="pond", name="Frog Pond", short="POND", cost=1200, color={126,224,151}, skin="frog", mascot="frog", pool={"frog","bloom","bee"}},
    {id="bloom", name="Bunny Bloom", short="BLOOM", cost=2200, color={232,175,255}, skin="bunny", mascot="bloom", pool={"mochi","bloom","bee"}},
    {id="shark", name="Shark Splash", short="SHARK", cost=3800, color={74,172,244}, skin="shark", mascot="shark", pool={"frog","shark","pearl"}},
    {id="lucky", name="Lucky Cat", short="LUCKY", cost=6000, color={255,202,116}, skin="cat", mascot="cat", pool={"cat","bee","mimic"}},
    {id="honey", name="Honey Hive", short="HONEY", cost=9000, color={255,209,74}, skin="hive", mascot="bee", pool={"bee","bloom","leaf"}},
    {id="dino", name="Dino Den", short="DINO", cost=14000, color={147,211,107}, skin="dino", mascot="tricera", pool={"dino","tricera","leaf"}},
    {id="rocket", name="Rocket Rally", short="ROCKET", cost=21000, color={250,119,107}, skin="rocket", mascot="rocket", pool={"cat","rocket","ufo"}},
    {id="soda", name="Cherry Soda", short="SODA", cost=32000, color={255,109,160}, skin="soda", mascot="cherry", pool={"bloom","cherry","pixel"}},
    {id="ufo", name="Cosmic UFO", short="UFO", cost=48000, color={111,226,210}, skin="ufo", mascot="ufo", pool={"star","ufo","rocket"}},
    {id="pearl", name="Ocean Pearl", short="PEARL", cost=72000, color={168,206,255}, skin="shell", mascot="pearl", pool={"shark","pearl","penguin"}},
    {id="treasure", name="Treasure Chest", short="TREASURE", cost=110000, color={198,132,82}, skin="treasure", mascot="mimic", pool={"mimic","lion","cherry"}},
    {id="pixel", name="Pixel Party", short="PIXEL", cost=165000, color={157,130,255}, skin="pixel", mascot="pixel", pool={"pixel","robot","unicorn"}},
    {id="ice", name="Ice Palace", short="ICE", cost=250000, color={129,231,255}, skin="ice", mascot="penguin", pool={"penguin","gemfox","pearl"}},
    {id="magma", name="Magma Forge", short="MAGMA", cost=380000, color={255,129,76}, skin="magma", mascot="ember", pool={"ember","lion","rocket"}},
    {id="jungle", name="Jungle Ruins", short="JUNGLE", cost=570000, color={100,187,135}, skin="jungle", mascot="leaf", pool={"leaf","tricera","gemfox"}},
    {id="rainbow", name="Rainbow Parade", short="RAINBOW", cost=850000, color={255,145,212}, skin="rainbow", mascot="unicorn", pool={"unicorn","star","gemfox"}},
    {id="royal", name="Golden Crown", short="ROYAL", cost=1300000, color={255,213,81}, skin="crown", mascot="lion", pool={"lion","unicorn","mimic"}},
    {id="diamond", name="Diamond Vault", short="DIAMOND", cost=2000000, color={121,199,255}, skin="diamond", mascot="gemfox", pool={"gemfox","penguin","robot"}},
    {id="galaxy", name="Galaxy Gate", short="GALAXY", cost=3000000, color={153,128,241}, skin="galaxy", mascot="star", pool={"star","ufo","voidbat"}},
    {id="cyber", name="Cyber Circuit", short="CYBER", cost=4500000, color={81,229,203}, skin="circuit", mascot="robot", pool={"robot","pixel","voidbat"}},
    {id="void", name="Void Reactor", short="VOID", cost=6800000, color={121,92,201}, skin="void", mascot="voidbat", pool={"voidbat","star","infinity"}},
    {id="infinity", name="Infinity Carnival", short="INFINITY", cost=10000000, color={247,164,238}, skin="carnival", mascot="infinity", pool={"infinity","unicorn","voidbat"}},
}
-- Five deliberately laid-out gallery rows, front to back. Aisles are 34 studs deep.
for i,machine in ipairs(Config.Machines) do
    machine.position=({{-44,0,64},{-22,0,64},{0,0,64},{22,0,64},{44,0,64},
        {-44,0,30},{-22,0,30},{0,0,30},{22,0,30},{44,0,30},
        {-44,0,-4},{-22,0,-4},{0,0,-4},{22,0,-4},{44,0,-4},
        {-44,0,-38},{-22,0,-38},{0,0,-38},{22,0,-38},{44,0,-38},
        {-44,0,-72},{-22,0,-72},{0,0,-72},{22,0,-72},{44,0,-72}})[i]
end
Config.Plushies = {
    {id="duck", name="Goofy Duck", rarity="Common", income=5, weight=60, color={255,219,79}, shape="duck"},
    {id="mochi", name="Mochi Bunny", rarity="Uncommon", income=8, weight=30, color={255,171,209}, shape="bunny"},
    {id="frog", name="Disco Frog", rarity="Rare", income=14, weight=10, color={113,239,176}, shape="frog"},
    {id="dino", name="Bubblegum Dino", rarity="Epic", income=24, weight=10, color={177,137,255}, shape="dino"},
    {id="cat", name="Space Cat", rarity="Legendary", income=40, weight=4, color={109,218,255}, shape="cat"},
    {id="star", name="Pocket Supernova", rarity="Mythical", income=65, weight=1, color={255,139,96}, shape="star"},
    {id="bloom", name="Petal Puff", rarity="Rare", income=18, weight=18, color={239,183,255}, shape="bunny"},
    {id="shark", name="Snack Shark", rarity="Rare", income=25, weight=20, color={103,183,250}, shape="shark"},
    {id="bee", name="Bumble Bean", rarity="Epic", income=35, weight=12, color={255,216,82}, shape="bee"},
    {id="tricera", name="Tiny Tricera", rarity="Epic", income=50, weight=12, color={157,224,143}, shape="dino"},
    {id="rocket", name="Booster Bean", rarity="Legendary", income=75, weight=10, color={250,141,122}, shape="cat"},
    {id="cherry", name="Cherry Cheeks", rarity="Epic", income=100, weight=12, color={255,128,171}, shape="cherry"},
    {id="ufo", name="Sleepy Saucer", rarity="Legendary", income=150, weight=8, color={117,232,203}, shape="ufo"},
    {id="pearl", name="Pearl Pudding", rarity="Legendary", income=220, weight=10, color={193,210,255}, shape="shell"},
    {id="mimic", name="Treasure Tater", rarity="Legendary", income=330, weight=8, color={225,163,87}, shape="chest"},
    {id="pixel", name="Pixel Pancake", rarity="Legendary", income=500, weight=10, color={185,155,255}, shape="robot"},
    {id="penguin", name="Frosty Waddle", rarity="Legendary", income=750, weight=10, color={151,227,255}, shape="penguin"},
    {id="ember", name="Ember Dumpling", rarity="Mythical", income=1100, weight=8, color={255,151,98}, shape="dino"},
    {id="leaf", name="Leafy Loaf", rarity="Mythical", income=1700, weight=8, color={135,209,126}, shape="frog"},
    {id="unicorn", name="Prism Pony", rarity="Mythical", income=2500, weight=6, color={255,183,232}, shape="unicorn"},
    {id="lion", name="Royal Roar", rarity="Mythical", income=3800, weight=8, color={255,211,99}, shape="lion"},
    {id="gemfox", name="Crystal Foxlet", rarity="Secret", income=5600, weight=5, color={154,209,255}, shape="cat"},
    {id="robot", name="Circuit Sprout", rarity="Secret", income=8500, weight=6, color={113,234,205}, shape="robot"},
    {id="voidbat", name="Midnight Marshmallow", rarity="Divine", income=13000, weight=3, color={168,133,230}, shape="bat"},
    {id="infinity", name="Infinity Sundae", rarity="Infinity", income=20000, weight=2, color={255,189,234}, shape="unicorn"},
}
Config.Upgrades = {
    speed={name="Servo speed", cost=60, max=4, description="Faster aim movement. Earned coins only."},
    shelves={name="Shelf multiplier", cost=90, max=4, description="+25% display income per level."},
}
Config.Catalog = {
    {id="rainbow_skin", name="Rainbow cabinet skin", kind="Pass", productId=0, benefit="One cosmetic cabinet skin. No random reward."},
    {id="confetti", name="Confetti party", kind="Product", productId=0, benefit="One deterministic cosmetic celebration."},
    {id="nameplate", name="VIP nameplate", kind="Pass", productId=0, benefit="One cosmetic nameplate. No gameplay odds change."},
}
Config.FutureTiers = {}
function Config.plushie(id)
    for _, item in ipairs(Config.Plushies) do if item.id == id then return item end end
    return nil
end
return Config

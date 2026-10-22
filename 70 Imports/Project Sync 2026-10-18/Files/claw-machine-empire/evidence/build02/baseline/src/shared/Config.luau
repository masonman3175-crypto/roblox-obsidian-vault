-- Build 01: deliberately fast alpha balance, not launch pricing.
local Config = {}
Config.Schema = 1
Config.Build = "01 - FIRST CATCH"
Config.StudioSessionOnly = true -- Never touches live player data from Studio.
Config.PurchasesEnabled = false
Config.MaxPlayers = 4
Config.Storage = 40
Config.ShelfSlots = 8
Config.FreeAttempts = 3
Config.AttemptRefillSeconds = 12
Config.RoundSeconds = 25
Config.DropSeconds = 2.6
Config.Machines = {
    {id="rusty", name="Rusty Claw", cost=0, color={255,161,87}, minTier=1, maxTier=3},
    {id="classic", name="Classic Arcade", cost=250, color={255,81,135}, minTier=2, maxTier=6},
}
Config.Plushies = {
    {id="duck", name="Goofy Duck", rarity="Common", income=5, weight=60, color={255,219,79}, shape="duck"},
    {id="mochi", name="Mochi Bunny", rarity="Uncommon", income=8, weight=30, color={255,171,209}, shape="bunny"},
    {id="frog", name="Disco Frog", rarity="Rare", income=14, weight=10, color={113,239,176}, shape="frog"},
    {id="dino", name="Bubblegum Dino", rarity="Epic", income=24, weight=10, color={177,137,255}, shape="dino"},
    {id="cat", name="Space Cat", rarity="Legendary", income=40, weight=4, color={109,218,255}, shape="cat"},
    {id="star", name="Pocket Supernova", rarity="Mythical", income=65, weight=1, color={255,139,96}, shape="star"},
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
Config.FutureTiers = {"Neon", "Golden", "Diamond", "Rainbow", "Galaxy", "Quantum", "Void", "Infinity"}
function Config.plushie(id)
    for _, item in ipairs(Config.Plushies) do if item.id == id then return item end end
    return nil
end
return Config

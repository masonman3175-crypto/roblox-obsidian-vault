local C = {}
C.Version = 1
C.RollCost = 15
C.RebirthBase = 500
C.Boss = {Health=900, Duration=100, Rest=35, Radius=58}
C.Zones = {
 {Name="FOOD TOWN", Size=0, Coins=0, Color=Color3.fromRGB(255,166,66)},
 {Name="TRAINING GROUNDS", Size=35, Coins=30, Color=Color3.fromRGB(55,215,220)},
 {Name="GIANT FOOD CITY", Size=120, Coins=80, Color=Color3.fromRGB(255,106,145)},
 {Name="COSMIC ARENA", Size=280, Coins=160, Color=Color3.fromRGB(150,105,255)},
 {Name="COLOSSAL WORLD", Size=650, Coins=350, Color=Color3.fromRGB(255,216,85)},
}
C.Rarities = {{Name="COMMON",Weight=60,Color=Color3.fromRGB(175,212,235)}, {Name="RARE",Weight=25,Color=Color3.fromRGB(50,185,255)}, {Name="EPIC",Weight=11,Color=Color3.fromRGB(190,100,255)}, {Name="LEGENDARY",Weight=3.5,Color=Color3.fromRGB(255,199,60)}, {Name="MYTHIC",Weight=.5,Color=Color3.fromRGB(255,85,155)}}
C.Powers = {
 {Id="jump",Name="Super Jump",Rarity=1,Kind="jump",Cooldown=8,Icon="↑",Description="Launch upward. Land safely and reach training platforms."},
 {Id="speed",Name="Speed Burst",Rarity=1,Kind="speed",Cooldown=12,Icon="»",Description="Run faster for six seconds."},
 {Id="punch",Name="Energy Punch",Rarity=1,Kind="blast",Cooldown=5,Damage=25,Radius=18,Icon="✦",Description="A close-range pulse that knocks training props away."},
 {Id="dash",Name="Dash",Rarity=1,Kind="dash",Cooldown=6,Icon="➜",Description="Burst forward with a bright energy trail."},
 {Id="lightning",Name="Lightning Dash",Rarity=2,Kind="dash",Cooldown=7,Damage=35,Radius=24,Icon="ϟ",Description="An electric dash that strikes nearby arena targets."},
 {Id="gravity",Name="Gravity Flip",Rarity=2,Kind="gravity",Cooldown=16,Damage=35,Radius=30,Icon="↕",Description="Brief personal gravity reversal inside the boss arena."},
 {Id="wave",Name="Energy Wave",Rarity=2,Kind="wave",Cooldown=10,Damage=45,Radius=45,Icon="≈",Description="Send a forward energy wave through the arena."},
 {Id="clone",Name="Shadow Clone",Rarity=2,Kind="clone",Cooldown=14,Icon="◈",Description="Leave three short-lived glowing visual decoys."},
 {Id="meteor",Name="Meteor Slam",Rarity=3,Kind="slam",Cooldown=15,Damage=75,Radius=35,Icon="▼",Description="Rise, then slam down in a telegraphed shockwave."},
 {Id="dragon",Name="Dragon Aura",Rarity=3,Kind="aura",Cooldown=18,Damage=65,Radius=30,Icon="♨",Description="A fiery aura and a strong arena energy pulse."},
 {Id="time",Name="Time Bubble",Rarity=3,Kind="time",Cooldown=22,Damage=35,Radius=40,Icon="◷",Description="Extend boss attack warnings for six seconds."},
 {Id="titan",Name="Titan Mode",Rarity=3,Kind="titan",Cooldown=25,Damage=70,Radius=35,Icon="▲",Description="Grow temporarily for eight seconds. No player damage."},
 {Id="cosmic",Name="Cosmic Breaker",Rarity=4,Kind="blast",Cooldown=22,Damage=110,Radius=50,Icon="✺",Description="A huge violet energy explosion in the arena."},
 {Id="thunder",Name="Thunder God Mode",Rarity=4,Kind="speed",Cooldown=24,Damage=95,Radius=45,Icon="ϟ",Description="Lightning aura, boosted movement, and an arena strike."},
 {Id="glitch",Name="Reality Glitch",Rarity=4,Kind="glitch",Cooldown=24,Damage=110,Radius=48,Icon="▧",Description="Glitch the arena props and unleash a colored pulse."},
 {Id="colossal",Name="Colossal Awakening",Rarity=4,Kind="titan",Cooldown=28,Damage=120,Radius=48,Icon="◆",Description="A dramatic giant transformation for eight seconds."},
 {Id="universe",Name="Universe Burst",Rarity=5,Kind="blast",Cooldown=30,Damage=160,Radius=55,Icon="✹",Description="A brilliant arena-wide burst. Never damages other players."},
 {Id="infinite",Name="Infinite Growth",Rarity=5,Kind="growth",Cooldown=40,Icon="∞",Description="Triple automatic and food growth for twelve seconds."},
 {Id="celestial",Name="Celestial Titan",Rarity=5,Kind="titan",Cooldown=32,Damage=160,Radius=55,Icon="★",Description="Become a glowing cosmic giant for eight seconds."},
}
C.Cosmetics = {
 {Id="mint",Name="Mint Aura",Cost=70,Kind="Aura",Color=Color3.fromRGB(60,255,185)},
 {Id="gold",Name="Golden Aura",Cost=150,Kind="Aura",Color=Color3.fromRGB(255,206,70)},
 {Id="violet",Name="Violet Aura",Cost=70,Kind="Aura",Color=Color3.fromRGB(170,90,255)},
 {Id="burger",Name="Burger Crown",Cost=120,Kind="Hat",Color=Color3.fromRGB(245,163,62)},
 {Id="neon",Name="Neon Trail",Cost=90,Kind="Trail",Color=Color3.fromRGB(66,210,255)},
 {Id="dance",Name="Victory Spin",Cost=50,Kind="Emote",Color=Color3.fromRGB(255,120,190)},
 {Id="vip",Name="Chill Lounge Pass",Cost=250,Kind="Lounge",Color=Color3.fromRGB(255,218,90)},
}
function C.Power(id) for _,p in ipairs(C.Powers) do if p.Id==id then return p end end end
function C.RebirthCost(n) return C.RebirthBase*(n+1) end
function C.Scale(size) return math.clamp(.8+math.log(1+size)/3,.8,4) end
function C.Multiplier(n) return 1+n*.5 end
function C.Roll(rng)
 local x=rng:NextNumber(0,100); local rarity=1
 for i,r in ipairs(C.Rarities) do x-=r.Weight; if x<=0 then rarity=i; break end end
 local pool={} for _,p in ipairs(C.Powers) do if p.Rarity==rarity then table.insert(pool,p) end end
 return pool[rng:NextInteger(1,#pool)]
end
return C

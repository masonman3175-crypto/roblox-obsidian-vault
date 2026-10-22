"""Original cartoon pictograms for the Robux shop and HUD (no text badges)."""
from pathlib import Path
import json
import math
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "icons"
OUT.mkdir(parents=True, exist_ok=True)

KEYS = [
    "Passes", "Boosts", "Coins", "Eggs", "Gym", "Rebirth", "Pets", "Shop", "Train",
    "Double", "AutoTrain", "VIP", "AutoPunch", "DoubleCoins", "FastWalk", "TripleHatch",
    "AutoHatch", "Lucky", "PetSlots", "GymVIP", "GymMega", "GymAdmin", "StrengthSmall",
    "StrengthMedium", "StrengthLarge", "CoinsSmall", "CoinsMedium", "CoinsLarge", "Boost",
    "CoinBoost", "LuckBoost", "Level", "RebirthSkip", "WorldSkip", "MegaEgg", "UltraEgg",
]
KIND = {
    "Passes":"ticket", "Boosts":"bolt", "Coins":"coins", "Eggs":"egg", "Gym":"dumbbell",
    "Rebirth":"rebirth", "Pets":"paw", "Shop":"bag", "Train":"fist", "Double":"dumbbell",
    "AutoTrain":"robot", "VIP":"crown", "AutoPunch":"fist", "DoubleCoins":"coins",
    "FastWalk":"shoe", "TripleHatch":"egg", "AutoHatch":"egg", "Lucky":"clover",
    "PetSlots":"paw", "GymVIP":"dumbbell", "GymMega":"dumbbell", "GymAdmin":"dumbbell",
    "StrengthSmall":"fist", "StrengthMedium":"fist", "StrengthLarge":"fist",
    "CoinsSmall":"coins", "CoinsMedium":"coins", "CoinsLarge":"coins", "Boost":"bolt",
    "CoinBoost":"coins", "LuckBoost":"clover", "Level":"level", "RebirthSkip":"rebirth",
    "WorldSkip":"portal", "MegaEgg":"egg", "UltraEgg":"egg",
}
COLORS = {
    "ticket":"#b886ff", "bolt":"#ffe04a", "coins":"#ffcc32", "egg":"#f7a0e6",
    "dumbbell":"#6dd9ff", "rebirth":"#fb8bc3", "paw":"#8cf07c", "bag":"#ff9a55",
    "fist":"#ffc985", "robot":"#83e4ff", "crown":"#ffe263", "shoe":"#92dcff",
    "clover":"#8bf37b", "level":"#9ef092", "portal":"#b596ff",
}
DARK = "#272238"

def draw_icon(key: str) -> Image.Image:
    kind = KIND[key]
    im = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    color = COLORS[kind]
    if kind == "coins":
        for x, y in ((44,125),(81,94),(122,122)):
            d.ellipse((x,y,x+92,y+70), fill="#c87e22", outline=DARK, width=9)
            d.ellipse((x,y-18,x+92,y+52), fill=color, outline=DARK, width=9)
            d.arc((x+22,y-3,x+70,y+38), 200, 330, fill="#fff5b0", width=8)
    elif kind == "egg":
        d.ellipse((57,26,199,224), fill=color, outline=DARK, width=13)
        d.ellipse((83,48,122,102), fill="#fff5fd")
        d.arc((73,63,184,204), 195, 340, fill="#fffdff", width=8)
        if key in ("MegaEgg", "UltraEgg", "TripleHatch"):
            d.polygon([(60,147),(89,135),(112,153),(137,132),(164,149),(197,138),(193,175),(66,175)], fill="#8b51d3", outline=DARK)
            d.line([(61,148),(89,136),(112,154),(137,133),(164,150),(197,139)], fill=DARK, width=9, joint="curve")
        if key == "UltraEgg":
            for x,y in ((52,77),(196,72),(115,19)):
                d.polygon([(x,y-16),(x+5,y-4),(x+17,y),(x+5,y+5),(x,y+17),(x-5,y+5),(x-17,y),(x-5,y-4)], fill="#fff088", outline=DARK)
    elif kind == "dumbbell":
        d.line((58,131,198,131), fill=DARK, width=33)
        d.line((58,128,198,128), fill="#e6f5ff", width=15)
        for x in (43,80,170,207):
            d.rounded_rectangle((x-16,76,x+16,183), radius=10, fill=color, outline=DARK, width=9)
        if key in ("GymMega", "GymAdmin"):
            d.polygon([(128,48),(140,81),(174,81),(146,101),(157,133),(128,113),(99,133),(110,101),(82,81),(116,81)], fill="#ffe54a", outline=DARK)
    elif kind == "fist":
        d.rounded_rectangle((64,104,190,205), radius=26, fill=color, outline=DARK, width=11)
        for x in (63,94,125,156):
            d.rounded_rectangle((x,60,x+38,132), radius=17, fill=color, outline=DARK, width=9)
        d.rounded_rectangle((43,118,99,164), radius=20, fill=color, outline=DARK, width=9)
        d.line((63,203,191,203), fill="#fff2d7", width=10)
        if key == "AutoPunch":
            for y in (98,142,186): d.line((14,y,37,y), fill="#ffffff", width=11)
    elif kind == "bolt":
        d.polygon([(133,15),(58,141),(110,141),(85,242),(207,100),(149,100),(177,15)], fill=color, outline=DARK)
        d.line([(133,15),(58,141),(110,141),(85,242),(207,100),(149,100),(177,15),(133,15)], fill=DARK, width=13, joint="curve")
    elif kind == "paw":
        for x,y,r in ((49,73,22),(103,40,24),(161,43,24),(205,82,22)):
            d.ellipse((x-r,y-r,x+r,y+r), fill=color, outline=DARK, width=9)
        d.rounded_rectangle((55,111,200,220), radius=55, fill=color, outline=DARK, width=12)
        d.ellipse((87,150,112,178), fill="#ffffff")
    elif kind == "crown":
        d.polygon([(28,72),(73,120),(120,54),(176,120),(226,70),(202,187),(52,187)], fill=color, outline=DARK)
        d.line([(28,72),(73,120),(120,54),(176,120),(226,70),(202,187),(52,187),(28,72)], fill=DARK, width=13, joint="curve")
        for x,y in ((75,140),(128,130),(181,140)):
            d.ellipse((x-12,y-12,x+12,y+12),fill="#fa72bf",outline=DARK,width=5)
    elif kind == "robot":
        d.rounded_rectangle((39,78,216,205), radius=27, fill=color, outline=DARK, width=12)
        d.line((128,53,128,79), fill=DARK, width=12)
        d.ellipse((114,33,142,61), fill="#ffec60", outline=DARK, width=8)
        for x in (82,169): d.ellipse((x-17,117,x+17,151), fill="#15243e", outline="#ffffff", width=5)
        d.arc((88,132,172,186), 20, 160, fill=DARK, width=9)
    elif kind == "shoe":
        d.polygon([(24,136),(84,130),(105,71),(155,83),(166,136),(231,159),(231,206),(30,206)], fill=color, outline=DARK)
        d.line([(24,136),(84,130),(105,71),(155,83),(166,136),(231,159),(231,206),(30,206),(24,136)], fill=DARK, width=12)
        for y in (111,129): d.line((108,y,152,y+8), fill="#ffffff", width=9)
        d.line((35,186,226,186), fill="#ffffff", width=10)
    elif kind == "clover":
        for x,y in ((64,50),(135,50),(64,120),(135,120)):
            d.ellipse((x,y,x+65,y+65), fill=color, outline=DARK, width=10)
        d.line((128,145,165,224), fill=DARK, width=17)
        d.line((128,145,165,224), fill="#64c457", width=8)
    elif kind == "bag":
        d.rounded_rectangle((42,80,216,222), radius=20, fill=color, outline=DARK, width=12)
        d.arc((83,25,177,131), 185, 355, fill=DARK, width=13)
        d.ellipse((92,116,112,136), fill="#fff3bc")
        d.ellipse((146,116,166,136), fill="#fff3bc")
        d.arc((100,129,160,188), 20, 160, fill=DARK, width=8)
    elif kind == "ticket":
        d.rounded_rectangle((22,62,234,198), radius=22, fill=color, outline=DARK, width=12)
        d.ellipse((8,111,42,151), fill=(0,0,0,0), outline=DARK, width=8)
        d.ellipse((214,111,248,151), fill=(0,0,0,0), outline=DARK, width=8)
        d.line((154,68,154,191), fill="#fff4c5", width=7)
        d.polygon([(92,88),(103,112),(130,114),(109,133),(114,161),(92,148),(70,161),(75,133),(54,114),(81,112)], fill="#fff5ab", outline=DARK)
    elif kind == "rebirth":
        d.arc((42,41,215,214), 30, 260, fill=DARK, width=30)
        d.arc((42,41,215,214), 30, 260, fill=color, width=17)
        d.polygon([(34,83),(103,80),(73,135)], fill=color, outline=DARK)
        d.ellipse((99,94,158,153), fill="#ffe272", outline=DARK, width=10)
    elif kind == "level":
        d.polygon([(25,211),(25,164),(82,164),(82,117),(138,117),(138,69),(184,69),(184,211)], fill=color, outline=DARK)
        d.line([(25,211),(25,164),(82,164),(82,117),(138,117),(138,69),(184,69),(184,211),(25,211)], fill=DARK, width=11)
        d.polygon([(195,70),(224,70),(224,27),(251,90),(224,148),(224,107),(195,107)], fill="#fff0a5", outline=DARK)
    elif kind == "portal":
        d.ellipse((42,26,207,229), fill="#7160db", outline=DARK, width=13)
        d.ellipse((72,54,177,201), fill="#affcff", outline=DARK, width=10)
        d.polygon([(89,115),(142,115),(142,94),(190,133),(142,172),(142,151),(89,151)], fill="#ffea65", outline=DARK)
    return im

atlas = Image.new("RGBA", (6*128, 6*128), (0,0,0,0))
mapping = {}
for index, key in enumerate(KEYS):
    glyph = draw_icon(key)
    glyph.save(OUT / f"{key}.png")
    x, y = index % 6, index // 6
    atlas.alpha_composite(glyph.resize((128,128), Image.Resampling.LANCZOS), (x*128,y*128))
    mapping[key] = [x*128,y*128]
    tile = Image.new("RGBA", (512,512), (0,0,0,0))
    td = ImageDraw.Draw(tile)
    td.ellipse((24,24,488,488), fill=COLORS[KIND[key]], outline=DARK, width=25)
    td.ellipse((51,48,461,295), outline="#ffffff", width=12)
    tile.alpha_composite(glyph.resize((360,360), Image.Resampling.LANCZOS), (76,74))
    tile.save(OUT / f"thumbnail_{key}.png")
atlas.save(OUT / "shop_atlas.png")
(OUT / "atlas_mapping.json").write_text(json.dumps(mapping, indent=2), encoding="utf-8")
print(f"ICON PASS: {len(KEYS)} original pictures, atlas {atlas.size[0]}x{atlas.size[1]}")

#!/usr/bin/env python3
"""Fetch public Roblox experience icon and thumbnail PNG references.
Artwork belongs to its respective Roblox experience creators; check permissions before reuse.
"""
import json
import pathlib
import time
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
PLACES = {
    "brookhaven-rp": 4924922222,
    "adopt-me": 920587237,
    "blox-fruits": 2753915549,
    "murder-mystery-2": 142823291,
    "doors": 6516141723,
    "rivals": 17625359962,
    "dress-to-impress": 15101393044,
    "fisch": 16732694052,
    "the-strongest-battlegrounds": 10449761463,
    "tower-of-hell": 1962086868,
    "bedwars": 6872265039,
    "welcome-to-bloxburg": 185655149,
    "blade-ball": 13772394625,
    "pet-simulator-99": 8737899170,
    "tower-defense-simulator": 3260590327,
    "prison-life": 155615604,
    "grand-piece-online": 1730877806,
    "arsenal": 286090429,
    "bee-swarm-simulator": 1537690962,
    "evade": 9872472334,
    "jailbreak": 606849621,
    "piggy": 4623386862,
    "slap-battles": 6403373529,
    "rainbow-friends": 7991339063,
    "catalog-avatar-creator": 7041939546,
    "dragon-adventures": 3475397644,
    "volleyball-legends": 73956553001240,
}
UA = {"User-Agent": "roblox-ai-reference-catalog/1.0"}

def get_json(url):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=25) as res:
        return json.load(res)

def get_png(url, path):
    if not url or not url.startswith("https://"):
        return False
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=30) as res:
        data = res.read(5_000_000)
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return True

manifest = []
for slug, place_id in PLACES.items():
    item = {"game": slug, "place_id": place_id, "source": "https://www.roblox.com/games/" + str(place_id)}
    try:
        lookup = get_json("https://apis.roblox.com/universes/v1/places/" + str(place_id) + "/universe")
        universe = lookup.get("universeId")
        item["universe_id"] = universe
        if not universe:
            raise ValueError("Universe ID not found")
        icon_url = ("https://thumbnails.roblox.com/v1/games/icons?universeIds=" +
            str(universe) + "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false")
        icon_data = get_json(icon_url).get("data", [])
        if icon_data and icon_data[0].get("state") == "Completed":
            item["icon_saved"] = get_png(icon_data[0].get("imageUrl"), ROOT / "logos" / (slug + ".png"))
        thumbnail_url = ("https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=" +
            str(universe) + "&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false")
        blocks = get_json(thumbnail_url).get("data", [])
        thumbs = blocks[0].get("thumbnails", []) if blocks else []
        if thumbs and thumbs[0].get("state") == "Completed":
            item["thumbnail_saved"] = get_png(thumbs[0].get("imageUrl"), ROOT / "thumbnails" / (slug + ".png"))
    except Exception as exc:
        item["error"] = str(exc)[:250]
    manifest.append(item)
    print(item)
    time.sleep(0.5)

(ROOT / "roblox-image-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print("Saved", sum(bool(x.get("icon_saved")) + bool(x.get("thumbnail_saved")) for x in manifest), "PNG files")

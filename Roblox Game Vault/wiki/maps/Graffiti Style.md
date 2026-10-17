---
type: reference
area: maps
owner: shared
status: building
sources:
  - raw/2026-10-16-graffiti-ref-underpass-throwies.webp
  - raw/2026-10-16-graffiti-ref-white-piece.webp
  - raw/2026-10-16-graffiti-ref-writers-grid.webp
  - raw/2026-10-16-graffiti-generated/
updated: 2026-10-16
tags: [reference, graffiti, environment]
---

# Graffiti Style

Cade's call (2026-10-16): the first pass (font text like FRESH, NOVA) looked fake and too suburban. Graffiti has to look like real spray paint.

![[2026-10-16-graffiti-ref-underpass-throwies.webp]]
![[2026-10-16-graffiti-ref-white-piece.webp]]
![[2026-10-16-graffiti-ref-writers-grid.webp]]

## What real walls look like (from the refs)
- **Layers.** Big pieces on top of older tags. Walls are never one clean piece.
- **Throw-ups:** fat bubble letters, 1 or 2 flat colors, heavy black outline, sometimes a white outer line. Quick and rough.
- **Pieces:** wildstyle letters with gradient or banded fill, thick outline, 3D block shadow, white shine marks, drips, sometimes a cloud behind.
- **Characters:** cartoon heads (skull with big eyes and teeth, drippy blob with a cap) next to the letters.
- **Tags:** thin marker or spray handstyles everywhere, black, silver, teal, red.
- Paint is worn: speckled, faded, chipped.

## Names
- Hood-sounding, short, punchy. **Not** soft words like FRESH, MOOD, WAVY.
- Use: SPAT, BRAKE, LONER, TYPE, SKOT, DONK, DAPS, BAK, GROSE, XTRA, TIKA, ZOER, HOPA, ENIPS, DELS, SEB, AMINAL, WINK, DERP, SHUE.
- These are words from Cade's ref sheet, used as our own made-up tags. Do not copy the actual artwork of real writers.
- Still banned: real gang names, sets, numbers that read as sets, hand signs, real places.

## What we built
![[2026-10-16-graffiti-generated-sheet.jpg]]
- **13 original pieces** drawn with a canvas generator (`raw/2026-10-16-graffiti-generated/generator.html`, Google fonts Sedgwick Ave Display, Titan One, Londrina Solid, Permanent Marker, Rock Salt): 5 pieces (SPAT, BRAKE, LONER, TYPE, SKOT), 4 throw-ups (DONK, DAPS, BAK, GROSE), 2 characters (skull, blob), 2 tag walls. 1024x512 transparent PNGs.
- **Not in game yet:** uploading needs `upload_image`, which Claude Code's permission check blocked. Fix: add a permission rule for `mcp__Roblox_Studio__upload_image`, or bulk import the PNGs yourself in Studio (Asset Manager > Bulk Import), then tell Claude the ids.
- **In game now (placeholder):** 8 free Creator Store decals, checked by eye. No brands, real people, or gang refs. 19 panels.

| Decal | Store id | Image id |
|---|---|---|
| skull dragon | 280284241 | 280284240 |
| orange wildstyle | 151393188 | 151393187 |
| blue wall piece | 80870306 | 80870305 |
| red wildstyle | 335231345 | 335231344 |
| KEEP OUT stencil | 109517300 | 109517299 |
| tag scribbles | 13226596753 | 13226596704 |
| color wildstyle | 1519360126 | 1519360121 |
| sticker pile | 160092192 | 160092191 |

## How we'd build it in Roblox
- **Instances:** invisible, non-collidable carrier `Part` flush with the wall, one `Decal` on its Front face. Templates in `ServerStorage.MapTools.GraffitiDecals` with an `Aspect` attribute.
- **Gotcha:** a Decal inserted from the store gets the *decal* id. It must use the *image* id or it renders blank. Get it with `InsertService:LoadAsset(decalId)` in Edit mode and read the Decal's Texture.
- **Sizing rule:** walls with windows (back buildings, east block) keep graffiti under 5 studs tall so it doesn't cover windows. Rowhouse rears up to 8. Blank side walls up to 11.
- **Perf:** one decal per panel, no SurfaceGuis.
- **Next:** swap in our 13 pieces once uploaded, add more layered tags per wall.

## Related
- [[Main Street Block]]
- [[Art Direction]]
- [[index]]

---
type: tool
area: tools
owner: shared
status: building
sources:
  - raw/2026-10-16-graffiti-generated/generator.html
updated: 2026-10-16
tags: [tool, graffiti, art]
---

# Graffiti Generator

A one-page HTML canvas tool Claude wrote to make original graffiti art for the map. Output: 1024x512 transparent PNGs. Lives at `raw/2026-10-16-graffiti-generated/generator.html` (the 13 PNGs it made are next to it).

![[2026-10-16-graffiti-generated-sheet.jpg]]

## What it can draw
- `piece({...})`: full color piece. Options: `word`, `font`, `size`, `fill` (gradient stops), `bands` (wavy stripes), `dots`, `outer`/`outerColor` (outer line), `line`/`lineColor` (black outline), `depth`/`dx`/`dy`/`depthColor` (3D block), `cloud` [fill, line], `drips`, `shine` (stars), `glow` (overspray), `tags` (side tags), `weather` (0..1 wear).
- `throwie({...})`: fat 2-color bubble letters with an optional drop shadow.
- `skull(seed)`, `blobHead(seed)`: cartoon characters.
- `tagWall(seed, words, colors)`: a messy layer of marker tags.
- Letters get random rotation, size and baseline jitter per letter so it looks hand painted. Fonts: Sedgwick Ave Display, Titan One, Londrina Solid, Permanent Marker, Rock Salt (Google Fonts).

## How to make more
1. Edit the `pieces` list at the bottom of the HTML (new word, colors, seed).
2. Serve the folder with a local server that accepts `POST /save?name=...` (Claude's `server.js` did this; ask Claude to recreate it) and open it in a browser. Each canvas saves as a PNG.
3. Upload with Studio MCP `upload_image` (needs http URLs + the permission rule) or Studio Asset Manager > Bulk Import.
4. Add a Decal template in `ServerStorage.MapTools.GraffitiDecals` with an `Aspect` attribute, and log the image id in [[Graffiti Style]].

## Rules
- Tag names from [[Graffiti Style]]. Hood-sounding, made up. No gang names, sets, hand signs, real places.
- Don't recreate real writers' actual pieces.

## Related
- [[Graffiti Style]]
- [[Map Tools]]
- [[index]]

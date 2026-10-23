---
type: ui
owner: shared
status: building
sources:
  - Roblox References/Source/visual-refs/sports/Basketball-GUI.png
updated: 2026-10-22
---

# Basketball GUI Spec (lobby reference)

Element-by-element notes from `visual-refs/sports/Basketball-GUI.png` (1919×1079), and how [[Ultimate Frisbee - Current Build]] maps each one.

![[Basketball-GUI.png]]

## Fonts (only two)
- **Numbers and stats** ("24", "OVR", "87,390", "161-172"): condensed bold. We use **Oswald Bold** (`Style.NUM`).
- **Labels and buttons** (SHOP, SZN PASS, "Practice Court", "Emote", player names): clean geometric bold. We use **Gotham Bold** (`Style.HEAVY`), with Gotham Medium (`Style.BOLD`) for names.
- No squarish or display fonts anywhere in the HUD.

## Left: tile grid (2 columns, ~84px squares, ~10px gap, ~4px corners)
- **Every tile, from inside out:**
  - a dark fill in the tile's own color (deep red, deep purple, deep navy)
  - a neon icon with a soft glow
  - a tiny white label at the bottom
  - an outer outline in the same dark color as the fill
  - a bright 2px border fading between two colors
  - a soft glow behind it in the main color

| Tile | Fill | Icon | Bright border |
| --- | --- | --- | --- |
| SHOP | dark red | red neon cart | red → orange |
| SZN PASS | dark magenta | pink ticket | pink → purple |
| SPINNER | dark purple | orange/purple wheel | purple → orange |
| Others | dark navy | cyan icon | blue → cyan |

- **Badges:** a red circle with a white ring and a white "!", on the top-right corner.
- **Collapse arrow:** a ~50px navy square with a light gray 2px border and a blue-violet "<" chevron.

## Bottom-left
- **OVR box (~110×86):**
  - near-black brown fill, with a thin orange-brown border
  - a big white condensed number, with "OVR" in orange condensed under it
  - a vertical meter on the right: dark brown track, orange fill from the bottom
- **Coins:** a big glossy gold coin overlapping the left edge, then a large gold condensed number, on a dark strip that fades out to the right.
- **Under that:** tiny "FPS / Ping" text. We skip it.

## Top-right: leaderboard (~270 wide)
- **Header:** a dark navy strip with a slanted dark tab on the left. "LEADERBOARD" in small light-blue caps, and the stat name in orange on the right.
- **LOBBY pill:** light gray with dark text.
- **Rows:** dark translucent, with a small avatar on the left, a white name centered (Gotham Medium), and a white value on the right.
- **Under it:** a server list in italic heavy text. We skip it.

## Right and bottom-right
- **"Emote [G]":** white Gotham Bold, and a small gray rounded keycap with "G".
- **"300 Coins in 14:04":** white Gotham Bold on two lines. A play-time reward we don't have.
- **"View Courts" / "Practice Court":** plain near-black navy bars (~85% opaque), large white Gotham Bold, with no fancy border.

## Nameplate under the player
- A textured (camo-like) light frame with a black outer edge.
- The name in small white text at the top, and the big stat in white condensed bold ("161-172").
- **Ours:** level + name (Cade's call), with the frame color set by the equipped Nameplate cosmetic.

## In-world (not HUD)
- "HEAT BUNDLE": italic heavy orange-red with a dark outline. "[LIMITED TIME]" in white, with a red timer.

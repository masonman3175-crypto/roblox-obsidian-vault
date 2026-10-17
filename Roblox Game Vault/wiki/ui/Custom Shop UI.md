---
type: reference
area: ui
owner: flow
status: idea
sources:
  - raw/2026-10-16-ui-custom-shop.webp
updated: 2026-10-16
tags: [reference, ui, shop]
---

# Custom Shop UI

![[2026-10-16-ui-custom-shop.webp]]

## What it is
A themed shop window made with Claude in Studio: a chunky framed panel, item cards with art, price buttons, a currency counter, gamepass cards and locked "rebirth" slots.

## Breakdown
- Thick outlined panels, bold display font, strong color blocks, every card has an icon.
- Prices sit on big green buttons. Currency is top right with a "+" button.
- Locked items are greyed with clear "to unlock" text.
- Our version should use our gritty street style, not cartoon Halloween. Keep the structure, change the skin.

## How we'd build it in Roblox
- `ScreenGui` > `Frame` with `UICorner`, `UIStroke`, `UIGradient`, `UIGridLayout` for cards, `ImageLabel` art, `TextButton` prices.
- Purchases go through the server only (`MarketplaceService`, `ProcessReceipt`). Cosmetic only.
- **Owner:** GAME FLOW (HUD/shop). Shared reference.

## Related
- [[Neon Sniper Skin And HUD]]
- [[Hood Warfare 2 HUD and Presentation]]
- [[index]]

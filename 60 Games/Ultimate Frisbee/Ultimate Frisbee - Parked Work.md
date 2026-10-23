---
type: system
owner: shared
status: planned
sources: []
updated: 2026-10-22
---

# Ultimate Frisbee - Parked Work

Things that are built but on hold, and ideas for later. Say the trigger phrase to pick one up.

## Movement (built, paused 2026-10-22)
Paused because the partner is rebuilding the lobby and practice flow. The full details are in [[Ultimate Frisbee - Current Build]] under "Base movement (second pass)".
- **Running:** always on, with the Rthro run animation and grass footsteps.
- **Abilities:** E High Jump and F Dash, plus C and X for shop powers.
- **Pivot:** planted-foot pivot with IK (Roblox's built-in way to hold a limb in place), using the server's `PlantPosition`.
- **Still to do:** check the dash lunge and pivot from a second player's view, add mobile buttons for E/F, and add server-side movement checks.

## Starter pack preview ("make the starter pack in the lobby")
- **The idea:** a model of the player's own character in the lobby, wearing the starter pack, so they see what they'd look like before buying. Inspired by a basketball game Cade showed.
- **How to build it:**
  - Load the player's look with `Players:GetHumanoidDescriptionFromUserId`.
  - Apply the pack's skin, trail and disc to a dummy on a lit pedestal next to the store.
  - Show only that player's preview on their own screen (built client-side).
  - Add a BUY button and the Robux price on a SurfaceGui.

## First-join shop tutorial
- New players start with 5,000 coins (`ShopConfig.StartingCoins`).
- On their first join, open the power shop and have them buy a starter power for the C slot.

## Store and power art (later)
- Power thumbnails should become stylized screenshots of the power in action.
- The big preview should eventually play a short video demo.
- Each store should get its own stylized building (power shop, store, ramen).

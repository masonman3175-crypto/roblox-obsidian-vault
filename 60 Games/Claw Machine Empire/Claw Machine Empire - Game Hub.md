---
kind: game-project
game: claw-machine-empire
status: playable-alpha
build: 03
tags: [roblox, game-project, claw-empire, implementation]
---

# Claw Machine Empire

**Our first game: a bright original claw arcade where your plushie crew funds your next cabinet.**

> [!success] Build 03 - Plushie Park
> The map is about 4.56x larger, catches have articulated crane/3D reveal animation, and the cartoon walking HUD has only wallet, one menu and play. See [[Claw Machine Empire - Build 03 Plushie Park]] for current implementation, screenshots and verification.

- [[Claw Machine Empire - Build 03 Plushie Park]] - current implementation and verification.
- [[Claw Machine Empire - Build 02 Toybox Arcade]] - historical toybox build.
- [[Claw Machine Empire - Build 01]] — historical first vertical slice.
- [[Claw Machine Empire - Visual Direction]] — your four preserved visual references.
- [[Claw Machine Empire - Build 02 Backlog]] — next priorities and reusable robot handoff.
- [[Original Game Design]] — your unchanged full source brief, including future features and suggested prices.
- [Project README](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/README.md)
- [Portable Roblox place](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/Claw%20Machine%20Empire.rbxlx)
- [Verification evidence](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/evidence/build03/VERIFICATION.txt)

## Playing the current build

![[CME Build 03 - Simple Walking HUD.jpg]]

Open the installed **Place1** in Studio and press Play, or open the portable place file. Use PLAY, then WASD/arrows or the direction buttons, then Space/DROP. Your first duck sits in the center. Display it from inventory, collect its $5/sec bank income, and unlock Classic with 250 earned coins.

Walk to a cabinet and hold E, or open MY ARCADE > Machines > GO HERE. MY ARCADE > Bird's-eye map / V shows the expanded park. **Purchases remain disabled.** Studio normally uses session data; an explicit Studio-only developer snapshot preserves the user's test progress across this rebuild. Live persistent storage still needs published staging validation. No game was published or product put on sale.

## Design identity

- Pastel studded park, chunky cartoon outlines, cream cards, mint actions, one pink menu and warm yellow money.
- Original goofy collectible plushies rather than characters or assets copied from the reference games.
- Free, replenishing aim-and-drop play; progression comes from earning and displaying.
- Long-term roadmap: machine tiers, merge variants, personal arcade expansion and Arcade Ascension.

## Related research

[[Systems Invariants and Schema Sketch]] · [[Stable item IDs and provenance]] · [[Collectible lifecycle state machine]] · [[Persistence is part of gameplay]] · [[Durable idempotent purchase grants]] · [[Regression suite organized by invariant]] · [[START HERE - Slop Game Lab]]

# Animation style briefs

**Original written briefs**, not downloaded footage, licensed files or tested Roblox implementations. Each gives timing in seconds (60 fps) and notes for the Roblox Animation Editor (keyframes, `Enum.AnimationPriority`) or UI tweens. Tune in Studio before shipping; none of these have been run in a live game.

Shared rules: one clear silhouette per pose, hold the key pose 2-4 frames, put hit-stop on the impact frame, and keep hitboxes and reward results server-authoritative regardless of how the animation looks.

## Anime / battlegrounds combat
1. **Dash punch combo (M1 x4)** - Each hit: 0.08s wind-up pull-back, 0.05s snap forward, 0.12s recover. Final hit gets a longer 0.25s wind-up and a knockback pose. Priority: Action.
2. **Heavy slam (M2)** - 0.35s raise with spine arch, 0.06s smash, 0.4s hold on a crouched landing. Camera shake and ground-crack VFX on the smash frame.
3. **Uppercut launch** - Low crouch (0.15s), rising strike with the body fully extended; victim lifts with a delayed fall. Attacker follows with a short hop.
4. **Teleport / flash step** - 3 frames of lean-in, character hidden or smeared for 2-4 frames, reappears mid-follow-through. Afterimage trail.
5. **Charge-up ultimate** - 1.0-2.0s crouch with a trembling loop (small random offsets), aura grows, release pose is a wide stance with arms thrown forward.
6. **Block / parry** - Arms cross in 0.06s, tiny recoil on hit; a parry flashes a bright pose for 2 frames then returns to idle.
7. **Hit react (light / heavy / knockdown)** - Light: 0.1s head snap. Heavy: torso twist and a step back. Knockdown: fall, 0.8s get-up.
8. **Awakening transform** - Hold a fist pose, hair or cloak flaps, brief freeze frame, then a burst stance. Pair with a white flash.

## Cartoony / bouncy
9. **Squash-and-stretch jump** - 0.12s crouch (scale Y 0.8), stretch on launch (Y 1.2), neutral mid-air, landing squash (Y 0.75), then settle with a small overshoot.
10. **Rubber-hose run** - Exaggerated arm swing, body bob about 15% bigger than realistic, big forward lean, feet cross over at top speed.
11. **Wobble idle** - Slow side-to-side sway with the arms lagging slightly (follow-through). 1.6s loop.
12. **Surprise take** - Anticipation squash 0.1s, body pops to 1.3x for 0.15s, shake, then relax.
13. **Happy bounce emote** - Three hops with decreasing height, arms up on each peak.
14. **Cartoon fall** - Hang in the air 0.3s, then drop with stretch and a flat splat squash on landing.

## Egg hatching and pet reveals
15. **Egg wobble ramp** - Rotation +/-3 degrees, then +/-8, then +/-15, each beat 0.2s shorter. 0.3s of stillness before the crack.
16. **Crack stages** - Swap to 3 crack textures across the wobble beats, each with a small scale pop (1.0 to 1.08 to 1.0 in 0.08s).
17. **Shell burst** - 6-10 shell pieces launched radially with gravity, fading over 0.6s. Light rays behind the egg scale from 0 to 1.5.
18. **Pet pop-out** - Pet starts at scale 0 inside the egg, overshoots to 1.2, settles at 1.0 over 0.35s, then a happy hop and a name card.
19. **Rarity tint reveal** - Background glow eased in by rarity (common grey, rare blue, epic purple, legendary gold); rarer pets get a longer build.
20. **Skip / auto-open** - Hold-to-skip collapses the sequence to 0.5s with an identical result card. The server picks the result before the animation starts.

## Box / chest / crate opening
21. **Shake and unlock** - Lock rattles 0.3s, lid hinge lifts 10 degrees, pause, then the lid pops fully open on a spring.
22. **Lid pop and light burst** - Lid flips 110 degrees with Back easing (0.25s), a beam of light rises, and the item silhouette rises from inside.
23. **Item fly-out arc** - Item travels a parabolic path to screen center, scaling 0.4 to 1.0 while spinning once.
24. **Multi-open fan** - 5-10 boxes open in a staggered chain (0.1s apart); results collect into a summary grid.
25. **Case roulette strip** - Horizontal item strip scrolls fast and decelerates (Quint Out, 4-6s) with a tick per item, stops on the server-picked slot, and the winner scales up.
26. **Mystery box float** - Idle bob (0.15 studs, 2s loop) with slow rotation and a sparkle every few seconds.

## Realistic / sports
27. **Jump shot** - Gather 0.2s, rise with arms extended, wrist flick at the release frame, hold the follow-through 0.3s.
28. **Sprint start** - Low crouch, drive push on the first two steps, torso rises to upright over 0.6s.
29. **Tackle / slide** - Lead shoulder low, arms extended, slide with drag, then recover to standing (0.5s).
30. **Victory celebration** - Fist pump, short jump, turn to the camera. Keep it skippable and non-blocking.

## Atmosphere / cutscene
31. **Dolly-in hero shot** - Camera pushes in 15% over 3s while the character holds a breathing idle.
32. **Whip-pan transition** - 0.2s fast pan with a motion-blur frame, cut on the blur, ease out.
33. **Slow-motion impact** - Drop animation speed to 0.2x for 0.25s on the killing blow, then restore with a short ramp.

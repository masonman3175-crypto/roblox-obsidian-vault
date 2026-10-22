# Roblox Animation Catalog

> **Honesty note.** Researched 2026-10-20. Pictures are preview images from public itch.io listings (credits in the root `IMAGE-CREDITS.md` and on each page). Recipes come from general Roblox knowledge and linked DevForum threads, and have **not** been tested in Studio. Many DevForum answers are older, so verify against the current API.

UI and character/combat animation patterns. Your own reference videos are in [`visual-refs/animation-refs/`](../visual-refs/animation-refs/_Folder%20Index.md).



## UI animations

1. [**Button Hover Scale.**](01-button-hover-scale/README.md) Button grows 5-8% on hover and settles back. Roblox recipe: UIScale tween 1 to 1.06 with Quad Out, 0.12s. 
2. [**Click Squash and Stretch.**](02-click-squash-and-stretch/README.md) Press squashes to 0.92 then springs past 1.05 and settles. Recipe: two chained tweens or a spring.
3. [**Pop-in Spring Open.**](03-pop-in-spring-open/README.md) Panel scales 0.6 to 1 with overshoot (Back/Elastic Out) while fading in. Recipe: UIScale + GroupTransparency on a CanvasGroup.
4. [**Slide Panel.**](04-slide-panel/README.md) Panel slides from an edge with Quint Out. Recipe: tween Position scale offsets, keep AnchorPoint consistent.
5. [**Error Shake.**](05-error-shake/README.md) Short horizontal shake on invalid input. Recipe: 4-6 tweens of +/-6px with Linear, 0.05s each.
6. [**Currency Count-up.**](06-currency-count-up/README.md) Number rolls up to the new value. Recipe: tween a NumberValue and update text on Changed.
7. [**Floating Plus-N Popup.**](07-floating-plus-n-popup/README.md) +N rises, fades and drifts. Recipe: pooled TextLabels, tween Position and TextTransparency.
8. [**Reward Chest Open.**](08-reward-chest-open/README.md) Chest shakes, lid pops, light rays burst, item card scales in. Recipe: sequence of tweens + ParticleEmitter:Emit.
9. [**Rainbow Gradient Cycle.**](09-rainbow-gradient-cycle/README.md) Gradient colours scroll continuously. Recipe: tween UIGradient.Offset or Rotation looped.
10. [**Shine Sweep.**](10-shine-sweep/README.md) White diagonal highlight sweeps across a button every few seconds. Recipe: UIGradient with Transparency sequence, tween Offset -1 to 1.
11. [**Tab Switch.**](11-tab-switch/README.md) Content fades/slides while the tab indicator glides. Recipe: tween indicator Position, swap pages with CanvasGroup.
12. [**Toast Slide.**](12-toast-slide/README.md) Toast enters from the side, waits, exits. Recipe: Back Out in, Quad In out, task.delay.
13. [**Egg Hatch Shake.**](13-egg-hatch-shake/README.md) Egg wobbles with increasing amplitude, cracks, bursts. Recipe: Rotation tweens with growing angle, then reveal.
14. [**Wheel Spin.**](14-wheel-spin/README.md) Wheel spins fast and eases to a server-chosen result. Recipe: tween Rotation with Quint Out; the server picks the prize first.
15. [**Progress Bar Fill.**](15-progress-bar-fill/README.md) Bar fills smoothly with a bright leading edge. Recipe: tween Size X; overlay shine.

## Character & combat animations

16. [**Idle Breathing.**](16-idle-breathing/README.md) Subtle chest rise and weight shift loop. Recipe: Animation Editor, 2-4s loop, low amplitude.
17. [**Run Cycle Lean.**](17-run-cycle-lean/README.md) Run loop with forward lean and arm swing, speed-scaled. Recipe: AnimationTrack:AdjustSpeed with velocity.
18. [**Jump Squash.**](18-jump-squash/README.md) Anticipation crouch, launch stretch, landing squash. Recipe: Jumping/Landed state events trigger tracks.
19. [**Punch Combo.**](19-punch-combo/README.md) 3-hit combo with increasing weight and a finisher. Recipe: marker events for hitbox timing, server validates.
20. [**Sword Swing Combo.**](20-sword-swing-combo/README.md) Chained slashes with cancel windows. Recipe: KeyframeMarkers for hit frames, combo timer reset.
21. [**Dodge Roll.**](21-dodge-roll/README.md) Quick roll with brief i-frames. Recipe: animation + server-side invulnerability window.
22. [**Hit Reaction Flinch.**](22-hit-reaction-flinch/README.md) Short additive flinch scaled by damage. Recipe: priority Action, 0.2s.
23. [**Death and Ragdoll.**](23-death-and-ragdoll/README.md) Blend from hit into ragdoll, camera lingers. Recipe: BallSocketConstraints on Humanoid.Died.
24. [**Emote Dance.**](24-emote-dance/README.md) Looping emote with prop sync. Recipe: Animator:LoadAnimation, Looped = true, stop on move.
25. [**Victory Pose.**](25-victory-pose/README.md) Celebratory pose at round end with confetti. Recipe: play track + VFX at winner.
26. [**Tool Equip Animation.**](26-tool-equip-animation/README.md) Draw/holster animation that attaches the tool at a keyframe. Recipe: Motor6D or tool grip on marker.
27. [**Cast Spell.**](27-cast-spell/README.md) Wind-up, release, recovery with hand glow. Recipe: markers drive projectile spawn.
28. [**Block and Parry.**](28-block-and-parry/README.md) Guard stance with parry-flash timing window. Recipe: short active frames, server timing check.
29. [**Dash and Slide.**](29-dash-and-slide/README.md) Burst dash with stretched pose and speed lines. Recipe: LinearVelocity + animation + VFX.
30. [**Sprint Camera Feel.**](30-sprint-camera-feel/README.md) FOV widens and subtle bob while sprinting. Recipe: tween Camera.FieldOfView 70 to 80.
31. [**Mount and Ride.**](31-mount-and-ride/README.md) Seat pose with idle sway and steering lean. Recipe: Seat + looped animation, lean from input.
32. [**Boss Telegraph Windup.**](32-boss-telegraph-windup/README.md) Exaggerated anticipation with a ground warning. Recipe: telegraph decal fills while windup plays.
33. [**2D Sprite Reference Sets.**](33-2d-sprite-reference-sets/README.md) Idle/run/jump/attack/die sprite sets are a useful timing reference for key poses. 


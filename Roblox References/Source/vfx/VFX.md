# Roblox VFX Catalog

> **Honesty note.** Researched 2026-10-20. Pictures are preview images from public itch.io listings (credits in the root `IMAGE-CREDITS.md` and on each page). Recipes come from general Roblox knowledge and linked DevForum threads, and have **not** been tested in Studio. Many DevForum answers are older, so verify against the current API.

Particle, beam, trail and UI-feedback effects. Many itch.io sprite packs are for other engines, so treat them as visual references or flipbook source art and check each licence.



## Combat VFX

1. [**Hit Spark.**](01-hit-spark/README.md) Bright burst at the point of impact. Recipe: ParticleEmitter, Lifetime 0.15-0.3, Rate 0, call Emit(8-15), LightEmission 1.
2. [**Slash Arc Trail.**](02-slash-arc-trail/README.md) Crescent smear following a swing. Recipe: Trail between two attachments on the blade, or a mesh arc faded with tween.
3. [**Impact Ring Shockwave.**](03-impact-ring-shockwave/README.md) Expanding ring on heavy hits or landings. Recipe: neon ring mesh, tween Size up and Transparency to 1.
4. [**Speed Lines Dash.**](04-speed-lines-dash/README.md) Radial lines around the screen or character on dash. Recipe: ImageLabel overlay tween, or particles streaking backward.
5. [**Anime Impact Frame.**](05-anime-impact-frame/README.md) One-frame high-contrast inverted flash on a big hit. Recipe: full-screen white/black Frame for 1-2 frames plus ColorCorrection.
6. [**Muzzle Flash.**](06-muzzle-flash/README.md) Short bright cone at the barrel. Recipe: PointLight + particle emit 1 frame, Rotation random.
7. [**Shield Bubble.**](07-shield-bubble/README.md) Translucent sphere with hex pattern that ripples on hit. Recipe: Neon sphere, Fresnel-like transparency, scale pulse on damage.
8. [**Blood Splat Stylised.**](08-blood-splat-stylised/README.md) Colour-neutral splat (paint, slime) for family-friendly games. Recipe: decal burst, no gore.

## Magic & elemental

9. [**Magic Circle Cast.**](09-magic-circle-cast/README.md) Rotating rune circle on the ground while casting. Recipe: Decal/SurfaceGui image, tween Rotation, fade out.
10. [**Heal Aura.**](10-heal-aura/README.md) Rising green sparkles and soft glow. Recipe: ParticleEmitter upward Speed, LightEmission 0.5.
11. [**Lightning Bolt.**](11-lightning-bolt/README.md) Jagged beam flickering between points. Recipe: Beam with random mid attachments, rebuild each 0.05s.
12. [**Ice Shatter.**](12-ice-shatter/README.md) Crystals burst outward with cold mist. Recipe: shard parts with velocity + particle mist.
13. [**Water Splash.**](13-water-splash/README.md) Droplets and ring on contact. Recipe: emit droplets with gravity (Acceleration), ripple ring.
14. [**Fireball Explosion.**](14-fireball-explosion/README.md) Fire core, smoke and debris. Recipe: layered emitters (flash, fire, smoke), Explosion with no damage for push.
15. [**Black Hole Vortex.**](15-black-hole-vortex/README.md) Swirling particles pulled to centre. Recipe: emitter with negative Acceleration toward centre + rotating mesh.
16. [**Meteor Impact.**](16-meteor-impact/README.md) Fire trail, impact flash, crater dust. Recipe: Trail + particle burst + camera shake.
17. [**Teleport Portal.**](17-teleport-portal/README.md) Ring with swirling inner and flash on entry. Recipe: Rotating mesh, particle swirl, light.
18. [**Poison Cloud.**](18-poison-cloud/README.md) Low green fog with bubbles. Recipe: slow big particles, Transparency 0.6.

## Environment & ambience

19. [**Rain and Snow.**](19-rain-and-snow/README.md) Weather particles following the camera. Recipe: emitter in a part above the camera, or collision-aware rain.
20. [**Dust Footsteps.**](20-dust-footsteps/README.md) Small puffs at feet when running or landing. Recipe: emit 3-5 on Running state or animation markers.
21. [**Smoke Puff.**](21-smoke-puff/README.md) Soft rising smoke. Recipe: texture sheet, Size grows, Transparency to 1.
22. [**Torch Fire.**](22-torch-fire/README.md) Looping flame with embers and flicker light. Recipe: Fire emitter + PointLight Brightness noise.
23. [**God Rays Light Shafts.**](23-god-rays-light-shafts/README.md) Beams from a window or sky. Recipe: SunRaysEffect or stretched neon planes at low alpha.
24. [**Fireflies Ambient.**](24-fireflies-ambient/README.md) Glowing motes drifting in dusk scenes. Recipe: low-rate emitters with random Rotation and fading glow.
25. [**Rocket Smoke Trail.**](25-rocket-smoke-trail/README.md) Smoke line behind projectiles. Recipe: Trail plus smoke emitter attached to the rocket.

## UI, reward & feedback

26. [**Level-Up Burst.**](26-level-up-burst/README.md) Gold burst, rays and banner. Recipe: UI ImageLabel scale + 2D particle spritesheet.
27. [**Coin Gem Sparkle.**](27-coin-gem-sparkle/README.md) Sparkles on pickup that fly to the HUD counter. Recipe: tween clones toward the currency icon, then count up.
28. [**Rarity Glow Beam.**](28-rarity-glow-beam/README.md) Coloured light pillar by rarity when a drop spawns. Recipe: tall Neon part + Beam, colour from rarity table.
29. [**Confetti Celebration.**](29-confetti-celebration/README.md) Multi-colour falling pieces. Recipe: emitter with ColorSequence random keypoints, gravity.
30. [**Damage Number Pop.**](30-damage-number-pop/README.md) Numbers arc up with scale punch. Recipe: pooled BillboardGui, tween.
31. [**Screen Damage Vignette.**](31-screen-damage-vignette/README.md) Red edges pulse at low health. Recipe: full-screen gradient frame with transparency tween.
32. [**Glitch Chromatic Pulse.**](32-glitch-chromatic-pulse/README.md) RGB split and jitter for hacks or hits. Recipe: ColorCorrection/Blur tween + offset duplicate frames.
33. [**Powerup Aura Flames.**](33-powerup-aura-flames/README.md) Body-wrapped flame aura for boosted states. Recipe: emitters on limbs, LightEmission 1.
34. [**Spawn Dissolve.**](34-spawn-dissolve/README.md) Materialize or dissolve with edge glow. Recipe: tween part Transparency + particles at edges.
35. [**Particle Texture Library.**](35-particle-texture-library/README.md) Texture sheets for ParticleEmitters (sparks, smoke, rings, beams). Recipe: use greyscale/white PNGs and tint with ColorSequence.
36. [**Cartoon VFX Spritesheets.**](36-cartoon-vfx-spritesheets/README.md) Stylised cartoon burst, smoke and impact sheets. Recipe: flipbook via ParticleEmitter FlipbookLayout.


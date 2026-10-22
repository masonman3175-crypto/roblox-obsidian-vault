# Roblox SFX and Audio Catalog

> **Honesty note.** Researched 2026-10-20. Sound design guidance (durations, layering, loudness) is general game-audio practice, not Roblox rules. Roblox API names and behaviour come from the bundled official docs in [`official-docs/`](../official-docs/README.md). Cookbook scripts were compile-checked and run against unparented instances in Roblox Studio 0.743, but **not** audibly tested. Pack licences differ: check each page, and only upload audio you have the right to use.

Roblox audio facts worth knowing: group `Volume` multiplies child volume and nested groups multiply again ([DevForum](https://devforum.roblox.com/t/support-for-nested-soundgroups/1669856)); a Sound must be assigned via its `SoundGroup` property, not just parented; effects placed on a group apply to everything in it.

## Free and licensed sound sources
- [OpenGameArt: Interface sounds (Kenney, CC0)](https://opengameart.org/content/interface-sounds)
- [OpenGameArt: 87 Clickety Clips (CC0)](https://opengameart.org/content/87-clickety-clips)
- [Kenney audio](https://kenney.nl/assets/category:Audio)
- [Freesound](https://freesound.org) (licence varies per sound)
- [RawAmbience free magic spells (itch.io)](https://itch.io/t/5286574/free-magic-spells-sound-effects)
- Previewed packs: Fast UI Sounds, UI Clicks, User Interface Sounds, Interface/Buttons, Hove Audio sword pack, Forge & Fantasy, Combat Magic Spells, Sci-Fi Swords (see each entry)


## UI sounds

1. [**Button Click.**](01-button-click/README.md) Short, dry, mid-high click (30-120 ms) that confirms a press. Keep it quiet and consistent: players hear it hundreds of times. Recipe: Sound in a UI SoundGroup at Volume 0.3-0.5, play with SoundService:PlayLocalSound so it does not replicate; vary PlaybackSpeed 0.97-1.03 only.
2. [**Button Hover Tick.**](02-button-hover-tick/README.md) Very soft tick (10-40 ms), lower volume than click. Use sparingly on desktop only. Recipe: trigger from MouseEnter, throttle to once per 80 ms, skip on touch.
3. [**Menu Open Whoosh.**](03-menu-open-whoosh/README.md) Soft rising whoosh (150-300 ms) on panel open, mirrored falling version on close. Recipe: pair with the pop-in tween so sound peak lands when the scale overshoots.
4. [**Confirm Success Chime.**](04-confirm-success-chime/README.md) Bright two-note rising chime (200-400 ms). Recipe: for purchases and claims, play after server confirmation, not on click.
5. [**Error Buzz.**](05-error-buzz/README.md) Low short buzz or dull thud (100-250 ms), never harsh. Recipe: pair with the UI error shake.
6. [**Toggle Switch.**](06-toggle-switch/README.md) Two distinct pitches for on and off (slight pitch up for on). Recipe: one Sound, set PlaybackSpeed 1.1 or 0.9.
7. [**Notification Ping.**](07-notification-ping/README.md) Gentle bell or pluck, 300-600 ms, rate-limited. Recipe: cap to one ping per second; group ducking not needed.
8. [**Purchase Cha-Ching.**](08-purchase-cha-ching/README.md) Coin and register sparkle (400-800 ms) for purchases. Recipe: play locally on server-confirmed purchase.
9. [**Coin Pickup Pitch Ladder.**](09-coin-pickup-pitch-ladder/README.md) Coin tick whose pitch rises on consecutive pickups, resetting after a pause. Recipe: PlaybackSpeed = 1 + 0.05*combo capped at 1.6.
10. [**Level-Up Fanfare.**](10-level-up-fanfare/README.md) Short ascending brass or synth stinger (1-2 s) with a sparkle tail. Recipe: duck music via SoundGroup volume tween while it plays.
11. [**Reward Chest Open.**](11-reward-chest-open/README.md) Creak or latch, burst, then sparkle shimmer layered over 1-2 s. Recipe: three Sounds timed to the chest animation markers.
12. [**Countdown Beep.**](12-countdown-beep/README.md) Three identical beeps and a higher final beep. Recipe: PlaybackSpeed 1.0 for 3-2-1, 1.5 for GO.
13. [**Typewriter Text Blip.**](13-typewriter-text-blip/README.md) Tiny blip per character, pitch-randomised slightly, per speaker voice. Recipe: play every 2nd character, skip spaces.

## Combat sounds

14. [**Sword Swing Whoosh.**](14-sword-swing-whoosh/README.md) Fast airy whoosh (150-300 ms), several variants rotated. Recipe: start the sound on the animation marker, 3-5 variants, PlaybackSpeed jitter 0.92-1.08.
15. [**Sword Hit Metal.**](15-sword-hit-metal/README.md) Metallic clang with short ring (200-500 ms). Recipe: layer a low thud under the clang; play at the hit position.
16. [**Punch Impact.**](16-punch-impact/README.md) Meaty low thump plus short noise slap (100-250 ms). Recipe: 4+ variants, louder for crits, 3D rolloff with RollOffMaxDistance about 60.
17. [**Heavy Slam.**](17-heavy-slam/README.md) Deep boom with sub tail (500-1000 ms) and debris rattle. Recipe: low-pass via EqualizerSoundEffect for distant players.
18. [**Block Parry Clang.**](18-block-parry-clang/README.md) Sharp metallic ping, brighter than a normal hit so the parry reads clearly. Recipe: distinct pitch band from hit sounds.
19. [**Projectile Whoosh.**](19-projectile-whoosh/README.md) Passing whoosh with Doppler feel. Recipe: 3D sound parented to the projectile, RollOffMode InverseTapered.
20. [**Gunshot.**](20-gunshot/README.md) Transient crack plus tail. Recipe: short tail for close, longer reverb for outdoors; compress to avoid clipping.
21. [**Reload Click.**](21-reload-click/README.md) Mechanical clicks in sequence synced to animation. Recipe: one Sound per marker (mag out, mag in, bolt).
22. [**Explosion.**](22-explosion/README.md) Initial crack, low boom, long rumble tail (1-3 s). Recipe: distance-based low-pass and delay for far players.
23. [**Shield Break.**](23-shield-break/README.md) Glassy shatter plus low thud. Recipe: layer chimes at high pitch.
24. [**Critical Hit Sting.**](24-critical-hit-sting/README.md) Short bright sting above the normal hit. Recipe: tie to the crit damage-number pop.
25. [**Hurt Grunt.**](25-hurt-grunt/README.md) Short voice grunt, several variants, rate-limited so low health spam is not annoying. Recipe: cooldown 0.5 s per player.
26. [**Death Sound.**](26-death-sound/README.md) Distinct non-annoying stinger. Recipe: global low-pass dip for 0.5 s on local player death.

## Magic and sci-fi

27. [**Spell Cast Charge.**](27-spell-cast-charge/README.md) Rising shimmer that builds to the release. Recipe: tween PlaybackSpeed 0.8 to 1.3 over the charge time.
28. [**Magic Impact.**](28-magic-impact/README.md) Boom with sparkle shatter. Recipe: reverb on SFX group, brighter EQ for ice, darker for dark magic.
29. [**Heal Chime.**](29-heal-chime/README.md) Warm ascending arpeggio, soft attack. Recipe: low volume, no sharp transient.
30. [**Lightning Zap.**](30-lightning-zap/README.md) Crackle burst with sub thump. Recipe: add DistortionSoundEffect lightly for edge.
31. [**Fire Whoosh.**](31-fire-whoosh/README.md) Noise whoosh with low roar. Recipe: loop a crackle bed for burning objects (3D, Looped).
32. [**Ice Crackle.**](32-ice-crackle/README.md) High glassy crackle with short tinkles. Recipe: EQ boost around 6-8 kHz.
33. [**Laser Beam.**](33-laser-beam/README.md) Sustained hum plus onset zap. Recipe: Looped Sound with PlaybackSpeed modulated by charge.
34. [**Teleport Whoosh.**](34-teleport-whoosh/README.md) Reversed whoosh into a tight pop. Recipe: sync pop with the portal flash VFX.
35. [**Power-Up Jingle.**](35-power-up-jingle/README.md) Quick rising arpeggio with sparkle. Recipe: short (500 ms) to avoid blocking gameplay.
36. [**Shield Hum.**](36-shield-hum/README.md) Low sustained hum with slight tremolo. Recipe: Looped, volume tween on activate.

## Movement and environment

37. [**Footsteps by Surface.**](37-footsteps-by-surface/README.md) Short steps with 4-6 variants per material, triggered by animation markers and Humanoid.FloorMaterial. Recipe: map Enum.Material to a SoundGroup of variants; random pick avoiding repeat.
38. [**Jump and Land.**](38-jump-and-land/README.md) Soft cloth or gear rustle on jump, thump on land scaled by fall speed. Recipe: Humanoid.StateChanged Jumping and Landed.
39. [**Swim Splash.**](39-swim-splash/README.md) Splash on entry, soft bubbling loop underwater with low-pass. Recipe: EqualizerSoundEffect on the local group when camera is underwater.
40. [**Door and Mechanism.**](40-door-and-mechanism/README.md) Creak, latch, slide with positional rolloff. Recipe: 3D sounds on the model, play on open/close tween.
41. [**Wind Ambience Loop.**](41-wind-ambience-loop/README.md) Low wind bed, volume modulated slowly. Recipe: Looped Sound in an Ambient group, tween volume with noise.
42. [**Rain Ambience Loop.**](42-rain-ambience-loop/README.md) Steady rain bed, crossfade indoors. Recipe: reduce volume and low-pass when roofed (raycast up).
43. [**Forest Ambience.**](43-forest-ambience/README.md) Birds and rustle layered over wind. Recipe: layer 3 loops with different lengths so it never repeats audibly.
44. [**Cave Reverb.**](44-cave-reverb/README.md) Long reverb on footsteps and voices inside caves. Recipe: ReverbSoundEffect on an area SoundGroup, enable on zone enter.
45. [**Fire Crackle Loop.**](45-fire-crackle-loop/README.md) Positional crackle for torches and campfires. Recipe: 3D Looped, RollOffMaxDistance 40.
46. [**Vehicle Engine Loop.**](46-vehicle-engine-loop/README.md) Looped engine whose PlaybackSpeed follows speed. Recipe: map velocity to PlaybackSpeed 0.8-2.0.
47. [**Crowd and Pet Cute Sounds.**](47-crowd-and-pet-cute-sounds/README.md) Short chirps and squeaks for pets, randomised pitch per pet. Recipe: per-pet pitch seed.

## Music, tension and stingers

48. [**Lobby Music Loop.**](48-lobby-music-loop/README.md) Seamless loop 60-120 s with no abrupt ending. Recipe: Looped Sound in a Music group, fade between tracks over 1-2 s.
49. [**Adaptive Combat Layers.**](49-adaptive-combat-layers/README.md) Add or remove stems (drums, bass, lead) by intensity. Recipe: several synced Sounds, tween volumes by tension value.
50. [**Boss Intro Stinger.**](50-boss-intro-stinger/README.md) Big hit plus riser (2-4 s) timed to the boss reveal. Recipe: duck all other groups while it plays.
51. [**Round Start End Stingers.**](51-round-start-end-stingers/README.md) Short fanfares for start and win/lose. Recipe: differentiate win (major) and lose (minor).
52. [**Horror Drone.**](52-horror-drone/README.md) Low evolving drone, filtered noise, occasional sub pulses. Recipe: Looped, slow volume swell, low-pass EQ.
53. [**Jumpscare Sting.**](53-jumpscare-sting/README.md) Loud short sting with a quiet lead-in for contrast. Recipe: compress heavily, play once; accessibility option to reduce.
54. [**Heartbeat Low Health.**](54-heartbeat-low-health/README.md) Looped heartbeat that speeds up as health falls. Recipe: PlaybackSpeed 1 to 1.6, plus low-pass on other sounds.

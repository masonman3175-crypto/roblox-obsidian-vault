# Luau cookbook

Small, self-contained Luau modules for the GUI, VFX, cutscene, animation and SFX patterns in this repo. Each file has a header with its **verification status**. Checked in Roblox Studio 0.743 (compile plus basic runs on unparented instances); nothing here has been checked in a live multiplayer game, so treat results as a starting point and test them.

Security reminder: rewards, purchases, combat hits and progression must stay server-authoritative. See `animation/02-combo-client.luau`.

| File | Pattern | What it does | Tags |
|---|---|---|---|
| [`ui/01-hover-scale.luau`](ui/01-hover-scale.luau.md) | Button hover scale + press squash | Grows a button on hover and squashes on press using UIScale, so layout is unaffected. | gui, animation, tween, uiscale |
| [`ui/02-pop-in-open.luau`](ui/02-pop-in-open.luau.md) | Pop-in panel open/close | Panel scales from 0.8 to 1 with a Back overshoot while fading in via a CanvasGroup. | gui, animation, canvasgroup |
| [`ui/03-count-up.luau`](ui/03-count-up.luau.md) | Currency count-up | Rolls a number to a new value by tweening a NumberValue (TweenService cannot tween text directly). | gui, tween, hud |
| [`ui/04-shine-sweep.luau`](ui/04-shine-sweep.luau.md) | Shine sweep across a button | A diagonal white highlight sweeps across a button using a UIGradient transparency ramp and an Offset tween. | gui, uigradient, polish |
| [`ui/05-error-shake.luau`](ui/05-error-shake.luau.md) | Error shake | Short horizontal shake for invalid input or a failed purchase. | gui, animation, feedback |
| [`ui/06-responsive-scale.luau`](ui/06-responsive-scale.luau.md) | Responsive scale + safe area | Scales a fixed-design ScreenGui to any viewport with UIScale and respects device safe insets. | gui, mobile, responsive |
| [`ui/07-toast-stack.luau`](ui/07-toast-stack.luau.md) | Pooled toast notifications | Stacks up to N toasts with slide-in/out, auto-dismiss and a UIListLayout. | gui, notifications, pooling |
| [`vfx/01-hit-spark.luau`](vfx/01-hit-spark.luau.md) | Hit spark burst | One-shot spark burst at an impact point using ParticleEmitter:Emit and a short Lifetime. | vfx, particles, combat |
| [`vfx/02-shockwave-ring.luau`](vfx/02-shockwave-ring.luau.md) | Shockwave ring | Expanding flat ring for landings and heavy hits, built from a Neon cylinder and a tween. | vfx, impact, tween |
| [`vfx/03-lightning-beam.luau`](vfx/03-lightning-beam.luau.md) | Lightning bolt with Beams | Jagged beam between two points rebuilt a few times so it flickers. | vfx, beam, magic |
| [`vfx/04-weapon-trail.luau`](vfx/04-weapon-trail.luau.md) | Weapon swing Trail | Adds a Trail between two attachments on a blade and toggles it during swings. | vfx, trail, combat |
| [`vfx/05-confetti.luau`](vfx/05-confetti.luau.md) | Confetti burst | Multi-colour falling confetti using random ColorSequence keypoints and gravity. | vfx, particles, reward |
| [`vfx/06-tween-particle-numbersequence.luau`](vfx/06-tween-particle-numbersequence.luau.md) | Tween a ParticleEmitter NumberSequence | TweenService cannot tween NumberSequence properties, so drive them from a NumberValue. | vfx, particles, tween |
| [`cutscene/01-camera-cutscene.luau`](cutscene/01-camera-cutscene.luau.md) | Scriptable camera cutscene | Plays a list of camera shots by tweening Camera.CFrame between marker parts, then restores control. | cutscene, camera, tween |
| [`cutscene/02-letterbox.luau`](cutscene/02-letterbox.luau.md) | Letterbox bars | Two black bars slide in for cinematic mode and out afterwards. | cutscene, gui, cinematic |
| [`cutscene/03-camera-shake.luau`](cutscene/03-camera-shake.luau.md) | Simple camera shake | Decaying random camera offset applied each frame on top of the default camera. | cutscene, camera, juice |
| [`cutscene/04-fov-sprint.luau`](cutscene/04-fov-sprint.luau.md) | Sprint FOV kick | Widens field of view while sprinting and eases back. | camera, animation |
| [`animation/01-play-with-markers.luau`](animation/01-play-with-markers.luau.md) | Play an animation and react to keyframe markers | Loads an animation on the character's Animator and fires logic on named KeyframeMarkers (hit frames, footsteps). | animation, combat, markers |
| [`animation/02-combo-client.luau`](animation/02-combo-client.luau.md) | Combo input (client) with server validation | Client sends the intent; the server checks cooldown and combo window. Never trust client timing. | animation, combat, security |
| [`sfx/01-play-with-variation.luau`](sfx/01-play-with-variation.luau.md) | Play an SFX with pitch/volume variation | Clones a template Sound, randomises pitch and volume slightly so repeated hits do not sound identical. | sfx, audio, variation |
| [`sfx/02-soundgroup-mix.luau`](sfx/02-soundgroup-mix.luau.md) | SoundGroup mixing bus | Creates Music / SFX / UI groups, applies a shared Reverb once and exposes volume sliders. | sfx, audio, mixing |
| [`sfx/03-positional-sound.luau`](sfx/03-positional-sound.luau.md) | 3D positional sound with rolloff | A sound attached to a part with a defined audible range. | sfx, audio, 3d |
| [`sfx/04-ui-sound-bus.luau`](sfx/04-ui-sound-bus.luau.md) | Local UI click/hover sounds | Plays UI sounds locally (no replication) through SoundService:PlayLocalSound. | sfx, gui, audio |

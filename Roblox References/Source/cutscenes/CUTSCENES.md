# Roblox Cutscene Catalog

> **Honesty note.** Researched 2026-10-20. Pictures are preview images from public itch.io listings (credits in the root `IMAGE-CREDITS.md` and on each page). Recipes come from general Roblox knowledge and linked DevForum threads, and have **not** been tested in Studio. Many DevForum answers are older, so verify against the current API.

Camera, cinematic and dialogue patterns. Your own reference video: [`visual-refs/animation-refs/CutScene.mp4`](../visual-refs/animation-refs/CutScene.mp4).



## Camera & story

1. [**Intro Fly-over.**](01-intro-fly-over/README.md) Scriptable camera glides over the map to the lobby. Recipe: CameraType Scriptable, tween CFrame between marker parts, restore to Custom.
2. [**Dolly Tracking Shot.**](02-dolly-tracking-shot/README.md) Camera follows a moving subject. Recipe: RenderStepped CFrame lerp to an offset from the target.
3. [**Orbit Reveal.**](03-orbit-reveal/README.md) Camera circles an object or boss. Recipe: CFrame.Angles rotation around a pivot over time.
4. [**Letterbox Bars.**](04-letterbox-bars/README.md) Black bars slide in for cinematic mode. Recipe: two Frames tween Size Y from 0 to 0.12.
5. [**Over-the-Shoulder Dialogue.**](05-over-the-shoulder-dialogue/README.md) Alternating shoulder shots for conversations. Recipe: two camera parts per speaker, cut on lines.
6. [**Boss Intro Cinematic.**](06-boss-intro-cinematic/README.md) Slow reveal, name card, roar, health bar fills. Recipe: tween sequence + camera shake + UI title.
7. [**Round Start Countdown.**](07-round-start-countdown/README.md) 3-2-1 with camera push and sound hits. Recipe: scale-punch TextLabel per second.
8. [**Victory Podium.**](08-victory-podium/README.md) Winners posed on podium, camera pans across. Recipe: cloned rigs + animations.
9. [**Killcam.**](09-killcam/README.md) Replay the killer's view or a freeze with slow-mo. Recipe: camera to killer attachment for 2s.
10. [**Impact Hit-Stop.**](10-impact-hit-stop/README.md) Brief freeze/slow on heavy hits plus a white flash frame. Recipe: AdjustSpeed 0.1 on tracks for 0.08s, overlay flash.
11. [**Fade Transition.**](11-fade-transition/README.md) Fade to black between scenes. Recipe: full-screen Frame transparency tween.
12. [**Comic Panel Split.**](12-comic-panel-split/README.md) Screen splits into panels with slanted dividers. Recipe: multiple ViewportFrames or masked frames.
13. [**Tutorial Camera Guide.**](13-tutorial-camera-guide/README.md) Camera nudges to the next objective then returns. Recipe: short tween, then restore.
14. [**Map Reveal Pan.**](14-map-reveal-pan/README.md) High pan across the arena at match start. Recipe: spline of marker CFrames.
15. [**Item Reveal Spotlight.**](15-item-reveal-spotlight/README.md) Dim the world and spotlight a new pet/item. Recipe: ViewportFrame + rotating model + rarity VFX.
16. [**Jumpscare Zoom.**](16-jumpscare-zoom/README.md) Fast FOV crush and shake with audio sting. Recipe: tween FOV 70 to 40 + shake + overlay.
17. [**Visual-Novel Dialogue Scene.**](17-visual-novel-dialogue-scene/README.md) Portrait, name tag, typewriter text, choices. Recipe: text reveal loop, remote events for choices.
18. [**Rig-Animated Scene.**](18-rig-animated-scene/README.md) Pre-authored scene animated on rigs (Moon Animator or Animation Editor) with a camera rig. Recipe: play tracks on cloned NPCs from a script.


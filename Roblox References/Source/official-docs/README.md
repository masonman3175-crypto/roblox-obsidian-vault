# Official Roblox documentation (bundled)

This folder bundles a **subset** of Roblox's open-source [creator-docs](https://github.com/Roblox/creator-docs) so AI tools can read authoritative API details offline: guides for UI, animation, effects, audio/sound, environment, characters, input, performance and camera, plus API reference YAML for the classes, data types and enums used by the GUI, animation, VFX, cutscene and SFX entries in this repo.

- **Source:** https://github.com/Roblox/creator-docs (commit `d99df2ea0ed1b0ad93acf15b05bfb762c38741e2`, 2026-10-20)
- **Licence:** Creative Commons Attribution 4.0 International. Full text in [LICENSE-CC-BY-4.0.txt](LICENSE-CC-BY-4.0.txt). Copyright Roblox Corporation. Files are copied unmodified (the Roblox code in the repo is under a separate licence, not included here).
- **Not included:** images and videos the guides reference (they use relative links into the original repo), and docs outside the listed areas. For those use https://create.roblox.com/docs.
- Guides use Roblox doc markup such as `Class.ParticleEmitter` links and `<Alert>` tags.


## Guides: animation

- [Animation capture](guides/animation/capture.md): Animation Capture in the Animation Editor allows you to generate high-quality, realistic animations for faces and bodies.
- [Curve Editor](guides/animation/curve-editor.md): Curve Editor is a curve-based animation editing interface that lets you see and modify a rig's position and orientation.
- [Animation Editor](guides/animation/editor.md): Animation Editor allows you to design and publish custom animations on rigs.
- [Animation events](guides/animation/events.md): Animation Events are markers across the timeline span in the Animation Editor.
- [Graph Editor expressions](guides/animation/expressions.md): Expressions let you calculate animation graph property and transition condition values with Luau-like formulas.
- [Graph Editor state machines](guides/animation/graph-editor-state-machine.md): Use state machines in the Animation Graph Editor to organize state-driven animations and control how they transition.
- [Animation Graph Editor](guides/animation/graph-editor.md): The animation graph editor is a visual, node-based tool that lets you build complex animation logic.
- [Animation in Roblox](guides/animation/index.md): An overview of all animation tools in Roblox Studio.
- [Inverse Kinematics](guides/animation/inverse-kinematics.md): Inverse Kinematics is a technique in computer animation to make characters move and interact with their environment.
- [Use animations](guides/animation/using.md): Explains the process of playing animations through scripts, and replacing default animations.

## Guides: audio

- [Audio assets](guides/audio/assets.md): Explore how to find and import audio assets for use in your games.
- [Audio effects](guides/audio/effects.md): Audio effects modify or enhance audio streams in your games.
- [Audio](guides/audio/index.md): An overview of audio features on Roblox.
- [Audio objects](guides/audio/objects.md): An overview of modular audio objects on Roblox.

## Guides: camera

- [Free camera mode](guides/camera/free-camera.md): Free camera mode allows free roam of the local camera around the scene.
- [Customize the camera](guides/camera/index.md): Explains how to configure a game's camera settings.

## Guides: characters

- [Adaptive Animation](guides/characters/adaptive-animation.md): Set up your character rig to support universal sets of animations and emotes.
- [Character appearance](guides/characters/appearance.md): Customize your in-game character appearance and properties.
- [Custom abilities](guides/characters/character-controller-library/custom-abilities.md): Custom abilities in the Character Controller Library (CCL) evaluate what a character can do, as well as enable flexible behavior composition such as a character being able to move while also aiming and crouching.
- [Character Controller Library](guides/characters/character-controller-library/index.md): The Character Controller Library (CCL) is a modular framework for building character movement and behaviors through attributes and Luau scripts.
- [CCL quick start](guides/characters/character-controller-library/quick-start.md): Traditional character abilities (run, climb, jump, swim, etc.) are easily configurable through scripting.
- [Emotes](guides/characters/emotes.md): Emotes are character animations used through chat commands, or accessing the emotes menu.
- [Characters](guides/characters/index.md): Characters are interactive models that players control or interact with in games.
- [Character name/health display](guides/characters/name-health-display.md): You can customize character UI, like name and health displays, using Class.Humanoid.
- [Pathfinding](guides/characters/pathfinding.md): Pathfinding is the process of moving a character or object (agent) along a logical path to reach a destination.

## Guides: effects

- [Beams](guides/effects/beams.md): Beams create a visual, animatable effect between two attachments.
- [Highlighting objects](guides/effects/highlighting.md): Highlighting objects lets you call attention to specific objects within your game.
- [Effects](guides/effects/index.md): Learn how to add visual effects to your games.
- [Light sources](guides/effects/light-sources.md): Light sources simulate realistic lighting from objects such as torches, spotlights, and screens.
- [Particle emitters](guides/effects/particle-emitters.md): Particle emitters emit 2D images to simulate special effects like fire, smoke, and sparks.
- [Trails](guides/effects/trails.md): Trails create visual motion effects as an object moves through space.

## Guides: environment

- [Atmospheric effects](guides/environment/atmosphere.md): Atmospheric effects simulate realistic environments by scattering sunlight in unique ways.
- [Dynamic clouds](guides/environment/clouds.md): Dynamic Clouds render realistic, customizable clouds that drift slowly across the sky.
- [Global wind](guides/environment/global-wind.md): The global wind vector sets the direction and strength that wind blows through a game, affecting terrain grass, dynamic clouds, and particles.
- [Lighting and effects](guides/environment/index.md): Create more immersive environments through lighting, atmospheres, and special effects.
- [Global lighting](guides/environment/lighting.md): Explains how to customize the global lighting with the Lighting service.
- [Post-processing effects](guides/environment/post-processing-effects.md): Post-processing effects are customizable filters that quickly enrich the visuals of a game.
- [Skyboxes](guides/environment/skybox.md): Skyboxes are cubes made up of six individual images that create an immersive background.

## Guides: input

- [Gamepad input](guides/input/gamepad.md): Explains how to accept input from USB gamepads, such as Xbox and PlayStation controllers.
- [Input](guides/input/index.md): Summary of cross-platform input on Roblox and implementation guidelines.
- [Input Action System](guides/input/input-action-system.md): The cross-platform Input Action System lets you connect actions and arrange bindings across various hardware inputs at edit time.
- [Micro gamepad input](guides/input/micro-gamepad.md): Explains how to accept input from micro gamepads, such as TV remotes, which provide directional navigation and a small set of buttons.
- [Mobile input](guides/input/mobile.md): Explains Roblox support for mobile devices.
- [Mouse and keyboard input](guides/input/mouse-and-keyboard.md): Explains Roblox support for computer mice and keyboards.

## Guides: performance-optimization

- [Design for performance](guides/performance-optimization/design.md): Outlines performance best practices to follow as you build a new game.
- [Identify performance issues](guides/performance-optimization/identify.md): Explains how to use Roblox tools to identify performance issues.
- [Improve performance](guides/performance-optimization/improve.md): Lists common performance problems and steps to mitigate them.
- [Performance optimization](guides/performance-optimization/index.md): Introduces the performance optimization process for games on Roblox.
- [MicroProfiler](guides/performance-optimization/microprofiler/index.md): The MicroProfiler is a Studio and client tool for optimizing your games on Roblox.
- [MicroProfiler modes](guides/performance-optimization/microprofiler/modes.md): The MicroProfiler includes several different modes, all of which offer different ways to understand your game's performance profile.
- [Network usage](guides/performance-optimization/microprofiler/network.md): The MicroProfiler provides detailed information on network usage within your game.
- [Tag reference](guides/performance-optimization/microprofiler/tag-table.md): A list of tags for the MicroProfiler.
- [Task scheduler](guides/performance-optimization/microprofiler/task-scheduler.md): Task Scheduler coordinates tasks done in each frame as the game runs.
- [MicroProfiler walkthrough](guides/performance-optimization/microprofiler/use-microprofiler.md): Explains how using the MicroProfiler can help you optimize portions of your game.
- [Monitor performance](guides/performance-optimization/monitor.md): Explains how to use the Performance Dashboard to monitor your games.
- [Scene Analysis](guides/performance-optimization/scene-analysis.md): Use the Scene Analysis tool to identify and resolve performance issues in your game. Check script memory, unparented instances, audio memory, animation memory, the instance composition view, and the extended scene triangle breakdown.
- [Test on hardware](guides/performance-optimization/test-on-hardware.md): Explains why and how to test your game on real devices to catch performance and usability issues before your players do.

## Guides: sound

- [Dynamic effects](guides/sound/dynamic-effects.md): Legacy effects that modify or enhance Sound objects in your games.
- [Sound groups](guides/sound/groups.md): Legacy audio mixers that group multiple Sound objects so you can control the properties of multiple audio signals at once.
- [Sound](guides/sound/index.md): An overview of legacy Sound objects and effects.
- [Sound objects](guides/sound/objects.md): Sound objects are legacy instances that emit sound within a game.

## Guides: ui

- [2D paths](guides/ui/2D-paths.md): The Path2D instance, along with its API methods and properties, lets you implement 2D splines and 2D curved lines.
- [3D drag detectors](guides/ui/3D-drag-detectors.md): 3D drag detectors facilitate and encourage interaction with 3D objects in a game, such as opening doors and drawers, sliding a part around, and much more.
- [UI 9-slice design](guides/ui/9-slice.md): UI 9-slice design lets you create UI elements of varying sizes without distorting the borders or corners.
- [UI animation/tweens](guides/ui/animation.md): Explains how to animate GuiObjects using the process of tweening.
- [UI appearance modifiers](guides/ui/appearance-modifiers.md): Explains how to use appearance modifiers to customize basic user interface objects.
- [Text & image buttons](guides/ui/buttons.md): Buttons allow players to prompt an action.
- [Frames](guides/ui/frames.md): Frames are basic containers for UI objects.
- [Grid and table layouts](guides/ui/grid-table-layouts.md): How to use grid and table layouts for highly structured user interfaces.
- [In-game UI containers](guides/ui/in-experience-containers.md): In-game UI containers hold SurfaceGuis, BillboardGuis, and GuiObjects that you want to display in the 3D space.
- [User interface](guides/ui/index.md): Explore the wide variety of user interface elements that players can interact with.
- [Text & image labels](guides/ui/labels.md): Explore how labels display customizable text and images in user interfaces.
- [List and flex layouts](guides/ui/list-flex-layouts.md): How to use list layouts and flex settings for highly responsive user interfaces.
- [On-screen UI containers](guides/ui/on-screen-containers.md): Learn how to display UI objects on a user's screen.
- [Page layouts](guides/ui/page-layouts.md): Explore how page layouts organize interface content into distinct pages.
- [Position and size UI objects](guides/ui/position-and-size.md): Explains the process of positioning, sizing, and ordering UI objects on a player's screen.
- [Proximity prompts](guides/ui/proximity-prompts.md): Proximity Prompts allow users to trigger actions when they approach objects in the 3D space.
- [Rich text markup](guides/ui/rich-text.md): Rich Text Markup are simple markup tags to style sections of a string.
- [Scrolling frames](guides/ui/scrolling-frames.md): ScrollingFrames feature built-in scrolling interactivity and are ideal for displaying a lot of information in a confined space.
- [Size modifiers and constraints](guides/ui/size-modifiers.md): Explains how use size modifiers and size constraints with user interface objects.
- [UI styling compatibility](guides/ui/styling/compatibility.md): Outlines all of the classes and associated properties which can be styled.
- [CSS Comparisons](guides/ui/styling/css-comparisons.md): Explore how CSS concepts map to Roblox UI styling concepts.
- [Style Editor](guides/ui/styling/editor.md): Explore the built-in Style Editor, a comprehensive tool that allows you to create, manage, and apply UI styles for Roblox games.
- [UI styling](guides/ui/styling/index.md): Explore how stylesheets let you declare and globally apply overrides to UI instance properties.
- [Text filtering](guides/ui/text-filtering.md): Text filtering prevents users from seeing inappropriate language and blocks personally identifiable information.
- [Text input fields](guides/ui/text-input.md): Text input fields allow users to input text from their physical or on-screen keyboard.
- [UI drag detectors](guides/ui/ui-drag-detectors.md): UI drag detectors facilitate and encourage interaction with 2D user interface elements in a game, such as sliders and spinners.
- [Video frames](guides/ui/video-frames.md): Video assets used on VideoFrame instances allow for video playback in games.
- [Viewport frames](guides/ui/viewport-frames.md): ViewportFrames use a camera to render 3D objects into a 2D viewport.

## API reference (class YAML)

[Animation](api/classes/Animation.yaml.md), [AnimationClip](api/classes/AnimationClip.yaml.md), [AnimationConstraint](api/classes/AnimationConstraint.yaml.md), [AnimationController](api/classes/AnimationController.yaml.md), [AnimationTrack](api/classes/AnimationTrack.yaml.md), [Animator](api/classes/Animator.yaml.md), [Atmosphere](api/classes/Atmosphere.yaml.md), [Attachment](api/classes/Attachment.yaml.md), [AudioAnalyzer](api/classes/AudioAnalyzer.yaml.md), [AudioChannelMixer](api/classes/AudioChannelMixer.yaml.md), [AudioChorus](api/classes/AudioChorus.yaml.md), [AudioCompressor](api/classes/AudioCompressor.yaml.md), [AudioDeviceInput](api/classes/AudioDeviceInput.yaml.md), [AudioDeviceOutput](api/classes/AudioDeviceOutput.yaml.md), [AudioDistortion](api/classes/AudioDistortion.yaml.md), [AudioEcho](api/classes/AudioEcho.yaml.md), [AudioEmitter](api/classes/AudioEmitter.yaml.md), [AudioEqualizer](api/classes/AudioEqualizer.yaml.md), [AudioFader](api/classes/AudioFader.yaml.md), [AudioFilter](api/classes/AudioFilter.yaml.md), [AudioFlanger](api/classes/AudioFlanger.yaml.md), [AudioGate](api/classes/AudioGate.yaml.md), [AudioLimiter](api/classes/AudioLimiter.yaml.md), [AudioListener](api/classes/AudioListener.yaml.md), [AudioPitchShifter](api/classes/AudioPitchShifter.yaml.md), [AudioPlayer](api/classes/AudioPlayer.yaml.md), [AudioReverb](api/classes/AudioReverb.yaml.md), [AudioTremolo](api/classes/AudioTremolo.yaml.md), [Beam](api/classes/Beam.yaml.md), [BillboardGui](api/classes/BillboardGui.yaml.md), [BloomEffect](api/classes/BloomEffect.yaml.md), [BlurEffect](api/classes/BlurEffect.yaml.md), [Camera](api/classes/Camera.yaml.md), [CanvasGroup](api/classes/CanvasGroup.yaml.md), [ChorusSoundEffect](api/classes/ChorusSoundEffect.yaml.md), [Clouds](api/classes/Clouds.yaml.md), [ColorCorrectionEffect](api/classes/ColorCorrectionEffect.yaml.md), [CompressorSoundEffect](api/classes/CompressorSoundEffect.yaml.md), [ContentProvider](api/classes/ContentProvider.yaml.md), [ContextActionService](api/classes/ContextActionService.yaml.md), [Debris](api/classes/Debris.yaml.md), [DepthOfFieldEffect](api/classes/DepthOfFieldEffect.yaml.md), [DistortionSoundEffect](api/classes/DistortionSoundEffect.yaml.md), [EchoSoundEffect](api/classes/EchoSoundEffect.yaml.md), [EqualizerSoundEffect](api/classes/EqualizerSoundEffect.yaml.md), [Explosion](api/classes/Explosion.yaml.md), [Fire](api/classes/Fire.yaml.md), [ForceField](api/classes/ForceField.yaml.md), [Frame](api/classes/Frame.yaml.md), [GuiBase2d](api/classes/GuiBase2d.yaml.md), [GuiObject](api/classes/GuiObject.yaml.md), [GuiService](api/classes/GuiService.yaml.md), [Highlight](api/classes/Highlight.yaml.md), [Humanoid](api/classes/Humanoid.yaml.md), [ImageButton](api/classes/ImageButton.yaml.md), [ImageLabel](api/classes/ImageLabel.yaml.md), [Keyframe](api/classes/Keyframe.yaml.md), [KeyframeMarker](api/classes/KeyframeMarker.yaml.md), [KeyframeSequence](api/classes/KeyframeSequence.yaml.md), [LayerCollector](api/classes/LayerCollector.yaml.md), [Lighting](api/classes/Lighting.yaml.md), [Motor6D](api/classes/Motor6D.yaml.md), [ParticleEmitter](api/classes/ParticleEmitter.yaml.md), [Path2D](api/classes/Path2D.yaml.md), [PitchShiftSoundEffect](api/classes/PitchShiftSoundEffect.yaml.md), [Players](api/classes/Players.yaml.md), [PointLight](api/classes/PointLight.yaml.md), [ProximityPrompt](api/classes/ProximityPrompt.yaml.md), [ProximityPromptService](api/classes/ProximityPromptService.yaml.md), [ReverbSoundEffect](api/classes/ReverbSoundEffect.yaml.md), [RunService](api/classes/RunService.yaml.md), [ScreenGui](api/classes/ScreenGui.yaml.md), [ScrollingFrame](api/classes/ScrollingFrame.yaml.md), [Sky](api/classes/Sky.yaml.md), [Smoke](api/classes/Smoke.yaml.md), [Sound](api/classes/Sound.yaml.md), [SoundEffect](api/classes/SoundEffect.yaml.md), [SoundGroup](api/classes/SoundGroup.yaml.md), [SoundService](api/classes/SoundService.yaml.md), [Sparkles](api/classes/Sparkles.yaml.md), [SpotLight](api/classes/SpotLight.yaml.md), [SunRaysEffect](api/classes/SunRaysEffect.yaml.md), [SurfaceGui](api/classes/SurfaceGui.yaml.md), [SurfaceLight](api/classes/SurfaceLight.yaml.md), [TextBox](api/classes/TextBox.yaml.md), [TextButton](api/classes/TextButton.yaml.md), [TextLabel](api/classes/TextLabel.yaml.md), [Trail](api/classes/Trail.yaml.md), [TremoloSoundEffect](api/classes/TremoloSoundEffect.yaml.md), [Tween](api/classes/Tween.yaml.md), [TweenBase](api/classes/TweenBase.yaml.md), [TweenService](api/classes/TweenService.yaml.md), [UIAspectRatioConstraint](api/classes/UIAspectRatioConstraint.yaml.md), [UIComponent](api/classes/UIComponent.yaml.md), [UIConstraint](api/classes/UIConstraint.yaml.md), [UICorner](api/classes/UICorner.yaml.md), [UIDragDetector](api/classes/UIDragDetector.yaml.md), [UIFlexItem](api/classes/UIFlexItem.yaml.md), [UIGradient](api/classes/UIGradient.yaml.md), [UIGridLayout](api/classes/UIGridLayout.yaml.md), [UIGridStyleLayout](api/classes/UIGridStyleLayout.yaml.md), [UILayout](api/classes/UILayout.yaml.md), [UIListLayout](api/classes/UIListLayout.yaml.md), [UIPadding](api/classes/UIPadding.yaml.md), [UIPageLayout](api/classes/UIPageLayout.yaml.md), [UIScale](api/classes/UIScale.yaml.md), [UIShadow](api/classes/UIShadow.yaml.md), [UISizeConstraint](api/classes/UISizeConstraint.yaml.md), [UIStroke](api/classes/UIStroke.yaml.md), [UITableLayout](api/classes/UITableLayout.yaml.md), [UITextSizeConstraint](api/classes/UITextSizeConstraint.yaml.md), [UserInputService](api/classes/UserInputService.yaml.md), [VideoFrame](api/classes/VideoFrame.yaml.md), [ViewportFrame](api/classes/ViewportFrame.yaml.md)


## Data types
[CFrame](api/datatypes/CFrame.yaml.md), [Color3](api/datatypes/Color3.yaml.md), [ColorSequence](api/datatypes/ColorSequence.yaml.md), [ColorSequenceKeypoint](api/datatypes/ColorSequenceKeypoint.yaml.md), [Font](api/datatypes/Font.yaml.md), [NumberRange](api/datatypes/NumberRange.yaml.md), [NumberSequence](api/datatypes/NumberSequence.yaml.md), [NumberSequenceKeypoint](api/datatypes/NumberSequenceKeypoint.yaml.md), [Rect](api/datatypes/Rect.yaml.md), [TweenInfo](api/datatypes/TweenInfo.yaml.md), [UDim](api/datatypes/UDim.yaml.md), [UDim2](api/datatypes/UDim2.yaml.md), [Vector2](api/datatypes/Vector2.yaml.md), [Vector3](api/datatypes/Vector3.yaml.md)


## Enums
[AnimationPriority](api/enums/AnimationPriority.yaml.md), [ApplyStrokeMode](api/enums/ApplyStrokeMode.yaml.md), [AudioFilterType](api/enums/AudioFilterType.yaml.md), [AutomaticSize](api/enums/AutomaticSize.yaml.md), [BorderMode](api/enums/BorderMode.yaml.md), [CameraType](api/enums/CameraType.yaml.md), [EasingDirection](api/enums/EasingDirection.yaml.md), [EasingStyle](api/enums/EasingStyle.yaml.md), [FillDirection](api/enums/FillDirection.yaml.md), [Font](api/enums/Font.yaml.md), [HighlightDepthMode](api/enums/HighlightDepthMode.yaml.md), [HorizontalAlignment](api/enums/HorizontalAlignment.yaml.md), [LineJoinMode](api/enums/LineJoinMode.yaml.md), [NormalId](api/enums/NormalId.yaml.md), [ParticleEmitterShape](api/enums/ParticleEmitterShape.yaml.md), [ParticleEmitterShapeInOut](api/enums/ParticleEmitterShapeInOut.yaml.md), [ParticleEmitterShapeStyle](api/enums/ParticleEmitterShapeStyle.yaml.md), [ParticleFlipbookLayout](api/enums/ParticleFlipbookLayout.yaml.md), [ParticleFlipbookMode](api/enums/ParticleFlipbookMode.yaml.md), [ParticleOrientation](api/enums/ParticleOrientation.yaml.md), [ResamplerMode](api/enums/ResamplerMode.yaml.md), [ReverbType](api/enums/ReverbType.yaml.md), [RollOffMode](api/enums/RollOffMode.yaml.md), [ScaleType](api/enums/ScaleType.yaml.md), [SizeConstraint](api/enums/SizeConstraint.yaml.md), [SortOrder](api/enums/SortOrder.yaml.md), [TextXAlignment](api/enums/TextXAlignment.yaml.md), [TextYAlignment](api/enums/TextYAlignment.yaml.md), [UIFlexMode](api/enums/UIFlexMode.yaml.md), [VerticalAlignment](api/enums/VerticalAlignment.yaml.md), [ZIndexBehavior](api/enums/ZIndexBehavior.yaml.md)

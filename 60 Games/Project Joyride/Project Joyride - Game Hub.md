# Project Joyride - Game Hub

Arcade ice cream truck driving prototype on the default Baseplate. Drift, lean, smash tiny dummies, score combos.

- **Studio place:** Place2 (unsaved local place, no placeId yet). Save it to keep the work.
- **Built:** 2026-10-25 by Claude from Cade's one-shot spec.
- **Status:** playable prototype, solo-tested.

## Controls
W/S accelerate, brake/reverse. A/D steer. Space hold to drift. R reset truck. F3 debug graphs.

## Where things live (Studio)
- `ReplicatedStorage.Joyride`: Config (all tuning), AnimationCurves (easings + analytic spring), VehicleMath, ModelFactory (truck + dummies from parts), RemoteRegistry
- `ServerScriptService.Joyride`: Main + Services (VehicleService, DummyService, HitDetectionService, ScoreService)
- `StarterPlayerScripts.Joyride`: Main + Controllers (Input, Driving, VehicleAnimation, Camera, Effects, Audio, HUD)

## How it works (short)
- Client owns the truck physics. LinearVelocity (plane) + AngularVelocity driven by a custom arcade model: forward/lateral split, exp grip decay, drift blend, yaw controller.
- Chassis box floats on 4 frictionless contact spheres so it rolls over ledges.
- Body roll/pitch/bob is cosmetic only (Motor6D.Transform), springs driven by lateral/long accel.
- Server sweeps the truck box against dummy hitboxes, awards score. Clients animate the flying dummies locally.

## V2 (2026-10-25): game feel and visual overhaul
- Faster: 115 top speed, 90 accel, quicker steering and drift in/out.
- Bigger lean (12 deg, 16 deg drifting), bouncier springs, more squat and dive.
- Speed zoom camera: distance 17 to 37, height 9 to 16, FOV 67 to 95, plus an acceleration FOV kick.
- Anime speed lines (`SpeedLinesController`) above 55 studs/s.
- Hits: client prediction (instant launches), 4 reaction styles (Flyer, Spinner, Bouncer, Tumbler), group-hit intensity, banners (NICE! / MEGA HIT! / MASSIVE COMBO!).
- Cinematic slow-mo (`ImpactDirector`): drifting 45+ studs/s with 6 hits in 0.35s. Only dummies, particles and popups slow down; the truck never does. 3s cooldown.
- Skid marks (`SkidMarkController`): distance-based segments per rear wheel, pooled, fade out.
- Fonts: LuckiestGuy numbers, FredokaOne banners, BuilderSans labels.
- All custom audio off (`Config.Audio.Enabled`).

## Blender truck
- Files in `Blender/`: `build_truck.py` (bpy script that builds it), `joyride_truck.blend`, `joyride_truck.fbx`, `truck_mesh.json`, `preview_*.png`.
- Rebuild: `blender -b --python build_truck.py -- <folder>`
- In game: `ReplicatedStorage.Joyride.TruckMeshData` holds the JSON. `TruckMeshBuilder` builds MeshParts with EditableMesh on each client and welds them to the rig (Body to BodyRoot, Wheel to each Wheel_XX). The parts truck is hidden locally and stays as the fallback.
- Re-import after a rebuild: serve `truck_mesh.json` on localhost, turn on HttpService for a moment, fetch it into `TruckMeshData` chunks, turn it off. Claude can do this.
- Manual option: File > Import 3D in Studio with `joyride_truck.fbx` (objects Body and Wheel), then swap those into the rig instead.

## Notes
- [[Joyride Test Results]]
- [[Joyride Tuning Log]]
- [[Joyride Known Issues]]

## Ideas for later
- Blender truck body to swap in for the parts model (rig is already split from physics).

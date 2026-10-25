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

## Notes
- [[Joyride Test Results]]
- [[Joyride Tuning Log]]
- [[Joyride Known Issues]]

## Ideas for later
- Blender truck body to swap in for the parts model (rig is already split from physics).

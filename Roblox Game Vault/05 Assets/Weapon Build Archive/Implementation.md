# Weapon Build Archive Files

Overview: [[Weapon Build Archive]]. All files here were copied byte-for-byte from local `weapon_reference_rebuild`, including the `polish` and `studio_import` subfolders.

- `MODIFIED_FILE.blend`: five-gun reference-guided scene; `BASELINE.blend` preserves the original rebuild input.
- `01_Walnut_AK.fbx` through `05_Satin_Pump_Shotgun.fbx`: individual rigged exports.
- `studio_import/ReferenceWeapons_Studio.fbx`: consolidated import export.
- `rebuild.py`, `export_studio.py`, `render.py`, `verify_scene.py`, `test.py`: historical build/test scripts.
- `manifest.json`, `studio_import/import_manifest.json`: original manifests.
- `VERIFICATION.txt`, `DIFF_FILE.md`, baseline/modified/rollback logs and `ROLLBACK.sh`: recorded Blender validation, preserved as historical evidence.
- `polish/`: prior ADS/pistol/recoil source, tests, rollback and verification.

The verification files retain their original workstation command paths. They were not re-run as Blender tests during this notes-only sync. [[04 Scripts/Current Runtime Snapshot/Implementation]] and [[Claude AK]] represent later integration. Binary duplicates/backups are retained to preserve the original evidence bundle.

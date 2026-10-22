# Combined Vault - Merge Report

## Result

- Destination: `C:\Users\mason\Downloads\frisbee\frisbee`
- Source (left unchanged): `C:\Users\mason\OneDrive\Desktop\slopshitv1\slopshit`
- Imported **1,324 files**, including **416 Markdown notes**.
- Preserved all **1,710 pre-existing destination files**; Obsidian may update its own workspace/graph state while open.
- **Zero file-path collisions, zero overwritten files, zero renamed source files.**
- Source `.obsidian` settings were deliberately excluded. Other content, including existing evidence/rollback files, was copied as inert data and not executed.
- Both original folder layouts are intact, preserving relative and vault-root paths.
- Empty source folders were also retained.

## Navigation and limitations

[[START HERE - Combined Roblox Vault|Open the combined home]]

The merge verifier checks SHA-256 hashes of every imported file and existing destination content, and compares local wiki/inline-Markdown link targets before and after the union. Unresolved source links are recorded rather than silently invented. Heading/block anchors, reference-style Markdown, dynamic plugin links and visual rendering are not tested by this static checker.

Some Slop project notes already link to files outside the vault (for example, separate game builds). Those external links remain unchanged; the linked external projects are not part of this vault merge. The Roblox references also retain their documented upstream missing links.

This merge does not change Obsidian's registry or delete either original vault. There is no automatic synchronization between the old Slopshit vault and this combined vault.

## Audit and rollback

Audit folder: `C:\Users\mason\Downloads\frisbee\vault-merge`

- `baseline.json`: original source/destination file hashes and folder paths.
- `baseline-links.json`, `modified-links.json`, `link-report.json`: navigation comparison and inherited unresolved links.
- `added-files.json`: exact imported/generated files, with SHA-256 hashes.
- `DIFF_FILE.patch`: additive change inventory and generated-note diffs.
- `VERIFICATION.txt`: executed tests, outputs and rollback evidence.
- `ROLLBACK.sh`: removes only this merge's additions after checking for later edits. Existing destination files are never overwritten by rollback.

Rollback was exercised on a separate copy, not on this combined vault.

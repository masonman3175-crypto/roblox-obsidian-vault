from pathlib import Path
import hashlib, json, shutil, re, sys, difflib, subprocess
from urllib.parse import quote

WORKSPACE = Path(r'C:\Users\mason\OneDrive\Desktop\slopshitv1')
VAULT = WORKSPACE / 'slopshit'
REL = Path('70 Imports') / 'Project Sync 2026-10-18'
DEST = VAULT / REL
STAGE = WORKSPACE / 'obsidian-sync-stage'
START = Path('START HERE - Slop Game Lab.md')
HUB = REL / 'Project Sync - Start Here.md'
PROJECTS = ['claw-machine-empire','fat-chaos','marketing','stat-sim-complete-shop',
 'stat-sim-endless-track','stat-sim-join-banner-fix','stat-sim-monetization',
 'stat-sim-pet-remodel','stat-sim-publish-ready','stat-sim-punch-upgrade',
 'stat-sim-punch-voice','stat-sim-release-fixes','stat-sim-spawn-fixes',
 'stat-sim-track-extension','world-video']

def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''): h.update(chunk)
    return h.hexdigest()

def write(rel, text):
    p=VAULT/rel; p.parent.mkdir(parents=True,exist_ok=True)
    assert not p.exists(), str(p)+' already exists'
    p.write_text(text,encoding='utf-8',newline='\n')
    return p

def note(title, body, kind='handoff'):
    return f'---\ntype: {kind}\nstatus: snapshot\nupdated: 2026-10-18\ntags: [roblox, project-sync]\n---\n\n# {title}\n\n{body}\n'

def link(path, label=None):
    return f'[{label or Path(path).name}]({quote(Path(path).as_posix(),safe="/")})'

def sync():
    assert not DEST.exists(), 'Snapshot exists; verify instead of overwriting it'
    baseline={str(p.relative_to(VAULT).as_posix()):sha(p) for p in VAULT.rglob('*') if p.is_file() and '.obsidian' not in p.relative_to(VAULT).parts}
    baseline_text=(VAULT/START).read_bytes()
    STAGE.mkdir(exist_ok=True)
    (STAGE/'baseline-vault-hashes.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
    print(f'BASELINE PASS: {len(baseline)} existing vault files hashed; START HERE backup retained.')
    DEST.mkdir(parents=True)
    (DEST/'START-HERE.original.md').write_bytes(baseline_text)
    (DEST/'original-hashes.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
    copies=[]
    def copy_file(source, destrel):
        target=VAULT/destrel; target.parent.mkdir(parents=True,exist_ok=True)
        assert not target.exists()
        shutil.copy2(source,target)
        digest=sha(source); assert sha(target)==digest
        copies.append({'source':str(source),'target':destrel.as_posix(),'sha256':digest,'bytes':source.stat().st_size})
    for project in PROJECTS:
        for p in sorted((WORKSPACE/project).rglob('*')):
            if p.is_file() and not any(s in {'.git','__pycache__','node_modules','.venv'} for s in p.relative_to(WORKSPACE/project).parts):
                copy_file(p,REL/'Files'/project/p.relative_to(WORKSPACE/project))
    for p in (WORKSPACE/'.research-audit').glob('*'):
        if p.is_file(): copy_file(p,REL/'Files'/'research-audit'/p.name)
    # Specific files supplied in this conversation; no unrelated Downloads are scanned.
    supplied=[Path(r'C:\Users\mason\Downloads')/n for n in ['ultimate-slop-hub-main.zip','Asian_Boy.blend','Charlie Brown baby you buggin.mp3','audiomass-output.mp3','Punch_Charlie_Brown_to_Level_Up.png']]
    supplied += [Path(r'C:\Users\mason\AppData\Local\Temp')/('codex-clipboard-'+n+'.png') for n in [
      '56780b69-2161-4778-9563-58ec1e0ad08d','3304473b-8851-4984-b181-61638d4e839c',
      '6cf44712-e01c-40ae-a7a7-0e53a1341ce8','53fa510a-6182-4f39-93ec-9c1411694aba',
      '08d423dd-f348-48a4-b85c-99e7510a0ee9','e27ae3bb-6120-4af2-a436-70ff0b642f9e',
      '106f6ea2-0497-4865-92d7-00d06776d8f0','7ecc1b72-ce3f-4f0b-a62d-a87acc4cf6c3',
      '08a77059-dc2b-425e-953b-a799e6009b76','662434b4-98c1-4fb6-818f-c38bd4c1454e',
      'c0e1bfe2-9eb8-496a-8219-11f1338da1a0','0e50a4d6-8145-4e94-974d-6dd5590dd1d8']]
    supplied += [Path(r'C:\Users\mason\.codex\attachments\dc07d484-c66d-4bb9-94cb-edff09b4f037\Pasted text.txt')]
    missing=[]
    for p in supplied:
        if p.is_file(): copy_file(p,REL/'Files'/'User References'/p.name)
        else: missing.append(str(p))
    exports=json.loads((STAGE/'studio-sources.json').read_text(encoding='utf-8'))
    metadata=json.loads((STAGE/'studio-metadata.json').read_text(encoding='utf-8'))
    copy_file(STAGE/'studio-sources.json',REL/'Files'/'Studio Snapshot'/'studio-sources.json')
    copy_file(STAGE/'studio-metadata.json',REL/'Files'/'Studio Snapshot'/'studio-metadata.json')
    source_links=[]
    for entry in exports:
        engine='RbxCharacterSounds' in entry['path']
        relative=Path(*entry['path'].split('.')).with_suffix('.luau')
        # Keep the full final module name: Path.with_suffix treats dotted model paths as extensions only after splitting.
        relative=Path(*entry['path'].split('.')[:-1])/(entry['path'].split('.')[-1]+'.luau')
        raw=REL/'Files'/'Studio Snapshot'/('Engine Runtime Reference' if engine else 'Project Source')/relative
        write(raw,entry['source'])
        title='Studio - '+entry['path']
        nrel=REL/'Studio Notes'/(title+'.md')
        body=f'Back: [[{HUB.with_suffix("").as_posix()}|Project Sync]]\n\n**Instance:** `{entry["path"]}`\n\n**Class:** `{entry["class"]}`\n\n'
        body+='**Provenance:** auto-inserted Roblox runtime reference; do not install as project code.\n\n' if engine else '**Provenance:** current Studio Play server snapshot; not proof of cloud publication.\n\n'
        body+='Raw source: '+link(Path('..')/'Files'/'Studio Snapshot'/('Engine Runtime Reference' if engine else 'Project Source')/relative)+'\n\n```luau\n'+entry['source']+'\n```\n'
        write(nrel,note(title,body,'source'))
        source_links.append(f'- [[{nrel.with_suffix("").as_posix()}|{entry["path"]}]]'+(' — engine reference' if engine else ''))
    # Every original project is preserved, including older prototypes and baseline/rollback files.
    project_links=[]
    for project in PROJECTS+['research-audit','User References']:
        entries=[c for c in copies if c['target'].startswith((REL/'Files'/project).as_posix()+'/')]
        nrel=REL/'Project Notes'/(project+'.md')
        body=f'Back: [[{HUB.with_suffix("").as_posix()}|Project Sync]]\n\n'
        body+='Archived workspace files, not an assertion that every older build is current or published. Prefer [[Current Studio Snapshot]] and [[Current Status and Remaining Work]] for the latest handoff.\n\n'
        body+='\n'.join('- '+link(Path('..')/'Files'/project/Path(c['target']).relative_to(REL/'Files'/project),Path(c['target']).relative_to(REL/'Files'/project).as_posix()) for c in entries)
        write(nrel,note(project,body,'archive'))
        project_links.append(f'- [[{nrel.with_suffix("").as_posix()}|{project}]] — {len(entries)} files')
    write(REL/'Current Studio Snapshot.md',note('Current Studio Snapshot',f'Back: [[{HUB.with_suffix("").as_posix()}|Project Sync]]\n\nPlace `{metadata["placeId"]}`; universe `{metadata["universeId"]}`. Exported without stopping the running playtest. The runtime reports PlaceVersion 0, which is not a cloud version. This is a source snapshot, not an RBXL world backup.\n\n37 project sources plus 2 auto-inserted Roblox character-sound runtime references.\n\n'+ '\n'.join(source_links),'source-index'))
    status='''Back: [[Project Sync - Start Here]] · [[Current Studio Snapshot]] · [[Media and Banner]] · [[Monetization Listing Audit]]

## Verified during work
- Egg presentation: scenery occlusion disabled for odds boards; world-up offset; individual name, price and chance labels. Client loader waits for all seven shipped controllers rather than skipping optional modules during replication.
- Join/rejoin test: 7/7 controllers ready, 11/11 egg boards populated, exactly one world Open Egg prompt per stand; no persistent Hatch x3 world prompt.
- Actual Starter Egg button test: 100 → 75 Coins, one pet added. Session-only fixture restored original Coins, pet inventory and next UID, and was removed.
- Punch voice: uploaded audio asset `83363670294957`; permission granted by the user to universe `10771586872`; client loaded duration 1.933061 seconds. A real manual impact played it; synthetic auto-impact and rapid-impact branch tests retained one reusable voice. Source contains the ending-only clip, restart-at-zero and preload.
- Cinematic: 10-second H.264/AAC MP4, 1280×720, 30 fps; external encode/decode verification preserved in the imported world-video folder.
- Thumbnail files: 1920×1080 JPEG 684342 bytes; alternate indexed PNG 774813 bytes. Original reference unchanged.

## Still open — do not mark shipped
- Egg/join patch was installed and playtested in Studio; saving/publishing that patch to live servers has NOT been verified. The same applies to the final punch-voice source after the interrupted save attempts. Do not claim live players have these changes until published and tested on a fresh server.
- Studio API access was off in observed tests. Studio showed session-only data. Persistence logic exists with a separate Studio data-store name, but a successful real cloud save/rejoin was NOT demonstrated.
- Monetization is incomplete: current source binds 7 developer-product IDs and 0 pass IDs. Local dashboard records contain 12 product IDs; five recorded listings remain unbound in the current snapshot. Mega/Ultra egg IDs and all 13 passes remain zero. Recheck ownership, sale status and actual prices before changing IDs.
- Banner: last Chrome observation shows the new artwork as the only Experience Detail Page thumbnail, with Save Changes disabled (no pending edit). This is stronger evidence than the earlier failed in-app uploads, but the public game page was not rechecked before the user switched tasks. Approval/caching status and public rendering remain unverified.
- Earlier in-app image uploads failed inside Roblox's WebAssembly image processor under Content Security Policy. JPG, JPEG and PNG format/size tests passed locally; those upload errors were not evidence of oversized files. Do not disable browser security protections.

## Next bounded tasks
1. Read [[Current Studio Snapshot]] and compare against Studio Edit sources; keep the old worlds, map, pets and animations intact.
2. Confirm detail-page thumbnail saved and inspect the public game-page carousel, separately from the Home Page thumbnail and square Icon.
3. Publish the tested source changes to the existing place without changing visibility, then test a genuinely fresh live server.
4. Complete and verify each listing and receipt grant; retain the user's R$100 maximum. Do not grant a pass from a zero ID or fake a successful purchase.
5. Verify persistence with approved API access and a genuine disconnect/rejoin, keeping Studio test data separate from live.
'''
    write(REL/'Current Status and Remaining Work.md',note('Current Status and Remaining Work',status))
    media='''Back: [[Project Sync - Start Here]] · [[Current Status and Remaining Work]]

## Upload-ready thumbnail
![[70 Imports/Project Sync 2026-10-18/Files/marketing/thumbnail/Roblox-Thumbnail.png]]

- [[70 Imports/Project Sync 2026-10-18/Files/marketing/thumbnail/Punch-Charlie-Brown-1920x1080.jpg|JPEG — 1920×1080, under 3 MB]]
- [[70 Imports/Project Sync 2026-10-18/Files/marketing/thumbnail/Roblox-Thumbnail.png|PNG — 1920×1080, under 3 MB]]
- Generation prompt and image verification are in the imported marketing folder.

## Cinematic
![[70 Imports/Project Sync 2026-10-18/Files/world-video/World-Trailer-10s.mp4]]

The trailer uses the first 10 seconds of the older full audio file. The punch sound uses the newer 1.93-second trimmed ending; these are distinct deliverables.

## Punch audio
![[70 Imports/Project Sync 2026-10-18/Files/stat-sim-punch-voice/punch-ending.mp3]]

## Banner destinations
- Large game page carousel: Thumbnails → Experience Detail Page.
- Discovery artwork: Thumbnails → Home Page.
- Small square artwork: Icon.

The large banner is not changed by uploading only an Icon. The last observed Chrome detail-page thumbnail was the new artwork; public rendering remained unchecked.
'''
    write(REL/'Media and Banner.md',note('Media and Banner',media,'media'))
    mono=next(e['source'] for e in exports if e['path']=='ReplicatedStorage.Shared.Config.Monetization')
    recorded={}
    for folder in ['stat-sim-monetization','stat-sim-release-fixes']:
        p=WORKSPACE/folder/'created-ids.json'
        if p.exists(): recorded.update(json.loads(p.read_text(encoding='utf-8-sig')))
    rows=[]; section=''
    for line in mono.splitlines():
        if 'Monetization.Passes = {' in line: section='Pass'
        if 'Monetization.Products = {' in line: section='Product'
        m=re.match(r'\s*(\w+) = \{Id = (\d+), Price = (\d+),.*?Name = "([^"]+)"',line)
        if m:
            key,asset,price,name=m.groups()
            rec=recorded.get(key)
            state='Bound in snapshot; sale not rechecked' if int(asset) else ('Recorded ID not bound' if rec else 'No ID in snapshot or local records')
            rows.append(f'| {section} | {key} — {name} | {price} | {asset} | {rec or "—"} | {state} |')
    write(REL/'Monetization Listing Audit.md',note('Monetization Listing Audit','Back: [[Project Sync - Start Here]] · [[Current Status and Remaining Work]]\n\nSource/catalog prices are intended values, not proof of current sale prices. User cap: R$100.\n\n| Type | Offer | Catalog R$ | Snapshot ID | Local recorded ID | Status |\n|---|---|---:|---|---|---|\n'+'\n'.join(rows)+'\n\nInspect the imported cartoon icons in stat-sim-complete-shop/icons. No listing was created or changed during this vault sync.','audit'))
    refs=[
      ('Original collection-loop inspiration','https://www.youtube.com/watch?v=elqpTtfFD40','User-linked reference; not a new video review.'),
      ('Claw-machine direction video','https://www.youtube.com/watch?v=I12L26L6-Mo','User-linked visual reference; not a new video review.'),
      ('Punch meme audio reference','https://www.youtube.com/watch?v=c9KI_kDvhtg','Source reference; user supplied local audio separately.'),
      ('Tripo model reference','https://studio.tripo3d.ai/3d-model/6695a2b1-4dc4-4402-aa61-280376734874','User-provided model page; model availability must be checked.'),
      ('Roblox thumbnails','https://create.roblox.com/docs/production/publishing/thumbnails','Detail-page versus Home Page thumbnails; image requirements.'),
      ('Roblox audio assets','https://create.roblox.com/docs/audio/assets','Audio import and usage access.'),
      ('Roblox asset privacy','https://create.roblox.com/docs/projects/assets/privacy','Experience usage permissions.'),
      ('Roblox BillboardGui','https://create.roblox.com/docs/reference/engine/classes/BillboardGui','AlwaysOnTop and world-space positioning.'),
      ('Roblox Ads Manager','https://create.roblox.com/docs/production/promotion/ads-manager','Campaign and group-role access; no ad was launched.'),
      ('Roblox groups','https://create.roblox.com/docs/projects/groups','Group roles, game ownership and collaboration.'),
      ('Roblox collaboration','https://create.roblox.com/docs/projects/collaboration','Shared Studio access differs from group ad roles.'),
      ('Forge MCP endpoint','https://forgegui.com/mcp','User-mentioned integration endpoint; connection status not verified by this sync.')]
    write(REL/'Reference Additions.md',note('Reference Additions','Back: [[Project Sync - Start Here]] · [[Reference Library]] · [[Video Review Desk]]\n\nExisting vault research and the Ultimate Slop Hub import are preserved, not replaced. The source-registry and reference-catalog audit files are also archived.\n\n'+'\n'.join(f'- [{title}]({url}) — {desc}' for title,url,desc in refs)+'\n\nUser attachments are copied byte-for-byte under Files/User References when still available; this sync does not claim to have freshly reviewed every archived image.','reference'))
    prompt='''Back: [[Project Sync - Start Here]] · [[Current Status and Remaining Work]] · [[Current Studio Snapshot]]

```text
Continue the existing Charlie Brown punching simulator; do not replace it with a new place.
Read Current Status and Remaining Work, Monetization Listing Audit, Media and Banner,
then the current source snapshots and matching live Studio scripts.
Keep the original worlds and visual style; preserve unrelated map, pet and UI work.
Choose one next bounded task. Inspect and back up the exact sources before editing.
Do not treat archived prototype installers as the latest release.
All prices must stay at or below R$100. Never grant purchases from zero IDs.
Keep coin hatching server-authoritative, show actual odds and grant paid eggs only
after a verified receipt. Do not invent listings, publishing, cloud saves or passes.
Test a fresh join, one real hatch, the relevant impact/purchase path and rollback.
Remove temporary playtest fixtures, preserve original data, and record literal results.
Confirm the final save/publish succeeded before calling it shipped.
Update this vault's handoff after the task with what changed, evidence and open work.
```
'''
    write(REL/'Coding Robot Handoff.md',note('Coding Robot Handoff',prompt,'prompt'))
    hub='''This is a non-destructive snapshot of the current workspace and Studio source, not a claim that all work is published.

## Start here
- [[Current Status and Remaining Work]] — verified work versus unfinished release items.
- [[Current Studio Snapshot]] — current source notes and raw Luau exports.
- [[Monetization Listing Audit]] — all 27 catalog offers, bound IDs and missing bindings.
- [[Media and Banner]] — thumbnail, cinematic and trimmed punch sound.
- [[Coding Robot Handoff]] — reusable continuation prompt.
- [[Reference Additions]] — links discussed during implementation.

## Existing library
- [[START HERE - Slop Game Lab]]
- [[Reference Library]]
- [[Video Review Desk]]
- [[70 Imports/Ultimate Slop Hub/Ultimate Slop Hub - Import Index|Ultimate Slop Hub import]]
- [[60 Games/Claw Machine Empire/Claw Machine Empire - Game Hub|Claw Machine Empire]]
- [[60 Games/Stat Sim/Stat Sim - Track Extension|Stat Sim track work]]

## Full project archive
'''+ '\n'.join(project_links)+'\n\n## Snapshot boundaries\n- Copies include project assets, scripts, external tests, baselines, rollback files and all trailer frames. Older experiments are retained as historical archives.\n- Dependency runtimes/caches, .git folders and Obsidian workspace settings are not copied.\n- The separate O Blah Warfare / hood warfare vault in Documents is a different project and was left untouched.\n- Source hashes and copied-file hashes are in manifest.json.\n'
    write(HUB,note('Project Sync - Start Here',hub,'map'))
    write(REL/'MODIFIED_FILE.md',note('Current Project Handoff',f'Open [[{HUB.with_suffix("").as_posix()}|Project Sync - Start Here]].\n\nChanged field: START HERE navigation gains a link to this complete project snapshot. All pre-existing research and project files are preserved.','map'))
    addition='\n\n## Latest complete project sync — 2026-10-18\n- [['+HUB.with_suffix('').as_posix()+'|Current code, assets, video, listing audit and handoff]]\n'
    updated=baseline_text.decode('utf-8')+addition
    (VAULT/START).write_text(updated,encoding='utf-8',newline='\n')
    diff=''.join(difflib.unified_diff(baseline_text.decode('utf-8').splitlines(True),updated.splitlines(True),fromfile=str(START)+' (before)',tofile=str(START)+' (after)'))
    write(REL/'DIFF_FILE.diff',diff)
    copy_file(Path(__file__),REL/'sync_vault.py')
    rollback='''#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "${PYTHON_OVERRIDE:-C:/Users/mason/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe}" "$HERE/sync_vault.py" rollback "$@"
'''
    write(REL/'ROLLBACK.sh',rollback)
    created=[p.relative_to(VAULT).as_posix() for p in DEST.rglob('*') if p.is_file()]
    manifest={'date':'2026-10-18','vault':str(VAULT),'snapshot':REL.as_posix(),'original_start_hash':hashlib.sha256(baseline_text).hexdigest(),'modified_start_hash':sha(VAULT/START),'baseline':baseline,'copies':copies,'created':created,'missing_supplied_files':missing,'scripts':len(exports),'project_scripts':sum('RbxCharacterSounds' not in e['path'] for e in exports),'engine_reference_scripts':sum('RbxCharacterSounds' in e['path'] for e in exports)}
    (DEST/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(f'SYNC PASS: {len(copies)} files copied byte-for-byte; {len(exports)} Studio sources exported; {len(rows)} offers indexed.')

def verify():
    m=json.loads((DEST/'manifest.json').read_text(encoding='utf-8'))
    for rel,digest in m['baseline'].items():
        if rel!=START.as_posix(): assert sha(VAULT/rel)==digest, 'Existing file altered: '+rel
    assert sha(VAULT/START)==m['modified_start_hash']
    for c in m['copies']: assert sha(VAULT/c['target'])==c['sha256'],c['target']
    files=list(DEST.rglob('*')); notes=[p for p in files if p.is_file() and p.suffix=='.md']
    all_notes=list(VAULT.rglob('*.md'))
    for p in notes:
        if 'Files' in p.relative_to(DEST).parts or p.name=='START-HERE.original.md': continue
        text=p.read_text(encoding='utf-8')
        for target in re.findall(r'\[\[([^\]|]+)(?:\|[^\]]*)?\]\]',text):
            target=target.split('#')[0]
            if not target: continue
            exact=VAULT/target
            valid=exact.exists() or Path(str(exact)+'.md').exists() or any(q.stem==target for q in all_notes)
            assert valid,f'Broken link: {p.name} -> {target}'
    assert (DEST/'Files/world-video/World-Trailer-10s.mp4').stat().st_size==7616626
    png=DEST/'Files/marketing/thumbnail/Roblox-Thumbnail.png'; assert png.stat().st_size==774813
    report={'copied_files':len(m['copies']),'copied_bytes':sum(c['bytes'] for c in m['copies']),'snapshot_markdown_files':len(notes),'project_scripts':m['project_scripts'],'engine_reference_scripts':m['engine_reference_scripts'],'original_files_preserved':len(m['baseline'])-1,'missing_supplied_files':m['missing_supplied_files']}
    (DEST/'verification-results.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('VERIFY PASS: '+json.dumps(report,separators=(',',':')))

def rollback(root, apply):
    root=Path(root).resolve()
    snap=(root/REL).resolve()
    assert snap.is_relative_to(root) and root.name in {'slopshit','rollback-fixture'},'Unexpected rollback target'
    m=json.loads((snap/'manifest.json').read_text(encoding='utf-8'))
    if not apply:
        print('ROLLBACK DRY RUN: restore original START HERE; remove only snapshot-created files. Add --apply to execute.'); return
    target=root/START
    assert sha(target) in {m['modified_start_hash'],m['original_start_hash']},'START HERE changed since sync; preserve newer edits'
    target.write_bytes((snap/'START-HERE.original.md').read_bytes())
    assert sha(target)==m['original_start_hash']
    # Remove only files whose resolved paths are contained inside this exact snapshot directory.
    paths=[p for p in snap.rglob('*') if p.is_file()]
    for p in paths:
        assert p.resolve().is_relative_to(snap),'Rollback path escapes snapshot'
    for p in paths: p.unlink()
    for p in sorted([p for p in snap.rglob('*') if p.is_dir()],key=lambda p:len(p.parts),reverse=True): p.rmdir()
    snap.rmdir()
    print('ROLLBACK PASS: original START HERE hash restored; snapshot removed only from target copy.')

def rollback_test():
    fixture=STAGE/'rollback-fixture'
    attempt=1
    while fixture.exists():
        attempt+=1
        fixture=STAGE/('rollback-attempt-'+str(attempt))/'rollback-fixture'
    snap=fixture/REL; snap.mkdir(parents=True)
    for name in ['manifest.json','START-HERE.original.md','ROLLBACK.sh','sync_vault.py']:
        shutil.copy2(DEST/name,snap/name)
    shutil.copy2(VAULT/START,fixture/START)
    probe=snap/'Files'/'rollback-probe.txt'; probe.parent.mkdir(parents=True); probe.write_text('isolated generated copy')
    bash=r'C:\Program Files\Git\bin\bash.exe'
    result=subprocess.run([bash,str(snap/'ROLLBACK.sh'),'--apply','--target-root',str(fixture)],capture_output=True,text=True)
    assert result.returncode==0,result.stdout+result.stderr
    m=json.loads((DEST/'manifest.json').read_text(encoding='utf-8'))
    assert sha(fixture/START)==m['original_start_hash'] and not snap.exists()
    assert sha(VAULT/START)==m['modified_start_hash'] and DEST.exists()
    print(result.stdout.strip())
    print('ACTIVE VAULT PASS: modified navigation and full synced snapshot remain intact.')

if __name__=='__main__':
    command=sys.argv[1]
    if command=='sync': sync()
    elif command=='verify': verify()
    elif command=='rollback-test': rollback_test()
    elif command=='rollback':
        root=sys.argv[sys.argv.index('--target-root')+1] if '--target-root' in sys.argv else str(VAULT)
        rollback(root,'--apply' in sys.argv)
    else: raise ValueError(command)

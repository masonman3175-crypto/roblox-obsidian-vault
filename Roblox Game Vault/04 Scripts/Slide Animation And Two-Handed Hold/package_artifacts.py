import json,pathlib,hashlib,difflib
r=pathlib.Path(__file__).parent
b=json.loads((r/'BASELINE.json').read_text(encoding='utf-8-sig'));m=json.loads((r/'MODIFIED_SOURCES.json').read_text(encoding='utf-8-sig'))
test=(r/'TEST_ROLLBACK.luau').read_text(encoding='utf-8-sig')
installer=test.split(' local game=fixture\n',1)[1].split('\nend)()',1)[0]
(r/'MODIFIED_FILE.luau').write_text(installer,encoding='utf-8')
diff=[]
for path,source in m.items():
 (r/(path.replace('.','_')+'.luau')).write_text(source,encoding='utf-8')
 diff.extend(difflib.unified_diff(b.get(path,'').splitlines(True),source.splitlines(True),fromfile='BASELINE/'+path,tofile='MODIFIED/'+path))
(r/'CharacterPose.luau').write_text(m['ReplicatedStorage.GameplayPresentation.CharacterPose'],encoding='utf-8')
(r/'DIFF_FILE.md').write_text('# Slide Animation And Two-Handed Hold\n\nChanged branch: rig guard accepts Motor6D and AnimationConstraint; one post-animation pose writer. Movement ground() probes with original standing height during the slide transition. HipDrop .35 -> 1.05; CameraDrop 1.45 -> .65. Weapon grips are profile targets solved through both arm chains. Camera and damage sources retained.\n\n```diff\n'+''.join(diff)+'\n```\n',encoding='utf-8')
hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest().upper() for p in r.iterdir() if p.is_file()}
(r/'HASHES.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
print('PASS: installer extracted from tested fixture; 5 final sources + diff written')
print('BASELINE_SHA256',hashes['BASELINE.json'])
print('MODIFIED_SHA256',hashes['MODIFIED_FILE.luau'])

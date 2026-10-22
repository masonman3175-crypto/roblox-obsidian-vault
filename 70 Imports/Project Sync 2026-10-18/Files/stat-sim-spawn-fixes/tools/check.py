from pathlib import Path
import json,hashlib,difflib,tempfile,shutil,sys
R=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def baseline():
 for p,h in json.loads((R/'baseline/SHA256.json').read_text()).items():assert sha(R/'baseline'/p)==h,p
 s=json.loads((R/'baseline/scene.json').read_text());assert s['effects']['Bloom']['Intensity']==1 and len(s['dummyParts'])==5
 print('BASELINE_PASS scene_backup=preserved original_dummy_parts=5 bloom=1')
def build():
 old=(R/'baseline/scene.json').read_text();new=(R/'evidence/modified-scene.json').read_text()
 (R/'evidence/DIFF_FILE.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='baseline/scene.json',tofile='evidence/modified-scene.json')))
 (R/'baseline/SHA256.json').write_text(json.dumps({p.name:sha(p)for p in (R/'baseline').iterdir()if p.name!='SHA256.json'},indent=2))
 (R/'evidence/MODIFIED_SHA256.json').write_text(json.dumps({p:sha(R/p)for p in ['MODIFIED_FILE.luau','evidence/STUDIO_ROLLBACK.luau','tests/COPY_ROLLBACK.luau','evidence/modified-scene.json']},indent=2))
 print('BUILD_PASS scene_diff=written hashes=sealed')
def verify():
 for p,h in json.loads((R/'evidence/MODIFIED_SHA256.json').read_text()).items():assert sha(R/p)==h,p
 old=json.loads((R/'baseline/scene.json').read_text());new=json.loads((R/'evidence/modified-scene.json').read_text())
 assert old['scripts']==new['scripts'],'Unrelated gameplay script changed'
 assert len(new['dummyParts'])==10 and sum(p['class']=='MeshPart'for p in new['dummyParts'])==9
 assert abs(new['effects']['Bloom']['Intensity']-.14)<1e-5 and abs(new['lighting']['ExposureCompensation']+.12)<1e-5
 assert abs(new['boardPivot'][0]+100)<.01 and abs(new['boardPivot'][2]-31)<.01
 print('MODIFIED_PASS board=off_spawn dummy_meshes=9 bloom=0.14 gameplay_sources=unchanged')
def rollback(test):
 src=R/'evidence/modified-scene.json';expected=json.loads((R/'evidence/MODIFIED_SHA256.json').read_text())['evidence/modified-scene.json']
 assert sha(src)==expected,'Later edit; rollback stopped'
 if not test:
  shutil.copy2(R/'baseline/scene.json',src);print('LOCAL_MANIFEST_RESTORED Studio=unchanged run=evidence/STUDIO_ROLLBACK.luau');return
 before=sha(src)
 with tempfile.TemporaryDirectory(dir=R/'evidence',prefix='rollback-copy-')as t:
  p=Path(t)/'scene.json';shutil.copy2(src,p);unrelated=Path(t)/'unrelated.txt';unrelated.write_text('keep')
  assert sha(p)==expected;shutil.copy2(R/'baseline/scene.json',p)
  assert sha(p)==sha(R/'baseline/scene.json')and unrelated.read_text()=='keep'
 assert sha(src)==before
 print('LOCAL_ROLLBACK_PASS copy=restored unrelated=preserved live=retained')
if __name__=='__main__':
 mode=sys.argv[1]
 if mode=='build':build()
 elif mode=='baseline':baseline()
 elif mode=='verify':verify()
 elif mode=='rollback':rollback('--test'in sys.argv)

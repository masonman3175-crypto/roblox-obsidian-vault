"""Local integrity and real rollback-on-copy tests. Never controls the Studio process."""
from pathlib import Path
import argparse, hashlib, json, shutil, tempfile

ROOT=Path(__file__).resolve().parents[1]
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path): return path.read_text(encoding='utf-8')
def baseline():
 b=ROOT/'baseline'
 hashes=json.loads(read(b/'sha256.json'))
 for path,want in hashes.items(): assert sha(b/path)==want, f'Original backup changed: {path}'
 d=json.loads(read(b/'sources.json'))
 assert len(d['pets'])==10 and len(d['stands'])==11 and len(d['sources'])==7
 assert (b/'scene.rbxm').read_bytes().startswith(b'<roblox!')
 print('BASELINE_PASS originals=7 models=10 stands=11 hashes=preserved')
def verify():
 m=json.loads(read(ROOT/'manifest.json'))
 assert len(m['source_sha256'])==8
 for name,want in m['source_sha256'].items(): assert sha(ROOT/'src'/f'{name}.luau')==want, name
 assert 'local sources={' in read(ROOT/'MODIFIED_FILE.luau')
 assert len(read(ROOT/'DIFF_FILE.diff'))>20000
 assert 'Preview = true' in read(ROOT/'src/PetsController.luau')
 assert 'ShapeStyle.Surface' in read(ROOT/'src/PetModelBuilder.luau')
 assert 'ShapeStyle.Surface' in read(ROOT/'src/EggVisual.luau')
 scene=json.loads(read(ROOT/'evidence/installed-scene.json'))
 assert len(scene['pets'])==63 and sum(p['massive'] for p in scene['pets'])==10 and len(scene['eggs'])==11
 assert all(e['preview'] for e in scene['eggs']) and scene['dummyMeshes']==9 and scene['trackParts']==34986
 assert abs(scene['bloom']-.14)<.001
 for name,path in m['paths'].items(): assert scene['sources'][path]==m['source_sha256'][name]
 print('MODIFIED_PASS modules=8 pets=63 massive=10 eggs=11 particles=surface preview=normalized')
def restore(target):
 target=target.resolve()
 assert target.is_relative_to(ROOT) and target not in (ROOT,ROOT/'src',ROOT/'baseline'), 'Use an isolated copy inside this package'
 m=json.loads(read(ROOT/'manifest.json'))
 for name in m['source_sha256']:
  original=ROOT/'baseline/tree'/f'{name}.luau'
  destination=target/f'{name}.luau'
  if original.exists(): shutil.copy2(original,destination)
  elif destination.exists(): destination.unlink()
 for name,want in m['original_sha256'].items(): assert sha(target/f'{name}.luau')==want, 'Restored source hash: '+name
 assert len(list(target.glob('*.luau')))==5
def rollback(test,target):
 if test:
  before={p.name:sha(p) for p in (ROOT/'src').glob('*.luau')}
  with tempfile.TemporaryDirectory(prefix='rollback-copy-',dir=ROOT) as tmp:
   copy=Path(tmp)/'src';shutil.copytree(ROOT/'src',copy)
   marker=copy/'unrelated.txt';marker.write_text('preserve',encoding='utf-8')
   restore(copy);assert read(marker)=='preserve'
  assert before=={p.name:sha(p) for p in (ROOT/'src').glob('*.luau')}
  print('ROLLBACK_PASS copy=original_sources_5 added_modules=removed unrelated=preserved live_files=retained')
 else:
  assert target, '--target must name an isolated source copy; use --test for the default self-test'
  restore(Path(target));print('ROLLBACK_RESTORED target='+str(Path(target).resolve()))

if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('command',choices=['baseline','verify','rollback'])
 ap.add_argument('--test',action='store_true');ap.add_argument('--target');args=ap.parse_args()
 if args.command=='baseline': baseline()
 elif args.command=='verify': verify()
 else: rollback(args.test,args.target)

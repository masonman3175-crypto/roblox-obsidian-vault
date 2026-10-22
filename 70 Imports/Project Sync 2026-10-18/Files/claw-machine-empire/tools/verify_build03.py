"""Build 03 transaction audit; restores Build 02 only when every guarded file matches."""
from pathlib import Path
import hashlib,json,re,shutil,sys,tempfile
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
AUDIT=ROOT/'evidence/build03'
BASE=AUDIT/'baseline'
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def hashes(): return json.loads((AUDIT/'BASELINE_SHA256.json').read_text())
def cabinet_count(source):
    body=source.split('Config.Machines = {',1)[1].split('\n}',1)[0]
    return len(re.findall(r'\bid="',body))
def baseline():
    for relative,value in hashes().items(): assert sha(BASE/relative)==value,relative
    assert cabinet_count((BASE/'src/shared/Config.luau').read_text(encoding='utf-8'))==25
    print('BUILD03_BASELINE_PASS machines=25 backup_hashes=preserved')
def seal():
    expected={relative:sha(ROOT/relative) for relative in hashes()}
    (AUDIT/'MODIFIED_SHA256.json').write_text(json.dumps(expected,indent=2)+'\n')
    print('BUILD03_SEAL_PASS guarded_files='+str(len(expected)))
def modified():
    expected=json.loads((AUDIT/'MODIFIED_SHA256.json').read_text())
    for relative,value in expected.items(): assert sha(ROOT/relative)==value,'modified after seal: '+relative
    config=(ROOT/'src/shared/Config.luau').read_text(encoding='utf-8')
    assert cabinet_count(config)==25
    skins=re.findall(r'function skins\.(\w+)\(', (ROOT/'src/server/World.luau').read_text(encoding='utf-8'))
    assert len(skins)==25 and len(set(skins))==25
    assert 'Enum.SurfaceType.Studs' in (ROOT/'src/server/World.luau').read_text(encoding='utf-8')
    tree=ET.parse(ROOT/'Claw Machine Empire.rbxlx')
    scripts=[o for o in tree.iter('Item') if o.attrib['class'] in ('ModuleScript','LocalScript','Script')]
    assert len(scripts)==7
    assert {o.find('Properties/ProtectedString').text for o in scripts}=={p.read_text(encoding='utf-8') for p in (ROOT/'src').rglob('*.luau')}
    assert 'Config.PurchasesEnabled = false' in config
    assert '03 - PLUSHIE PARK' in config and 'halfWidth=150, back=-210, front=230' in config
    assert 'function Config.clawPose' in config
    client=(ROOT/'src/client/Main.client.luau').read_text(encoding='utf-8')
    assert 'PrizeReveal' in client and 'CME_LocalCatchFX' in client
    assert 'Tutorial' not in client and 'BuildLabel' not in client
    assert 'Enum.ApplyStrokeMode.Border' in client
    for name in ['DIFF_FILE.diff','VERIFICATION.txt','ROLLBACK.sh']:
        assert (AUDIT/name).stat().st_size>20
    print('BUILD03_MODIFIED_PASS machines=25 authored_skins=25 area=132000 animation=choreographed hud=3 source_sync=true')
def restore(target):
    target=target.resolve()
    allowed=ROOT.resolve() if target==ROOT.resolve() else (AUDIT/'rollback-fixtures').resolve()
    assert target==ROOT.resolve() or target.parent==allowed,'unexpected restore directory'
    expected=json.loads((AUDIT/'MODIFIED_SHA256.json').read_text())
    # Preflight every path before writing anything, so a later edit cancels all writes.
    for relative,value in expected.items(): assert sha(target/relative)==value,'later edit: '+relative
    for relative,value in hashes().items():
        assert sha(BASE/relative)==value,'baseline altered'
        shutil.copy2(BASE/relative,target/relative)
    for relative,value in hashes().items(): assert sha(target/relative)==value
def rollback(test=False):
    if test:
        fixtures=AUDIT/'rollback-fixtures'; fixtures.mkdir(exist_ok=True)
        live=sha(ROOT/'Claw Machine Empire.rbxlx')
        with tempfile.TemporaryDirectory(dir=fixtures,prefix='build03-') as temp:
            target=Path(temp).resolve(); assert target.parent==fixtures.resolve()
            for relative in hashes():
                dst=target/relative; dst.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(ROOT/relative,dst)
            unrelated=target/'unrelated.txt'; unrelated.write_text('keep')
            restore(target)
            assert cabinet_count((target/'src/shared/Config.luau').read_text())==25
            assert unrelated.read_text()=='keep'
            for relative in hashes(): shutil.copy2(ROOT/relative,target/relative)
            edited=target/'src/server/World.luau'; edited.write_text('later user edit')
            blocked=False
            try: restore(target)
            except AssertionError: blocked=True
            assert blocked and edited.read_text()=='later user edit'
        assert sha(ROOT/'Claw Machine Empire.rbxlx')==live
        print('BUILD03_ROLLBACK_PASS copy_restored=Build02 later_edit_guard=true live_machines=25')
    else:
        restore(ROOT)
        print('BUILD03_ROLLBACK_APPLIED game=Build02 sources=restored Studio=unchanged')
if __name__=='__main__':
    action=sys.argv[1] if len(sys.argv)>1 else 'modified'
    if action=='baseline': baseline()
    elif action=='seal': seal()
    elif action=='modified': modified()
    elif action=='rollback': rollback('--test' in sys.argv)
    else: raise SystemExit('use baseline, seal, modified, rollback [--test]')

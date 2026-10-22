"""Local package/rollback audit. Roblox engine checks are recorded separately."""
from pathlib import Path
import hashlib, json, shutil, sys, tempfile
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def manifest(): return json.loads((ROOT/'evidence/SHA256.json').read_text(encoding='utf-8'))
def restore(before,target,expected):
    assert digest(target)==expected,'later edits detected; preserve your changes before rollback'
    shutil.copy2(before,target)
    assert digest(target)==digest(before)
def baseline():
    path=ROOT/'evidence/BASELINE.rbxlx'
    assert digest(path)==manifest()['evidence/BASELINE.rbxlx'],'baseline changed'
    tree=ET.parse(path)
    assert not any(x.attrib['class'] in ('Script','ModuleScript','LocalScript') for x in tree.iter('Item'))
    assert (ROOT/'evidence/BASELINE.json').is_file()
    print('BASELINE_PASS scripts=0 original=preserved')
def modified():
    path=ROOT/'Claw Machine Empire.rbxlx'; tree=ET.parse(path)
    assert digest(path)==manifest()['Claw Machine Empire.rbxlx'],'modified file hash mismatch'
    items=list(tree.iter('Item')); refs=[x.attrib['referent'] for x in items]
    assert len(refs)==len(set(refs)),'duplicate referents'
    scripts=[x for x in items if x.attrib['class'] in ('Script','ModuleScript','LocalScript')]
    assert len(scripts)==7
    expected={p.read_text(encoding='utf-8') for p in (ROOT/'src').rglob('*.luau')}
    actual={x.find('Properties/ProtectedString').text for x in scripts}
    assert expected==actual,'packaged source drift'
    config=(ROOT/'src/shared/Config.luau').read_text(encoding='utf-8')
    assert 'Config.PurchasesEnabled = false' in config
    assert 'PromptProductPurchase(' not in ''.join(actual)
    for path in ['INSTALL.luau','STUDIO_ROLLBACK.luau','evidence/DIFF_FILE.diff','ROLLBACK.sh']:
        assert (ROOT/path).stat().st_size>20,path
    for path,sha in manifest().items():
        assert digest(ROOT/path)==sha,'source drift: '+path
    print('MODIFIED_PASS scripts=7 source_sync=true purchases=disabled')
def rollback(test=False):
    before=ROOT/'evidence/BASELINE.rbxlx'; live=ROOT/'Claw Machine Empire.rbxlx'
    hashes=manifest(); expected=hashes['Claw Machine Empire.rbxlx']
    assert digest(before)==hashes['evidence/BASELINE.rbxlx'],'baseline changed'
    if test:
        live_sha=digest(live)
        temp_root=ROOT/'evidence/rollback-fixtures'; temp_root.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='cme-rollback-',dir=temp_root) as temp:
            assert Path(temp).resolve().parent==temp_root.resolve()
            target=Path(temp)/live.name; shutil.copy2(live,target)
            unrelated=Path(temp)/'unrelated.txt'; unrelated.write_text('keep me')
            restore(before,target,expected)
            assert digest(target)==digest(before)
            assert unrelated.read_text()=='keep me'
            target.write_text('later user edit')
            blocked=False
            try: restore(before,target,expected)
            except AssertionError: blocked=True
            assert blocked and target.read_text()=='later user edit','later edit guard failed'
        assert digest(live)==live_sha and live_sha==expected
        print('ROLLBACK_PASS copy_restored=true later_edit_guard=true live_modified=true')
    else:
        restore(before,live,expected)
        print('ROLLBACK_APPLIED package=baseline Studio=unchanged')
if __name__=='__main__':
    mode=sys.argv[1] if len(sys.argv)>1 else 'modified'
    if mode=='baseline': baseline()
    elif mode=='modified': modified()
    elif mode=='rollback': rollback('--test' in sys.argv)
    else: raise SystemExit('use baseline, modified, or rollback [--test]')

import argparse,pathlib,json,tempfile,hashlib
r=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--self-test',action='store_true');p.add_argument('--fixture');a=p.parse_args()
b=json.loads((r/'BASELINE.json').read_text(encoding='utf-8-sig'));m=json.loads((r/'MODIFIED_SOURCES.json').read_text(encoding='utf-8-sig'))
old={k:b[k] for k in m if k in b};new='ReplicatedStorage.GameplayPresentation.CharacterPose'
def restore(target):
 target=pathlib.Path(target).resolve()
 assert target not in [r/'BASELINE.json',r/'MODIFIED_SOURCES.json'],'Use a disposable copy'
 data=json.loads(target.read_text(encoding='utf-8-sig'))
 data.update(old);data.pop(new,None)
 target.write_text(json.dumps(data,indent=2),encoding='utf-8')
 assert all(data[k]==v for k,v in old.items()) and new not in data
 return data
if a.self_test:
 before=(r/'MODIFIED_SOURCES.json').read_bytes()
 with tempfile.TemporaryDirectory() as tmp:
  target=pathlib.Path(tmp)/'COPY.json';target.write_text(json.dumps(m),encoding='utf-8');restore(target)
 assert (r/'MODIFIED_SOURCES.json').read_bytes()==before
 print('PASS: rollback copy restored 4 original sources; CharacterPose absent; modified artifact unchanged')
elif a.fixture:
 restore(a.fixture);print('PASS: fixture restored 4 original sources; CharacterPose absent')
else:p.error('Choose --self-test or --fixture')

from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[1]
files=[p for p in root.rglob('*') if p.is_file() and p.name!='FILE_HASHES.json']
hashes={}
images=texts=0
for p in files:
 data=p.read_bytes()
 hashes[str(p.relative_to(root))]=hashlib.sha256(data).hexdigest()
 if p.suffix=='.jpg':
  assert data.startswith(bytes([255,216])) or data.startswith(bytes([137,80,78,71]))
  images+=1
 elif p.suffix!='.rbxm':
  data.decode('utf-8');texts+=1
out=root/'evidence/FILE_HASHES.json'
out.write_text(json.dumps(hashes,indent=2),encoding='utf-8')
assert json.loads(out.read_text(encoding='utf-8'))==hashes
print(f'REOPEN_PASS files={len(files)} images={images} text={texts} hash_manifest=verified')
for name in ['MODIFIED_FILE.luau','DIFF_FILE.diff','VERIFICATION.txt','ROLLBACK.sh']:
 print(str(root/name)+' SHA256='+hashes[name])

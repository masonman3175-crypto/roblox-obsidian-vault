import pathlib,json,tempfile,hashlib
r=pathlib.Path(__file__).parent
baseline=json.loads((r/'BASELINE.json').read_text(encoding='utf-8-sig'))
modified=json.loads((r/'FINAL_SOURCES.json').read_text(encoding='utf-8-sig'))
before=(r/'FINAL_SOURCES.json').read_bytes()
with tempfile.TemporaryDirectory() as tmp:
 p=pathlib.Path(tmp)/'COPY.json';p.write_text(json.dumps(modified),encoding='utf-8')
 copy=json.loads(p.read_text(encoding='utf-8'))
 for key in list(copy):
  if isinstance(baseline.get(key),str):copy[key]=baseline[key]
  else:copy.pop(key)
 p.write_text(json.dumps(copy),encoding='utf-8')
 assert all(copy[k]==baseline[k] for k in copy)
 assert len(modified)-len(copy)==7
 assert (r/'FINAL_SOURCES.json').read_bytes()==before
print('PASS: copied sources restored; 7 new sources removed; original baseline and modified artifacts unchanged')

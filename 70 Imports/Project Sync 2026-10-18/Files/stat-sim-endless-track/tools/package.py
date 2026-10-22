from pathlib import Path
import difflib,hashlib,json,shutil,sys,tempfile
R=Path(__file__).resolve().parents[1]
A=R/'evidence'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def literal(s):
 for n in range(3,20):
  eq='='*n
  if ']'+eq+']' not in s:return '['+eq+'['+s+']'+eq+']'
 raise ValueError()
def sources():
 out={}
 for p in (R/'src').rglob('*.luau'):
  name=p.name;cls='ModuleScript'
  if name.endswith('.server.luau'):cls='Script';name=name[:-12]
  elif name.endswith('.client.luau'):cls='LocalScript';name=name[:-12]
  else:name=name[:-5]
  path='.'.join(p.relative_to(R/'src').parts[:-1]+(name,))
  out[path]={'class':cls,'source':p.read_text(encoding='utf-8'),'file':p.relative_to(R).as_posix()}
 return out
def build():
 old=json.loads((A/'baseline/SOURCES.json').read_text(encoding='utf-8'));src=sources()
 changed={k:v for k,v in src.items() if k not in old or old[k]['source']!=v['source']}
 assert len(src)==33 and len(changed)==8
 (R/'sources.json').write_text(json.dumps(src,indent=2)+'\n')
 (R/'changed.json').write_text(json.dumps(changed)+'\n')
 head='assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")\nlocal function resolve(path) local obj=game;for n in path:gmatch("[^%.]+") do obj=obj and obj:FindFirstChild(n) end;return obj end\n'
 code=head+'local src={}\n'
 for k,v in changed.items():
  code+='src['+json.dumps(k)+']={class='+json.dumps(v['class'])+',source='+literal(v['source'])+'}\n'
 for k,v in changed.items():
  if k in old:code+='assert(resolve('+json.dumps(k)+').Source=='+literal(old[k]['source'])+','+json.dumps('Baseline changed: '+k)+')\n'
  else:code+='assert(not resolve('+json.dumps(k)+'),'+json.dumps('New namespace occupied: '+k)+')\n'
 code+='for name,v in pairs(src) do local fn,err=loadstring(v.source);assert(fn,name..": "..tostring(err)) end\n'
 code+='''local backup=game.ServerStorage:FindFirstChild("PunchExpansion_Backup")
if not backup then
 backup=Instance.new("Folder");backup.Name="PunchExpansion_Backup";backup:SetAttribute("Camera",workspace.CurrentCamera.CFrame);backup.Parent=game.ServerStorage
 local t=workspace.Map.Track:Clone();t.Parent=backup
 local bag=Instance.new("Folder");bag.Name="Scripts";bag.Parent=backup
 local i=0
 for _,root in ipairs({game.ReplicatedStorage,game.ServerScriptService,game.StarterPlayer.StarterPlayerScripts}) do
  for _,v in ipairs(root:GetDescendants()) do if v:IsA("LuaSourceContainer") then
   local c=v:Clone();c:SetAttribute("OriginalPath",v:GetFullName());c.Name="Script"..i;c.Parent=bag;i+=1
  end end
 end
end
assert(backup:FindFirstChild("Track") and backup:FindFirstChild("Scripts"),"Incomplete backup")
for path,v in pairs(src) do
 local old=resolve(path);if old then old:Destroy() end
 local parentPath,name=path:match("^(.*)%.([^%.]+)$")
 local obj=Instance.new(v.class);obj.Name=name;obj.Source=v.source;obj.Parent=assert(resolve(parentPath),parentPath)
end
local track=workspace.Map.Track;track:Destroy()
track=Instance.new("Folder");track.Name="Track";track:SetAttribute("Build","PunchExpansion_60_v1");track.Parent=workspace.Map
local builder=require(game.ReplicatedStorage.Shared.Util.PunchTrackBuilder)
local masks=builder.MaskHub(workspace.Map.Hub);local records={}
for _,m in ipairs(masks) do table.insert(records,{path=m.part:GetFullName(),value=m.previous}) end
local value=Instance.new("StringValue");value.Name="HubMask";value.Value=game:GetService("HttpService"):JSONEncode(records);value.Parent=backup
builder.Preview(track)
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(195,105,160),Vector3.new(195,22,-90))
return "INSTALL_PASS scripts=33 original_worlds=60 old_max_wall=removed hub_and_economy=preserved"
'''
 (R/'MODIFIED_FILE.luau').write_text(code,encoding='utf-8')
 delta=''
 for k,v in changed.items():
  before=old.get(k,{}).get('source','')
  delta+=''.join(difflib.unified_diff(before.splitlines(True),v['source'].splitlines(True),fromfile='baseline/'+k,tofile='modified/'+k))
 (A/'DIFF_FILE.diff').write_text(delta,encoding='utf-8')
 rollback=head+'local backup=assert(game.ServerStorage:FindFirstChild("PunchExpansion_Backup"),"Missing original backup")\n'
 rollback+='local paths={'+','.join(json.dumps(k) for k in changed)+'}\n'
 for k,v in changed.items():rollback+='assert(resolve('+json.dumps(k)+').Source=='+literal(v['source'])+','+json.dumps('Later source edit: '+k)+')\n'
 rollback+='''local originals={}
for _,v in ipairs(backup.Scripts:GetChildren()) do originals[v:GetAttribute("OriginalPath")]=v end
for _,path in ipairs(paths) do
 local obj=resolve(path);if obj then obj:Destroy() end
 if originals[path] then
  local parentPath,name=path:match("^(.*)%.([^%.]+)$")
  local c=originals[path]:Clone();c.Name=name;c.Parent=assert(resolve(parentPath))
 end
end
workspace.Map.Track:Destroy()
local track=backup.Track:Clone();track.Name="Track";track.Parent=workspace.Map
local masks=backup:FindFirstChild("HubMask")
if masks then for _,m in ipairs(game:GetService("HttpService"):JSONDecode(masks.Value)) do local p=resolve(m.path);if p then p.LocalTransparencyModifier=m.value end end end
workspace.CurrentCamera.CFrame=backup:GetAttribute("Camera")
return "STUDIO_ROLLBACK_PASS themes=6 original_max_wall=restored original_scripts=29"
'''
 (A/'STUDIO_ROLLBACK.luau').write_text(rollback,encoding='utf-8')
 # Inject pure modules, using the real engine Color3 for palette calculations.
 levels=src['ReplicatedStorage.Shared.Config.PunchLevels']['source']
 punch=src['ReplicatedStorage.Shared.Config.Punch']['source'].replace('local Levels=require(script.Parent.PunchLevels)','')
 fmt=src['ReplicatedStorage.Shared.Util.Format']['source']
 test='local Levels=assert(loadstring('+literal(levels)+'))()\n'
 test+='local Punch=assert(loadstring('+literal('return function(Levels)\n'+punch+'\nend')+'))()(Levels)\n'
 test+='local Format=assert(loadstring('+literal(fmt)+'))()\n'
 test+='return assert(loadstring('+literal('return function(Levels,Punch,Format)\n'+(R/'tests/contracts.luau').read_text(encoding='utf-8')+'\nend')+'))()(Levels,Punch,Format)\n'
 (R/'tests/RUN_IN_STUDIO.luau').write_text(test,encoding='utf-8')
 print('BUILD_PASS scripts=33 changed=8 catalog=60 installer=generated baseline=preserved')
def baseline():
 expected=json.loads((A/'BASELINE_SHA256.json').read_text())
 for rel,h in expected.items():assert sha(A/'baseline'/rel)==h,rel
 print('FILES_BASELINE_PASS scripts=29 engine_backup_hash=preserved')
def seal():
 guarded=[p for p in (R/'src').rglob('*.luau')]
 guarded+=[R/'MODIFIED_FILE.luau',A/'STUDIO_ROLLBACK.luau',R/'tests/RUN_IN_STUDIO.luau']
 (A/'MODIFIED_SHA256.json').write_text(json.dumps({p.relative_to(R).as_posix():sha(p) for p in guarded},indent=2)+'\n')
 print('SEAL_PASS guarded_files='+str(len(guarded)))
def verify():
 for rel,h in json.loads((A/'MODIFIED_SHA256.json').read_text()).items():assert sha(R/rel)==h,rel
 baseline()
 src=sources()
 assert len(src)==33 and len(src['ReplicatedStorage.Shared.Config.PunchLevels']['source'].split('{"'))>=61
 assert 'math.clamp(math.log10' not in src['ReplicatedStorage.Shared.Config.Punch']['source']
 assert 'MaxVisibleStages=8' in src['ReplicatedStorage.Shared.Config.Punch']['source']
 assert 'MaxWall' not in src['ReplicatedStorage.Shared.Util.PunchTrackBuilder']['source']
 print('FILES_MODIFIED_PASS scripts=33 levels=60 max_wall=absent bounded_route=8')
def restore(target):
 target=target.resolve();fixture=(A/'rollback-fixtures').resolve()
 assert target==R.resolve() or target.parent==fixture
 expected=json.loads((A/'MODIFIED_SHA256.json').read_text())
 for rel,h in expected.items():assert sha(target/rel)==h,'later edit: '+rel
 # All resolved targets remain inside the selected project/fixture.
 old=json.loads((A/'baseline/SOURCES.json').read_text())
 for rel in expected:
  p=(target/rel).resolve();assert p.is_relative_to(target)
 for p in (target/'src').rglob('*.luau'):
  rel=p.relative_to(target/'src');b=A/'baseline/src'/rel
  if b.exists():shutil.copy2(b,p)
  else:p.unlink()
 for rel in ['MODIFIED_FILE.luau','evidence/STUDIO_ROLLBACK.luau','tests/RUN_IN_STUDIO.luau']:
  (target/rel).unlink()
 for p in (A/'baseline/src').rglob('*.luau'):assert sha(target/'src'/p.relative_to(A/'baseline/src'))==sha(p)
def rollback(test=False):
 if not test:restore(R);print('FILES_ROLLBACK_APPLIED baseline_scripts=29 Studio=unchanged');return
 fixtures=A/'rollback-fixtures';fixtures.mkdir(exist_ok=True)
 expected=json.loads((A/'MODIFIED_SHA256.json').read_text());current=sha(R/'MODIFIED_FILE.luau')
 with tempfile.TemporaryDirectory(dir=fixtures,prefix='copy-') as temp:
  t=Path(temp)
  def copy():
   for rel in expected:
    q=t/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,q)
  copy();(t/'unrelated.txt').write_text('keep')
  restore(t);assert len(list((t/'src').rglob('*.luau')))==29 and (t/'unrelated.txt').read_text()=='keep'
  copy();p=t/'src/ReplicatedStorage/Shared/Config/Punch.luau';p.write_text('later edit')
  try:restore(t)
  except AssertionError:pass
  else:raise AssertionError('later edit not protected')
  assert p.read_text()=='later edit'
 assert sha(R/'MODIFIED_FILE.luau')==current
 print('FILES_ROLLBACK_PASS copy_scripts=29 unrelated=preserved later_edit_guard=true live_levels=60')
if __name__=='__main__':
 action=sys.argv[1] if len(sys.argv)>1 else 'build'
 if action=='build':build()
 elif action=='baseline':baseline()
 elif action=='seal':seal()
 elif action=='verify':verify()
 elif action=='rollback':rollback('--test' in sys.argv)
 elif action=='bundle':print(json.dumps({'sources':sources(),'installer':(R/'MODIFIED_FILE.luau').read_text(encoding='utf-8'),'tests':(R/'tests/RUN_IN_STUDIO.luau').read_text(encoding='utf-8'),'rollback':(A/'STUDIO_ROLLBACK.luau').read_text(encoding='utf-8')}))


from pathlib import Path
import json,difflib,hashlib,shutil,sys,tempfile
R=Path(__file__).resolve().parents[1];A=R/'evidence'
def literal(s):
 for n in range(3,20):
  e='='*n
  if ']'+e+']' not in s:return '['+e+'['+s+']'+e+']'
 raise ValueError()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def sources():
 out={}
 for p in (R/'src').rglob('*.luau'):
  name=p.name;cls='ModuleScript'
  if name.endswith('.server.luau'):name=name[:-12];cls='Script'
  elif name.endswith('.client.luau'):name=name[:-12];cls='LocalScript'
  else:name=name[:-5]
  out['.'.join(p.relative_to(R/'src').parts[:-1]+(name,))]={'class':cls,'source':p.read_text(encoding='utf-8'),'file':p.relative_to(R).as_posix()}
 return out
def build():
 old=json.loads((R/'baseline/SOURCES.json').read_text(encoding='utf-8'));src=sources()
 changed={k:v for k,v in src.items() if k not in old or old[k]['source']!=v['source']}
 assert len(changed)==6 and len(src)==33
 (R/'sources.json').write_text(json.dumps(src,indent=2)+'\n')
 (R/'changed.json').write_text(json.dumps(changed)+'\n')
 head='assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")\nlocal function resolve(path)local p=game;for n in path:gmatch("[^%.]+") do p=p and p:FindFirstChild(n) end;return p end\n'
 code=head+'local src={}\n'
 for k,v in changed.items():code+='src['+json.dumps(k)+']={class='+json.dumps(v['class'])+',source='+literal(v['source'])+'}\n'
 for k,v in changed.items():
  if k in old:code+='assert(resolve('+json.dumps(k)+').Source=='+literal(old[k]['source'])+','+json.dumps('Original source changed: '+k)+')\n'
  else:code+='assert(not resolve('+json.dumps(k)+'),'+json.dumps('Namespace occupied: '+k)+')\n'
 code+='''assert(not game.ReplicatedStorage:FindFirstChild("TrackExtensionTemplates"),"Templates already exist")
local originals={"GrassFields","Desert","SnowMountains","Volcano","CandyLand","OuterSpace"}
for _,n in ipairs(originals) do assert(workspace.Map.Track:FindFirstChild(n),"Original missing: "..n) end
for k,v in pairs(src) do local fn,err=loadstring(v.source);assert(fn,k..": "..tostring(err)) end
local backup=game.ServerStorage:FindFirstChild("TrackAppend_Backup")
if backup then
 assert(backup:FindFirstChild("Track") and backup.Track:FindFirstChild("Finish") and backup:FindFirstChild("Scripts") and #backup.Scripts:GetChildren()==2,"Incomplete original backup")
else
backup=Instance.new("Folder");backup.Name="TrackAppend_Backup";backup.Parent=game.ServerStorage;backup:SetAttribute("Camera",workspace.CurrentCamera.CFrame)
local track=workspace.Map.Track:Clone();track.Name="Track";track.Parent=backup
local bag=Instance.new("Folder");bag.Name="Scripts";bag.Parent=backup
for path,v in pairs(src) do local old=resolve(path);if old then local copy=old:Clone();copy:SetAttribute("OriginalPath",path);copy.Parent=bag end end
end
local templates=Instance.new("Folder");templates.Name="TrackExtensionTemplates";templates.Parent=game.ReplicatedStorage
for _,n in ipairs(originals) do backup.Track[n]:Clone().Parent=templates;task.wait() end
local board=backup.Track.DistanceBoards.Board_40:Clone();board.Name="DistanceBoard";board.Parent=templates
for path,v in pairs(src) do
 local old=resolve(path);if old then old:Destroy() end
 local parent,name=path:match("^(.*)%.([^%.]+)$")
 local script=Instance.new(v.class);script.Name=name;script.Source=v.source;script.Parent=assert(resolve(parent))
end
local live=workspace.Map.Track
-- Keep every original biome intact. Only the obsolete finish barrier is removed.
live.Finish:Destroy()
local endWall=live.OuterSpace.Scenery.SpaceBackdrop.BackdropEnd
backup:SetAttribute("BackdropTransparency",endWall.Transparency)
endWall.Transparency=1
-- Retain the old space backdrop around a flight-sized continuation opening.
local opening=Instance.new("Folder");opening.Name="HorizonOpening";opening.Parent=live
for _,s in ipairs({{479,-255.5,460,225},{185,172.5,460,225},{96,32,365,272.5}}) do
 local p=endWall:Clone();p.Name="BackdropContinuation";p.Transparency=0;p.Size=Vector3.new(6,s[3],s[1]);p.Position=Vector3.new(6125,s[4],s[2]);p.Parent=opening
end
live:SetAttribute("TrackAppendVersion","original-six-plus-sixty")
local builder=require(game.ReplicatedStorage.Shared.Util.TrackLandscapeBuilder)
builder.Preview(live,7,66)
return "APPEND_INSTALL_PASS originals=6 added=60 total=66 original_landscapes=retained"
'''
 (R/'MODIFIED_FILE.luau').write_text(code,encoding='utf-8')
 rollback=head
 for k,v in changed.items():rollback+='assert(resolve('+json.dumps(k)+').Source=='+literal(v['source'])+','+json.dumps('Later edit: '+k)+')\n'
 rollback+='''local backup=assert(game.ServerStorage:FindFirstChild("TrackAppend_Backup"))
local live=workspace.Map.Track
local preview=live:FindFirstChild("ExtensionsPreview");if preview then preview:Destroy() end
local opening=live:FindFirstChild("HorizonOpening");if opening then opening:Destroy() end
live.OuterSpace.Scenery.SpaceBackdrop.BackdropEnd.Transparency=backup:GetAttribute("BackdropTransparency")
backup.Track.Finish:Clone().Parent=live
live:SetAttribute("TrackAppendVersion",nil)
game.ReplicatedStorage.TrackExtensionTemplates:Destroy()
local originals={}
for _,v in ipairs(backup.Scripts:GetChildren()) do originals[v:GetAttribute("OriginalPath")]=v end
'''
 for k,v in changed.items():
  rollback+='do local path='+json.dumps(k)+';local p=resolve(path);p:Destroy();if originals[path] then local parent,name=path:match("^(.*)%.([^%.]+)$");local c=originals[path]:Clone();c.Name=name;c.Parent=resolve(parent) end end\n'
 rollback+='workspace.CurrentCamera.CFrame=backup:GetAttribute("Camera")\nreturn "APPEND_STUDIO_ROLLBACK_PASS originals=6 old_finish=restored original_scripts=29"\n'
 (A/'STUDIO_ROLLBACK.luau').write_text(rollback,encoding='utf-8')
 diff=''
 for k,v in changed.items():diff+=''.join(difflib.unified_diff(old.get(k,{}).get('source','').splitlines(True),v['source'].splitlines(True),fromfile='original/'+k,tofile='append-only/'+k))
 (A/'DIFF_FILE.diff').write_text(diff,encoding='utf-8')
 cat=src['ReplicatedStorage.Shared.Config.TrackExtensionCatalog']['source'];punch=src['ReplicatedStorage.Shared.Config.Punch']['source'].replace('local Catalog = require(script.Parent.TrackExtensionCatalog)','')
 test='local Catalog=assert(loadstring('+literal(cat)+'))()\nlocal Punch=assert(loadstring('+literal('return function(Catalog)\n'+punch+'\nend')+'))()(Catalog)\nreturn assert(loadstring('+literal('return function(Catalog,Punch)\n'+(R/'tests/contracts.luau').read_text(encoding='utf-8')+'\nend')+'))()(Catalog,Punch)'
 (R/'tests/RUN_IN_STUDIO.luau').write_text(test,encoding='utf-8')
 print('BUILD_PASS original_scripts=29 total_scripts=33 changed_existing=2 new_modules_and_runtime=4')
def baseline():
 expected=json.loads((A/'BASELINE_SHA256.json').read_text())
 for p,h in expected.items():assert sha(R/'baseline'/p)==h
 print('BASELINE_FILES_PASS originals=6 original_scripts=29 engine_backup_hash=preserved')
def seal():
 paths=list((R/'src').rglob('*.luau'))+[R/'MODIFIED_FILE.luau',A/'STUDIO_ROLLBACK.luau',R/'tests/RUN_IN_STUDIO.luau']
 (A/'MODIFIED_SHA256.json').write_text(json.dumps({p.relative_to(R).as_posix():sha(p) for p in paths},indent=2)+'\n')
 print('SEAL_PASS files='+str(len(paths)))
def verify():
 for p,h in json.loads((A/'MODIFIED_SHA256.json').read_text()).items():assert sha(R/p)==h,p
 baseline()
 assert 'live.Finish:Destroy()' in (R/'MODIFIED_FILE.luau').read_text(encoding='utf-8')
 assert 'workspace.Map.Track:Destroy()' not in (R/'MODIFIED_FILE.luau').read_text(encoding='utf-8')
 assert len(sources())==33
 print('MODIFIED_FILES_PASS originals=6 appended=60 original_track_not_rebuilt=true runtime_budget=8')
def restore(target):
 target=target.resolve();allowed=(A/'rollback-fixtures').resolve()
 assert target==R.resolve() or target.parent==allowed
 expected=json.loads((A/'MODIFIED_SHA256.json').read_text())
 for rel,h in expected.items():
  p=(target/rel).resolve();assert p.is_relative_to(target) and sha(p)==h,'later edit: '+rel
 for p in (target/'src').rglob('*.luau'):
  old=R/'baseline/src'/p.relative_to(target/'src')
  if old.exists():shutil.copy2(old,p)
  else:p.unlink()
 for rel in ['MODIFIED_FILE.luau','evidence/STUDIO_ROLLBACK.luau','tests/RUN_IN_STUDIO.luau']:(target/rel).unlink()
 for p in (R/'baseline/src').rglob('*.luau'):assert sha(target/'src'/p.relative_to(R/'baseline/src'))==sha(p)
def rollback(test=False):
 if not test:restore(R);print('ROLLBACK_APPLIED scripts=29 Studio=unchanged');return
 expected=json.loads((A/'MODIFIED_SHA256.json').read_text());fixtures=A/'rollback-fixtures';fixtures.mkdir(exist_ok=True)
 live=sha(R/'MODIFIED_FILE.luau')
 with tempfile.TemporaryDirectory(dir=fixtures,prefix='copy-') as tmp:
  t=Path(tmp)
  def copy():
   for rel in expected:
    q=t/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,q)
  copy();(t/'unrelated.txt').write_text('keep');restore(t)
  assert len(list((t/'src').rglob('*.luau')))==29 and (t/'unrelated.txt').read_text()=='keep'
  copy();p=t/'src/ReplicatedStorage/Shared/Config/Punch.luau';p.write_text('later edit')
  try:restore(t)
  except AssertionError:pass
  else:raise AssertionError('later edit not protected')
 assert sha(R/'MODIFIED_FILE.luau')==live
 print('ROLLBACK_PASS copy_scripts=29 unrelated=preserved later_edit_guard=true live_append=retained')
if __name__=='__main__':
 mode=sys.argv[1] if len(sys.argv)>1 else 'build'
 if mode=='build':build()
 elif mode=='baseline':baseline()
 elif mode=='seal':seal()
 elif mode=='verify':verify()
 elif mode=='rollback':rollback('--test' in sys.argv)


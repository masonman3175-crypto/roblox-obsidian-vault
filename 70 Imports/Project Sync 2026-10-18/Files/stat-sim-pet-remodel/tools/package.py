from pathlib import Path
import json, difflib, hashlib

ROOT=Path(__file__).resolve().parents[1]
paths={
 'PetDesigns':'ReplicatedStorage.Shared.Config.PetDesigns',
 'PetModelBuilder':'ReplicatedStorage.Shared.Util.PetModelBuilder',
 'EggVisual':'ReplicatedStorage.Shared.Util.EggVisual',
 'PetVisual':'ReplicatedStorage.Shared.Util.PetVisual',
 'PetController':'StarterPlayer.StarterPlayerScripts.Controllers.PetController',
 'PetsController':'StarterPlayer.StarterPlayerScripts.Controllers.PetsController',
 'HatchController':'StarterPlayer.StarterPlayerScripts.Controllers.HatchController',
 'EggService':'ServerScriptService.Services.EggService',
}
baseline=json.loads((ROOT/'baseline/sources.json').read_text(encoding='utf-8'))['sources']
originals={name:baseline[path]['source'] for name,path in paths.items() if path in baseline}
(ROOT/'baseline/tree').mkdir(exist_ok=True)
for name,source in originals.items():
 (ROOT/'baseline/tree'/f'{name}.luau').write_text(source,encoding='utf-8',newline='\n')
sources={name:(ROOT/'src'/f'{name}.luau').read_text(encoding='utf-8') for name in paths}
def literal(s):
 delimiter='===='
 assert ']'+delimiter+']' not in s
 return '['+delimiter+'['+s+']'+delimiter+']'
payload='local sources={\n'+''.join('['+json.dumps(paths[name])+']='+literal(source)+',\n' for name,source in sources.items())+'}\n'
installer='''-- Run in the authorized Studio EDIT DataModel. Makes no economy or global-lighting changes.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installation")
assert(game.PlaceId==98823628319724,"Wrong place")
assert(game.ServerStorage:FindFirstChild("PetRemodel_Backup"),"Create the original backup first")
'''+payload+'''
local function resolve(path)
 local x=game
 for n in path:gmatch("[^.]+") do x=x:FindFirstChild(n) assert(x,"Missing parent "..path) end
 return x
end
local order={"ReplicatedStorage.Shared.Config.PetDesigns","ReplicatedStorage.Shared.Util.PetModelBuilder","ReplicatedStorage.Shared.Util.EggVisual","ReplicatedStorage.Shared.Util.PetVisual","StarterPlayer.StarterPlayerScripts.Controllers.PetController","StarterPlayer.StarterPlayerScripts.Controllers.PetsController","StarterPlayer.StarterPlayerScripts.Controllers.HatchController","ServerScriptService.Services.EggService"}
-- Compile every source before touching the live place.
for path,source in sources do local fn,err=loadstring(source) assert(fn,path..": "..tostring(err)) end
for _,path in order do
 local parentPath,name=path:match("^(.*)%.([^.]+)$")
 local parent=resolve(parentPath)
 local old=parent:FindFirstChild(name)
 local m=Instance.new("ModuleScript");m.Name=name;m.Source=sources[path];m:SetAttribute("PetRemodelVersion",1)
 if old then old:Destroy() end
 m.Parent=parent
end
local pets=Instance.new("Folder");pets.Name="PetModels_RemodelStaging"
local Builder=require(game.ReplicatedStorage.Shared.Util.PetModelBuilder)
local ids={} for id in require(game.ReplicatedStorage.Shared.Config.Pets).List do table.insert(ids,id) end table.sort(ids)
for i,id in ids do Builder.Build(id).Parent=pets if i%7==0 then task.wait() end end
assert(#pets:GetChildren()==63)
local old=game.ReplicatedStorage:FindFirstChild("PetModels") if old then old:Destroy() end
pets.Name="PetModels";pets.Parent=game.ReplicatedStorage
local E=require(game.ReplicatedStorage.Shared.Util.EggVisual)
local n=0
for _,stand in workspace.Map.Gameplay:GetDescendants() do
 if stand:IsA("BasePart") and stand:GetAttribute("EggId") then
  for _,x in stand:GetChildren() do if x.Name=="EggPreview" or x.Name=="Egg" then x:Destroy() end end
  local model=E.Make(stand:GetAttribute("EggId"))
  model.Name="EggPreview";model:PivotTo(stand.CFrame*CFrame.new(0,stand.Size.Y/2+3.4,0));model.Parent=stand
  n+=1
 end
end
assert(n==11)
game.ServerStorage.PetRemodel_Backup:SetAttribute("InstalledVersion",1)
return "INSTALL_PASS pet_models=63 egg_previews=11 sources=8 economy=untouched"
'''
(ROOT/'MODIFIED_FILE.luau').write_text(installer,encoding='utf-8',newline='\n')
diff=''
for name in paths:
 diff+=''.join(difflib.unified_diff(originals.get(name,'').splitlines(True),sources[name].splitlines(True),fromfile='baseline/'+name+'.luau',tofile='src/'+name+'.luau'))
(ROOT/'DIFF_FILE.diff').write_text(diff,encoding='utf-8',newline='\n')
(ROOT/'manifest.json').write_text(json.dumps({'paths':paths,'source_sha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()},'original_sha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in originals.items()}},indent=2),encoding='utf-8')
print('PACKAGE_PASS modules=8 baseline=5')

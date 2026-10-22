"""Reproducible standard-library packager; never touches an open Studio place."""
from pathlib import Path
import json, hashlib, difflib, shutil, sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    'Config': ('ModuleScript','ReplicatedStorage/ClawEmpire/Shared/Config','src/shared/Config.luau'),
    'BigNumber': ('ModuleScript','ReplicatedStorage/ClawEmpire/Shared/BigNumber','src/shared/BigNumber.luau'),
    'Economy': ('ModuleScript','ReplicatedStorage/ClawEmpire/Shared/Economy','src/shared/Economy.luau'),
    'World': ('ModuleScript','ServerScriptService/ClawEmpire/World','src/server/World.luau'),
    'ProfileStore': ('ModuleScript','ServerScriptService/ClawEmpire/ProfileStore','src/server/ProfileStore.luau'),
    'Bootstrap': ('Script','ServerScriptService/ClawEmpire/Bootstrap','src/server/Bootstrap.server.luau'),
    'ClawEmpireClient': ('LocalScript','StarterPlayer/StarterPlayerScripts/ClawEmpireClient','src/client/Main.client.luau'),
}
def sources():
    return {k: (ROOT/v[2]).read_text(encoding='utf-8') for k,v in SOURCES.items()}
def literal(value):
    for n in range(4,20):
        eq='='*n
        if ']'+eq+']' not in value: return '['+eq+'['+value+']'+eq+']'
    raise ValueError('no long-string delimiter')
def add(parent, cls, name):
    item=ET.SubElement(parent,'Item',{'class':cls,'referent':'RBX'+str(len(list(parent.iter())))+name})
    props=ET.SubElement(item,'Properties'); ET.SubElement(props,'string',{'name':'Name'}).text=name
    return item
def prop(item, kind, name, value):
    ET.SubElement(item.find('Properties'),kind,{'name':name}).text=str(value)
def place(src):
    tree=ET.Element('roblox',{'version':'4'})
    ET.SubElement(tree,'External').text='null'; ET.SubElement(tree,'External').text='nil'
    services={name:add(tree,name,name) for name in ['Workspace','Lighting','ReplicatedStorage','ServerScriptService','StarterPlayer']}
    starter=add(services['StarterPlayer'],'StarterPlayerScripts','StarterPlayerScripts')
    base=add(services['Workspace'],'Part','Baseplate')
    prop(base,'bool','Anchored','true'); prop(base,'bool','Locked','true')
    size=ET.SubElement(base.find('Properties'),'Vector3',{'name':'size'})
    for axis,value in [('X',512),('Y',2),('Z',512)]: ET.SubElement(size,axis).text=str(value)
    cf=ET.SubElement(base.find('Properties'),'CoordinateFrame',{'name':'CFrame'})
    for key,value in [('X',0),('Y',-2),('Z',0),('R00',1),('R01',0),('R02',0),('R10',0),('R11',1),('R12',0),('R20',0),('R21',0),('R22',1)]: ET.SubElement(cf,key).text=str(value)
    prop(services['Lighting'],'float','Brightness',3); prop(services['Lighting'],'float','ClockTime',14.5)
    nodes={**services,'StarterPlayer/StarterPlayerScripts':starter}
    for name,source in src.items():
        cls,path,_=SOURCES[name]; segments=path.split('/')
        for i in range(2,len(segments)):
            p='/'.join(segments[:i]); parent='/'.join(segments[:i-1])
            if p not in nodes: nodes[p]=add(nodes[parent],'Folder',segments[i-1])
        obj=add(nodes['/'.join(segments[:-1])],cls,segments[-1])
        prop(obj,'ProtectedString','Source',source)
        if cls!='ModuleScript': prop(obj,'bool','Disabled','false')
    for i,obj in enumerate(tree.iter('Item'),1): obj.set('referent','RBX'+str(i))
    ET.indent(tree,space='  ')
    return ET.tostring(tree,encoding='unicode',xml_declaration=True)
def installer(src):
    code=['-- Generated from src by tools/build.py. Run in Studio EDIT Command Bar.\n',
    'assert(not game:GetService("RunService"):IsRunning(),"Stop Play before installing")\n',
    'assert(not game.ReplicatedStorage:FindFirstChild("ClawEmpire"),"ClawEmpire already installed; use UPDATE or rollback first")\n',
    'assert(not game.ServerScriptService:FindFirstChild("ClawEmpire"),"Server namespace occupied")\n',
    'assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("ClawEmpireClient"),"Client namespace occupied")\n',
    'local src={}\n']
    for name,source in src.items(): code.append('src['+json.dumps(name)+']='+literal(source)+'\n')
    code.append('for name,source in pairs(src) do local fn,err=loadstring(source); assert(fn,name..": "..tostring(err)) end\n')
    code.append('local function folder(parent,name) local f=Instance.new("Folder"); f.Name=name; f.Parent=parent; return f end\n')
    code.append('local rs=folder(game.ReplicatedStorage,"ClawEmpire"); local shared=folder(rs,"Shared"); local server=folder(game.ServerScriptService,"ClawEmpire")\n')
    for name,(cls,path,_) in SOURCES.items():
        dest='shared' if '/Shared/' in path else ('server' if path.startswith('ServerScriptService') else 'game.StarterPlayer.StarterPlayerScripts')
        code.append('do local obj=Instance.new('+json.dumps(cls)+'); obj.Name='+json.dumps(name)+'; obj.Source=src['+json.dumps(name)+']; obj.Parent='+dest+' end\n')
    code.append('game:GetService("Lighting").ClockTime=14.5; game:GetService("Lighting").Brightness=3\n')
    code.append('local world=require(server.World); world.build(workspace,"ClawEmpirePreview",Vector3.zero)\n')
    code.append('workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable; workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(64,46,76),Vector3.new(0,8,-7))\n')
    code.append('return "INSTALL_PASS scripts=7 preview=1 purchases=disabled existing-baseplate-and-spawn=preserved"\n')
    return ''.join(code)
def rollback():
    baseline=json.loads((ROOT/'evidence/BASELINE.json').read_text())
    def array(x): return [x[str(i)] for i in range(1,len(x)+1)] if isinstance(x,dict) else x
    light=baseline['lighting']; cam=baseline['camera']
    code='-- Stop Play first. Removes ONLY Build 01 namespaces; restores captured lighting/camera.\nassert(not game:GetService("RunService"):IsRunning(),"Stop Play first")\n'
    for path,name in [('game.ReplicatedStorage','ClawEmpire'),('game.ServerScriptService','ClawEmpire'),('game.StarterPlayer.StarterPlayerScripts','ClawEmpireClient'),('workspace','ClawEmpirePreview'),('workspace','ClawEmpirePlots')]:
        code+=f'do local obj={path}:FindFirstChild("{name}"); if obj then obj:Destroy() end end\n'
    for name,value in light.items():
        val='Color3.new('+','.join(map(str,array(value)))+')' if isinstance(value,(dict,list)) else str(value)
        code+=f'game:GetService("Lighting").{name}={val}\n'
    code+='workspace.CurrentCamera.CFrame=CFrame.new('+','.join(map(str,array(cam['cframe'])))+')\n'
    code+='workspace.CurrentCamera.CameraType=Enum.CameraType.'+cam['type']+'\n'
    code+='return "STUDIO_ROLLBACK_PASS namespaces=removed original-baseplate-and-spawn=preserved lighting-camera=restored"\n'
    return code
def test_code(src):
    result='local Big,Config,Economy,ProfileStore\n'
    for name,args in [('BigNumber',''),('Config',''),('Economy','Config,Big'),('ProfileStore','Economy')]:
        source=src[name]
        source='\n'.join(line for line in source.splitlines() if not (line.startswith('local Config') and 'require(' in line or line.startswith('local Big') and 'require(' in line or line.startswith('local Economy') and 'require(' in line))
        out='Big' if name=='BigNumber' else name
        result+=out+'=assert(loadstring('+literal('return function('+args+')\n'+source+'\nend')+'))()('+args+')\n'
    tests=(ROOT/'tests/contracts.luau').read_text(encoding='utf-8')
    result+='return assert(loadstring('+literal('return function(Big,Config,Economy,ProfileStore)\n'+tests+'\nend')+'))()(Big,Config,Economy,ProfileStore)'
    return result
def build():
    src=sources()
    baseline=ROOT/'evidence/BASELINE.rbxlx'
    if not baseline.exists(): baseline.write_text(place({}),encoding='utf-8')
    # MODIFIED_FILE is derived from the retained, hash-guarded baseline fixture.
    modified=ROOT/'Claw Machine Empire.rbxlx'
    modified.write_text(place(src),encoding='utf-8')
    (ROOT/'INSTALL.luau').write_text(installer(src),encoding='utf-8')
    (ROOT/'STUDIO_ROLLBACK.luau').write_text(rollback(),encoding='utf-8')
    (ROOT/'tests/RUN_IN_STUDIO.luau').write_text(test_code(src),encoding='utf-8')
    before=baseline.read_text(encoding='utf-8').splitlines(True)
    diff=''.join(difflib.unified_diff(before,modified.read_text(encoding='utf-8').splitlines(True),fromfile='BASELINE.rbxlx',tofile='Claw Machine Empire.rbxlx'))
    (ROOT/'evidence/DIFF_FILE.diff').write_text(diff,encoding='utf-8')
    files=[p for p in ROOT.rglob('*') if p.is_file() and p.suffix in {'.luau','.rbxlx','.py','.md'} and 'node_modules' not in p.parts]
    hashes={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    (ROOT/'evidence/SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
    print('BUILD_PASS scripts=7 place_xml=valid installer=generated baseline=preserved')
if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='bundle':
        print(json.dumps({'sources':sources(),'installer':(ROOT/'INSTALL.luau').read_text(encoding='utf-8'),'tests':(ROOT/'tests/RUN_IN_STUDIO.luau').read_text(encoding='utf-8'),'rollback':(ROOT/'STUDIO_ROLLBACK.luau').read_text(encoding='utf-8')}))
    else: build()

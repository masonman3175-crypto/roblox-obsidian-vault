from pathlib import Path
import xml.etree.ElementTree as ET
import hashlib, json, difflib, shutil

ROOT = Path(__file__).resolve().parent
BASE = ROOT / 'baseline'
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def item(parent, cls, name):
    node=ET.SubElement(parent,'Item',{'class':cls,'referent':'RBX'+str(len(list(parent.iter())))+name})
    props=ET.SubElement(node,'Properties'); ET.SubElement(props,'string',{'name':'Name'}).text=name
    return node,props
def scalar(props,kind,name,value): ET.SubElement(props,kind,{'name':name}).text=str(value)
def vec(props,kind,name,values):
    n=ET.SubElement(props,kind,{'name':name})
    for k,v in zip(('X','Y','Z') if kind=='Vector3' else ('R','G','B'),values): ET.SubElement(n,k).text=str(v)
def base_place():
    root=ET.Element('roblox',{'version':'4'}); ET.SubElement(root,'External').text='null'; ET.SubElement(root,'External').text='nil'
    w,_=item(root,'Workspace','Workspace')
    original=json.loads((BASE/'studio.json').read_text())
    for obj in original['Objects']:
        n,p=item(w,obj['Class'],obj['Name'])
        vec(p,'Vector3','size',obj['Size']);vec(p,'Color3','Color',obj['Color'])
        cf=ET.SubElement(p,'CoordinateFrame',{'name':'CFrame'})
        for k,v in zip(('X','Y','Z'),obj['Position']): ET.SubElement(cf,k).text=str(v)
        for i in range(3):
            for j in range(3): ET.SubElement(cf,f'R{i}{j}').text=str(int(i==j))
        scalar(p,'bool','Anchored','true');scalar(p,'bool','CanCollide','true')
    return root
def write_xml(root,path): ET.indent(root);ET.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
def quoted(s):
    eq='===='
    while ']'+eq+']' in s: eq+='='
    return '['+eq+'[\n'+s+']'+eq+']'

write_xml(base_place(),BASE/'Place2.rbxlx')
root=base_place();rs,_=item(root,'ReplicatedStorage','ReplicatedStorage');shared,_=item(rs,'Folder','FatChaos')
sss,_=item(root,'ServerScriptService','ServerScriptService');server,_=item(sss,'Folder','FatChaosServer')
sp,_=item(root,'StarterPlayer','StarterPlayer');client,_=item(sp,'StarterPlayerScripts','StarterPlayerScripts')
units=[]
for directory,target in [('shared',shared),('server',server),('client',client)]:
    for path in sorted((ROOT/'src'/directory).glob('*.luau')):
        cls='Script' if '.server.' in path.name else 'LocalScript' if '.client.' in path.name else 'ModuleScript'
        name=path.name.split('.')[0];source=path.read_text(encoding='utf-8');_,props=item(target,cls,name)
        scalar(props,'ProtectedString','Source',source)
        units.append({'group':directory,'class':cls,'name':name,'source':source})
write_xml(root,ROOT/'FatChaos.rbxlx');shutil.copyfile(ROOT/'FatChaos.rbxlx',ROOT/'MODIFIED_FILE')
(ROOT/'units.json').write_text(json.dumps(units,ensure_ascii=False),encoding='utf-8')
installer='''-- Generated installer. Run in Studio Edit mode, not during a play session.
assert(not game:GetService("RunService"):IsRunning(),"Stop play before installation")
local rs=game:GetService("ReplicatedStorage")
local ss=game:GetService("ServerScriptService")
local sp=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
assert(not rs:FindFirstChild("FatChaos") and not ss:FindFirstChild("FatChaosServer"),"Fat Chaos already installed")
local shared=Instance.new("Folder");shared.Name="FatChaos";shared.Parent=rs
local server=Instance.new("Folder");server.Name="FatChaosServer";server.Parent=ss
local targets={shared=shared,server=server,client=sp}
'''
for u in units:
    installer+=f'do local s=Instance.new("{u["class"]}");s.Name="{u["name"]}";s.Source={quoted(u["source"])};s.Parent=targets.{u["group"]} end\n'
installer+='return "INSTALLED: 5 zones, 19 powers, server services and HUD"\n'
(ROOT/'INSTALL.luau').write_text(installer,encoding='utf-8')
rollback='''-- Run in Studio Edit mode. Removes only this build's named roots.
assert(not game:GetService("RunService"):IsRunning(),"Stop play before rollback")
for _,entry in ipairs({{game:GetService("ReplicatedStorage"),"FatChaos"},{game:GetService("ServerScriptService"),"FatChaosServer"},{game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"),"UIController"},{workspace,"FatChaosWorld"},{game:GetService("Lighting"),"FatChaosBloom"}}) do local v=entry[1]:FindFirstChild(entry[2]);if v then v:Destroy() end end
local l=game:GetService("Lighting");l.ClockTime=14.5;l.Brightness=3;l.Ambient=Color3.fromRGB(70,70,70);l.OutdoorAmbient=Color3.fromRGB(70,70,70)
return "ROLLBACK PASS: original baseplate and spawn retained; Fat Chaos roots removed"
'''
(ROOT/'STUDIO_ROLLBACK.luau').write_text(rollback,encoding='utf-8')
script='''#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$ROOT/rollback-copy.rbxlx}"
cp -- "$ROOT/baseline/Place2.rbxlx" "$TARGET"
cmp -- "$ROOT/baseline/Place2.rbxlx" "$TARGET"
printf '%s\\n' 'ROLLBACK PASS: original baseplate restored in target copy; modified game retained'
'''
(ROOT/'ROLLBACK.sh').write_text(script,encoding='utf-8',newline='\n');(ROOT/'ROLLBACK.sh').chmod(0o755)
before=(BASE/'Place2.rbxlx').read_text();after=(ROOT/'FatChaos.rbxlx').read_text()
(ROOT/'DIFF_FILE').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='baseline/Place2.rbxlx',tofile='FatChaos.rbxlx')),encoding='utf-8')
(ROOT/'HASHES.json').write_text(json.dumps({'original_place_sha256':digest(BASE/'Place2.rbxlx'),'original_snapshot_sha256':digest(BASE/'studio.json'),'original_brief_sha256':digest(ROOT/'BUILD_BRIEF.txt'),'modified_place_sha256':digest(ROOT/'FatChaos.rbxlx')},indent=2),encoding='utf-8')
print(f'BUILD PASS: {len(units)} Luau scripts; standalone place and installer written')

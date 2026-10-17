import bpy,os,json,contextlib,io
from mathutils import Matrix, Vector
OUT=os.path.join(r'C:\Users\mason\OneDrive\Desktop\Roblox AI\weapon_reference_rebuild','studio_import')
os.makedirs(OUT,exist_ok=True)
source=bpy.data.scenes['Reference_Rebuild_Studio']
src_rigs=sorted([o for o in source.objects if o.type=='ARMATURE'],key=lambda o:o.name)
source.frame_set(1)
export_scene=bpy.data.scenes.new('Roblox_Import_Pack')
manifest=[]
for index,rig in enumerate(src_rigs,1):
    bpy.context.window.scene=source
    for track in rig.animation_data.nla_tracks: track.mute=True
    rig.animation_data.action=None
    for pb in rig.pose.bones: pb.location=(0,0,0);pb.rotation_euler=(0,0,0)
    bpy.context.view_layer.update()
    dep=bpy.context.evaluated_depsgraph_get()
    groups={}
    for ob in source.objects:
        if ob.type!='MESH' or ob.parent!=rig: continue
        ev=ob.evaluated_get(dep); me=bpy.data.meshes.new_from_object(ev,preserve_all_data_layers=True,depsgraph=dep)
        # Body detail, magazine and bolt stay separate; surface colors stay separated too.
        key=(ob['animation_component'],me.materials[0].name.removeprefix('REF_') if me.materials else 'CarbonBlack')
        clone=bpy.data.objects.new('Copy_'+ob.name,me); export_scene.collection.objects.link(clone)
        clone.matrix_world=Matrix.Translation((-index*15,0,0)) @ rig.parent.matrix_world.inverted() @ ob.matrix_world
        groups.setdefault(key,[]).append(clone)
    bpy.context.window.scene=export_scene
    name=rig.name.replace('_Rig','');rec={'id':'W'+str(index),'name':name,'parts':[]}
    for (component,material),objs in groups.items():
        chunks=[];chunk=[];tris=0
        for ob in objs:
            ob.data.calc_loop_triangles(); t=len(ob.data.loop_triangles)
            if chunk and tris+t>12000: chunks.append(chunk);chunk=[];tris=0
            chunk.append(ob);tris+=t
        if chunk:chunks.append(chunk)
        for n,chunk in enumerate(chunks):
            bpy.ops.object.select_all(action='DESELECT')
            for ob in chunk:ob.select_set(True)
            bpy.context.view_layer.objects.active=chunk[0]
            bpy.ops.object.join(); merged=bpy.context.object
            merged.name=f'W{index}__{component}__{material}__{n}'
            # Keep appearance for every source surface including inside the bore.
            merged.data.calc_loop_triangles()
            rec['parts'].append({'name':merged.name,'component':component,'material':material,'triangles':len(merged.data.loop_triangles)})
    bpy.ops.mesh.primitive_cube_add(size=.06,location=(-index*15,0,0))
    bpy.context.object.name=f'W{index}__ORIGIN'
    manifest.append(rec)
    print('PACKED',rec['id'],name,len(rec['parts']),'mesh groups')
bpy.ops.object.select_all(action='SELECT')
with contextlib.redirect_stdout(io.StringIO()):
    bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,'ReferenceWeapons_Studio.fbx'),use_selection=True,object_types={'MESH'},global_scale=1,apply_unit_scale=True,bake_anim=False,axis_forward='-Z',axis_up='Y')
with open(os.path.join(OUT,'import_manifest.json'),'w') as f:json.dump(manifest,f,indent=2)
bpy.context.window.scene=source
print('STUDIO_EXPORT',os.path.join(OUT,'ReferenceWeapons_Studio.fbx'))

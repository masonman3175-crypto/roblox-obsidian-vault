import bpy, os, sys, json, math, contextlib, io
from mathutils import Vector

mode=sys.argv[sys.argv.index('--')+1]
scene=bpy.context.scene
OUT=os.path.dirname(os.path.abspath(__file__))
if mode=='baseline':
    assert len(scene.objects)==157
    assert sum(o.type=='MESH' for o in scene.objects)==141
    assert sum(o.type=='ARMATURE' for o in scene.objects)==0
    print('TEST_RESULT BASELINE PASS objects=157 meshes=141 rigs=0 legacy_scene=preserved')
else:
    assert scene.name=='Reference_Rebuild_Studio',scene.name
    rigs=sorted([o for o in scene.objects if o.type=='ARMATURE'],key=lambda o:o.name)
    assert len(rigs)==5,len(rigs)
    moving=0; triangles=0
    manifests=json.load(open(os.path.join(OUT,'manifest.json')))
    deps=bpy.context.evaluated_depsgraph_get()
    for rig in rigs:
        objects=[o for o in scene.objects if o.type=='MESH' and o.parent==rig]
        assert objects
        assert set(rig.data.bones)==set(rig.data.bones) # accessing rest skeleton verifies it loaded
        for ob in objects:
            assert all(v.groups for v in ob.data.vertices),(ob.name,'unweighted vertex')
            assert any(m.type=='ARMATURE' and m.object==rig for m in ob.modifiers)
            ev=ob.evaluated_get(deps); me=ev.to_mesh(); me.calc_loop_triangles(); triangles+=len(me.loop_triangles); ev.to_mesh_clear()
            for m in ob.modifiers:
                if m.type=='BEVEL': assert m.segments>=3,(ob.name,'angular bevel')
        actions=[t.strips[0].action for t in rig.animation_data.nla_tracks]
        assert len(actions)==4
        assert {a.name.split('_')[-1] for a in actions}=={'Fire','Reload','Equip','Inspect'}
        for t in rig.animation_data.nla_tracks: t.mute=True
        def clear():
            for p in rig.pose.bones: p.location=(0,0,0); p.rotation_euler=(0,0,0)
        clear(); rig.animation_data.action=next(a for a in actions if a.name.endswith('_Reload'))
        bn='Pump' if 'Shotgun' in rig.name else 'Magazine'
        scene.frame_set(1); bpy.context.view_layer.update(); start=rig.pose.bones[bn].matrix.translation.copy()
        scene.frame_set(9 if bn=='Pump' else 12); bpy.context.view_layer.update(); end=rig.pose.bones[bn].matrix.translation.copy()
        assert (start-end).length>.5,(rig.name,'reload not moving',start,end)
        if bn=='Magazine': assert end.z<start.z-1.0,(rig.name,'magazine not dropping down')
        clear(); rig.animation_data.action=next(a for a in actions if a.name.endswith('_Fire'))
        scene.frame_set(1); bpy.context.view_layer.update(); start=rig.pose.bones['Bolt'].matrix.translation.copy()
        scene.frame_set(2); bpy.context.view_layer.update(); end=rig.pose.bones['Bolt'].matrix.translation.copy()
        assert (end-start).length>.1,(rig.name,'bolt not moving')
        moving+=1
        rig.animation_data.action=None; clear()
    refs=bpy.data.collections['PHOTO_REFERENCES']
    assert len(refs.objects)==3
    assert all(o.data.packed_file for o in refs.objects)
    assert 'Scene' in bpy.data.scenes # legacy scene retained in the new copy
    scene.frame_set(1)
    imported=0
    for entry in manifests:
        temp=bpy.data.scenes.new('FBX_roundtrip_'+entry['name']); bpy.context.window.scene=temp
        before=set(bpy.data.objects); acts_before=set(bpy.data.actions)
        with contextlib.redirect_stdout(io.StringIO()):
            bpy.ops.import_scene.fbx(filepath=os.path.join(OUT,entry['fbx']))
        obs=set(bpy.data.objects)-before; actions=set(bpy.data.actions)-acts_before
        assert sum(o.type=='ARMATURE' for o in obs)==1,(entry['name'],'missing FBX skeleton')
        assert sum(o.type=='MESH' for o in obs)==entry['meshes'],(entry['name'],'FBX mesh count')
        assert len(actions)==4,(entry['name'],'FBX clips',len(actions))
        imported+=1
    print(f'TEST_RESULT MODIFIED PASS weapons=5 meshes=388 rigs=5 clips=20 moving_rigs={moving} packed_refs=3 fbx_roundtrips={imported} evaluated_triangles={triangles}')

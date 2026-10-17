"""Reference-guided game meshes. Run in the connected Blender; preserves the old scene."""
import bpy, bmesh, math, os, json
from mathutils import Vector
from math import sin, cos, pi

OUT = r'C:\Users\mason\OneDrive\Desktop\Roblox AI\weapon_reference_rebuild'
RAW = r'C:\Users\mason\OneDrive\Desktop\Roblox AI\_github_repo\Roblox Game Vault\raw'
os.makedirs(OUT, exist_ok=True)
scene = bpy.data.scenes.new('Reference_Rebuild_Studio')
bpy.context.window.scene = scene
scene.render.fps = 30
scene.frame_start, scene.frame_end = 1, 180
scene.world = bpy.data.worlds.new('ReferenceStudioWorld')
scene.world.use_nodes = True
scene.world.node_tree.nodes.get('Background').inputs['Color'].default_value = (.12,.16,.23,1)
scene.world.node_tree.nodes.get('Background').inputs['Strength'].default_value = .45
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x, scene.render.resolution_y = 1800, 1400
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = 'AgX'

def material(name, color, metal=0, rough=.35, noise=False, wood=False):
    m=bpy.data.materials.new('REF_'+name); m.diffuse_color=(*color,1); m.use_nodes=True
    ns=m.node_tree.nodes; bs=next(n for n in ns if n.type=='BSDF_PRINCIPLED')
    bs.inputs['Base Color'].default_value=(*color,1)
    bs.inputs['Metallic'].default_value=metal; bs.inputs['Roughness'].default_value=rough
    if noise or wood:
        tex=ns.new('ShaderNodeTexNoise'); tex.inputs['Scale'].default_value=5 if wood else 145
        tex.inputs['Detail'].default_value=3
        coord=ns.new('ShaderNodeTexCoord'); mapping=ns.new('ShaderNodeVectorMath'); mapping.operation='MULTIPLY'
        mapping.inputs[1].default_value=(1,24,24) if wood else (1,1,1)
        m.node_tree.links.new(coord.outputs['Generated'],mapping.inputs[0]); m.node_tree.links.new(mapping.outputs[0],tex.inputs['Vector'])
        ramp=ns.new('ShaderNodeValToRGB')
        ramp.color_ramp.elements[0].position=.15; ramp.color_ramp.elements[1].position=.85
        ramp.color_ramp.elements[0].color=(*(c*.65 for c in color),1)
        ramp.color_ramp.elements[1].color=(*(min(1,c*1.3) for c in color),1)
        m.node_tree.links.new(tex.outputs['Fac'],ramp.inputs[0]); m.node_tree.links.new(ramp.outputs['Color'],bs.inputs['Base Color'])
        bump=ns.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.09 if wood else .13
        bump.inputs['Distance'].default_value=.009 if wood else .003
        m.node_tree.links.new(tex.outputs['Fac'],bump.inputs['Height']); m.node_tree.links.new(bump.outputs['Normal'],bs.inputs['Normal'])
    return m

STEEL=material('BluedSteel',(.065,.085,.105),.82,.3,True)
EDGE=material('SatinMachinedSteel',(.24,.29,.32),.85,.26,True)
BLACK=material('CarbonBlack',(.019,.024,.03),.15,.49,True)
SILVER=material('BrushedSilver',(.55,.61,.65),.9,.25,True)
WOOD=material('HoneyWalnut',(.62,.255,.055),0,.32,wood=True)
DARKWOOD=material('DarkWalnut',(.24,.075,.025),0,.4,wood=True)
RUBBER=material('GripRubber',(.033,.039,.043),0,.7,True)
GREEN=material('LimeGrip',(.13,.63,.025),0,.49,True)
BORE=material('BoreDark',(.004,.005,.007),.1,.9)
BRASS=material('Brass',(.64,.39,.075),.75,.29)
RED=material('ShellRed',(.65,.045,.015),.1,.4)
WHITE=material('SightWhite',(.73,.9,.8),.15,.24)

weapons=[]; current=None; parts=[]
def begin(name, offset):
    global current, parts
    current=bpy.data.collections.new(name); scene.collection.children.link(current); parts=[]
    root=bpy.data.objects.new(name+'_DISPLAY',None); current.objects.link(root); root.location=offset
    root['reference_guided']=True; root['note']='Original mesh modeled from photo silhouettes; not a photo texture.'
    weapons.append({'name':name,'collection':current,'root':root,'parts':parts})
    return root

def attach(o, mat, bone='Body', smooth=True):
    for c in list(o.users_collection): c.objects.unlink(o)
    current.objects.link(o)
    if mat: o.data.materials.append(mat)
    o['animation_component']=bone
    if o.type=='MESH':
        for p in o.data.polygons: p.use_smooth=smooth
    parts.append(o)
    return o

def bevel(o, width=.035, seg=4):
    if width:
        b=o.modifiers.new('Rounded machined edges','BEVEL'); b.width=width; b.segments=seg
        b.harden_normals=True
        n=o.modifiers.new('Face weighted normals','WEIGHTED_NORMAL'); n.keep_sharp=True; n.weight=40
    return o

def mesh(name,verts,faces,mat,bone='Body',bev=0):
    me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update()
    bm=bmesh.new(); bm.from_mesh(me); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(me); bm.free()
    o=bpy.data.objects.new(name,me); current.objects.link(o); attach(o,mat,bone)
    return bevel(o,bev)

def profile(name,points,width,mat,bone='Body',bev=.035,y=0):
    n=len(points); v=[(x,y+s*width/2,z) for s in (-1,1) for x,z in points]
    f=[tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    return mesh(name,v,f,mat,bone,bev)

def box(name,loc,dims,mat,bone='Body',bev=.035,rot=None):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.name=name
    o.dimensions=dims; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if rot: o.rotation_euler=rot
    attach(o,mat,bone); return bevel(o,bev)

def cyl(name,loc,radius,length,mat,bone='Body',axis='X',vertices=48,bev=.012):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=length,location=loc)
    o=bpy.context.object; o.name=name
    o.rotation_euler=(0,pi/2,0) if axis=='X' else ((pi/2,0,0) if axis=='Y' else (0,0,0))
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    attach(o,mat,bone); return bevel(o,bev,3)

def tube(name,x0,x1,z,outer,inner,mat,bone='Body',y=0):
    n=48; verts=[]
    for x,r in [(x0,outer),(x1,outer),(x1,inner),(x0,inner)]:
        verts += [(x,y+r*cos(i*2*pi/n),z+r*sin(i*2*pi/n)) for i in range(n)]
    faces=[(k*n+i,k*n+(i+1)%n,((k+1)%4)*n+(i+1)%n,((k+1)%4)*n+i) for k in range(4) for i in range(n)]
    o=mesh(name,verts,faces,mat,bone)
    o.data.materials.append(BORE)
    for i,p in enumerate(o.data.polygons):
        if 2*n<=i<3*n: p.material_index=1
    return bevel(o,.007,3)

def path(name,coords,radius,mat,bone='Body',cyclic=False):
    cu=bpy.data.curves.new(name,'CURVE'); cu.dimensions='3D'; cu.resolution_u=12
    sp=cu.splines.new('BEZIER'); sp.bezier_points.add(len(coords)-1)
    for p,co in zip(sp.bezier_points,coords): p.co=co; p.handle_left_type='AUTO'; p.handle_right_type='AUTO'
    sp.use_cyclic_u=cyclic; cu.bevel_depth=radius; cu.bevel_resolution=4; cu.use_fill_caps=True
    ob=bpy.data.objects.new(name,cu); current.objects.link(ob)
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); bpy.context.view_layer.objects.active=ob
    bpy.ops.object.convert(target='MESH'); attach(ob,mat,bone); return ob

def loft(name,sections,mat,bone='Body',bev=.025):
    # Each X section is a rounded octagonal YZ cross-section, not a scaled cube.
    verts=[]
    for x,cy,cz,w,h in sections:
        verts += [(x,cy+y*w/2,cz+z*h/2) for y,z in [(-.65,-1),(.65,-1),(1,-.65),(1,.65),(.65,1),(-.65,1),(-1,.65),(-1,-.65)]]
    n=8; count=len(sections)
    faces=[tuple(range(7,-1,-1)),tuple(range((count-1)*8,count*8))]
    faces += [(s*n+i,s*n+(i+1)%n,(s+1)*n+(i+1)%n,(s+1)*n+i) for s in range(count-1) for i in range(n)]
    return mesh(name,verts,faces,mat,bone,bev)

def screw(name,x,y,z,r=.046,mat=EDGE,bone='Body'):
    cyl(name,(x,y,z),r,.025,mat,bone,'Y',24,.004)
    box(name+'_slot',(x,y+(.016 if y>0 else -.016),z),(.052,.009,.009),BORE,bone,.003)

def guard(x,z,width=.52,height=.44,mat=STEEL):
    return path('Open_Trigger_Guard',[(x-width/2,0,z+.13),(x-width/2-.06,0,z-height*.58),(x,0,z-height*.77),(x+width/2,0,z-height*.52),(x+width/2,0,z+.12)],.045,mat)

def curved_mag(name,x,z,length=1.7,curve=.58,mat=BLACK):
    verts=[]; levels=13
    for j in range(levels):
        t=j/(levels-1); cx=x-curve*t*t; cz=z-length*t
        for xx,yy in [(-.34,-.19),(.30,-.19),(.34,-.13),(.34,.13),(.30,.19),(-.34,.19),(-.38,.13),(-.38,-.13)]:
            verts.append((cx+xx,yy,cz))
    faces=[tuple(range(7,-1,-1)),tuple(range((levels-1)*8,levels*8))]
    faces += [(s*8+i,s*8+(i+1)%8,(s+1)*8+(i+1)%8,(s+1)*8+i) for s in range(levels-1) for i in range(8)]
    o=mesh(name,verts,faces,mat,'Magazine',.035)
    for side in [-1,1]:
        for dx in [-.20,.06,.23]:
            path(name+'_PressedFlute',[(x-curve*t*t+dx,side*.203,z-length*t) for t in [.09,.28,.5,.72,.92]],.013,STEEL,'Magazine')
    for t in [.15,.48,.81,.98]:
        box(name+'_WrapBand',(x-curve*t*t,0,z-length*t),(.78,.425,.045),STEEL,'Magazine',.014)
    return o

def ak(compact=False):
    prefix='02_Compact_AK' if compact else '01_Walnut_AK'
    begin(prefix,(0,0,0) if not compact else (0,0,-4.3))
    profile(prefix+'_Stamped_Receiver',[(-1.48,1.13),(1.10,1.13),(1.17,1.37),(1.02,1.83),(-1.18,1.83),(-1.48,1.58)],.48,STEEL,bev=.055)
    loft(prefix+'_Rounded_Dust_Cover',[(-1.25,0,1.82,.43,.27),(-1.1,0,1.86,.53,.34),(.8,0,1.86,.53,.34),(1.02,0,1.78,.43,.25)],STEEL,bev=.025)
    for x in [-.94,-.76,.65,.85]:
        for side in [-1,1]: screw('Receiver_Rivet',x,side*.26,1.43,.04,STEEL)
    profile('Selector_Lever',[(.85,1.58),(.72,1.49),(-.12,1.33),(-.20,1.39),(.62,1.65)],.035,EDGE,y=-.265,bev=.02)
    screw('Selector_Pivot',.78,-.29,1.57,.075)
    box('Bolt_Opening',(-.47,-.256,1.70),(1.05,.02,.13),BORE,bev=.035)
    box('Bolt_Carrier',(-.45,-.277,1.73),(.72,.06,.085),EDGE,'Bolt',.02)
    cyl('Charging_Handle',(-.13,-.40,1.70),.055,.29,STEEL,'Bolt','Y')
    front=-2.53 if compact else -3.0
    loft('Sculpted_Lower_Handguard',[(front,0,1.4,.40,.42),(front+.12,0,1.39,.58,.53),(-1.66,0,1.38,.62,.55),(-1.48,0,1.43,.43,.40)],BLACK if compact else WOOD,bev=.055)
    loft('Upper_Gas_Handguard',[(front+.06,0,1.89,.31,.22),(front+.19,0,1.92,.47,.32),(-1.59,0,1.91,.45,.30),(-1.48,0,1.87,.30,.23)],BLACK if compact else WOOD,bev=.035)
    for side in [-1,1]:
        path('Handguard_Finger_Recess',[(front+.19,side*.29,1.42),((front-1.48)/2,side*.31,1.40),(-1.67,side*.30,1.42)],.037,STEEL if compact else DARKWOOD)
        for x in [front+.20,-1.7]: screw('Handguard_Pin',x,side*.30,1.54,.037)
    muzzle=-3.62 if compact else -5.05
    tube('Barrel',muzzle,front,1.64,.105,.064,STEEL)
    cyl('GasTube',((muzzle+front)/2+.17,0,1.98),.09,front-muzzle-.25,STEEL)
    cyl('Gas_Block',(muzzle+.40,0,1.69),.17,.20,STEEL)
    profile('Gas_Block_Slope',[(muzzle+.30,1.65),(muzzle+.51,1.69),(muzzle+.59,1.99),(muzzle+.38,1.99)],.19,STEEL,bev=.02)
    tube('Hollow_Muzzle_Brake',muzzle-.27,muzzle+.07,1.64,.16,.074,STEEL)
    for side in [-1,1]:
        for xx in [muzzle-.17,muzzle-.05]: box('Brake_Port',(xx,side*.152,1.65),(.048,.009,.11),BORE,bev=.013)
    cyl('Sight_Base',(muzzle+.18,0,1.67),.145,.17,STEEL)
    profile('Front_Sight_Tower',[(muzzle+.10,1.69),(muzzle+.26,1.69),(muzzle+.27,2.17),(muzzle+.17,2.27),(muzzle+.10,2.17)],.14,STEEL,bev=.02)
    # Genuine circular open sight hood.
    tube('Open_Sight_Hood',muzzle+.11,muzzle+.24,2.24,.14,.095,STEEL)
    box('Front_Post',(muzzle+.175,0,2.20),(.05,.04,.14),EDGE,bev=.008)
    box('Rear_Sight_Base',(-1.15,0,2.05),(.42,.32,.10),STEEL,bev=.02)
    for y in [-.13,.13]: box('Rear_Sight_Ear',(-.93,y,2.12),(.11,.075,.15),STEEL,bev=.015)
    profile('Angled_Pistol_Grip',[(.59,1.17),(1.04,1.12),(1.41,-.10),(1.28,-.27),(.87,-.23),(.50,.86)],.39,BLACK if compact else DARKWOOD,bev=.10)
    for side in [-1,1]:
        for z in [.14,.28,.42,.56,.70]: path('Grip_Checkering',[(.82+( .7-z)*.29,side*.202,z), (1.12+(.7-z)*.29,side*.202,z+.05)],.013,RUBBER)
        screw('Grip_Screw',1.09,side*.21,.37,.055)
    guard(.17,.97,.65,.48)
    path('Curved_Trigger',[(.28,0,1.14),(.19,0,.91),(.24,0,.82)],.038,STEEL,'Trigger')
    curved_mag('Curved_Detachable_Magazine',-.64,1.19,1.66 if compact else 1.95,.58 if compact else .82)
    if compact:
        path('Skeleton_Stock_Upper',[(1.1,-.18,1.74),(2.70,-.18,1.55),(2.84,-.18,.85)],.075,STEEL)
        path('Skeleton_Stock_Lower',[(1.15,-.18,1.24),(2.52,-.18,.90),(2.82,-.18,.85)],.07,STEEL)
        box('Rubber_Stock_Pad',(2.83,-.18,1.12),(.16,.36,.80),RUBBER,bev=.075)
        box('Optic_Rail',(-.1,0,2.13),(1.16,.37,.13),BLACK,bev=.02)
        for i in range(10): box('Rail_Tooth',(-.60+i*.115,0,2.23),(.06,.45,.08),STEEL,bev=.012)
    else:
        profile('Sculpted_Walnut_Stock',[(1.08,1.75),(1.49,1.78),(2.12,1.55),(3.28,1.68),(3.40,1.57),(3.42,.42),(3.23,.36),(2.30,.67),(1.58,1.08),(1.08,1.14)],.49,WOOD,bev=.12)
        profile('Butt_Pad',[(3.29,1.67),(3.46,1.68),(3.49,.39),(3.32,.38)],.54,RUBBER,bev=.055)
        for y in [-.28,.28]: screw('Stock_Screw',2.97,y,.80,.049)
    weapons[-1]['mag_origin']=(-.64,0,1.0)
    weapons[-1]['bolt_origin']=(-.45,0,1.73)

def pistol(green=False):
    name='04_Lime_Tactical_9mm' if green else '03_Silver_9mm'
    begin(name,(9,0,-3.9) if green else (9,0,0))
    mat=STEEL if green else SILVER
    slide=loft('Contoured_Slide',[(-1.90,0,1.83,.49,.46),(-1.78,0,1.86,.60,.54),(.53,0,1.86,.60,.54),(.67,0,1.83,.48,.48)],mat,'Bolt',.035)
    # Cut a real ejection opening into the slide, not a painted black rectangle.
    cutter=box('TEMP_Ejection_Cutter',(.05,-.20,2.07),(.66,.40,.26),None,bev=.035)
    bpy.context.view_layer.objects.active=cutter
    for mod in list(cutter.modifiers): bpy.ops.object.modifier_apply(modifier=mod.name)
    cut=slide.modifiers.new('Ejection port opening','BOOLEAN'); cut.operation='DIFFERENCE'; cut.object=cutter
    bpy.context.view_layer.objects.active=slide; bpy.ops.object.modifier_apply(modifier=cut.name)
    parts.remove(cutter); bpy.data.objects.remove(cutter,do_unlink=True)
    tube('Visible_Barrel',-2.03,.30,1.89,.147,.088,EDGE)
    tube('Muzzle_Crown',-2.06,-1.94,1.89,.172,.088,mat)
    profile('Contoured_Lower_Frame',[(-1.85,1.60),(.59,1.59),(.69,1.37),(.42,1.15),(-.05,1.11),(-.36,1.32),(-1.83,1.34)],.52,BLACK if green else EDGE,bev=.065)
    profile('Finger_Scalloped_Grip',[(.16,1.43),(.58,1.38),(.91,-.24),(.75,-.40),(.19,-.30),(.06,-.04),(-.02,.16),(-.12,.37),(-.12,.59),(-.24,.81),(-.18,1.12)],.51,GREEN if green else RUBBER,bev=.09)
    profile('Grip_Backstrap',[(.52,1.37),(.64,1.32),(1.02,-.20),(.88,-.34),(.77,-.20)],.40,RUBBER,bev=.055)
    for side in [-1,1]:
        for z in [.05,.29,.53,.77]:
            for x in [.14,.27,.40]:
                xx=x+(1-z)*.26
                cyl('Grip_Stipple',(xx,side*.257,z),.012,.009,RUBBER,axis='Y',vertices=8,bev=0)
        for i in range(8):
            x=.05+i*.066
            box('Rear_Slide_Serration',(x,side*.302,1.85),(.021,.014,.34),BORE,'Bolt',.006,rot=(0,-.16,0))
        for i in range(4): box('Front_Slide_Serration',(-1.60+i*.085,side*.302,1.85),(.024,.014,.30),BORE,'Bolt',.006)
        screw('Frame_Pin',-.05,side*.277,1.36,.035)
    guard(-.51,1.09,.88,.60,BLACK if green else mat)
    path('Swept_Trigger',[(-.32,0,1.23),(-.40,0,.99),(-.31,0,.90)],.047,STEEL,'Trigger')
    box('Trigger_Safety',(-.44,-.002,1.04),(.035,.05,.16),RUBBER,'Trigger',.012)
    for y in [-.17,.17]: box('Rear_Notch_Sight',(.48,y,2.18),(.16,.09,.14),BLACK,'Bolt',.023)
    box('Front_Sight',(-1.64,0,2.19),(.14,.10,.13),BLACK,'Bolt',.022)
    cyl('Front_Sight_Dot',(-1.56,0,2.22),.024,.012,WHITE,'Bolt','X',24,.002)
    box('Slide_Stop',(-.12,-.312,1.53),(.36,.045,.075),STEEL,bev=.018)
    screw('Take_Down',-.60,-.295,1.43,.052)
    box('Magazine_Base',(.54,0,-.36),(.75,.58,.14),BLACK,'Magazine',.05)
    profile('Detachable_Magazine',[(.27,.93),(.62,.91),(.87,-.28),(.28,-.31)],.36,STEEL,'Magazine',.025)
    if green:
        loft('Underbarrel_Light',[(-1.45,0,1.20,.33,.30),(-1.35,0,1.20,.44,.39),(-.75,0,1.20,.44,.39),(-.68,0,1.2,.33,.29)],BLACK,bev=.025)
        tube('Light_Bezel',-1.51,-1.34,1.20,.20,.153,EDGE)
        cyl('Flashlight_Lens',(-1.47,0,1.20),.147,.014,SILVER)
        for i in range(4): box('Light_Cooling_Fin',(-1.25+i*.11,0,1.20),(.04,.46,.39),STEEL,bev=.03)
    weapons[-1]['mag_origin']=(.50,0,.30); weapons[-1]['bolt_origin']=(.4,0,1.8)

def shotgun():
    begin('05_Satin_Pump_Shotgun',(0,0,-8.8))
    profile('Contoured_Shotgun_Receiver',[(-1.52,1.32),(1.01,1.32),(1.19,1.48),(1.08,1.91),(.84,2.02),(-1.43,2.02),(-1.58,1.80)],.55,SILVER,bev=.07)
    box('Ejection_Port',(-.70,-.282,1.76),(.90,.015,.27),BORE,bev=.055)
    box('Visible_Bolt',(-.72,-.296,1.77),(.75,.02,.20),EDGE,'Bolt',.04)
    cyl('Bolt_Handle',(-.42,-.38,1.75),.06,.22,STEEL,'Bolt','Y')
    tube('Long_Hollow_Barrel',-6.30,-1.43,1.83,.14,.102,SILVER)
    tube('Barrel_Crown',-6.34,-6.15,1.83,.166,.102,EDGE)
    cyl('Magazine_Tube',(-3.69,0,1.39),.13,4.18,STEEL)
    cyl('Magazine_Cap',(-5.85,0,1.39),.158,.20,EDGE)
    for x in [-5.60,-1.80]:
        profile('Barrel_Band',[(x-.06,1.33),(x+.06,1.33),(x+.08,1.98),(x-.08,1.98)],.18,EDGE,bev=.025)
    loft('Sculpted_Pump',[(-4.57,0,1.37,.37,.32),(-4.40,0,1.37,.61,.51),(-2.82,0,1.38,.63,.53),(-2.64,0,1.39,.40,.34)],RUBBER,'Pump',.05)
    for i in range(14):
        x=-4.37+i*.111
        loft('Pump_Grip_Ring',[(x,0,1.37,.64,.54),(x+.035,0,1.37,.66,.56),(x+.062,0,1.37,.64,.54)],BLACK,'Pump',.009)
    for y in [-.23,.23]: box('Action_Bar',(-1.96,y,1.43),(1.66,.06,.075),EDGE,'Pump',.016)
    # Reference-style skeleton buttstock with an actual large opening.
    path('Skeleton_Stock_Top',[(1.03,0,1.85),(2.10,0,1.81),(3.51,0,2.12),(3.66,0,1.93)],.12,SILVER)
    path('Skeleton_Stock_Lower',[(1.15,0,1.42),(1.70,0,1.18),(2.38,0,1.26),(3.58,0,1.02)],.11,SILVER)
    path('Stock_Butt_Frame',[(3.62,0,2.07),(3.68,0,1.53),(3.59,0,1.02)],.14,SILVER)
    box('Butt_Rubber_Pad',(3.77,0,1.56),(.16,.43,1.04),RUBBER,bev=.07,rot=(0,.08,0))
    profile('Pistol_Grip',[(.74,1.49),(1.16,1.39),(1.64,-.03),(1.48,-.20),(1.03,-.14),(.61,1.13)],.43,RUBBER,bev=.105)
    guard(.23,1.11,.72,.52,SILVER)
    path('Shotgun_Trigger',[(.34,0,1.28),(.26,0,1.03),(.33,0,.94)],.04,STEEL,'Trigger')
    for side in [-1,1]:
        screw('Receiver_Pin',.75,side*.29,1.62,.058)
        screw('Receiver_Pin',-.10,side*.29,1.48,.040)
    box('Ventilated_Sight_Rib',(-3.88,0,2.012),(4.60,.12,.06),STEEL,bev=.012)
    for i in range(8): box('Rib_Support',(-5.82+i*.57,0,1.99),(.09,.09,.08),EDGE,bev=.008)
    cyl('Front_Bead',(-6.03,0,2.08),.047,.065,BRASS,axis='Z',vertices=24)
    for i in range(3):
        x=.0+i*.25
        cyl('Side_Saddle_Shell',(x,-.41,1.48),.101,.60,RED,'Body','Z')
        cyl('Shell_Brass',(x,-.41,1.81),.108,.11,BRASS,'Body','Z')
        box('Shell_Clip',(x,-.43,1.48),(.18,.22,.10),RUBBER,bev=.03)
    weapons[-1]['mag_origin']=(.5,0,1.05); weapons[-1]['bolt_origin']=(-.7,0,1.77)

ak(False); ak(True); pistol(False); pistol(True); shotgun()
print('BUILT',[(w['name'],len(w['parts'])) for w in weapons])

def rig_weapon(w):
    bpy.ops.object.select_all(action='DESELECT')
    data=bpy.data.armatures.new(w['name']+'_Skeleton'); rig=bpy.data.objects.new(w['name']+'_Rig',data)
    w['collection'].objects.link(rig); bpy.context.view_layer.objects.active=rig; rig.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    positions={'Root':(0,0,0),'Body':(0,0,1.4),'Magazine':w['mag_origin'],'Bolt':w['bolt_origin'],'Trigger':(.2,0,1.1),'Pump':(-3.5,0,1.4)}
    for name,pos in positions.items():
        b=data.edit_bones.new(name); b.head=pos; b.tail=Vector(pos)+Vector((0,.25,0))
        if name!='Root': b.parent=data.edit_bones['Root' if name=='Body' else 'Body']
    bpy.ops.object.mode_set(mode='OBJECT'); rig.parent=w['root']; w['rig']=rig
    for ob in w['parts']:
        if ob.type!='MESH': continue
        ob.parent=rig
        group=ob.vertex_groups.new(name=ob['animation_component']); group.add(list(range(len(ob.data.vertices))),1,'REPLACE')
        mod=ob.modifiers.new('Rigid animation binding','ARMATURE'); mod.object=rig
    rig.animation_data_create(); w['actions']=[]
    def make_action(suffix,tracks,end):
        act=bpy.data.actions.new(w['name']+'_'+suffix); rig.animation_data.action=act
        act.use_fake_user=True
        for p in rig.pose.bones: p.rotation_mode='XYZ'; p.location=(0,0,0); p.rotation_euler=(0,0,0)
        for bn,prop,keys in tracks:
            pb=rig.pose.bones[bn]
            for frame,vec in keys:
                setattr(pb,prop,vec); pb.keyframe_insert(data_path=prop,frame=frame,group=bn)
        track=rig.animation_data.nla_tracks.new(); track.name=suffix
        strip=track.strips.new(suffix,1,act); track.mute=True
        w['actions'].append(act.name)
    make_action('Fire',[('Root','location',[(1,(0,0,0)),(3,(.12,0,0)),(8,(0,0,0))]),('Root','rotation_euler',[(1,(0,0,0)),(3,(0,-.055,0)),(8,(0,0,0))]),('Bolt','location',[(1,(0,0,0)),(2,(.20,0,0)),(5,(0,0,0))]),('Trigger','rotation_euler',[(1,(0,0,0)),(2,(0,.20,0)),(6,(0,0,0))])],8)
    isshot='Shotgun' in w['name']
    if isshot:
        reload_tracks=[('Pump','location',[(1,(0,0,0)),(9,(.65,0,0)),(17,(0,0,0)),(60,(0,0,0))]),('Root','rotation_euler',[(1,(0,0,0)),(20,(.3,.10,0)),(46,(.3,.1,0)),(60,(0,0,0))])]
    else:
        reload_tracks=[('Magazine','location',[(1,(0,0,0)),(12,(.05,-.06,-1.95)),(28,(.05,-.06,-1.95)),(39,(0,0,0)),(60,(0,0,0))]),('Magazine','rotation_euler',[(1,(0,0,0)),(12,(0,.24,0)),(28,(0,.24,0)),(39,(0,0,0))]),('Bolt','location',[(1,(0,0,0)),(43,(0,0,0)),(48,(.33,0,0)),(54,(0,0,0))]),('Root','rotation_euler',[(1,(0,0,0)),(10,(.22,0,.07)),(39,(.22,0,.07)),(60,(0,0,0))])]
    make_action('Reload',reload_tracks,60)
    make_action('Equip',[('Root','location',[(1,(0,0,-1.5)),(9,(0,0,.06)),(15,(0,0,0))]),('Root','rotation_euler',[(1,(0,.4,.15)),(15,(0,0,0))])],15)
    make_action('Inspect',[('Root','rotation_euler',[(1,(0,0,0)),(18,(.52,-.08,-.22)),(42,(.52,-.08,-.22)),(67,(-.42,.04,.17)),(90,(0,0,0))])],90)
    rig.animation_data.action=None
    for pb in rig.pose.bones: pb.location=(0,0,0); pb.rotation_euler=(0,0,0)
    rig.show_in_front=True

for w in weapons: rig_weapon(w)
scene.frame_set(1)

# Load the actual references into Blender as pinned image empties.
refs=bpy.data.collections.new('PHOTO_REFERENCES'); scene.collection.children.link(refs)
for i,file in enumerate(['2026-10-16-weapon-kit-reference.png','2026-10-16-weapon-lineup.png','2026-10-16-color-grip-pistols-keyart.webp']):
    ob=bpy.data.objects.new('Reference_'+file,None); ob.empty_display_type='IMAGE'; ob.data=bpy.data.images.load(os.path.join(RAW,file),check_existing=True)
    refs.objects.link(ob); ob.location=(i*8,4,4); ob.rotation_euler=(pi/2,0,0); ob.empty_display_size=7
    ob.hide_render=True; ob.hide_set(True); ob.hide_select=True

stage=bpy.data.collections.new('PRESENTATION_ONLY'); scene.collection.children.link(stage)
def staged(o):
    for c in list(o.users_collection): c.objects.unlink(o)
    stage.objects.link(o); return o
def label(body,loc,size=.23,color=(.6,.72,.85)):
    cu=bpy.data.curves.new('Label','FONT'); cu.body=body; cu.size=size; cu.extrude=.001
    o=bpy.data.objects.new(body,cu); stage.objects.link(o); o.location=loc; o.rotation_euler=(pi/2,0,0)
    cu.materials.append(material('Label_'+body[:12],color,0,.6)); return o
for w in weapons:
    off=w['root'].location
    label(w['name'].replace('_',' ').upper(),(off.x-4.5,-.1,off.z-1.46),.24)
    label('BEVELED MESH / SEPARATE MOVING PARTS',(off.x-4.5,-.1,off.z-1.85),.12,(.24,.43,.59))
label('REFERENCE SERIES  /  FIRST-PERSON WEAPONS',(-5.2,0,3.8),.34,(.83,.91,1))
label('WALNUT + BLUED STEEL  /  SATIN SILVER  /  COLOR GRIPS',(-5.2,0,3.23),.18,(.30,.55,.72))
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,2.2,-3))
back=bpy.context.object; staged(back); back.name='Studio_Backdrop'; back.rotation_euler=(pi/2,0,0)
back.data.materials.append(material('Backdrop',(.012,.025,.043),.0,.85))
def area(name,loc,power,size,color,target=(2,0,-3)):
    data=bpy.data.lights.new(name,'AREA'); data.energy=power; data.shape='DISK'; data.size=size; data.color=color
    o=bpy.data.objects.new(name,data); stage.objects.link(o); o.location=loc; o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
area('Large_Softbox',(-3,-8,8),2600,10,(.80,.9,1))
area('Warm_Fill',(11,-6,-1),1900,8,(1,.82,.65))
area('Lower_Softbox',(-1,-6,-10),1600,7,(.68,.82,1))
area('Top_Rim',(1,1,7),2100,7,(.55,.75,1))
camdata=bpy.data.cameras.new('Reference_Lineup_Camera'); camera=bpy.data.objects.new('Reference_Lineup_Camera',camdata); stage.objects.link(camera)
camera.location=(-8,-32,16); target=Vector((2.7,0,-3.5)); camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
camdata.type='ORTHO'; camdata.ortho_scale=24.5; camdata.lens=48; scene.camera=camera
scene.render.image_settings.file_format='PNG'; scene.render.filepath=os.path.join(OUT,'reference_lineup.png')
scene['built_from']='2026-10-16-weapon-kit-reference.png + weapon-lineup.png + color-grip-pistols-keyart.webp'
scene['scope']='Five original reference-guided meshes; old Studio prototypes not replaced in this modeling pass.'
bpy.ops.object.select_all(action='DESELECT')
for w in weapons: w['root'].select_set(True)
bpy.context.view_layer.objects.active=weapons[0]['root']
for screen in bpy.data.screens:
    for a in screen.areas:
        if a.type=='VIEW_3D':
            a.spaces.active.region_3d.view_perspective='CAMERA'
            a.spaces.active.shading.type='MATERIAL'

# Export one self-contained FBX per weapon; only that weapon's actions are visible to FBX.
for w in weapons:
    bpy.ops.object.select_all(action='DESELECT'); rig=w['rig']; root=w['root']; offset=root.location.copy(); root.location=(0,0,0)
    rig.select_set(True)
    for ob in w['parts']: ob.select_set(True)
    for act in bpy.data.actions: act.use_fake_user=True
    # NLA strips are distinct named clips; muted tracks avoid a combined display pose.
    for t in rig.animation_data.nla_tracks: t.mute=False
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,w['name']+'.fbx'),use_selection=True,object_types={'MESH','ARMATURE'},global_scale=.1,apply_unit_scale=True,add_leaf_bones=False,bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=True,bake_anim_simplify_factor=0,axis_forward='-Z',axis_up='Y',path_mode='AUTO')
    for t in rig.animation_data.nla_tracks: t.mute=True
    rig.animation_data.action=None
    for pb in rig.pose.bones: pb.location=(0,0,0); pb.rotation_euler=(0,0,0)
    root.location=offset
    bpy.context.view_layer.update()

manifest=[]
for w in weapons:
    manifest.append({'name':w['name'],'meshes':len(w['parts']),'base_faces':sum(len(o.data.polygons) for o in w['parts']),'actions':w['actions'],'bones':[b.name for b in w['rig'].data.bones],'fbx':w['name']+'.fbx'})
with open(os.path.join(OUT,'manifest.json'),'w') as f: json.dump(manifest,f,indent=2)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'MODIFIED_FILE.blend'))
print('SUCCESS',json.dumps(manifest))

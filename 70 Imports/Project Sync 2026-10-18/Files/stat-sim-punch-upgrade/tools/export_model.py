import bpy, numpy as np, json, struct, pathlib, math
from mathutils import Vector, Matrix
R=pathlib.Path(r'C:\Users\mason\OneDrive\Desktop\slopshitv1\stat-sim-punch-upgrade')
scene=bpy.data.scenes['PunchDummy_ImportPreview'];bpy.context.window.scene=scene
names=['Punch_asian_boy','Punch_asian_boy.001','Punch_Shoe','Punch_Eye_lash','Punch_Lower_Teeth','Punch_PperTeeth','Punch_Tongue','Punch_Eye_R','Punch_Eye_L']
objects=[scene.objects[n] for n in names]
mats=list(objects[0].data.materials)
atlas=np.ones((1024,1024,4),dtype=np.float32);tiles={}
special={'Material.001':(0,512,512),'SkullCap':(512,512,256),'HairStrands':(768,512,256),'HairCrown':(512,768,256),'Shirt':(768,768,256)}
def image_array(image,size):
 a=np.empty(len(image.pixels),dtype=np.float32);image.pixels.foreach_get(a);a=a.reshape(image.size[1],image.size[0],4)
 ix=np.minimum((np.arange(size)+.5)*image.size[0]/size,image.size[0]-1).astype(int)
 iy=np.minimum((np.arange(size)+.5)*image.size[1]/size,image.size[1]-1).astype(int)
 return a[iy[:,None],ix[None,:]].copy()
for i,m in enumerate(mats):
 x,y,size=special.get(m.name,(i%8*128,i//8*128,128));tiles[i]=(x,y,size)
 p=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
 a=np.ones((size,size,4),dtype=np.float32);a[:]=list(p.inputs['Base Color'].default_value)
 links=p.inputs['Base Color'].links
 if links and links[0].from_node.type=='TEX_IMAGE':a=image_array(links[0].from_node.image,size)
 links=p.inputs['Alpha'].links
 if links and links[0].from_node.type=='TEX_IMAGE':a[:,:,3]=image_array(links[0].from_node.image,size)[:,:,0]
 atlas[y:y+size,x:x+size]=a
# Blender pixels are linear RGB; the engine's texture buffer expects sRGB bytes.
atlas[:,:,:3]=np.where(atlas[:,:,:3]<=.0031308,atlas[:,:,:3]*12.92,1.055*np.maximum(atlas[:,:,:3],0)**(1/2.4)-.055)
raw=(np.clip(atlas[::-1],0,1)*255+.5).astype(np.uint8).tobytes();(R/'assets/atlas.rgba').write_bytes(raw)
image=bpy.data.images.new('PunchDummy_Atlas',1024,1024,alpha=True)
linear=np.ones((1024,1024,4),dtype=np.float32);linear[:]=atlas
image.pixels.foreach_set(linear.reshape(-1));image.filepath_raw=str(R/'assets/PunchDummy_Atlas.png');image.file_format='PNG';image.save()
deps=bpy.context.evaluated_depsgraph_get();meshes=[];points=[]
for o in objects:
 mesh=bpy.data.meshes.new_from_object(o.evaluated_get(deps),preserve_all_data_layers=True,depsgraph=deps);mesh.calc_loop_triangles()
 coords=[o.matrix_world@v.co for v in mesh.vertices]
 # Static relaxed-arm derivative; only the copied visual mesh is changed.
 if o.name=='Punch_asian_boy':
  for j,p in enumerate(coords):
   if abs(p.x)>.19 and 1.28<p.z<1.8:
    sign=1 if p.x>0 else -1;angle=math.radians(48)*sign*min(1,max(0,(abs(p.x)-.19)/.12))
    pivot=Vector((sign*.19,.08,1.53));coords[j]=pivot+Matrix.Rotation(angle,3,'Y')@(p-pivot)
 points.extend(coords);meshes.append((o,mesh,coords))
minimum=min(p.z for p in points);maximum=max(p.z for p in points);scale=4.6/(maximum-minimum)
manifest=[]
for idx,(o,mesh,coords) in enumerate(meshes):
 def convert(p):return Vector((p.y*scale,(p.z-minimum)*scale,p.x*scale))
 positions=[convert(p)for p in coords];lo=Vector([min(p[k]for p in positions)for k in range(3)]);hi=Vector([max(p[k]for p in positions)for k in range(3)]);center=(lo+hi)/2
 verts=[];faces=[];dedup={};uvs=mesh.uv_layers.active.data
 for tri in mesh.loop_triangles:
  mi=mesh.polygons[tri.polygon_index].material_index
  if mats[mi].name.startswith('Std_Cornea'):continue
  x,y,size=tiles[mi];face=[]
  for li in tri.loops:
   loop=mesh.loops[li];p=positions[loop.vertex_index]-center;n=loop.normal;uv=uvs[li].uv
   data=tuple(round(float(q),6)for q in (*p,n.y,n.z,n.x,(x+2+float(uv.x)*(size-4))/1024,1-(y+2+float(uv.y)*(size-4))/1024))
   if data not in dedup:dedup[data]=len(verts);verts.append(data)
   face.append(dedup[data])
  faces.append(face)
 assert len(faces)<20000,(o.name,len(faces))
 blob=struct.pack('<II',len(verts),len(faces))+b''.join(struct.pack('<8f',*v)for v in verts)+b''.join(struct.pack('<III',*f)for f in faces)
 filename=f'mesh_{idx}.bin';(R/'assets'/filename).write_bytes(blob)
 manifest.append({'name':o.name,'file':filename,'vertices':len(verts),'triangles':len(faces),'center':list(center),'size':list(hi-lo)})
 bpy.data.meshes.remove(mesh)
(R/'assets/manifest.json').write_text(json.dumps({'height':4.6,'meshes':manifest,'textureSize':1024},indent=2))
print('MODEL_EXPORT_PASS meshes='+str(len(manifest))+' triangles='+str(sum(m['triangles']for m in manifest))+' atlas=1024 source=unchanged')

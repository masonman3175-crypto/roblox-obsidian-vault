import bpy,os
s=bpy.data.scenes['Reference_Rebuild_Studio']; bpy.context.window.scene=s
s.render.resolution_x=1800; s.render.resolution_y=1400; s.render.resolution_percentage=100
s.render.image_settings.file_format='PNG'
s.render.filepath=os.path.join(os.path.dirname(__file__),'reference_lineup.png')
bpy.ops.render.render(write_still=True)

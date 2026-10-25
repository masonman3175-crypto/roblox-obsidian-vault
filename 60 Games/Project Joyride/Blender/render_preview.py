# Renders preview PNGs of joyride_truck.blend with Workbench (material colors, cavity outline).
#   blender -b joyride_truck.blend --python render_preview.py -- <out_dir>
import bpy, math, os, sys
from mathutils import Vector

OUT = sys.argv[sys.argv.index("--") + 1]
scene = bpy.context.scene
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "STUDIO"
shading.color_type = "MATERIAL"
shading.show_cavity = True
shading.show_object_outline = True
scene.render.resolution_x, scene.render.resolution_y = 960, 720

wheel = bpy.data.objects["Wheel"]
for name, loc, rotz in (("WFL", (-3.25, -4.0, 1.5), math.pi), ("WRL", (-3.25, 4.0, 1.5), math.pi), ("WRR", (3.25, 4.0, 1.5), 0)):
    w = wheel.copy()
    w.name = name
    w.location = loc
    w.rotation_euler = (0, 0, rotz)
    scene.collection.objects.link(w)

cam_data = bpy.data.cameras.new("Cam")
cam_data.lens = 50
cam = bpy.data.objects.new("Cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
target = Vector((0, 0, 3.6))
for i, pos in enumerate(((-17, -17, 9), (14, 20, 8), (-22, 2, 4))):
    cam.location = pos
    cam.rotation_euler = (target - Vector(pos)).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = os.path.join(OUT, f"preview_{i + 1}.png")
    bpy.ops.render.render(write_still=True)
print("RENDERED")

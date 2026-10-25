# Project Joyride - procedural ice cream truck (Blender 5.x, run headless):
#   blender -b --python build_truck.py -- <out_dir>
# Units are Roblox studs. Blender axes: X right, Y forward, Z up, ground at z=0,
# truck centred between the axles. Outputs:
#   joyride_truck.blend, joyride_truck.fbx (objects: Body, Wheel)
#   truck_mesh.json  (Roblox space: x, y=up, z=-forward; per-face colors, corner normals)

import bpy, bmesh, math, json, os, sys, random
from mathutils import Vector, Matrix

OUT = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else os.path.dirname(__file__)
bpy.ops.wm.read_factory_settings(use_empty=True)

COLORS = {
    "Cream": (255, 236, 200), "Blue": (140, 200, 240), "Pink": (242, 110, 150),
    "PinkLight": (250, 175, 200), "White": (250, 250, 250), "Glass": (40, 60, 95),
    "Tire": (38, 38, 44), "Dark": (55, 55, 65), "Well": (45, 40, 50),
    "Headlight": (255, 240, 170), "Orange": (255, 150, 40), "Red": (255, 60, 50),
    "Cone": (222, 160, 90), "ConeDark": (190, 125, 65),
    "ScoopCream": (255, 240, 205), "ScoopPink": (244, 120, 160), "ScoopPinkLight": (250, 185, 205),
    "SprBlue": (110, 180, 255), "SprYellow": (255, 205, 70), "SprPurple": (170, 130, 230), "SprGreen": (120, 220, 170),
}
MATS = {}


def mat(name):
    if name not in MATS:
        m = bpy.data.materials.new(name)
        r, g, b = (c / 255 for c in COLORS[name])
        m.diffuse_color = (r, g, b, 1)
        MATS[name] = m
    return MATS[name]


BODY, WHEEL, CUTTERS = [], [], []


def new_obj(name, bm, color, group=BODY):
    me = bpy.data.meshes.new(name)
    bm.normal_update()
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    for c in ([color] if isinstance(color, str) else color):
        me.materials.append(mat(c))
    if group is not None:
        group.append(o)
    return o


def bevel(o, width, segs=3, angle=35):
    m = o.modifiers.new("Bevel", "BEVEL")
    m.width = width
    m.segments = segs
    m.limit_method = "ANGLE"
    m.angle_limit = math.radians(angle)
    return o


def box(name, color, x0, x1, y0, y1, z0, z1, bev=0.0, segs=3, group=BODY, matrix=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    sx, sy, sz = x1 - x0, y1 - y0, z1 - z0
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    bmesh.ops.translate(bm, vec=((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), verts=bm.verts)
    if matrix is not None:
        bmesh.ops.transform(bm, matrix=matrix, verts=bm.verts)
    o = new_obj(name, bm, color, group)
    if bev > 0:
        bevel(o, min(bev, sx / 2.05, sy / 2.05, sz / 2.05), segs)
    return o


def obox(name, color, center, size, rot, bev=0.0, segs=2, group=BODY):
    """Box of `size` centred at origin, rotated by 3x3 `rot`, moved to `center`."""
    m = Matrix.Translation(Vector(center)) @ rot.to_4x4()
    return box(name, color, -size[0] / 2, size[0] / 2, -size[1] / 2, size[1] / 2, -size[2] / 2, size[2] / 2,
               bev, segs, group, matrix=m)


def lathe(name, profile, segs, matrix, group=BODY):
    """Revolve profile [(radius, x, colorName), ...] around local X, then apply `matrix`.
    Faces between point i and i+1 use point i's color."""
    bm = bmesh.new()
    names = []
    for _, _, c in profile:
        if c not in names:
            names.append(c)
    rings = []
    for r, x, _ in profile:
        if r <= 1e-6:
            rings.append([bm.verts.new((x, 0, 0))])
        else:
            rings.append([bm.verts.new((x, r * math.cos(2 * math.pi * k / segs), r * math.sin(2 * math.pi * k / segs)))
                          for k in range(segs)])
    for i in range(len(profile) - 1):
        a, b = rings[i], rings[i + 1]
        idx = names.index(profile[i][2])
        for k in range(segs):
            k2 = (k + 1) % segs
            if len(a) == 1:
                vs = (a[0], b[k2], b[k])
            elif len(b) == 1:
                vs = (a[k], a[k2], b[0])
            else:
                vs = (a[k], a[k2], b[k2], b[k])
            try:
                f = bm.faces.new(vs)
                f.material_index = idx
            except ValueError:
                pass
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.transform(bm, matrix=matrix, verts=bm.verts)
    return new_obj(name, bm, names, group)


def axis_matrix(origin, direction):
    """4x4 mapping local +X to `direction`, placed at `origin`."""
    d = Vector(direction).normalized()
    up = Vector((0, 0, 1)) if abs(d.z) < 0.95 else Vector((0, 1, 0))
    y = up.cross(d).normalized()
    z = d.cross(y).normalized()
    m = Matrix((d, y, z)).transposed().to_4x4()
    m.translation = Vector(origin)
    return m


def sphere(name, color, center, radius, squash=1.0, group=BODY):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=11, radius=radius)
    bmesh.ops.scale(bm, vec=(1, 1, squash), verts=bm.verts)
    bmesh.ops.translate(bm, vec=center, verts=bm.verts)
    return new_obj(name, bm, color, group)


def split_faces(bm, split_z):
    geom = list(bm.verts) + list(bm.edges) + list(bm.faces)
    bmesh.ops.bisect_plane(bm, geom=geom, plane_co=(0, 0, split_z), plane_no=(0, 0, 1))
    for f in bm.faces:
        f.material_index = 0 if f.calc_center_median().z < split_z else 1


def prism_x(name, pts_yz, x0, x1, split_z):
    """Extrude a YZ polygon along X; faces below split_z are Blue, above Cream."""
    bm = bmesh.new()
    vs = [bm.verts.new((x0, y, z)) for y, z in pts_yz]
    f = bm.faces.new(vs)
    res = bmesh.ops.extrude_face_region(bm, geom=[f])
    nv = [g for g in res["geom"] if isinstance(g, bmesh.types.BMVert)]
    bmesh.ops.translate(bm, vec=(x1 - x0, 0, 0), verts=nv)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    split_faces(bm, split_z)
    return new_obj(name, bm, ["Blue", "Cream"])


def arc_tube(name, color, x, cy, cz, R, a0, a1, segs, radial, lateral, ring=10):
    """Fender flare: a rounded tube following a circular arc in the YZ plane."""
    bm = bmesh.new()
    rings = []
    for i in range(segs + 1):
        a = math.radians(a0 + (a1 - a0) * i / segs)
        n = Vector((0, math.cos(a), math.sin(a)))
        c = Vector((x, cy, cz)) + n * R
        rings.append([bm.verts.new(c + n * (radial * math.cos(2 * math.pi * k / ring))
                                   + Vector((lateral * math.sin(2 * math.pi * k / ring), 0, 0)))
                      for k in range(ring)])
    for i in range(segs):
        for k in range(ring):
            k2 = (k + 1) % ring
            bm.faces.new((rings[i][k], rings[i][k2], rings[i + 1][k2], rings[i + 1][k]))
    bm.faces.new(rings[0])
    bm.faces.new(list(reversed(rings[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return new_obj(name, bm, color)


def cutter_cylinder(y, z, r):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=40, radius1=r, radius2=r, depth=9)
    bmesh.ops.rotate(bm, cent=(0, 0, 0), matrix=Matrix.Rotation(math.radians(90), 3, "Y"), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0, y, z), verts=bm.verts)
    o = new_obj("Cutter", bm, "Well", group=CUTTERS)
    o.hide_render = True
    return o


# Dimensions (match Config.Vehicle.Dimensions) -------------------------------------------
W = 3.5                  # half width
WR, WB = 1.5, 4.0        # wheel radius, half wheelbase
ARCH_R = 1.9
SPLIT = 2.35             # blue / cream line
ROOF = 6.9

# Shell -----------------------------------------------------------------------------------
cab_profile = [(-6.45, 0.95), (-6.45, 3.55), (-6.2, 3.85), (-4.55, 3.98), (-3.7, 5.85), (-1.75, 5.98), (-1.75, 0.95)]
cab = prism_x("Cab", cab_profile, -3.45, 3.45, SPLIT)
bevel(cab, 0.32, 3, 30)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1)
bmesh.ops.scale(bm, vec=(2 * W, 8.3, ROOF - 0.95), verts=bm.verts)
bmesh.ops.translate(bm, vec=(0, 2.25, (ROOF + 0.95) / 2), verts=bm.verts)
split_faces(bm, SPLIT)
rear = new_obj("RearBox", bm, ["Blue", "Cream"])
bevel(rear, 0.4, 3, 30)

# Wheel arches: boolean cut; the well walls take the dark cutter material.
for shell in (cab, rear):
    shell.data.materials.append(mat("Well"))
for wy in (WB, -WB):
    c = cutter_cylinder(wy, WR, ARCH_R)
    for shell in (cab, rear):
        mod = shell.modifiers.new("Arch", "BOOLEAN")
        mod.operation = "DIFFERENCE"
        mod.solver = "EXACT"
        mod.object = c
        mod.material_mode = "TRANSFER"

# Fender flares: pink arcs hugging each arch with consistent rounded thickness.
for s in (-1, 1):
    for wy in (WB, -WB):
        arc_tube("Flare", "Pink", s * (W + 0.12), wy, WR, ARCH_R + 0.05, -12, 192, 28, 0.2, 0.3)

# Glass and lights --------------------------------------------------------------------------
A, B = Vector((-4.55, 3.98)), Vector((-3.7, 5.85))
d = (B - A).normalized()
nrm = Vector((-d.y, d.x))
mid = (A + B) / 2 + nrm * 0.05
ang = math.atan2(d.y, d.x)
obox("Windshield", "Glass", (0, mid.x, mid.y), (5.9, (B - A).length * 0.82, 0.08), Matrix.Rotation(ang, 3, "X"), 0.03)
obox("WindshieldPillar", "Cream", (0, mid.x + nrm.x * 0.02, mid.y + nrm.y * 0.02), (0.28, (B - A).length * 0.82, 0.1),
     Matrix.Rotation(ang, 3, "X"), 0.03)
for s in (-1, 1):
    box("CabWindow", "Glass", s * 3.44 - 0.04, s * 3.44 + 0.04, -3.9, -2.2, 4.1, 5.45, 0.03, 2)
    box("DoorWindow", "Glass", s * W - 0.04, s * W + 0.04, -1.6, -0.5, 4.4, 5.9, 0.03, 2)
    box("DoorHandle", "Dark", s * (W + 0.05) - 0.06, s * (W + 0.05) + 0.06, -1.3, -0.85, 3.6, 3.78, 0.04, 2)
    box("MirrorArm", "Dark", min(s * 3.45, s * 4.05), max(s * 3.45, s * 4.05), -4.15, -4.0, 4.45, 4.58, 0.03, 2)
    box("Mirror", "Dark", s * 4.05 - 0.18, s * 4.05 + 0.18, -4.25, -3.75, 4.2, 5.2, 0.12, 2)
    lathe("Headlight", [(0.68, 0.0, "PinkLight"), (0.68, 0.12, "PinkLight"), (0.55, 0.16, "Headlight"),
                        (0.35, 0.2, "Headlight"), (0.0, 0.22, "Headlight")], 20, axis_matrix((s * 2.4, -6.45, 3.0), (0, -1, 0)))
    box("Indicator", "Orange", s * 2.4 - 0.35, s * 2.4 + 0.35, -6.55, -6.4, 2.1, 2.42, 0.05, 2)
    box("TailLight", "Red", s * 2.9 - 0.3, s * 2.9 + 0.3, 6.38, 6.5, 3.1, 3.95, 0.08, 2)
    box("TailIndicator", "Orange", s * 2.9 - 0.3, s * 2.9 + 0.3, 6.38, 6.5, 2.55, 3.0, 0.06, 2)
    box("RearWindow", "Glass", s * 0.8 - 0.55, s * 0.8 + 0.55, 6.38, 6.48, 4.9, 6.2, 0.06, 2)
    box("BumperCap", "White", s * 2.4 - 0.35, s * 2.4 + 0.35, -7.05, -6.35, 0.95, 2.05, 0.12, 2)
    box("RearBumperCap", "White", s * 2.4 - 0.35, s * 2.4 + 0.35, 6.35, 7.0, 0.95, 1.95, 0.12, 2)
    lathe("RoofRail", [(0.0, 0.0, "Pink"), (0.16, 0.0, "Pink"), (0.16, 7.6, "Pink"), (0.0, 7.6, "Pink")], 10,
          axis_matrix((s * 3.0, -1.6, ROOF + 0.35), (0, 1, 0)))
    for ly in (-1.3, 2.4, 5.7):
        box("RailLeg", "Pink", s * 3.0 - 0.1, s * 3.0 + 0.1, ly - 0.1, ly + 0.1, ROOF - 0.05, ROOF + 0.35, 0.03, 1)
    box("Marker", "Orange", s * 2.95 - 0.22, s * 2.95 + 0.22, -1.75, -1.5, ROOF - 0.05, ROOF + 0.15, 0.05, 2)
    box("MarkerRear", "Orange", s * 2.95 - 0.22, s * 2.95 + 0.22, 6.0, 6.25, ROOF - 0.05, ROOF + 0.15, 0.05, 2)
    box("CabMarker", "Orange", s * 2.6 - 0.2, s * 2.6 + 0.2, -3.9, -3.65, 5.9, 6.1, 0.05, 2)

for by in (-0.9, 2.4, 5.4):
    lathe("RoofBar", [(0.0, 0.0, "Pink"), (0.13, 0.0, "Pink"), (0.13, 6.0, "Pink"), (0.0, 6.0, "Pink")], 8,
          axis_matrix((-3.0, by, ROOF + 0.35), (1, 0, 0)))

box("RearDoorSeam", "Dark", -0.05, 0.05, 6.4, 6.47, 2.4, 6.5, 0, 1)
box("Grille", "PinkLight", -1.75, 1.75, -6.6, -6.38, 2.4, 3.55, 0.12, 2)
for gz in (2.62, 2.97, 3.32):
    box("GrilleSlat", "Dark", -1.5, 1.5, -6.66, -6.55, gz - 0.09, gz + 0.09, 0.04, 1)
box("FrontBumper", "Pink", -3.75, 3.75, -7.0, -6.3, 0.9, 2.0, 0.32, 3)
box("RearBumper", "Pink", -3.7, 3.7, 6.3, 6.95, 0.9, 1.9, 0.3, 3)
box("SideStep", "White", -3.95, -3.45, -0.9, 0.9, 0.95, 1.15, 0.06, 2)

# Serving window (left / -X side) ----------------------------------------------------------
wx = -W
box("WindowFrame", "White", wx - 0.08, wx + 0.02, 0.05, 3.95, 3.75, 6.15, 0.05, 2)
box("ServingWindow", "Glass", wx - 0.12, wx - 0.04, 0.3, 3.7, 4.0, 5.9, 0.03, 1)
box("Counter", "Pink", wx - 0.9, wx + 0.02, -0.05, 4.05, 3.68, 3.92, 0.08, 2)
stripes = 8
for i in range(stripes):
    y0 = -0.1 + i * 4.2 / stripes
    col = "Pink" if i % 2 == 0 else "White"
    obox("Awning", col, (wx - 0.72, y0 + 2.1 / stripes, 6.15), (1.55, 4.2 / stripes + 0.005, 0.12),
         Matrix.Rotation(math.radians(24), 3, "Y"), 0.02, 1)
    lathe("Scallop", [(0.0, -0.05, col), (0.26, -0.05, col), (0.26, 0.05, col), (0.0, 0.05, col)], 14,
          axis_matrix((wx - 1.42, y0 + 2.1 / stripes, 5.8), (1, 0, 0)))
for i, sc in enumerate(("ScoopCream", "ScoopPink")):
    y = 1.3 + i * 0.75
    lathe("MiniCone", [(0.0, 0.0, "Cone"), (0.24, 0.55, "Cone"), (0.0, 0.56, "Cone")], 10,
          axis_matrix((wx - 0.42, y, 3.92), (0, 0, 1)))
    sphere("MiniScoop", sc, (wx - 0.42, y, 4.62), 0.3)
box("MenuBorder", "Pink", wx - 0.06, wx + 0.02, 4.15, 5.65, 3.7, 6.0, 0.05, 2)
box("MenuSign", "White", wx - 0.1, wx - 0.04, 4.25, 5.55, 3.8, 5.9, 0.03, 1)
lathe("MenuCone", [(0.0, 0.0, "Cone"), (0.22, 0.75, "Cone"), (0.0, 0.76, "Cone")], 8,
      axis_matrix((wx - 0.12, 4.9, 4.0), (0, 0, 1)))
sphere("MenuScoop", "ScoopPink", (wx - 0.12, 4.9, 4.95), 0.32, 0.9)
sphere("MenuScoop2", "Blue", (wx - 0.12, 4.9, 5.42), 0.27, 0.9)

# Sprinkles on the sides
rnd = random.Random(7)
spr = ["SprBlue", "SprYellow", "SprPurple", "Pink", "SprGreen"]
for s in (-1, 1):
    for i in range(8):
        y = rnd.uniform(-1.4, 6.0)
        if s == -1 and -0.2 < y < 5.8:
            y = rnd.uniform(-1.5, -0.4)
        obox("Sprinkle", spr[i % 5], (s * (W + 0.04), y, rnd.uniform(2.6, 3.6)), (0.1, 0.55, 0.16),
             Matrix.Rotation(rnd.uniform(-1.2, 1.2), 3, "X"), 0.05, 2)

# Megaphone (front-left of roof)
box("MegaMount", "Dark", -2.45, -2.15, -1.35, -1.05, ROOF - 0.05, ROOF + 0.55, 0.05, 1)
lathe("Megaphone", [(0.0, 0.0, "Pink"), (0.3, 0.0, "Pink"), (0.3, 0.7, "Pink"), (0.36, 0.75, "Pink"),
                    (0.68, 1.35, "Pink"), (0.6, 1.38, "Dark"), (0.0, 1.2, "Dark")], 18,
      axis_matrix((-2.3, -1.0, ROOF + 0.85), (0, -1, 0)))

# Giant roof cone + scoops ----------------------------------------------------------------
CS = 0.72  # cone scale relative to the first pass (which towered over the truck)
mouth = Vector((-0.2, 0.9, ROOF + 1.45))
cone_dir = Vector((1.0, -0.3, 0.3)).normalized()
bands = 10
prof = [(0.0, 0.0, "Cone"), (1.95 * CS, 0.05, "ConeDark")]
for i in range(bands + 1):
    t = i / bands
    prof.append(((1.9 * (1 - t) + 0.15 * t) * CS, (0.2 + t * 6.0) * CS, "Cone" if i % 2 == 0 else "ConeDark"))
prof.append((0.0, 6.35 * CS, "ConeDark"))
lathe("Cone", prof, 22, axis_matrix(mouth, cone_dir))
box("ConeMount", "Pink", -1.3, 1.1, -0.4, 2.2, ROOF - 0.05, ROOF + 0.5, 0.18, 2)
scoops = [((-0.6, 0.5, 0.1), 1.7, "ScoopCream"), ((0.9, 0.1, 0.5), 1.5, "ScoopPink"),
          ((0.2, 0.9, 1.4), 1.3, "ScoopPinkLight"), ((-1.2, -0.4, 1.0), 1.2, "ScoopCream")]
for off, r, col in scoops:
    r *= CS
    c = mouth + Vector(off) * CS
    sphere("Scoop", col, c, r, 0.92)
    for k in range(6):
        dvec = Vector((rnd.uniform(-1, 1), rnd.uniform(-1, 1), rnd.uniform(0.15, 1))).normalized()
        rot = dvec.to_track_quat("Z", "Y").to_matrix() @ Matrix.Rotation(rnd.uniform(0, 3), 3, "Z")
        obox("ScoopSprinkle", spr[k % 5], c + dvec * r * 0.95, (0.12, 0.42, 0.12), rot, 0.05, 2)

# Wheel (one object, axle along X, outer face +X, centred at origin) -----------------------
tire_prof = [(0.98, -0.66, "Tire"), (1.25, -0.66, "Tire"), (1.42, -0.6, "Tire"), (1.5, -0.42, "Tire"),
             (1.5, 0.42, "Tire"), (1.42, 0.6, "Tire"), (1.25, 0.66, "Tire"), (0.98, 0.66, "Tire")]
lathe("Tire", tire_prof, 28, Matrix.Identity(4), group=WHEEL)
rim_prof = [(0.0, 0.7, "Dark"), (0.24, 0.7, "Dark"), (0.26, 0.66, "White"), (0.62, 0.62, "White"),
            (0.66, 0.6, "Pink"), (0.98, 0.56, "Pink"), (1.0, 0.5, "Pink"), (1.0, -0.5, "Pink"),
            (0.98, -0.56, "Pink"), (0.0, -0.58, "Pink")]
lathe("Rim", rim_prof, 24, Matrix.Identity(4), group=WHEEL)
for k in range(5):
    a = 2 * math.pi * k / 5
    obox("Lug", "White", (0.68, math.cos(a) * 0.43, math.sin(a) * 0.43), (0.12, 0.16, 0.16),
         Matrix.Identity(3), 0.04, 1, group=WHEEL)

# Bake: evaluate modifiers, merge per group, export ------------------------------------------
dg = bpy.context.evaluated_depsgraph_get()


def bake(objs, name):
    bm = bmesh.new()
    mats = []
    for o in objs:
        me = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
        me.transform(o.matrix_world)
        remap = []
        for m in me.materials:
            names = [x.name for x in mats]
            if m.name not in names:
                mats.append(m)
            remap.append([x.name for x in mats].index(m.name))
        for p in me.polygons:
            p.material_index = remap[p.material_index] if remap else 0
        bm.from_mesh(me)
        bpy.data.meshes.remove(me)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    for m in mats:
        me.materials.append(m)
    me.shade_smooth()
    me.set_sharp_from_angle(angle=math.radians(38))
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    return o


body = bake(BODY, "Body")
wheel = bake(WHEEL, "Wheel")
for o in BODY + WHEEL + CUTTERS:
    bpy.data.objects.remove(o)


def export_json(o):
    me = o.data
    me.calc_loop_triangles()
    cn = me.corner_normals
    verts = [[round(v.co.x, 3), round(v.co.z, 3), round(-v.co.y, 3)] for v in me.vertices]
    normals, nindex = [], {}

    def nid(vec):
        key = (round(vec.x, 2), round(vec.z, 2), round(-vec.y, 2))
        if key not in nindex:
            nindex[key] = len(normals)
            normals.append(list(key))
        return nindex[key]

    palette = [list(COLORS[m.name]) for m in me.materials]
    faces = [list(t.vertices) + [nid(cn[li].vector) for li in t.loops] + [t.material_index] for t in me.loop_triangles]
    return {"verts": verts, "normals": normals, "palette": palette, "faces": faces}


data = {"Body": export_json(body), "Wheel": export_json(wheel)}
with open(os.path.join(OUT, "truck_mesh.json"), "w") as f:
    json.dump(data, f, separators=(",", ":"))
print("TRIS body", len(data["Body"]["faces"]), "wheel", len(data["Wheel"]["faces"]),
      "verts", len(data["Body"]["verts"]), "normals", len(data["Body"]["normals"]))

wheel.location = (3.25, -4.0, 1.5)  # preview placement only; JSON is exported centred
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "joyride_truck.blend"))
bpy.ops.export_scene.fbx(filepath=os.path.join(OUT, "joyride_truck.fbx"), use_selection=False,
                         apply_scale_options="FBX_SCALE_ALL", axis_forward="-Z", axis_up="Y")
print("DONE")

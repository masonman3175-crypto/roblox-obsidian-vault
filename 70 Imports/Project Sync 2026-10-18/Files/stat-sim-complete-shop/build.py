from pathlib import Path
import json
import shutil

ROOT = Path(__file__).resolve().parent
BASE = ROOT / "baseline"
OUT = ROOT / "modified"
OUT.mkdir(exist_ok=True)
for p in BASE.glob("*.luau"):
    shutil.copy2(p, OUT / p.name)

mapping = json.loads((ROOT / "icons" / "atlas_mapping.json").read_text(encoding="utf-8"))
mapping["RebirthButton"] = mapping["Rebirth"]
mapping["SkipButton"] = mapping["RebirthSkip"]
lines = [f'    {key} = Vector2.new({xy[0]}, {xy[1]}),' for key, xy in mapping.items()]

p = OUT / "UiStyle.luau"
s = p.read_text(encoding="utf-8")
a = s.index("-- Original typographic brand mark")
b = s.index("\nfunction UiStyle.Logo", a)
s = s[:a] + '''-- Original illustrated atlas: each key crops a distinct cartoon pictogram.
local ICON_ATLAS = "rbxassetid://101842589645723"
local ICON_OFFSETS = {
''' + "\n".join(lines) + "\n}\n" + s[b:]
a = s.index('    new("Frame", {\n        Name="Underline"', s.index('function UiStyle.Logo'))
b = s.index('    return frame', a)
s = s[:a] + '''    new("ImageLabel", {
        Name = "Picture",
        BackgroundTransparency = 1,
        Image = ICON_ATLAS,
        ImageRectOffset = ICON_OFFSETS[props.Key] or ICON_OFFSETS.Shop,
        ImageRectSize = Vector2.new(128, 128),
        ScaleType = Enum.ScaleType.Stretch,
        Position = UDim2.fromScale(0.04, 0.02),
        Size = UDim2.fromScale(0.92, 0.92),
        ZIndex = z + 3,
        Parent = face,
    })
''' + s[b:]
p.write_text(s, encoding="utf-8", newline="\n")

p = OUT / "ShopController.luau"
s = p.read_text(encoding="utf-8")
s = s.replace('Position = UDim2.fromOffset(11, 9), Size = UDim2.fromOffset(62, 62)',
              'Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(76, 76)')
s = s.replace('Position = UDim2.fromOffset(78, 14)', 'Position = UDim2.fromOffset(96, 14)')
s = s.replace('Size = UDim2.new(1, -88, 0, 54)', 'Size = UDim2.new(1, -106, 0, 54)')
p.write_text(s, encoding="utf-8", newline="\n")
print(f"BUILD PASS: illustrated atlas bound for {len(mapping)} logo keys")

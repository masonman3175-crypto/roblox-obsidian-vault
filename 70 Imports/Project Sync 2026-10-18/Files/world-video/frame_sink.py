import sys, json, base64
import ctypes, os
from pathlib import Path
root=Path(__file__).resolve().parent/'frames'
root.mkdir(exist_ok=True)
if os.name=='nt' and sys.stdin.isatty():
    kernel=ctypes.windll.kernel32
    handle=kernel.GetStdHandle(-10)
    mode=ctypes.c_ulong()
    if kernel.GetConsoleMode(handle,ctypes.byref(mode)):
        kernel.SetConsoleMode(handle,mode.value & ~0x0006)
print('FRAME SINK READY',flush=True)
for line in sys.stdin:
    if not line.strip():
        continue
    item=json.loads(line)
    if item.get('done'):
        print('FRAME SINK CLOSED',flush=True)
        break
    name=f"frame_{int(item['frame']):04d}.jpg"
    (root/name).write_bytes(base64.b64decode(item['data']))
    print(f"FRAME {item['frame']} SAVED",flush=True)

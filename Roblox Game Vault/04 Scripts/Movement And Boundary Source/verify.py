from pathlib import Path
import hashlib, json, re, sys
root=Path(__file__).resolve().parent
hashes=json.loads((root/"HASHES.json").read_text())
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def source(name): return (root/name).read_text(encoding="utf-8-sig")
def number(text,key): return float(re.search(r"\b"+key+r"\s*=\s*([.0-9]+)",text).group(1))
mode=sys.argv[1].upper()
for name in ("BASELINE_Config.luau","BASELINE_Client.luau","BASELINE_Server.luau"):
    assert digest(root/name)==hashes[name], name+" changed"
if mode=="BASELINE":
    c=source("BASELINE_Config.luau")
    assert number(c,"SlideCooldown")==1.25 and number(c,"CameraDrop")==.78
    assert number(c,"StaminaMax")/number(c,"SprintDrain")==6.25
elif mode=="MODIFIED":
    c=source("MovementConfig.luau")
    assert number(c,"SlideCooldown")==0 and number(c,"CameraDrop")==1.45
    assert number(c,"StaminaMax")/number(c,"SprintDrain")==20
    assert number(c,"SlideEndSpeed")>=number(c,"SlideMinSpeed")
    client=source("MODIFIED_FILE.luau")
    assert "hum.CameraOffset=baseCameraOffset+Vector3.new(0,-drop,0)" in client
    assert "queuedSlideStamp" in client and "lastChainAttempt" in client
    server=source("MovementServer.luau")
    assert "local wasSliding=" in server and "math.max(50000" in server
    assert "s.BaseC0*CFrame.new" not in server
    wall=source("BuildBoundary.luau")
    for name in ("NorthSolid","SouthSolid","EastSolid","WestSolid","EastGroundApron","WestGroundApron","NorthGroundApron","SouthGroundApron"):
        assert name in wall
    for name in ("MODIFIED_FILE.luau","MovementConfig.luau","MovementServer.luau","BuildBoundary.luau"):
        assert digest(root/name)==hashes[name], name+" changed after verification snapshot"
elif mode=="ROLLBACK":
    target=Path(sys.argv[2]).resolve()
    assert target!=root/"MODIFIED_FILE.luau"
    assert digest(target)==hashes["BASELINE_Client.luau"]
    assert digest(root/"MODIFIED_FILE.luau")==hashes["MODIFIED_FILE.luau"]
else:
    raise ValueError(mode)
print(mode+": PASS")

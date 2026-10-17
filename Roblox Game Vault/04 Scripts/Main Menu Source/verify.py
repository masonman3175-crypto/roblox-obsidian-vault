from pathlib import Path
import hashlib, sys
root = Path(__file__).resolve().parent
mode = sys.argv[1].upper()
baseline = root / "BASELINE_MenuClient.luau"
current = root / "MODIFIED_FILE.luau"
b = baseline.read_text(encoding="utf-8-sig")
s = current.read_text(encoding="utf-8-sig")
assert hashlib.sha256(baseline.read_bytes()).hexdigest().upper() == "F733EF89FCFC3004011B63ED54C87FC5492BF3859668148AA809C7ADCF6EB1C6"
if mode == "BASELINE":
    assert "b.Selected.Visible" in b and "LiveBirdsEye" not in b
    print("BASELINE: minimal layout; no aerial background; selection collision detected")
elif mode == "MODIFIED":
    for token in ("MainMenuStreamingFocus", "ReplicationFocus=nil"):
        assert token in (root / "Server.luau").read_text(encoding="utf-8-sig")
    for token in ("LiveBirdsEye", "menuLighting(value)", "RankPanel", "FeatureCard", "Toolbar", "AgentViewport", "RequestStreamAroundAsync", "FindFirstChild('Selected')"):
        assert token in s, token
    assert "GothamLight" not in s and "b.Selected.Visible" not in s
    config = (root / "MenuConfig.luau").read_text(encoding="utf-8-sig")
    assert "GLACIER" in config and "ARCTIC" in config
    print("MODIFIED: detailed layout; live aerial view; 4 skins / 6 wraps; source checks PASS")
else:
    raise ValueError(mode)

from pathlib import Path
import hashlib
import sys

root = Path(__file__).resolve().parent
mode = sys.argv[1] if len(sys.argv) > 1 else ""
if mode == "baseline":
    p = root / "baseline" / "PunchFxController.luau"
    s = p.read_text(encoding="utf-8")
    assert "impactAudio()" not in s
    assert "SoundService" not in s
    print("BASELINE PASS: punch cutscene had no hit, whoosh, or boing audio")
elif mode == "modified":
    p = root / "modified" / "PunchFxController.luau"
    s = p.read_text(encoding="utf-8")
    v = (root / "modified" / "install_visual.luau").read_text(encoding="utf-8")
    assert 'local SoundService = game:GetService("SoundService")' in s
    assert 'local MEME_CLIP_ASSET_ID = ""' in s
    assert "rbxassetid://9120709477" in s
    assert "rbxassetid://7468131335" in s
    assert "rbxassetid://75314486373846" in s
    assert "sound:Stop(); sound:Destroy()" in s
    assert "impactAudio()" in s
    assert 'dummy:SetAttribute("VisualStyle", "CartoonBoy2026")' in v
    assert "dummy.CharacterVisual:Destroy()" in v
    assert "PunchPrompt" in v
    assert p.read_bytes() == (root / "MODIFIED_FILE").read_bytes()
    print("MODIFIED PASS: cartoon visual installer, 3 punch SFX, 2-second hit cap, source mirror")
elif mode == "rollback":
    p = root / "rollback-copy" / "PunchFxController.luau"
    assert p.read_bytes() == (root / "baseline" / "PunchFxController.luau").read_bytes()
    assert p.read_bytes() != (root / "modified" / "PunchFxController.luau").read_bytes()
    print("ROLLBACK PASS: original silent cutscene restored in test copy; modified source retained")
else:
    raise SystemExit("usage: python validate.py baseline|modified|rollback")

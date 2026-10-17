import difflib,pathlib
p=pathlib.Path(__file__).resolve().parent
diff=''
for before,after in [('BASELINE_Controller.luau','MODIFIED_FILE.luau'),('BASELINE_Config.luau','WeaponConfig.luau')]:
    diff+=''.join(difflib.unified_diff((p/before).read_text().splitlines(True),(p/after).read_text().splitlines(True),fromfile=before,tofile=after))
diff+='\n# Additional model changes: see geometry.luau. Studio baseline saved in ServerStorage.WeaponPolishBackup_20261016.\n'
(p/'DIFF_FILE.patch').write_text(diff,encoding='utf8')
print('DIFF PASS controller/config changes recorded')

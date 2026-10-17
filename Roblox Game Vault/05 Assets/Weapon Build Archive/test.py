import pathlib,subprocess,sys
root=pathlib.Path(__file__).resolve().parent
mode=sys.argv[1]
file={'baseline':'BASELINE.blend','modified':'MODIFIED_FILE.blend','rollback':'rollback-test.blend'}[mode]
blender=r'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe'
result=subprocess.run([blender,'--background',str(root/file),'--python-exit-code','1','--python',str(root/'verify_scene.py'),'--','baseline' if mode=='rollback' else mode],capture_output=True,text=True)
(root/(mode+'-test.log')).write_text(result.stdout+'\n'+result.stderr,encoding='utf8')
lines=[s for s in result.stdout.splitlines() if s.startswith('TEST_RESULT ')]
for line in lines:
    output=line.removeprefix('TEST_RESULT ').replace('BASELINE','ROLLBACK') if mode=='rollback' else line.removeprefix('TEST_RESULT ')
    print(' '.join(output.split()[:2]) if '--brief' in sys.argv else output)
if result.returncode or not lines:
    print(result.stdout[-5000:]); print(result.stderr[-3000:]); sys.exit(result.returncode or 1)

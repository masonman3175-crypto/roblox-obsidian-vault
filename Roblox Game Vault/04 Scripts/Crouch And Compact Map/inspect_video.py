import sys, pathlib, subprocess
root=pathlib.Path(r"C:\Users\mason\.codex\visualizations\2026\10\16\01a14317-0d61-7650-b711-1ea3626ed7b5\crouch_boundary_floor")
sys.path.insert(0,str(root/"video_deps"))
import imageio_ffmpeg
f=imageio_ffmpeg.get_ffmpeg_exe()
video=r"C:\Users\mason\Videos\Screen Recordings\Screen Recording 2026-10-17 111235.mp4"
p=subprocess.run([f,"-hide_banner","-i",video,"-vf","fps=2,scale=1280:-2","-frames:v","12",str(root/"clip_%02d.png")],capture_output=True,text=True)
print(p.stderr[-4500:]);print("EXIT",p.returncode)


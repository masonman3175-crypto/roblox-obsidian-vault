import sys,pathlib,subprocess
r=pathlib.Path(r"C:\Users\mason\.codex\visualizations\2026\10\16\01a14317-0d61-7650-b711-1ea3626ed7b5")
sys.path.insert(0,str(r/'crouch_boundary_floor/video_deps'))
import imageio_ffmpeg
f=imageio_ffmpeg.get_ffmpeg_exe()
v=r'C:\Users\mason\Downloads\v12044gd0000dari477og65rmfl0qa80.mp4'
p=subprocess.run([f,'-hide_banner','-i',v,'-vf','fps=1/3,scale=640:-2','-frames:v','30',str(r/'slide_pose_repair/ref_%02d.png')],capture_output=True,text=True)
print(p.stderr[-4000:]);print('EXIT',p.returncode)
from PIL import Image,ImageDraw
files=list((r/'slide_pose_repair').glob('ref_*.png'));sheet=Image.new('RGB',(640*3,380*((len(files)+2)//3)),(20,20,20));d=ImageDraw.Draw(sheet)
for i,file in enumerate(files):
 im=Image.open(file);im.thumbnail((640,350));x=(i%3)*640;y=(i//3)*380;sheet.paste(im,(x,y));d.text((x+8,y+354),f'{i*3} sec / {file.name}',fill='white')
sheet.save(r/'slide_pose_repair/REFERENCE_SHEET.jpg')

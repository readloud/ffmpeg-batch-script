import subprocess
import os
import glob
from tqdm import tqdm

# Vertical Settings
WIDTH, HEIGHT = 1080, 1920
BG_VIDEO = "bg_loop.mp4"
DEFAULT_IMAGE = "cover.jpg"
LOGO_FILE = "logo.png"

songs = glob.glob("*.mp3")

for audio_file in tqdm(songs, desc="Creating Shorts"):
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + "_vertical.mp4"
    
    # Matching image...
    image_to_use = DEFAULT_IMAGE
    
    ffmpeg_cmd = [
        'ffmpeg', '-y', '-loglevel', 'error',
        '-i', audio_file, 
        '-stream_loop', '-1', '-i', BG_VIDEO, 
        '-i', image_to_use,
        '-filter_complex', 
        # 1. Vertical Background (Blurred & Vignetted)
        f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=40:20,vignette=angle=0.5[bg]; "
        # 2. Circular Waveform (The "Ring" effect)
        f"[0:a]showwaves=s={WIDTH}x{WIDTH}:mode=line:colors=#25d3d0:draw=full,format=rgba,"
        f"extractplanes=r+g+b+a,geometry=hypot(x-W/2\,y-H/2):0:0:0:0:0:0:0:0:0:0:0:0:0:0:0[vwave]; "
        # 3. Center Art (Scaled to a nice square for the vertical screen)
        f"[2:v]scale=800:800:force_original_aspect_ratio=increase,crop=800:800[fg]; "
        # 4. Layering: BG -> Waveform -> FG Art
        f"[bg][vwave]overlay=(W-w)/2:(H-h)/2[bg_wave]; "
        f"[bg_wave][fg]overlay=(W-w)/2:(H-h)/2, "
        f"fade=t=in:st=0:d=1, fade=t=out:st=28:d=2[vout]",
        '-map', '[vout]', '-map', '0:a', '-c:v', 'libx264', '-preset', 'fast', '-crf', '20', '-t', '30', output_name
    ]
    subprocess.run(ffmpeg_cmd)

print("Vertical Videos Ready!")
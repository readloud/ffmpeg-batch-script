import subprocess
import os
import glob
from tqdm import tqdm

# Settings
WIDTH, HEIGHT = 1080, 1920
BG_VIDEO = "bg_loop.mp4"
DEFAULT_IMAGE = "cover.jpg"

songs = glob.glob("*.mp3")

for audio_file in tqdm(songs, desc="Creating Pulsing Shorts"):
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + "_pulsing.mp4"
    
    image_to_use = DEFAULT_IMAGE # Fallback logic omitted for brevity

    ffmpeg_cmd = [
        'ffmpeg', '-y', '-loglevel', 'error',
        '-i', audio_file, 
        '-stream_loop', '-1', '-i', BG_VIDEO, 
        '-i', image_to_use,
        '-filter_complex', 
        # 1. Background
        f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=40:20[bg]; "
        # 2. Circular Waveform
        f"[0:a]showwaves=s={WIDTH}x{WIDTH}:mode=line:colors=#25d3d0:draw=full,format=rgba,"
        f"extractplanes=r+g+b+a,geometry=hypot(x-W/2\,y-H/2):0:0:0:0:0:0:0:0:0:0:0:0:0:0:0[vwave]; "
        # 3. THE BASS SHAKE LOGIC
        # We scale the image based on the audio volume (between 1.0 and 1.1 scale)
        f"[2:v]scale=800:800:force_original_aspect_ratio=increase,crop=800:800,"
        f"zoompan=z='min(zoom+0.0015*it,1.1)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fg]; "
        # 4. Final Layers
        f"[bg][vwave]overlay=(W-w)/2:(H-h)/2[bg_wave]; "
        f"[bg_wave][fg]overlay=(W-w)/2:(H-h)/2, "
        f"fade=t=in:st=0:d=1, fade=t=out:st=28:d=2[vout]",
        '-map', '[vout]', '-map', '0:a', '-c:v', 'libx264', '-preset', 'fast', '-crf', '20', '-t', '30', output_name
    ]
    subprocess.run(ffmpeg_cmd)

print("Pulsing Shorts Ready!")
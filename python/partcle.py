import subprocess
import os
import glob
from tqdm import tqdm

# Settings
BG_VIDEO = "bg_loop.mp4"
PARTICLE_FILE = "particles.mp4" # The new layer
DEFAULT_IMAGE = "cover.jpg"
LOGO_FILE = "logo.png"
WIDTH, HEIGHT = 1920, 1080

songs = glob.glob("*.mp3")

for audio_file in tqdm(songs, desc="Total Progress"):
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + ".mp4"
    
    # Logic to find image... (omitted for brevity)
    image_to_use = DEFAULT_IMAGE 

    ffmpeg_cmd = [
        'ffmpeg', '-y', '-loglevel', 'error',
        '-i', audio_file, 
        '-stream_loop', '-1', '-i', BG_VIDEO, 
        '-stream_loop', '-1', '-i', PARTICLE_FILE, # Input 2: Particles
        '-i', image_to_use, 
        '-i', LOGO_FILE,
        '-filter_complex', 
        # 1. Background + Blur
        f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=20:10,vignette=angle=0.5[bg]; "
        # 2. Add Particles using 'screen' blend (makes black transparent)
        f"[2:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT}[part]; "
        f"[bg][part]blend=all_mode='addition':all_opacity=0.5[bg_with_particles]; "
        # 3. Center Art
        f"[3:v]scale=-1:700[fg]; [bg_with_particles][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
        # 4. Waveform & Branding... (rest of the previous logic)
        f"[0:a]compand,showwaves=size={WIDTH}x250:colors=#ffffff:draw=full:mode=line[v_sharp]; "
        f"[combined][v_sharp]overlay=(W-w)/2:H-300[v_elements]; "
        f"[4:v]scale=180:-1[logo_scaled]; "
        f"[v_elements][logo_scaled]overlay=W-w-30:30[vout]",
        '-map', '[vout]', '-map', '0:a', '-c:v', 'libx264', '-preset', 'fast', '-crf', '20', '-shortest', output_name
    ]
    subprocess.run(ffmpeg_cmd)
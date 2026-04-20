import subprocess
import json
import os
import glob

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

# Resolution Settings
WIDTH = 1920
HEIGHT = 1080
DEFAULT_IMAGE = "cover.jpg"
LOGO_FILE = "logo.png"
FONT_SIZE = 40  # Increased for 1080p
SPEED = 150     # Increased speed to match larger width
IMG_EXTS = ['.jpg', '.jpeg', '.png', '.webp']

songs = glob.glob("*.mp3")

for audio_file in songs:
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + ".mp4"
    
    image_to_use = DEFAULT_IMAGE
    for ext in IMG_EXTS:
        potential_img = base_name + ext
        if os.path.exists(potential_img):
            image_to_use = potential_img
            break

    if not os.path.exists(image_to_use):
        continue

    print(f"--- Processing 1080p: {audio_file} ---")
    
    try:
        duration = get_duration(audio_file)
        fade_start = max(0, duration - 2)
        display_title = base_name.replace('_', ' ').upper()

        ffmpeg_cmd = [
            'ffmpeg', '-y', '-i', audio_file, '-i', image_to_use, '-i', LOGO_FILE,
            '-filter_complex', 
            # 1. Prepare Background (Blurry)
            f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=40:20[bg]; "
            # 2. Prepare Center Art (Square-ish)
            f"[1:v]scale=-1:800[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
            # 3. Prepare Neon Waveform
            f"[0:a]compand,showwaves=size={WIDTH}x300:colors=#25d3d0@0.8:draw=full:mode=line[v_glow]; "
            f"[v_glow]boxblur=10:5[v_blurred]; "
            f"[0:a]compand,showwaves=size={WIDTH}x300:colors=#ffffff:draw=full:mode=line[v_sharp]; "
            f"[v_blurred][v_sharp]overlay=format=auto[vwave]; "
            # 4. Final Compositing
            f"[combined][vwave]overlay=(W-w)/2:H-350[v_elements]; "
            f"[2:v]scale=200:-1[logo_scaled]; "
            f"[v_elements][logo_scaled]overlay=W-w-30:30, "
            f"drawtext=text='NOW PLAYING\: {display_title}':fontcolor=white:fontsize={FONT_SIZE}:y=h-80:x=w-mod(t*{SPEED}\,w+tw), "
            f"fade=t=in:st=0:d=2, fade=t=out:st={fade_start}:d=2[vout]; "
            f"[0:a]afade=t=in:st=0:d=2, afade=t=out:st={fade_start}:d=2[aout]",
            '-map', '[vout]', '-map', '[aout]', '-c:v', 'libx264', '-preset', 'fast', '-crf', '18', '-shortest', output_name
        ]

        subprocess.run(ffmpeg_cmd)
    except Exception as e:
        print(f"Error: {e}")

print("\n1080p HD Batch Processing Complete!")
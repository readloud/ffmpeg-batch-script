import subprocess
import json
import os
import glob

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

# Settings
DEFAULT_IMAGE = "cover.jpg"
FONT_SIZE = 20
SPEED = 80 

# Supported image extensions
IMG_EXTS = ['.jpg', '.jpeg', '.png', '.webp']

songs = glob.glob("*.mp3")

for audio_file in songs:
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + ".mp4"
    
    # Logic to find a matching image
    image_to_use = DEFAULT_IMAGE
    for ext in IMG_EXTS:
        potential_img = base_name + ext
        if os.path.exists(potential_img):
            image_to_use = potential_img
            break

    if not os.path.exists(image_to_use):
        print(f"Skipping {audio_file}: No image found (looked for {base_name} or {DEFAULT_IMAGE})")
        continue

    print(f"--- Processing: {audio_file} with {image_to_use} ---")
    
    try:
        duration = get_duration(audio_file)
        fade_start = max(0, duration - 2)
        display_title = base_name.replace('_', ' ').upper()

        ffmpeg_cmd = [
            'ffmpeg', '-y', '-i', audio_file, '-i', image_to_use,
            '-filter_complex', 
            f"[1:v]scale=854:480:force_original_aspect_ratio=increase,crop=854:480,boxblur=20:10[bg]; "
            f"[1:v]scale=-1:350[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
            f"[0:a]compand,showwaves=size=854x120:colors=#25d3d0@0.8:draw=full:mode=line[v_glow]; "
            f"[v_glow]boxblur=5:2[v_blurred]; "
            f"[0:a]compand,showwaves=size=854x120:colors=#ffffff:draw=full:mode=line[v_sharp]; "
            f"[v_blurred][v_sharp]overlay=format=auto[vwave]; "
            f"[combined][vwave]overlay=(W-w)/2:H-140, "
            f"drawtext=text='NOW PLAYING\: {display_title}':fontcolor=white:fontsize={FONT_SIZE}:y=h-40:x=w-mod(t*{SPEED}\,w+tw), "
            f"fade=t=in:st=0:d=2, fade=t=out:st={fade_start}:d=2[vout]; "
            f"[0:a]afade=t=in:st=0:d=2, afade=t=out:st={fade_start}:d=2[aout]",
            '-map', '[vout]', '-map', '[aout]', '-c:v', 'libx264', '-preset', 'fast', '-crf', '22', '-shortest', output_name
        ]

        subprocess.run(ffmpeg_cmd)
    except Exception as e:
        print(f"Error processing {audio_file}: {e}")

print("\nBatch processing complete!")
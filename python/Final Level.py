import subprocess
import json
import os
import glob

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

# Settings
BG_VIDEO = "bg_loop.mp4"
DEFAULT_IMAGE = "cover.jpg"
LOGO_FILE = "logo.png"
WIDTH, HEIGHT = 1920, 1080
FONT_SIZE, SPEED = 40, 150

songs = glob.glob("*.mp3")

for audio_file in songs:
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + ".mp4"
    thumb_name = base_name + "_thumb.jpg"
    
    image_to_use = DEFAULT_IMAGE
    for ext in ['.jpg', '.png']:
        if os.path.exists(base_name + ext):
            image_to_use = base_name + ext
            break

    if not os.path.exists(image_to_use):
        continue

    print(f"--- Rendering Video: {audio_file} ---")
    
    try:
        duration = get_duration(audio_file)
        fade_start = max(0, duration - 2)
        display_title = base_name.replace('_', ' ').upper()

        # 1. GENERATE THE VIDEO
        ffmpeg_cmd = [
            'ffmpeg', '-y', '-i', audio_file, '-i', BG_VIDEO, '-i', image_to_use, '-i', LOGO_FILE,
            '-filter_complex', 
            f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=20:10,vignette=angle=0.5[bg]; "
            f"[2:v]scale=-1:700[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
            f"[0:a]compand,showwaves=size={WIDTH}x250:colors=#25d3d0@0.7:draw=full:mode=line[v_glow]; "
            f"[v_glow]boxblur=12:6[v_blurred]; "
            f"[0:a]compand,showwaves=size={WIDTH}x250:colors=#ffffff:draw=full:mode=line[v_sharp]; "
            f"[v_blurred][v_sharp]overlay=format=auto[vwave]; "
            f"[combined][vwave]overlay=(W-w)/2:H-300[v_elements]; "
            f"[3:v]scale=180:-1[logo_scaled]; "
            f"[v_elements][logo_scaled]overlay=W-w-30:30, "
            f"drawtext=text='NOW PLAYING\: {display_title}':fontcolor=white:fontsize={FONT_SIZE}:y=h-80:x=w-mod(t*{SPEED}\,w+tw), "
            f"fade=t=in:st=0:d=2, fade=t=out:st={fade_start}:d=2[vout]; "
            f"[0:a]afade=t=in:st=0:d=2, afade=t=out:st={fade_start}:d=2[aout]",
            '-map', '[vout]', '-map', '[aout]', '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-shortest', output_name
        ]
        subprocess.run(ffmpeg_cmd)

        # 2. EXTRACT THE THUMBNAIL
        print(f"--- Extracting Thumbnail: {thumb_name} ---")
        thumb_cmd = [
            'ffmpeg', '-y', '-ss', '00:00:05', '-i', output_name, 
            '-frames:v', '1', '-q:v', '2', thumb_name
        ]
        subprocess.run(thumb_cmd)

    except Exception as e:
        print(f"Error: {e}")

print("\nProduction complete! Videos and Thumbnails are ready for upload.")
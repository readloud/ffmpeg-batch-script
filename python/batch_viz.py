import subprocess
import json
import os
import glob

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

# Settings
image_file = "cover.jpg" # Make sure this exists in the folder
font_size = 20
speed = 80 # Scrolling speed

# Find all MP3 files in the current directory
songs = glob.glob("*.mp3")

if not os.path.exists(image_file):
    print(f"Error: {image_file} not found! Please place a cover.jpg in the folder.")
    exit()

for audio_file in songs:
    # Create output name (e.g., "Song Name.mp3" -> "Song Name.mp4")
    output_name = os.path.splitext(audio_file)[0] + ".mp4"
    print(f"--- Processing: {audio_file} ---")
    
    try:
        duration = get_duration(audio_file)
        fade_start = max(0, duration - 2) # Ensures no negative start times for short clips
        
        # Clean song title for the overlay text
        display_title = os.path.splitext(audio_file)[0].replace('_', ' ').upper()

        ffmpeg_cmd = [
            'ffmpeg', '-y', '-i', audio_file, '-i', image_file,
            '-filter_complex', 
            f"[1:v]scale=854:480:force_original_aspect_ratio=increase,crop=854:480,boxblur=20:10[bg]; "
            f"[1:v]scale=-1:350[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
            f"[0:a]compand,showwaves=size=854x120:colors=#25d3d0@0.8:draw=full:mode=line[v_glow]; "
            f"[v_glow]boxblur=5:2[v_blurred]; "
            f"[0:a]compand,showwaves=size=854x120:colors=#ffffff:draw=full:mode=line[v_sharp]; "
            f"[v_blurred][v_sharp]overlay=format=auto[vwave]; "
            f"[combined][vwave]overlay=(W-w)/2:H-140, "
            f"drawtext=text='NOW PLAYING\: {display_title}':fontcolor=white:fontsize={font_size}:y=h-40:x=w-mod(t*{speed}\,w+tw), "
            f"fade=t=in:st=0:d=2, fade=t=out:st={fade_start}:d=2[vout]; "
            f"[0:a]afade=t=in:st=0:d=2, afade=t=out:st={fade_start}:d=2[aout]",
            '-map', '[vout]', '-map', '[aout]', '-c:v', 'libx264', '-preset', 'fast', '-crf', '22', '-shortest', output_name
        ]

        subprocess.run(ffmpeg_cmd)
        print(f"Successfully created: {output_name}\n")
        
    except Exception as e:
        print(f"Failed to process {audio_file}: {e}")

print("All done! Check your folder for the new videos.")
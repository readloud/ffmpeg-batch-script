import subprocess
import os
import glob
from tqdm import tqdm

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

# --- CONFIGURATION ---
DEFAULT_IMAGE = "cover.jpg"
BG_VIDEO = "bg_loop.mp4"
LOGO_FILE = "logo.png"

print("🎨 WELCOME TO THE MASTER VISUALIZER 🚀")
print("1. Horizontal (16:9) - Best for YouTube")
print("2. Vertical (9:16) - Best for TikTok/Shorts/Reels")
choice = input("Select your format (1 or 2): ")

if choice == "1":
    WIDTH, HEIGHT = 1920, 1080
    ART_SIZE = 800
    WAVE_H = 250
    TEXT_Y = "h-80"
    TIME_LIMIT = "" # Full song
    SUFFIX = "_YT"
else:
    WIDTH, HEIGHT = 1080, 1920
    ART_SIZE = 750
    WAVE_H = 350
    TEXT_Y = "h-400" # Higher up to avoid TikTok buttons
    TIME_LIMIT = "-t 60" # Limit to 60s for Shorts
    SUFFIX = "_Shorts"

songs = glob.glob("*.mp3")

for audio_file in tqdm(songs, desc="Processing Queue"):
    base_name = os.path.splitext(audio_file)[0]
    output_name = base_name + SUFFIX + ".mp4"
    
    # Image Matching
    image_to_use = DEFAULT_IMAGE
    for ext in ['.jpg', '.png']:
        if os.path.exists(base_name + ext):
            image_to_use = base_name + ext
            break

    try:
        duration = get_duration(audio_file)
        fade_start = max(0, duration - 2) if choice == "1" else 58
        display_title = base_name.replace('_', ' ').upper()

        # Dynamic Filter Complex
        if choice == "1":
            # Horizontal: Linear Waveform at bottom
            filters = (
                f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=20:10,vignette=angle=0.5[bg]; "
                f"[2:v]scale=-1:{ART_SIZE}[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
                f"[0:a]showwaves=size={WIDTH}x{WAVE_H}:colors=#25d3d0:mode=line[vwave]; "
                f"[combined][vwave]overlay=(W-w)/2:H-{WAVE_H+50}[v_elements]; "
            )
        else:
            # Vertical: Circular Pulse + Shake
            filters = (
                f"[1:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},boxblur=40:20,vignette=angle=0.6[bg]; "
                f"[0:a]showwaves=s={WIDTH}x{WIDTH}:mode=line:colors=#25d3d0:draw=full,format=rgba,"
                f"extractplanes=r+g+b+a,geometry=hypot(x-W/2\,y-H/2):0:0:0:0:0:0:0:0:0:0:0:0:0:0:0[vwave]; "
                f"[2:v]scale={ART_SIZE}:{ART_SIZE}:force_original_aspect_ratio=increase,crop={ART_SIZE}:{ART_SIZE},"
                f"zoompan=z='min(zoom+0.0015*it,1.1)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fg]; "
                f"[bg][vwave]overlay=(W-w)/2:(H-h)/2[bg_wave]; "
                f"[bg_wave][fg]overlay=(W-w)/2:(H-h)/2[v_elements]; "
            )

        # Common Overlays (Logo + Text)
        filters += (
            f"[3:v]scale=180:-1[logo_scaled]; "
            f"[v_elements][logo_scaled]overlay=W-w-30:30, "
            f"drawtext=text='{display_title}':fontcolor=white:fontsize=40:y={TEXT_Y}:x=w-mod(t*120\,w+tw), "
            f"fade=t=in:st=0:d=1, fade=t=out:st={fade_start}:d=2[vout]"
        )

        ffmpeg_cmd = [
            'ffmpeg', '-y', '-loglevel', 'error',
            '-i', audio_file, '-i', BG_VIDEO, '-i', image_to_use, '-i', LOGO_FILE,
            '-filter_complex', filters,
            '-map', '[vout]', '-map', '0:a', '-c:v', 'libx264', '-preset', 'fast', '-crf', '20'
        ]
        
        if TIME_LIMIT:
            ffmpeg_cmd.extend(TIME_LIMIT.split())
        
        ffmpeg_cmd.append(output_name)
        subprocess.run(ffmpeg_cmd)

    except Exception as e:
        print(f"Error on {audio_file}: {e}")

print("✅ DONE! Check your folder for the exports.")
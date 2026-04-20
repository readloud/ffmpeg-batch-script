import subprocess
import os
from gtts import gTTS

def create_code_scene(explanation, code_snippet, filename):
    # 1. Generate Voice for the explanation
    tts = gTTS(text=explanation, lang='en')
    audio_file = "temp_audio.mp3"
    tts.save(audio_file)
    
    # 2. Get duration
    audio_dur_cmd = f'ffprobe -i {audio_file} -show_entries format=duration -v quiet -of csv="p=0"'
    duration = float(subprocess.check_output(audio_dur_cmd, shell=True)) + 1.5

    # 3. Create Video: Top half is explanation, Bottom half is the Code Box
    # We use 'drawtext' with line breaks (\n)
    ffmpeg_cmd = [
        'ffmpeg', '-y', '-f', 'lavfi', '-i', f'color=c=0x1e1e1e:s=1920x1080:d={duration}',
        '-i', audio_file,
        '-vf', (
            f"drawtext=text='{explanation}':fontcolor=0x25d3d0:fontsize=40:x=100:y=150:fontfile='Courier',"
            f"drawtext=text='{code_snippet}':fontcolor=white:fontsize=32:x=100:y=400:fontfile='Courier':"
            f"max_chars='t*30'" # Fast typing for code
        ),
        '-c:v', 'libx264', '-c:a', 'aac', '-shortest', filename
    ]
    
    subprocess.run(ffmpeg_cmd)
    os.remove(audio_file)

# Example Usage
explanation = "This line uses glob to find all MP3 files in your current directory."
code = "songs = glob.glob('*.mp3')\\nfor song in songs:\\n    print(song)"

create_code_scene(explanation, code, "code_tutorial_1.mp4")
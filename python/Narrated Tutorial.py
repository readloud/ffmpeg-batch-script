import subprocess
import os
from gtts import gTTS
from tqdm import tqdm

def generate_narrated_tutorial(steps):
    if not os.path.exists("final_tutorial"):
        os.makedirs("final_tutorial")

    print("🎙️ Generating Narrated Tutorial Scenes...")

    for i, text in enumerate(tqdm(steps)):
        audio_file = f"final_tutorial/audio_{i+1}.mp3"
        video_file = f"final_tutorial/scene_{i+1}.mp4"
        
        # 1. Generate AI Voice
        tts = gTTS(text=text, lang='en')
        tts.save(audio_file)
        
        # 2. Get Audio Duration
        # We need the video to be exactly as long as the voiceover
        audio_dur_cmd = f'ffprobe -i {audio_file} -show_entries format=duration -v quiet -of csv="p=0"'
        duration = float(subprocess.check_output(audio_dur_cmd, shell=True)) + 1.0 # Add a 1s buffer

        # 3. Create the Typing Video + Audio Sync
        ffmpeg_cmd = [
            'ffmpeg', '-y', '-f', 'lavfi', 
            '-i', f'color=c=0x1e1e1e:s=1920x1080:d={duration}', # Background
            '-i', audio_file, # The Voiceover
            '-vf', (
                f"drawtext=text='{text}':fontcolor=white:fontsize=48:"
                f"x=(W-tw)/2:y=(H-th)/2:fontfile='Courier':" # Centered text
                f"max_chars='t*20'" # Typing speed
            ),
            '-c:v', 'libx264', '-c:a', 'aac', '-pix_fmt', 'yuv420p', video_file
        ]
        
        subprocess.run(ffmpeg_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        os.remove(audio_file) # Clean up temp audio file

# --- YOUR TUTORIAL SCRIPT ---
my_steps = [
    "Welcome to the Music Factory. First, place your music and covers in the folder.",
    "Make sure the image names match your audio names perfectly.",
    "Now, run the script and choose your video format.",
    "The engine will now render your videos and extract thumbnails automatically.",
    "Your content is ready for upload. Thanks for watching!"
]

generate_narrated_tutorial(my_steps)
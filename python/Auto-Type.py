# pip install gTTS
from gtts import gTTS

for i, text in enumerate(my_steps):
    tts = gTTS(text=text, lang='en')
    tts.save(f"tutorial_scenes/audio_{i+1}.mp3")
    
def create_typing_clip(text, output_file, duration=5):
    # This expression counts characters based on time (t). 
    # 't*15' means it types 15 characters per second.
    typing_expression = f"text='{{SCREENTEXT}}':x=100:y=100:fontsize=32:fontcolor=white:text='{text}':enable='lte(n,t*15)'"
    
    # We use a black background for the "terminal" look
    cmd = [
        'ffmpeg', '-y', '-f', 'lavfi', '-i', 'color=c=black:s=1920x1080:d=' + str(duration),
        '-vf', f"drawtext=fontfile=courier.ttf:text='{text}':x=50:y=50:fontsize=30:fontcolor=green:text_source=text:enable='between(t,0,{duration})':box=1:boxcolor=black@0.5",
        '-c:v', 'libx264', output_file
    ]
    # Note: For a true 'typing' effect, the 'drawtext' filter 
    # needs to use a substring logic like this:
    
    # Refined command for the "Typewriter" effect:
    cmd = [
        'ffmpeg', '-y', '-f', 'lavfi', '-i', f'color=c=0x1e1e1e:s=1280x720:d={duration}',
        '-vf', f"drawtext=text='{text}':fontcolor=white:fontsize=24:x=40:y=40:text='':"
               f"text='{text}':max_chars='t*20'", 
        '-c:v', 'libx264', output_file
    ]
    subprocess.run(cmd)
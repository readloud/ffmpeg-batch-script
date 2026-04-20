import subprocess
import json

def get_duration(filename):
    cmd = f'ffprobe -v quiet -print_format json -show_format "{filename}"'
    result = subprocess.check_output(cmd, shell=True)
    return float(json.loads(result)['format']['duration'])

audio_file = "input.mp3"
image_file = "cover.jpg"
duration = get_duration(audio_file)
fade_start = duration - 2

ffmpeg_cmd = [
    'ffmpeg', '-i', audio_file, '-i', image_file,
    '-filter_complex', 
    f"[1:v]scale=854:480:force_original_aspect_ratio=increase,crop=854:480,boxblur=20:10[bg]; "
    f"[1:v]scale=-1:350[fg]; [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; "
    f"[0:a]compand,showwaves=size=854x120:colors=#25d3d0@0.8:draw=full:mode=line[v_glow]; "
    f"[v_glow]boxblur=5:2[v_blurred]; "
    f"[0:a]compand,showwaves=size=854x120:colors=#ffffff:draw=full:mode=line[v_sharp]; "
    f"[v_blurred][v_sharp]overlay=format=auto[vwave]; "
    f"[combined][vwave]overlay=(W-w)/2:H-140, "
    f"drawtext=text='SONG TITLE':fontcolor=white:fontsize=20:y=h-40:x=w-mod(t*80\,w+tw), "
    f"fade=t=in:st=0:d=2, fade=t=out:st={fade_start}:d=2[vout]; "
    f"[0:a]afade=t=in:st=0:d=2, afade=t=out:st={fade_start}:d=2[aout]",
    '-map', '[vout]', '-map', '[aout]', '-c:v', 'libx264', '-preset', 'fast', '-crf', '22', '-shortest', 'output.mp4'
]

subprocess.run(ffmpeg_cmd)
import os
import subprocess
import json
from glob import glob

def get_video_duration(video_path):
    """Get duration of video in seconds"""
    cmd = [
        'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
        '-of', 'json', video_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    data = json.loads(result.stdout)
    return float(data['format']['duration'])

def merge_with_transitions(folder, output_file, fade_duration=1):
    """Merge all MP4 files with smooth transitions"""
    
    # Get all mp4 files
    video_files = sorted(glob(os.path.join(folder, "*.mp4")))
    
    if len(video_files) < 2:
        print("Need at least 2 video files")
        return False
    
    print(f"Found {len(video_files)} video files")
    
    # Build filter complex
    filter_parts = []
    
    # Track cumulative time for offset calculation
    cumulative_time = 0
    durations = []
    
    # Get durations of all videos
    for video in video_files:
        duration = get_video_duration(video)
        durations.append(duration)
        print(f"{os.path.basename(video)}: {duration:.2f}s")
    
    # Build input string
    inputs = []
    for i, video in enumerate(video_files):
        inputs.extend(['-i', video])
    
    # Create filter for each segment with transitions
    filter_complex = ""
    
    # First video
    filter_complex += f"[0:v]trim=0:{durations[0]},setpts=PTS-STARTPTS[v0];"
    filter_complex += f"[0:a]atrim=0:{durations[0]},asetpts=PTS-STARTPTS[a0];"
    
    # Subsequent videos with transitions
    for i in range(1, len(video_files)):
        prev_end = sum(durations[:i])
        offset = prev_end - fade_duration
        
        # Add video with transition
        filter_complex += f"[{i}:v]trim=0:{durations[i]},setpts=PTS-STARTPTS+{prev_end}/TB[v{i}];"
        filter_complex += f"[{i}:a]atrim=0:{durations[i]},asetpts=PTS-STARTPTS+{prev_end}/TB[a{i}];"
        
        # Crossfade between previous and current
        filter_complex += f"[v{i-1}][v{i}]xfade=transition=fade:duration={fade_duration}:offset={offset}[v{i}_f];"
        filter_complex += f"[a{i-1}][a{i}]acrossfade=d={fade_duration}[a{i}_f];"
    
    # Map final output
    last_idx = len(video_files) - 1
    map_video = f"[v{last_idx}_f]"
    map_audio = f"[a{last_idx}_f]"
    
    # Execute ffmpeg
    cmd = [
        'ffmpeg', '-y',
        *inputs,
        '-filter_complex', filter_complex,
        '-map', map_video,
        '-map', map_audio,
        '-pix_fmt', 'yuv420p',
        '-c:v', 'libx264',
        '-c:a', 'aac',
        output_file
    ]
    
    print("Starting merge process...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"Success! Output saved to: {output_file}")
        return True
    else:
        print("Error during merge:")
        print(result.stderr)
        return False

if __name__ == "__main__":
    folder = "tutorials"
    output = "final_tutorial/master_tutorial_with_fades.mp4"
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output), exist_ok=True)
    
    merge_with_transitions(folder, output, fade_duration=1)
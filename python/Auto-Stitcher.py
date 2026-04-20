import os
import subprocess

def merge_tutorial_scenes(folder="tutorials", output_filename="full_tutorial.mp4"):
    # 1. Find all scene files and sort them numerically
    scenes = [f for f in os.listdir(folder) if f.startswith("scene_") and f.endswith(".mp4")]
    
    # Custom sort to ensure scene_10 comes after scene_2
    scenes.sort(key=lambda x: int(x.split('_')[1].split('.')[0]))

    if not scenes:
        print("❌ No scenes found in the folder!")
        return

    # 2. Create the temporary concat list
    list_path = os.path.join(folder, "concat_list.txt")
    with open(list_path, "w") as f:
        for scene in scenes:
            # FFmpeg needs the full path or relative path formatted correctly
            f.write(f"file '{scene}'\n")

    print(f"🔗 Stitching {len(scenes)} scenes into {output_filename}...")

    # 3. Run the FFmpeg concat command
    # -safe 0 allows for flexible file paths
    # -c copy is lightning fast because it doesn't re-encode
    cmd = [
        'ffmpeg', '-y', '-f', 'concat', '-safe', '0',
        '-i', list_path, '-c', 'copy', output_filename
    ]

    subprocess.run(cmd)
    
    # Cleanup the temporary list
    os.remove(list_path)
    print(f"✨ DONE! Your master tutorial is ready: {output_filename}")

# Run it
merge_tutorial_scenes()
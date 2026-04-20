import os
import time
import subprocess
import shutil
from gtts import gTTS

# Baca file input.txt
print("Membaca file input.txt...")
with open('input.txt', 'r', encoding='utf-8') as f:
    lines = [line.strip() for line in f if line.strip()]

print(f"Total kalimat: {len(lines)}")

# Folder output
os.makedirs("output_mp3", exist_ok=True)
os.makedirs("output_videos", exist_ok=True)

# Cek FFmpeg
print("Cek FFmpeg...")
try:
    subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
    print("✅ FFmpeg siap digunakan")
except:
    print("❌ FFmpeg tidak ditemukan! Silakan install FFmpeg")
    exit(1)

# ========== STEP 1: Generate MP3 dengan gTTS ==========
print("\n=== STEP 1: Generate MP3 ===")
audio_files = []
for idx, text in enumerate(lines):
    mp3_path = f"output_mp3/sentence_{idx+1:03d}.mp3"
    
    try:
        print(f"  [{idx+1}/{len(lines)}] Generating: {text[:40]}...")
        tts = gTTS(text=text, lang='id', slow=False)
        tts.save(mp3_path)
        audio_files.append(mp3_path)
        time.sleep(0.3)
    except Exception as e:
        print(f"  ❌ Error: {e}")

print(f"✅ Berhasil generate {len(audio_files)} MP3")

# ========== STEP 2: Buat video per kalimat (TANPA JEDA) ==========
print("\n=== STEP 2: Membuat Video (Tanpa Jeda) ===")
video_files = []

for idx, audio_path in enumerate(audio_files):
    print(f"  [{idx+1}/{len(audio_files)}] Processing video...")
    
    text = lines[idx]
    output_video = f"output_videos/video_{idx+1:03d}.mp4"
    
    # Escape teks untuk FFmpeg
    safe_text = text.replace("'", "'\\''").replace(":", "\\:").replace("%", "%%")
    
    # Buat video dengan teks di tengah (langsung sesuai durasi audio, tanpa jeda)
    cmd = f'ffmpeg -f lavfi -i color=c=black:s=1280x720:r=24 -i "{audio_path}" -vf "drawtext=text=\'{safe_text}\':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:fontfile=/Windows/Fonts/arial.ttf" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "{output_video}" -y -loglevel error'
    
    try:
        subprocess.run(cmd, shell=True, check=True, timeout=60)
        video_files.append(output_video)
        print(f"    ✅ Video {idx+1} selesai")
    except subprocess.TimeoutExpired:
        print(f"    ⚠️ Timeout, lanjut...")
    except Exception as e:
        print(f"    ❌ Error: {e}")

# ========== STEP 3: Gabungkan semua video (TANPA JEDA) ==========
print("\n=== STEP 3: Menggabungkan Semua Video ===")

if len(video_files) > 0:
    # Buat file list untuk concat
    with open("videos_list.txt", "w", encoding="utf-8") as f:
        for video in video_files:
            f.write(f"file '{video.replace('\\', '/')}'\n")
    
    # Gabungkan dengan FFmpeg
    cmd_concat = f'ffmpeg -f concat -safe 0 -i videos_list.txt -c copy output_all.mp4 -y'
    try:
        subprocess.run(cmd_concat, shell=True, check=True)
        print("✅ Video final: output_all.mp4 (Tanpa jeda antar kalimat)")
    except Exception as e:
        print(f"❌ Error menggabungkan: {e}")
        
        # Metode alternatif jika concat gagal
        print("Mencoba metode alternatif...")
        filter_complex = ""
        for i in range(len(video_files)):
            filter_complex += f"[{i}:v]"
        filter_complex += f"concat=n={len(video_files)}:v=1:a=0[outv]"
        
        inputs = ""
        for video in video_files:
            inputs += f'-i "{video}" '
        
        cmd_alt = f'ffmpeg {inputs}-filter_complex "{filter_complex}" -map "[outv]" output_all.mp4 -y'
        subprocess.run(cmd_alt, shell=True)
else:
    print("❌ Tidak ada video yang berhasil dibuat")

# ========== STEP 4: Cleanup ==========
print("\n=== STEP 4: Cleanup ===")
# Hapus file temporary
if os.path.exists("videos_list.txt"):
    os.remove("videos_list.txt")

print("\n" + "="*50)
print("✅ SEMUA PROSES SELESAI!")
print("="*50)
print(f"📁 MP3 files: output_mp3/ ({len(audio_files)} file)")
print(f"📁 Video per kalimat: output_videos/ ({len(video_files)} file)")
print(f"🎬 Video lengkap: output_all.mp4")
print("⚡ Tanpa jeda 5 detik antar kalimat")
print("="*50)
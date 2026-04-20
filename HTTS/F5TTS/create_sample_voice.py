# create_sample_voice.py
from gtts import gTTS
import subprocess
import os

os.makedirs("ref_audio", exist_ok=True)

# Sample teks untuk pria
sample_text_pria = "Halo, saya adalah suara pria untuk demonstrasi voice cloning dengan F5-TTS. Semoga berhasil."
sample_text_wanita = "Halo, saya adalah suara wanita untuk demonstrasi voice cloning dengan F5-TTS. Semoga berhasil."

# Generate dengan gTTS (sebagai sample sementara)
for gender, text in [("pria", sample_text_pria), ("wanita", sample_text_wanita)]:
    tts = gTTS(text=text, lang='id', slow=False)
    tts.save(f"ref_audio/{gender}.mp3")
    
    # Konversi ke WAV format yang benar
    cmd = f'ffmpeg -i "ref_audio/{gender}.mp3" -ac 1 -ar 24000 -sample_fmt s16 "ref_audio/{gender}.wav" -y'
    subprocess.run(cmd, shell=True, check=True)
    
    print(f"✅ Sample voice created: ref_audio/{gender}.wav")

print("\n⚠️ CATATAN: Sample ini dari gTTS (suara komputer), bukan suara manusia asli.")
print("Untuk hasil terbaik, ganti dengan rekaman suara manusia asli.")
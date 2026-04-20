import os
import subprocess

os.makedirs("ref_audio", exist_ok=True)

# Cara 1: Download sample voice pria Indonesia dari internet
# Atau gunakan rekaman sendiri

# Cara 2: Konversi file audio yang sudah ada ke format yang benar
def convert_to_ref_format(input_file, output_file, duration=8):
    """
    Konversi audio ke format yang dibutuhkan F5-TTS
    - Mono, 24kHz, WAV, durasi 5-10 detik
    """
    cmd = f'ffmpeg -i "{input_file}" -ac 1 -ar 24000 -t {duration} -sample_fmt s16 "{output_file}" -y'
    subprocess.run(cmd, shell=True, check=True)
    print(f"✅ Converted: {output_file}")

# Contoh penggunaan:
# convert_to_ref_format("rekaman_pria.wav", "ref_audio/pria.wav", 8)
# convert_to_ref_format("rekaman_wanita.wav", "ref_audio/wanita.wav", 8)

print("\n📌 INSTRUKSI:")
print("1. Siapkan file audio suara target (rekaman sendiri atau download)")
print("2. Letakkan di folder 'ref_audio/' dengan nama 'pria.wav' dan 'wanita.wav'")
print("3. Atau gunakan script di atas untuk konversi")
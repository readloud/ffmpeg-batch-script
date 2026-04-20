import os
import time
import subprocess
from gtts import gTTS  # fallback jika Azure gagal

# Coba import Azure
try:
    import azure.cognitiveservices.speech as speechsdk
    AZURE_AVAILABLE = True
except:
    AZURE_AVAILABLE = False
    print("Azure TTS tidak tersedia, akan menggunakan fallback")

# Konfigurasi Azure (GANTI DENGAN KEY ASLI ANDA)
AZURE_KEY = "YOUR_AZURE_KEY"
AZURE_REGION = "southeastasia"

# Baca file
with open('input.txt', 'r', encoding='utf-8') as f:
    lines = [line.strip() for line in f if line.strip()]

os.makedirs("output_mp3", exist_ok=True)

# Generate suara pria
for idx, text in enumerate(lines):
    output_file = f"output_mp3/sentence_{idx+1:03d}.mp3"
    
    if AZURE_AVAILABLE and AZURE_KEY != "YOUR_AZURE_KEY":
        # Gunakan Azure TTS (Suara Pria)
        speech_config = speechsdk.SpeechConfig(subscription=AZURE_KEY, region=AZURE_REGION)
        speech_config.speech_synthesis_voice_name = "id-ID-ArdiNeural"
        audio_config = speechsdk.audio.AudioOutputConfig(filename=output_file)
        synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)
        synthesizer.speak_text_async(text).get()
        print(f"✅ Azure Pria: {text[:40]}")
    else:
        # Fallback ke gTTS (tapi suara wanita/netral)
        tts = gTTS(text=text, lang='id', slow=False)
        tts.save(output_file)
        print(f"⚠️ gTTS (Netral): {text[:40]}")
    
    time.sleep(0.5)

print("Selesai!")
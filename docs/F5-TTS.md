Step 1: 
```PowerShell
pip install f5-tts
```
```Python
from TTS.api import TTS
# Model akan otomatis terunduh saat pertama kali dijalankan
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to("cuda")
2. Instalasi F5-TTS
F5-TTS adalah model Flow Matching terbaru yang sangat halus dan manusiawi. Karena tidak menggunakan Git, kita menginstalnya langsung dari paket resmi y```ang tersedia di PyPI.

```PowerShell
pip install scipy numpy torch torchvision torchaudio
```
```
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
(Gunakan cu121 jika Anda menggunakan seri RTX 3000/4000).
```
```PowerShell
pip install flash-attn --no-build-isolation
```
(Catatan: flash-attn mempercepat proses namun membutuhkan build tools Windows. Jika error, Anda bisa melewati langkah ini).

```PowerShell
[System.Environment]::SetEnvironmentVariable("HF_TOKEN", "hf_xxxxxxxxxxxxxxxxxxxxx", "User")
pip install huggingface_hub
```

Step 2: Process Voice with FFmpeg (Enhancement)
Raw TTS output can sound "processed." Use FFmpeg to enhance it. 
Normalize and Clean the Audio:
```bash
ffmpeg -i output.wav -af "loudnorm,aresample=44100" enhanced_voice.wav
```
loudnorm: Normalizes audio loudness to standard (-16 LUFS).
aresample=44100: Ensures sample rate compatibility. 

Step 3: Combine Voice with Background Music (Cover)
Use FFmpeg to mix the voiceover with a background track, making the voice clear.
```bash
ffmpeg -i enhanced_voice.wav -i background_music.mp3 \
-filter_complex "[1:a]volume=0.2[music];[0:a][music]amix=inputs=2:duration=first[audio]" \
-map "[audio]" -c:a libmp3lame -q:a 2 final_cover.mp3
volume=0.2: Dips background music to 20%.
amix=inputs=2:duration=first: Mixes the two audios and stops when the voice finishes. 
```

## Top Open-Source TTS Engines for FFmpeg
 *F5-TTS/E2-F5: Top choice for voice cloning; high-quality, realistic output.*
 *Kokoro: Lightweight 82-million parameter model, very high quality, great for local use.*
 *Coqui XTTS-v2: Excellent for zero-shot voice cloning across languages.*

## Alternatives
If you prefer not to use local AI models, you can use high-quality API-based generators (like ElevenLabs) and use FFmpeg to combine them:
```bash
ffmpeg -i elevenlabs_speech.mp3 -i backing_track.mp3 -filter_complex "[0:a]volume=1.5[v];[1:a]volume=0.3[b];[v][b]amix=inputs=2" final_cover.mp3
```

## Pro-Tips for Realism
Punctuation Matters: Add commas and periods in your text input to force the AI to make natural pauses.
Lower Stability: In many TTS GUIs, reducing stability makes the voice more emotional/expressive but less consistent.
Refine Text: For voice covers, ensure the text phonetically matches the singer's timing. 

***F5-TTS/E2-TTS:***
 *Voice Cloning & Quality: Both models offer state-of-the-art voice cloning, allowing for high-quality, natural-sounding audio generation without training.*
 *F5-TTS Characteristics: Implements Flow Matching with ConvNeXt V2, providing faster training and better robustness.*
 *E2-TTS Characteristics: Known as "Embarrassingly Easy" TTS, this model is designed for simplicity and can sometimes offer better coherence on longer samples.*
 *Usage: Popularly used via web UI demos (like Hugging Face) or run locally with a GPU.*

 ***+60Features:***
 *Capable of generating speech with specific emotional tones and supports multi-lingual output.*
 *F5-TTS is generally considered superior in speed and robustness, making it the preferred choice for most applications.*
 *E2-TTS is a strong, slightly different alternative focusing on simple, direct reproduction.*
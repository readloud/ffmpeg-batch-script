import sys
import re
import os
import subprocess
import torch
import torchaudio
import tempfile

def check_ffmpeg():
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
        return True
    except:
        return False

def convert_audio_format(input_file, output_file, target_sr=24000):
    """Konversi audio ke format yang benar untuk F5-TTS"""
    cmd = f'ffmpeg -i "{input_file}" -ac 1 -ar {target_sr} -sample_fmt s16 "{output_file}" -y -loglevel error'
    subprocess.run(cmd, shell=True, check=True)
    return output_file

def clean_text(text):
    """Membersihkan tag dari teks"""
    text = re.sub(r'\[.*?\]', '', text)
    return text.strip()

def generate_f5tts(text, output_wav, gender):
    """Generate TTS dengan F5-TTS"""
    text_to_speak = clean_text(text)
    if not text_to_speak:
        return False
    
    # Path reference audio
    ref_audio = f"ref_audio/{gender}.wav"
    
    # Cek apakah reference audio ada
    if not os.path.exists(ref_audio):
        print(f"[ERROR] Reference audio tidak ditemukan: {ref_audio}")
        print("[INFO] Buat file reference audio terlebih dahulu!")
        return False
    
    try:
        # Import F5-TTS
        from f5_tts.api import F5TTS
        
        # Setup device
        device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"[INFO] Using device: {device}")
        
        # Load model
        print("[INFO] Loading F5-TTS model...")
        model = F5TTS(device=device)
        
        # Generate speech
        print(f"[INFO] Generating speech for: {text_to_speak[:50]}...")
        
        # Parameter inference untuk F5-TTS
        wav, sr, _ = model.infer(
            ref_file=ref_audio,
            ref_text="",  # Biarkan kosong untuk auto-transcription
            gen_text=text_to_speak,
            remove_silence=True,
            speed=1.0
        )
        
        # Simpan audio
        if isinstance(wav, torch.Tensor):
            wav = wav.cpu()
        
        torchaudio.save(output_wav, wav.unsqueeze(0) if wav.dim() == 1 else wav, sr)
        print(f"[OK] Audio saved: {output_wav}")
        return True
        
    except ImportError:
        print("[ERROR] F5-TTS tidak terinstall!")
        print("Install dengan: pip install f5-tts")
        return False
    except Exception as e:
        print(f"[ERROR] F5-TTS gagal: {e}")
        import traceback
        traceback.print_exc()
        return False

def generate_fallback(text, output_wav):
    """Fallback ke gTTS jika F5-TTS gagal"""
    try:
        from gtts import gTTS
        
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as tmp:
            tts = gTTS(text=text, lang='id', slow=False)
            tts.save(tmp.name)
            tmp_path = tmp.name
        
        # Convert ke WAV
        cmd = f'ffmpeg -i "{tmp_path}" -acodec pcm_s16le -ar 24000 "{output_wav}" -y -loglevel error'
        subprocess.run(cmd, shell=True, check=True)
        os.unlink(tmp_path)
        return True
    except Exception as e:
        print(f"[ERROR] Fallback juga gagal: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 3:
        text = sys.argv[1]
        output_wav = sys.argv[2]
        gender = sys.argv[3]
        
        print(f"[TTS] Processing: {text[:50]}...")
        print(f"[TTS] Gender: {gender}")
        
        # Coba F5-TTS dulu
        success = generate_f5tts(text, output_wav, gender)
        
        # Fallback ke gTTS jika gagal
        if not success:
            print("[INFO] Falling back to gTTS...")
            success = generate_fallback(text, output_wav)
        
        sys.exit(0 if success else 1)
    else:
        print("Usage: python tts_single.py <text> <output_wav> <gender>")
        sys.exit(1)
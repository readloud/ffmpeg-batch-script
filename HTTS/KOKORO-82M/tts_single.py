import sys
import re
import os
from kokoro import KPipeline
import soundfile as sf
from huggingface_hub import login

# 1. Cek dan Aktifkan HF_TOKEN
hf_token = os.getenv("HF_TOKEN")
if hf_token:
    # Melakukan login secara programmatik agar library mengenali token
    login(token=hf_token)
    print("HF_TOKEN terdeteksi dan berhasil diaktifkan.")
else:
    print("Peringatan: HF_TOKEN tidak ditemukan di environment variable.")
    print("Silakan set HF_TOKEN terlebih dahulu")

# 2. Inisialisasi Pipeline Kokoro
try:
    pipeline = KPipeline(lang_code='a')  # 'a' untuk English (Kokoro support English)
    print("Pipeline Kokoro berhasil diinisialisasi")
except Exception as e:
    print(f"Error inisialisasi pipeline: {e}")
    sys.exit(1)

def clean_text(text):
    # Menghapus tag menggunakan regex
    return re.sub(r'\[.*?\]', '', text).strip()

def validate_text(text):
    """Validate and sanitize text before processing"""
    # Remove any problematic characters
    text = re.sub(r'[^\w\s.,!?\'"-]', '', text)
    # Ensure text is not empty
    return text.strip()

def generate_kokoro(text, output_wav, gender):
    text_to_speak = clean_text(text)
    text_to_speak = validate_text(text_to_speak)
    
    if not text_to_speak:
        print("Text kosong setelah cleaning")
        return False
    
    # Add a fallback text if needed
    if len(text_to_speak) < 2:
        print("Text terlalu pendek, menggunakan default text")
        text_to_speak = "Hello, this is a test message."

    # Pilihan suara Kokoro (Michael = Pria, Sarah = Wanita)
    if gender == 'pria':
        voice_preset = 'am_michael'
    else:
        voice_preset = 'af_sarah'
    
    try:
        print(f"Memproses: {text_to_speak[:100]}...")
        print(f"Menggunakan voice: {voice_preset}")
        print(f"Panjang teks: {len(text_to_speak)} karakter")
        
        # Try to generate audio with better error handling
        generator = pipeline(
            text_to_speak, 
            voice=voice_preset, 
            speed=1.0, 
            split_pattern=r'\n+'
        )
        
        # Mengambil hasil audio
        audio_generated = False
        audio_data = None
        
        for i, (gs, ps, audio) in enumerate(generator):
            if audio is not None and len(audio) > 0:
                audio_data = audio
                audio_generated = True
                print(f"Audio chunk {i+1} generated successfully")
                break
            else:
                print(f"Audio chunk {i+1} is empty or None")
        
        if not audio_generated or audio_data is None:
            print("Tidak ada audio yang dihasilkan")
            return False
        
        # Save audio to file
        sf.write(output_wav, audio_data, 24000)
        print(f"Audio saved: {output_wav}")
        return True
        
    except TypeError as e:
        if "phonemes" in str(e):
            print("Error: Text contains characters that cannot be processed for phoneme generation")
            print("Trying alternative approach...")
            
            # Try to process text in smaller chunks
            try:
                words = text_to_speak.split()
                chunks = []
                current_chunk = []
                current_length = 0
                
                for word in words:
                    current_chunk.append(word)
                    current_length += len(word) + 1
                    if current_length > 100:  # Smaller chunks
                        chunks.append(' '.join(current_chunk))
                        current_chunk = []
                        current_length = 0
                
                if current_chunk:
                    chunks.append(' '.join(current_chunk))
                
                # Generate audio for each chunk
                audio_chunks = []
                for idx, chunk in enumerate(chunks):
                    print(f"Processing chunk {idx+1}/{len(chunks)}")
                    generator = pipeline(chunk, voice=voice_preset, speed=1.0)
                    for gs, ps, audio in generator:
                        if audio is not None:
                            audio_chunks.append(audio)
                            break
                
                if audio_chunks:
                    # Concatenate all audio chunks
                    import numpy as np
                    final_audio = np.concatenate(audio_chunks)
                    sf.write(output_wav, final_audio, 24000)
                    print(f"Audio saved with chunking: {output_wav}")
                    return True
                else:
                    print("No audio chunks generated")
                    return False
                    
            except Exception as chunk_error:
                print(f"Chunking approach also failed: {chunk_error}")
                return False
        else:
            print(f"Error pada Kokoro: {e}")
            import traceback
            traceback.print_exc()
            return False
            
    except Exception as e:
        print(f"Error pada Kokoro: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    if len(sys.argv) > 3:
        # arg 1: teks, arg 2: nama_file, arg 3: gender
        text = sys.argv[1]
        output_file = sys.argv[2]
        gender = sys.argv[3]
        
        # Validate gender parameter
        if gender not in ['pria', 'wanita']:
            print("Gender harus 'pria' atau 'wanita'")
            sys.exit(1)
        
        # Ensure output directory exists
        output_dir = os.path.dirname(output_file)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir, exist_ok=True)
        
        success = generate_kokoro(text, output_file, gender)
        sys.exit(0 if success else 1)
    else:
        print("Usage: python tts_single.py <text> <output_wav> <gender>")
        print("Gender: 'pria' or 'wanita'")
        sys.exit(1)
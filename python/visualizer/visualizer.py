#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
READLOUD VISUALIZER - Python Version
Audio/Video processing tool with waveform visualization
"""

import os
import sys
import subprocess
import random
import shutil
import tempfile
import re
from pathlib import Path
from datetime import datetime
import glob

# ==================== KONFIGURASI AWAL ====================
# Direktori
USERPROFILE = os.environ.get('USERPROFILE', os.path.expanduser('~'))
MUSIC_DIR = os.path.join(USERPROFILE, 'Music')
VIDEOS_DIR = os.path.join(USERPROFILE, 'Videos')
PICTURES_DIR = os.path.join(USERPROFILE, 'Pictures')
DOWNLOADS_DIR = os.path.join(USERPROFILE, 'Downloads')
CAPTURES = os.path.join(VIDEOS_DIR, 'Captures')
OUTPUT_DIR = os.path.join(VIDEOS_DIR, 'Exports', 'YT_Video')
OUTPUT_AUDIO = os.path.join(VIDEOS_DIR, 'Exports', 'YT_Audio')
TEMP_DIR = os.path.join(tempfile.gettempdir(), 'VISUALIZER')
ASSETS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assets')

# Default Settings
LOGO_TEXT = "READLOUD"
track_filters = "This video has been uploaded to READLOUD youtube channel and is for educational purposes only. All rights reserved to the music, images, and clips used belong to their respective owners."
LOGO_MODE = "GLOW"
cc = "(White soft shadow)"
BG_MODE = "STATIC"
SAFE_BG = "Default"
C_COLOR = "white@0.9"
FONT_LOGO = "Buda.ttf"
FONT_TITLE = "Bulgia.otf"
FONT_SUB = "Super Wonder.ttf"

# Format default
FORMAT = "YT"
WIDTH = "1920"
HEIGHT = "1080"
FONT_SIZE_TITLE = "35"
FONT_SIZE_SUB = "30"
SCROLL_X = "x=w-mod(100*t\,w+tw+50):y=h-text_h-120"

input_bg = os.path.join(ASSETS_DIR, 'default.png')
bgm = os.path.join(ASSETS_DIR, 'bgm.mp3')

# ==================== FUNGSI BANTUAN ====================
def create_directories():
    """Buat direktori yang diperlukan"""
    for d in [OUTPUT_DIR, OUTPUT_AUDIO, TEMP_DIR, ASSETS_DIR]:
        Path(d).mkdir(parents=True, exist_ok=True)

def clear_screen():
    """Bersihkan layar terminal"""
    os.system('cls' if os.name == 'nt' else 'clear')

def check_ffmpeg():
    """Periksa apakah ffmpeg tersedia"""
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("[ERROR] ffmpeg tidak ditemukan. Pastikan ffmpeg terinstal dan dalam PATH.")
        return False

def check_ytdlp():
    """Periksa apakah yt-dlp tersedia"""
    try:
        subprocess.run(['yt-dlp', '--version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("[ERROR] yt-dlp tidak ditemukan. Pastikan yt-dlp terinstal.")
        return False

def sanitize_filename(name):
    """Bersihkan nama file dari karakter ilegal"""
    # Hapus underscore dan karakter ilegal
    name = name.replace('_', ' ')
    name = re.sub(r'[<>:"/\\|?*]', '', name)
    # Hapus kata-kata umum
    for word in ['Official', 'Remastered', 'Lyric', 'Lirik', 'Music', 'Video']:
        name = name.replace(word, '')
    name = re.sub(r'[\[\]\(\)]', '', name)
    name = re.sub(r'\s+', ' ', name).strip()
    return name if name else "Unknown_Title"

def get_audio_duration(audio_file):
    """Dapatkan durasi file audio dalam detik"""
    try:
        result = subprocess.run(
            ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
             '-of', 'default=noprint_wrappers=1:nokey=1', audio_file],
            capture_output=True, text=True, check=True
        )
        duration = float(result.stdout.strip())
        return duration - 2  # overlap
    except Exception:
        return 10  # default

def show_videos(target_dir=None):
    """Tampilkan daftar video"""
    if target_dir is None:
        target_dir = VIDEOS_DIR
    
    videos = []
    extensions = ['*.mp4', '*.mkv', '*.avi', '*.mov', '*.wmv', '*.3gp']
    
    for ext in extensions:
        videos.extend(Path(target_dir).rglob(ext))
    
    if not videos:
        print("Tidak ada file video ditemukan.")
        return []
    
    for i, video in enumerate(videos, 1):
        print(f"[{i}] {video.name}")
    
    return videos

def show_music(target_dir=None):
    """Tampilkan daftar file musik"""
    if target_dir is None:
        target_dir = MUSIC_DIR
    
    music_files = []
    extensions = ['*.mp3', '*.opus', '*.wav']
    
    for ext in extensions:
        music_files.extend(Path(target_dir).rglob(ext))
    
    if not music_files:
        print("Tidak ada file audio ditemukan.")
        return []
    
    for i, music in enumerate(music_files, 1):
        print(f"[{i}] {music.name}")
    
    return music_files

def show_pictures(target_dir=None):
    """Tampilkan daftar gambar"""
    if target_dir is None:
        target_dir = PICTURES_DIR
    
    images = []
    extensions = ['*.jpg', '*.jpeg', '*.png', '*.jfif', '*.webp']
    
    for ext in extensions:
        images.extend(Path(target_dir).rglob(ext))
    
    if not images:
        print("Tidak ada file gambar ditemukan.")
        return []
    
    for i, img in enumerate(images, 1):
        print(f"[{i}] {img.name}")
    
    return images

def show_subtitles():
    """Tampilkan daftar subtitle"""
    subtitle_dir = Path(VIDEOS_DIR) / 'Exports' / 'Subtitle'
    subtitle_dir.mkdir(parents=True, exist_ok=True)
    
    subtitles = []
    extensions = ['*.srt', '*.vtt', '*.ass', '*.ssa']
    
    for ext in extensions:
        subtitles.extend(Path('.').glob(ext))
        subtitles.extend(subtitle_dir.glob(ext))
    
    if not subtitles:
        print("Tidak ada file subtitle ditemukan.")
        return []
    
    for i, sub in enumerate(subtitles, 1):
        print(f"[{i}] {sub.name}")
    
    return subtitles

def select_folder(base_dir, folder_type="Folder"):
    """Pilih folder dari direktori"""
    dirs = [d for d in Path(base_dir).rglob('*') if d.is_dir()]
    
    if not dirs:
        print(f"Tidak ada subfolder di {base_dir}")
        return base_dir
    
    print(f"\n=== SELECT {folder_type.upper()} ===")
    for i, d in enumerate(dirs, 1):
        print(f"[{i}] {d.name}")
    
    choice = input(f"\nPilih folder (Enter untuk root): ").strip()
    
    if choice and choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(dirs):
            return str(dirs[idx])
    
    return base_dir

def select_platform():
    """Pilih format output"""
    clear_screen()
    print("\n" + "=" * 52)
    print("  1. YouTube (1920x1080)")
    print("  2. Reels/Shorts (1080x1920)")
    print("  3. Exit")
    print("=" * 52)
    
    choice = input("Select Format [1-3]: ").strip()
    
    if choice == "3":
        return None, None, None, None, None, None
    elif choice == "1":
        return "YT", "1920", "1080", "35", "30", "x=w-mod(100*t\,w+tw+50):y=h-text_h-120"
    elif choice == "2":
        return "Shorts", "1080", "1920", "35", "35", "x=w-mod(100*t\,w+tw+50):y=h-text_h-30"
    else:
        return select_platform()

def get_logo_filter():
    """Dapatkan filter logo untuk ffmpeg"""
    font_path = FONT_LOGO.replace('\\', '/')
    if LOGO_MODE == "RAINBOW":
        return (f"drawtext=fontfile='{font_path}':text='{LOGO_TEXT}':fontcolor=white:fontsize=45:x=W-tw-60:y=60,"
                f"drawtext=fontfile='Playball.ttf':text='ffmpeg_ART':fontcolor=white@0.3:fontsize=30:x=W-tw-60:y=100:"
                f"shadowcolor=black@0.5:shadowx=2:shadowy=2,hue=h=t*100")
    else:
        return (f"drawtext=fontfile='{font_path}':text='{LOGO_TEXT}':fontcolor=white:fontsize=45:x=W-tw-60:y=60,"
                f"drawtext=fontfile='{font_path}':text='{LOGO_TEXT}':fontcolor=white@0.3:fontsize=43:x=W-tw-58:y=58,"
                f"drawtext=fontfile='Playball.ttf':text='ffmpeg_ART':fontcolor=white@0.3:fontsize=30:x=W-tw-60:y=100")

def create_waveform(input_mp3, input_bg, outfile, overlap=10, safe_title="Audio", track_text=""):
    """Buat video waveform dari audio"""
    logo_filter = get_logo_filter()
    
    if not track_text:
        track_text = track_filters
    
    if FORMAT == "YT":
        cmd = [
            'ffmpeg', '-y', '-hide_banner',
            '-stream_loop', '-1', '-i', input_bg,
            '-i', input_mp3,
            '-filter_complex',
            f'[0:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,crop={WIDTH}:{HEIGHT},'
            f'fade=t=in:st=0:d=2,fade=t=out:st={overlap}:d=2[bg_faded];'
            f'[bg_faded]{logo_filter}[bg_txt];'
            f'[bg_txt]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];'
            f'[bg_box]drawtext=fontfile=\'{FONT_TITLE}\':text=\'{safe_title}\':fontcolor=white@0.9:'
            f'fontsize={FONT_SIZE_TITLE}:x=40:y=h-160:shadowcolor=black@0.4:shadowx=4:shadowy=4,'
            f'drawtext=text=\'{track_text}\':fontfile=\'{FONT_SUB}\':fontsize={FONT_SIZE_SUB}:'
            f'fontcolor=white@0.5:x=(w-text_w)/2:y=h-150:{SCROLL_X}[v_final];'
            f'[1:a]afade=t=in:st=0:d=2,afade=t=out:st={overlap}:d=2[a_final]',
            '-map', '[v_final]', '-map', '[a_final]',
            '-c:v', 'libx264', '-preset', 'fast', '-tune', 'stillimage',
            '-c:a', 'aac', '-b:a', '192k', '-shortest', outfile
        ]
    else:
        # Format Shorts/TikTok
        cmd = [
            'ffmpeg', '-y', '-hide_banner',
            '-stream_loop', '-1', '-i', input_bg,
            '-i', input_mp3,
            '-filter_complex',
            f'[0:v]fps=30,scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,'
            f'crop={WIDTH}:{HEIGHT},fade=t=in:st=0:d=2,fade=t=out:st={overlap}:d=2[bg_faded];'
            f'[bg_faded]{logo_filter}[v_no_text];'
            f'[v_no_text]drawtext=text=\'{track_text}\':fontfile=\'{FONT_SUB}\':fontsize={FONT_SIZE_SUB}:'
            f'fontcolor=white@0.9:x=(w-text_w)/2:y=h-150:{SCROLL_X};'
            f'[1:a]afade=t=in:st=0:d=2,afade=t=out:st={overlap}:d=2[outv]',
            '-map', '[outv]', '-map', '1:a',
            '-c:v', 'libx264', '-preset', 'fast', '-pix_fmt', 'yuv420p',
            '-r', '30', '-g', '60', '-c:a', 'aac', '-b:a', '192k', '-shortest', outfile
        ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0

# ==================== MENU UTAMA ====================
def main_menu():
    """Menu utama aplikasi"""
    global LOGO_TEXT, LOGO_MODE, BG_MODE, SAFE_BG, input_bg, track_filters
    
    while True:
        clear_screen()
        print("\n" + "=" * 52)
        print("  VISUALIZER PRO DEFAULT SYSTEM")
        print("=" * 52)
        print(" [1] Download Audio MP3")
        print(" [2] Download + Convert")
        print(" [3] Bulk Download")
        print(" [4] Convert Existing MP3")
        print(" [5] Audio Video Tools")
        print(" [6] Screen Cam-Recorder")
        print(" [7] Transcribe Subtitle")
        print(" [8] TTSpeech Synthesizer")
        print(" [9] Images Slideshow")
        print(" [A] Archived")
        print(" [X] Settings")
        print("-" * 52)
        print(f" Current Mode: [ {SAFE_BG} {BG_MODE} {LOGO_MODE} ]")
        print("-" * 52)
        
        choice = input("Select Menu [1-9][A][X][Q]uit: ").strip().lower()
        
        if choice == 'q':
            exit_program()
            break
        elif choice == 'x':
            logo_settings()
        elif choice == 'a':
            archived()
        elif choice == '1':
            download_audio()
        elif choice == '2':
            download_waveform()
        elif choice == '3':
            bulk_download()
        elif choice == '4':
            convert_waveform()
        elif choice == '5':
            av_tools()
        elif choice == '6':
            screen_recorder()
        elif choice == '7':
            transcribe_subtitle()
        elif choice == '8':
            tts_synthesizer()
        elif choice == '9':
            image_slideshow()

def logo_settings():
    """Pengaturan logo dan background"""
    global LOGO_TEXT, LOGO_MODE, BG_MODE, SAFE_BG, input_bg, track_filters
    
    while True:
        clear_screen()
        print("\n" + "=" * 52)
        print("  LOGO TEXT SETTINGS")
        print("=" * 52)
        print(f" [1] Change Logo Text (Current: {LOGO_TEXT})")
        print(" [2] Change Background LOOP")
        print(" [3] Change Background STATIC")
        print(" [4] Set Mode: RAINBOW")
        print(" [5] Set Mode: GLOW")
        print(" [6] Change Scroll Text")
        print("-" * 52)
        print(f" Mode: {BG_MODE} | {LOGO_MODE} - {cc}")
        print("-" * 52)
        
        choice = input("Choice Menu [1-6][M]enu: ").strip().lower()
        
        if choice == '1':
            LOGO_TEXT = input("Enter New Logo Text: ").strip()
        elif choice == '6':
            track_filters = input("Enter New Scroll Text: ").strip()
        elif choice == '2':
            BG_MODE = "LOOP"
            videos = show_videos()
            if videos:
                try:
                bg_num = int(input("Select number: ")) - 1
                    if 0 <= bg_num < len(videos):
                        input_bg = str(videos[bg_num])
                        SAFE_BG = videos[bg_num].stem
                except ValueError:
                    pass
        elif choice == '3':
            BG_MODE = "STATIC"
            images = show_pictures()
            if images:
                try:
                    bg_num = int(input("Select number: ")) - 1
                    if 0 <= bg_num < len(images):
                        input_bg = str(images[bg_num])
                        SAFE_BG = images[bg_num].stem
                except ValueError:
                    pass
        elif choice == '4':
            LOGO_MODE = "RAINBOW"
            cc = "(Colors cycle over time)"
        elif choice == '5':
            LOGO_MODE = "GLOW"
        elif choice == 'm':
            break

def download_audio():
    """Download audio MP3 dari YouTube"""
    clear_screen()
    print("\n" + "=" * 52)
    print("  DOWNLOAD AUDIO MP3")
    print("=" * 52)
    print(" [0] Back to Main Menu")
    
    url = input("\nEnter YouTube URL: ").strip()
    
    if url == "0" or not url:
        return
    
    if not check_ytdlp():
        input("Press Enter to continue...")
        return
    
    print(f"\nDownloading audio to: {MUSIC_DIR}\n")
    
    cmd = [
        'yt-dlp', '-x', '--audio-format', 'mp3',
        '--audio-quality', '320k',
        '-o', f'{MUSIC_DIR}/%(title)s.%(ext)s', url
    ]
    
    result = subprocess.run(cmd)
    
    if result.returncode == 0:
        print("[SUCCESS] Download complete!")
        print(f"File saved to: {MUSIC_DIR}")
    else:
        print("[ERROR] Download failed!")
    
    input("Press Enter to continue...")

def download_waveform():
    """Download dan konversi ke waveform video"""
    clear_screen()
    print("\n" + "=" * 52)
    print("  DOWNLOAD + CONVERT WITH WAVEFORM")
    print("=" * 52)
    print(" [0] Back to Main Menu")
    
    url = input("\nEnter YouTube URL: ").strip()
    
    if url == "0" or not url:
        return
    
    if not check_ytdlp() or not check_ffmpeg():
        input("Press Enter to continue...")
        return
    
    # Get title
    print("[1/3] Fetching Metadata from YouTube...")
    try:
        result = subprocess.run(
            ['yt-dlp', '--print', 'title', url],
            capture_output=True, text=True, check=True
        )
        safe_title = result.stdout.strip()
    except:
        safe_title = "Unknown_Title"
    
    safe_title = sanitize_filename(safe_title)
    
    # Select format
    result = select_platform()
    if result[0] is None:
        return
    
    global FORMAT, WIDTH, HEIGHT, FONT_SIZE_TITLE, FONT_SIZE_SUB, SCROLL_X
    FORMAT, WIDTH, HEIGHT, FONT_SIZE_TITLE, FONT_SIZE_SUB, SCROLL_X = result
    
    # Download audio
    print("\nDownloading audio...")
    temp_audio = os.path.join(TEMP_DIR, f'temp_waveform_{random.randint(1000,9999)}.mp3')
    
    cmd = [
        'yt-dlp', '-x', '--audio-format', 'mp3',
        '--audio-quality', '320k', '-o', temp_audio, url
    ]
    
    subprocess.run(cmd, capture_output=True)
    
    if not os.path.exists(temp_audio):
        print("[ERROR] Downloaded file not found!")
        input("Press Enter to continue...")
        return
    
    print("[SUCCESS] Audio downloaded successfully!")
    
    # Create output filename
    outfile = os.path.join(OUTPUT_DIR, f'{safe_title}_{FORMAT}_{random.randint(1000,9999)}.mp4')
    
    # Get duration and create video
    overlap = get_audio_duration(temp_audio)
    
    success = create_waveform(temp_audio, input_bg, outfile, overlap, safe_title, f"'{safe_title}'")
    
    if success:
        print("[SUCCESS] Video complete!")
        print(f"File saved to: {OUTPUT_DIR}")
    else:
        print("[ERROR] Failed to create video!")
    
    # Cleanup
    if os.path.exists(temp_audio):
        os.remove(temp_audio)
    
    input("Press Enter to continue...")

def convert_waveform():
    """Konversi MP3 existing ke waveform video"""
    clear_screen()
    
    target_dir = select_folder(MUSIC_DIR, "Music")
    music_files = show_music(target_dir)
    
    if not music_files:
        input("Press Enter to continue...")
        return
    
    try:
        m_sel = int(input("Select MP3 Number: ")) - 1
        if 0 <= m_sel < len(music_files):
            selected_mp3 = str(music_files[m_sel])
            safe_title = music_files[m_sel].stem
        else:
            return
    except ValueError:
        return
    
    safe_title = sanitize_filename(safe_title)
    
    # Get duration
    overlap = get_audio_duration(selected_mp3)
    
    # Select format
    result = select_platform()
    if result[0] is None:
        return
    
    global FORMAT, WIDTH, HEIGHT, FONT_SIZE_TITLE, FONT_SIZE_SUB, SCROLL_X
    FORMAT, WIDTH, HEIGHT, FONT_SIZE_TITLE, FONT_SIZE_SUB, SCROLL_X = result
    
    outfile = os.path.join(OUTPUT_DIR, f'{safe_title}_{FORMAT}_{random.randint(1000,9999)}.mp4')
    
    success = create_waveform(selected_mp3, input_bg, outfile, overlap, safe_title, f"'{safe_title}'")
    
    if success:
        print("[SUCCESS] Video created successfully!")
    else:
        print("[ERROR] Failed to create video!")
    
    input("Press Enter to continue...")

def bulk_download():
    """Bulk download dari file txt"""
    clear_screen()
    print("\n" + "=" * 52)
    print("  BULK DOWNLOAD FROM FILE")
    print("=" * 52)
    print(f"Searching for TXT files in: {os.getcwd()}\n")
    
    txt_files = [f for f in Path('.').glob('*.txt')]
    
    if not txt_files:
        print("[ERROR] No .txt files found!")
        input("Press Enter to continue...")
        return
    
    for i, f in enumerate(txt_files, 1):
        print(f"[{i}] {f.name}")
    
    print("\n[0] Back to Main Menu")
    choice = input("Select file number: ").strip()
    
    if choice == "0" or not choice:
        return
    
    try:
        idx = int(choice) - 1
        if 0 <= idx < len(txt_files):
            selected_file = txt_files[idx]
        else:
            return
    except ValueError:
        return
    
    clear_screen()
    print("\n" + "=" * 52)
    print(f"  FILE: {selected_file.name}")
    print("=" * 52)
    print(" [1] Download MP3 Only (320kbps)")
    print(" [2] Download + Waveform (MP4)")
    print(" [3] Download Original Video (Best Quality MP4)")
    print("-" * 52)
    
    bulk_type = input("Select Format [1-3][0]Cancel: ").strip()
    
    if bulk_type == "0" or not bulk_type:
        return
    
    proses_type = {
        "1": "audio",
        "2": "waveform",
        "3": "video_asli"
    }.get(bulk_type)
    
    if not proses_type:
        print("Invalid choice!")
        input("Press Enter to continue...")
        return
    
    print("\nProcessing bulk download...")
    print("=" * 52)
    
    with open(selected_file, 'r') as f:
        urls = [line.strip() for line in f if line.strip()]
    
    success_count = 0
    failed_count = 0
    
    for i, url in enumerate(urls, 1):
        # Get title
        try:
            result = subprocess.run(
                ['yt-dlp', '--get-filename', '--restrict-filenames', '-o', '%(title)s', url],
                capture_output=True, text=True, check=True
            )
            safe_title = result.stdout.strip()
        except:
            safe_title = f"Unknown_{i}"
        
        safe_title = sanitize_filename(safe_title)
        print(f"[{i}] {safe_title}")
        
        if proses_type == "audio":
            cmd = [
                'yt-dlp', '-x', '--audio-format', 'mp3',
                '--audio-quality', '320k',
                '-o', f'{MUSIC_DIR}/{safe_title}.%(ext)s', url
            ]
            result = subprocess.run(cmd, capture_output=True)
            
        elif proses_type == "waveform":
            temp_audio = os.path.join(TEMP_DIR, f'tmp_{random.randint(1000,9999)}.mp3')
            cmd = [
                'yt-dlp', '-x', '--audio-format', 'mp3',
                '--audio-quality', '320k', '-o', temp_audio, url
            ]
            subprocess.run(cmd, capture_output=True)
            
            if os.path.exists(temp_audio):
                overlap = get_audio_duration(temp_audio)
                output_file = os.path.join(OUTPUT_DIR, f'{safe_title}_{FORMAT}.mp4')
                success = create_waveform(temp_audio, input_bg, output_file, overlap, safe_title, f"'{safe_title}'")
                os.remove(temp_audio)
                if success:
                    success_count += 1
                else:
                    failed_count += 1
                continue
            else:
                failed_count += 1
                continue
            
        elif proses_type == "video_asli":
            cmd = [
                'yt-dlp', '-f', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
                '--restrict-filenames', '-o', f'{OUTPUT_DIR}/%(title)s.%(ext)s', url
            ]
            result = subprocess.run(cmd, capture_output=True)
        
        if proses_type != "waveform":
            if result.returncode == 0:
                success_count += 1
                print(f"    [OK] Success.")
            else:
                failed_count += 1
                print(f"    [FAILED] An error occurred.")
    
    print("\n" + "=" * 52)
    print(f"  Successful: {success_count} | Failed: {failed_count}")
    print("=" * 52)
    
    # Clear file
    open(selected_file, 'w').close()
    
    input("Press Enter to continue...")

def av_tools():
    """Audio Video Tools menu"""
    while True:
        clear_screen()
        print("\n" + "=" * 52)
        print(f"  AUDIO VIDEO TOOLS [{LOGO_MODE}]")
        print("=" * 52)
        print(" [1] Replace Audio   [8] Add Logo")
        print(" [2] Mixing Audio    [9] Add Watermark")
        print(" [3] Extract Audio   [10] Add Logo & Watermark")
        print(" [4] Merge Audio     [11] Picture in picture")
        print(" [5] Merge Video     [12] Side by side")
        print(" [6] Mute Video      [13] Video Trim")
        print(" [7] Remove Track    [14] Video Scale")
        print("=" * 52)
        
        choice = input("Select [1-14][0]Cancel: ").strip()
        
        if choice == "0":
            break
        
        mix_mode = {
            "1": "replace", "2": "mix", "3": "split", "4": "merge_au",
            "5": "merge_av", "6": "muted", "7": "remove", "8": "logo",
            "9": "watermark", "10": "logo_wm", "11": "p2p", "12": "mirror",
            "13": "trim", "14": "scale"
        }.get(choice)
        
        if not mix_mode:
            print("Invalid choice!")
            input("Press Enter to continue...")
            continue
        
        if mix_mode == "replace":
            videos = show_videos()
            if not videos:
                input("Press Enter to continue...")
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            music_files = show_music()
            if not music_files:
                continue
            try:
                m_sel = int(input("Select MP3: ")) - 1
                selected_mp3 = str(music_files[m_sel])
            except:
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'replace_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = [
                'ffmpeg', '-i', selected_video, '-i', selected_mp3,
                '-c:v', 'copy', '-c:a', 'aac', '-map', '0:v:0', '-map', '1:a:0',
                '-shortest', '-y', outfile
            ]
            subprocess.run(cmd)
            print("✅ Replace Audio done!")
            
        elif mix_mode == "mix":
            videos = show_videos()
            if not videos:
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            music_files = show_music()
            if not music_files:
                continue
            try:
                m_sel = int(input("Select MP3: ")) - 1
                selected_mp3 = str(music_files[m_sel])
            except:
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'mix_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = [
                'ffmpeg', '-i', selected_video, '-i', selected_mp3,
                '-filter_complex', '[0:a][1:a]amix=inputs=2:duration=first',
                '-c:v', 'copy', '-c:a', 'aac', '-y', outfile
            ]
            subprocess.run(cmd)
            print("✅ Mixing AV done!")
            
        elif mix_mode == "split":
            videos = show_videos()
            if not videos:
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            outfile = os.path.join(OUTPUT_AUDIO, f'split_{filename}_{random.randint(1000,9999)}.mp3')
            cmd = [
                'ffmpeg', '-i', selected_video, '-vn',
                '-acodec', 'libmp3lame', '-q:a', '2', '-y', outfile
            ]
            subprocess.run(cmd)
            print("✅ Split AV done!")
            
        elif mix_mode == "muted":
            videos = show_videos()
            if not videos:
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'muted_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = ['ffmpeg', '-i', selected_video, '-an', '-c:v', 'copy', '-y', outfile]
            subprocess.run(cmd)
            print("✅ Remove Audio done!")
            
        elif mix_mode == "trim":
            videos = show_videos()
            if not videos:
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            v_str = input("Start from [hh:mm:ss] (Default: 00:00:00): ").strip()
            if not v_str:
                v_str = "00:00:00"
            
            v_end = input("End to [hh:mm:ss]: ").strip()
            if not v_end:
                print("❌ End time is required")
                input("Press Enter to continue...")
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'trim_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = ['ffmpeg', '-ss', v_str, '-to', v_end, '-i', selected_video, '-c', 'copy', '-y', outfile]
            subprocess.run(cmd)
            print("✅ Trim video done!")
            
        elif mix_mode == "scale":
            videos = show_videos()
            if not videos:
                continue
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'scale_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = [
                'ffmpeg', '-i', selected_video,
                '-vf', 'crop=ih*9/16:ih,scale=1080:1920,unsharp=5:5:1.0:5:5:0.0',
                '-c:v', 'libx264', '-crf', '18', '-preset', 'fast', '-c:a', 'copy', '-y', outfile
            ]
            subprocess.run(cmd)
            print("✅ Scaling to [1080x1920] done!")
        
        input("Press Enter to continue...")

def screen_recorder():
    """Screen and camera recorder"""
    while True:
        clear_screen()
        print("\n" + "=" * 58)
        print("  S T R E A M   L I B R A R Y")
        print("=" * 58)
        print(" [1] CAMCORDER")
        print(" [2] SCREEN CAPTURE")
        print(" [3] DUAL MODE")
        print(" [4] DEVICE TEST")
        print("=" * 58)
        
        choice = input("SYSTEM_INPUT [C]ANCEL: ").strip().lower()
        
        if choice == 'c':
            break
        elif choice == '1':
            rec_cam()
        elif choice == '2':
            rec_screen()
        elif choice == '3':
            dual_mode()
        elif choice == '4':
            dev_test()

def rec_cam():
    """Record from camera"""
    print("\n[SELECT VIDEO DEVICES]")
    # Get video devices
    result = subprocess.run(
        ['ffmpeg', '-list_devices', 'true', '-f', 'dshow', '-i', 'dummy'],
        capture_output=True, text=True
    )
    
    video_devices = []
    for line in result.stderr.split('\n'):
        if '(video)' in line:
            device = line.split(']')[1].strip().replace('(video)', '').strip('"')
            video_devices.append(device)
    
    if not video_devices:
        print("[!] No video devices found.")
        input("Press Enter to continue...")
        return
    
    for i, dev in enumerate(video_devices, 1):
        print(f"[{i}] {dev}")
    
    try:
        v_sel = int(input("Select Video Device: ")) - 1
        v_name = video_devices[v_sel]
    except:
        return
    
    print("\n[SELECT AUDIO DEVICES]")
    audio_devices = []
    for line in result.stderr.split('\n'):
        if '(audio)' in line:
            device = line.split(']')[1].strip().replace('(audio)', '').strip('"')
            audio_devices.append(device)
    
    if audio_devices:
        for i, dev in enumerate(audio_devices, 1):
            print(f"[{i}] {dev}")
        try:
            a_sel = int(input("Select Audio Device: ")) - 1
            a_name = audio_devices[a_sel]
        except:
            a_name = ""
    else:
        a_name = ""
    
    # Get resolution
    print("\n" + "=" * 44)
    print("      SELECT VIDEO RESOLUTION")
    print("=" * 44)
    print(" [1] 480p  (640x480)")
    print(" [2] 720p  (1280x720)")
    print(" [3] 1080p (1920x1080)")
    print("=" * 44)
    
    res_choice = input("Select Resolution [1-3]: ").strip()
    res_map = {"1": "640x480", "2": "1280x720", "3": "1920x1080"}
    resolution = res_map.get(res_choice, "1280x720")
    
    # Get FPS
    print("\n" + "=" * 44)
    print("      SELECT FRAME RATE (FPS)")
    print("=" * 44)
    print(" [1] 15 FPS")
    print(" [2] 30 FPS - Standard")
    print(" [3] 60 FPS - High")
    print("=" * 44)
    
    fps_choice = input("Select FPS [1-3]: ").strip()
    fps_map = {"1": "15", "2": "30", "3": "60"}
    fps = fps_map.get(fps_choice, "30")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    outfile = os.path.join(CAPTURES, f'Camera_{timestamp}.mkv')
    
    Path(CAPTURES).mkdir(parents=True, exist_ok=True)
    
    print("[!] START RECORDING...")
    
    if a_name:
        cmd = [
            'ffmpeg', '-f', 'dshow',
            '-i', f'video="{v_name}":audio="{a_name}"',
            '-video_size', resolution, '-framerate', fps,
            '-vcodec', 'libx264', '-preset', 'ultrafast',
            '-crf', '28', '-pix_fmt', 'yuv420p', outfile
        ]
    else:
        cmd = [
            'ffmpeg', '-f', 'dshow',
            '-i', f'video="{v_name}"',
            '-video_size', resolution, '-framerate', fps,
            '-vcodec', 'libx264', '-preset', 'ultrafast',
            '-crf', '28', '-pix_fmt', 'yuv420p', outfile
        ]
    
    process = subprocess.Popen(cmd)
    
    print("\n" + "=" * 58)
    print("             R E C O R D I N G   A C T I V E")
    print("=" * 58)
    print(f"  Status    : Running...")
    print(f"  Camera    : {v_name}")
    print(f"  Audio     : {a_name if a_name else 'None'}")
    print(f"  Specs     : {resolution} @ {fps} FPS")
    print(f"  Output    : {CAPTURES}")
    print("\n  PRESS ANY KEY TO STOP AND SAVE")
    print("=" * 58)
    
    input()
    process.terminate()
    
    print("[!] Recording stopped.")
    input("Press Enter to continue...")

def rec_screen():
    """Screen capture with various modes"""
    clear_screen()
    print("\n" + "=" * 52)
    print("  CHOOSE MODE")
    print("=" * 52)
    print(" [1] Select BGM")
    print(" [2] Voice Mode")
    print(" [3] Silent Mode")
    print("=" * 52)
    
    mode = input("CHOOSE MODE [C]ancel: ").strip().lower()
    
    if mode == 'c':
        return
    
    fps = "30"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    outfile = os.path.join(CAPTURES, f'Capture_{timestamp}.mkv')
    Path(CAPTURES).mkdir(parents=True, exist_ok=True)
    
    if mode == '1':  # BGM Mode
        music_files = show_music()
        if not music_files:
            return
        try:
            m_sel = int(input("Select MP3: ")) - 1
            bgm_file = str(music_files[m_sel])
        except:
            return
        
        cmd = [
            'ffmpeg', '-f', 'gdigrab', '-framerate', fps, '-i', 'desktop',
            '-i', bgm_file, '-c:v', 'libx264', '-preset', 'ultrafast',
            '-c:a', 'aac', '-map', '0:v', '-map', '1:a',
            '-crf', '28', '-pix_fmt', 'yuv420p', '-shortest', outfile
        ]
        
    elif mode == '2':  # Voice Mode
        cmd = [
            'ffmpeg', '-f', 'gdigrab', '-framerate', fps, '-i', 'desktop',
            '-f', 'dshow', '-i', 'audio="Microphone (Synaptics SmartAudio HD)"',
            '-c:v', 'libx264', '-preset', 'ultrafast', '-pix_fmt', 'yuv420p',
            '-c:a', 'aac', outfile
        ]
    else:  # Silent Mode
        cmd = [
            'ffmpeg', '-f', 'gdigrab', '-framerate', fps, '-i', 'desktop',
            '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '28',
            '-pix_fmt', 'yuv420p', outfile
        ]
    
    print("[!] START CAPTURING...")
    process = subprocess.Popen(cmd)
    
    print("\n" + "=" * 58)
    print("             R E C O R D I N G   A C T I V E")
    print("=" * 58)
    print("  PRESS ANY KEY TO STOP AND SAVE")
    print("=" * 58)
    
    input()
    process.terminate()
    print("[!] Recording stopped.")
    input("Press Enter to continue...")

def dual_mode():
    """Record both camera and screen simultaneously"""
    print("[!] DUAL MODE - Recording camera and screen...")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    cam_out = os.path.join(CAPTURES, f'Camera_{timestamp}.mkv')
    screen_out = os.path.join(CAPTURES, f'Capture_{timestamp}.mkv')
    Path(CAPTURES).mkdir(parents=True, exist_ok=True)
    
    # Camera recording
    cmd_cam = [
        'ffmpeg', '-f', 'dshow', '-i', 'video="Integrated Webcam"',
        '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '28',
        '-pix_fmt', 'yuv420p', cam_out
    ]
    
    # Screen recording
    cmd_screen = [
        'ffmpeg', '-f', 'gdigrab', '-framerate', '30', '-i', 'desktop',
        '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '28',
        '-pix_fmt', 'yuv420p', screen_out
    ]
    
    proc_cam = subprocess.Popen(cmd_cam)
    proc_screen = subprocess.Popen(cmd_screen)
    
    print("Recording both camera and screen...")
    print("Press Enter to stop...")
    input()
    
    proc_cam.terminate()
    proc_screen.terminate()
    
    # Ask for finishing mode
    print("\n" + "=" * 58)
    print("  F I N I S H I N G")
    print("=" * 58)
    print(" [1] SIDE BY SIDE")
    print(" [2] PICTURE IN PICTURE")
    print("=" * 58)
    
    finish = input("FINISHING [C]ANCEL: ").strip().lower()
    
    if finish == '1':
        output = os.path.join(CAPTURES, f'Record-SBS_{timestamp}.mov')
        cmd = [
            'ffmpeg', '-i', screen_out, '-i', cam_out,
            '-filter_complex', '[0:v]scale=trunc(oh*a/2)*2:720[cam];[1:v]scale=trunc(oh*a/2)*2:720[scr];[cam][scr]hstack=inputs=2',
            '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '23',
            '-pix_fmt', 'yuv420p', output
        ]
        subprocess.run(cmd)
        print("✅ Side by side video created!")
        
    elif finish == '2':
        output = os.path.join(CAPTURES, f'Record-P2P_{timestamp}.mov')
        cmd = [
            'ffmpeg', '-i', screen_out, '-i', cam_out,
            '-filter_complex', '[0:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[bg];[1:v]scale=640/2:-1[pinp];[bg][pinp]overlay=x=W-w-20:y=H-h-20',
            '-vcodec', 'libx264', '-preset', 'ultrafast', '-crf', '28',
            '-pix_fmt', 'yuv420p', output
        ]
        subprocess.run(cmd)
        print("✅ Picture in picture video created!")
    
    input("Press Enter to continue...")

def dev_test():
    """Test video/audio devices"""
    print("Testing devices...")
    cmd = ['ffplay', '-f', 'dshow', '-i', 'video="Integrated Webcam"']
    subprocess.run(cmd)

def transcribe_subtitle():
    """Transcribe audio/video and embed subtitles"""
    while True:
        clear_screen()
        print("\n" + "=" * 44)
        print("  TRANSCRIBE SUBTITLE")
        print("=" * 44)
        print(" [1] Transcribe Audio")
        print(" [2] Transcribe Video")
        print(" [3] Embed Subtitle")
        print("=" * 44)
        
        choice = input("Select [1-3][0]Cancel: ").strip()
        
        if choice == "0":
            break
        elif choice == "1":
            target_dir = select_folder(MUSIC_DIR, "Music")
            music_files = show_music(target_dir)
            if not music_files:
                input("Press Enter to continue...")
                continue
            
            try:
                m_sel = int(input("Select MP3: ")) - 1
                selected_file = str(music_files[m_sel])
                filename = music_files[m_sel].stem
            except:
                continue
            
            print(f"Transcribing: {filename}...")
            cmd = ['whisper', selected_file, '--model', 'base', '--output_format', 'srt']
            subprocess.run(cmd)
            
            subtitle_dir = Path(VIDEOS_DIR) / 'Exports' / 'Subtitle'
            subtitle_dir.mkdir(parents=True, exist_ok=True)
            
            srt_file = Path(f"{filename}.srt")
            if srt_file.exists():
                shutil.move(str(srt_file), str(subtitle_dir / srt_file.name))
                print("✅ Transcribe audio successfully!")
            
        elif choice == "2":
            videos = show_videos()
            if not videos:
                input("Press Enter to continue...")
                continue
            
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_file = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            print(f"Transcribing: {filename}...")
            cmd = ['whisper', selected_file, '--model', 'base', '--output_format', 'srt']
            subprocess.run(cmd)
            
            subtitle_dir = Path(VIDEOS_DIR) / 'Exports' / 'Subtitle'
            subtitle_dir.mkdir(parents=True, exist_ok=True)
            
            srt_file = Path(f"{filename}.srt")
            if srt_file.exists():
                shutil.move(str(srt_file), str(subtitle_dir / srt_file.name))
                print("✅ Transcribe video successfully!")
            
        elif choice == "3":
            subtitles = show_subtitles()
            if not subtitles:
                input("Press Enter to continue...")
                continue
            
            try:
                sub_sel = int(input("Select Subtitle: ")) - 1
                selected_sub = str(subtitles[sub_sel])
            except:
                continue
            
            videos = show_videos()
            if not videos:
                continue
            
            try:
                v_sel = int(input("Select Video: ")) - 1
                selected_video = str(videos[v_sel])
                filename = videos[v_sel].stem
            except:
                continue
            
            outfile = os.path.join(OUTPUT_DIR, f'embed_{filename}_{random.randint(1000,9999)}.mp4')
            cmd = ['ffmpeg', '-i', selected_video, '-vf', f'subtitles="{selected_sub}"', '-y', outfile]
            subprocess.run(cmd)
            print("✅ Embed Subtitle successfully!")
        
        input("Press Enter to continue...")

def tts_synthesizer():
    """Text-to-Speech video creator"""
    clear_screen()
    
    folder = "tutorial"
    width, height = "1920", "1080"
    bg_color = "0x1e1e1e"
    
    print(f"Searching for content files in: {os.getcwd()}\n")
    
    txt_files = list(Path('.').glob('*.txt'))
    
    if not txt_files:
        print("[ERROR] No content files found.")
        input("Press Enter to continue...")
        return
    
    for i, f in enumerate(txt_files, 1):
        print(f"[{i}] {f.name}")
    
    print("\nFound {} file(s).".format(len(txt_files)))
    
    try:
        choice = int(input(f"Select Content (1-{len(txt_files)}): ")) - 1
        source_file = txt_files[choice]
    except:
        return
    
    Path(folder).mkdir(exist_ok=True)
    
    print(f"\n✅ Selected: {source_file.name}")
    print("Processing...")
    print("=" * 58)
    print("             CREATE VIDEO TUTORIAL")
    print("=" * 58)
    print("🎙️ Reading tutorial content...")
    
    with open(source_file, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) < 3:
                continue
            
            fname, voice, display = parts[0], parts[1], parts[2]
            
            print(f"🎤 Processing {fname}...")
            
            # Generate voice with PowerShell
            ps_script = f'''
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
try {{ $speak.SelectVoice('Microsoft Andika') }} catch {{ }}
$speak.SetOutputToWaveFile('{TEMP_DIR}\\temp.wav')
$speak.Speak([regex]::Unescape('{voice}'))
$speak.Dispose()
'''
            ps_file = os.path.join(TEMP_DIR, 'speak.ps1')
            with open(ps_file, 'w') as ps:
                ps.write(ps_script)
            
            subprocess.run(['powershell', '-ExecutionPolicy', 'Bypass', '-File', ps_file])
            
            # Get duration
            result = subprocess.run(
                ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
                 '-of', 'default=noprint_wrappers=1:nokey=1',
                 os.path.join(TEMP_DIR, 'temp.wav')],
                capture_output=True, text=True
            )
            try:
                dur = float(result.stdout.strip())
            except:
                dur = 5
            
            # Create video
            outfile = os.path.join(folder, f'{fname}.mp4')
            cmd = [
                'ffmpeg', '-y',
                '-f', 'lavfi', '-i', f'color=c={bg_color}:s={width}x{height}:d={dur}',
                '-i', os.path.join(TEMP_DIR, 'temp.wav'),
                '-vf', f"drawtext=fontfile='Playball.ttf':text='{display}':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=(h-text_h)/2",
                '-c:v', 'libx264', '-c:a', 'aac', '-pix_fmt', 'yuv420p', '-shortest', outfile
            ]
            subprocess.run(cmd)
            
            # Cleanup
            if os.path.exists(os.path.join(TEMP_DIR, 'temp.wav')):
                os.remove(os.path.join(TEMP_DIR, 'temp.wav'))
            
            print(f"✅ Created {fname}.mp4")
    
    # Merge videos
    print("\n" + "=" * 58)
    print("  MERGE VIDEO")
    print("=" * 58)
    
    video_files = sorted(Path(folder).glob('*.mp4'))
    
    if len(video_files) < 2:
        print("❌ Need at least 2 video files to merge")
        input("Press Enter to continue...")
        return
    
    print(f"Found {len(video_files)} MP4 files\n")
    
    # Create file list for concat
    list_file = os.path.join(TEMP_DIR, 'file_list.txt')
    with open(list_file, 'w') as f:
        for vf in video_files:
            f.write(f"file '{vf.absolute()}'\n")
    
    outfile = os.path.join(OUTPUT_DIR, f'scene_final_{random.randint(1000,9999)}.mp4')
    
    cmd = ['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', list_file,
           '-c', 'copy', outfile]
    subprocess.run(cmd)
    
    print(f"✅ Successfully merged All scenes!")
    input("Press Enter to continue...")

def image_slideshow():
    """Create image slideshow video"""
    clear_screen()
    print("Configure...")
    
    target_dir = select_folder(PICTURES_DIR, "Pictures")
    images = show_pictures(target_dir)
    
    if not images:
        print("No images found!")
        input("Press Enter to continue...")
        return
    
    try:
        img_dur = float(input("Enter duration per image (seconds): "))
    except:
        img_dur = 3
    
    trans_dur = 1
    
    # Get resolution
    print("\n" + "=" * 44)
    print("      SELECT VIDEO RESOLUTION")
    print("=" * 44)
    print(" [1] 480p  (640x480)")
    print(" [2] 720p  (1280x720)")
    print(" [3] 1080p (1920x1080)")
    print("=" * 44)
    
    res_choice = input("Select Resolution [1-3]: ").strip()
    res_map = {"1": "640x480", "2": "1280x720", "3": "1920x1080"}
    resolution = res_map.get(res_choice, "1280x720")
    
    # Get BGM
    music_files = show_music()
    if not music_files:
        print("No music found!")
        input("Press Enter to continue...")
        return
    
    try:
        m_sel = int(input("Select BGM: ")) - 1
        selected_bgm = str(music_files[m_sel])
        bgm_name = music_files[m_sel].stem
    except:
        return
    
    try:
        bgm_dur = float(input("Enter BGM duration (seconds): "))
    except:
        bgm_dur = 30
    
    title = input("Enter title: ").strip()
    
    print(f"\nMusik     : {bgm_name}")
    print(f"Gambar    : {len(images)}")
    print(f"Resolusi  : {resolution}")
    
    # Process audio
    temp_music = os.path.join(TEMP_DIR, 'temp_music.m4a')
    cmd = ['ffmpeg', '-y', '-i', selected_bgm, '-t', str(bgm_dur),
           '-c:a', 'aac', '-b:a', '192k', temp_music]
    subprocess.run(cmd, capture_output=True)
    
    # Build filter complex
    inputs = ""
    scaler = ""
    for i, img in enumerate(images[:20]):  # Max 20 images
        inputs += f" -loop 1 -t {img_dur} -i \"{img}\""
        scaler += f"[{i}:v]scale={resolution}:force_original_aspect_ratio=increase,crop={resolution},setsar=1,settb=AVTB,setpts=PTS-STARTPTS[v{i}];"
    
    # Build xfade chain
    xfade = ""
    last_out = "[v0]"
    overlap_step = img_dur - trans_dur
    
    for i in range(1, min(len(images), 20)):
        offset = i * overlap_step
        if i == min(len(images), 20) - 1:
            xfade += f"{last_out}[v{i}]xfade=transition=fade:duration={trans_dur}:offset={offset}"
            if title:
                xfade += f",drawtext=fontfile='arial':text='{title}':fontcolor=white:fontsize=30:x=(w-tw)/2:y=150:box=1:boxcolor=#000000@0.4:boxborderw=15"
            xfade += f",format=yuv420p[vfinal]"
        else:
            xfade += f"{last_out}[v{i}]xfade=transition=fade:duration={trans_dur}:offset={offset}[vtrans{i}];"
            last_out = f"[vtrans{i}]"
    
    outfile = os.path.join(VIDEOS_DIR, 'Exports', 'Short', f'reels_{bgm_name}_{random.randint(1000,9999)}.mp4')
    Path(outfile).parent.mkdir(parents=True, exist_ok=True)
    
    cmd = f'ffmpeg -y {inputs} -i {temp_music} -filter_complex "{scaler}{xfade}" -map "[vfinal]" -map {len(images[:20])}:a -c:v libx264 -r 30 -pix_fmt yuv420p -c:a aac -preset fast -shortest "{outfile}"'
    subprocess.run(cmd, shell=True)
    
    # Cleanup
    if os.path.exists(temp_music):
        os.remove(temp_music)
    
    print(f"✅ Slideshow created: {outfile}")
    input("Press Enter to continue...")

def archived():
    """Archive old files and cleanup"""
    clear_screen()
    print("[!] KILL PROCESS...")
    
    subprocess.run(['taskkill', '/f', '/im', 'ffplay.exe'], capture_output=True)
    subprocess.run(['taskkill', '/f', '/im', 'ffmpeg.exe'], capture_output=True)
    
    datestr = datetime.now().strftime("%Y-%m-%d")
    
    # Archive video files
    archive_video = os.path.join(OUTPUT_DIR, f'Archive_{datestr}')
    Path(archive_video).mkdir(parents=True, exist_ok=True)
    
    for f in Path(OUTPUT_DIR).glob('*.mp4'):
        shutil.move(str(f), os.path.join(archive_video, f.name))
    
    # Archive audio files
    archive_audio = os.path.join(OUTPUT_AUDIO, f'Archive_{datestr}')
    Path(archive_audio).mkdir(parents=True, exist_ok=True)
    
    for f in Path(OUTPUT_AUDIO).glob('*.mp3'):
        shutil.move(str(f), os.path.join(archive_audio, f.name))
    
    # Clean temp
    shutil.rmtree(TEMP_DIR, ignore_errors=True)
    
    print(f"{archive_video} Archived!")
    print("Goodbye!")
    time.sleep(3)

def exit_program():
    """Clean exit"""
    clear_screen()
    print("\n" + "-" * 52)
    print("  SYSTEM INFORMATION")
    print("-" * 52)
    
    music_count = len(list(Path(MUSIC_DIR).rglob('*.mp3')) + list(Path(MUSIC_DIR).rglob('*.opus')) + list(Path(MUSIC_DIR).rglob('*.wav')))
    print(f"Music    : {music_count} exist audio files")
    
    pics_count = len(list(Path(PICTURES_DIR).rglob('*.jpg')) + list(Path(PICTURES_DIR).rglob('*.jpeg')) +
                     list(Path(PICTURES_DIR).rglob('*.png')) + list(Path(PICTURES_DIR).rglob('*.webp')))
    print(f"Pictures : {pics_count} exist image files")
    
    video_count = len(list(Path(VIDEOS_DIR).rglob('*.mp4')) + list(Path(VIDEOS_DIR).rglob('*.avi')) +
                       list(Path(VIDEOS_DIR).rglob('*.mkv')) + list(Path(VIDEOS_DIR).rglob('*.mov')))
    print(f"Videos   : {video_count} exist video files")
    
    out_count = len(list(Path(OUTPUT_DIR).glob('*.mp4')))
    print(f"Output   : {out_count} output videos")
    
    out_audio_count = len(list(Path(OUTPUT_AUDIO).glob('*.mp3')))
    print(f"Output   : {out_audio_count} output audio")
    
    print("\n" + "-" * 52)
    print("  [INFO] Your MP3, Image, Video files are SAFE")
    print("  [INFO] All original files remain untouched")
    print("-" * 52)
    print("\n Cleaning up temporary files...")
    
    shutil.rmtree(TEMP_DIR, ignore_errors=True)
    
    print(" Goodbye!")
    subprocess.run(['taskkill', '/f', '/im', 'ffplay.exe'], capture_output=True)
    subprocess.run(['taskkill', '/f', '/im', 'ffmpeg.exe'], capture_output=True)
    
    time.sleep(3)

# ==================== MAIN ====================
if __name__ == "__main__":
    import time
    
    create_directories()
    
    if not check_ffmpeg():
        print("FFmpeg is required. Please install FFmpeg and add it to PATH.")
        sys.exit(1)
    
    main_menu()
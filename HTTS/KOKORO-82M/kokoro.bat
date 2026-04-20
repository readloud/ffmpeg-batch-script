@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    KOKORO-82M MASS VIDEO RENDERER
echo ===============================================

:: Set HF_TOKEN (GANTI DENGAN TOKEN ASLI ANDA)
set HF_TOKEN=hf_xxxxxxxxxxxxxx

:: Set environment variable
setx HF_TOKEN %HF_TOKEN% > nul

set "INPUT_FILE=input.txt"
set "OUT_DIR=HASIL_KOKORO"

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo.
echo PILIH JENIS SUARA:
echo [1] Pria (Michael)
echo [2] Wanita (Sarah)
set /p pilih="Masukkan pilihan (1/2): "

if "%pilih%"=="1" (set GENDER=pria) else (set GENDER=wanita)

echo.
echo Mulai memproses...
echo.

set /a count=1

for /f "usebackq delims=" %%A in ("%INPUT_FILE%") do (
    set "LINE_TEXT=%%A"
    
    if not "!LINE_TEXT!"=="" (
        echo ----------------------------------------
        echo [BARIS !count!] Memproses: !LINE_TEXT!
        
        :: Hapus file temp jika ada
        if exist "temp.wav" del "temp.wav"
        
        :: 1. Jalankan Kokoro TTS
        python tts_single.py "!LINE_TEXT!" "temp.wav" %GENDER%
        
        :: Cek apakah file WAV berhasil dibuat
        if exist "temp.wav" (
            echo [OK] TTS berhasil, membuat video dan audio...
            
            :: Video MP4 Background Hitam dengan teks
            ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=24 -i temp.wav ^
                   -vf "drawtext=text='!LINE_TEXT!':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2" ^
                   -c:v libx264 -tune stillimage -c:a aac -b:a 192k ^
                   -pix_fmt yuv420p -shortest "%OUT_DIR%\Video_!count!.mp4" -y -loglevel error
            
            if exist "%OUT_DIR%\Video_!count!.mp4" (
                echo [OK] Video berhasil: Video_!count!.mp4
            ) else (
                echo [ERROR] Gagal membuat video
            )
            
            :: Audio MP3 saja
            ffmpeg -i temp.wav -acodec libmp3lame -aq 2 "%OUT_DIR%\Audio_!count!.mp3" -y -loglevel error
            
            if exist "%OUT_DIR%\Audio_!count!.mp3" (
                echo [OK] Audio berhasil: Audio_!count!.mp3
            )
            
            :: Hapus file temp
            del "temp.wav"
            echo [SELESAI] Baris !count!
        ) else (
            echo [ERROR] Gagal generate TTS untuk baris !count!
        )
        
        set /a count+=1
        echo.
    )
)

echo.
echo ===============================================
echo SEMUA PROSES BERHASIL! Cek folder: %OUT_DIR%
echo Total file: %count% baris
echo ===============================================
pause
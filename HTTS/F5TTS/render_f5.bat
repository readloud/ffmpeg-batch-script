@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    F5-TTS MASS RENDERER (INDONESIA)
echo ===============================================
echo.

:: Cek FFmpeg
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg tidak ditemukan!
    pause
    exit /b 1
)

:: Set input dan output
set "INPUT_FILE=input.txt"
set "OUT_DIR=HASIL_F5TTS"

if not exist "%INPUT_FILE%" (
    echo [ERROR] File %INPUT_FILE% tidak ditemukan!
    pause
    exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

:: Cek folder ref_audio
if not exist "ref_audio" (
    echo [WARNING] Folder ref_audio tidak ditemukan!
    echo Membuat folder ref_audio...
    mkdir ref_audio
)

echo PILIH JENIS SUARA:
echo [1] Pria (butuh file ref_audio/pria.wav)
echo [2] Wanita (butuh file ref_audio/wanita.wav)
echo.
set /p pilih="Masukkan pilihan (1/2): "

if "%pilih%"=="1" (set GENDER=pria) else (set GENDER=wanita)

:: Cek file reference audio
if not exist "ref_audio\%GENDER%.wav" (
    echo.
    echo [ERROR] File ref_audio/%GENDER%.wav tidak ditemukan!
    echo.
    echo Silakan siapkan file reference audio terlebih dahulu:
    echo 1. Rekam suara %GENDER% selama 5-10 detik
    echo 2. Simpan sebagai ref_audio/%GENDER%.wav
    echo 3. Format: WAV, mono, 24kHz
    echo.
    echo Atau jalankan script create_sample_voice.py untuk sample sementara
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Reference audio ditemukan: ref_audio/%GENDER%.wav
echo.

echo Mulai memproses...
echo.

set /a count=1
set /a total=0

:: Hitung total baris
for /f "usebackq delims=" %%A in ("%INPUT_FILE%") do (
    set /a total+=1
)

echo Total kalimat: !total!
echo.

for /f "usebackq delims=" %%A in ("%INPUT_FILE%") do (
    set "LINE_TEXT=%%A"
    
    if not "!LINE_TEXT!"=="" (
        echo ----------------------------------------
        echo [%count%/%total%] Memproses: !LINE_TEXT!
        
        :: Generate TTS dengan F5-TTS
        python tts_single.py "!LINE_TEXT!" "temp_%count%.wav" %GENDER%
        
        :: Cek hasil
        if exist "temp_%count%.wav" (
            echo [OK] TTS berhasil
            
            :: Escape teks untuk drawtext
            set "TEXT_ESCAPED=!LINE_TEXT:'=^'!"
            
            :: Buat video
            ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=24 -i "temp_%count%.wav" ^
                   -vf "drawtext=text='!TEXT_ESCAPED!':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:fontfile=/Windows/Fonts/arial.ttf" ^
                   -c:v libx264 -tune stillimage -c:a aac -b:a 192k ^
                   -pix_fmt yuv420p -shortest "%OUT_DIR%\Video_%count%.mp4" -y -loglevel error
            
            if exist "%OUT_DIR%\Video_%count%.mp4" (
                echo [OK] Video: Video_%count%.mp4
                
                :: Audio MP3
                ffmpeg -i "temp_%count%.wav" -acodec libmp3lame -aq 2 "%OUT_DIR%\Audio_%count%.mp3" -y -loglevel error
                echo [OK] Audio: Audio_%count%.mp3
            )
            
            del "temp_%count%.wav" 2>nul
            
        ) else (
            echo [ERROR] Gagal generate TTS
        )
        
        set /a count+=1
        echo.
    )
)

echo.
echo ===============================================
echo SEMUA PROSES SELESAI!
echo ===============================================
echo Output folder: %OUT_DIR%
echo.
echo File yang dihasilkan:
dir "%OUT_DIR%" /b
echo.
pause
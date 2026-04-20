@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    TTS INDONESIA MASS RENDERER (TANPA JEDA)
echo ===============================================
echo.

set "INPUT_FILE=input.txt"
set "OUT_DIR=HASIL_VIDEO"

if not exist "%INPUT_FILE%" (
    echo [ERROR] File %INPUT_FILE% tidak ditemukan!
    pause
    exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
if not exist "temp_audio" mkdir "temp_audio"

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
        
        :: Generate TTS dengan gTTS
        python -c "from gtts import gTTS; gTTS('!LINE_TEXT!', lang='id', slow=False).save('temp_audio/temp.mp3')"
        
        :: Cek hasil TTS
        if exist "temp_audio\temp.mp3" (
            echo [OK] TTS berhasil
            
            :: Escape teks untuk drawtext
            set "TEXT_ESCAPED=!LINE_TEXT:'=^'!"
            
            :: Video MP4 Background Hitam dengan Teks (tanpa jeda)
            ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=24 -i "temp_audio\temp.mp3" ^
                   -vf "drawtext=text='!TEXT_ESCAPED!':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:fontfile=/Windows/Fonts/arial.ttf" ^
                   -c:v libx264 -tune stillimage -c:a aac -b:a 192k ^
                   -pix_fmt yuv420p -shortest "%OUT_DIR%\Video_!count!.mp4" -y -loglevel error
            
            if exist "%OUT_DIR%\Video_!count!.mp4" (
                echo [OK] Video berhasil: Video_!count!.mp4
                
                :: Audio MP3 saja
                copy "temp_audio\temp.mp3" "%OUT_DIR%\Audio_!count!.mp3" >nul
                echo [OK] Audio berhasil: Audio_!count!.mp3
            ) else (
                echo [ERROR] Gagal membuat video
            )
            
            :: Hapus file temporary
            del "temp_audio\temp.mp3" 2>nul
            
        ) else (
            echo [ERROR] Gagal generate TTS
        )
        
        set /a count+=1
        echo.
    )
)

:: Gabungkan semua video (tanpa jeda)
echo ===============================================
echo Menggabungkan semua video...
echo ===============================================

if exist "videos_list.txt" del "videos_list.txt"
for /L %%i in (1,1,!total!) do (
    if exist "%OUT_DIR%\Video_%%i.mp4" (
        echo file '%OUT_DIR%\Video_%%i.mp4' >> videos_list.txt
    )
)

if exist videos_list.txt (
    ffmpeg -f concat -safe 0 -i videos_list.txt -c copy output_all.mp4 -y -loglevel error
    echo [OK] Video final: output_all.mp4
    del videos_list.txt
) else (
    echo [ERROR] Tidak ada video untuk digabung
)

echo.
echo ===============================================
echo SEMUA PROSES SELESAI! (Tanpa jeda 5 detik)
echo ===============================================
echo Output folder: %OUT_DIR%
echo Video final: output_all.mp4
echo.
pause
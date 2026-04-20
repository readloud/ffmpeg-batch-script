@echo off
setlocal enabledelayedexpansion

:: --- KONFIGURASI ---
set "RES=1080:1920"
set "IMG_DUR=10"
set "TRANS_DUR=1"
set "OUTPUT=reels_fixed.mp4"

echo [STEP 1] Mencari Gambar ^& Musik...

set "MUSIK_INPUT="
for /f "delims=" %%m in ('dir /b *.mp3 *.opus *.m4a *.wav 2^>nul') do (
    set "MUSIK_INPUT=%%m"
)

set "INPUT_FILES="
set /a num_img=0
for /f "delims=" %%g in ('dir /b *.jfif *.jpg *.png *.jpeg *.webp *.bmp 2^>nul') do (
    if !num_img! LSS 100 (
        :: loop 1 dan -t sangat krusial di sini
        set "INPUT_FILES=!INPUT_FILES! -loop 1 -t %IMG_DUR% -i "%%g""
        set /a num_img+=1
    )
)

echo Musik: %MUSIK_INPUT%
echo Gambar: %num_img%

echo.
echo [STEP 2] Menyiapkan Audio...
ffmpeg -i "%MUSIK_INPUT%" -t 60 -c:a aac -b:a 192k temp_music.m4a -y

echo.
echo [STEP 3] Memproses Video (Filter Complex)...

set "SCALER="
set /a end_idx=%num_img% - 1

:: Bagian ini penting: Menyamakan Timebase agar durasi tidak hilang
for /L %%i in (0,1,%end_idx%) do (
    set "SCALER=!SCALER![%%i:v]scale=%RES%:force_original_aspect_ratio=increase,crop=%RES%,setsar=1,settb=AVTB,setpts=PTS-STARTPTS[v%%i];"
)

set "XFADE="
set "LAST_OUT=[v0]"
set /a overlap_step=%IMG_DUR% - %TRANS_DUR%

for /L %%i in (1,1,%end_idx%) do (
    set /a "offset=%%i * overlap_step"
    
    if %%i==%end_idx% (
        set "XFADE=!XFADE!!LAST_OUT![v%%i]xfade=transition=fade:duration=%TRANS_DUR%:offset=!offset!,drawtext=fontfile='arial':text='READLOUD':fontcolor=white:fontsize=60:x=(w-tw)/2:y=150,format=yuv420p[vfinal]"
    ) else (
        set "XFADE=!XFADE!!LAST_OUT![v%%i]xfade=transition=fade:duration=%TRANS_DUR%:offset=!offset![vtrans%%i];"
        set "LAST_OUT=[vtrans%%i]"
    )
)

ffmpeg %INPUT_FILES% -i temp_music.m4a -filter_complex "%SCALER%%XFADE%" ^
-map "[vfinal]" -map %num_img%:a -c:v libx264 -r 30 -pix_fmt yuv420p -c:a aac -preset fast -shortest "%OUTPUT%" -y

del temp_music.m4a
echo Selesai! Video: %OUTPUT%
pause
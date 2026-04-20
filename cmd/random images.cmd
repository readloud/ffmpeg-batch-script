@echo off
setlocal enabledelayedexpansion
IF NOT EXIST "output" MKDIR "output"
REM radom images background
FOR %%i IN (*.mp3) DO (
    set "FILENAME=%%~ni"
    
    REM Cek apakah ada file gambar .jpg atau .png dengan nama yang sama
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
        set "V_FILTER=scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
    ) else (
        REM Jika tidak ada gambar, pakai warna hitam
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
        set "V_FILTER=format=yuv420p"
    )

    ffmpeg !INPUT_V! -i "%%i" -filter_complex "[0:v]!V_FILTER![main];[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves];[main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box];[bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2,drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text];[video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni_images.mp4"
)
echo --- PROSES SELESAI ---
pause
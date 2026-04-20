@echo off
setlocal enabledelayedexpansion
REM Smart Detect logic
if not exist "output" mkdir "output"

FOR %%i IN (*.mp3) do (
    set "FILENAME=%%~ni"
    echo Processing: "!FILENAME!"
    
    if exist "%%~ni.jpg" (
        set "INPUT_V=-loop 1 -i "%%~ni.jpg""
    ) else if exist "%%~ni.png" (
        set "INPUT_V=-loop 1 -i "%%~ni.png""
    ) else if exist "images.webp" (
        set "INPUT_V=-loop 1 -i "images.webp""
    ) else (
        set "INPUT_V=-f lavfi -i color=c=#0e0e0e:s=1280x720:r=25"
    )

    ffmpeg -y !INPUT_V! -i "%%i" -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main];     [1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves];[main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box];     [bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2,drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text];[video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
echo --- RENDER COMPLETE ---
pause
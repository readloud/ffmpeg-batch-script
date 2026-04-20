@echo off
REM solid black background
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -f lavfi -i color=c=#0e0e0e:s=1280x720:r=25 -i "%%i" -filter_complex "[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves];[0:v]drawbox=x=0:y=ih-140:w=iw:h=140:color=#1a1a1a@1:t=fill[bg_box];[bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110,drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70[video_text];[video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -c:a copy -shortest -y "output\%%~ni_solid-black.mp4"
)
pause
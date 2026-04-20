@echo off
::RENDER AUDIO IMAGE WITH SAME TITLE (AUDIO.MP3 = AUDIO.JPG)
IF NOT EXIST "output" MKDIR "output"
FOR %%i IN (*.mp3) DO (
    ffmpeg -loop 1 -i "%%~ni.jpg" -i "%%i" -filter_complex ^
    "[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main];[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; [main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.5:t=fill[bg_box];[bg_box]drawtext=text='%%~ni':fontcolor=#00FF41:fontsize=36:x=40:y=h-110:shadowcolor=black@0.9:shadowx=2:shadowy=2,drawtext=text='Official Audio':fontcolor=white:fontsize=20:x=42:y=h-70:shadowcolor=black@0.9:shadowx=1:shadowy=1[video_text];[video_text][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a copy -shortest -y "output\%%~ni.mp4"
)
pause
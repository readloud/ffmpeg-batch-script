@echo off
set "INPUT=audio.mp4"
set "TITLE=Your Video Title"
set "SUBTITLE=Additional Text"
set "OUTPUT=final_video.mp4"
REM Long process rendering deppend of amount of RAM
:: Check if input exists first
if not exist "%INPUT%" (
    echo [ERROR] Input file %INPUT% not found!
    pause
    exit /b
)

echo Starting render...

ffmpeg -y -i "%INPUT%" -filter_complex "[0:v]scale=1280:720[scaled];[0:a]showwaves=s=1200x100:mode=cline:rate=25:colors=white|cyan[waves];color=c=#222222:s=1280x120,format=rgba[bg];[bg][waves]overlay=40:10[waves_final];[scaled]drawtext=text='%TITLE%':fontcolor=white:fontsize=44:x=(w-text_w)/2:y=(h/2)-40:shadowcolor=black@0.6:shadowx=3:shadowy=3,drawtext=text='%SUBTITLE%':fontcolor=#AAAAAA:fontsize=24:x=(w-text_w)/2:y=(h/2)+20,drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=16:x=20:y=10,drawtext=text='Duration\: 00\:02\:30':fontcolor=yellow:fontsize=16:x=w-180:y=10[v_txt];[v_txt][waves_final]overlay=0:H-120" -c:v libx264 -preset fast -crf 20 -c:a copy "%OUTPUT%"

echo.
if exist "%OUTPUT%" (
    echo Done! Output saved as %OUTPUT% [cite: 2]
) else (
    echo Render failed. Check if FFmpeg is installed.
)
pause
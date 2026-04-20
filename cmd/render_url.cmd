@echo off
setlocal enabledelayedexpansion

:: 1. Configuration 
set "FONT_FILE=Ritual of the Witch.ttf"
REM depend of SIGNAL STRENGTH
:: Create a path that FFmpeg understands 
:: We replace backslashes with forward slashes AND escape the colon 
set "TEMP_PATH=%CD%\%FONT_FILE%"
set "FONT_PATH=!TEMP_PATH:\=/!"
set "FONT_PATH=!FONT_PATH::=\:!"

if not exist "output" mkdir "output" 
if not exist "list.txt" echo https://www.youtube.com/watch?v=JHwn7kB_6sQ > list.txt
for /f "usebackq tokens=*" %%u in ("list.txt") do (
    echo --------------------------------------------------
    echo Fetching: %%u 

    :: Get Metadata using yt-dlp 
    for /f "delims=" %%t in ('yt-dlp --get-filename -o "%%(title)s" "%%u"') do set "RAW_TITLE=%%t" 
    for /f "delims=" %%g in ('yt-dlp -f "bestaudio/best" -g "%%u"') do set "STREAM_URL=%%g" 

    :: Sanitize Title 
    set "SAFE_TITLE=!RAW_TITLE::=-!" 
    set "SAFE_TITLE=!SAFE_TITLE:?=!" 
    set "SAFE_TITLE=!SAFE_TITLE:'=!"

    echo Processing: !SAFE_TITLE! 

    :: FFmpeg Command 
    :: Note the use of double quotes around the fontfile path inside the filter
    ffmpeg -y -hide_banner -loop 1 -i "images.jpg" -i "!STREAM_URL!" -filter_complex ^
"[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720[main]; ^
[1:a]showwaves=s=1280x60:mode=p2p:rate=25:colors=#00FF41@0.9[waves]; ^
[main]drawbox=x=0:y=ih-140:w=iw:h=140:color=#000000@0.6:t=fill[bg_box]; ^
[bg_box]drawtext=fontfile='!FONT_PATH!':text='!SAFE_TITLE!':fontcolor=#00FF41:fontsize=42:x=40:y=h-110:shadowcolor=black@0.9:shadowx=3:shadowy=3, ^
drawtext=fontfile='!FONT_PATH!':text='Remote Audio Stream':fontcolor=white:fontsize=20:x=42:y=h-70[v_txt]; ^
[v_txt][waves]overlay=x=0:y=H-60[final]" -map "[final]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "output\!SAFE_TITLE!.mp4" 
)
pause
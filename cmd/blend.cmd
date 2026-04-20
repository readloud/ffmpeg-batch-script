@echo off
setlocal enabledelayedexpansion
REM blend render
if not exist "output" mkdir "output"

set "total=0"
for %%a in (*.mp3) do set /a "total+=1"

if %total%==0 (
    echo [ERROR] No .mp3 files found in: %cd%
    pause
    exit /b
)

set "current=0"
for %%i in (*.mp3) do (
    set /a "current+=1"
    echo [!current!/%total%] Processing: "%%i"
    
    ffmpeg -y -hide_banner -loglevel error -stats -i "%%i" -filter_complex "[0:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:rate=60:colors=0x00FF00[wave];[wave]split[v1][v2];[v1]drawbox=x=0:y=0:w=1280:h=720:c=black@1:t=fill[bg];[v2]gblur=sigma=3,eq=brightness=0.2:contrast=1.2[glow];[bg][glow]blend=all_mode=addition:all_opacity=0.3,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -preset fast -crf 20 -c:a aac -b:a 192k -shortest "output\%%~ni_blend.mp4"

    if exist "output\%%~ni_seewav.mp4" (echo Success!) else (echo Failed!)
)

echo.
echo === FINISHED ===
pause
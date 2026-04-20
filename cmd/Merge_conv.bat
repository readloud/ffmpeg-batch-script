@echo off
setlocal enabledelayedexpansion

set "FOLDER=tutorial"
set "OUTPUT_DIR=%USERPROFILE%\Videos"
set "OUT_FILE=%OUTPUT_DIR%\conv_final-%random%.mp4"

:: Create output directory if it doesn't exist
if not exist "%tutorial%" mkdir %tutorial%

echo 🎬 Detecting all video files in "%FOLDER%" folder...
echo.

:: Check if folder exists
if not exist "%FOLDER%" (
    echo ❌ Folder "%FOLDER%" does not exist!
    echo    Current directory: %cd%
    pause
    exit /b
)

:: Clear old file list
if exist file_list.txt del file_list.txt

:: Find all MP4 files (simplified - just MP4 for now)
echo Looking for MP4 files...
set COUNT=0

:: Change to the folder and get files sorted by name
pushd "%FOLDER%"

:: Use dir to get sorted files and save to list
dir /b /on *.mp4 > ..\file_list.txt 2>nul

popd

:: Count files
if exist file_list.txt (
    for /f %%i in ('type file_list.txt ^| find /c /v ""') do set COUNT=%%i
)

echo Found %COUNT% MP4 files
echo.

if %COUNT% lss 2 (
    echo ❌ Need at least 2 video files
    echo.
    echo Files in "%FOLDER%" folder:
    dir "%FOLDER%" /b
    pause
    exit /b
)

:: Show files
echo Files to merge (in order):
type file_list.txt
echo.

:: Ask to continue
set /p CONFIRM=Process these %COUNT% files? (Y/N): 
if /i not "!CONFIRM!"=="Y" exit /b

:: Build filter_complex for crossfades
set "FILTER="
set "INPUTS="
set "PREV="
set "FADE_DURATION=1"  :: 1 second fade

for /f "usebackq delims=" %%i in ("file_list.txt") do (
    set "INPUTS=!INPUTS! -i "%FOLDER%\%%i""
)

:: Create filter graph for crossfades
set "FILTER="
set "LAST_STREAM=0"

for /L %%n in (0,1,%COUNT%) do (
    if %%n lss %COUNT% (
        set /a NEXT=%%n+1
        if %%n equ 0 (
            set "FILTER=[%%n:v]format=pix_fmts=yuva420p,fade=t=out:st=5:d=%FADE_DURATION%:alpha=1[v%%n]; "
            set "FILTER=!FILTER![!NEXT!:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=%FADE_DURATION%:alpha=1[v!NEXT!]; "
            set "FILTER=!FILTER![v%%n][v!NEXT!]overlay=format=auto,format=yuv420p[merged%%n]; "
        ) else (
            set "FILTER=!FILTER![merged%%n][v!NEXT!]overlay=format=auto,format=yuv420p[merged!NEXT!]; "
        )
    )
)

:: Simplify - use concat with crossfade at each transition
echo Creating video with crossfades between segments...
echo This will take time as it requires re-encoding...

:: Use complex filter for crossfades (simpler approach)
set "FILTER="
set "STREAMS="

for /L %%i in (0,1,%COUNT%) do (
    if %%i lss %COUNT% (
        set /a NEXT=%%i+1
        if !NEXT! lss %COUNT% (
            set "FILTER=!FILTER![%%i:v][%%i:a][!NEXT!:v][!NEXT!:a]"
        )
    )
)

:: Alternative simpler approach - use concat filter
ffmpeg %INPUTS% -filter_complex "concat=n=%COUNT%:v=1:a=1[v][a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac "%OUT_FILE%"


ffmpeg -y -hide_banner -stream_loop -1 -i "%OUT_FILE%" -i -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[bg];[1:v]format=rgba,scale=150:-1[logo_s];[bg][logo_s]overlay=W-w-10:10[bg_l];[wave];[bg_l]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];[bg_box][wave]overlay=0:H-175,format=yuv420p,eq=brightness=0.2:contrast=1.5[bg_waves]; [bg_waves]drawtext=fontfile=arial:font=arialbd:text='!OUT_FILE!':fontcolor=white:fontsize=60:x=30:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4,drawtext=fontfile=arial:font=arialbd:text='':fontcolor=white:fontsize=36:x=42:y=h-70[final]" -map "[final]" -map 0:a -c:v libx264 -preset fast -pix_fmt yuv420p -c:a aac -b:a 192k -shortest -y "%OUTPUT%"

if %errorlevel% equ 0 (
    echo ✅ Successfully created merged video
) else (
    echo ❌ Failed to create merged video
)

del file_list.txt 2>nul
echo.
pause
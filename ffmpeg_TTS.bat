@echo off
title Speech Synthesizer
setlocal enabledelayedexpansion

set "FOLDER=tutorial"
set "SOURCE_FILE=content.txt"
set "OUTPUT_DIR=%USERPROFILE%\Videos\Exports"

if not exist "%FOLDER%" mkdir "%FOLDER%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

if not exist "%SOURCE_FILE%" (
    echo ❌ Error: %SOURCE_FILE% not found!
    pause
    exit /b
)
:: Define video parameters
set "WIDTH=1920"
set "HEIGHT=1080"
set "WAVE_HEIGHT=90"
set "LOGO_TEXT=READLOUD"
set "LOGO_MODE=GLOW"
set "FONT_LOGO=Buda.ttf"
set "FONT_TITLE=Bulgia.otf"
set "FONT_SIZE_TITLE=30"
set "FONT_SUB=Super Wonder.ttf"
set "FONT_SIZE_SUB=30"
set "FONT_TEXT=Super Wonder.ttf"
set "FONT_SIZE=60"
set "BG_COLOR=0x1e1e1e"
set "SCROLL_X=box=1:boxcolor=#000000@0.4:boxborderw=15:x=w-mod(100*t\,w+tw+50):y=120"

set "TEMP_PATH=%CD%\%FONT_FILE%"
set "FONT_PATH=!TEMP_PATH:\=/!"
set "FONT_PATH=!FONT_PATH::=\:!"

:: Create simple filter for local files
set "track_filters='This video has been uploaded to READLOUD youtube channel and is for educational purposes only. All rights reserved to the music\, images\, and clips used belong to their respective owners.'"
	
:: Variabel Efek Rainbow/Glow 
if "%LOGO_MODE%"=="RAINBOW" (
    set "LOGO_FILTER=drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white:fontsize=45:x=W-tw-60:y=60,drawtext=fontfile='Playball.ttf':text='ffmpeg_ART':fontcolor=white@0.3:fontsize=30:x=W-tw-60:y=100:shadowcolor=black@0.5:shadowx=2:shadowy=2,hue=h=t*100"
) else (
    set "LOGO_FILTER=drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white:fontsize=45:x=W-tw-60:y=60,drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white@0.3:fontsize=43:x=W-tw-58:y=58,drawtext=fontfile='Playball.ttf':text='ffmpeg_ART':fontcolor=white@0.3:fontsize=30:x=W-tw-60:y=100"
)

:MAIN_MENU
cls
echo ========================================================
echo             T U T O R I A L   L I B R A R Y
echo ========================================================
echo  [1] CREATE VIDEO
echo  [2] MERGE VIDEO
echo  [3] MERGE VIDEO + WAVEFORM
echo  [4] LOGO_SETTINGS
echo  [5] ARCHIVED
echo ========================================================
set /p "main_choice=SYSTEM_INPUT [C]ANCLE> "

if /i "%main_choice%"=="c" goto MAIN_MENU
if "%main_choice%"=="1" goto CREATE_VIDEO
if "%main_choice%"=="2" goto MERGE_DIFF
if "%main_choice%"=="3" goto MERGE_CONV 
if "%main_choice%"=="4" goto LOGO_SETTINGS 
if "%main_choice%"=="5" goto ARCHIVED

exit /b

:LOGO_SETTINGS
cls
echo ========================================
echo         LOGO TEXT SETTINGS
echo ========================================
echo [1] Change Text (Current: %LOGO_TEXT%)
echo [2] Change Background (Loop)
echo [3] Set Mode: RAINBOW (Colors cycle over time)
echo [4] Set Mode: GLOW (White soft shadow)
echo ----------------------------------------
echo Current Mode: %LOGO_MODE%
echo ----------------------------------------
echo.
set /p l_choice="Choice (1-3) 0 -cancel: "
if "%l_choice%"=="1" set /p "LOGO_TEXT=Enter New Logo Text: " & goto LOGO_SETTINGS
if "%l_choice%"=="2" goto MAIN_MENU
if "%l_choice%"=="3" set "LOGO_MODE=RAINBOW" & goto MAIN_MENU
if "%l_choice%"=="4" set "LOGO_MODE=GLOW" & goto MAIN_MENU
if "%l_choice%"=="0" goto MAIN_MENU

:CREATE_VIDEO
cls
echo ========================================================
echo             CREATE VIDEO TUTORIAL
echo ========================================================
echo 🎙️ Reading tutorial content from %SOURCE_FILE%...
:: Loop through each line in the text file
for /f "usebackq tokens=1,2,3 delims=|" %%a in ("%SOURCE_FILE%") do (
    set "fname=%%a"
    set "voice=%%b"
    set "display=%%c"
    
    echo 🎤 Processing !fname!...

    :: 1. Generate Voice using PowerShell
    powershell -Command "Add-Type -AssemblyName System.Speech; $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; try { $speak.SelectVoice('Microsoft Andika') } catch {}; $speak.SetOutputToWaveFile('%TEMP%\temp.wav'); $speak.Speak([regex]::Unescape('!voice!')); $speak.Dispose()"

    :: 2. Get Duration
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%TEMP%\temp.wav" > dur.tmp
    set /p dur=<dur.tmp
    del dur.tmp
    if "!dur!"=="" set "dur=5"

    :: 3. Create Video - SIMPLE VERSION
    ffmpeg -y ^
    -f lavfi -i "color=c=%BG_COLOR%:s=%WIDTH%x%HEIGHT%:d=!dur!" ^
    -i "%TEMP%\temp.wav" ^
    -vf "drawtext=fontfile='DUBAI-BOLD.TTF':text='!display!':fontcolor=white:fontsize=%FONT_SIZE%:x=(w-text_w)/2:y=(h-text_h)/2" ^
    -c:v libx264 -c:a aac -pix_fmt yuv420p -shortest "%FOLDER%\!fname!.mp4"

    del "%TEMP%\temp.wav"
    
    echo ✅ Created !fname!.mp4
)

if %errorlevel% equ 0 (
    echo ✨ All scenes generated from file!
) else (
    echo ❌ Failed generated all video scene!
)
pause
goto MAIN_MENU

:MERGE_DIFF
cls
echo ========================================================
echo  MERGE VIDEO
echo ========================================================
echo  🎬 Detecting all video files in "%FOLDER%" folder...
echo.

set "OUT_FILE=%OUTPUT_DIR%\deep_final-%random%.mp4"

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
echo -------------------------
type file_list.txt
echo -------------------------
echo.

:: Ask to continue
set /p CONFIRM=Process these %COUNT% files? (Y/N): 
if /i not "!CONFIRM!"=="Y" exit /b

:: METHOD 1: Simple concat (no re-encoding, no fades)
echo.
echo Method 1: Attempting simple concatenation...
echo.

:: Create concat file for FFmpeg with full paths
set "CONCAT_FILE=%TEMP%\concat_list.txt"
if exist "%CONCAT_FILE%" del "%CONCAT_FILE%"

echo Creating FFmpeg concat file...
(for /f "usebackq delims=" %%i in ("file_list.txt") do (
    echo file '%cd%\%FOLDER%\%%i'
)) > "%CONCAT_FILE%"

:: Display the concat file content for debugging
echo Concat file content:
type "%CONCAT_FILE%"
echo.

:: Try simple concat first
ffmpeg -f concat -safe 0 -i "%CONCAT_FILE%" -c copy "%OUT_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Successfully merged %COUNT% files using simple concat
    goto :cleanup
) else (
    echo.
    echo Method 1 failed. Trying Method 2 with re-encoding...
    echo.
)

:: METHOD 2: Concat with re-encoding
echo Method 2: Concat with re-encoding...
echo.

:: Build command for concat with re-encoding
set "INPUT_FILES="
set "FILE_INDEX=0"

(for /f "usebackq delims=" %%i in ("file_list.txt") do (
    set "INPUT_FILES=!INPUT_FILES! -i "%FOLDER%\%%i""
    set /a FILE_INDEX+=1
))

:: Use concat filter for re-encoding
ffmpeg %INPUT_FILES% -filter_complex "concat=n=%COUNT%:v=1:a=1" -c:v libx264 -c:a aac "%OUT_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Successfully merged %COUNT% files with re-encoding
    goto :cleanup
) else (
    echo.
    echo Method 2 failed. Trying Method 3 with individual file processing...
    echo.
)

:: METHOD 3: Create a temporary file list and process one by one
echo Method 3: Individual file processing...
echo.

:: If output file exists, delete it
if exist "%OUT_FILE%" del "%OUT_FILE%"

set "FIRST_FILE=1"
(for /f "usebackq delims=" %%i in ("file_list.txt") do (
    if !FIRST_FILE! equ 1 (
        echo Copying first file: %%i
        copy "%FOLDER%\%%i" "%OUT_FILE%" >nul
        set "FIRST_FILE=0"
    ) else (
        echo Appending: %%i
        
        :: Create temporary concat for just these two files
        echo file '%OUT_FILE%' > "%TEMP%\temp_concat.txt"
        echo file '%FOLDER%\%%i' >> "%TEMP%\temp_concat.txt"
        
        :: Merge current output with next file
        ffmpeg -f concat -safe 0 -i "%TEMP%\temp_concat.txt" -c copy "%TEMP%\temp_output.mp4" -y
        
        if exist "%TEMP%\temp_output.mp4" (
            move /y "%TEMP%\temp_output.mp4" "%OUT_FILE%" >nul
        ) else (
            echo ❌ Failed to append %%i
        )
        
        del "%TEMP%\temp_concat.txt" 2>nul
    )
))

if %errorlevel% equ 0 (
    echo ✅ Successfully merged All scenes!

) else (
    echo ❌ Failed to create merged video
)
pause
goto MAIN_MENU

:MERGE_CONV
cls
echo ========================================================
echo  NERGE VIDEO + WAVEFORM
echo ========================================================
echo  🎬 Detecting all video files in "%FOLDER%" folder...
echo.

set "OUT_FILE=%OUTPUT_DIR%\conv_final-%random%.mp4"

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
echo -------------------------
type file_list.txt
echo -------------------------
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
set "OUTFILE=%TEMP%\temp_output.mp4"
ffmpeg -y %INPUTS% -filter_complex "concat=n=%COUNT%:v=1:a=1[v][a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac "%OUTFILE%"

::Get overlap
	for /f "tokens=*" %%i in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%OUTFILE%"') do (
    set "DUR=%%i"
)
	for /f "delims=." %%a in ("%DUR%") do set "DUR_INT=%%a"
	set /a overlap=%DUR_INT% - 2
	
ffmpeg -y -hide_banner -stream_loop -1 -i "%OUTFILE%" -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,fade=t=in:st=0:d=2,fade=t=out:st=%overlap%:d=2[bg_faded];[bg_faded]%LOGO_FILTER%[bg_txt];[0:a]channelsplit=channel_layout=stereo[l][r];[l]showwaves=s=960x%WAVE_HEIGHT%:colors=red:draw=full:mode=cline[l_wave];[r]showwaves=s=960x%WAVE_HEIGHT%:colors=green:draw=full:mode=line[r_raw];[r_raw]hflip[r_flipped];[l_wave][r_flipped]hstack[waves];[bg_txt]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];[bg_box]drawtext=fontfile='%FONT_TITLE%':text='ReadLoud FFmpeg Tutorial':fontcolor=white@0.9:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.4:shadowx=4:shadowy=4,drawtext=text='%track_filters%':fontfile='%FONT_SUB%':fontsize=%FONT_SIZE_SUB%:fontcolor=white@0.5:x=(w-text_w)/2:y=h-150:%SCROLL_X%[v_final];[v_final][waves]overlay=x=0:y=H-%WAVE_HEIGHT%[outv]" -map "[outv]" -map 0:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest "%OUT_FILE%"

if %errorlevel% equ 0 (
    echo ✅ Successfully merged All scenes!

) else (
    echo ❌ Failed to create merged video
)
pause
goto MAIN_MENU

:ARCHIVED
cls
echo [!] KILL PROCESS...
set "datestr=%date:~10,4%-%date:~4,2%-%date:~7,2%"
set "archive=%OUTPUT_DIR%\Archive_%datestr%"
if not exist "%archive%" mkdir "%archive%"
move "%OUTPUT_DIR%\*.mp4" "%archive%" >nul 2>&1
rmdir /s /q "%TEMP%" 2>nul
echo %archive% Goodbye!
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
timeout /t 3
endlocal
exit
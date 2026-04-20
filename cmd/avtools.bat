@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title READLOUD AUDIO VIDEO TOOLS - STABLE

set "MUSIC_DIR=%USERPROFILE%\Music"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"
set "OUTPUT_DIR=%VIDEOS_DIR%\Exports"
set "OUTPUT=%VIDEOS_DIR%\Exports\YT_Audio"
set "TEMP_DIR=%TEMP%\AV"

:: Create directories
for %%d in ("%OUTPUT_DIR%" "%OUTPUT%" "%TEMP_DIR%") do (if not exist "%%~d" mkdir "%%~d")

:: Default Settings
set "LOGO_TEXT=READLOUD"
set "FONT_LOGO=Buda.ttf"
set "RES=1280:720"

:AV_TOOLS
cls
echo.
echo ============================================
echo  AUDIO VIDEO TOOLS [STABLE]
echo ============================================
echo [1] Replace Audio   [8] Add Logo
echo [2] Mixing Audio    [9] Add Watermark
echo [3] Extract Audio   [10] Add Logo ^& Watermark
echo [4] Merge Audio     [11] Picture in picture
echo [5] Merge Video     [12] Side by side
echo [6] Mute Video      [13] Video Trim
echo [7] Remove Track    [14] Video Scale
echo [X] Change Logo Text (Current: %LOGO_TEXT%)
echo ============================================
set "mix="
set /p mix="Select[1-14][0]Cancel: "

if "%mix%"=="0" goto EXIT
if /i "%mix%"=="x" (set /p "LOGO_TEXT=Enter New Logo Text: " & goto AV_TOOLS)

:: Map choices to modes
if "%mix%"=="1" set "mix_mode=replace"
if "%mix%"=="2" set "mix_mode=mix"
if "%mix%"=="3" set "mix_mode=split"
if "%mix%"=="4" set "mix_mode=merge_au"
if "%mix%"=="5" set "mix_mode=merge_av"
if "%mix%"=="6" set "mix_mode=muted"
if "%mix%"=="7" set "mix_mode=remove"
if "%mix%"=="8" set "mix_mode=logo"
if "%mix%"=="9" set "mix_mode=watermark"
if "%mix%"=="10" set "mix_mode=logo_wm"
if "%mix%"=="11" set "mix_mode=p2p"
if "%mix%"=="12" set "mix_mode=mirror"
if "%mix%"=="13" set "mix_mode=trim"
if "%mix%"=="14" set "mix_mode=scale"

if not defined mix_mode (echo Invalid choice! & pause & goto AV_TOOLS)

:: --- PROCESSING LOGIC ---

if "!mix_mode!"=="replace" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    call :SHOW_MUSIC
    set /p m_sel="Select MP3: "
    for /l %%i in (1,1,!m!) do if "!m_sel!"=="%%i" (set "selected_mp3=!mp3_%%i!")
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest -y "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Replace Audio done! & pause & goto end
)

if "!mix_mode!"=="mix" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    call :SHOW_MUSIC
    set /p m_sel="Select MP3: "
    for /l %%i in (1,1,!m!) do if "!m_sel!"=="%%i" (set "selected_mp3=!mp3_%%i!")
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -filter_complex "[0:a][1:a]amix=inputs=2:duration=first" -c:v copy -c:a aac -y "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Mixing AV done! & pause & goto end
)

if "!mix_mode!"=="split" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    ffmpeg -i "!selected_video!" -vn -acodec libmp3lame -q:a 2 "%OUTPUT%\!mix_mode!_!filename!_%random%.mp3"
    echo ✅ Split AV done! & pause & goto end
)

if "!mix_mode!"=="merge_au" (
    call :SHOW_MUSIC
    (for %%i in ("%target_dir%\*.mp3" "%target_dir%\*.opus") do echo file '%%i') > "%TEMP_DIR%\audiolist.txt"
    ffmpeg -f concat -safe 0 -i "%TEMP_DIR%\audiolist.txt" -c copy "%OUTPUT%\merged_audio_%random%.mp3"
    echo ✅ Merge Audio done! & pause & goto end
)

if "!mix_mode!"=="merge_av" (
    call :SHOW_VIDEOS
    (for %%i in ("%target_dir%\*.mp4" "%target_dir%\*.mov") do echo file '%%i') > "%TEMP_DIR%\videolist.txt"
    ffmpeg -f concat -safe 0 -i "%TEMP_DIR%\videolist.txt" -c copy "%OUTPUT_DIR%\merged_video_%random%.mp4"
    echo ✅ Merge Video done! & pause & goto end
)

if "!mix_mode!"=="muted" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    ffmpeg -i "!selected_video!" -an -c:v copy "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Remove Audio done! & pause & goto end
)

if "!mix_mode!"=="remove" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    set /p "track=Track Number to Remove (0, 1, etc.): "
    ffmpeg -i "!selected_video!" -map 0 -map -0:a:!track! -c copy "%OUTPUT_DIR%\!filename!_!mix_mode!_!track!%random%.mp4"
    echo ✅ Remove Track done! & pause & goto end
)

if "!mix_mode!"=="logo" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    ffmpeg -y -i "!selected_video!" -vf "drawtext=text='%LOGO_TEXT%':fontcolor=white:fontsize=40:x=W-tw-60:y=60" -vcodec libx264 -preset fast "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Add Logo done! & pause & goto end
)

if "!mix_mode!"=="watermark" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    call :SHOW_PICTURES
    set /p p_sel="Select Image: "
    for /l %%i in (1,1,!p!) do if "!p_sel!"=="%%i" (set "selected_img=!img_%%i!")
    ffmpeg -i "!selected_video!" -i "!selected_img!" -filter_complex "[1:v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay=(W-w)/2:(H-h)/2" -vcodec libx264 -preset fast "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Add Watermark done! & pause & goto end
)

if "!mix_mode!"=="p2p" (
    call :SHOW_VIDEOS
    set /p v_sel="Select 1st Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video1=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    call :SHOW_VIDEOS
    set /p v_sel="Select 2nd Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video2=!video_%%i!")
    call :RES
    ffmpeg -y -i "!selected_video1!" -i "!selected_video2!" -filter_complex "[0:v]fps=30,scale=!RES!:force_original_aspect_ratio=increase,crop=!RES![bg];[1:v]scale=320:-1[pinp];[bg][pinp]overlay=x=W-w-20:y=H-h-20" -c:v libx264 -preset fast -c:a aac -shortest "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Picture in picture video done! & pause & goto end
)

if "!mix_mode!"=="trim" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    set "v_str=00:00:00"
    set /p v_str="Start from [hh:mm:ss] (Default 00:00:00): "
    set /p v_end="End to [hh:mm:ss]: "
    ffmpeg -ss !v_str! -to !v_end! -i "!selected_video!" -c copy "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Trim video done! & pause & goto end
)

if "!mix_mode!"=="scale" (
    call :SHOW_VIDEOS
    set /p v_sel="Select Video: "
    for /l %%i in (1,1,!v!) do if "!v_sel!"=="%%i" (set "selected_video=!video_%%i!" & for %%f in ("!video_%%i!") do set "filename=%%~nf")
    ffmpeg -i "!selected_video!" -vf "crop=ih*9/16:ih,scale=1080:1920" -c:v libx264 -crf 18 -preset fast -c:a copy "%OUTPUT_DIR%\!mix_mode!_!filename!_%random%.mp4"
    echo ✅ Scaling done! & pause & goto end
)
goto AV_TOOLS

:RES
cls
echo.
echo ============================================
echo   SELECT VIDEO RESOLUTION
echo ============================================
echo  [1] 1080p Portrait (1080x1920)
echo  [2] 1080p Landscape (1920x1080)
echo ============================================
set /p "r_sel=Choice [1-2]: "
if "%r_sel%"=="1" set "RES=1080:1920"
if "%r_sel%"=="2" set "RES=1920:1080"
if not defined RES set "RES=1280:720"
exit /b

:SHOW_VIDEOS
cls
echo ====================================================
echo  SELECT FOLDER
echo ====================================================

:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%VIDEOS_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)

echo.
set /p folder_choice="Select folder [R]oot): "

:: Determine the search path based on choice
if "%folder_choice%"=="r" (
    set "target_dir=%VIDEOS_DIR%"
) else (
    set "target_dir=!dir_%folder_choice%!"
)

cls
echo ====================================================
echo  VIDEOS IN: %target_dir%
echo ====================================================

:: 2. Scan only the chosen directory for files
set v=0
if exist "%target_dir%" (
    pushd "%target_dir%"
    :: We remove /R here if you only want files in that specific folder, 
    :: or keep it if you want that folder + its children.
    for %%f in (*.mp4 *.mkv *.avi *.mov *.wma) do (
        set /a v+=1
		set "video_!v!=%%~ff"
        echo [!v!] %%~nxf
    )
    popd
)

if %v%==0 echo No audio files found.
echo ====================================================
exit /b

:SHOW_MUSIC
cls
echo ====================================================
echo  SELECT FOLDER
echo ====================================================

:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%MUSIC_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)

echo.
set /p folder_choice="Select folder [R]oot): "

:: Determine the search path based on choice
if "%folder_choice%"=="r" (
    set "target_dir=%MUSIC_DIR%"
) else (
    set "target_dir=!dir_%folder_choice%!"
)

cls
echo ====================================================
echo  MUSIC IN: %target_dir%
echo ====================================================

:: 2. Scan only the chosen directory for files
set m=0
if exist "%target_dir%" (
    pushd "%target_dir%"
    :: We remove /R here if you only want files in that specific folder, 
    :: or keep it if you want that folder + its children.
    for %%f in (*.mp3 *.opus *.wav) do (
        set /a m+=1
		set "mp3_!m!=%%~ff"
        echo [!m!] %%~nxf
    )
    popd
)

if %m%==0 echo No audio files found.
echo ====================================================
exit /b

:SHOW_PICTURES
cls
echo ====================================================
echo  SELECT FOLDER
echo ====================================================

:: 1. List all directories
set d=0
:: Use /ad to list ONLY directories and avoid errors
for /d /r "%PICTURES_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)

echo.
set /p folder_choice="Select folder [R]oot): "

:: Determine the search path based on choice
if "%folder_choice%"=="r" (
    set "target_dir=%PICTURES_DIR%"
) else (
    set "target_dir=!dir_%folder_choice%!"
)

cls
echo ====================================================
echo  IMAGES IN: %target_dir%
echo ====================================================

:: 2. Scan for images
set p=0
if exist "%target_dir%" (
    pushd "%target_dir%"
    :: Searching for image formats
    for %%f in (*.jpg *.jpeg *.png *.jfif *.webp) do (
        set /a p+=1
        echo [!p!] %%~nxf
        set "img_!p!=%%~ff"
    )
    popd
)

if %p%==0 echo No images files found.
echo ====================================================
exit /b

:SHOW_OUTPUT
cls
echo ====================================================
echo  OUTPUT FOLDER
echo ====================================================
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
		set "output_!o!=%%f"
)
set o+=0
for %%f in ("%OUTPUT%\*.mp3") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
		set "output_!o!=%%f"
)
exit /b

:end
echo Process Complete.
echo 1. Process another
echo 2. Open output folder
set /p end_choice="Select: "
if "%end_choice%"=="2" explorer "%OUTPUT_DIR%"
goto AV_TOOLS

:EXIT
echo  Cleaning up temporary files...
rmdir /s /q "%TEMP_DIR%" 2>nul
echo  Goodbye!
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
timeout /t 3
endlocal
exit
rmdir /s /q "%TEMP_DIR%" 2>nul
exit
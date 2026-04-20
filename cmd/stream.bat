@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title READLOUD STREAM - STABLE

:: --- CONFIGURATION ---
set "MUSIC_DIR=%USERPROFILE%\Music"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%USERPROFILE%\Videos\Captures"
set "ASSETS_DIR=%~dp0assets"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

if not defined bgm set "bgm=%ASSETS_DIR%\trance.mp3" & set "SAFE_BGM=trance"

:MAIN_MENU
cls
echo.
echo ========================================================
echo  S T R E A M   L I B R A R Y
echo ========================================================
echo  [1] CAMCORDER
echo  [2] SCREEN CAPTURE
echo  [3] DUAL MODE
echo  [4] SIDE BY SIDE
echo  [5] PICTURE IN PICTURE
echo  [6] DEVICE TEST
echo ========================================================
set /p "main_choice=SYSTEM_INPUT [Q]UIT: "
if /i "%main_choice%"=="q" goto EXIT
if "%main_choice%"=="1" goto REC_CAM
if "%main_choice%"=="2" goto REC_SCREEN 
if "%main_choice%"=="3" goto DUAL_MODE
if "%main_choice%"=="4" goto SIDE_BY
if "%main_choice%"=="5" goto PIC_2PIC
if "%main_choice%"=="6" goto DEV_TEST
if "%main_choice%"=="7" goto SHOW_MUSIC
if "%main_choice%"=="" goto MAIN_MENU

:: --- [1] DETEKSI VIDEO ---
:DV
cls
echo.
echo [ SELECT VIDEO DEVICES ]
set v_count=0
for /f "tokens=2 delims=]" %%a in ('ffmpeg -list_devices true -f dshow -i dummy 2^>^&1 ^| findstr /C:"(video)"') do (
    set "line=%%a"
    for /f "tokens=* delims= " %%b in ("!line!") do set "clean=%%b"
    set "clean=!clean:"=!"
    set "clean=!clean: (video)=!"
    set /a v_count+=1
    set "v_!v_count!=!clean!"
    echo  [!v_count!] !clean!
)
if %v_count%==0 (echo [!] No video devices found. & pause & goto MAIN_MENU)

exit /b

:: --- [2] DETEKSI AUDIO ---
:AV
cls
echo.
echo [ SELECT AUDIO DEVICES ]
set a_count=0
for /f "tokens=2 delims=]" %%a in ('ffmpeg -list_devices true -f dshow -i dummy 2^>^&1 ^| findstr /C:"(audio)"') do (
    set "line=%%a"
    for /f "tokens=* delims= " %%b in ("!line!") do set "clean=%%b"
    set "clean=!clean:"=!"
    set "clean=!clean: (audio)=!"
    set /a a_count+=1
    set "a_!a_count!=!clean!"
    echo  [!a_count!] !clean!
)

if %a_count%==0 (echo [!] No audio devices found. & pause & goto MAIN_MENU)

exit /b

:GET_TS
:: Get and Escape Timestamp 
set "t_stamp=%time:~0,8%"
set "t_stamp=!t_stamp: =0!"
:: IMPORTANT: Escape the colons for FFmpeg (replace : with \:)
set "esc_stamp=!t_stamp::=\:!" 

set "ts=%time:~0,2%%time:~3,2%%time:~6,2%"
set "ts=!ts: =0!"
exit /b

:: --- [3] PILIH RESOLUSI ---
:RES
cls
echo.
echo ============================================
echo      SELECT VIDEO RESOLUTION
echo ============================================
echo  [1] 480p  (640x480)
echo  [2] 720p  (1280x720)
echo  [3] 1080p (1920x1080)
echo ============================================
set /p "r_sel=Pilih Resolusi [1-3][C]CANCEL: "
if /i "%r_sel%"=="c" goto MAIN_MENU
if "%r_sel%"=="1" set "RES=640x480"
if "%r_sel%"=="2" set "RES=1280x720"
if "%r_sel%"=="3" set "RES=1920x1080"
if not defined RES set "RES=1280x720"
exit /b

:: --- [4] PILIH FPS ---
:FPS
cls
echo.
echo ============================================
echo      SELECT FRAME RATE (FPS)
echo ============================================
echo  [1] 15 FPS
echo  [2] 30 FPS - Standard
echo  [3] 60 FPS - High
echo ============================================
set /p "f_sel=Pilih FPS [1-3]: "

if "%f_sel%"=="1" set "FPS=15"
if "%f_sel%"=="2" set "FPS=30"
if "%f_sel%"=="3" set "FPS=60"
if not defined FPS set "FPS=30"

:: --- [5] KONFIGURASI FILTER DRAWTEXT (LOGO & TIMER) ---
:: Menentukan parameter font (menggunakan Arial yang standar Windows)
:: Kita harus escape titik dua (:) pada path Windows menjadi 'C\\:/Windows/...' agar FFmpeg tidak error
set "FONT_PATH=arial.ttf"

:: PENTING: Sintaks COMPLEX FILTER untuk FFmpeg (Double Quote dan Variable Handling)
:: Bagian 1: Logo Teks di Pojok Kanan Atas
set "F_LOGO=drawtext=fontfile='%FONT_PATH%':text='RECORDING %COMPUTERNAME% @ %%{localtime\:%%Y-%%m-%%d}':fontcolor=white@0.8:fontsize=20:x=w-tw-20:y=20:box=1:boxcolor=black@0.4:boxborderw=5"

:: Bagian 2: Timer Otomatis (Waktu Rekaman) di Pojok Kanan Bawah
set "F_TIMER=drawtext=fontfile='%FONT_PATH%':text='RES %RES% @ %FPS% FPS %%{pts\:hms}':fontcolor=white@0.8:fontsize=20:x=w-tw-20:y=h-th-20:box=1:boxcolor=black@0.5:boxborderw=5"

:: Menggabungkan kedua filter dengan koma
set "V_FILTERS=%F_LOGO%,%F_TIMER%"
exit /b

:: --- [5] SINGLE MODE (CAMERA/WEBCAM) ---
:REC_CAM
cls
echo.
echo ============================================
echo      SELECT VIDEO ^& AUDIO DEVICES
echo ============================================
call :DV
set /p "v_sel=Select Video Device (1-%v_count%): "
if not defined v_!v_sel! (echo [!] Invalid selection. & pause & goto DV)
set "V_NAME=!v_%v_sel%!" (echo [!] Device selected.)

call :AV
set /p "a_sel=Select Audio Device (1-%a_count%): "
if not defined a_!a_sel! (echo [!] Invalid selection. & pause & goto AV)
set "A_NAME=!a_%a_sel%!" (echo [!] Device selected.)

call :RES
call :FPS
call :GET_TS
echo [!] START RECORDING...
:: Eksekusi dengan filter video kompleks. 
:: Gunakan tanda kutip ganda di luar dan kutip tunggal di dalam path font.
start "" /min ffmpeg -f dshow -i video="!V_NAME!":audio="!A_NAME!" -video_size %RES% -framerate %FPS% -vf "%V_FILTERS%" -vcodec libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p "%OUTPUT_DIR%\Camera_%ts%.mkv"

timeout /t 3 >nul

goto MONITOR

:: --- [5] SINGLE MODE (SCREEN CAPTURE) ---
:REC_SCREEN
cls
echo.
echo ============================================
echo  CHOOSE MODE [Current: %SAFE_BGM%]
echo ============================================
echo [1] Select BGM 
echo [2] Default BGM 
echo [3] Voice Mode
echo [4] Silent Mode
echo ============================================
echo.
set /p "ss_choice=CHOOSE MODE [C]ancle: "
if /i "%ss_choice%"=="c" goto MAIN_MENU
if "%ss_choice%"=="1" goto SHOW_MUSIC
if "%ss_choice%"=="2" goto BGM_MODE 
if "%ss_choice%"=="3" goto VOICE_MODE
if "%ss_choice%"=="4" goto SILENT_MODE

:BGM_MODE
set "FPS=30"
set "RES=N/A"
set "V_NAME=N/A"
set "A_NAME=N/A"
call :GET_TS
echo [!] START CAPTURING...
start "BGM_MODE" /min ffmpeg -f gdigrab -framerate %FPS% -i desktop -i "%bgm%" -c:v libx264 -preset ultrafast -c:a aac -map 0:v -map 1:a -crf 28 -pix_fmt yuv420p -shortest "%OUTPUT_DIR%\Capture_%ts%.mkv"

timeout /t 5 >nul

goto MONITOR

:VOICE_MODE
set "FPS=30"
set "RES=N/A"
set "V_NAME=N/A"
set "A_NAME=Microphone (Synaptics SmartAudio HD)"
call :GET_TS
echo [!] START CAPTURING...
start "VOICE_MODE" /min ffmpeg -f gdigrab -framerate %FPS% -i desktop -f dshow -i audio="Microphone (Synaptics SmartAudio HD)" -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac "%OUTPUT_DIR%\Capture_%ts%.mkv"

timeout /t 5 >nul

goto MONITOR

:SILENT_MODE
set "FPS=30"
set "RES=N/A"
set "V_NAME=N/A"
set "A_NAME=N/A"
call :GET_TS
echo [!] START CAPTURING...
start "SILENT_MODE" /min ffmpeg -f gdigrab -framerate %FPS% -i desktop -c:v libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p "%OUTPUT_DIR%\Capture_%ts%.mkv"

timeout /t 5 >nul

goto MONITOR

:: --- [6] DUAL MODE (CAMERA+SCREEN) ---
:DUAL_MODE
cls
call :DV
set /p "v_sel=Select Video: "
call :AV
set /p "a_sel=Select Audio: "
set "V_NAME=!v_%v_sel%!"
set "A_NAME=!a_%a_sel%!"
call :RES
call :FPS
call :GET_TS
echo [!] START RECORDING...
start "" /min ffmpeg -f dshow -i video="!V_NAME!":audio="!A_NAME!" -video_size %RES% -framerate %FPS% -vcodec libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p "%OUTPUT_DIR%\Camera_%ts%.mkv"
timeout /t 3 >nul
start "" /min ffmpeg -f gdigrab -framerate %FPS% -i desktop -vf "%V_FILTERS%" -c:v libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p "%OUTPUT_DIR%\Capture_%ts%.mkv"

goto MONITOR & goto PIC_2PIC

:: --- [7] SAVE KILL ---
:MONITOR
cls
echo.
echo ========================================================
echo             R E C O R D I N G   A C T I V E
echo ========================================================
echo  Status    : Running...
echo  Camera    : !V_NAME!
echo  Audio     : !A_NAME!
echo  Specs     : %RES% @ %FPS% FPS
echo  Output    : %OUTPUT_DIR% 
echo.
echo  PRESS ANY KEY TO STOP AND SAVED
echo ========================================================
pause >nul

echo [!] Stopping FFmpeg...
powershell -command "Get-Process ffmpeg -ErrorAction SilentlyContinue | Stop-Process"
pause & goto end
exit /b

:: --- [8] FAST-MERGE ---
:SIDE_BY
cls
echo.
:: 1. Find the latest files
for /f "delims=" %%i in ('dir "%OUTPUT_DIR%\Capture_*.mkv" /b /a-d /od 2^>nul') do set "ls=%%i"
for /f "delims=" %%i in ('dir "%OUTPUT_DIR%\Camera_*.mkv" /b /a-d /od 2^>nul') do set "lc=%%i"

:: 2. Validation
if "!ls!"=="" (echo ERROR: No Capture_*.mkv found. & pause & goto MAIN_MENU)
if "!lc!"=="" (echo ERROR: No Cameracorder_*.mkv found. & pause & goto MAIN_MENU)

echo [SILENT_MERGE]
echo Processing: !ls! + !lc! 
call :GET_TS

:: 4. Execution with escaped timestamp 
:: Execution with "Force Even" width logic
ffmpeg -i "%OUTPUT_DIR%\!ls!" -i "%OUTPUT_DIR%\!lc!" -filter_complex "[0:v]scale=trunc(oh*a/2)*2:720[cam];[1:v]scale=trunc(oh*a/2)*2:720[scr];[cam][scr]hstack=inputs=2" -c:v libx264 -preset ultrafast -crf 23 -pix_fmt yuv420p "%OUTPUT_DIR%\Record-SBS_%ts%.mov"

pause & goto end

:: --- [9] PICTURE IN PICTURES VIDEO MODE---
:PIC_2PIC
cls
echo.
:: 1. Find the latest files
for /f "delims=" %%i in ('dir "%OUTPUT_DIR%\Capture_*.mkv" /b /a-d /od 2^>nul') do set "ls=%%i"
for /f "delims=" %%i in ('dir "%OUTPUT_DIR%\Camera_*.mkv" /b /a-d /od 2^>nul') do set "lc=%%i"

:: 2. Validation
if "!ls!"=="" (echo ERROR: No Capture_*.mkv found. & pause & goto MAIN_MENU)
if "!lc!"=="" (echo ERROR: No Camera_*.mkv found. & pause & goto MAIN_MENU)

echo [SILENT_MERGE]
echo Processing: !ls! + !lc! 
call :GET_TS

:: 4. Execution with escaped timestamp 
:: Execution with "Force Even" width logic
ffmpeg -i "%OUTPUT_DIR%\!ls!" -i "%OUTPUT_DIR%\!lc!" -filter_complex  "[0:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[bg];[1:v]scale=640/2:-1[pinp];[bg][pinp]overlay=x=W-w-20:y=H-h-20" -vcodec libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p "%OUTPUT_DIR%\Record-P2P_%ts%.mov"

pause & goto end

:: --- [10] TROUBLESHOOT ---
:DEV_TEST
cls
echo.
call :DV
set /p "v_sel=Select Video: "
call :AV
set /p "a_sel=Select Audio: "
set "V_NAME=!v_%v_sel%!"
set "A_NAME=!a_%a_sel%!"

ffplay -f dshow -i video="!V_NAME!":audio="!A_NAME!"

goto MAIN_MENU

:: --- [11] VIDEO PREVIEW ---
:PREVIEW_VIDEOS
cls
set v=0
for /R "%OUTPUT_DIR%" %%f in (*.mp4 *.mkv *.mov *.avi) do (set /a v+=1 & set "video_!v!=%%f" & echo [!v!] %%~nxf)
set /p "sel=Select Number [e]xit: "
if /i "%sel%"=="e" goto MAIN_MENU
if defined video_%sel% (start "" /min ffplay -autoexit -noborder "!video_%sel%!" & goto PREVIEW_VIDEOS)
exit /b

:: --- [12] VIDEO GLITCH PREVIEW ---
:GLITCH_PREVIEW
cls
set v=0
for /R "%OUTPUT_DIR%" %%f in (*.mp4 *.mkv *.mov *.avi) do (set /a v+=1 & set "video_!v!=%%f" & echo [!v!] %%~nxf)
set /p "gnum=Select Number: "
if "%gnum%"=="" goto MAIN_MENU
if defined video_%gnum% (
ffplay -autoexit -window_title "GLITCH_VIEW" -i "!video_%gnum%!" -vf "noise=alls=20:allf=t+u, rgbashift=rh=4, setdar=16/9" & goto GLITCH_PREVIEW)
exit /b

:: --- [13] SHARED ---
:SHOW_MUSIC
cls
echo ====================================================
echo  SELECT A FOLDER
echo ====================================================

:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%MUSIC_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)

echo.
set /p folder_choice="Select a folder (or press Enter to continue): "

:: Determine the search path based on choice
if "%folder_choice%"=="" (
    set "target_dir="
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

if %m%==0 echo No audio files found in this selection.
echo ====================================================
set /p m_sel="Select BGM : "
for /l %%i in (1,1,!m!) do if "!m_sel!"=="%%i" (set "selected_mp3=!mp3_%%i!")
set "bgm=!selected_mp3!"
for %%f in ("!mp3_%%i!") do set "filename=%%~nf")
for %%f in ("!selected_mp3!") do set "SAFE_BGM=%%~nf" & goto BGM_MODE
exit /b

:end
cls
echo.
echo ==========================================
echo ✅ Reording saved to:
echo 📁 %OUTPUT_DIR%
echo ==========================================
echo 1. Process another video
echo 2. Open output folder
echo 3. Exit
set /p end_choice="Select (1-3): "

if "!end_choice!"=="1" (
    goto :MAIN_MENU
) else if "!end_choice!"=="2" (
    explorer "%OUTPUT_DIR%"
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
) else if "!end_choice!"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :EXIT
)
exit b/0

:: --- [14] SAVED EXIT ---
:EXIT
cls
echo.
echo ----------------------------------------
set o=0
for %%f in ("%OUTPUT_DIR%\*.mkv") do set /a o+=1
echo Output   : %o% files to archived
echo ----------------------------------------
echo.
echo Archiving ^& Cleaning up temporary files...
echo.
set "datestr=%date:~10,4%-%date:~4,2%-%date:~7,2%"
set "archive=%OUTPUT_DIR%\Archive_%datestr%"
if not exist "%archive%" mkdir "%archive%"
move "%OUTPUT_DIR%\*.mkv" "%archive%" >nul 2>&1
echo Goodbye!
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
timeout /t 3
endlocal
exit
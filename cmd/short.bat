@echo off
setlocal enabledelayedexpansion
set "MUSIC_DIR=%USERPROFILE%\Music"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "DOCUMENTS_DIR=%USERPROFILE%\Documents"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"
set "OUTPUT_DIR=%USERPROFILE%\Videos\YT_Converter\Short"
set "TEMP_DIR=%TEMP%"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:INIT
cls
:: --- KONFIGURASI ---
echo Configure...
set "IMG_DUR="
set "TRANS_DUR=1"
set "BGM_DUR="
set "title="
set "INPUT_FILES="
set "target_dir="
set "num_img="
timeout /t 3
cls
echo [STEP 1] Menyiapkan Gambar ^& Musik...
call :SHOW_PICTURES
set /p "IMG_DUR=Enter duration: "
for /f "delims=" %%g in ('dir /b "%target_dir%\*.jpg" "%target_dir%\*.jpeg" "%target_dir%\*.jfif" "%target_dir%\*.webp" "%target_dir%\*.png" 2^>nul') do (
    if !num_img! LSS 20 (
        :: Building the FFmpeg input string
        set "INPUT_FILES=!INPUT_FILES! -loop 1 -t %IMG_DUR% -i "%target_dir%\%%g""
        set /a num_img+=1
    )
)

call :RES
call :SHOW_MUSIC
set /p m_sel="Select BGM: "
set "selected_mp3="
for /l %%i in (1,1,!m!) do if "%m_sel%"=="%%i" (
    set "selected_mp3=!mp3_%%i!"
    for %%f in ("!mp3_%%i!") do set "filename=%%~nf")
    set "MUSIC_INPUT=!selected_mp3!"
set /p "BGM_DUR=Enter BGM duration: "

set "title="
set /p "title=Enter title [e]xit: "

:: To verify the output:
echo Total images found: %num_img%
echo First 100 chars of command: !INPUT_FILES:~0,100!...

echo Musik	 : %filename%
echo Gambar	 : %num_img%
echo Resolusi: %RES%

echo.
echo [STEP 2] Menyiapkan Audio...
ffmpeg -y -i "!selected_mp3!" -t %BGM_DUR% -c:a aac -b:a 192k temp_music.m4a

echo.
echo [STEP 3] Memproses Video (Filter Complex)...
set "OUTPUT=%OUTPUT_DIR%\reels_%filename%-%random%.mp4"

set "SCALER="
set /a end_idx=%num_img% - 1

:: Bagian ini penting: Menyamakan Timebase agar durasi tidak hilang
for /L %%i in (0,1,%end_idx%) do (
    set "SCALER=!SCALER![%%i:v]scale=%RES%:force_original_aspect_ratio=increase,crop=%RES%,setsar=1,settb=AVTB,setpts=PTS-STARTPTS[v%%i];"
)

set "XFADE="
set "LAST_OUT=[v0]"
set /a overlap_step=%IMG_DUR% - %TRANS_DUR%

for /L %%i in (1,1,%end_idx%) do (
    set /a "offset=%%i * overlap_step"
    
    if %%i==%end_idx% (
        set "XFADE=!XFADE!!LAST_OUT![v%%i]xfade=transition=fade:duration=%TRANS_DUR%:offset=!offset!,drawtext=fontfile='arial':text='%title%':fontcolor=white:fontsize=30:x=(w-tw)/2:y=150:box=1:boxcolor=#000000@0.4:boxborderw=15:x=w-mod(100*t\,w+tw+50):y=h-text_h-30,format=yuv420p[vfinal]"
    ) else (
        set "XFADE=!XFADE!!LAST_OUT![v%%i]xfade=transition=fade:duration=%TRANS_DUR%:offset=!offset![vtrans%%i];"
        set "LAST_OUT=[vtrans%%i]"
    )
)

ffmpeg -y %INPUT_FILES% -i temp_music.m4a -filter_complex "%SCALER%%XFADE%" ^
-map "[vfinal]" -map %num_img%:a -c:v libx264 -r 30 -pix_fmt yuv420p -c:a aac -preset fast -shortest "%OUTPUT%"

del temp_music.m4a
goto end

:SHOW_PICTURES
cls
echo ====================================================
echo  SELECT IMAGE IN PICTURES FOLDER
echo ====================================================
:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%PICTURES_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)
echo ====================================================
echo  SELECT IMAGE IN DOCUMENTS FOLDER
echo ====================================================
set d+=0
for /d /r "%DOCUMENTS_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)
echo ====================================================
echo  SELECT IMAGE IN DOWNLOADS FOLDER
echo ====================================================
set d+=0
for /d /r "%DOWNLOADS_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)
echo.
set /p folder_choice="Select folder (Enter for root)[q]uit: "
if /i "%folder_choice%"=="q" goto EXIT

:: Determine the search path based on choice
if "%folder_choice%"=="" (
    set "target_dir=%PICTURES_DIR%"
) else (
    set "target_dir=!dir_%folder_choice%!"
)
cls
echo ====================================================
echo  IMAGES IN: %target_dir%
echo ====================================================

:: 2. Scan only the chosen directory for files
set p=0
if exist "%target_dir%" (
    pushd "%target_dir%"
    :: We remove /R here if you only want files in that specific folder, 
    :: or keep it if you want that folder + its children.
    for %%f in (*.jpg *.jpeg *.png *.jfif *.webp) do (
        set /a p+=1
        set "img_!p!=%%~ff"
		echo [!p!] %%~nxf
        )
    popd
)

if %p%==0 echo No audio files found in this selection.
echo ====================================================
exit /b

:SHOW_MUSIC
cls
echo ====================================================
echo  SELECT MUSIC IN MUSIC FOLDER
echo ====================================================

:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%MUSIC_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)
echo ====================================================
echo  SELECT MUSIC IN DOWNLOADS FOLDER
echo ====================================================
set d+=0
for /d /r "%DOWNLOADS_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)
echo.
set /p folder_choice="Select folder (Enter for root)[c]ancel: "
if /i "%folder_choice%"=="c" goto INIT

:: Determine the search path based on choice
if "%folder_choice%"=="" (
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
        echo [!m!] %%~nxf
        set "mp3_!m!=%%~ff"
    )
    popd
)

if %m%==0 echo No audio files found in this selection.
echo ====================================================
exit /b

:RES
cls
echo.
echo ============================================
echo      SELECT VIDEO RESOLUTION
echo ============================================
echo  [1] 480p (640x480) - Low
echo  [2] 720p (1280x720) - Recomended
echo  [3] 920p (1920x1080) - High
echo  [4] 920p (Portrait) - Unresponsive
echo ============================================
set /p "r_sel=Pilih Resolusi [1-3][c]ancle: "
if /i "%r_sel%"=="c" goto INIT
if "%r_sel%"=="1" set "RES=640:480"
if "%r_sel%"=="2" set "RES=1280:720"
if "%r_sel%"=="3" set "RES=1920:1080"
if "%r_sel%"=="4" set "RES=1080:1920"
if not defined RES set "RES=1280:720"
exit /b

:SHOW_OUTPUT
cls
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
		set "output_!o!=%%f"
)
exit /b

:end
echo ==========================================
echo ✅ All videos rendered!
echo 📁 Check the output folder: %OUTPUT_DIR%
echo ==========================================
echo.
echo 1. Process another video
echo 2. Open output folder
echo 3. Exit
set /p end_choice="Select (1-3): "

if "!end_choice!"=="1" (
    goto :INIT
) else if "!end_choice!"=="2" (
    explorer "%OUTPUT_DIR%"
    timeout /t 2 /nobreak >nul
    goto :INIT
) else if "!end_choice!"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :EXIT
)
exit b/0

:EXIT
cls
echo.
echo ----------------------------------------
echo         SYSTEM INFORMATION
echo ----------------------------------------
echo Music    : %MUSIC_DIR%
echo Pictures : %PICTURES_DIR%
echo Videos   : %VIDEOS_DIR%
echo Output   : %OUTPUT_DIR%
echo.
echo [FOLDER STATUS]
echo ----------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3" "%MUSIC_DIR%\*.opus" "%MUSIC_DIR%\*.wav") do set /a m+=1
echo Music    : %m% audio files
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.jfif" "%PICTURES_DIR%\*.png" "%PICTURES_DIR%\*.webp") do set /a p+=1
echo Pictures : %p% image files
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do set /a v+=1
echo Videos   : %v% video files
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do set /a o+=1
echo Output   : %o% output files
echo.
echo ---------------------------------------------
echo [INFO] Your MP3, Image, Video files are SAFE
echo [INFO] All original files remain untouched
echo ---------------------------------------------
echo.
echo Clean up temporary files...
rmdir /s /q "%TEMP_DIR%" 2>nul
echo Goodbye!
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
timeout /t 3
endlocal
exit
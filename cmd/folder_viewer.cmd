@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title READLOUD VISUALIZER - STABLE

set "MUSIC_DIR=%USERPROFILE%\Music"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"

:SHOW_VIDEOSD
cls
echo ====================================================
echo  VIDEOS FOLDER - DEFAULT
echo ====================================================
set v=0
:: Loop through each main directory
for %%d in ("%VIDEOS_DIR%") do (
    if exist "%%~d" (
        pushd "%%~d"
        :: /R perform a recursive search through all subdirectories
        for /R %%f in (*.mp4 *.avi *.mkv *.mov *.wmv *.3gp) do (
            set /a v+=1
            echo [!v!] %%~nxf
            set "video_!v!=%%f"
        )
        popd
    )
)

if %v%==0 echo No video files found in any subfolders.
echo ====================================================
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

:SHOW_MUSICD
cls
echo ====================================================
echo  MUSIC FOLDER - DEFAULT
echo ====================================================
set m=0
for %%a in ("%MUSIC_DIR%") do (
    if exist "%%~a" (
        pushd "%%~a"
        :: /R perform a recursive search through all subdirectories
        for /R %%f in (*.mp3 *.opus *.wav) do (
            set /a m+=1
            echo [!m!] %%~nxf
            set "mp3_!m!=%%f"
         )
        popd
    )
)

if %m%==0 echo No audio files found in any subfolders.
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

:ARCHIVED
cls
echo [!] KILL PROCESS...
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
set "datestr=%date:~10,4%-%date:~4,2%-%date:~7,2%"
set "archive=%OUTPUT_DIR%\Archive_%datestr%"
if not exist "%archive%" mkdir "%archive%"
move "%OUTPUT_DIR%\*.mp4" "%archive%" >nul 2>&1
set "archive=%OUTPUT%\Archive_%datestr%"
if not exist "%archive%" mkdir "%archive%"
move "%OUTPUT%\*.mp3" "%archive%" >nul 2>&1
rmdir /s /q "%TEMP_DIR%" 2>nul
echo %archive% Goodbye!
timeout /t 3
exit /b

:PREVIEW_VIDEOS
cls
set v=0
for /R "%OUTPUT_DIR%" %%f in (*.mp4 *.mkv *.mov *.avi) do (set /a v+=1 & set "video_!v!=%%f" & echo [!v!] %%~nxf)
set /p "sel=Select Number [e]xit: "
if /i "%sel%"=="e" goto MAIN_MENU
if defined video_%sel% (start "" /min ffplay -autoexit -noborder "!video_%sel%!" & goto PREVIEW_VIDEOS)
exit /b

:GLITCH_PREVIEW
cls
set v=0
for /R "%OUTPUT_DIR%" %%f in (*.mp4 *.mkv *.mov *.avi) do (set /a v+=1 & set "video_!v!=%%f" & echo [!v!] %%~nxf)
set /p "gnum=Select Number: "
if "%gnum%"=="" goto MAIN_MENU
if defined video_%gnum% (
ffplay -autoexit -window_title "GLITCH_VIEW" -i "!video_%gnum%!" -vf "noise=alls=20:allf=t+u, rgbashift=rh=4, setdar=16/9" & goto GLITCH_PREVIEW)
exit /b

:CREATE_SHORTCUT
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\Tutorial.lnk"
if not exist "%SHORTCUT_PATH%" (
    echo [!] DESKTOP SHORTCUT NOT FOUND. 
    set /p "inst=Create Desktop Shortcut? (Y/N): "
    if /i "!inst!"=="y" (
        powershell -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT_PATH%');$s.TargetPath='%~f0';$s.IconLocation='cmd.exe';$s.Save()"
        echo [!] SHORTCUT CREATED ON DESKTOP.
        timeout /t 2 >nul
    )
)
echo [!] RESTARTING...
timeout /t 3
goto MAIN_MENU

:end
cls
echo.
echo ====================================================
echo  ✅ Rendered done success!
echo ====================================================
echo  [1] Open output folder
echo ----------------------------------------------------
set /p end_choice="Enter [M]enu: "

if "!end_choice!"=="m" (
    goto :MAIN_MENU
) else if "!end_choice!"=="1" (
    explorer "%OUTPUT_DIR%"
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
)
exit b/0

:EXIT
cls
echo.
echo ----------------------------------------------------
echo  SYSTEM INFORMATION
echo ----------------------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3" "%MUSIC_DIR%\*.opus" "%MUSIC_DIR%\*.wav") do set /a m+=1
echo Music    : %m% exist audio files
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.jfif" "%PICTURES_DIR%\*.png" "%PICTURES_DIR%\*.webp") do set /a p+=1
echo Pictures : %p% exist image files
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do set /a v+=1
echo Videos   : %v% exist video files
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do set /a o+=1
echo Output   : %o% output videos
set o=0
for %%f in ("%OUTPUT%\*.mp3") do set /a o+=1
echo Output   : %o% output audio
echo.
echo ----------------------------------------------------
echo  [INFO] Your MP3, Image, Video files are SAFE
echo  [INFO] All original files remain untouched
echo ----------------------------------------------------
echo.
echo  Cleaning up temporary files...
rmdir /s /q "%TEMP_DIR%" 2>nul
echo  Goodbye!
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffmpeg.exe >nul 2>&1
timeout /t 3
endlocal
exit
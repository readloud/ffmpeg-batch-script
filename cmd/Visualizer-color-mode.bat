@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

::Check tools
where ffmpeg >nul 2>nul || echo [WARNING] FFmpeg not installed!
where yt-dlp >nul 2>nul || echo [WARNING] yt-dlp not installed!
timeout /t 2 >nul

set "MUSIC_DIR=%USERPROFILE%\Music"
set "AU_DIR=%USERPROFILE%\Music\YT_Audio"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter"
set "TEMP_DIR=%TEMP%\YT_Converter"
set "ASSETS_DIR=assets"

for %%d in ("%OUTPUT_DIR%" "%TEMP_DIR%" "%ASSETS_DIR%" "%AU_DIR%") do (if not exist "%%~d" mkdir "%%~d")

:: Default Settings
set "LOGO_TEXT=READLOUD"
set "LOGO_MODE=RAINBOW"
set "C_COLOR=white@0.9"
set "MAIN_TITLE=ReadLoud Music Compilation"
set "FONT_TITLE=Ritual of the Witch.ttf"
set "FONT_LOGO=Buda.ttf"
set "FONT_SUB=StainStreet.otf"

if not defined input_bg set "selected_bg=-f lavfi -i smptebars=s=%WIDTH%x%HEIGHT%:r=30"

:MAIN_MENU
cls
echo ========================================
echo     YOUTUBE DOWNLOADER CONVERTER PRO
echo ========================================
echo [1] Download Audio MP3
echo [2] Download + Convert (Custom Color)
echo [3] Convert Existing MP3
echo [4] Background Setting (Current: %input_bg%)
echo [L] Logo Text Settings (Current: %LOGO_MODE%)
echo [0] Exit
echo ----------------------------------------
set /p choice="Select menu: "

if /i "%choice%"=="L" goto LOGO_SETTINGS
if "%choice%"=="1" goto DOWNLOAD_AUDIO
if "%choice%"=="2" goto DOWNLOAD_WAVEFORM
if "%choice%"=="3" goto CONVERT_WAVEFORM
if "%choice%"=="4" goto CHANGE_BACKGROUND
if "%choice%"=="0" goto EXIT
goto MAIN_MENU

:LOGO_SETTINGS
cls
echo ========================================
echo         LOGO TEXT SETTINGS
echo ========================================
echo [1] Change Text (Current: %LOGO_TEXT%)
echo [2] Change Text (Current: %MAIN_TITLE%)
echo [3] Set Mode: GLOW (White with soft shadow)
echo [4] Set Mode: RAINBOW (Colors cycle over time)
echo [0] Back
echo ----------------------------------------
echo BG: %input_bg% ^| Logo Mode: %LOGO_MODE%
echo ----------------------------------------
echo.
set /p l_choice="Choice (0-3): "
if "%l_choice%"=="1" set /p "LOGO_TEXT=Enter New Logo Text: " & goto LOGO_SETTINGS
if "%l_choice%"=="2" set /p "MAIN_TITLE=Enter New Main Title: " & goto LOGO_SETTINGS
if "%l_choice%"=="3" set "LOGO_MODE=GLOW"
if "%l_choice%"=="4" set "LOGO_MODE=RAINBOW"
goto MAIN_MENU

:PICK_COLOR
cls
echo.
echo ===============================================
echo         COLOR SETTINGS (Color)
echo ===============================================
echo Select Wave Color:
echo [1] Aquamarine		[11] Neon Pink
echo [2] Blue		[12] Neon Purple
echo [3] Cyan		[13] Neon Red   
echo [4] Deep Azure Blue	[14] Electric Yellow 
echo [5] Deep Sky Blue	[15] Silver  
echo [6] Electric Cyan	[16] Spring
echo [7] Emerald Green	[17] Spring Green
echo [8] Ice White/Blue	[18] Gold
echo [9] Neon Blue		[19] Goldenrod
echo [10] Neon Green		[20] Orange
echo [0] Default
echo ------------------------------------------
echo BG: %input_bg% ^| AU: !selected_mp3!
echo ------------------------------------------
set /p c_choice="Choice (0-20): "
if "%c_choice%"=="0" set "C_COLOR=white@0.9"
if "%c_choice%"=="1" set "C_COLOR=#7fffd4@0.9"
if "%c_choice%"=="2" set "C_COLOR=#4666FF@0.9"
if "%c_choice%"=="3" set "C_COLOR=#00CCFF@0.9"
if "%c_choice%"=="4" set "C_COLOR=#007FFF@0.9"
if "%c_choice%"=="5" set "C_COLOR=#00bfff@0.9"
if "%c_choice%"=="6" set "C_COLOR=#00ffff@0.9"
if "%c_choice%"=="7" set "C_COLOR=#50C878@0.9"
if "%c_choice%"=="8" set "C_COLOR=#f0f8ff@0.9"
if "%c_choice%"=="9" set "C_COLOR=#15F4EE@0.9"
if "%c_choice%"=="10" set "C_COLOR=#29FF14@0.9"
if "%c_choice%"=="11" set "C_COLOR=#ff00ff@0.9"
if "%c_choice%"=="12" set "C_COLOR=#BC13FE@0.9"
if "%c_choice%"=="13" set "C_COLOR=#FF073A@0.9"
if "%c_choice%"=="14" set "C_COLOR=#FFF01F@0.9"
if "%c_choice%"=="15" set "C_COLOR=#B0B0B0@0.9"
if "%c_choice%"=="16" set "C_COLOR=#00FF7F@0.9"
if "%c_choice%"=="17" set "C_COLOR=#00ff7f@0.9"
if "%c_choice%"=="18" set "C_COLOR=#FFD700@0.9"
if "%c_choice%"=="19" set "C_COLOR=#daa520@0.9"
if "%c_choice%"=="20" set "C_COLOR=#FF4500@0.9"
exit /b

:PLATFORM
cls
echo ==========================================
echo 1. YouTube (1920x1080)
echo 2. TikTok/Shorts (1080x1920)
echo 3. Exit
echo ==========================================
set /p choice="Select Format (1-3): "
if "%choice%"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
)

if "%choice%"=="1" (
    set "FORMAT=YT"
    set "WIDTH=1920"
    set "HEIGHT=1080"
    set "WAVE_HEIGHT=100"
    set "FONT_SIZE_TITLE=48"
    set "FONT_SIZE_SUB=38"
) else if "%choice%"=="2" (
    set "FORMAT=Shorts"
    set "WIDTH=1080"
    set "HEIGHT=1920"
    set "WAVE_HEIGHT=100"
    set "FONT_SIZE_TITLE=48"
    set "FONT_SIZE_SUB=38"
) else (
    goto PLATFORM
)
exit /b

:WAVESTYLE
cls
echo ========================================
echo           WAVESTYLE SETTINGS
echo ========================================
echo [1] Circular (Centered)
echo [2] Circular (Complex)
echo [3] Rotating (Centered)
echo [4] Rotating (Complex)
echo [0] Cancel
echo ==========================================
set /p ws_sel="Select Style: "
if "%ws_sel%"=="1" (
	:: Center-aligned Circular Wave
    set "WAVE_LOGIC=[1:a]aformat=cl=mono,showwaves=s=600x600:mode=cline:colors=%C_COLOR%,format=rgba,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[waves];"
    set "W_POS=x=(W-w)/2:y=(H-h)/2-100"
) else if "%ws_sel%"=="2" (
	:: Center-aligned Complex Circular Wave
	set "WAVE_LOGIC=[1:a]aformat=cl=mono,showwaves=600x600:cline:colors=%C_COLOR%:draw=full,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[waves];"
	set "W_POS=(W-w)/2:(H-h)/2"
) else if "%ws_sel%"=="3" (
    :: Center-aligned Rotating Wave
    set "WAVE_LOGIC=[1:a]showwaves=s=600x600:colors=%C_COLOR%:mode=line,format=rgba,rotate=a=2*PI*t/10:c=black@0.5[waves];"
    set "W_POS=x=(W-w)/2:y=(H-h)/2-100"
) else if "%ws_sel%"=="4" (
	:: Center-aligned Complex Rotating Wave
	set "WAVE_LOGIC=[1:a]aformat=channel_layouts=mono,showwaves=s=600x600:colors=%C_COLOR%:scale=sqrt:mode=p2p,format=yuva420p[waves]; [waves]geq=r='if(lte(sqrt((X-300)^2+(Y-300)^2),300),r(X,Y),0)':g='if(lte(sqrt((X-300)^2+(Y-300)^2),300),g(X,Y),0)':b='if(lte(sqrt((X-300)^2+(Y-300)^2),300),b(X,Y),0)':a='if(lte(sqrt((X-300)^2+(Y-300)^2),300),255,0)',rotate=angle=2*PI*t/8[waves];"
	set "W_POS=(W-w)/2:(H-h)/2"
) else (
    goto MAIN_MENU
)
exit /b

:CREATE_WAVEFORM
set "input_mp3=%~1"
set "input_bg=%~2"
set "outfile=%~3"

:: Background Source (Default to SMPTE)
if "%input_bg%"=="" set "input_bg=SMPTE"
if /i "%input_bg%"=="SMPTE" (
    set "BG_SRC=-f lavfi -i smptebars=s=%WIDTH%x%HEIGHT%:r=30"
) else (
    set "BG_SRC=-f lavfi -i "%input_bg%""
)

:: Logo Filter
if "%LOGO_MODE%"=="RAINBOW" (
    set "LOGO_FILTER=drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white:fontsize=45:x=W-tw-60:y=60:shadowcolor=black@0.5:shadowx=2:shadowy=2,hue=h=t*100"
) else (
    set "LOGO_FILTER=drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white@0.3:fontsize=48:x=W-tw-58:y=58,drawtext=fontfile='%FONT_LOGO%':text='%LOGO_TEXT%':fontcolor=white:fontsize=45:x=W-tw-60:y=60"
)

echo [PROCESS] Rendering Pulsing Video...
if "%FORMAT%"=="YT" (
ffmpeg -y -hide_banner %BG_SRC% -i "%input_mp3%" -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,format=yuv420p[bg_base];[bg_base]zoompan=z='min(zoom+0.001+it*0.01,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; %WAVE_LOGIC% [bg_pulsed]%LOGO_FILTER%[bg_logo];[bg_logo]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];[bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_TITLE%':text='%MAIN_TITLE%':fontcolor=%C_COLOR%:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_SUB%':text='%track_filters%':fontcolor=%C_COLOR%:fontsize=%FONT_SIZE_SUB%:y=h-70:x=w-mod(90*t\,w+tw)[v_ui];[v_ui][waves]overlay=%W_POS%:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -preset veryfast -tune stillimage -c:a aac -b:a 192k -shortest "%outfile%" 
pause & goto end
) else (
ffmpeg -y -hide_banner %BG_SRC% -i "%input_mp3%" -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,format=yuv420p[bg_base];[bg_base]zoompan=z='min(zoom+0.001+it*0.01,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; %WAVE_LOGIC% [bg_pulsed]%LOGO_FILTER%[bg_logo];[bg_logo]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];[bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_TITLE%':text='%MAIN_TITLE%':fontcolor=%C_COLOR%:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_SUB%':text='%track_filters%':fontcolor=%C_COLOR%:fontsize=%FONT_SIZE_SUB%:y=h-70:x=w-mod(90*t\,w+tw)[v_ui];[v_ui][waves]overlay=%W_POS%:shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -preset veryfast -tune stillimage -c:a aac -b:a 192k -shortest "%outfile%"
)
pause & goto end
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
    goto :MAIN_MENU
) else if "!end_choice!"=="2" (
    explorer "%OUTPUT_DIR%"
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
) else if "!end_choice!"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
)
exit b/0    

:DOWNLOAD_AUDIO
cls
echo ========================================
echo        DOWNLOAD AUDIO MP3
echo ========================================
echo.
echo [0] Back to Main Menu
echo.
set /p url="Enter YouTube URL: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_AUDIO

::Sanitize input
set "url=!url:"=!"

echo.
echo Downloading audio to: %MUSIC_DIR%
echo.
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
) else (
    echo [SUCCESS] Download complete!
    echo File saved to: %MUSIC_DIR%
    call :SHOW_MUSIC
)
pause
goto MAIN_MENU

:DOWNLOAD_WAVEFORM
cls
echo ========================================
echo    DOWNLOAD + CONVERT WITH WAVEFORM
echo ========================================
echo.
echo [0] Back to Main Menu
echo.
set /p url="Enter YouTube URL: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_WAVEFORM

::Sanitize input
set "url=!url:"=!"
set "youtube_url=!url!"

echo [1/3] Fetching Metadata from YouTube...
yt-dlp --print "title" "%youtube_url%" > title.txt 2>nul
set /p SAFE_TITLE=<title.txt 2>nul
if "!SAFE_TITLE!"=="" set "SAFE_TITLE=Unknown_Title"
del title.txt 2>nul

:: Create filters
set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"

::Select color
call :PICK_COLOR

::Select format
call :PLATFORM

::Choose waveform style
call :WAVESTYLE

::Download audio
echo.
echo Downloading audio...
set "temp_audio=%TEMP_DIR%\temp_waveform_%random%.mp3"
echo Downloading to: !temp_audio!
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "!url!"

if errorlevel 1 (
    echo [ERROR] Download failed!
    pause
    goto DOWNLOAD_WAVEFORM
)

:: Verify file was downloaded
if not exist "!temp_audio!" (
    echo [ERROR] Downloaded file not found!
    pause
    goto DOWNLOAD_WAVEFORM
) else (
    echo [SUCCESS] Audio downloaded successfully!
)

::Create output filename
set "outfile=%OUTPUT_DIR%\!SAFE_TITLE!_%COUNT%.mp4"

::Create waveform video
call :CREATE_WAVEFORM "!temp_audio!" "%input_bg%" "!outfile!"

if errorlevel 1 (
    echo [ERROR] Failed to create video!
) else (
    echo [SUCCESS] Video complete!
    echo File saved to: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)

::Cleanup - ONLY delete temporary files
del "!temp_audio!" 2>nul
pause
goto MAIN_MENU

:CONVERT_WAVEFORM
call :SHOW_MUSIC
set /p m_sel="Select MP3 Number: "
set "selected_mp3="
for /l %%i in (1,1,!m!) do if "%m_sel%"=="%%i" set "selected_mp3=!mp3_%%i!"
if not exist "!selected_mp3!" goto MAIN_MENU

for %%f in ("!selected_mp3!") do set "SAFE_TITLE=%%~nf"
set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"
call :PICK_COLOR
call :PLATFORM
call :WAVESTYLE
set "outfile=%OUTPUT_DIR%\!SAFE_TITLE!_%RANDOM%.mp4"
call :CREATE_WAVEFORM "!selected_mp3!" "%input_bg%" "!outfile!"
goto MAIN_MENU

:BULK_DOWNLOAD
setlocal enabledelayedexpansion
cls
echo ========================================
echo         BULK DOWNLOAD FROM FILE
echo ========================================
echo.
echo Searching for TXT files in: %CD%
echo.

::1. Reset Counter & Clear Memory
set "idx=0"
for /f "tokens=1 delims==" %%v in ('set urlfile_ 2^>nul') do set "%%v="

::2. Scan Files (Only show files containing YT links)
for %%f in (*.txt) do (
    findstr /i "youtube.com youtu.be" "%%f" >nul 2>nul
    if !errorlevel! equ 0 (
        set /a idx+=1
        set "urlfile_!idx!=%%f"
        echo [!idx!] %%f
    )
)

if %idx%==0 (
    echo [ERROR] No .txt file containing YouTube URLs found!
    pause
    endlocal & goto MAIN_MENU
)

echo.
echo [0] Back to Main Menu
set /p "file_choice=Select file number: "
if "!file_choice!"=="0" (endlocal & goto MAIN_MENU)

::Get selected file
set "selected_urlfile=!urlfile_%file_choice%!"
if "!selected_urlfile!"=="" (
    echo Invalid choice!
    pause
    endlocal & goto BULK_DOWNLOAD
)

cls
echo ========================================
echo FILE: !selected_urlfile!
echo ========================================
echo [1] Download MP3 Only (320kbps)
echo [2] Download + Waveform (MP4)
echo [3] Download Original Video (Best Quality MP4)
echo [0] Cancel
echo ----------------------------------------
set /p "bulk_type=Select Format [0-3]: "

if "!bulk_type!"=="0" (endlocal & goto BULK_DOWNLOAD)

::3. Prepare variables based on choice
if "!bulk_type!"=="1" (
    set "proses_type=audio"
) else if "!bulk_type!"=="2" (
    set "proses_type=waveform"
    echo Using default background...
)
	call :CONVERT_WAVEFORM
) else if "!bulk_type!"=="3" (
    set "proses_type=video_asli"
) else (
    echo Invalid choice!
    pause
    endlocal & goto BULK_DOWNLOAD
)

echo.
echo Processing bulk download...
echo ========================================

set "total=0"
set "success=0"
set "failed=0"

for /f "usebackq delims=" %%u in ("!selected_urlfile!") do (
    set /a total+=1
    
    ::Get Video Title
    for /f "delims=" %%t in ('yt-dlp --get-filename --restrict-filenames -o "%%(title)s" "%%u" 2^>nul') do set "SAFE_TITLE=%%t"
    if "!SAFE_TITLE!"=="" set "SAFE_TITLE=Unknown_!total!"
    
    echo [!total!] !SAFE_TITLE!

    if "!proses_type!"=="audio" (
        yt-dlp -x --audio-format mp3 --audio-quality 320k --restrict-filenames -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    ) else if "!proses_type!"=="waveform" (
        set "temp_audio=!TEMP_DIR!\tmp_!random!.mp3"
        echo Downloading to: !temp_audio!
        yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            if exist "!temp_audio!" (
                set "outfile=!OUTPUT_DIR!\!SAFE_TITLE!_%COUNT%.mp4"
                set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"
                call :CREATE_WAVEFORM "!temp_audio!" "%input_bg%" "!outfile!"
                del "!temp_audio!" 2>nul
            ) else (
                echo    [FAILED] Downloaded file not found.
                set /a failed+=1
            )
        ) else (
            echo    [FAILED] Download error.
            set /a failed+=1
        )
    ) else if "!proses_type!"=="video_asli" (
        ::DOWNLOAD ORIGINAL VIDEO (Best MP4)
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --restrict-filenames -o "%OUTPUT_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    )

    if !errorlevel! equ 0 (
        if not "!proses_type!"=="waveform" (
            echo    [OK] Success.
            set /a success+=1
        )
    ) else (
        if "!proses_type!"=="waveform" (
            rem Already counted in waveform section
        ) else (
            echo    [FAILED] An error occurred.
            set /a failed+=1
        )
    )
)

echo.
echo ========================================
echo COMPLETE! Successful: !success! ^| Failed: !failed!
echo ========================================
pause
endlocal
goto MAIN_MENU

:SHOW_MUSIC
cls
echo.
echo ========================================
echo        MUSIC FOLDER - DEFAULT
echo ========================================
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3" "%MUSIC_DIR%\*.opus" "%AU_DIR%\*.opus" "%AU_DIR%\*.mp3") do (
    set /a m+=1
    echo [!m!] %%~nxf
    set "mp3_!m!=%%f"
)
exit /b

:SHOW_OUTPUT
cls
echo.
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
    )
)
    set /a o+=1
    echo [!o!] %%~nxf
    set "output_!o!=%%f"
)
exit /b

:CHANGE_BACKGROUND
cls
echo.
echo ========================================
echo    BACKGROUND COLOR SETTINGS (Color)
echo ========================================
echo Select Background Color:
echo [1] Red     [4] White
echo [2] Green   [5] Light Gray
echo [3] Blue    [0] Default (Black)
echo ----------------------------------------
echo BG: %input_bg% ^| AU: !selected_mp3!
echo ----------------------------------------
echo.
set /p bg_mode="Choice: "
if "%bg_mode%"=="0" set "C_MODE=black@0.9"
if "%bg_mode%"=="1" set "C_MODE=red@0.9"
if "%bg_mode%"=="2" set "C_MODE=green@0.9"
if "%bg_mode%"=="3" set "C_MODE=blue@0.9"
if "%bg_mode%"=="4" set "C_MODE=white@0.9"
if "%bg_mode%"=="5" set "C_MODE=#D3D3D3@0.9"
echo ========================================
set "input_bg=color=c=!C_MODE!"
goto MAIN_MENU

:EXIT
cls
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
for %%f in ("%MUSIC_DIR%\*.mp3") do set /a m+=1
echo Music    : %m% MP3 files
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do set /a p+=1
echo Pictures : %p% image files
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do set /a v+=1
echo Videos   : %v% video files
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do set /a o+=1
echo Output   : %o% output files
echo.
echo [NOTE]
echo ----------------------------------------
echo [INFO] Your MP3, Image, Video files are SAFE
echo [INFO] All original files remain untouched
echo.
echo Cleaning up temporary files...
rmdir /s /q "%TEMP_DIR%" 2>nul
echo Goodbye!
timeout /t 3
endlocal
exit
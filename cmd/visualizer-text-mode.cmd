@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title READLOUD VISUALIZER - STABLE

set "MUSIC_DIR=%USERPROFILE%\Music"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter\YT_Video"
set "TEMP_DIR=%TEMP%\YTV"
set "ASSETS_DIR=%~dp0assets"

for %%d in ("%OUTPUT_DIR%" "%TEMP_DIR%" "%ASSETS_DIR%") do (if not exist "%%~d" mkdir "%%~d")

:: Default Settings
set "LOGO_TEXT=READLOUD"
set "LOGO_MODE=GLOW" & set "cc=(White soft shadow)" 
set "BG_MODE=STATIC" & set "SAFE_BG=Default"
set "C_COLOR=white@0.9"
set "FONT_LOGO=Buda.ttf"
set "FONT_TITLE=Bulgia.otf"
set "FONT_SUB=Super Wonder.ttf"
if not defined input_bg set "input_bg=%ASSETS_DIR%\default.png"

:MAIN_MENU
cls
echo.
echo ====================================================
echo   VISUALIZER PRO DEFAULT SYSTEM
echo ====================================================
echo  [1] Download Audio MP3
echo  [2] Download + Convert
echo  [3] Bulk Download
echo  [4] Convert Existing MP3
echo  [X] Settings 
echo ----------------------------------------------------
echo  Current Mode: [ !SAFE_BG! %BG_MODE% %LOGO_MODE% ]
echo ----------------------------------------------------
set /p choice="Select Menu[0-4][Q]uit: "
if /i "%choice%"=="Q" goto EXIT
if /i "%choice%"=="X" goto LOGO_SETTINGS
if "%choice%"=="1" goto DOWNLOAD_AUDIO
if "%choice%"=="2" set "WAVE_PICK=1" & goto DOWNLOAD_WAVEFORM
if "%choice%"=="3" goto BULK_DOWNLOAD
if "%choice%"=="4" set "WAVE_PICK=1" & goto CONVERT_WAVEFORM
goto MAIN_MENU

:LOGO_SETTINGS
cls
echo.
echo ====================================================
echo  LOGO TEXT SETTINGS
echo ====================================================
echo  [1] Change Text (Current: %LOGO_TEXT%)
echo  [2] Change Background LOOP
echo  [3] Change Background STATIC
echo  [4] Set Mode: RAINBOW 
echo  [5] Set Mode: GLOW 
echo ----------------------------------------------------
echo  Mode: %BG_MODE% ^| %LOGO_MODE% - %CC%
echo ----------------------------------------------------
set /p l_choice="Choice Menu [1-5][C]ancel: "
if "%l_choice%"=="1" set /p "LOGO_TEXT=Enter New Logo Text: " & goto LOGO_SETTINGS
if "%l_choice%"=="2" set "BG_MODE=LOOP"
if "%l_choice%"=="3" set "BG_MODE=STATIC"
if "%l_choice%"=="4" set "LOGO_MODE=RAINBOW" & set "cc=(Colors cycle over time)" & goto LOGO_SETTINGS
if "%l_choice%"=="5" set "LOGO_MODE=GLOW" & goto MAIN_MENU
if "%l_choice%"=="c" goto MAIN_MENU

if "!BG_MODE!"=="LOOP" (
    call :SHOW_VIDEOS
	set /p bg_number="Select number [C]ancel: " 
	for /l %%i in (1,1,!v!) do if "!bg_number!"=="%%i" set "selected_bg=!video_%%i!"
	set "input_bg=!selected_bg!"
	for %%f in ("!selected_bg!") do set "SAFE_BG=%%~nf" & goto LOGO_SETTINGS
) else if "!BG_MODE!"=="STATIC" (
    call :SHOW_PICTURES
	set /p bg_number="Select number [C]ancel: " 
	for /l %%i in (1,1,!p!) do if "!bg_number!"=="%%i" set "selected_bg=!img_%%i!"
	set "input_bg=!selected_bg!"
	for %%f in ("!selected_bg!") do set "SAFE_BG=%%~nf" & goto LOGO_SETTINGS
)
exit /b

:PLATFORM
cls
echo.
echo ====================================================
echo  1. YouTube (1920x1080)
echo  2. Reels/Shorts (1080x1920)
echo  3. Exit
echo ----------------------------------------------------
echo  Audio: !SAFE_TITLE!
echo ----------------------------------------------------
set /p choice="Select Format [1-3]: "
if "%choice%"=="3" (
    echo Exiting...
    timeout /t 2 /nobreak >nul
    goto :MAIN_MENU
)
if "%choice%"=="1" (
    set "FORMAT=YT"
    set "WIDTH=1920"
    set "HEIGHT=1080"
    set "WAVE_HEIGHT=90"
    set "FONT_SIZE_TITLE=30"
    set "FONT_SIZE_SUB=30"
	set "SCROLL_X=box=1:boxcolor=#000000@0.4:boxborderw=15:x=w-mod(100*t\,w+tw+50):y=120"
) else if "%choice%"=="2" (
    set "FORMAT=Shorts"
    set "WIDTH=1080"
    set "HEIGHT=1920"
    set "FONT_SIZE_SUB=30"
	set "SCROLL_X=box=1:boxcolor=#000000@0.4:boxborderw=15:x=w-mod(100*t\,w+tw+50):y=h-text_h-30"
) else (
    goto PLATFORM
)
exit /b

:PICK_COLOR
cls
echo.
echo ====================================================
echo  Select Wave Color:
echo  [1] Cyan		
echo  [2] Electric Blue		
echo  [3] Fluorescent Blue
echo  [4] Neon Red
echo  [5] Neon Green
echo ----------------------------------------------------
echo  Platform: %FORMAT%
echo ----------------------------------------------------
set /p c_choice="Choice [1-5]: "
if "%c_choice%"=="1" set "C_COLOR=#00FFFF" & set "COLOR=Cyan"
if "%c_choice%"=="2" set "C_COLOR=#00CCFF" & set "COLOR=Electric Blue"
if "%c_choice%"=="3" set "C_COLOR=#15F4EE" & set "COLOR=Fluorescent Blue"
if "%c_choice%"=="4" set "C_COLOR=#FF073A" & set "COLOR=Neon Red"
if "%c_choice%"=="5" set "C_COLOR=#29FF14" & set "COLOR=Neon Green"
if "%c_choice%"=="" set "C_COLOR=white" & set "COLOR=System Default"
exit /b

:WAVESTYLE
cls
echo.
echo ====================================================
echo  Select Wave Style:
echo  [1] Full Mode
echo  [2] Peak 2Peak
echo  [3] Split Channel
echo  [4] Mirror Effect
echo  [5] A/B Test
echo ----------------------------------------------------
echo  Selected Color : %COLOR%
echo ----------------------------------------------------
set /p WAVE_FILTER="Select Format (1-5): "
if "%WAVE_FILTER%"=="1" (
    set "WAVE_FILTER=[1:a]compand,showwaves=s=%WIDTH%x%WAVE_HEIGHT%:colors=%C_COLOR%:draw=full:mode=line" & set "WAVE_STYLE=Full Mode"
) else if "%WAVE_FILTER%"=="2" (
    set "WAVE_FILTER=[1:a]compand,showwaves=s=%WIDTH%x%WAVE_HEIGHT%:colors=%C_COLOR%:draw=full:mode=p2p:scale=sqrt" & set "WAVE_STYLE=Peak 2Peak SQRT"
) else if "%WAVE_FILTER%"=="3" (
	set "WAVE_FILTER=[1:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:draw=full:mode=cline:colors=green|%C_COLOR%:split_channels=1" & set "WAVE_STYLE=Split Channel"
) else if "%WAVE_FILTER%"=="4" (
   set "WAVE_FILTER=[1:a]channelsplit=channel_layout=stereo[l][r];[l]showwaves=s=960x%WAVE_HEIGHT%:mode=cline:colors=green:rate=30[left];[r]showwaves=s=960x%WAVE_HEIGHT%:mode=cline:colors=%C_COLOR%:rate=30[right];[left][right]hstack" & set "WAVE_STYLE=Mirror Effect"
) else if "%WAVE_FILTER%"=="5" (
    set "WAVE_FILTER=[1:a]channelsplit=channel_layout=stereo[l][r];[l]showwaves=s=960x%WAVE_HEIGHT%:colors=green:draw=full:mode=cline[l_wave];[r]showwaves=s=960x%WAVE_HEIGHT%:colors=%C_COLOR%:draw=full:mode=line[r_raw];[r_raw]hflip[r_flipped];[l_wave][r_flipped]hstack" & set "WAVE_STYLE=A/B Test"
) else if "%WAVE_FILTER%"=="" (
    set "WAVE_FILTER=[1:a]showspectrum=s=%WIDTH%x%WAVE_HEIGHT%:mode=combined" & set "WAVE_STYLE=System Default" 
)
if %errorlevel% equ 0 (echo Wavestyle Selected!) else (echo Use default Wavestyle!)
exit /b

:CREATE_WAVEFORM
cls
echo.
echo ====================================================
echo  [1] Mode      : %LOGO_MODE% %BG_MODE%
echo  [2] Background: !SAFE_BG!
echo  [3] Audio file: %AUDIO%
echo  [4] Scale     : %FORMAT% (%WIDTH%x%HEIGHT%)
echo  [5] Color     : %COLOR%
echo  [6] Style     : %WAVE_STYLE%
echo  [7] Output    : !SAFE_TITLE!_%FORMAT%
echo ====================================================
echo  All Checked! render %overlap% start in ...
timeout /t 5

set "input_mp3=%~1"
set "input_bg=%~2"
set "outfile=%~3"
set "FONT_LOGO=Buda.ttf"
set "FONT_TITLE=Bulgia.otf"
set "FONT_SUB=Super Wonder.ttf"
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

if "%FORMAT%"=="YT" (
    ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" -filter_complex "[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,fade=t=in:st=0:d=2,fade=t=out:st=%overlap%:d=2[bg_faded];[bg_faded]%LOGO_FILTER%[bg_txt];%WAVE_FILTER%[waves];[bg_txt]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box];[bg_box]drawtext=fontfile='%FONT_TITLE%':text='!SAFE_TITLE!':fontcolor=white@0.9:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.4:shadowx=4:shadowy=4,drawtext=text='%track_filters%':fontfile='%FONT_SUB%':fontsize=%FONT_SIZE_SUB%:fontcolor=white@0.5:x=(w-text_w)/2:y=h-150:%SCROLL_X%[v_final];[v_final][waves]overlay=x=0:y=H-%WAVE_HEIGHT%[outv];[1:a]afade=t=in:st=0:d=2,afade=t=out:st=%overlap%:d=2" -map "[outv]" -map 1:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest "%outfile%"
) else (
    :: Untuk format Shorts/TikTok
    ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" -filter_complex "[0:v]fps=30,scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,fade=t=in:st=0:d=2,fade=t=out:st=%overlap%:d=2[bg_faded];[bg_faded]%LOGO_FILTER%[v_no_text];[v_no_text]drawtext=text='%track_filters%':fontfile='%FONT_SUB%':fontsize=%FONT_SIZE_SUB%:fontcolor=white@0.9:x=(w-text_w)/2:y=h-150:%SCROLL_X%;[1:a]afade=t=in:st=0:d=2,afade=t=out:st=%overlap%:d=2[outv]" -map "[outv]" -map 1:a -c:v libx264 -preset fast -pix_fmt yuv420p -r 30 -g 60 -c:a aac -b:a 192k -shortest "%outfile%"
)

if %errorlevel% equ 0 (echo Success!) else (echo Failed!)
pause & goto end
exit /b

:end
cls
echo.
echo ====================================================
echo  ✅ All videos rendered!
echo  📁 Check the output folder: %outputfile%
echo ====================================================
echo  [1] Process another video
echo  [2] Open output folder
echo  [3] Exit
echo ----------------------------------------------------
set /p end_choice="Select [1-3]: "

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

:CONVERT_WAVEFORM
call :SHOW_MUSIC
set /p m_sel="Select MP3 Number: "
set "selected_mp3="
for /l %%i in (1,1,!m!) do if "%m_sel%"=="%%i" (
    set "selected_mp3=!mp3_%%i!"
    for %%f in ("!mp3_%%i!") do set "filename=%%~nf")
if not exist "!selected_mp3!" goto MAIN_MENU

::Get filename
set "input_mp3=!selected_mp3!"
for %%f in ("!selected_mp3!") do set "SAFE_TITLE=%%~nf" & set "AUDIO=!SAFE_TITLE!"

::Get overlap
	for /f "tokens=*" %%i in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%input_mp3%"') do (
    set "DUR=%%i"
)
	for /f "delims=." %%a in ("%DUR%") do set "DUR_INT=%%a"
	set /a overlap=%DUR_INT% - 2
	
::Select format
call :PLATFORM

::Select color
call :PICK_COLOR

::Choose waveform style
call :WAVESTYLE

set "outfile=%OUTPUT_DIR%\!SAFE_TITLE!_%FORMAT%_%random%.mp4"

call :CREATE_WAVEFORM "!selected_mp3!" "%input_bg%" "!outfile!"
goto MAIN_MENU

:DOWNLOAD_AUDIO
cls
echo.
echo ====================================================
echo  DOWNLOAD AUDIO MP3
echo ====================================================
echo  [0] Back to Main Menu
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
    call :SHOW_MUSICD
)
pause
goto MAIN_MENU

:DOWNLOAD_WAVEFORM
cls
echo.
echo ====================================================
echo  DOWNLOAD + CONVERT WITH WAVEFORM
echo ====================================================
echo.
echo  [0] Back to Main Menu
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
set "track_filters='!SAFE_TITLE!'"

::Select format
call :PLATFORM

::Select color
call :PICK_COLOR

::Choose waveform style
call :WAVESTYLE

::Download audio
echo.
echo Downloading audio...
set "temp_audio=%TEMP_DIR%\temp_waveform_%random%.mp3"
echo Downloading to: !temp_audio!
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "!url!"

    :: Force-remove any remaining underscores
    set "SAFE_TITLE=!SAFE_TITLE:_= !"
    set "SAFE_TITLE=!SAFE_TITLE:'= !"
	
	:: Remove "Official Music Video" (and variations)
	set "SAFE_TITLE=!SAFE_TITLE:Official=!"
	set "SAFE_TITLE=!SAFE_TITLE:Remastered=!"
	set "SAFE_TITLE=!SAFE_TITLE:Lyric=!"
	set "SAFE_TITLE=!SAFE_TITLE:Lirik=!"
	set "SAFE_TITLE=!SAFE_TITLE:Music=!"
	set "SAFE_TITLE=!SAFE_TITLE:Video=!"
	
	:: Clean up brackets often left behind: [ ], ( )
	set "SAFE_TITLE=!SAFE_TITLE:[]=!"
	set "SAFE_TITLE=!SAFE_TITLE:()=!"

	:: Clean up extra spaces created by the removals
	set "SAFE_TITLE=!SAFE_TITLE:  = !"
	set "SAFE_TITLE=!SAFE_TITLE:   = !"	

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
set "outfile=%OUTPUT_DIR%\!SAFE_TITLE!_%FORMAT%_%random%.mp4"

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

:BULK_DOWNLOAD
setlocal enabledelayedexpansion
cls
echo.
echo ====================================================
echo  BULK DOWNLOAD FROM FILE
echo ====================================================
echo  Searching for TXT files in: %CD%
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
echo.
echo ====================================================
echo  FILE: !selected_urlfile!
echo ====================================================
echo  [1] Download MP3 Only (320kbps)
echo  [2] Download + Waveform (MP4)
echo  [3] Download Original Video (Best Quality MP4)
echo ----------------------------------------------------
set /p "bulk_type=Select Format [1-3][0]Cancel: "

if "!bulk_type!"=="0" (endlocal & goto MAIN_MENU)
::3. Prepare variables based on choice
if "!bulk_type!"=="1" (
    set "proses_type=audio"
) else if "!bulk_type!"=="2" (
    set "proses_type=waveform"
) else if "!bulk_type!"=="3" (
    set "proses_type=video_asli"
) else (
    echo Invalid choice!
    pause
    endlocal & goto BULK_DOWNLOAD
)

echo.
echo  Processing bulk download...
echo ====================================================

set "total=0"
set "success=0"
set "failed=0"

for /f "usebackq delims=" %%u in ("!selected_urlfile!") do (
    set /a total+=1
    
	:: Get Title
    for /f "delims=" %%t in ('yt-dlp --get-filename --restrict-filenames -o "%%(title)s" "%%u" 2^>nul') do set "SAFE_TITLE=%%t"
    :: Force-remove any remaining underscores
    set "SAFE_TITLE=!SAFE_TITLE:_= !"
    	
	:: Remove "Official Music Video" (and variations)
	set "SAFE_TITLE=!SAFE_TITLE:Official=!"
	set "SAFE_TITLE=!SAFE_TITLE:Remastered=!"
	set "SAFE_TITLE=!SAFE_TITLE:Lyric=!"
	set "SAFE_TITLE=!SAFE_TITLE:Lirik=!"
	set "SAFE_TITLE=!SAFE_TITLE:Music=!"
	set "SAFE_TITLE=!SAFE_TITLE:Video=!"

	:: Clean up brackets often left behind: [ ], ( )
	set "SAFE_TITLE=!SAFE_TITLE:[]=!"
	set "SAFE_TITLE=!SAFE_TITLE:()=!"

	:: Clean up extra spaces created by the removals
	set "SAFE_TITLE=!SAFE_TITLE:  = !"
	set "SAFE_TITLE=!SAFE_TITLE:   = !"	
	
    :: Fallback if empty
    if "!SAFE_TITLE!"=="" set "SAFE_TITLE=Unknown !total!"
    echo [!total!] !SAFE_TITLE!

	if "!proses_type!"=="audio" (
    :: Use !SAFE_TITLE! which we already cleaned of underscores
    yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\!SAFE_TITLE!.%%(ext)s" "%%u" >nul 2>&1
    ) else if "!proses_type!"=="waveform" (
        set "temp_audio=!TEMP_DIR!\tmp_!random!.mp3"
        echo Downloading to: !temp_audio!
        yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            if exist "!temp_audio!" (
                set "output_file=!OUTPUT_DIR!\!SAFE_TITLE!_%FORMAT%.mp4"
                set "track_filters='!SAFE_TITLE!':fontcolor=white:fontsize=40:x=(w-text_w)/2:y=h-150"
                call :CREATE_WAVEFORM "!temp_audio!" "%input_bg%" "!output_file!"
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
echo ====================================================
echo  Successful: !success! ^| Failed: !failed!
echo ====================================================
echo  Clearing URL list...
type nul > "!selected_urlfile!"
pause
endlocal
goto MAIN_MENU

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
echo  SELECT A FOLDER
echo ====================================================

:: 1. List all directories (and subdirectories) to let the user choose
set d=0
for /d /r "%VIDEOS_DIR%" %%i in (*) do (
    set /a d+=1
    set "dir_!d!=%%i"
    echo [!d!] %%~ni
)

echo.
set /p folder_choice="Select a folder (or press Enter for root): "

:: Determine the search path based on choice
if "%folder_choice%"=="" (
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

if %v%==0 echo No audio files found in this selection.
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
set /p folder_choice="Select a folder (or press Enter for root): "

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
		set "mp3_!m!=%%~ff"
        echo [!m!] %%~nxf
    )
    popd
)

if %m%==0 echo No audio files found in this selection.
echo ====================================================
exit /b

:SHOW_PICTURES
cls
echo ====================================================
echo  SELECT A FOLDER
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
set /p folder_choice="Select folder (Enter for root): "

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

if %p%==0 echo No audio files found in this selection.
echo ====================================================
exit /b

:SHOW_OUTPUT
cls
echo ====================================================
echo  OUTPUT FOLDER - YT_Converter
echo ====================================================
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
		set "output_!o!=%%f"
)
exit /b

:EXIT
cls
echo.
echo ----------------------------------------------------
echo  SYSTEM INFORMATION
echo ----------------------------------------------------
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
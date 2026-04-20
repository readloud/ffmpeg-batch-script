@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title READLOUD MUSIC PLAYER - STABLE

:: ==========================================
:: 1. CONFIGURATION
:: ==========================================
set "MUSIC_DIR=%USERPROFILE%\Music"
:: ==========================================

:INIT
set "VOL=1.0"
set "v_step=10"
set "current_idx=0"
set "MODE=NORMAL"
set "status=IDLE"
set "LOOP_PARAM=-autoexit"
set "current_dur=--:--"
:: Clean up any old instances 
taskkill /f /im ffplay.exe >nul 2>&1

:SCAN_FILES
cls
echo.
set m=0
:: Fast scan: only grabbing filenames to keep it stable 
for /R "%MUSIC_DIR%" %%f in (*.mp3 *.opus *.wav *.m4a) do (
    set /a m+=1
    set "music_!m!=%%f"
    set "name_!m!=%%~nxf"
)
if %m% EQU 0 (echo NO MUSIC FOUND IN %MUSIC_DIR% & pause & exit)

:REFRESH_UI
cls
echo.
echo ==========================================================================
	echo   BATCH MUSIC PLAYER [STABLE]
echo ==========================================================================
if not "!current_idx!"=="0" (
    echo   [STATUS]  : !status!
    echo   [PLAYING] : !name_%current_idx%! [!current_dur!]
    echo   [MODE]    : !MODE!     [VOLUME]: !VOL!
) else (
    echo   [STATUS]  : IDLE ^| SONGS LOADED: %m%
)
echo ==========================================================================
echo.
echo   [P] PLAYLIST    [H] SHUFFLE     [L] LIST ALL    [F] SEARCH
echo   [N] NEXT        [B] PREV        [R] REPEAT      [X] STOP
echo   [W] VOL UP      [S] VOL DOWN    [Q] EXIT        [U] RE-SCAN
echo.
echo ==========================================================================

:AUTO_LOOP
:: Alphanumeric ONLY to prevent "Invalid Choice" crashes [cite: 5]
:: P=1, H=2, L=3, N=4, F=5, B=6, R=7, X=8, Q=9, U=10, W=11, S=12, T=13(Timer)
choice /c phlnfbrxquwst /n /t 1 /d t >nul 2>&1
set "key=%errorlevel%"

:: CHECK IF SONG ENDED (Auto-Advance Logic) 
tasklist /fi "imagename eq ffplay.exe" 2>NUL | find /I "ffplay.exe" >NUL
if errorlevel 1 (
    if "!status!"=="PLAYING" (
        if /i "!MODE!"=="PLAYLIST" goto NEXT_SONG
        if /i "!MODE!"=="SHUFFLE" goto SHUFFLE_SONG
        set "status=FINISHED" & set "current_dur=--:--" & goto REFRESH_UI
    )
)

:: KEY MAPPING
if %key% EQU 1 (set "MODE=PLAYLIST" & goto NEXT_SONG)
if %key% EQU 2 (set "MODE=SHUFFLE" & goto SHUFFLE_SONG)
if %key% EQU 3 (goto SHOW_LIST)
if %key% EQU 4 (goto NEXT_SONG)
if %key% EQU 5 (goto SEARCH_FUNC)
if %key% EQU 6 (goto PREV_SONG)
if %key% EQU 7 (set "MODE=REPEAT" & set "LOOP_PARAM=-loop 0" & goto PLAY_LOGIC)
if %key% EQU 8 (taskkill /f /im ffplay.exe >nul 2>&1 & set "current_idx=0" & set "status=STOPPED" & goto REFRESH_UI)
if %key% EQU 9 (taskkill /f /im ffplay.exe >nul 2>&1 & exit /b)
if %key% EQU 10 (goto SCAN_FILES)
if %key% EQU 11 (goto VOL_UP)
if %key% EQU 12 (goto VOL_DOWN)

goto AUTO_LOOP

:PLAY_LOGIC
if "!current_idx!"=="0" goto REFRESH_UI
set "status=PLAYING"
taskkill /f /im ffplay.exe >nul 2>&1

:: Get duration for only the selected song 
for /f "tokens=*" %%d in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 -sexagesimal "!music_%current_idx%!"') do (
    set "raw_dur=%%d"
    set "current_dur=!raw_dur:~3,5!"
)

start /min "" ffplay -nodisp %LOOP_PARAM% -af "volume=%VOL%" "!music_%current_idx%!"
goto REFRESH_UI

:SHUFFLE_SONG
set /a "rand=(!RANDOM! * %m% / 32768) + 1"
set "current_idx=!rand!"
goto PLAY_LOGIC

:NEXT_SONG
set /a current_idx+=1
if !current_idx! GTR %m% set current_idx=1
goto PLAY_LOGIC

:PREV_SONG
set /a current_idx-=1
if !current_idx! LSS 1 set current_idx=%m%
goto PLAY_LOGIC

:VOL_UP
set /a "v_step+=1" & if !v_step! GTR 20 set v_step=20
goto UPDATE_VOL

:VOL_DOWN
set /a "v_step-=1" & if !v_step! LSS 0 set v_step=0
goto UPDATE_VOL

:UPDATE_VOL
if !v_step! LSS 10 (set "VOL=0.!v_step!") else if !v_step! EQU 10 (set "VOL=1.0") else (set "tmp_v=!v_step:~1,1!" & set "VOL=1.!tmp_v!")
if !v_step! EQU 20 set "VOL=2.0" [cite: 12, 13]
if "!status!"=="PLAYING" goto PLAY_LOGIC
goto REFRESH_UI

:SEARCH_FUNC
cls
echo [SEARCH] Enter part of the filename:
set /p "q="
for /L %%i in (1,1,%m%) do (
    echo !name_%%i! | findstr /i "!q!" >nul
    if !errorlevel! == 0 echo [%%i] !name_%%i!
)
set /p "sq=ID to play (0 to back): "
if "!sq!"=="0" goto REFRESH_UI
if defined music_%sq% (set "current_idx=%sq%" & set "MODE=NORMAL" & set "LOOP_PARAM=-autoexit" & goto PLAY_LOGIC)
goto REFRESH_UI

:SHOW_LIST
cls
for /L %%i in (1,1,%m%) do (echo [%%i] !name_%%i!)
set /p "lsel=ID to play (0 to back): "
if "!lsel!"=="0" goto REFRESH_UI
if defined music_%lsel% (set "current_idx=%lsel%" & set "MODE=NORMAL" & set "LOOP_PARAM=-autoexit" & goto PLAY_LOGIC)
goto REFRESH_UI
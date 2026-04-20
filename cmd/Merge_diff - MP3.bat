@echo off
setlocal enabledelayedexpansion

set "FOLDER=do_mix"
set "OUT_FILE=final\mix_%random%.mp3"

:: Create output directory if it doesn't exist
if not exist "final" mkdir final

echo 🎬 Detecting all audio files in "%FOLDER%" folder...
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

:: Find all MP3 files (simplified - just MP3 for now)
echo Looking for MP3 files...
set COUNT=0

:: Change to the folder and get files sorted by name
pushd "%FOLDER%"

:: Use dir to get sorted files and save to list
dir /b /on *.mp3 > ..\file_list.txt 2>nul

popd

:: Count files
if exist file_list.txt (
    for /f %%i in ('type file_list.txt ^| find /c /v ""') do set COUNT=%%i
)

echo Found %COUNT% MP3 files
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
ffmpeg %INPUT_FILES% -filter_complex "concat=n=%COUNT%:v=1:a=1" -c:v libmp3lame -c:a aac "%OUT_FILE%"

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
        ffmpeg -f concat -safe 0 -i "%TEMP%\temp_concat.txt" -c copy "%TEMP%\temp_output.mp3" -y
        
        if exist "%TEMP%\temp_output.mp3" (
            move /y "%TEMP%\temp_output.mp3" "%OUT_FILE%" >nul
        ) else (
            echo ❌ Failed to append %%i
        )
        
        del "%TEMP%\temp_concat.txt" 2>nul
    )
))

if exist "%OUT_FILE%" (
    echo.
    echo ✅ Successfully merged files using sequential method
) else (
    echo.
    echo ❌ All merge methods failed
)

:cleanup
:: Clean up
del file_list.txt 2>nul
del "%CONCAT_FILE%" 2>nul
del "%TEMP%\temp_concat.txt" 2>nul
del "%TEMP%\temp_output.mp3" 2>nul

echo.
echo Output file: %OUT_FILE%
pause
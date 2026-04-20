@echo off
setlocal enabledelayedexpansion

REM Prompt the user for the input directory
set /p "inputDir=Enter the directory where the MKV and SRT files are located: "

REM Check if the "added" directory exists in the input directory; if not, create it
if not exist "!inputDir!\added" mkdir "!inputDir!\added"

REM Function to add subtitles to MKV files
:ConvertToMKV
for %%f in ("!inputDir!\*.mkv") do (
    set "videoFile=%%~nf.mkv"
    set "outputFile=!inputDir!\added\%%~nf-added-subtitle.mkv"
    if not exist "!outputFile!" (
        ffmpeg -hide_banner -loglevel panic -i "%%~f" -sub_charenc UTF-8 -f srt -i "!inputDir!\%%~nf.srt" -map 0:0 -map 0:1 -map 1:0 -c:v copy -c:a copy -c:s srt "!outputFile!"
        echo [Success] Converted "%%~nf.mkv" with subtitles to "!outputFile!"
    ) else (
        echo [Skipped] "!outputFile!" already exists
    )
)

echo Conversion completed.
pause

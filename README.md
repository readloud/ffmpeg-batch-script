# FFMPEG Batch Convert for Windows

A Windows batch script for FFmpeg allows you to automate media processing for multiple files simultaneously. To create one, write your commands in a text editor like Notepad and save the file with a .bat or .cmd extension. 

1. Basic Batch Scripts
Convert All Files in a Folder: This script processes every .mp4 file in the current directory and converts it to .mkv.
~~~batch
@echo off
for %%a in (*.mp4) do ffmpeg -i "%%a" "%%~na.mkv"
pause
Note: %%~na extracts only the filename without the extension to prevent creating files named video.mp4.mkv.
Extract Audio from Videos: Convert all videos in a folder to high-quality .mp3 files.
batch
@echo off
for %%i in (*.mp4) do ffmpeg -i "%%i" -vn -q:a 2 "%%~ni.mp3"
pause
~~~

2. Advanced Scripts
Recursive Processing (Include Subfolders): Use the /R flag to walk through all subdirectories and convert files.
~~~batch
@echo off
for /R %%f in (*.mkv) do ffmpeg -i "%%f" -c:v libx264 -c:a aac "%%~dpnf_converted.mp4"
pause
~~~
Drag-and-Drop Script: Create a script where you can drop a single file or a group of files onto the .bat icon to process them.
~~~batch
@echo off
:loop
if "%~1"=="" goto end
ffmpeg -i "%~1" -c:v copy -c:a copy "%~n1_copy.mp4"
shift
goto loop
:end
pause
~~~

3. Setup and Execution
Installation: Ensure FFmpeg is [installed](https://ffmpeg.org/download.html) and added to your [Windows System Path](https://video.stackexchange.com/questions/20495/how-do-i-set-up-and-use-ffmpeg-in-windows) so the ffmpeg command can be recognized from any folder.
Running the Script: Place your .bat file in the same folder as your media and [double-click it](https://www.lenovo.com/in/en/glossary/batch-file/) to run.
GUI Alternative: If you prefer a graphical interface over scripts, use the open-source FFmpeg Batch AV Converter for advanced multi-file management. 

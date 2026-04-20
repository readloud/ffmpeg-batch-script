@echo off
setlocal enabledelayedexpansion

:: --- 1. SETUP & SELEKSI INPUT ---
echo ====================================================
echo      FFMPEG TUTORIAL MAKER - NUMERIC PICKER
echo ====================================================

:: Menemukan Folder Music Default Windows secara otomatis
set "WIN_MUSIC=%USERPROFILE%\Music"
set "OUTPUT_DIR=%USERPROFILE%\Videos"
set "TEMP_DIR=%temp%\YT_Tutorials"

:: --- KONFIGURASI PATH ---
set "SAFE_NAME=%V_TITLE: =_%"
set "SOURCE_FILE=content.txt"
set "CONCAT_LIST=%OUTPUT_DIR%\file_list.txt"
set "MASTER_TEMP=%temp%\tutorial\temp_merged.mp4"
set "OUT=%temp%\tutorial"
set "FINAL_DIR=%OUTPUT_DIR%"
set "OUTPUT=%OUTPUT_DIR%\%SAFE_NAME%_%random%.mp4"

::Create folders
if not exist "%WIN_MUSIC%" mkdir "%WIN_MUSIC%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%OUT%" mkdir "%OUT%"

:: Font settings
set "F_BOLD=C\:/Windows/Fonts/Buda.ttf"
set "F_REG=C\:/Windows/Fonts/Buda.ttf"

:: Clear old file list
if exist file_list.txt del file_list.txt

:: A. Pilih File
echo 🔍 Mencari daftar file...
set count=0
for /f "delims=" %%f in ('dir /b *.txt 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
    echo !count!. %%f
)

if %count% equ 0 (
    echo (Tidak ada file CONTENT di folder Anda)
    set "SELECTED_FILE="
) else (
    set /p "CHOICE=Pilih nama file (1-%count%) atau tekan Enter untuk skip: "
    if not "!CHOICE!"=="" (
        set "SELECTED_FILE=!file%CHOICE%!"
        echo File yang dipilih: !SELECTED_FILE!
    )
)
echo ----------------------------------------------------
echo.
echo ✨ Memproses Content...
powershell .\processor_.ps1 -InputPath !SELECTED_FILE! content.txt
 
:: B. Pilih Judul Video
echo.
set /p "V_TITLE=Masukkan Judul Video: "

:: C. Pilih BGM dengan Angka
echo.
echo 🎵 Daftar musik di folder Music Windows:
set count=0
for /f "delims=" %%f in ('dir /b "%WIN_MUSIC%\*.mp3" 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
    echo !count!. %%f
)

if %count% equ 0 (
    echo (Tidak ada file .mp3 di folder Music Anda, proses tanpa BGM)
    set "SELECTED_BGM="
) else (
    set /p "CHOICE=Pilih nomor lagu (1-%count%) atau tekan Enter untuk skip: "
    if not "!CHOICE!"=="" (
        set "SELECTED_BGM=!file%CHOICE%!"
        echo Musik yang dipilih: !SELECTED_BGM!
    )
)

:: --- 2. GENERASI ADEGAN ---
echo.
echo 🎙️ Memproses Audio dan Video...
for /f "usebackq tokens=1,2,3 delims=|" %%a in ("%SOURCE_FILE%") do (
    set "fname=%%a"
    set "voice=%%b"
    set "display=%%c"
    
    if not "!voice!"=="" (
        echo 🎤 Rendering: !fname!
        powershell -Command "Add-Type -AssemblyName System.Speech; $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; try { $speak.SelectVoice('Microsoft Andika') } catch {}; $speak.SetOutputToWaveFile('%OUT%\temp.wav'); $speak.Speak([regex]::Unescape('!voice!')); $speak.Dispose()"

        for /f "tokens=*" %%d in ('ffprobe -i "%OUT%\temp.wav" -show_entries format^=duration -v quiet -of csv^="p=0"') do set "dur=%%d"
        ffmpeg -y -f lavfi -i "color=c=0x1e1e1e:s=1920x1080:d=!dur!" -i "%OUT%\temp.wav" -vf "drawtext=fontfile='%F_REG%':text='!display!':fontcolor=white:fontsize=80:x=(w-text_w)/2:y=(h-text_h)/2" -c:v libx264 -c:a aac -pix_fmt yuv420p -shortest "%OUT%\!fname!.mp4"
    )
)

:: --- 3. PENGGABUNGAN ---
echo.
echo 🎬 Menyatukan segmen...
if exist "%CONCAT_LIST%" del "%CONCAT_LIST%"
(for /f "delims=" %%i in ('dir /b /on "%OUT%\*.mp4"') do (echo file '%cd%\%OUT%\%%i')) > "%CONCAT_LIST%"
ffmpeg -y -f concat -safe 0 -i "%CONCAT_LIST%" -c:v libx264 -pix_fmt yuv420p -c:a aac "%MASTER_TEMP%"

:: --- 4. FINALISASI (BGM PICKER LOGIC) ---
echo.
echo 🎨 Finalisasi visual dan audio...

if not "!SELECTED_BGM!"=="" (
    if exist "%WIN_MUSIC%\!SELECTED_BGM!" (
        echo 🎵 Menggunakan BGM: !SELECTED_BGM!
        ffmpeg -y -hide_banner -i "%MASTER_TEMP%" -i "%WIN_MUSIC%\!SELECTED_BGM!" -filter_complex "[1:a]aloop=loop=-1:size=2e+09,volume=0.30[bg_audio];[0:a]volume=1.0[main_audio];[main_audio][bg_audio]amix=inputs=2:duration=first:dropout_transition=2[mixed_a];[0:v]drawtext=fontfile='%F_BOLD%':text='ReadLoud':fontcolor=white@0.8:fontsize=40:x=W-tw-40:y=40,drawbox=x=0:y=ih-200:w=iw:h=200:color=black@0.7:t=fill,drawtext=fontfile='%F_BOLD%':text='%V_TITLE%':fontcolor=white:fontsize=60:x=30:y=h-160,drawtext=fontfile='%F_REG%':text='FFmpeg Tutorial':fontcolor=white:fontsize=32:x=42:y=h-70[v_txt];[0:a]showwaves=s=1920x150:mode=cline:colors=white:rate=25,format=rgba[wave];[v_txt][wave]overlay=0:H-175:format=auto[final_v]" -map "[final_v]" -map "[mixed_a]" -c:v libx264 -preset fast -pix_fmt yuv420p -c:a aac -shortest "%OUTPUT%"
        goto :finish
    )
)

:: Render Standar jika BGM tidak dipilih/tidak ada
echo ℹ️ Memproses tanpa BGM...
		ffmpeg -y -hide_banner -i "%MASTER_TEMP%" -filter_complex "[0:v]drawtext=fontfile='%F_BOLD%':text='FFmpeg ReadLoud':fontcolor=white@0.8:fontsize=40:x=W-tw-40:y=40,drawbox=x=0:y=ih-200:w=iw:h=200:color=black@0.7:t=fill,  drawtext=fontfile='%F_BOLD%':text='%V_TITLE%':fontcolor=white:fontsize=60:x=30:y=h-160,drawtext=fontfile='%F_REG%':text='FFmpeg Tutorial':fontcolor=white:fontsize=32:x=42:y=h-70[v_txt];[0:a]showwaves=s=1920x150:mode=cline:colors=white:rate=25,format=rgba[wave];[v_txt][wave]overlay=0:H-175:format=auto[final_v]" -map "[final_v]" -map 0:a -c:v libx264 -preset fast -pix_fmt yuv420p -c:a aac -shortest "%OUTPUT%"

:finish
:: Cleanup
if exist "%OUTPUT%" (
    del "%TEMP_DIR%" 2>nul
	del "%CONCAT_LIST%" 2>nul
    del "%MASTER_TEMP%" 2>nul
    echo.
    echo ✨ SELESAI! Video tersimpan di: %OUTPUT%
)
pause
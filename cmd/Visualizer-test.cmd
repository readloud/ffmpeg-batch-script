@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
:: DEFAULT SYSTEM FOLDERS ONLY
:: ========================================
set "MUSIC_DIR=%USERPROFILE%\Music"
set "PICTURES_DIR=%USERPROFILE%\Pictures"
set "VIDEOS_DIR=%USERPROFILE%\Videos"
set "OUTPUT_DIR=%VIDEOS_DIR%\YT_Converter"
set "TEMP_DIR=%TEMP%\YT_Converter"

:: Create folders
if not exist "%MUSIC_DIR%" mkdir "%MUSIC_DIR%"
if not exist "%PICTURES_DIR%" mkdir "%PICTURES_DIR%"
if not exist "%VIDEOS_DIR%" mkdir "%VIDEOS_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Check tools
where ffmpeg >nul 2>nul || echo [WARNING] FFmpeg not installed!
where yt-dlp >nul 2>nul || echo [WARNING] yt-dlp not installed!
timeout /t 2 >nul

:: ========================================
:: MENU UTAMA
:: ========================================
:MAIN_MENU
cls
echo ========================================
echo    YOUTUBE DOWNLOADER CONVERTER PRO
echo         DEFAULT SYSTEM FOLDERS
echo ========================================
echo.
echo [1] Download Audio MP3
echo [2] Download + Convert Waveform
echo [3] Bulk Download from File
echo [4] Convert Existing MP3
echo [5] Mix Audio + Video
echo [6] System Info
echo [0] Exit
echo.
echo ----------------------------------------
echo MUSIC:    %MUSIC_DIR%
echo PICTURES: %PICTURES_DIR%
echo VIDEOS:   %VIDEOS_DIR%
echo OUTPUT:   %OUTPUT_DIR%
echo ----------------------------------------
echo.
set /p choice="Pilih menu [0-6]: "

if "%choice%"=="1" goto DOWNLOAD_AUDIO
if "%choice%"=="2" goto DOWNLOAD_WAVEFORM
if "%choice%"=="3" goto BULK_DOWNLOAD
if "%choice%"=="4" goto CONVERT_WAVEFORM
if "%choice%"=="5" goto ADD_AUDIO_VIDEO
if "%choice%"=="6" goto SYSTEM_INFO
if "%choice%"=="0" goto EXIT

echo Pilihan tidak valid!
pause
goto MAIN_MENU

:: ========================================
:: FUNGSI TAMPIL FILE - TIDAK MENGUBAH FILE
:: ========================================
:SHOW_MUSIC
cls
echo ========================================
echo        MUSIC FOLDER - DEFAULT
echo ========================================
echo %MUSIC_DIR%
echo.
echo DAFTAR FILE MP3:
echo ----------------------------------------
set m=0
for %%f in ("%MUSIC_DIR%\*.mp3") do (
    if exist "%%f" (
        set /a m+=1
        echo [!m!] %%~nxf
        set "mp3_!m!=%%f"
        set "mp3_name_!m!=%%~nxf"
    )
)
if %m%==0 echo (Belum ada file MP3)
echo ========================================
echo Total: %m% file
echo.
echo [0] Kembali ke Menu Utama
echo.
exit /b 0

:SHOW_PICTURES
cls
echo ========================================
echo      PICTURES FOLDER - DEFAULT
echo ========================================
echo %PICTURES_DIR%
echo.
echo DAFTAR FILE GAMBAR:
echo ----------------------------------------
set p=0
for %%f in ("%PICTURES_DIR%\*.jpg" "%PICTURES_DIR%\*.jpeg" "%PICTURES_DIR%\*.png") do (
    if exist "%%f" (
        set /a p+=1
        echo [!p!] %%~nxf
        set "img_!p!=%%f"
        set "img_name_!p!=%%~nxf"
    )
)
if %p%==0 echo (Belum ada file gambar)
echo ========================================
echo Total: %p% file
echo.
echo [0] Kembali ke Menu Utama
echo.
exit /b 0

:SHOW_VIDEOS
cls
echo ========================================
echo      VIDEOS FOLDER - DEFAULT
echo ========================================
echo %VIDEOS_DIR%
echo.
echo DAFTAR FILE VIDEO:
echo ----------------------------------------
set v=0
for %%f in ("%VIDEOS_DIR%\*.mp4" "%VIDEOS_DIR%\*.avi" "%VIDEOS_DIR%\*.mkv" "%VIDEOS_DIR%\*.mov") do (
    if exist "%%f" (
        set /a v+=1
        echo [!v!] %%~nxf
        set "video_!v!=%%f"
        set "video_name_!v!=%%~nxf"
    )
)
if %v%==0 echo (Belum ada file video)
echo ========================================
echo Total: %v% file
echo.
echo [0] Kembali ke Menu Utama
echo.
exit /b 0

:SHOW_OUTPUT
cls
echo ========================================
echo      OUTPUT FOLDER - YT_Converter
echo ========================================
echo %OUTPUT_DIR%
echo.
echo DAFTAR FILE OUTPUT:
echo ----------------------------------------
set o=0
for %%f in ("%OUTPUT_DIR%\*.mp4") do (
    if exist "%%f" (
        set /a o+=1
        echo [!o!] %%~nxf
    )
)
if %o%==0 echo (Belum ada file output)
echo ========================================
echo Total: %o% file
echo.
echo [0] Kembali ke Menu Utama
echo.
exit /b 0

:: ========================================
:: FUNGSI SELECT WAVEFORM STYLE
:: ========================================
:WAVEFORM_STYLE_SELECT
cls
echo =========================================
echo       FFMPEG WAVEFORM STYLE SELECTOR
echo =========================================
echo [ SOLID BACKGROUNDS ]
echo 1. Black - White Cline          5. Black - Red/Blue Cline
echo 2. Black - Cyan Line            6. Black - Green P2P
echo 3. Black - Yellow Point         7. Black - White Cline (Blur)
echo 4. Blue  - White Cline          8. Black - Cyan/Magenta Hex
echo.
echo [ IMAGE BACKGROUNDS ]
echo 9.  White Cline                 13. Red/Blue Cline
echo 10. Cyan Line                   14. Green P2P
echo 11. Yellow Point                15. White Cline (Blur)
echo 12. Cyan/Magenta Hex
echo =========================================
set /p wave_style="Select Style (1-15):

if "%wave_style%"=="0" exit /b 2
if "%wave_style%"=="" set wave_style=1
exit /b 0

:: ========================================
:: FUNGSI CREATE WAVEFORM VIDEO
:: ========================================
:CREATE_WAVEFORM
set "input_img=%~1"
set "input_mp3=%~2"
set "output_file=%~3"

echo.
echo Membuat video dengan waveform...
echo Style: %wave_style%
echo Resolution: 1280x720
echo.

:: Validasi file
if not exist "%input_mp3%" (
    echo [ERROR] File audio tidak ditemukan!
    exit /b 1
)
if not exist "%input_img%" (
    echo [ERROR] File gambar tidak ditemukan!
    exit /b 1
)

:: Apply waveform style sesuai pilihan
:: Solid Background Logic (Styles 1-8)
if %wave_style% equ 1 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" [cite: 1]
    goto :WAVEFORM_DONE
)
if %wave_style% equ 2 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=line:rate=25:colors=cyan[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" [cite: 1]
    goto :WAVEFORM_DONE
)
if %wave_style% equ 3 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=yellow[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 4 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=blue:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 5 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=red|blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 6 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=p2p:rate=25:colors=green[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 7 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1,boxblur=2:1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 8 (
    ffmpeg -i "%input_mp3%" -filter_complex "color=c=black:s=1280x720:d=300[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)

:: Image Background Logic (Styles 9-15)
if %wave_style% equ 9 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 10 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=line:rate=25:colors=cyan[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 11 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=yellow[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 12 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 13 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=red|blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 14 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=p2p:rate=25:colors=green[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 15 (
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1,boxblur=2:1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)

:WAVEFORM_DONE
if errorlevel 1 (
    echo [ERROR] Gagal membuat video waveform!
    exit /b 1
) else (
    echo [SUCCESS] Video berhasil dibuat!
    exit /b 0
)

:: ========================================
:: FUNGSI PILIH GAMBAR - TETAP AMAN
:: ========================================
:PILIH_GAMBAR
call :SHOW_PICTURES
if %p%==0 (
    echo [ERROR] Tidak ada file gambar!
    echo.
    echo Tekan sembarang tombol untuk kembali ke Menu Utama...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_GAMBAR
set /p img_choice="Pilih nomor gambar [0 untuk batal]: "

if "!img_choice!"=="0" (
    echo Batal memilih gambar.
    exit /b 2
)

set "selected_img="
for /l %%i in (1,1,%p%) do (
    if "!img_choice!"=="%%i" set "selected_img=!img_%%i!"
)

if "!selected_img!"=="" (
    echo Pilihan tidak valid!
    goto ULANG_PILIH_GAMBAR
)

echo Menggunakan gambar: !selected_img!
exit /b 0

:: ========================================
:: FUNGSI PILIH MP3 - TETAP AMAN
:: ========================================
:PILIH_MP3
call :SHOW_MUSIC
if %m%==0 (
    echo [ERROR] Tidak ada file MP3!
    echo.
    echo Tekan sembarang tombol untuk kembali ke Menu Utama...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_MP3
set /p mp3_choice="Pilih nomor MP3 [0 untuk batal]: "

if "!mp3_choice!"=="0" (
    echo Batal memilih MP3.
    exit /b 2
)

set "selected_mp3="
for /l %%i in (1,1,%m%) do (
    if "!mp3_choice!"=="%%i" set "selected_mp3=!mp3_%%i!"
)

if "!selected_mp3!"=="" (
    echo Pilihan tidak valid!
    goto ULANG_PILIH_MP3
)

echo Menggunakan MP3: !selected_mp3!
exit /b 0

:: ========================================
:: FUNGSI PILIH VIDEO - TETAP AMAN
:: ========================================
:PILIH_VIDEO
call :SHOW_VIDEOS
if %v%==0 (
    echo [ERROR] Tidak ada file video!
    echo.
    echo Tekan sembarang tombol untuk kembali ke Menu Utama...
    pause >nul
    exit /b 1
)

:ULANG_PILIH_VIDEO
set /p video_choice="Pilih nomor video [0 untuk batal]: "

if "!video_choice!"=="0" (
    echo Batal memilih video.
    exit /b 2
)

set "selected_video="
for /l %%i in (1,1,%v%) do (
    if "!video_choice!"=="%%i" set "selected_video=!video_%%i!"
)

if "!selected_video!"=="" (
    echo Pilihan tidak valid!
    goto ULANG_PILIH_VIDEO
)

echo Menggunakan video: !selected_video!
exit /b 0

:: ========================================
:: MENU 1 - DOWNLOAD AUDIO MP3
:: ========================================
:DOWNLOAD_AUDIO
cls
echo ========================================
echo        DOWNLOAD AUDIO MP3
echo ========================================
echo.
echo [0] Kembali ke Menu Utama
echo.
set /p url="Masukkan URL YouTube: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_AUDIO

:: Sanitasi input
set "url=!url:"=!"

echo.
echo Mendownload audio ke: %MUSIC_DIR%
echo.
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "!url!"

if errorlevel 1 (
    echo [ERROR] Download gagal!
) else (
    echo [SUCCESS] Download selesai!
    echo File tersimpan di: %MUSIC_DIR%
    call :SHOW_MUSIC
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 2 - DOWNLOAD + CONVERT WITH IMAGE + WAVEFORM
:: ========================================
:DOWNLOAD_WAVEFORM
cls
echo ========================================
echo    DOWNLOAD + CONVERT WITH WAVEFORM
echo ========================================
echo.
echo [0] Kembali ke Menu Utama
echo.
set /p url="Masukkan URL YouTube: "

if "%url%"=="0" goto MAIN_MENU
if "%url%"=="" goto DOWNLOAD_WAVEFORM

:: Sanitasi input
set "url=!url:"=!"

:: Pilih gambar
call :PILIH_GAMBAR
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto DOWNLOAD_WAVEFORM

:: Download audio
echo.
echo Mendownload audio...
set "temp_audio=%TEMP_DIR%\temp_waveform_%random%.mp3"
yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "!url!"

if errorlevel 1 (
    echo [ERROR] Download gagal!
    pause
    goto DOWNLOAD_WAVEFORM
)

:: Dapatkan judul video
set "title=video_%random%"
for /f "delims=" %%i in ('yt-dlp --get-filename -o "%%(title)s" "!url!" 2^>nul') do set "title=%%i"
if "!title!"=="" set "title=video_!random!"

:: Pilih waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" (
    del "!temp_audio!" 2>nul
    goto MAIN_MENU
)

:: Buat output filename
set "output_file=%OUTPUT_DIR%\!title!_%wave_style%_%random%.mp4"

:: Buat video waveform
call :CREATE_WAVEFORM "!selected_img!" "!temp_audio!" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Gagal membuat video!
) else (
    echo [SUCCESS] Video selesai!
    echo File tersimpan di: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)

:: Cleanup - HANYA hapus file temporary
del "!temp_audio!" 2>nul
pause
goto MAIN_MENU

:: ========================================
:: MENU 3 - CONVERT EXISTING MP3 + IMAGE + WAVEFORM
:: ========================================
:CONVERT_WAVEFORM
cls
echo ========================================
echo    CONVERT MP3 + IMAGE + WAVEFORM
echo ========================================

:: Pilih MP3
call :PILIH_MP3
set "mp3_exit=!errorlevel!"
if "!mp3_exit!"=="1" goto MAIN_MENU
if "!mp3_exit!"=="2" goto CONVERT_WAVEFORM

:: Pilih gambar
call :PILIH_GAMBAR
set "gambar_exit=!errorlevel!"
if "!gambar_exit!"=="1" goto MAIN_MENU
if "!gambar_exit!"=="2" goto CONVERT_WAVEFORM

:: Dapatkan nama file
for %%f in ("!selected_mp3!") do set "filename=%%~nf"

:: Pilih waveform style
call :WAVEFORM_STYLE_SELECT
if "!errorlevel!"=="2" goto MAIN_MENU

:: Buat output filename
set "output_file=%OUTPUT_DIR%\!filename!_waveform_%random%.mp4"

:: Buat video waveform
call :CREATE_WAVEFORM "!selected_img!" "!selected_mp3!" "!output_file!"

if errorlevel 1 (
    echo [ERROR] Gagal membuat video!
) else (
    echo [SUCCESS] Video selesai!
    echo File tersimpan di: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 4 - ADD AUDIO TO VIDEO
:: ========================================
:ADD_AUDIO_VIDEO
cls
echo ========================================
echo        ADD AUDIO TO VIDEO
echo ========================================

:: Pilih video
call :PILIH_VIDEO
set "video_exit=!errorlevel!"
if "!video_exit!"=="1" goto MAIN_MENU
if "!video_exit!"=="2" goto ADD_AUDIO_VIDEO

:: Pilih MP3
call :PILIH_MP3
set "mp3_exit=!errorlevel!"
if "!mp3_exit!"=="1" goto MAIN_MENU
if "!mp3_exit!"=="2" goto ADD_AUDIO_VIDEO

echo.
echo [1] Replace audio (hapus audio original)
echo [2] Mix with original (campur dengan audio original)
echo [0] Batal
echo.
set /p mix="Pilih [0-2]: "

if "!mix!"=="0" goto ADD_AUDIO_VIDEO
if "!mix!"=="1" (
    set "mix_mode=replace"
) else if "!mix!"=="2" (
    set "mix_mode=mix"
) else (
    echo Pilihan tidak valid!
    pause
    goto ADD_AUDIO_VIDEO
)

for %%f in ("!selected_video!") do set "filename=%%~nf"
set "output_file=%OUTPUT_DIR%\!filename!_mixed_%random%.mp4"

echo.
echo Memproses audio mixing...
if "!mix_mode!"=="replace" (
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest -y "!output_file!"
) else (
    ffmpeg -i "!selected_video!" -i "!selected_mp3!" -filter_complex "[0:a][1:a]amix=inputs=2:duration=first" -c:v copy -c:a aac -y "!output_file!"
)

if errorlevel 1 (
    echo [ERROR] Gagal memproses audio!
) else (
    echo [SUCCESS] Video selesai!
    echo File tersimpan di: %OUTPUT_DIR%
    call :SHOW_OUTPUT
)
pause
goto MAIN_MENU

:: ========================================
:: MENU 5 - BULK DOWNLOAD FROM FILE
:: ========================================
:BULK_DOWNLOAD
setlocal Enabledelayedexpansion
cls
echo ========================================
echo         BULK DOWNLOAD FROM FILE
echo ========================================
echo.
echo Mencari file TXT di: %CD%
echo.

:: 1. Reset Counter & Bersihkan Memori
set "idx=0"
for /f "tokens=1 delims==" %%v in ('set urlfile_ 2^>nul') do set "%%v="

:: 2. Scan File (Pastikan hanya file yang ada link YT yang muncul)
for %%f in (*.txt) do (
    findstr /i "youtube.com youtu.be" "%%f" >nul 2>nul
    if !errorlevel! equ 0 (
        set /a idx+=1
        set "urlfile_!idx!=%%f"
        echo [!idx!] %%f
    )
)

if %idx%==0 (
    echo [ERROR] Tidak ada file .txt berisi URL YouTube!
    pause
    endlocal & goto MAIN_MENU
)

echo.
echo [0] Kembali ke Menu Utama
set /p "file_choice=Pilih nomor file: "
if "!file_choice!"=="0" (endlocal & goto MAIN_MENU)

:: Ambil file yang dipilih
set "selected_urlfile=!urlfile_%file_choice%!"
if "!selected_urlfile!"=="" (
    echo Pilihan tidak valid!
    pause
    endlocal & goto BULK_DOWNLOAD
)

cls
echo ========================================
echo FILE: !selected_urlfile!
echo ========================================
echo [1] Download MP3 Saja (320kbps)
echo [2] Download + Waveform (MP4)
echo [3] Download Video Asli (Best Quality MP4)
echo [0] Batal
echo ----------------------------------------
set /p "bulk_type=Pilih Format [0-3]: "

if "!bulk_type!"=="0" (endlocal & goto BULK_DOWNLOAD)

:: 3. Persiapan variabel berdasarkan pilihan
if "!bulk_type!"=="1" (
    set "proses_type=audio"
) else if "!bulk_type!"=="2" (
    set "proses_type=waveform"
    call :PILIH_GAMBAR
    if "!errorlevel!"=="1" (endlocal & goto MAIN_MENU)
    set "bulk_img=!selected_img!"
    call :WAVEFORM_STYLE_SELECT
) else if "!bulk_type!"=="3" (
    set "proses_type=video_asli"
) else (
    echo Pilihan tidak valid!
    pause
    endlocal & goto BULK_DOWNLOAD
)

echo.
echo Memproses bulk download...
echo ========================================

set "total=0"
set "success=0"
set "failed=0"

for /f "usebackq delims=" %%u in ("!selected_urlfile!") do (
    set /a total+=1
    
    :: Ambil Judul Video
    for /f "delims=" %%t in ('yt-dlp --get-filename --restrict-filenames -o "%%(title)s" "%%u" 2^>nul') do set "title=%%t"
    
    echo [!total!] !title!

    if "!proses_type!"=="audio" (
        yt-dlp -x --audio-format mp3 --audio-quality 320k --restrict-filenames -o "%MUSIC_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    ) else if "!proses_type!"=="waveform" (
        set "temp_audio=!TEMP_DIR!\tmp_!random!.mp3"
        yt-dlp -x --audio-format mp3 --audio-quality 320k -o "!temp_audio!" "%%u" >nul 2>&1
        if !errorlevel! equ 0 (
            call :CREATE_WAVEFORM "!bulk_img!" "!temp_audio!" "!OUTPUT_DIR!\!title!_waveform.mp4"
            del "!temp_audio!" 2>nul
        )
    ) else if "!proses_type!"=="video_asli" (
        :: DOWNLOAD VIDEO ASLI (Best MP4)
        yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --restrict-filenames -o "%OUTPUT_DIR%\%%(title)s.%%(ext)s" "%%u" >nul 2>&1
    )

    if !errorlevel! equ 0 (
        echo    [OK] Berhasil.
        set /a success+=1
    ) else (
        echo    [GAGAL] Terjadi kesalahan.
        set /a failed+=1
    )
)

echo.
echo ========================================
echo SELESAI! Berhasil: %success% ^| Gagal: %failed%
echo ========================================
pause
endlocal
goto MAIN_MENU
:: ========================================
:: MENU 6 - SYSTEM INFORMATION
:: ========================================
:SYSTEM_INFO
cls
echo ========================================
echo         SYSTEM INFORMATION
echo ========================================
echo.
echo [DEFAULT SYSTEM FOLDERS]
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
echo [INSTALLED TOOLS]
echo ----------------------------------------
where ffmpeg >nul 2>nul && echo FFmpeg   : INSTALLED || echo FFmpeg   : NOT FOUND
where yt-dlp >nul 2>nul && echo yt-dlp   : INSTALLED || echo yt-dlp   : NOT FOUND
echo.
echo [NOTE]
echo ----------------------------------------
echo - File MP3 asli TIDAK PERNAH dihapus
echo - File gambar TIDAK PERNAH diubah/dihapus
echo - File video TIDAK PERNAH dihapus
echo - Hanya file temporary yang dibersihkan
echo.
echo [0] Kembali ke Menu Utama
echo.
set /p "back=Tekan 0 untuk kembali: "
if "!back!"=="0" goto MAIN_MENU
pause
goto MAIN_MENU

:: ========================================
:: EXIT
:: ========================================
:EXIT
cls
echo ========================================
echo     TERIMA KASIH TELAH MENGGUNAKAN
echo    YOUTUBE DOWNLOADER CONVERTER PRO
echo ========================================
echo.
echo Membersihkan temporary files...
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" 2>nul
    echo Temporary files dibersihkan.
) else (
    echo Tidak ada temporary files.
)
echo.
echo [INFO] File MP3, Gambar, Video Anda TETAP AMAN
echo [INFO] Semua file asli tidak tersentuh
echo.
echo Sampai jumpa!
timeout /t 5 >nul

:: Bersihkan environment dan keluar
endlocal
exit /b 0

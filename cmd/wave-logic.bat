:: First, determine which waveform style to use and set appropriate variables
if %wave_style% equ 1 (
    :: Circular Wave Static
    set "WAVEFORM_TYPE=circular_static"
    set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p[v];[v]format=rgba, geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[vout]"
    goto :SET_PLATFORM_LOGIC
)
if %wave_style% equ 2 (
    :: Circular Wave Full Background
    set "WAVEFORM_TYPE=circular_full"
    set "WAVEFORM_FILTER=[1:v]scale=%WIDTH%:%WAVE_HEIGHT%[bg];[0:a]aformat=cl=mono,showwaves=%WIDTH%x%WAVE_HEIGHT%:cline:colors=white:draw=full,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a];[bg][a]overlay=(W-w)/2:(H-h)/2"
    goto :SET_PLATFORM_LOGIC
)
if %wave_style% equ 14 (
    :: Split Channel
    set "WAVEFORM_TYPE=split_channel"
    set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=line:split_channels=1[v]"
    goto :SET_PLATFORM_LOGIC
)
if %wave_style% equ 0 (
    :: Circular Wave Solid Background
    set "WAVEFORM_TYPE=circular_solid"
    set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]"
    goto :SET_PLATFORM_LOGIC
)

:: Regular waveform styles (can use simple showwaves)
if %wave_style% equ 3 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p:scale=log[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 4 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p:scale=cbrt[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 5 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p:scale=sqrt[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 6 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=p2p[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 7 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=line[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 8 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full:mode=cline[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 9 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white:draw=full[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 10 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=white[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 11 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=#25d3d0|#7925d3:draw=full:mode=line[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 12 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=#25d3d0:draw=full:mode=line[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 13 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]compand,showwaves=size=%WIDTH%x%WAVE_HEIGHT%:colors=#7925d3:draw=full:mode=line[vout]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 15 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[1:a]aformat=channel_layouts=mono,showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:colors=white[v]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 16 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=blue[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 17 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=white[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 18 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=line:rate=25:colors=cyan[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 19 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=point:rate=25:colors=yellow[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 20 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 21 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=red|blue[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 22 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=p2p:rate=25:colors=green[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 23 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=cline:rate=25:colors=white[wave]" & goto :SET_PLATFORM_LOGIC
if %wave_style% equ 24 set "WAVEFORM_TYPE=regular" & set "WAVEFORM_FILTER=[0:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=p2p:rate=25:colors=white@0.9[wave]" & goto :SET_PLATFORM_LOGIC

:SET_PLATFORM_LOGIC
:: Now apply platform logic (YouTube/TikTok) with appropriate waveform integration
if "%FORMAT%"=="youtube" (
    :: YouTube Horizontal Logic
    if "!USE_LOGO!"=="1" (
        if "%USE_BANNER%"=="1" (
            :: With banner and logo
            if "%WAVEFORM_TYPE%"=="circular_static" (
                ffmpeg -y -hide_banner -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "%WAVEFORM_FILTER%;[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv];[2:v]scale=100:-1[logo_s];[outv][logo_s]overlay=W-w-10:10[final]" ^
                -map "[final]" -map 0:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="circular_full" (
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[2:v]scale=100:-1[logo_s];[3:a]%WAVEFORM_FILTER%[final];[1:v][logo_s]overlay=W-w-10:10[final2]" ^
                -map "[final2]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="split_channel" (
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[0:v]scale=%WIDTH%:%WAVE_HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%WAVE_HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; [3:a]%WAVEFORM_FILTER%; [bg_l][v]overlay=shortest=1[bg_l_waves]; [bg_l_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
                -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="circular_solid" (
                ffmpeg -y -hide_banner -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "%WAVEFORM_FILTER%;[1:v][outv]overlay=(W-w)/2:(H-h)/2[bg_w_banner];[2:v]scale=100:-1[logo_s];[bg_w_banner][logo_s]overlay=W-w-10:10[final]" ^
                -map "[final]" -map 0:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else (
                :: Regular waveform style
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[0:v]scale=%WIDTH%:%WAVE_HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%WAVE_HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; [3:a]%WAVEFORM_FILTER%; [bg_l][vout]overlay=shortest=1[bg_l_waves]; [bg_l_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
                -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            )
     )
) else (
    :: TikTok Vertical Logic
    if "!USE_LOGO!"=="1" (
        if "%USE_BANNER%"=="1" (
            :: With banner and logo
			    if "!USE_LOGO!"=="1" (
        if "%USE_BANNER%"=="1" (
            :: With banner and logo
            if "%WAVEFORM_TYPE%"=="circular_static" (
                ffmpeg -y -hide_banner -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "%WAVEFORM_FILTER%;[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv];[2:v]scale=100:-1[logo_s];[outv][logo_s]overlay=W-w-10:10[final]" ^
                -map "[final]" -map 0:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="circular_full" (
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[2:v]scale=100:-1[logo_s];[3:a]%WAVEFORM_FILTER%[final];[1:v][logo_s]overlay=W-w-10:10[final2]" ^
                -map "[final2]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="split_channel" (
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[0:v]scale=%WIDTH%:%WAVE_HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%WAVE_HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; [3:a]%WAVEFORM_FILTER%; [bg_l][v]overlay=shortest=1[bg_l_waves]; [bg_l_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
                -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else if "%WAVEFORM_TYPE%"=="circular_solid" (
                ffmpeg -y -hide_banner -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "%WAVEFORM_FILTER%;[1:v][outv]overlay=(W-w)/2:(H-h)/2[bg_w_banner];[2:v]scale=100:-1[logo_s];[bg_w_banner][logo_s]overlay=W-w-10:10[final]" ^
                -map "[final]" -map 0:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
            ) else (
                :: Regular waveform style
                ffmpeg -y -hide_banner -stream_loop -1 -i "%ASSETS_DIR%\bg_loop.mp4" -i "%ASSETS_DIR%\banner.png" -i "!logo!" -i "!audio_file!" ^
                -filter_complex "[0:v]scale=%WIDTH%:%WAVE_HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%WAVE_HEIGHT%,boxblur=10:5[bg]; [1:v]scale=%WIDTH%/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg][banner]overlay=(W-w)/2:(H-h)/2[bg_w_banner]; [2:v]scale=100:-1[logo_s]; [bg_w_banner][logo_s]overlay=W-w-10:10[bg_l]; [3:a]%WAVEFORM_FILTER%; [bg_l][vout]overlay=shortest=1[bg_l_waves]; [bg_l_waves]drawbox=x=0:y=ih-200:w=iw:h=200:color=#000000@0.7:t=fill[bg_box]; [bg_box]drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%SAFE_TITLE%':fontcolor=white:fontsize=%FONT_SIZE_TITLE%:x=40:y=h-160:shadowcolor=black@0.9:shadowx=4:shadowy=4, drawtext=fontfile='%FONT_PATH%':font='%FONT_NAME%':text='%track_filters%':fontcolor=white:fontsize=%FONT_SIZE_SUB%:x=42:y=h-70[final]" ^
                -map "[final]" -map 3:a -c:v libx264 -preset fast -tune stillimage -c:a aac -b:a 192k -shortest -y "%output_file%"
			
       )
    )
)
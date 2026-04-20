::Apply waveform style sesuai pilihan
if %wave_style% equ 1 (
::Circular Wave Static Image(Note escaped commas)
ffmpeg -i "%input_mp3%" -i default.png -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p[v];[v]format=rgba, geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[vout];[1:v][vout]overlay=(W-w)/2:(H-h)/2[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p -y circularbg.mp4
    goto :WAVEFORM_DONE
)
if %wave_style% equ 2 (
::Circular Wave Full Background
ffmpeg -i "%input_mp3%" -i "%input_bg%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=white:draw=full,geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))':a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a];[bg][a]overlay=(W-w)/2:(H-h)/2" -c:v libx264 -c:a copy -shortest -y circularfull.mp4 -y
    goto :WAVEFORM_DONE
)
if %wave_style% equ 3 (
::SCALE LOG
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=log,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 4 (
::SCALE CBRT
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=cbrt,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 5 (
::MODE SQRT
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=sqrt,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy waveform_scale_sqrt.mp4
    goto :WAVEFORM_DONE
)
if %wave_style% equ 6 (
::P2P
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 7 (
::LINE
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=line,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 8 (
::CLINE
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=cline,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 9 (
::DRAWFULL
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 10 (
::DEFAULT
ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 11 (
::CYAN MAGENTA
	ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=#25d3d0|#7925d3:draw=full:mode=line,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 12 (
::CYAN
	ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=#25d3d0:draw=full:mode=line,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 13 (
::PURPLE
	ffmpeg -i "%input_mp3%" -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=#7925d3:draw=full:mode=line[vout];[1:v][vout]overlay=format=auto:shortest=1,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 14 (
::Split Channel
	ffmpeg -i "%input_mp3%" -filter_complex "[0:a]showwaves=s=1280x720:mode=line:split_channels=1[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 15 (
::Pinkglow	
	ffmpeg -i "%input_mp4%" -i "%input_mp3%" -filter_complex "[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; [top][blurred]blend=all_mode=addition[glow]; [0:v][glow]overlay=y=H-h[final]" -map "[final]" -map 1:a -c:a copy -pix_fmt yuv420p -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 16 (
::blue_line
    ffmpeg -i "%input_mp3%" -filter_complex "[1:v]scale=1280:720[bg];[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 17 (
::White Cline                 
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 18 (
::Cyan Line
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=line:rate=25:colors=cyan[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%" 
    goto :WAVEFORM_DONE
)
if %wave_style% equ 19 (
::Yellow Point
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=yellow[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 20 (
::Cyan/Magenta Hex
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=0x00FFFF|0xFF00FF[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 21 (
::Red/Blue Cline
   ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=red|blue[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 22 (
::Green P2P
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=p2p:rate=25:colors=green[wave];[bg][wave]overlay=shortest=1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 23 (
::White Cline (Blur)
    ffmpeg -i "%input_mp3%" -loop 1 -i "%input_img%" -filter_complex "[1:v]scale=1280:720[bg];[0:a]showwaves=s=1280x720:mode=cline:rate=25:colors=white[wave];[bg][wave]overlay=shortest=1,boxblur=2:1" -c:v libx264 -c:a aac -shortest -y "%output_file%"
    goto :WAVEFORM_DONE
)
if %wave_style% equ 0 (
::Circular Wave Solid Backgroung(Note escaped commas)
	ffmpeg -i "%input_mp3%" -filter_complex "[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba,geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))':a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" -map "[outv]" -map 0:a -pix_fmt yuv420p -y "%output%"
    goto :WAVEFORM_DONE
)
@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "SOURCE_FILE=live.txt"
set duration=140
set fontsize=38
set xoffset=0
set fontfile=Palyball-Regular.ttf

:: Define video parameters
set "WIDTH=1920"
set "HEIGHT=1080"
set "FONT_PATH=C\:/Windows/Fonts/Dubai.ttf"
set "FONT_SIZE=30"
set "BG_COLOR=0x1e1e1e"

ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=10 -vf ^
"drawtext=fontfile=Palyball-Regular.ttf: ^
textfile=live.txt: ^
fontcolor=gold: ^
fontsize=40: ^
x=(w-text_w)/2+8: ^
y=h*0.8-(t/10)*(h*0.6+text_h): ^
box=1: ^
boxcolor=black@0.5: ^
boxborderw=5" -codec:a copy output.mp4


ffmpeg -y -i input.jpeg -vf "colorkey=white:0.3:0.5" input.png

ffmpeg -i input.mp4 -i input.jpeg -filter_complex "[1:v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay=(W-w)/2:(H-h)/2" -vcodec libx264 1%random%.mkv

ffmpeg -i input.mp4 -i input.jpeg -filter_complex "[0]scale=1920:1080:force_original_aspect_ratio=increase,crop=1080:1920,split[m][a];[a]geq='if(lt(lum(X,Y),16),0,255)',hue=s=0[al];[m][al]alphamerge,format=yuva420p" -c:v libx264 2%random%.mkv

ffmpeg -y -hide_banner -stream_loop -1 -i input.mp4 -i input.jpeg -filter_complex "[0:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1080:1920,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=1920x1080[bg_faded];[1:v]scale=1920/2:-1,format=rgba,colorchannelmixer=aa=0.7[banner]; [bg_faded][banner]overlay=(W-w)/2:(H-h)/2[v_no_text];[v_no_text]drawtext=text='track_filters1':fontfile='arial.ttf':fontsize=40:fontcolor=white@0.9:x=(w-text_w)/2:y=h-150,drawtext=text='track_filters2':fontfile='arial.ttf':fontsize=40:fontcolor=white@0.9:x=(w-text_w)/2:y=h-100,drawtext=text='track_filters3':fontfile='arial.ttf':fontsize=40:fontcolor=white@0.9:x=(w-text_w)/2:y=h-50[outv]" -map "[outv]" -map 0:a? -c:v libx264 -preset fast -pix_fmt yuv420p -r 30 -g 60 -c:a aac -b:a 192k -shortest 3%random%.mkv

ffmpeg -y -i input.mp4 -vf "drawtext=text='Selamat Hari Raya Idul Fitri 1447 H':fontfile='bulgia.otf':fontsize=12:fontcolor=gold@0.7:x='max((w-tw)/2, w-t*100)':y=(h-th)/2,drawtext=text='Taqabbalallahu minna wa minkum':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:x=@'min(1, mod(t,20)*2)':x='min((w-tw)/2, -tw+(mod(t,20)*100))':y=(h-th)/2+50,drawtext=text='Minal Aidin Wal Faizin':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:x='max((w-tw)/2, w-t*100)':y=(h-th)/2+100,drawtext=text='Mohon maaf lahir dan batin':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:x=@'min(1, mod(t,20)*2)':x='min((w-tw)/2, -tw+(mod(t,20)*100))':y=(h-th)/2+150" -codec:a copy outputCredits%random%.mp4

ffmpeg -y -i input.mp4 -vf "drawtext=text='Selamat Hari Raya Idul Fitri 1447 H':fontfile='bulgia.otf':fontsize=12:fontcolor=gold@0.7:enable='between(t,0,15)':x='max((w-tw)/2, w-t*100)':y=(h-th)/2,drawtext=text='Taqabbalallahu minna wa minkum':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:enable='between(t,1,15)':x=@'min(1, mod(t,20)*2)':x='min((w-tw)/2, -tw+(mod(t,20)*100))':y=(h-th)/2+50,drawtext=text='Minal Aidin Wal Faizin':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:enable='between(t,2,15)':x='max((w-tw)/2, w-t*100)':y=(h-th)/2+100,drawtext=text='Mohon maaf lahir dan batin':fontfile='bulgia.otf':fontsize=12:fontcolor=white@0.7:enable='gt(t,3)':x=@'min(1, mod(t,20)*2)':x='min((w-tw)/2, -tw+(mod(t,20)*100))':y=(h-th)/2+150" -codec:a copy outputCredits%random%.mp4

ffmpeg -y -hide_banner -stream_loop -1 -i input.mp4 -i ied2.mp4 -filter_complex "[0:v]fps=30,scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[bg];[1:v]scale=640/2:-1[pinp];[bg][pinp]overlay=x=W-w-20:y=H-h-20,format=yuva420p" -c:v libx264 -t 5 %random%.mkv

:: Get-ChildItem "C:\Path\to\Files" -Recurse | Rename-Item -NewName {$_.name -replace '_',' '}
endlocal
exit /b
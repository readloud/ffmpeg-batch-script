Rotating videos in FFmpeg can be achieved using either the transpose filter (best for 90/180-degree increments) or the rotate filter (best for arbitrary angles). These methods involve re-encoding the video. 

1. 90-Degree Increments (Recommended) 
The transpose filter is the most efficient way to rotate by 90-degree increments or combine rotation with flipping. 
90° Clockwise:
```ffmpeg -i input.mp4 -vf "transpose=1" -c:a copy output.mp4```
90° Counter-Clockwise:
```ffmpeg -i input.mp4 -vf "transpose=2" -c:a copy output.mp4```
180° Rotation:
```ffmpeg -i input.mp4 -vf "transpose=2,transpose=2" -c:a copy output.mp4```
 
Transpose Options:
0: 90° CCW and vertical flip (default)
1: 90° Clockwise
2: 90° Counter-clockwise
3: 90° Clockwise and vertical flip 

2. Arbitrary Angles
To rotate by an angle other than 90/180/270, use the rotate filter. The angle must be specified in radians. 

Rotate by 45 degrees:
```ffmpeg -i input.mp4 -vf "rotate=45*PI/180" output.mp4```

Rotate by 30 degrees (Counter-Clockwise):
```ffmpeg -i input.mp4 -vf "rotate=-30*PI/180" output.mp4```
 
3. Rotate Without Re-encoding (Metadata Fix) 
If your video is already rotated correctly but has wrong orientation metadata, you can fix it without re-encoding, which is very fast: 
```ffmpeg -i input.mp4 -c copy -metadata:s:v:0 rotate=0 output.mp4```

4. Batch Rotate an Entire Directory 
You can use a loop in terminal to process multiple files (example for 90-degree clockwise): 
```for f in *.mp4; do ffmpeg -i "$f" -vf "transpose=1" "rotated_$f"; done```

Key Considerations
Re-encoding: Using -vf (video filters) requires re-encoding, which takes time and reduces quality slightly.
Audio: The -c:a copy command ensures the audio is not re-encoded, saving time.
Scaling: When using the rotate filter (arbitrary angle), the video dimensions might change, requiring you to crop or scale to avoid black borders. 

FFmpeg provides two primary ways to rotate videos: the transpose filter (re-encodes, reliable) and the rotation metadata method (fast, no re-encoding). 

1. Using Transpose Filter (Recommended - Rotates Pixels) 
This method physically changes the pixels and is the most compatible across players. It uses -vf (video filter). 
Rotate 90 degrees Clockwise:
```ffmpeg -i input.mp4 -vf "transpose=1" output.mp4```
Rotate 90 degrees Counter-Clockwise:
```ffmpeg -i input.mp4 -vf "transpose=2" output.mp4```
Rotate 180 degrees (Upside Down):
```ffmpeg -i input.mp4 -vf "transpose=2,transpose=2" output.mp4```
Rotate 90 Clockwise + Vertical Flip:
```ffmpeg -i input.mp4 -vf "transpose=3" output.mp4```

Transpose Parameter Options:
0 = 90°CounterClockwise and Vertical Flip (default)
1 = 90°Clockwise
2 = 90°CounterClockwise
3 = 90°Clockwise and Vertical Flip 

2. Using Rotation Metadata (Fastest - No Re-encoding) 
This method changes the orientation flag, telling players to rotate the video without actually re-encoding the video stream. 

Rotate 90 degrees:
```ffmpeg -i input.mp4 -display_rotation 90 -c:v copy output.mp4```
Rotate 180 degrees:
```ffmpeg -i input.mp4 -display_rotation 180 -c:v copy output.mp4```
Rotate 270 degrees:
```ffmpeg -i input.mp4 -display_rotation 270 -c:v copy output.mp4```

3. Rotating Specific Parts of a Video
To rotate a specific time range (e.g., from 10 seconds to 20 seconds) while keeping the rest normal, you need to filter that part and concatenate it back.

Example: ```ffmpeg -i input.mp4 -vf "between(t,10,20)*transpose=1" output.mp4```

4. Batch Rotating All Videos in a Directory (Windows PowerShell) 
You can rotate all MP4 files in a folder 90 degrees clockwise:
foreach ($i in Get-ChildItem *.mp4) { ffmpeg -i $i -vf "transpose=1" ("rot_" + $i.Name) } 

*Summary Table
Goal 	Command Filter (-vf)
90° CW	transpose=1
90° CCW	transpose=2
180°	transpose=2,transpose=2
Horizontal Flip	hflip
Vertical Flip	vflip


##scrolling text file

```
ffmpeg -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=arial.ttf:fontsize=30:fontcolor=white:x=10:y=10:text='Line One\nLine Two\nLine Three'" -codec:a copy line-one.mp4
```
```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:textfile=live.txt:reload=1:x=w-t*(w+tw)/10:y=h-th-20" -codec:a copy live-txt.mp4
```
```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x=w-t*(w+tw)/30:y=h-th-10:textfile=live.txt" live-txt.mp4
```
```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=arial.ttf:fontsize=30:fontcolor=white:x=10:y=10:textfile=live.txt" -codec:a copy live-txt.mp4
```
```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x=w-t*(w+tw)/5:y=h-th-10:textfile=live.txt" -c:a copy live-txt.mp4
```
```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -filter_complex "[0]split[txt][orig];[txt]drawtext=fontfile=arial.ttf:fontsize=55:fontcolor=white:x=(w-text_w)/2+20:y=h-20*t:textfile='live.txt':bordercolor=black:line_spacing=20:borderw=3[txt];[orig]crop=iw:50:0:0[orig];[txt][orig]overlay" -c:v libx264 -y -preset ultrafast -shortest live.txt.mp4
```

## Bottom Scroll
```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [v_no_text]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x=w-mod(t*100\,w+tw):y=h-80[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```

## Center Scroll
```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [v_no_text]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x='max((w-tw)/2, w-t*200)':y=(h-th)/2[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```

## chain with the waveform and shadow
```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [1:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=intensity:colors=white|yellow:n=1[waves_raw]; ^
 [waves_raw]split[waves_main][waves_tmp]; ^
 [waves_tmp]format=rgba,colorlevels=rimin=1:gimin=1:bimin=1:rimax=1:gimax=1:bimax=1,boxblur=luma_radius=5:luma_power=2[waves_shadow]; ^
 [v_no_text][waves_shadow]overlay=x=4:y=H-%WAVE_HEIGHT%-20+4:format=auto[v_w_shadow]; ^
 [v_w_shadow][waves_main]overlay=x=0:y=H-%WAVE_HEIGHT%-20:format=auto[v_with_waves]; ^
 [v_with_waves]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x='max((w-tw)/2, w-t*200)':y=(h-th)/2[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```

drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x='min( (w-tw)/2 , w-t*300 )':y=h-80
Target Position (w-tw)/2: This is the exact horizontal center of the screen.

Starting Position w-t*300: The text starts at the right edge (w) and moves left at 300 pixels per second.
```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [1:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=intensity:colors=white|yellow:n=1[waves_raw]; ^
 [waves_raw]split[waves_main][waves_tmp]; ^
 [waves_tmp]format=rgba,colorlevels=rimin=1:gimin=1:bimin=1:rimax=1:gimax=1:bimax=1,boxblur=luma_radius=5:luma_power=2[waves_shadow]; ^
 [v_no_text][waves_shadow]overlay=x=4:y=H-%WAVE_HEIGHT%-20+4:format=auto[v_w_shadow]; ^
 [v_w_shadow][waves_main]overlay=x=0:y=H-%WAVE_HEIGHT%-20:format=auto[v_with_waves]; ^
 [v_with_waves]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x='max((w-tw)/2, w-t*300)':y=h-100[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```

## scroll from the left and then stop and stay
The logic for the x parameter:
x='min((w-tw)/2, -tw+t*400)'

-tw: This starts the text completely off-screen to the left (negative Text Width).

t*400: This moves the text to the right at 400 pixels per second.

(w-tw)/2: This is the exact center of your screen.

min(...): This picks the smaller of the two numbers. Once the text reaches the center, -tw+t*400 becomes larger than the center point, so FFmpeg locks it at the center for the rest of the video.

The Full Command chain:

```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [1:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=intensity:colors=white|0x808080:n=1[waves_raw]; ^
 [waves_raw]split[waves_main][waves_tmp]; ^
 [waves_tmp]format=rgba,colorlevels=rimin=1:gimin=1:bimin=1:rimax=1:gimax=1:bimax=1,boxblur=luma_radius=5:luma_power=2[waves_shadow]; ^
 [v_no_text][waves_shadow]overlay=x=4:y=H-%WAVE_HEIGHT%-20+4:format=auto[v_w_shadow]; ^
 [v_w_shadow][waves_main]overlay=x=0:y=H-%WAVE_HEIGHT%-20:format=auto[v_with_waves]; ^
 [v_with_waves]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white:x='min((w-tw)/2, -tw+t*400)':y=h-100[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```
Customizing the Movement
Speed: Change 400 to a higher number to make it fly in faster, or a lower number (like 200) for a slow, smooth entrance.

## The Logic for the Scroll-Pause-Loop
The x parameter below handles the movement:

mod(t, 10+5): This creates a 15-second loop (10 seconds for the scroll/stay + 5 seconds hidden/reset).

min((w-tw)/2, -tw + (mod(t,15)*600)): This moves the text from the left (-tw) toward the center (w-tw)/2. Once it hits the center, it stays there until the 15-second cycle resets.

The Modified Command
```
ffmpeg -y -hide_banner -stream_loop -1 -i "%input_bg%" -i "%input_mp3%" ^
-filter_complex ^
"[0:v]scale=%WIDTH%:%HEIGHT%:force_original_aspect_ratio=increase,crop=%WIDTH%:%HEIGHT%,zoompan=z='min(zoom+0.0006,1.1)':d=1:s=%WIDTH%x%HEIGHT%[bg_pulsed]; ^
 [bg_pulsed]%LOGO_FILTER%[v_no_text]; ^
 [1:a]showwaves=s=%WIDTH%x%WAVE_HEIGHT%:mode=intensity:colors=white|0x808080:n=1[waves_raw]; ^
 [waves_raw]split[waves_main][waves_tmp]; ^
 [waves_tmp]format=rgba,colorlevels=rimin=1:gimin=1:bimin=1:rimax=1:gimax=1:bimax=1,boxblur=luma_radius=5:luma_power=2[waves_shadow]; ^
 [v_no_text][waves_shadow]overlay=x=4:y=H-%WAVE_HEIGHT%-20+4:format=auto[v_w_shadow]; ^
 [v_w_shadow][waves_main]overlay=x=0:y=H-%WAVE_HEIGHT%-20:format=auto[v_with_waves]; ^
 [v_with_waves]drawtext=text='%SONG_TITLE%':fontfile='%FONT_PATH%':fontsize=40:fontcolor=white@'min(1, mod(t,15)*2)':x='min((w-tw)/2, -tw+(mod(t,15)*600))':y=h-100[outv]" ^
-map "[outv]" -map 1:a -c:v libx264 -preset fast -c:a aac -b:a 192k -shortest "%outfile%"
```
What’s New in This Version:
The Loop & Pause:

mod(t, 15): This resets the animation timer every 15 seconds.

600: This is the speed. The text will fly in from the left and lock into the center quickly.

The Fade-In:

fontcolor=white@'min(1, mod(t,15)*2)': This controls the opacity (alpha).

At the start of every 15-second loop, the alpha starts at 0 (invisible) and ramps up to 1 (solid) over the first half-second (*2).

The Waveform Style:

I kept the 0x808080 gray tones to keep it looking stylish and cyberpunk-appropriate.

Adjusting the Timing
Want it to stay longer? Change the 15 to 20. This gives the text 5 extra seconds of "rest" time in the middle before it disappears and starts again from the left.

Want it to slide slower? Change 600 to 300.

Want it higher up? Change y=h-100 to y=h-200.
:: Variabel Scroll

:: Bottom Right
:: x=w-t*(w+tw)/10:y=h-th-20
:: x=w-t*(w+tw)/10:y=h-th-20w-t*(w+tw)/10:y=h-th-20
:: x=w-mod(t*100\,w+tw):y=h-80
:: x=w-mod(t*100\,w+tw):y=h-80x=w-mod(t*100\,w+tw):y=h-80

:: Bottom Right Pause
:: x='max((w-tw)/2, w-t*200)':y=h-100

:: Bottom Left Pause
:: x='min((w-tw)/2, -tw+t*400)'

:: Top Right
:: x=w-mod(t*100\,w-tw-50)':y=50
:: x=w-mod(t*100\,w-tw-50)':y=50x=w-mod(t*100\,w-tw)':y=50

:: Top Left Pause
:: x='min((w-tw)/2, -tw+t*400)':y=h-100

:: Center Right Pause
:: x='max((w-tw)/2, w-t*200)':y=(h-th)/2
:: x='max((w-tw)/2+20)':y=h-20*t

:: Pause-Loop
:: x=@'min(1, mod(t,15)*2)':x='min((w-tw)/2, -tw+(mod(t,15)*600))':y=h-100"

:: overlay=x=0:y=H-h
:: overlay=x=0:y=H-h-2
:: overlay=x=0:y=H-h:eval=init
:: overlay=x=W-w:y=H-h
:: overlay=(W-w)/2:(H-h)/2

```
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf "drawtext=fontfile=bulgia.otf:fontsize=40:fontcolor=white:text=live.txt:x=@'min(1, mod(t,15)*2)':x='min((w-tw)/2, -tw+(mod(t,15)*600))':y=(h-th)/2" -codec:a copy outputCredits.mp4
```
```
ffmpeg -i shot.mkv -i cshot.mkv -filter_complex "[0:v]scale=-1:720[cam];[1:v]scale=-1:720[scr];[cam][scr]hstack=inputs=2,drawtext=text='%t_stamp% + ':fontcolor=cyan:fontsize=32:x=w-200:y=20,drawtext=text='%%{pts\:hms}':fontcolor=cyan:fontsize=32:x=w-100:y=20[v];[0:a][1:a]amix=inputs=2[a]" -map "[v]" -map "[a]" -c:v libx264 -crf 23 -preset ultrafast Merged_%RANDOM%.mp4
```

## Screen Recording
```
ffmpeg -list_devices true -f dshow -i dummy
```
```
ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -pix_fmt yuv420p output.mp4
```
```
ffmpeg -f gdigrab -framerate 30 -i desktop -i music.mp3 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -c:a aac -map 0:v -map 1:a -shortest output.mp4
```
```
ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i video="USB2.0 VGA UVC WebCam" -c:v libx264 -pix_fmt yuv420p output.mp4
```
```
ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i audio="Stereo Mix (Synaptics SmartAudio HD)" -c:v libx264 -preset ultrafast -c:a aac -pix_fmt yuv420p output.mp4
``` 

### Error message 

`Could not find audio only device with name [Stereo Mix]` means that FFmpeg cannot find a recording device named "Stereo Mix" on your system. This is a very common issue because "Stereo Mix" is not a universal or default audio device on Windows; its name and availability depend entirely on your specific sound card driver .

Here are the steps to diagnose and fix this problem, starting with the most likely solution.

### Find the Exact Name of Your "What U Hear" Device

1.  Run the following command:
    ```bash
    ffmpeg -list_devices true -f dshow -i dummy
    ```
2.  Look for the `DirectShow audio devices` section in the output. You will see a list of your available audio input devices, which might look something like this :
    ```
    [dshow @ 000001e0034ade00] DirectShow audio devices
    [dshow @ 000001e0034ade00]  "立体声混音 (Realtek(R) Audio)"
    [dshow @ 000001e0034ade00]     Alternative name "@device_cm_{33D9A762-90C8-11D0-BD43-00A0C911CE86}\wave_{348B8A31-CF2E-42D5-A6B2-862A966A1ED0}"
    ```
    In this example, the device is actually named `立体声混音 (Realtek(R) Audio)` (which is "Stereo Mix" in Chinese). On an English system, it might be named something like `Stereo Mix (Realtek High Definition Audio)`, `What U Hear`, `Wave Out Mix`, or `Mixed Output` .

The exact name in the quotes (`" "`) is what you must use in your FFmpeg command. Copy and paste it directly from your terminal to avoid typos.

```bash
ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i audio="Stereo Mix (Realtek High Definition Audio)" -c:v libx264 -pix_fmt yuv420p output.mp4
```

### Alternative Solutions If No Device Is Found

If the `ffmpeg -list_devices ...` command **does not list any audio devices at all** under `DirectShow audio devices`, or if the device you find doesn't capture system audio, you have a few options:

*   **Enable "Stereo Mix" in Windows Sound Settings:** The device might be present but disabled. Follow these steps:
    1.  Right-click the **speaker icon** in your system tray and select **"Sounds"**.
    2.  Go to the **"Recording"** tab.
    3.  Right-click in an empty area of the list and check **"Show Disabled Devices"**.
    4.  If "Stereo Mix" appears, right-click it and select **"Enable"** .
	
*   **Use a Virtual Audio Cable:** This is a very reliable fallback. Software like **VB-Cable** or **Virtual Audio Cable** creates a new virtual audio device. You set your system's audio to output to this virtual cable, and then FFmpeg records from it. This guarantees a consistent device name (like `CABLE Input`), solving the problem permanently .
*   **Check Your Sound Card Driver:** On some systems, the "Stereo Mix" feature is not enabled in the sound card driver itself. You may need to open your sound card's control panel (e.g., Realtek HD Audio Manager) and look for an option to enable "Stereo Mix" or "Record What You Hear" .

Start with identify the correct name. In the vast majority of cases, that's all you need to do to get your screen recording command working.
```
ffmpeg -f lavfi -i color=c=white@0.0:s=1920x1080 -frames:v 1 trans.png
```
```
ffmpeg -i input.jpeg -vf "colorkey=white:0.3:0.5" trans.png
```
```
ffmpeg -i input.mp4 -i trans.png -filter_complex "[1:v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay" -vcodec libx264 -t 3 out.mkv
```
```
ffmpeg -i input.mp4 -i trans.png -filter_complex "[0]scale=1920:1080:force_original_aspect_ratio=increase,crop=1080:1920,split[m][a];[a]geq='if(lt(lum(X,Y),16),0,255)',hue=s=0[al];[m][al]alphamerge,format=yuva420p" -c:v libx264 -t 3 1910.mov
```
```
ffmpeg -y -i input.mp4 -i trans.png -filter_complex "[0:v]scale=1080:1920,split[m][a];[a]geq='if(lt(lum(X,Y),16),0,255)',hue=s=0[al];[m][al]alphamerge,format=yuva420p[v];[v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay" -c:v libx264 -t 3 1019.mov
```
```
ffmpeg -y -i input.mp4 -i trans.png -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1080:1920,split[m][a];[a]geq='if(lt(lum(X,Y),16),0,255)',hue=s=0[al];[m][al]alphamerge,format=yuva420p[v];[v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay" -c:v libx264 -t 3 1910.mkv
```
```
ffmpeg -y -i input.mp4 -i trans.png -filter_complex "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,split[m][a];[a]geq='if(lt(lum(X,Y),16),0,255)',hue=s=0[al];[m][al]alphamerge,format=yuva420p[v];[v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork];[0:v][zork]overlay" -c:v libx264 -t 3 1019.mkv
```
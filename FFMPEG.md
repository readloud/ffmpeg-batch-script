# RETIRED
Good news! There hasn't been a need to update this installer as ffmpeg has been added to `winget` for some time now. 
Simply open Terminal on Windows, paste either one of the commands in, and press ENTER. Accept the terms that appear in Terminal and the install will complete.
```
winget install --id=Gyan.FFmpeg  -e
winget install --id=Gyan.FFmpeg.Essentials  -e
winget install --id yt-dlp.yt-dlp  -e
```
```
yt-dlp -x --audio-format mp3 https://www.youtube.com/watch?v=A5roFJELMD4
```
Reference: https://winstall.app/apps/Gyan.FFmpeg and https://winstall.app/apps/Gyan.FFmpeg.Essentials

This repo will be left here for roughly 6 months from this commit (2nd, Oct, 2025) so those who starred or bookmarked can see this update.

---

# ffmpeg Install Package
Ease-of-use binary executable installers for Windows 7 and up (64bit/x64).

[![version](https://img.shields.io/badge/Download-7.0.0-blue)](https://github.com/icedterminal/ffmpeg-installer/releases/latest)

## About
`ffmpeg` is an open source command line multimedia framework to encode, decode, transcode, convert etc. a wide array of video formats. [Learn more here.](https://ffmpeg.org/about.html) For use refer to the [official documentation.](https://ffmpeg.org/documentation.html).

The build contained in this installer is obtained from [gyan.](https://www.gyan.dev/ffmpeg/builds/) No tampering or modification has occured. Simply packaged into an installer. Rather than compile my own ffmpeg build I opted to use one that is already available.

> [!NOTE]
> Windows 8 and later has a "SmartScreen" feature that blocks software that it doesn't trust. Naturally since it has never seen this software, it may warn you. The installer is safe as is the contained ffmpeg build. If you are unsure, you may cross check the ffmpeg binary with gyans archives (`get-filehash`) or upload to virus total. You may need to click "Run anyway" when the warning appears.

gyan makes a few notes regarding these builds:

> [gyan] hosts packages containing binaries of ffmpeg, ffprobe and ffplay. These are compatible with Windows 7 and above. They may work on Windows Vista but that hasn't been tested. If you're downloading ffmpeg to support features in a program such as Krita or Blender, get the release essentials build. All builds are 64-bit.

Because ffmpeg is built for 64-bit only, this installer is 64-bit only. Attempting to run it on 32-bit will fail.

Builds from gyan are as follows:

- _git full_ - built from master branch with a large set of libraries
- _git essentials_ - built from master branch with commonly-used libraries
- _release full_ - built from latest release branch with a large set of libraries
- _release essentials_ - built from latest release branch with commonly-used libraries

This repo houses installers for *release full* and *release essentials*. I make an effort to keep it updated by checking every 30 days. If there is no updated build, there is no update here. Updates can be as needed (security, critical bugs).

Why use an installer?

- Installs and uninstalls cleanly. Just like manually upacking, this leaves no traces.
- Automatically adds `ffmpeg` to PATH. No need to add this yourself.
- Fast and simple GUI for those not 100% comfortable with command line.
- Can be used for mass deployment to streamline software installation via scripting.
  - From an elevated script `> ffmpeg.msi /qr`

Installer versioning is in format: MAJOR.MINOR.BUILD.YearMonthDay (EX: 4.4.0.20210101).

## Alternative Sources
If you need more frequent updating, please use gyan's git `.7z` archives direct from the website. These are nightly builds. Gyan also publishes the release build to `winget` and the Chocolately community publishes their own build if you prefer command line installation from archives.

## Hardware Support
gyan builds are compiled with hardware acceleration enabled. Supporting the following libraries:

- AMD Advanced Media Framework
  - `--enable-amf`
- Nvidia CUDA, CUVID, NVDEC, & NVENC
  - `--enable-cuda-llvm --enable-cuvid --enable-ffnvcodec --enable-nvdec --enable-nvenc`
- Intel Quick Sync Video
  - `--enable-libmfx`
- D3D11VA
  - `--enable-d3d11va`
- DXVA2
  - `--enable-dxva2`

Refer to the `README.txt` file for more information.

# The Basic Command

Use the following command, replacing input.jpg and input.mp3 with your actual filenames:

```
ffmpeg -loop 1 -i joshua-earle-EszQhMd_sBo-unsplash.jpg -i *.mp3 -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest output.mp4
```

# Explanation of arguments:

-loop 1: Loops the input image indefinitely.
-i input.jpg: The input image file.
-i input.mp3: The input audio file.
-c:v libx264: Uses the H.264 video codec.
-tune stillimage: Optimizes for a static image.
-c:a aac: Encodes the audio to AAC format.
-pix_fmt yuv420p: Ensures compatibility with most media players.
-shortest: Forces the video to stop when the audio ends.
output.mp4: The resulting video file. 

# Troubleshooting (If the command fails)

If your image dimensions are not divisible by 2 (e.g., 1001x500), FFmpeg might throw an error. Use this version to automatically resize/pad the image: 

```
ffmpeg -loop 1 -i input.jpg -i input.mp3 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest output.mp4
```

# Batch Convert Multiple MP3s 

If you have a folder full of MP3s and one image you want to use for all of them, you can use a simple bash loop:

```
for file in *.mp3; do
    ffmpeg -loop 1 -i images.webp -i "$file" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "${file%.mp3}.mp4"
```
```
for %f in (*.mp3) do ffmpeg -loop 1 -i images.webp -i "%f" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "%~nf.mp4"
```
```
for %%f in (*.mp3) do ffmpeg -loop 1 -i images.webp -i "%%f" -c:v libx264 -tune stillimage -c:a aac -pix_fmt yuv420p -shortest "%%~nf.mp4"
```

# Add audio to video

By default, FFmpeg will only take one audio and one video stream. In your case that's taken from the first file only.
You need to map the streams correctly:
```
ffmpeg -i input.mp4 -i input.mp3 -c copy -map 0:v:0 -map 1:a:0 output.mp4
```
## Fast extraction with codec copy (recommended)
```
ffmpeg -i input_video.mp4 -vn -acodec copy output_audio.m4a
```
## Re-encode to a specific format
```
ffmpeg -i input_video.mp4 -vn -acodec libmp3lame output_audio.mp3
```
## Using the -map option
```
ffmpeg -i input_video.mp4 -map 0:a -acodec copy output_audio.m4a
```
 * Before you start, you can use ffprobe (included with FFmpeg) to inspect your file and see which audio codecs and streams are available: 'ffprobe input_video.mp4'

## Separate Audio Tracks
```
ffmpeg -i video.mp4 -i audio1.mp3 -i audio2.mp3 -map 0:v -map 1:a -map 2:a -c copy output.mp4
```
## Meta Data
```
ffmpeg -i video.mp4 -i audio1.mp3 -i audio2.mp3 -map 0:v -map 1:a -metadata:s:a:0 language=eng -map 2:a -metadata:s:a:1 language=spa -c copy output.mp4
```
##Extract Metadata (Song Titles) 

If the audio tracks have embedded metadata (titles, artists), you can view them using ffprobe: 
```bash
ffprobe -v error -show_entries format_tags=title,artist -of default=noprint_wrappers=1:nokey=1 input_video.mp4
```

Summary of Commands
|Goal 	|Command  |
|-------|---------|
|Quick Extract	|ffmpeg -i input.mp4 -vn -acodec copy output.aac|
|Convert to MP3	|ffmpeg -i input.mp4 -vn -c:a libmp3lame output.mp3|
|Trim Audio	|ffmpeg -i input.mp4 -ss 00:10 -to 00:20 -vn output.aac|

*Note: If the video contains multiple audio tracks (e.g., voice, music), you may need to use -map 0:a:1 to select the second audio stream instead of the first.
##Extract Audio without Re-encoding (Fastest) 
```bash
ffmpeg -i input_video.mp4 -vn -acodec copy output_audio.aac
```
-vn: Excludes the video stream.
-acodec copy: Copies the audio directly. 

##specific format like MP3, use:
```bash
ffmpeg -i input_video.mp4 -vn -c:a libmp3lame -q:a 2 output_audio.mp3
```
-c:a libmp3lame: Converts the audio to MP3. 

##Extract Specific Time Segments (Compilation) video is a mix of talking and music

```bash
ffmpeg -i input_video.mp4 -ss 00:01:30 -to 00:05:00 -vn -c:a copy part1.aac
```
```
ffmpeg -i input_video.mp4 -ss 00:10:00 -to 00:15:00 -vn -c:a copy part2.aac
```

##Create a Compilation (Merge/Concat) 
```text
file 'part1.aac'
file 'part2.aac'
```
```
``bash
ffmpeg -f concat -safe 0 -i list.txt -c copy output_compilation.aac
```

## Mixing Audio
```
ffmpeg -i video.mp4 -i audio1.mp3 -i audio2.mp3 -filter_complex "[1:a][2:a]amix=inputs=2[a]" -map 0:v -map "[a]" -c:v copy -shortest output.mp4
```

## Issue Reporting
Issues regarding ffmpeg should be directed elsewhere. Issues are open *only* for install and uninstall process.

FFmpeg (Most Recommended)
The most powerful and widely used open-source multimedia framework:

# Basic conversion with static image
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -c:v libx264 -c:a aac -b:a 192k -shortest output.mp4
```
# With fade effects
```
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -vf "fade=in:0:30,fade=out:st=60:d=5" -c:v libx264 -c:a aac -shortest output.mp4
```
# Add waveform visualization
```
ffmpeg -i batrawali.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a aac output.mp4
```
# crossfade transition
```
ffmpeg \
-loop 1 -t 3 -i img001.jpg \
-loop 1 -t 3 -i img002.jpg \
-loop 1 -t 3 -i img003.jpg \
-loopslideshow transition 1 -t 3 -i img004.jpg \
-loop 1 -t 3 -i img005.jpg \
-filter_complex \
"[1]fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+2/TB[f0]; \
 [2]fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+4/TB[f1]; \
 [3]fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+6/TB[f2]; \
 [4]fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+8/TB[f3]; \
 [0][f0]overlay[bg1];[bg1][f1]overlay[bg2];[bg2][f2]overlay[bg3]; \
 [bg3][f3]overlay,format=yuv420p[v]" -map "[v]" -r 25 output-crossfade.mp4
 ```
 
# slideshow transition
```
ffmpeg -y \
	-loop 1 -t 32.5 -i /tmp/Ilb2mg/0.png \
	-loop 1 -t 32.5 -i /tmp/Ilb2mg/1.png \
	-loop 1 -t 32.5 -i /tmp/Ilb2mg/2.png \
	-filter_complex "
		[0][1]xfade=transition=fade:duration=0.5:offset=32[f1];
		[f1][2]xfade=transition=fade:duration=0.5:offset=64,format=yuv420p[v]
	" -map "[v]" \
	-movflags +faststart -r 25 /tmp/output/res.mp4
```	
# swipe transition
```
 ffmpeg \
-loop 1 -t 3 -i img001.jpg \
-loop 1 -t 3 -i img002.jpg \
-loop 1 -t 3 -i img003.jpg \
-loop 1 -t 3 -i img004.jpg \
-loop 1 -t 3 -i img005.jpg \
-filter_complex \
"[0][1]xfade=transition=slideleft:duration=0.5:offset=2.5[f0]; \
[f0][2]xfade=transition=slideleft:duration=0.5:offset=5[f1]; \
[f1][3]xfade=transition=slideleft:duration=0.5:offset=7.5[f2]; \
[f2][4]xfade=transition=slideleft:duration=0.5:offset=10[f3]" \
-map "[f3]" -r 25 -pix_fmt yuv420p -vcodec libx264 output-swipe.mp4
```
# multiple different transitions
```
ffmpeg \
-loop 1 -t 3 -i img001.jpg \
-loop 1 -t 3 -i img002.jpg \
-loop 1 -t 3 -i img003.jpg \
-loop 1 -t 3 -i img004.jpg \
-loop 1 -t 3 -i img005.jpg \
-filter_complex \
"[0][1]xfade=transition=circlecrop:duration=0.5:offset=2.5[f0]; \
[f0][2]xfade=transition=smoothleft:duration=0.5:offset=5[f1]; \
[f1][3]xfade=transition=pixelize:duration=0.5:offset=7.5[f2]; \
[f2][4]xfade=transition=hblur:duration=0.5:offset=10[f3]" \
-map "[f3]" -r 25 -pix_fmt yuv420p -vcodec libx264 output-swipe-custom.mp4
```
# meltdown
```
melt \
	image2.jpg out=824 \
	image3.jpg out=824 \
	-mix 12 -mixer luma \
	image4.jpg out=812 \
	-mix 12 -mixer luma \
	-consumer avformat:/res.mp4 frame_rate_num=25 width=1920 height=1080 sample_aspect_num=1 sample_aspect_den=1
```
# Full list of Xfade filters
```
fade
wipeleft
wiperight
wipeup
wipedown
slideleft
slideright
slideup
slidedown
circlecrop
rectcrop
distance
fadeblack
fadewhite
radial
smoothleft
smoothright
smoothup
smoothdown
circleopen
circleclose
vertopen
vertclose
horzopen
horzclose
dissolve
pixelize
diagtl
diagtr
diagbl
diagbr
hlslice
hrslice
vuslice
vdslice
hblur
fadegrays
wipetl
wipetr
wipebl
wipebr
squeezeh
squeezev
zoomin
```

## Template Circular/Avectorscope
```
ffmpeg -i audio.mp3 -filter_complex "color=c=black:s=1280x720:r=30[bg];[0:a]avectorscope=s=720x720:m=circular:colors=white:zoom=1.5,format=rgba[sw];[bg][sw]overlay=x=(W-w)/2:y=(H-h)/2:shortest=1,format=yuv420p[outv]" -map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output_black.mp4
```

## Template Showwaves
```
ffmpeg -i audio.mp3 -filter_complex "color=c=black:s=1280x720:r=30[bg];[0:a]showwaves=s=1280x200:mode=cline[wave];[bg][wave]overlay=y=H-h:shortest=1,format=yuv420p[outv]" -map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output_black.mp4
```

## Template Showspectrum
```
ffmpeg -i audio.mp3 -filter_complex "color=c=black:s=1280x720:r=30[bg];[0:a]showspectrum=s=1280x400:mode=combined[v];[bg][v]overlay=y=H-h:shortest=1,format=yuv420p[outv]" -map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output_black.mp4
```
```
ffmpeg -i [AUDIO_FILE] -filter_complex "color=c=black:s=[WIDTH]x[HEIGHT]:r=30[bg];[0:a][WAVEFORM_FILTER] [wave];[bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" -map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest [OUTPUT].mp4
```
**Description:**

- `[WAVEFORM_FILTER]`: showwaves/showspectrum/avectorscope with its parameters
- `[WIDTH]x[HEIGHT]`: video resolution (e.g., 1280x720, 1920x1080)
- `[AUDIO_FILE]`: input audio file
- `[OUTPUT]`: output file name

## Template 1: Basic with Image
```
ffmpeg -loop 1 -i [BACKGROUND_IMAGE] -i [AUDIO_FILE] -filter_complex "[1:a]showwaves=s=[WIDTH]x[HEIGHT]:mode=[MODE]:colors=[COLOR1]|[COLOR2][wave];[0:v]scale=[WIDTH]:[HEIGHT][bg]; [bg][wave]overlay=shortest=1[outv]" -map "[outv]" -map 1:a -c:v libx264 -shortest [OUTPUT].mp4
```

## Template 2: Without Image (Solid Background)
```
ffmpeg -i [AUDIO_FILE] -filter_complex "showwaves=s=[WIDTH]x[HEIGHT]:mode=[MODE]:colors=[COLORS],format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy [OUTPUT].mp4
```
**Customizable Parameters:**
- `MODE`: line, cline, p2p, bar
- `COLORS`: white, cyan, yellow, red, green, blue, or combination (e.g., white|green|red)
- `WIDTH x HEIGHT`: 1280x720, 1920x1080, 640x360, etc.
---
## Add Visual On-Screen Title with Duration
```
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
```
```
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal myvideo.mp4
```
```
ffmpeg -i input.mp4 -vf "drawtext=text='Your Video ```

*Title':fontfile='/path/to/font.ttf':fontsize=50:fontcolor=white:x=(main_w-text_w)/2:y=50:enable='between(t,0,10)'" -c:a copy output_with_title.mp4

## Adding an On-Screen Timer/Timestamp Overlay

```
ffmpeg -i input.mp4 -vf "drawtext=fontfile=/path/to/font.ttf:text='%{pts\:gmtime\:1\:%%H\:\%%M\:\%%S}':fontcolor=white:fontsize=24:x=10:y=10" -c:a copy output_timer.mp4
```

## Add Title to Video Metadata
```
ffmpeg -i Hampura.mp4 -c copy -metadata title="Your Video Title" output_with_metadata.mp4
```

## Manually Set Output Video Duration
```
ffmpeg -i input.mp4 -c copy -t 60 output_60_seconds.mp4
```

## Extending a Video with Blank Duration (concat)
```
ffmpeg -f lavfi -i color=c=black:s=1920x1080:d=5 -f lavfi -i anullsrc:channel_layout=stereo:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p blank.mp4
```
Create a text file (mylist.txt) listing your files:
```
file 'input.mp4'
file 'blank.mp4'
```
```
ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4
```

## YCgCo color matrix and Full Color Range, which are non-standard for most video editing workflows. By using setparams and format=yuv420p, you manually forced the video to use the BT.709 standard, which is what YouTube and your script's filters (like hue and overlay) expect.
```
ffmpeg -i YCgCo.mp4 -vf "colorspace=all=bt709:irange=tv:ispace=bt709:itp=bt709,format=yuv420p" -c:v libx264 -crf 18 -c:a copy  anime_loop_fixed.mp4
```
```
ffmpeg -i YCgCo.mp4  -vf "colorspace=all=bt709:trc=bt709:primary=bt709:space=bt709,format=yuv420p" -c:v libx264 -crf 18 -c:a copy anime_loop_fixed.mp4
```
```
ffmpeg -i YCgCo.mp4 -vf "setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,format=yuv420p" -c:v libx264 -crf 18 -c:a copy anime_loop_fixed.mp4
```
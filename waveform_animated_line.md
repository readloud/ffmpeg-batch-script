# Classic "oscilloscope" style waveform video


https://github.com/user-attachments/assets/3e3c96ea-3e89-4345-a35f-c6aa5504b1da



```
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:colors=white,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy waveform_animated_line.mp4
```

## command codes:
 * showwaves: Converts the audio into a video stream of the waveform.

 * s=1280x720: Sets the resolution to 720p HD.

 * mode=line: Draws a continuous line rather than individual points or solid blocks.

 * format=yuv420p: Ensures compatibility with most modern video players (QuickTime, mobile, etc.).

 * -c:a copy: Perfectly preserves your original audio quality without re-encoding.

## Common Enhancements
If you want to change the aesthetic, here are a few modified versions of that command:

1. Solid "Bar" Waveform
If you prefer a filled-in look rather than a single thin line, change the mode:

```Bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=solid:colors=white,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

2. Changing the Frame Rate
By default, showwaves uses 25 fps. For a smoother, more "high-end" look, you can bump it to 60 fps:

```Bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:rate=60:colors=cyan,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy output.mp4
```

3. Adding a Background Image
If you don't want a plain black background, you can overlay the waveform on top of an image:

```Bash
ffmpeg -loop 1 -i background.jpg -i input.mp3 -filter_complex "[1:a]showwaves=s=1280x720:mode=line:colors=white:draw=full[fg]; [0:v][fg]overlay=format=auto,format=yuv420p[v]" -map "[v]" -map 1:a -c:v libx264 -c:a copy -shortest output.mp4
```

## A Quick Tip on Performance
If the encoding is taking a long time, you can add -preset veryfast before the output filename. It will result in a slightly larger file size but will finish the render much faster.

## Note: 
 ***If you get an error about "Dimensions not divisible by 2," it’s usually because of the yuv420p requirement. Your current 1280x720 is perfect and won't have this issue.***

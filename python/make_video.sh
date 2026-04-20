#!/bin/bash

# Input files
AUDIO="input.mp3"
IMAGE="cover.jpg"
OUT="output.mp4"

# 1. Get duration in seconds using ffprobe
DUR=$(ffprobe -i "$AUDIO" -show_entries format=duration -v quiet -of csv='p=0')

# 2. Calculate fade-out start time (Duration - 2 seconds)
FADE_START=$(echo "$DUR - 2" | bc)

echo "Processing $AUDIO ($DUR seconds). Fade-out starts at $FADE_START."

# 3. Run the "Final Master" FFmpeg command
ffmpeg -i "$AUDIO" -i "$IMAGE" -filter_complex \
"[1:v]scale=854:480:force_original_aspect_ratio=increase,crop=854:480,boxblur=20:10[bg]; \
 [1:v]scale=-1:350[fg]; \
 [bg][fg]overlay=(W-w)/2:(H-h)/2[combined]; \
 [0:a]compand,showwaves=size=854x120:colors=#25d3d0@0.8:draw=full:mode=line[v_glow]; \
 [v_glow]boxblur=5:2[v_blurred]; \
 [0:a]compand,showwaves=size=854x120:colors=#ffffff:draw=full:mode=line[v_sharp]; \
 [v_blurred][v_sharp]overlay=format=auto[vwave]; \
 [combined][vwave]overlay=(W-w)/2:H-140, \
 drawtext=text='SONG TITLE - ARTIST':fontcolor=white:fontsize=20:y=h-40:x=w-mod(t*80\,w+tw), \
 fade=t=in:st=0:d=2, \
 fade=t=out:st=$FADE_START:d=2[vout]; \
 [0:a]afade=t=in:st=0:d=2, \
 afade=t=out:st=$FADE_START:d=2[aout]" \
-map "[vout]" -map "[aout]" -c:v libx264 -preset fast -crf 22 -shortest "$OUT"
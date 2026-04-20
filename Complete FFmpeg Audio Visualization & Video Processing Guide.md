# Complete FFmpeg Audio Visualization & Video Processing Guide

A comprehensive reference covering waveform generation, circular visualizations, stereo effects, text overlays, logo integration, screen recording, video rotation, and advanced compositing techniques.

---

## Table of Contents

1. [Waveform Basics](#waveform-basics)
2. [Waveform Modes & Styles](#waveform-modes--styles)
3. [Background Integration](#background-integration)
4. [Stereo Visualizations](#stereo-visualizations)
5. [Circular & Radial Visualizations](#circular--radial-visualizations)
6. [VU Meters & Volume Displays](#vu-meters--volume-displays)
7. [Spectrum Analyzers](#spectrum-analyzers)
8. [Text Overlays & Title Animations](#text-overlays--title-animations)
9. [Logo & Image Overlays](#logo--image-overlays)
10. [Glow Effects](#glow-effects)
11. [Screen Recording](#screen-recording)
12. [Video Rotation](#video-rotation)
13. [Scrolling Text](#scrolling-text)
14. [Static Waveform Images](#static-waveform-images)
15. [Scale Modes](#scale-modes)
16. [Color Reference Palette](#color-reference-palette)
17. [Troubleshooting & Tips](#troubleshooting--tips)

---

## Waveform Basics

### Simplest Waveform (Line Mode)

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:colors=white,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

**Parameters:**
- `showwaves`: Converts audio into video waveform stream
- `s=1280x720`: Sets resolution to 720p HD
- `mode=line`: Draws continuous line (sharp, no blur)
- `format=yuv420p`: Ensures compatibility with most players
- `-c:a copy`: Preserves original audio quality without re-encoding

### Solid Bar Waveform

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=solid:colors=white,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Changing Frame Rate (60fps)

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:rate=60:colors=cyan,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy output.mp4
```

### Oscilloscope Style

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=point:rate=25:colors=white[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest oscilloscope.mp4 -y
```

### Waveform at Bottom of Video

```bash
ffmpeg -i input.mp4 -filter_complex "[0:a]showwaves=s=1280x202:mode=line[waveform]; [0:v][waveform]overlay=0:H-h" -c:a copy output.mp4
```

**Positioning Options:**
- `overlay=0:H-h` - Perfectly at bottom
- `overlay=0:H-h-20` - Slightly above bottom
- `overlay=(W-w)/2:(H-h)/2` - Center of frame

---

## Waveform Modes & Styles

### Mode Comparison

| Mode | Description |
|------|-------------|
| `line` | Sharp single-pixel line (no blur) |
| `cline` | Continuous line (smooth) |
| `solid` | Filled area under waveform |
| `p2p` | Point-to-point (connected dots) |
| `point` | Individual points only |
| `filled` | Filled curve |
| `intensity` | Intensity-based display |

### Line Mode (Sharpest)

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=line,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### CLine Mode (Smooth Continuous)

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=cline,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Point-to-Point Mode (Dots)

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Filled Curve

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=filled[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest filled_black.mp4
```

### ECG/Heartbeat Style

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:r=25[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest waveform_ecg.mp4
```

### Symmetrical Waveform

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showwaves=s=1280x720:mode=cline:colors=white:rate=30[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy -pix_fmt yuv420p -shortest symmetrical.mp4
```

### Split Channels (Double Wave)

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showwaves=s=1280x720:split_channels=1:colors=white|red,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy double_wave.mp4
```

### 3D Wave (avectorscope)

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=1280x720:m=ascope[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_3dwave.mp4
```

### Vector Scope

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=480x480:zoom=1.5[v]" -map "[v]" -map 0:a -c:v libx264 output_vector.mp4
```

---

## Background Integration

### Black Background (Default)

```bash
ffmpeg -i input.mp3 -f lavfi -i color=c=black:s=1280x720 -filter_complex \
"[0:a]showwaves=size=1280x720:colors=#15F4EE:draw=full:mode=line[wave]; \
 [1:v][wave]overlay=format=auto:shortest=1[v]" \
-map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy output_neon.mp4
```

Alternative with explicit color filter:

```bash
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=line:colors=white[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

### Custom Color Background

```bash
ffmpeg -i input.mp3 -f lavfi -i color=c=#f0f8ff:s=854x480 -r 25 -filter_complex \
"[0:a]compand,showwaves=size=854x480:colors=#25d3d0:draw=full:mode=line[vout]; \
 [1:v][vout]overlay=format=auto:shortest=1,format=yuv420p[v]" \
-map "[v]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Background Image (Static)

```bash
ffmpeg -loop 1 -i background.jpg -i input.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=white:draw=full[fg]; \
 [0:v][fg]overlay=format=auto,format=yuv420p[v]" \
-map "[v]" -map 1:a -c:v libx264 -c:a copy -shortest output.mp4
```

### Waveform Centered on Image

```bash
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=cline:colors=white[wave]; \
 [0:v]scale=1280:720[bg]; [bg][wave]overlay=shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

### Bottom-Aligned Waveform with Image

```bash
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=x=0:y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

### Top-Aligned Waveform

```bash
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white[wave]; \
 [0:v][wave]overlay=x=0:y=0:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 output.mp4
```

### Waveform with Transparency

```bash
ffmpeg -loop 1 -i image.jpeg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x200:mode=cline:colors=white:rate=25[sw]; \
 [sw]format=rgba,colorchannelmixer=aa=0.8[v]; \
 [0:v][v]overlay=x=0:y=H-h:eval=init[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output.mp4
```

### Converting Any Background to Black

```bash
# Original with image
ffmpeg -loop 1 -i background.jpg -i audio.mp3 -filter_complex \
"[1:a]showwaves=s=1280x720:mode=line:colors=white[v]; \
 [0:v][v]overlay=(W-w)/2:(H-h)/2:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -shortest output.mp4

# Converted to black background
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]showwaves=s=1280x720:mode=line:colors=white[wave]; \
 [bg][wave]overlay=(W-w)/2:(H-h)/2:shortest=1,format=yuv420p[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -c:a copy -shortest output.mp4
```

---

## Stereo Visualizations

### Basic Stereo Split (Left/Right Separate)

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=640x200:mode=cline:rate=25:colors=red[left]; \
 [r]showwaves=s=640x200:mode=cline:rate=25:colors=blue[right]; \
 [left][right]hstack[waves]; \
 color=c=black:s=1280x720[bg]; \
 [bg][waves]overlay=0:(H-h)/2:format=auto" \
-c:v libx264 -preset fast -crf 23 -c:a copy -shortest output_stereo_viz.mp4
```

### Mirrored Stereo (Centered Growth)

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=640x200:mode=cline:colors=red[l_wave]; \
 [r]showwaves=s=640x200:mode=cline:colors=blue[r_raw]; \
 [r_raw]hflip[r_flipped]; \
 [l_wave][r_flipped]hstack[waves]; \
 color=c=black:s=1280x720[bg]; \
 [bg][waves]overlay=0:H-h" \
-c:v libx264 -preset fast -crf 23 -c:a copy -shortest output_sides_to_center.mp4
```

### Stereo with Gap (Separated Display)

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=640x300:mode=cline:colors=red,format=rgba,colorchannelmixer=aa=0.5[l_wave]; \
 [r]showwaves=s=640x300:mode=cline:colors=blue,format=rgba[r_raw]; \
 [r_raw]hflip,colorchannelmixer=aa=0.5[r_flipped]; \
 color=c=black:s=1280x720[bg]; \
 [bg][l_wave]overlay=x=20:y=(H-h)/2:format=auto[bg_l]; \
 [bg_l][r_flipped]overlay=x=660:y=(H-h)/2:format=auto" \
-c:v libx264 -preset fast -crf 23 -c:a copy -shortest output_transparent_gapped.mp4
```

### Split Channels Stereo Colors

```bash
ffmpeg -i audio.mp3 -filter_complex "showwaves=s=1280x720:split_channels=1:colors=blue|red" -c:v libx264 -pix_fmt yuv420p output.mp4
```

### Stereo Bars (showcqt)

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showcqt=s=1280x720[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest cqt_black.mp4
```

### Rainbow Stereo (Hue Rotation)

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=630x300:mode=cline:colors=red:rate=25,format=rgba[l_v]; \
 [r]showwaves=s=630x300:mode=cline:colors=red:rate=25,format=rgba[r_v]; \
 [l_v]hue=h=t*100:s=1,colorchannelmixer=aa=0.6[l_wave]; \
 [r_v]hflip,hue=h=t*100+180:s=1,colorchannelmixer=aa=0.6[r_flipped]; \
 color=c=black:s=1280x720[bg]; \
 [bg][l_wave]overlay=x=5:y=(H-h)/2:format=auto[bg_l]; \
 [bg_l][r_flipped]overlay=x=645:y=(H-h)/2:format=auto" \
-c:v libx264 -preset fast -crf 20 -c:a copy -shortest output_rainbow_viz.mp4
```

### Glow Effect Stereo

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=630x300:mode=cline:colors=red:rate=25,format=rgba[l_v]; \
 [r]showwaves=s=630x300:mode=cline:colors=red:rate=25,format=rgba[r_v]; \
 [l_v]hue=h=t*100:s=1[l_c]; [r_v]hue=h=t*100+180:s=1[r_c]; \
 [l_c]boxblur=5:1,colorchannelmixer=aa=0.4[l_glow]; \
 [r_c]hflip,boxblur=5:1,colorchannelmixer=aa=0.4[r_glow]; \
 [l_c]colorchannelmixer=aa=0.9[l_core]; \
 [r_c]hflip,colorchannelmixer=aa=0.9[r_core]; \
 color=c=black:s=1280x720[bg]; \
 [bg][l_glow]overlay=x=5:y=(H-h)/2:format=auto[b1]; \
 [b1][r_glow]overlay=x=645:y=(H-h)/2:format=auto[b2]; \
 [b2][l_core]overlay=x=5:y=(H-h)/2:format=auto[b3]; \
 [b3][r_core]overlay=x=645:y=(H-h)/2:format=auto" \
-c:v libx264 -preset fast -crf 20 -c:a copy -shortest output_glow_viz.mp4
```

### Stereo with Reflection

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showwaves=s=630x200:mode=cline:colors=red:rate=25,format=rgba[l_v]; \
 [r]showwaves=s=630x200:mode=cline:colors=red:rate=25,format=rgba[r_v]; \
 [l_v]hue=h=t*100:s=1[l_c]; [r_v]hue=h=t*100+180:s=1[r_c]; \
 [l_c]boxblur=5:1,colorchannelmixer=aa=0.3[l_glow]; \
 [r_c]hflip,boxblur=5:1,colorchannelmixer=aa=0.3[r_glow]; \
 [l_c]colorchannelmixer=aa=0.8[l_core]; \
 [r_c]hflip,colorchannelmixer=aa=0.8[r_core]; \
 [l_c]hflip,vflip,colorchannelmixer=aa=0.2[l_refl]; \
 [r_c]hflip,vflip,colorchannelmixer=aa=0.2[r_refl]; \
 color=c=black:s=1280x720[bg]; \
 [bg][l_glow]overlay=x=5:y=(H-h)/2-10:format=auto[b1]; \
 [b1][r_glow]overlay=x=645:y=(H-h)/2-10:format=auto[b2]; \
 [b2][l_core]overlay=x=5:y=(H-h)/2-10:format=auto[b3]; \
 [b3][r_core]overlay=x=645:y=(H-h)/2-10:format=auto[b4]; \
 [b4][l_refl]overlay=x=5:y=(H-h)/2+190:format=auto[b5]; \
 [b5][r_refl]overlay=x=645:y=(H-h)/2+190:format=auto" \
-c:v libx264 -preset fast -crf 20 -c:a copy -shortest output_reflected_viz.mp4
```

---

## Circular & Radial Visualizations

### Basic Circular Waveform (avectorscope)

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]avectorscope=s=1280x720:m=circular:colors=white:zoom=1.5[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_black.mp4
```

### Circular Waveform with Image Background

```bash
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=white:zoom=1.5[sw]; \
 [0:v][sw]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest circular_bg.mp4
```

### Rotating Circular Waveform

```bash
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=white:zoom=1.5[sw]; \
 [sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot]; \
 [0:v][rot]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest output_rotating.mp4
```

### Advanced Circular Wave with GEQ Filter

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]showwaves=s=1280x720:colors=white:draw=full:mode=p2p,format=rgba, \
 geq='p(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))': \
 a='1*alpha(mod((2*W/(2*PI))*(PI+atan2(0.5*H-Y,X-W/2)),W), H-2*hypot(0.5*H-Y,X-W/2))'[outv]" \
-map "[outv]" -map 0:a -pix_fmt yuv420p waveform_circular.mp4
```

### Circular Wave with Image Background (GEQ)

```bash
ffmpeg -i input.mp3 -i background.jpg -filter_complex \
"[1:v]scale=1280:720[bg]; \
 [0:a]aformat=cl=mono,showwaves=1280x720:cline:colors=red:draw=full, \
 geq='p(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))': \
 a='alpha(mod(W/PI*(PI+atan2(H/2-Y,X-W/2)),W), H-2*hypot(H/2-Y,X-W/2))'[a]; \
 [bg][a]overlay=(W-w)/2:(H-h)/2" \
-c:v libx264 -c:a copy -shortest waveform_circular_image.mp4 -y
```

### Rotating Circular Spectrum

```bash
ffmpeg -y -i input.mp3 -filter_complex \
"[0:a]aformat=channel_layouts=mono,showfreqs=mode=bar:size=600x600:rate=25:fscale=log:colors=purple|red|green|yellow|blue,format=rgba[waves]; \
 [waves]geq=r='if(lte(sqrt((X-300)^2+(Y-300)^2),300),r(X,Y),0)':g='if(lte(sqrt((X-300)^2+(Y-300)^2),300),g(X,Y),0)':b='if(lte(sqrt((X-300)^2+(Y-300)^2),300),b(X,Y),0)':a='if(lte(sqrt((X-300)^2+(Y-300)^2),300),255,0)',rotate=angle=2*PI*t/8:fillcolor=black@0,format=rgba[circ]; \
 color=c=black:s=1920x1080[bg]; [bg][circ]overlay=(W-w)/2:(H-h)/2" \
-c:v libx264 -preset ultrafast rotating_circular.mp4
```

### Transparent Circular Wave

```bash
ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"[0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=1:gc=1:bc=1:rf=1:gf=1:bf=1[waveform]; \
 [waveform]format=rgba,rotate=5:c=none[rotated]; \
 [rotated][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60:alpha=if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4
```

### Circular Wave with Black Background

```bash
ffmpeg -i audio.mp3 -i logo.png -filter_complex \
"color=c=black:s=720x720:r=30[bg]; \
 [0:a]avectorscope=s=720x720:mode=circle:zoom=1.3:rc=0:gc=1:bc=0:rf=1:gf=1:bf=1,format=rgba[waveform]; \
 [bg][waveform]overlay=0:0[withbg]; \
 [withbg][1:v]overlay=10:10[withlogo]; \
 [withlogo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=H-60[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy output.mp4
```

### Combined Circular Waveform + Stereo VU (Split-Screen)

```bash
ffmpeg -loop 1 -i input.png -i input.mp3 -filter_complex \
"[1:a]asplit=2[a_circ][a_vu]; \
 [a_circ]showwaves=s=600x600:mode=line:colors=0x00CCFF:draw=full[v_wave]; \
 [v_wave]format=rgba,geq=r='r(X,Y)':a='if(between(hypot(X-W/2,Y-H/2),W/4,W/2),alpha(X,Y),0)'[v_circle]; \
 [a_vu]channelsplit=channel_layout=stereo[l][r]; \
 [l]showvolume=b=4:w=500:h=30:c=0x29FF14[l_v]; \
 [r]showvolume=b=4:w=500:h=30:c=0x29FF14[r_raw]; \
 [r_raw]hflip[r_v]; \
 [l_v][r_v]hstack=inputs=2[v_meter]; \
 [0:v][v_circle]overlay=x=(W-w)/2:y=(H-h)/2-100:shortest=1[bg_circ]; \
 [bg_circ][v_meter]overlay=x=(W-w)/2:y=H-100[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest combined_cyber_viz.mp4
```

**Technical Breakdown:**
- `asplit=2`: Creates two audio copies (one for circle, one for VU)
- `hypot(X-W/2,Y-H/2)`: Calculates pixel distance from center
- `between(..., W/4, W/2)`: Restricts waveform to ring area
- `channelsplit`: Separates left/right for stereo response
- `hflip`: Mirrors right channel for symmetric growth

---

## VU Meters & Volume Displays

### Basic VU Meter

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showvolume=b=4:w=1280:h=50[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest waveform_vu.mp4
```

### VU Meter with Fade (Arc Style)

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showvolume=f=0.5:w=1280:h=50[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest waveform_arc.mp4
```

### Stereo VU Meter (Mirrored)

```bash
ffmpeg -i input.mp3 -filter_complex \
"[0:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showvolume=b=4:w=960:h=50[l_wave]; \
 [r]showvolume=b=4:w=960:h=50[r_raw]; \
 [r_raw]hflip[r_flipped]; \
 [l_wave][r_flipped]hstack[v]" \
-map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest stereo_vu.mp4
```

### Clean Stereo VU with Image Background

```bash
ffmpeg -loop 1 -i input.png -i input.mp3 -filter_complex \
"[1:a]channelsplit=channel_layout=stereo[l][r]; \
 [l]showvolume=b=4:w=600:h=40:c=0x29FF14[l_wave]; \
 [r]showvolume=b=4:w=600:h=40:c=0x15F4EE[r_raw]; \
 [r_raw]hflip[r_flipped]; \
 [l_wave][r_flipped]hstack=inputs=2[v_meter]; \
 [0:v][v_meter]overlay=x=(W-w)/2:y=H-150:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest clean_stereo_vu.mp4
```

### Animated VU Meter

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showvolume=b=5:w=1280:h=60:o=h:v=1:p=0.5:t=0:f=0" -c:v libx264 output_vumeter.mp4
```

---

## Spectrum Analyzers

### Classic Bars Spectrum (Black Background)

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showspectrum=s=1280x720:mode=combined[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest waveform_spectrum_black.mp4
```

### Fire Spectrum

```bash
ffmpeg -i input.mp3 -filter_complex "[0:a]showspectrum=s=1920x1080:mode=combined:color=fire:scale=log[v]" -map "[v]" -map 0:a -c:v libx264 waveform_spectrum_fire.mp4
```

### Spectrum with Image Background

```bash
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -filter_complex \
"[1:a]showspectrum=s=1280x400:mode=combined[v]; \
 [0:v][v]overlay=y=H-h:shortest=1[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest spectrum_bg.mp4
```

### Frequency Spectrum

```bash
ffmpeg -i audio.mp3 -filter_complex "[0:a]showfrequency=s=1280x720[v]" -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a copy -shortest freq_black.mp4
```

### Scrolling Spectrum

```bash
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]showspectrum=s=1280x720:mode=line:color=intensity:slide=scroll:fps=30[v]" \
-map "[v]" output_video.mp4
```

---

## Text Overlays & Title Animations

### Centered Title with Shadow

```bash
ffmpeg -i input.mp4 -filter_complex \
"drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:fontweight=bold:x=(w-text_w)/2:y=(h-text_h)/2-30:shadowcolor=black@0.7:shadowx=3:shadowy=3" \
-c:a copy output.mp4
```

### Title with Subtitle

```bash
ffmpeg -i input.mp4 -filter_complex \
"drawtext=text='VIDEO TITLE':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-100:shadowcolor=black@0.7:shadowx=3:shadowy=3, \
 drawtext=text='Subtitle or Description':fontcolor=#CCCCCC:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2-40" \
-c:a copy output.mp4
```

### Fading Text Animation

```bash
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [bg]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=40:x=(W-text_w)/2:y=H-120: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))', \
 drawtext=text='%{pts\:gmtime\:0\:%M\\\:%S}':fontcolor=white:fontsize=30:x=(W-text_w)/2:y=H-70: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))'[outv]" \
-map "[outv]" -map 0:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy -shortest output.mp4
```

### Timestamp Display

```bash
ffmpeg -i input.mp4 -filter_complex \
"drawtext=text='%{pts\:hms}':fontcolor=cyan:fontsize=16:x=10:y=10, \
 drawtext=text='Duration: 00:02:30':fontcolor=yellow:fontsize=16:x=w-180:y=10" \
-c:a copy output.mp4
```

### Text with Background Box

```bash
ffmpeg -i input.mp4 -filter_complex \
"drawtext=text='Subtitle or Description':fontcolor=white:fontsize=28:x=(w-text_w)/2:y=(h-text_h)/2-40:box=1:boxcolor=black@0.5:boxborderw=10" \
-c:a copy output.mp4
```

### Multiple Text Overlays

```bash
ffmpeg -i input.mp4 -filter_complex \
"drawtext=fontfile=KGTeacherJordan.ttf:text='The Best Darso':fontsize=48:fontcolor=white:x=(w-tw)/2:y=h-th-2, \
 drawtext=fontfile=RitualoftheWitch.ttf:text='Mawar Bodas':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2, \
 drawtext=fontfile=SuperWonder.ttf:text='%{pts\:hms}':x=(w-text_w-10):y=(h-text_h-10):fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5" \
-y output.mp4
```

---

## Logo & Image Overlays

### Basic Logo Overlay (Top Right)

```bash
ffmpeg -i input.mp4 -i logo.png -filter_complex \
"[1:v]scale=100:-1[logo_small]; [0:v][logo_small]overlay=W-w-20:20" \
-c:a copy output.mp4
```

### Logo with Transparency

```bash
ffmpeg -i input.mp4 -i logo.png -filter_complex \
"[1:v]format=rgba,colorchannelmixer=aa=0.8[logo_trans]; [0:v][logo_trans]overlay=10:10" \
-c:a copy output.mp4
```

### Logo Position Reference

```bash
# Top Left
overlay=20:20

# Top Right
overlay=W-w-20:20

# Bottom Left
overlay=20:H-h-20

# Bottom Right
overlay=W-w-20:H-h-20

# Center
overlay=(W-w)/2:(H-h)/2
```

### Animated Logo (Fade In)

```bash
ffmpeg -i input.mp4 -i logo.png -filter_complex \
"[1:v]scale=100:-1,format=rgba,colorchannelmixer=aa='if(lt(t,2),t/2,1)'[logo_fade]; \
 [0:v][logo_fade]overlay=W-w-20:20" \
-c:a copy output.mp4
```

---

## Glow Effects

### Waveform with Glow

```bash
ffmpeg -i audio.mp3 -loop 1 -i image.jpg -filter_complex \
"[1:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; \
 [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; \
 [top][blurred]blend=all_mode=addition[glow]; \
 [0:v][glow]overlay=y=H-h:shortest=1[final]" \
-map "[final]" -map 1:a -c:v libx264 -pix_fmt yuv420p output_glow.mp4
```

### Glow with Black Background

```bash
ffmpeg -i audio.mp3 -filter_complex \
"color=c=black:s=1280x720:r=30[bg]; \
 [0:a]aformat=channel_layouts=mono,showwaves=s=1280x720:mode=cline:colors=white[v]; \
 [v]split[top][bottom]; [bottom]gblur=sigma=10[blurred]; \
 [top][blurred]blend=all_mode=addition[glow]; \
 [bg][glow]overlay=y=(H-h)/2:shortest=1,format=yuv420p[final]" \
-map "[final]" -map 0:a -c:v libx264 -c:a copy -shortest output_glow.mp4
```

### Circular Waveform with Complete Glow + Logo + Text

```bash
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -i logo.png -filter_complex \
"[1:a]avectorscope=s=720x720:m=circular:colors=cyan|purple:zoom=1.3[sw]; \
 [sw]format=rgba,rotate=a=t*0.5:c=none:ow=rotw(a):oh=roth(a)[rot]; \
 [rot]split[main][glow]; [glow]boxblur=10:5[glow_blurred]; \
 [main][glow_blurred]mergeplanes=0x00010203:0x00010203[final_sw]; \
 [0:v][final_sw]overlay=x=(W-w)/2:y=(H-h)/2:format=auto[bg_wave]; \
 [bg_wave][2:v]overlay=W-w-20:20[bg_logo]; \
 [bg_logo]drawtext=text='YOUR SONG TITLE':fontcolor=white:fontsize=45:x=(W-text_w)/2:y=H-120: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))', \
 drawtext=text='%{pts\:gmtime\:0\:%M\\\:%S}':fontcolor=white:fontsize=30:x=(W-text_w)/2:y=H-70: \
 alpha='if(lt(t,1),0,if(lt(t,4),(t-1)/3,1))'[outv]" \
-map "[outv]" -map 1:a -c:v libx264 -pix_fmt yuv420p -preset fast -c:a copy -shortest output_pro.mp4
```

---

## Screen Recording

### List Available Devices

```bash
ffmpeg -list_devices true -f dshow -i dummy
```

### Basic Screen Recording

```bash
ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -pix_fmt yuv420p output.mp4
```

### Screen Recording with Audio

```bash
ffmpeg -f gdigrab -framerate 30 -i desktop -i music.mp3 \
-c:v libx264 -pix_fmt yuv420p -preset ultrafast -c:a aac -map 0:v -map 1:a -shortest output.mp4
```

### Screen Recording with Webcam

```bash
ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i video="USB2.0 VGA UVC WebCam" \
-c:v libx264 -pix_fmt yuv420p output.mp4
```

### Screen Recording with System Audio

```bash
ffmpeg -f gdigrab -framerate 30 -i desktop -f dshow -i audio="Stereo Mix (Realtek High Definition Audio)" \
-c:v libx264 -preset ultrafast -c:a aac -pix_fmt yuv420p output.mp4
```

### Find Correct Audio Device Name

```bash
ffmpeg -list_devices true -f dshow -i dummy
# Look for DirectShow audio devices section
```

---

## Video Rotation

### Transpose Filter (90° Increments - Recommended)

```bash
# 90° Clockwise
ffmpeg -i input.mp4 -vf "transpose=1" -c:a copy output.mp4

# 90° Counter-Clockwise
ffmpeg -i input.mp4 -vf "transpose=2" -c:a copy output.mp4

# 180° Rotation
ffmpeg -i input.mp4 -vf "transpose=2,transpose=2" -c:a copy output.mp4

# 90° Clockwise + Vertical Flip
ffmpeg -i input.mp4 -vf "transpose=3" -c:a copy output.mp4
```

**Transpose Options:**
- `0` = 90° CCW and vertical flip (default)
- `1` = 90° Clockwise
- `2` = 90° Counter-clockwise
- `3` = 90° Clockwise and vertical flip

### Rotate Filter (Arbitrary Angles)

```bash
# 45 degrees
ffmpeg -i input.mp4 -vf "rotate=45*PI/180" output.mp4

# 30 degrees counter-clockwise
ffmpeg -i input.mp4 -vf "rotate=-30*PI/180" output.mp4
```

### Rotation Metadata (No Re-encoding)

```bash
# Rotate 90 degrees
ffmpeg -i input.mp4 -display_rotation 90 -c:v copy output.mp4

# Rotate 180 degrees
ffmpeg -i input.mp4 -display_rotation 180 -c:v copy output.mp4

# Rotate 270 degrees
ffmpeg -i input.mp4 -display_rotation 270 -c:v copy output.mp4
```

### Batch Rotate (Windows PowerShell)

```bash
foreach ($i in Get-ChildItem *.mp4) { ffmpeg -i $i -vf "transpose=1" ("rot_" + $i.Name) }
```

### Batch Rotate (Linux/Mac)

```bash
for f in *.mp4; do ffmpeg -i "$f" -vf "transpose=1" "rotated_$f"; done
```

---

## Scrolling Text

### Basic Bottom Scroll

```bash
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf \
"drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x=w-t*(w+tw)/10:y=h-th-20:textfile=live.txt" \
-codec:a copy live-txt.mp4
```

### Right to Left Scroll (Continuous)

```bash
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf \
"drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x=w-mod(t*100\,w+tw):y=h-80:textfile=live.txt" \
-c:a copy output.mp4
```

### Scroll and Stop at Center (Left to Right)

```bash
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf \
"drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x='min((w-tw)/2, -tw+t*400)':y=h-100:textfile=live.txt" \
-c:a copy output.mp4
```

### Scroll and Stop at Center (Right to Left)

```bash
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf \
"drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white:x='max((w-tw)/2, w-t*200)':y=h-100:textfile=live.txt" \
-c:a copy output.mp4
```

### Loop-Pause-Reset Scroll Animation

```bash
ffmpeg -y -f lavfi -i color=c=black:s=1280x720:d=30 -vf \
"drawtext=fontfile=arial.ttf:fontsize=40:fontcolor=white@'min(1, mod(t,15)*2)':x='min((w-tw)/2, -tw+(mod(t,15)*600))':y=(h-th)/2:textfile=live.txt" \
-c:a copy outputCredits.mp4
```

### Scrolling Text Variables Reference

| Position | X Expression |
|----------|--------------|
| Bottom Right | `x=w-t*(w+tw)/10:y=h-th-20` |
| Bottom Right (continuous) | `x=w-mod(t*100\,w+tw):y=h-80` |
| Bottom Right Pause | `x='max((w-tw)/2, w-t*200)':y=h-100` |
| Bottom Left Pause | `x='min((w-tw)/2, -tw+t*400)'` |
| Top Right | `x=w-mod(t*100\,w-tw-50):y=50` |
| Center Right Pause | `x='max((w-tw)/2+20)':y=h-20*t` |
| Center | `x='max((w-tw)/2, w-t*200)':y=(h-th)/2` |

---

## Static Waveform Images

### Basic Waveform Image

```bash
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=640x120" -frames:v 1 output.png
```

### Double Waveform Image

```bash
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=640x240:split_channels=1:colors=white|white" -frames:v 1 output.png
```

### Split Channel Image

```bash
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=640x240:split_channels=1" -frames:v 1 output.png
```

### Spectrogram Image

```bash
ffmpeg -i input_file.mp3 -lavfi showspectrumpic=s=800x400:mode=separate spectrogram.png
```

### Colored Waveform Image

```bash
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=1280x720:colors=blue|yellow" -frames:v 1 output.png
```

### Waveform with Dark Background

```bash
ffmpeg -i audio.mp3 -filter_complex "color=s=1280x240:c=black[bg];[0:a]showwavespic=s=1280x240:colors=white[fg];[bg][fg]overlay" -frames:v 1 output.png
```

### Transparent Background Image

```bash
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=640x120:colors=white:bg=0x00000000" -frames:v 1 output.png
```

### Advanced Colored Waveform Image

```bash
ffmpeg -i audio.mp3 -filter_complex \
"[0:a]aformat=channel_layouts=mono,compand=gain=-6,showwavespic=s=600x120:colors=#9cf42f[fg]; \
 color=s=600x120:color=#44582c,drawgrid=width=iw/10:height=ih/5:color=#9cf42f@0.1[bg]; \
 [bg][fg]overlay=format=auto,drawbox=x=(iw-w)/2:y=(ih-h)/2:w=iw:h=1:color=#9cf42f" \
-frames:v 1 output.png
```

---

## Scale Modes

### Linear Scale (Default)

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=lin,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Logarithmic Scale

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=log,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

### Square Root Scale

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=sqrt,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy waveform_scale_sqrt.mp4
```

### Cube Root Scale

```bash
ffmpeg -i input.mp3 -r 25 -filter_complex "[0:a]compand,showwaves=size=854x480:colors=white:draw=full:mode=p2p:scale=cbrt,format=yuv420p[vout]" -map "[vout]" -map 0:a -c:v libx264 -c:a copy output.mp4
```

---

## Color Reference Palette

| Visual Style | Hex Code | FFmpeg Format |
|--------------|----------|---------------|
| **Aquamarine** | `7fffd4` | `0x7fffd4` |
| **Blue** | `4666FF` | `0x4666FF` |
| **Cyan** | `00CCFF` | `0x00CCFF` |
| **Deep Azure Blue** | `007FFF` | `0x007FFF` |
| **Deep Sky Blue** | `00bfff` | `0x00bfff` |
| **Electric Cyan** | `00ffff` | `0x00ffff` |
| **Emerald Green** | `50C878` | `0x50C878` |
| **Ice White/Blue** | `f0f8ff` | `0xf0f8ff` |
| **Electric Yellow** | `FFF01F` | `0xFFF01F` |
| **Silver** | `B0B0B0` | `0xB0B0B0` |
| **Spring** | `00FF7F` | `0x00FF7F` |
| **Gold** | `FFD700` | `0xFFD700` |
| **Goldenrod** | `daa520` | `0xdaa520` |
| **Orange** | `FF4500` | `0xFF4500` |
| **Neon Green** | `#29FF14` | `0x29FF14` |
| **Neon Blue** | `#15F4EE` | `0x15F4EE` |
| **Neon Purple** | `#BC13FE` | `0xBC13FE` |
| **Neon Pink** | `ff00ff` | `0xff00ff` |
| **Neon Red Vibrant** | `E30303` | `0xE30303` |
| **Neon Red** | `E60000` | `0xE60000` |
| **Neon Lime** | `66FF00` | `0x66FF00` |
| **Neon Yellow** | `CFFF04` | `0xCFFF04` |
| **Electric Green** | `0FFF50` | `0x0FFF50` |
| **Electric Yellow** | `F8FF00` | `0xF8FF00` |
| **Electric Lime** | `89F336` | `0x89F336` |
| **Electric Purple** | `BF00FE` | `0xBF00FE` |
| **Electric Red** | `#FF073A` | `0xFF073A` |

---

## Troubleshooting & Tips

### Performance Optimization

```bash
# Fast encoding (larger file)
ffmpeg -i input.mp3 ... -preset veryfast output.mp4

# Ultra fast (largest file)
ffmpeg -i input.mp3 ... -preset ultrafast output.mp4

# Best quality (slower)
ffmpeg -i input.mp3 ... -preset slow -crf 18 output.mp4
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **Dimensions not divisible by 2** | Use even dimensions like 1280x720 or 1920x1080 |
| **Slow encoding** | Add `-preset veryfast` or `-preset ultrafast` |
| **Blurry waveform** | Use `mode=line` or `mode=point` instead of `mode=solid` |
| **Audio/video sync issues** | Add `-shortest` flag |
| **No video output** | Ensure `format=yuv420p` for compatibility |
| **Font errors** | Specify valid font path or use `font='Sans'` |
| **Stereo Mix not found** | Check device name with `ffmpeg -list_devices true -f dshow -i dummy` |

### YCgCo Color Space Fix

```bash
ffmpeg -i YCgCo.mp4 -vf "colorspace=all=bt709:irange=tv:ispace=bt709:itp=bt709,format=yuv420p" -c:v libx264 -crf 18 -c:a copy anime_loop_fixed.mp4

# Alternative
ffmpeg -i YCgCo.mp4 -vf "setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,format=yuv420p" -c:v libx264 -crf 18 -c:a copy anime_loop_fixed.mp4
```

### Useful Filters Quick Reference

| Filter | Purpose |
|--------|---------|
| `showwaves` | Audio waveform visualization |
| `showvolume` | VU meter display |
| `showspectrum` | Frequency spectrum analyzer |
| `avectorscope` | Vector/3D audio visualization |
| `showcqt` | Constant Q transform (stereo bars) |
| `showfreqs` | Frequency bars visualization |
| `drawtext` | Text overlays |
| `overlay` | Image/video compositing |
| `rotate` | Video rotation |
| `transpose` | 90° rotation increments |
| `hflip` / `vflip` | Mirror horizontally/vertically |
| `channelsplit` | Separate stereo channels |
| `geq` | Pixel-level manipulation |
| `gblur` / `boxblur` | Blur effects |
| `colorchannelmixer` | Alpha/color adjustments |
| `hstack` / `vstack` | Stack videos horizontally/vertically |

### Pro Tips

1. **YouTube Shorts (9:16)**: Change size to `1080x1920` and adjust overlay coordinates
2. **Color Format**: Use `0x` prefix for hex colors in FFmpeg
3. **Transparency**: Use `format=rgba` or `format=argb` with appropriate codec (qtrle, prores)
4. **Background Scaling**: Ensure background image matches output resolution to avoid scaling overhead
5. **Audio Quality**: Use `-c:a copy` to preserve original audio without re-encoding
6. **Duration Control**: Always add `-shortest` when using `-loop 1` with images
7. **No Blur**: Use `mode=line` or `mode=point` in `showwaves` to avoid piled-up look
8. **Batch Processing**: Use loops to process multiple files with same settings
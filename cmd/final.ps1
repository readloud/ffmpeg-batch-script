# --- SETTINGS ---
$slidePath       = "C:\Users\svn\Pictures\YT_Images"
$audioFile       = "Trance.mp3"
$fontFile        = "Buda.ttf" 
$slideDuration   = 5       
$watermarkText   = "READLOUD 🖤" 

Set-Location -Path $slidePath

$images = Get-ChildItem -File | Where-Object { $_.Extension -match "jpg|jpeg|png|jfif|webp|bmp" } | Select-Object -ExpandProperty Name
$numImages = $images.Count
$totalDuration = ($numImages * $slideDuration)
$globalFadeStart = $totalDuration - 2
$audioIndex = $numImages 

$ffmpegArgs = @()
# IMPORTANT: -loop 1 is removed here to prevent the "1 hour" runaway video
foreach ($img in $images) { $ffmpegArgs += "-t", "$slideDuration", "-i", "$img" }
$ffmpegArgs += "-i", $audioFile 

# 4. Filter Complex (Glitch + CRT)
$filter = ""
for ($i=0; $i -lt $numImages; $i++) {
    $bg = "[$($i):v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=20:10,hue=s=0,noise=alls=10:allf=t+u[bg$i];"
    $fg = "[$($i):v]scale=1080:1920:force_original_aspect_ratio=decrease,format=yuva420p," +
          "zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=125:s=1080x1920," +
          "rgbashift=rh=6:bv=-6:gh=2," + 
          "drawgrid=w=1080:h=4:t=2:c=black@0.4," + 
          "rotate='0.1*PI*t:fillcolor=black@0',setsar=1[fg$i];"
    $merge = "[bg$i][fg$i]overlay=(W-w)/2:(H-h)/2," +
             "fade=t=in:st=0:d=0.5,fade=t=out:st=4.5:d=0.5," +
             "setsar=1,format=yuv420p[$i];"
    $filter += $bg + $fg + $merge
}

$concatInputs = ""
for ($i=0; $i -lt $numImages; $i++) { $concatInputs += "[$i]" }

$finalVideoChain = "${concatInputs}concat=n=${numImages}:v=1:a=0," +
                   "drawtext=fontfile='${fontFile}':text='${watermarkText}':fontcolor=0x00FFFF@0.5:fontsize=42:x=(w-text_w)/2:y=100," +
                   "fade=t=out:st=${globalFadeStart}:d=2,format=yuv420p[v]"

$finalAudioChain = "[${audioIndex}:a]afade=t=out:st=${globalFadeStart}:d=2[a]"

$filter += $finalVideoChain + ";" + $finalAudioChain

# 5. Export with SHORTEST flag
$ffmpegArgs += "-filter_complex", $filter
$ffmpegArgs += "-map", "[v]", "-map", "[a]"
$ffmpegArgs += "-c:v", "libx264", "-preset", "veryfast", "-crf", "22", "-pix_fmt", "yuv420p", "-shortest", "final_fixed_time.mp4"

& ffmpeg $ffmpegArgs
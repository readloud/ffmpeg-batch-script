Audio data is often represented by a waveform image. This guide explains how to
easily create such an image or video.

= Waveform image =

The [https://ffmpeg.org/ffmpeg-filters.html#showwavespic showwavespic] filter is the easiest method to create a waveform image.

== All channels ==

[[Image(showwavespic.png)]]

{{{
ffmpeg -i input -filter_complex "showwavespic=s=640x120" -frames:v 1 output.png
}}}

All channels will be represented by various shades in the waveform.

== Downmixed ==

[[Image(showwavespic_mono.png)]]

If you want a simpler representation where all channels are represented by one waveform you can downmix your audio to mono first with [https://ffmpeg.org/ffmpeg-filters.html#aformat aformat]:

{{{
ffmpeg -i input -filter_complex "aformat=channel_layouts=mono,showwavespic=s=640x120" -frames:v 1 output.png
}}}

== Separate channels ==

[[Image(showwavespic_split.png)]]

If you want to split them into separate channels:

{{{
ffmpeg -i input -filter_complex "showwavespic=s=640x240:split_channels=1" -frames:v 1 output.png
}}}

== Changing range ==

[[Image(showwavespic_compand.png)]]

If the waveform looks a little flat you can use the [https://ffmpeg.org/ffmpeg-filters.html#compand compand] filter to expand or compress the dynamic range:

{{{
ffmpeg -i input -filter_complex "compand,showwavespic=s=640x120" -frames:v 1 output.png
}}}

Note that this won't be as accurate of a representation as it would without compand, but for aesthetics it may be preferred.

== Adding a background ==

[[Image(showwavespic_bg.png)]]

Using [https://ffmpeg.org/ffmpeg-filters.html#overlay overlay]:

{{{
ffmpeg -i input -i background.png -filter_complex "[0:a]showwavespic=s=640x240[fg];[1:v][fg]overlay=format=auto" -frames:v 1 output.png
}}}

* This example assumes the background is the same width and height as the waveform. If it is not, you can [https://ffmpeg.org/ffmpeg-filters.html#scale scale], [https://ffmpeg.org/ffmpeg-filters.html#crop crop], or [https://ffmpeg.org/ffmpeg-filters.html#pad pad] the background first.

* The waveform color can be modified with the `colors` option in showwavespic.

=== Add a solid background color ===

[[Image(showwavespic_bg_solid.png)]]

{{{
ffmpeg -i in.flac -f lavfi -i color=c=black:s=640x320 -filter_complex \
  "[0:a]showwavespic=s=640x320:colors=white[fg];[1:v][fg]overlay=format=auto" \
  -frames:v 1 out.png
}}}

== Audacity-like look ==

[[Image(showwavespic_like_audacity.png)]]

{{{
size="640x240"
bg_col="#c0c0c0"
peak_col="#3232c8"
rms_col="#6464dc"

ffmpeg -i input.wav -f lavfi -i "color=c=${bg_col}:s=${size}" -filter_complex " \
    [0:a] showwavespic=s=${size}:split_channels=1:colors=${peak_col}:filter=peak [pk]; \
    [0:a] showwavespic=s=${size}:split_channels=1:colors=${rms_col} [rms], \
    [pk] [rms] overlay=format=auto [nobg], [1:v] [nobg] overlay=format=auto" \
    -frames:v 1 -update true output.png
}}}

= Waveform video =

[[Image(showwaves.png)]]

The [https://ffmpeg.org/ffmpeg-filters.html#showwaves showwaves] filter makes a video waveform.

{{{
ffmpeg -i input -filter_complex "[0:a]showwaves=s=1280x720:mode=line,format=yuv420p[v]" -map "[v]" -map 0:a -c:v libx264 -c:a copy output.mkv 
}}}

----

= Using Gnuplot =

== Single Channel ==

Plotting a single channel waveform is easier as the data can be passed to
Gnuplot directly. The basic idea here is to generate a specific binary format
for the audio data which then can be read and interpreted automatically with
Gnuplot.

The following command will generate a stream of raw binary data with two bytes
representing each sample. The input format does not matter as long as there is
an audio stream. If it is a multi-channel audio stream, the channels will be
mixed into one.

{{{
  ffmpeg -i in.mkv -ac 1 -map 0:a -c:a pcm_s16le -f data -
}}}

Since audio usually comes with a lot of samples per second (e.g. 44100 samples
per second for CD audio) it is usually a good idea to reduce the amount of data
to increase speed and decrease memory consumption. Note that reducing the
samplerate too much might distort the generated waveform. A good value to use
is usually 8000 samples per second. The modified command line to do that would
look like this:

{{{
  ffmpeg -i "$1" -ac 1 -filter:a aresample=8000 -map 0:a -c:a pcm_s16le -f data -
}}}

Now what is left is the letting Gnuplot create the waveform image from these
data. For that we need a plot command that deals with the output from FFmpeg.

{{{
  plot '<cat' binary filetype=bin format='%int16' endian=little array=1:0 with lines;
}}}

This plot command reads from stdin where it expects a one dimensional array of
two byte, little endian, signed integer representing the pcm vales. These are
then plotted with lines.

We can already try this out by combining those commands. Note that the live
rendering using the graphical user interface of Gnuplot is rather slow so you
don't want to throw too many data at it. Use a short audio file or limit the
duration using the '-t' option to plot only a part of the file.

{{{
  ffmpeg -i in.wav -ac 1 -filter:a aresample=8000 -map 0:a -c:a pcm_s16le -f data - | \
    gnuplot -p -e "plot '<cat' binary filetype=bin format='%int16' endian=little array=1:0 with lines;"
}}}

This should result in something like this:

[[Image(gnuplot_window.png)]]

Here we already got the waveform, but usually we don't need axis, labels,
scales etc. Also the aspect ratio is not optimal. It should rather be something
like '1:10'. Hence we need to extend the plot command.

{{{
  set terminal png size 5000,500;
  set output 'waveform.png';

  unset key;
  unset tics;
  unset border;
  set lmargin 0;
  set rmargin 0;
  set tmargin 0;
  set bmargin 0;

  plot '<cat' binary filetype=bin format='%int16' endian=little array=1:0 with lines;
}}}

This will make Gnuplot generate a PNG image with the dimension of 5000x500
pixel as output and store it in a file named 'waveform.png'. It also removes all
labels, axis and other non-data from the image and set all margins to zero.

All this can still be specified using the command line, but it is much more
convenient to put all the plot commands in a separate file and pass that one to
Gnuplot. Assuming the plot commands are stored in 'waveform.gnuplot', a valid
command line to generate a waveform image would then be:

{{{
  ffmpeg -i in.mp3 -ac 1 -filter:a aresample=8000 -map 0:a -c:a pcm_s16le -f data - | \
    gnuplot waveform.gnuplot
}}}

The result should then look somewhat like this.

[[Image(ac1.png)]]


== Multiple Channels ==

While the basic idea and the command for plotting multiple channels remain the
same, we cannot simply pipe the data into Gnuplot since the channels have to be
plotted separately. Thus we first use FFmpeg to extract the data for all
channels and then plot the data in a second step.

An FFmpeg command line to extract the audio channel data into separate files,
prepared for Gnuplot could look like this:

{{{
  ffmpeg -i in.mp4 -ac 2 -filter_complex:a '[0:a]aresample=8000,asplit[l][r]' \
    -map '[l]' -c:a pcm_s16le -f data /tmp/plot-waveform-ac1 \
    -map '[r]' -c:a pcm_s16le -f data /tmp/plot-waveform-ac2
}}}

This would again downsample the data, but then split the audio channels into
separate streams and store them in two files. One for each channel.

A plot command for this would then look like this:

{{{
  set terminal png size 5000,1000;
  set output 'waveform.png';

  unset key;
  unset tics;
  unset border;
  set lmargin 0;
  set rmargin 0;
  set tmargin 0;
  set bmargin 0;

  set multiplot layout 2,1;
  plot '/tmp/plot-waveform-ac1' binary filetype=bin format='%int16' endian=little array=1:0 with lines;
  plot '/tmp/plot-waveform-ac2' binary filetype=bin format='%int16' endian=little array=1:0 with lines;
  unset multiplot;
}}}

The resulting image would then look like this:

[[Image(ac2.png)]]


== Additional Hints ==

Sometimes there are a few loud pitches while the rest of the data is relatively
quiet. These pitches would cause the rest of the data to scale down which might
be unwanted. To make the y-axis centered and cut off peaks, add the following
line (adjust the values) to the plot command:

{{{
  set yrange [-600:600];
}}}
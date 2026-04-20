#!/bin/bash

#author: nima.2004hkh@gmail.com
#ffmpeg command from : https://gist.github.com/kurlov/32cbe841ea9d2b299e15297e54ae8971

NOCOLOR='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';

[ -d added ] || mkdir added

addToMKV(){
  for i in ./*.mkv
  do
     if [ -f "added/${i%.*}-added-subtitle.mkv" ]; then
        echo -e  "${RED}${i%.*}-added-subtitle.mkv Exists in added directory${NOCOLOR}"

     else
	ffmpeg -hide_banner -loglevel panic -i "$i" -sub_charenc 'UTF-8' -f srt -i "${i%.*}.srt" -map 0:0 -map 0:1 -map 1:0 -c:v copy -c:a copy -c:s srt "added/${i%.*}-added-subtitle.mkv";
        echo -e  "${GREEN}${1} converted successfully ${i%.*}-with-subtitle.mkv${NOCOLOR}";
     fi
  done
} 

echo -e  "Converting is starting:";

addToMKV
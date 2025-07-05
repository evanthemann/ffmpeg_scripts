#!/bin/bash

# Ask user for title slide text
read -p "Enter the title slide text: " title_text

# Convert special characters to safe values
title_safe=$(echo "$title_text" | sed 's/[^a-zA-Z0-9\_\-]/_/g')

# 1. Generate cellauto video
ffmpeg -f lavfi -i cellauto=s=1920x1080:rule=30 -t 10 -c:v libx264 cellauto.mp4 -y

# 2. Generate red color video yellow/gold #F7DC6F pale green (good) #C9E4CA pale blue #C5E3F4 pale red (good) #FFC6C9
ffmpeg -f lavfi -i color=c=#C9E4CA:s=1920x1080 -t 10 -c:v libx264 color.mp4 -y

# 3. Overlay red on top of cellauto and blend with multiply
ffmpeg -i cellauto.mp4 -i color.mp4 -filter_complex "[0:v] format=rgba [bg]; [1:v] format=rgba [fg]; [bg][fg] blend=all_mode='multiply':all_opacity=1, format=rgba" out.mp4 -y

# 4. Blur the overlaid video
ffmpeg -i out.mp4 -vf "gblur=sigma=2" -c:a copy outblur.mp4 -y

# 5. Add title slide and output to file with safe filename
ffmpeg -i outblur.mp4 -vf "drawtext=text='$title_text':x=(w-text_w)/2:y=(h-text_h)/2:fontsize=100:fontcolor=white" -c:a copy "${title_safe//[^a-zA-Z0-9\_\-]/_}.mp4" -y

# Remove temporary files
rm cellauto.mp4
rm color.mp4
rm out.mp4
rm outblur.mp4

ffplay "${title_safe//[^a-zA-Z0-9\_\-]/_}.mp4"
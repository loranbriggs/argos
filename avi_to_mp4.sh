#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Illegal number of prameters"
  echo "usage: $0 path/to/file.avi"
  exit 1
fi

file=$1

if [[ $file == *.avi ]]; then
  ffmpeg -i "$file" "${file%.avi}.mp4"
  exit 0
else
  echo "$1 is not an .avi file"
  exit 1
fi


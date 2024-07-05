#! /bin/bash
# Adapted for UNIX based on reddit post by u/justhadto https://www.reddit.com/r/datamoshing/comments/t46x3i/datamoshing_with_ffmpeg_howto_in_comments/
# Usage: ffmosh.sh <filename.mp4>


# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found"
    exit 1
fi

# Check if at least two arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename.mp4>"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "File not found!"
    exit 1
fi

file=$1
RR=5 # Remove Rate: every RRth frame  will be removed

echo "File: $file"

# Convert it to libxvid so that the I-frames will be generated:
ffmpeg -i $file -vcodec libxvid -q:v 1 -g 1000 -qmin 1 -qmax 1 -flags qpel+mv4 -an -y xvid_video.avi


mkdir ./frames  

# Extract the raw frames
ffmpeg -i xvid_video.avi -vcodec copy -start_number 0 frames/\f_%04d.raw

cd frames
# Remove every other frame in frames
for f in $(ls -1); do
    if [ $((i++ % $RR)) -eq $(($RR-1)) ]; then
        echo "Removing $f"
        rm $f
    fi
done

# Copy all frames to new file
touch edited_video.avi
for i in $(ls *.raw | sort); do 
    cat "$i" >> edited_video.avi; 
done

# Convert the datamoshed video back to mp4
ffmpeg -i edited_video.avi -i ../$file -vf scale=1280:-2 -map 0:v:0 -map 1:a:0 -vcodec h264 ../final_video.mp4

cd ..
rm -rf frames images xvid_video.avi


# Exit the script
exit 0

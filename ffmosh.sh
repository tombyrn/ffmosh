#! /bin/bash
# Adapted for UNIX script based on reddit post by u/justhadto https://www.reddit.com/r/datamoshing/comments/t46x3i/datamoshing_with_ffmpeg_howto_in_comments/
# Usage: ./ffmosh.sh <input_file> [-o <output_file> -r <interval>]

filename="$1"
base="${filename%.mp4}"
output_file=$base.datamoshed.mp4 # Default output name if none provided
input_file=""
interval=5 # Every i'th frame that will be removed

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "ERROR: ffmpeg could not be found"
    exit 1
fi

# Check if at least two arguments are provided
if [ "$#" -lt 1 ] || [ "$#" -gt 6 ]; then
    echo "Usage: $0 <input_file> [-o <output_file> -r <interval>]"
    exit 1
fi

# Go through each argument
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      output_file="$2"
      shift 2
      ;;
    -o*)
      output_file="${1#-o}"
      shift
      ;;
    -r)
      interval="$2"
      shift 2
      ;;
    -r*)
      interval="${1#-r}"
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      input_file="$1"
      shift
      ;;
  esac
done

# Check if the file exists
if [ ! -f $input_file ]; then
    echo "File not found!"
    exit 1
fi

# Append ".mp4" to output file name if not present
if [[ $output_file != *.mp4 ]]; then
    ouput_file="${output_file}.mp4"
fi

# Convert it to libxvid so that the I-frames will be generated:
ffmpeg -i $input_file -vcodec libxvid -q:v 1 -g 1000 -qmin 1 -qmax 1 -flags qpel+mv4 -an -y xvid_video.avi

# Extract the raw frames
mkdir ./frames  
ffmpeg -i xvid_video.avi -vcodec copy -start_number 0 frames/\f_%04d.raw

cd frames
# Remove every other frame in frames
prev=""
i=0
for f in $(ls -1); do
    if [ $i -eq 0 ]; then
      continue 
    fi
    if [ $((i++ % $interval)) -eq $(($interval-1)) ]; then
        cp "$prev" "$f"
    fi
    prev=$f
    ((i++))
done

# Copy all frames to new file
touch edited_video.avi
for i in $(ls *.raw | sort); do 
    cat "$i" >> edited_video.avi; 
done

# Convert the datamoshed video back to mp4
ffmpeg -i edited_video.avi -i ../$input_file -vf scale=1280:-2 -map 0:v:0 -map 1:a:0 -vcodec h264 ../$output_file

# Cleanup
cd ..
rm -rf frames images xvid_video.avi

# Exit the script
exit 0

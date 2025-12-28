# ffmosh
Bash script that uses FFMPEG to create datamoshed .mp4 files

## Usage 

Simply run the bash script and provide the video file as the second command line argument

`
./ffmosh.sh <input_file> [-o <output_file> -r <interval>]
`

`input_file` should be in mp4 format

`output_file` is optional and ".mp4" will be appended if it's not present in the string

`interval` is every i'th frame that will be removed when the i frames are being manipulated in the datamoshing process default is 5
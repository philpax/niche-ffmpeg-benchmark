#!/bin/sh

# Check if the correct number of arguments was provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <start_time> <duration>"
    exit 1
fi

INPUT="$1"
START_TIME="$2"
DURATION="$3"
LOGFILE="log.txt"
PRESETS=("ultrafast" "superfast" "veryfast" "faster" "fast" "medium" "slow" "slower" "veryslow")

# Clear the log file
> "$LOGFILE"

for PRESET in "${PRESETS[@]}"; do
    OUTPUT="output_${PRESET}.mp4"

    # Get current time
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Notify the current preset being processed along with the current time
    echo "[$CURRENT_TIME] Processing with preset: $PRESET"
    echo "Encoding with preset: $PRESET" >> "$LOGFILE"

    # Command template with placeholders for variables
    CMD="ffmpeg -y -i \"$INPUT\" -map 0:v:0 -map 0:a:0 -c:v libx264 -pix_fmt yuv420p -crf 23 -preset \"$PRESET\" -tune animation -vf \"subtitles='$INPUT':si=0\" -c:a ac3 -ss \"$START_TIME\" -t \"$DURATION\" \"$OUTPUT\""

    # Run ffmpeg with time and append output to log file
    { time eval $CMD ; } 2>&1 | grep real >> "$LOGFILE"

    # Log the file size
    SIZE=$(stat -c %s "$OUTPUT")
    echo "$PRESET output file size: $SIZE bytes" >> "$LOGFILE"

    # Get current time after encoding
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

    # Notify completion of the current preset along with the current time
    echo "[$CURRENT_TIME] Completed encoding with preset: $PRESET"
done

echo "Encoding completed. Check $LOGFILE for details."


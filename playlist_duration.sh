#!/bin/bash

# Load API key from .secrets file
source .secrets
API_KEY="$YOUTUBE_API_KEY"

# In case the Playlist URL is not passed, print the Usage
if [ -z "$1" ]; then
    echo "Usage: $0 <playlist URL>"
    exit 1
fi
echo "Using API_KEY=$API_KEY"

# Example URL: https://www.youtube.com/playlist?list=PLlrATfBNZ98dudnM48yfGUldqGD0S4FFb
URL="$1"

# Extract the playlist id from the url provided by the user
# Example PLAYLIST_ID = PLlrATfBNZ98dudnM48yfGUldqGD0S4FFb 
PLAYLIST_ID=$(echo "$URL" | grep -oP '(?<=list=)[a-zA-Z0-9_-]+')

TOTAL_DURATION_IN_SECS=0
NEXT_PAGE_TOKEN=""

VIDEO_NUMBER=1
# Loop to fetch all videos from the playlist
while true; do
    # Fetch video IDs (and the nextPageToken)
    RESPONSE=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$PLAYLIST_ID&pageToken=$NEXT_PAGE_TOKEN&key=$API_KEY")
    VIDEO_IDS=$(echo $RESPONSE | jq -r '.items[].snippet.resourceId.videoId')

    # Get the nextPageToken (if available)
    NEXT_PAGE_TOKEN=$(echo $RESPONSE | jq -r '.nextPageToken')

    for VIDEO_ID in $VIDEO_IDS; do
        # DURATION is in ISO-8601 Format. Ex: P1DT5H31M40S, PT30, etc.
        DURATION=$(curl -s "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$VIDEO_ID&key=$API_KEY" | jq -r '.items[].contentDetails.duration')

        # Parse and log duration using Perl
        PERL_OUTPUT=$(perl -nE '
            if (/P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/) {
                $d = $1 // 0;
                $h = $2 // 0;
                $m = $3 // 0;
                $s = $4 // 0;
                $total = $d * 86400 + $h * 3600 + $m * 60 + $s;
                say "Duration: '"$DURATION"' => Parsed as: ${d}d ${h}h ${m}m ${s}s = ${total}s";
            }
        ' <<< "$DURATION")

        # Echo log to stdout
        echo "Video-$VIDEO_NUMBER: $PERL_OUTPUT"

        # Extract just the numeric total from the last line of output
        SECONDS_TO_ADD=$(echo "$PERL_OUTPUT" | grep -oE '[0-9]+s$' | grep -oE '^[0-9]+')
        TOTAL_DURATION_IN_SECS=$((TOTAL_DURATION_IN_SECS + SECONDS_TO_ADD))

        VIDEO_NUMBER=$((VIDEO_NUMBER + 1))
    done

    # No Next Page Token implies that all videos have been processed
    if [ -z "$NEXT_PAGE_TOKEN" ] || [ "$NEXT_PAGE_TOKEN" == "null" ]; then
        break
    fi
done

HOURS=$((TOTAL_DURATION_IN_SECS / 3600))
MINUTES=$(( (TOTAL_DURATION_IN_SECS % 3600) / 60 ))
SECONDS=$((TOTAL_DURATION_IN_SECS % 60))
echo "Total Duration: $HOURS : $MINUTES : $SECONDS"


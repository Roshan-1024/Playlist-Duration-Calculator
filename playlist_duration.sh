#!/bin/bash

API_KEY=""

if [ -z "$1" ]; then
    echo "Usage: $0 <playlist URL>"
    exit 1
fi

URL="$1"

# Extract the playlist id from the url provided by the user
PLAYLIST_ID=$(echo "$URL" | grep -oP '(?<=list=)[a-zA-Z0-9_-]+')

TOTAL_DURATION=0
NEXT_PAGE_TOKEN=""

# Loop to fetch all videos from the playlist
while true; do
    # Fetch video IDs (and the nextPageToken)
    RESPONSE=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$PLAYLIST_ID&pageToken=$NEXT_PAGE_TOKEN&key=$API_KEY")
    VIDEO_IDS=$(echo $RESPONSE | jq -r '.items[].snippet.resourceId.videoId')

    # Get the nextPageToken (if available)
    NEXT_PAGE_TOKEN=$(echo $RESPONSE | jq -r '.nextPageToken')

    for VIDEO_ID in $VIDEO_IDS; do
        DURATION=$(curl -s "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$VIDEO_ID&key=$API_KEY" | jq -r '.items[].contentDetails.duration')

        MINUTES=$(echo $DURATION | sed -E 's/PT([0-9]+)M[0-9]+S/\1/')
        SECONDS=$(echo $DURATION | sed -E 's/PT[0-9]+M([0-9]+)S/\1/')

        MINUTES=${MINUTES:-0}
        SECONDS=${SECONDS:-0}

        VIDEO_DURATION=$((MINUTES * 60 + SECONDS))
        TOTAL_DURATION=$((TOTAL_DURATION + VIDEO_DURATION))

        echo "Video ID: $VIDEO_ID - Duration: $DURATION - Seconds: $VIDEO_DURATION"
    done
    
    if [ -z "$NEXT_PAGE_TOKEN" ] || [ "$NEXT_PAGE_TOKEN" == "null" ]; then
        break
    fi
done

echo "Total Duration (in seconds): $TOTAL_DURATION"
HOURS=$((TOTAL_DURATION / 3600))
MINUTES=$(( (TOTAL_DURATION % 3600) / 60 ))
SECONDS=$((TOTAL_DURATION % 60))
echo "Total Duration: $HOURS : $MINUTES : $SECONDS"


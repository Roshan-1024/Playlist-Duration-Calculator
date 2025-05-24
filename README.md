<h1 align="center">
<img src="doc/_static/logo.png" width="200">
</h1><br>

# YouTube Playlist Duration Calculator

Easily calculate the total playtime of any YouTube playlist with this automated Bash script. Whether you're planning a study schedule, managing binge-watching sessions, or just curious about how long a playlist really is, this tool gives you a precise breakdown in days, hours, minutes, and seconds.

## Features

* Accepts a YouTube playlist URL and computes the total time (in days, hours, minutes, seconds).
* Uses ISO 8601 duration format and parses it via Perl.
* Handles pagination using `nextPageToken`.
* Docker-compatible for containerized use.
* Outputs clear logs for each video processed.

## Prerequisites

* Bash shell
* `curl` for making HTTP requests
* `jq` for parsing JSON
* `perl` for duration parsing
* A valid YouTube Data API v3 key

## Setup

### Setup locally

1. Clone the repository and navigate to the directory.
2. Create a `.secrets` file:

    ```bash
    cp .secrets.example .secrets
    ```
3. Place your API key inside the .secrets file

### Using Docker

#### Build the Docker image

```bash
docker build -t playlist-duration .
```

#### Run the container

```bash
docker run -it --rm playlist-duration
```

## Usage

```bash
./playlist_duration.sh <YouTube Playlist URL>
```

## Output
* Logs the parsed duration of each video in a human-readable format.
* At the end, prints the cumulative duration in the format:

  ```
  Total Duration: <days> : <hours> : <minutes> : <seconds>
  ```

## Notes

* API key quota limits may restrict large playlists; use efficiently.
* The script processes up to 50 videos per page using YouTube’s pagination, and handles all pages automatically.


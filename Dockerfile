FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    grep \
    jq \
    perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY playlist_duration.sh .
COPY .secrets ./.secrets

RUN chmod +x playlist_duration.sh

CMD ["bash"]

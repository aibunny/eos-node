
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Leap
RUN apt-get update && apt-get install -y \
    wget \
    zstd \
    libstdc++6 \
    ca-certificates \
    curl \
    && wget https://github.com/AntelopeIO/leap/releases/download/v5.0.2/leap_5.0.2_amd64.deb -O /tmp/leap_5.0.2_amd64.deb \
    && apt-get install -y /tmp/leap_5.0.2_amd64.deb \
    && rm /tmp/leap_5.0.2_amd64.deb

RUN nodeos --full-version


WORKDIR /mnt/dev

COPY config.ini /mnt/dev/config.ini

# Set environment variables
ENV EOSDIR=/mnt/dev
ENV SNAPSHOT_URL=https://snapshots.eosnation.io/eos-v6/latest
ENV SNAPSHOT_PATH=$EOSDIR/snapshots/latest.bin.zst

# Create necessary directories
RUN mkdir -p $EOSDIR/snapshots


# Clean up the blocks directory if it exists
RUN rm -rf $EOSDIR/blocks

# Expose ports for API and P2P communication
EXPOSE 8888
EXPOSE 9876

# Start nodeos with the latest snapshot and log to stdout
CMD nodeos --data-dir $EOSDIR --config-dir $EOSDIR --http-server-address=0.0.0.0:8888 --access-control-allow-origin=* --contracts-console --http-validate-host=false
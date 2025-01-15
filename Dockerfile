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

# Set environment variables
ENV EOSDIR=/mnt/dev
ENV SNAPSHOT_URL=https://snapshots.eosnation.io/eos-v6/latest
ENV SNAPSHOT_PATH=$EOSDIR/snapshots/latest.bin.zst
ENV CHAIN_STATE_SIZE=327680  # Increased to 300gb

# Create necessary directories and ensure they're empty
RUN mkdir -p $EOSDIR/snapshots \
    && mkdir -p $EOSDIR/state \
    && mkdir -p $EOSDIR/blocks \
    && mkdir -p $EOSDIR/state-history

WORKDIR $EOSDIR

# Copy config file
COPY config.ini $EOSDIR/config.ini

# Download and decompress the latest snapshot
RUN wget $SNAPSHOT_URL -O $SNAPSHOT_PATH && \
    zstd -d $SNAPSHOT_PATH -o $EOSDIR/snapshots/latest.bin && \
    rm $SNAPSHOT_PATH && \
    # Ensure all directories are empty
    rm -rf $EOSDIR/blocks/* \
    $EOSDIR/state/* \
    $EOSDIR/state-history/*

# Expose ports for API and P2P communication
EXPOSE 8888
EXPOSE 9876

# Start nodeos with the latest snapshot
CMD ["sh", "-c", "rm -rf $EOSDIR/blocks/* $EOSDIR/state/* $EOSDIR/state-history/* && nodeos --data-dir $EOSDIR --config-dir $EOSDIR --snapshot $EOSDIR/snapshots/latest.bin"]
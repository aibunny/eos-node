# Start with an Alpine-based image
FROM alpine:3.18

# Install dependencies
RUN apk add --no-cache \
    wget \
    zstd \
    libstdc++ \
    ca-certificates \
    bash \
    curl

# Download and install the Antelope Leap software
RUN wget https://github.com/AntelopeIO/leap/releases/download/v5.0.2/leap_5.0.2_amd64.deb \
    -O /tmp/leap_5.0.2_amd64.deb && \
    mkdir -p /opt/leap && \
    tar -xvf /tmp/leap_5.0.2_amd64.deb -C /opt/leap && \
    rm /tmp/leap_5.0.2_amd64.deb

# Set up environment variables
ENV EOSDIR=/mnt/dev
ENV SNAPSHOT_URL=https://snapshots.eosnation.io/eos-v6/latest
ENV SNAPSHOT_PATH=$EOSDIR/snapshots/latest.bin.zst

# Create necessary directories
RUN mkdir -p $EOSDIR/snapshots

# Copy the existing config.ini file into the container
COPY config.ini /mnt/dev/config.ini

# Download and decompress the latest snapshot
RUN wget $SNAPSHOT_URL -O $SNAPSHOT_PATH && \
    zstd -d $SNAPSHOT_PATH -o $EOSDIR/snapshots/latest.bin && \
    rm $SNAPSHOT_PATH

# Clean up the blocks directory if it exists
RUN rm -rf $EOSDIR/blocks

# Expose ports for API and P2P communication
EXPOSE 8888
EXPOSE 9876

# Start nodeos with the latest snapshot
CMD /opt/leap/bin/nodeos --data-dir $EOSDIR --config-dir $EOSDIR --snapshot $EOSDIR/snapshots/latest.bin --http-server-address=0.0.0.0:8888 --access-control-allow-origin=* --contracts-console --http-validate-host=false >> $EOSDIR/nodeos.log 2>&1 &

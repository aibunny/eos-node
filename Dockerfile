
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

RUN nodeos --version

WORKDIR /mnt/dev

COPY config.ini /mnt/dev/config.ini
COPY genesis.json /mnt/dev/genesis.json

# Set environment variables
ENV EOSDIR=/mnt/dev


# Clean up the blocks directory if it exists
RUN rm -rf $EOSDIR/blocks

# Expose ports for API and P2P communication
EXPOSE 8888
EXPOSE 9876


RUN rm -rf /mnt/dev/blocks /mnt/dev/state

# Start nodeos with the latest snapshot and log to stdout
CMD nodeos --data-dir $EOSDIR  --config-dir  $EOSDIR --genesis-json $EOSDIR/genesis.json --http-server-address=0.0.0.0:8888 --access-control-allow-origin=* --contracts-console --http-validate-host=false
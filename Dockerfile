
FROM eosio/eos:compile_time_chainid_boxed

# Install zstd for decompression
RUN apt-get update && apt-get install -y zstd wget

# Set the working directory
WORKDIR /mnt/dev

# Copy the config file and any other necessary files
COPY config.ini /mnt/dev/config.ini

# Set environment variables
ENV EOSDIR=/mnt/dev
ENV SNAPSHOT_URL=https://snapshots.eosnation.io/eos-v6/latest
ENV SNAPSHOT_PATH=$EOSDIR/snapshots/latest.bin.zst

# Create necessary directories
RUN mkdir -p $EOSDIR/snapshots

# Download and decompress the latest snapshot
RUN wget $SNAPSHOT_URL -O $SNAPSHOT_PATH && \
    zstd -d $SNAPSHOT_PATH -o $EOSDIR/snapshots/latest.bin && \
    rm $SNAPSHOT_PATH


# Start the nodeos with the latest snapshot
CMD nodeos --data-dir $EOSDIR --config-dir $EOSDIR --snapshot $EOSDIR/snapshots/latest.bin --http-server-address=0.0.0.0:8888 --access-control-allow-origin=* --contracts-console --http-validate-host=false >> $EOSDIR/nodeos.log 2>&1 &

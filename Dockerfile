# Build stage
FROM ubuntu:22.04 AS build

ARG BITCOIN_CORE_VERSION=24.1
ARG ARCH=x86_64

RUN apt update \
  && apt install -y --no-install-recommends \
  ca-certificates \
  gnupg \
  wget \
  && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download Bitcoin binaries to tmp/ directory.
# Verify checksums, unpack files and run tests.
# Remove unnecessary files at the end.
RUN cd /tmp \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/SHA256SUMS \
  https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-${ARCH}-linux-gnu.tar.gz \
  && sha256sum --ignore-missing --check SHA256SUMS \
  && tar -xzvf bitcoin-${BITCOIN_CORE_VERSION}-${ARCH}-linux-gnu.tar.gz -C /opt \
  && ln -sv bitcoin-${BITCOIN_CORE_VERSION} /opt/bitcoin \
  && /opt/bitcoin/bin/test_bitcoin --show_progress \
  && rm -v bitcoin-${BITCOIN_CORE_VERSION}-${ARCH}-linux-gnu.tar.gz \
  /opt/bitcoin/bin/test_bitcoin /opt/bitcoin/bin/bitcoin-qt

# Runtime stage
FROM ubuntu:22.04

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG USER=bitcoin
ARG WORKING_DIRECTORY=/bitcoin

WORKDIR ${WORKING_DIRECTORY}

# Add non-root user and set him as owner of the home directory.
RUN groupadd -g ${GROUP_ID} ${USER} \
  && useradd -u ${USER_ID} -g ${USER} -d /bitcoin ${USER} \
  && chown -R ${USER} /bitcoin

# Copy bitcoin binaries from the Build stage
COPY --from=build /opt/ /opt/

# Link binaries to be accessible in PATH
RUN ln -sv /opt/bitcoin/bin/* /usr/local/bin

# Copy entrypoint script
COPY --chown=${USER}:${USER} docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch to non-root user
USER ${USER}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bitcoind", "-conf=/bitcoin/bitcoin.conf"]

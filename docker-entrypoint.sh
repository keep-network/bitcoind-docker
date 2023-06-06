#!/usr/bin/env bash

set -e

# Set WORKDIR to HOME if the HOME variable exists
# Otherwise set /bitcoin
WORKDIR="${HOME:-/bitcoin}"

# Default path for Bitcoin config
BITCOIN_CONF="$WORKDIR/bitcoin.conf"

# Default directory for data
BITCOIN_DATA="${DATADIR:-$WORKDIR/data}"

# Default path for optional Bitcoin config
OPTIONAL_BITCOIN_CONF=${OPTIONAL_CONF:-$WORKDIR/optional.conf}

# Create default data directory
mkdir -p "$BITCOIN_DATA"

# Fill the most important parameters using environment variables
# Overwrite the file if exists!
cat <<EOF >"$BITCOIN_CONF"
chain=${CHAIN:-main}
port=${PORT:-8333}
rpcport=${RPCPORT:-8332}
rpcuser=${RPCUSER:-bitcoinrpc}
rpcpassword=${RPCPASSWORD:-$(dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64)}
rpcbind=${RPCBIND:-0.0.0.0}
rpcallowip=${RPCALLOWIP:-0.0.0.0/0}
datadir=${BITCOIN_DATA}
disablewallet=${DISABLEWALLET:-1}
EOF

# Other (optional) parameters are taken from the mounted file
# and passed to the main config.
# Do not fail if the file does not exist.
cat "$OPTIONAL_BITCOIN_CONF" >>"$BITCOIN_CONF" || true

# Run command (Dockerfile CMD or custom)
exec "$@"

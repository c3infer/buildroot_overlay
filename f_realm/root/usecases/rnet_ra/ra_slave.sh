#/bin/bash/env bash
set -x

/root/rw_ivshmem --prefault configs/ra.json
cat configs/ra.json > /dev/rsi_policy_json
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
/root/rw_ivshmem -P "$SCRIPT_DIR/packet.txt"

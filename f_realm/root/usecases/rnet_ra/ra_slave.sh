#/bin/bash/env bash
set -x

SCRIPT_DIR="/root/usecases/rnet_ra"
/root/rw_ivshmem --prefault "$SCRIPT_DIR/configs/ra.json"
cat "$SCRIPT_DIR/configs/ra.json" > /dev/rsi_policy_json
/root/rw_ivshmem -P "$SCRIPT_DIR/packet.txt"

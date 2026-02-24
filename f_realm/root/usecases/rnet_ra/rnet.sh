#/bin/bash/env bash
set -x

/root/rw_ivshmem --prefault configs/rnet.json
cat configs/rnet.json > /dev/rsi_policy_json
/root/rw_ivshmem -C /tmp/rnet_rx.txt

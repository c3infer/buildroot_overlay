#!/usr/bin/env bash
set -x
set -euo pipefail
OUT_BR="${OUT_BR:-/mnt/out-br}"
OUT_BIN="${OUT_BIN:-/mnt/out/bin}"
echo "Agent <-> shm1 <-> RNET"

qemu-system-aarch64 -M confidential-guest-support=rme0 -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512 -nodefaults -chardev stdio,mux=on,id=virtiocon0,signal=off -device virtio-serial-pci -device virtconsole,chardev=virtiocon0 -mon chardev=virtiocon0,mode=readline -kernel "${OUT_BIN}/Image-guest" -drive if=none,file="${OUT_BR}/images/rootfs1.img",format=raw,id=hd0,snapshot=on -device virtio-blk-pci,drive=hd0 -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 -device ivshmem-plain,memdev=shm1,protected=true -device virtio-net-pci,netdev=net0,romfile= -netdev user,id=net0 -cpu host -M virt -enable-kvm -M gic-version=3,its=on -smp 1 -m 1024M -nographic -append "console=hvc0 root=/dev/vda1 rw agent_rnet_rnet" < /dev/hvc1 >/dev/hvc1 &

qemu-system-aarch64 -M confidential-guest-support=rme0 -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512 -nodefaults -chardev stdio,mux=on,id=virtiocon0,signal=off -device virtio-serial-pci -device virtconsole,chardev=virtiocon0 -mon chardev=virtiocon0,mode=readline -kernel "${OUT_BIN}/Image-guest" -drive if=none,file="${OUT_BR}/images/rootfs2.img",format=raw,id=hd0,snapshot=on -device virtio-blk-pci,drive=hd0 -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 -device ivshmem-plain,memdev=shm1,protected=true -cpu host -M virt -enable-kvm -M gic-version=3,its=on -smp 1 -m 1024M -nographic -append "console=hvc0 root=/dev/vda1 rw agent_rnet_agent" < /dev/hvc2 >/dev/hvc2 &

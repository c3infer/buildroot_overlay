#/bin/bash/env bash
set -x
QEMU_BIN="${QEMU_BIN:-/mnt/qemu/build/qemu-system-aarch64}"
if [ ! -x "$QEMU_BIN" ]; then
  QEMU_BIN="$(command -v qemu-system-aarch64 || true)"
fi
if [ -z "$QEMU_BIN" ]; then
  echo "ERROR: qemu-system-aarch64 not found (set QEMU_BIN)"
  exit 1
fi

echo "rnet (Realm A) -> shm1 <- ra (Realm B)"

echo "--------------------rnet (Realm A)------------------------"
"$QEMU_BIN"\
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512  \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs1.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -device ivshmem-plain,memdev=shm1,protected=true \
      -device virtio-net-pci,netdev=net0,romfile= \
      -netdev user,id=net0 \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw blabla" < /dev/hvc1 >/dev/hvc1 &

echo "--------------------ra (Realm B)------------------------"
"$QEMU_BIN"\
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512  \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -initrd /mnt/out-br/images/rootfs.cpio \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -device ivshmem-plain,memdev=shm1,protected=true \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0" < /dev/hvc2 >/dev/hvc2 &

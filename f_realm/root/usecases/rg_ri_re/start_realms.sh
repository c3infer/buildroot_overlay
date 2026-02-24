#!/usr/bin/env bash
set -x

echo "RG -> shm1 <- RE, RE -> shm2 <- RN, RN -> shm3 <- RG"

echo "--------------------RG------------------------"
qemu-system-aarch64 \
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512 \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs1.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm3,id=shm3 \
      -device ivshmem-plain,memdev=shm1,protected=true \
      -device ivshmem-plain,memdev=shm3,protected=true \
      -device virtio-net-pci,netdev=net0,romfile= \
      -netdev user,id=net0 \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw rg" < /dev/hvc1 >/dev/hvc1 &

echo "--------------------RE------------------------"
qemu-system-aarch64 \
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512 \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs2.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm2,id=shm2 \
      -device ivshmem-plain,memdev=shm1,protected=true \
      -device ivshmem-plain,memdev=shm2,protected=true \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw re" < /dev/hvc2 >/dev/hvc2 &

echo "--------------------RN------------------------"
qemu-system-aarch64 \
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512 \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs3.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm2,id=shm2 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm3,id=shm3 \
      -device ivshmem-plain,memdev=shm2,protected=true \
      -device ivshmem-plain,memdev=shm3,protected=true \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw rn" < /dev/hvc3 >/dev/hvc3 &


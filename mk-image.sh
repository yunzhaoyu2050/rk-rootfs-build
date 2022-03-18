#!/bin/bash -e

source "${PRDIR}/"script/function.sh

TARGET_ROOTFS_DIR=./binary
MOUNTPOINT=./rootfs
ROOTFSIMAGE=linaro-rootfs.img

info Making rootfs!

if [ -e ${ROOTFSIMAGE} ]; then
  rm ${ROOTFSIMAGE}
fi
if [ -e ${MOUNTPOINT} ]; then
  rm -r ${MOUNTPOINT}
fi

# Create directories
mkdir ${MOUNTPOINT}
dd if=/dev/zero of=${ROOTFSIMAGE} bs=1M count=0 seek=4000

finish() {
  sudo umount ${MOUNTPOINT} || true
  error "MAKE ROOTFS FAILED."
  exit -1
}

info Format rootfs to ext4
mkfs.ext4 ${ROOTFSIMAGE}

info Mount rootfs to ${MOUNTPOINT}
sudo mount ${ROOTFSIMAGE} ${MOUNTPOINT}
trap finish ERR

info Copy rootfs to ${MOUNTPOINT}
sudo cp -rfp ${TARGET_ROOTFS_DIR}/* ${MOUNTPOINT}

info Umount rootfs
sudo umount ${MOUNTPOINT}

info Rootfs Image: ${ROOTFSIMAGE}

e2fsck -p -f ${ROOTFSIMAGE}
resize2fs -M ${ROOTFSIMAGE}

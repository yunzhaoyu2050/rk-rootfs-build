#!/bin/bash

# app user define
RELEASE_VAL=buster # debian10-buster , debian9-stretch
ARCH_VAL=arm64     # armhf arm64
DEBUG_IS_ENABLE=false
TARGET_VAL=base # desktop , base
# --

chmod 775 *.sh
export RELEASE="$RELEASE_VAL" ARCH="$ARCH_VAL" TARGET="$TARGET_VAL"
echo -e "\033[36m>> creat RELEASE=$RELEASE_VAL ARCH=$ARCH_VAL TARGET="$TARGET_VAL" rootfs img.start. \033[0m"

echo ">> mk-base-debian.sh"
./mk-base-debian.sh
if [ $? -ne 0 ]; then
  echo -e "\e[31m Failed mk-base-debian.sh. \e[0m"
  exit 1
fi

if [ "$DEBUG_IS_ENABLE" != "true" ]; then
  echo ">> mk-rootfs.sh"
  ./mk-rootfs.sh
  if [ $? -ne 0 ]; then
    echo -e "\e[31m Failed mk-rootfs.sh. \e[0m"
    exit 1
  fi
else
  #VERSION=debug ARCH=armhf ./mk-rootfs-buster.sh
  exit 1
fi
echo ">> mk-image.sh"
./mk-image.sh
if [ $? -ne 0 ]; then
  echo -e "\e[31m Failed mk-image.sh. \e[0m"
  exit 1
fi

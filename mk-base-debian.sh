#!/bin/bash -e

source "${PRDIR}/"script/function.sh

if [ "$RELEASE" == "stretch" ]; then
  RELEASE='stretch'
elif [ "$RELEASE" == "buster" ]; then
  RELEASE='buster'
else
  error "please input the os type, stretch or buster..."
fi

if [ "$ARCH" == "armhf" ]; then
  ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then
  ARCH='arm64'
else
  error "please input the os type, armhf or arm64..."
fi

[ ! $TARGET ] && TARGET='desktop'

[ -e "${PRDIR}/"linaro-$RELEASE-alip-*.tar.gz ] && rm "${PRDIR}/"linaro-$RELEASE-alip-*.tar.gz

cd "${PRDIR}/"ubuntu-build-service/$RELEASE-$TARGET-$ARCH

debug "staring download..."

make clean

./configure

make

if [ -e linaro-$RELEASE-alip-*.tar.gz ]; then
  sudo chmod 0666 linaro-$RELEASE-alip-*.tar.gz
  cp linaro-$RELEASE-alip-*.tar.gz ../../
else
  error "failed to run livebuild, please check your network connection."
fi

cd "${PRDIR}/"

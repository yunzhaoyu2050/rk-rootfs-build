#!/bin/bash

source setenv.sh -c rootfs.cfg

function clean_project() {
  make clean -C "${PRDIR}/ubuntu-build-service/$RELEASE-$TARGET-$ARCH/" &&
    info "clean ubuntu-build-service..."
  rm -rf "${PRDIR}/"binary/ "${PRDIR}/"rootfs/ "${PRDIR}/"*.tar.gz "${PRDIR}/"*.img &&
    info "clean binary/ and output files..."
}

for a in "$@"; do
  case $a in
  -c | --clean | clean)
    clean_project
    exit 1
    ;;
  -h | --help)
    # usage_help
    exit 0
    ;;
  *=*) ;;
  *) ;;
  esac
done

info_ "
===========================
rootfs config info:
===========================
 RELEASE: $RELEASE
 ARCH: $ARCH
 TARGET: $TARGET
 VERSION: $VERSION
==========================="

debug "live build debian base rootfs..."
"${PRDIR}/"mk-base-debian.sh
[ $? -ne 0 ] && error " failed mk-base-debian.sh" && exit 1

# check RELEASE and TODO:
[ "$RELEASE" == "stretch" ] && warn "not currently supported 'stretch'" && exit 1

br=$(git branch | grep "*" | awk -F' ' '{print $2}')
[[ "$br" == "master" || "$br" == "main" ]] &&
  br="mk"
export BOARD_NAME="$br" # export env

[ ! -f "${PRDIR}/"board/$br-rootfs-buster.sh ] &&
  error "please edit the rootfs custom script of the specified development board" && exit 1
[ -f "${PRDIR}/"mk-rootfs-buster.sh ] && rm "${PRDIR}/"mk-rootfs-buster.sh
ln -ns "${PRDIR}/"board/$br-rootfs-buster.sh "${PRDIR}/"mk-rootfs-buster.sh
[ $? -ne 0 ] && error "error create soft links" && exit 1

debug "adapt to custom content..."
"${PRDIR}/"mk-rootfs-$RELEASE.sh
[ $? -ne 0 ] && error " failed mk-rootfs-$RELEASE.sh" && exit 1

debug "create rootfs image..."
"${PRDIR}/"mk-image.sh
[ $? -ne 0 ] && error " failed mk-image.sh" && exit 1

info "build rootfs image success"
exit 0

#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

if [ -e $TARGET_ROOTFS_DIR ]; then
	sudo rm -rf $TARGET_ROOTFS_DIR
fi

if [ "$ARCH" == "armhf" ]; then
	ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then
	ARCH='arm64'
else
	echo -e "\033[36m please input is: armhf or arm64...... \033[0m"
fi

if [ ! $VERSION ]; then
	VERSION="debug"
fi

if [ ! -e linaro-buster-alip-*.tar.gz ]; then
	echo "\033[36m Run mk-base-debian.sh first \033[0m"
fi

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev
	exit -1
}
trap finish ERR

echo -e "\033[36m Extract image \033[0m"
sudo tar -xpf linaro-buster-alip-*.tar.gz

# packages folder
sudo mkdir -p $TARGET_ROOTFS_DIR/packages
sudo cp -rf packages/$ARCH/* $TARGET_ROOTFS_DIR/packages

# overlay folder
sudo cp -rf overlay/* $TARGET_ROOTFS_DIR/

# overlay-firmware folder
sudo cp -rf overlay-firmware/* $TARGET_ROOTFS_DIR/

# overlay-debug folder
# adb, video, camera  test file
sudo cp -rf overlay-debug/* $TARGET_ROOTFS_DIR/

## hack the serial
sudo cp -f overlay/usr/lib/systemd/system/serial-getty@.service $TARGET_ROOTFS_DIR/lib/systemd/system/serial-getty@.service

# bt/wifi firmware
if [ "$ARCH" == "armhf" ]; then
    sudo cp overlay-firmware/usr/bin/brcm_patchram_plus1_32 $TARGET_ROOTFS_DIR/usr/bin/brcm_patchram_plus1
    sudo cp overlay-firmware/usr/bin/rk_wifi_init_32 $TARGET_ROOTFS_DIR/usr/bin/rk_wifi_init
elif [ "$ARCH" == "arm64" ]; then
    sudo cp overlay-firmware/usr/bin/brcm_patchram_plus1_64 $TARGET_ROOTFS_DIR/usr/bin/brcm_patchram_plus1
    sudo cp overlay-firmware/usr/bin/rk_wifi_init_64 $TARGET_ROOTFS_DIR/usr/bin/rk_wifi_init
fi
sudo mkdir -p $TARGET_ROOTFS_DIR/system/lib/modules/
sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

# adb
if [ "$ARCH" == "armhf" ] && [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/usr/local/share/adb/adbd-32 $TARGET_ROOTFS_DIR/usr/local/bin/adbd
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp -rf overlay-debug/usr/local/share/adb/adbd-64 $TARGET_ROOTFS_DIR/usr/local/bin/adbd
fi

# glmark2
sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/glmark2
sudo mkdir -p $TARGET_ROOTFS_DIR/usr/local/share/glmark2
if [ "$ARCH" == "armhf" ] && [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/usr/local/share/glmark2/armhf/share/* $TARGET_ROOTFS_DIR/usr/local/share/glmark2
	sudo cp overlay-debug/usr/local/share/glmark2/armhf/bin/glmark2-es2 $TARGET_ROOTFS_DIR/usr/local/bin/glmark2-es2
elif [ "$ARCH" == "arm64" ] && [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/usr/local/share/glmark2/aarch64/share/* $TARGET_ROOTFS_DIR/usr/local/share/glmark2
	sudo cp overlay-debug/usr/local/share/glmark2/aarch64/bin/glmark2-es2 $TARGET_ROOTFS_DIR/usr/local/bin/glmark2-es2
fi

echo -e "\033[36m Change root.....................\033[0m"
if [ "$ARCH" == "armhf" ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
fi
sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get update

chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod +x /etc/rc.local

#---------------Power management --------------
apt-get install -y busybox pm-utils triggerhappy
cp /etc/Powermanager/triggerhappy.service  /lib/systemd/system/triggerhappy.service

#---------------System--------------
apt-get install -y cpio parted dosfstools isc-dhcp-client-ddns
apt-get install -f -y

#---------------Rga--------------
dpkg -i /packages/rga/*.deb

# # ---------Video---------
# echo -e "\033[36m Setup Video.................... \033[0m"
# apt-get install -y gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa \
# gstreamer1.0-plugins-base-apps qtmultimedia5-examples
# apt-get install -f -y

# dpkg -i  /packages/mpp/*
# dpkg -i  /packages/gst-rkmpp/*.deb
# dpkg -i  /packages/gst-base/*.deb
# # apt-mark hold gstreamer1.0-x
# apt-get install -f -y

# # ---------Camera--------- # del for rk3568 board
# echo -e "\033[36m Install camera.................... \033[0m"
# apt-get install cheese v4l-utils -y
# dpkg -i  /packages/rkisp/*.deb 
# dpkg -i  /packages/libv4l/*.deb

#---------Xserver---------
echo -e "\033[36m Install Xserver.................... \033[0m"
# apt-get build-dep -y xorg-server-source
apt-get install -y libgl1-mesa-dev libgles1 libegl1-mesa-dev libc-dev-bin libc6-dev libfontenc-dev libfreetype6-dev \
libpciaccess-dev libpng-dev libpng-tools libxfont-dev libxkbfile-dev linux-libc-dev manpages manpages-dev xserver-common zlib1g-dev \
libdmx1 libpixman-1-dev libxcb-xf86dri0 libxcb-xv0

apt-get install -f -y
dpkg -i /packages/xserver/*.deb
apt-get install -f -y
# apt-mark hold xserver-common xserver-xorg-core xserver-xorg-legacy

#---------------Openbox--------------
echo -e "\033[36m Install openbox.................... \033[0m"
apt-get install -y openbox
dpkg -i  /packages/openbox/*.deb
apt-get install -f -y

#----------------Pcmanfm------------
echo -e "\033[36m Install pcmanfm.................... \033[0m"
apt-get install -y pcmanfm
dpkg -i  /packages/pcmanfm/*.deb
apt-get install -f -y

# #--------------Ffmpeg------------
# echo -e "\033[36m Install ffmpeg.................... \033[0m"
# apt-get install -y ffmpeg
# dpkg -i  /packages/ffmpeg/*.deb
# apt-get install -f -y

# #----------------Mpv------------
# echo -e "\033[36m Install mpv.................... \033[0m"
# apt-get install -y libmpv1 mpv
# dpkg -i  /packages/mpv/*.deb
# apt-get install -f -y

#---------Update chromium-----
apt-get install -y chromium
apt-get install -f -y /packages/chromium/*.deb

#------------------Libdrm------------
echo -e "\033[36m Install libdrm.................... \033[0m"
dpkg -i  /packages/libdrm/*.deb
apt-get install -f -y

# mark package to hold
# apt-mark hold libv4l-0 libv4l2rds0 libv4lconvert0 libv4l-dev v4l-utils
# apt-mark hold librockchip-mpp1 librockchip-mpp-static librockchip-vpu0 rockchip-mpp-demos
# apt-mark hold xserver-common xserver-xorg-core xserver-xorg-legacy
# apt-mark hold libegl-mesa0 libgbm1 libgles1 alsa-utils
# apt-get install -f -y

#---------------Custom Script--------------
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
rm /lib/systemd/system/wpa_supplicant@.service # del for rk3568 board
systemctl mask hostapd.service

#---------------Unclutter------------
echo -e "\033[36m Install unclutter.................... \033[0m"
apt-get install -y unclutter
echo "unclutter -idle 3 -root &" >> /root/.bashrc 

#---------------Chromium app server--------------
echo -e "\033[36m Install enable Chromium app startup.................... \033[0m"
systemctl enable chromium_startup.service

#---------------Bt uart config--------------
echo -e "\033[36m Install enable Bt uart startup.................... \033[0m"
systemctl enable bt_uart.service

#---------------Wifi config--------------
echo -e "\033[36m Wifi config for rk3568.................... \033[0m"
ln -ns /system/ /vendor

# #-------------Dhclient config--------------
# echo -e "\033[36m Dhclient config for rk3568.................... \033[0m"
# systemctl enable dhclient.service

#---------------Clean--------------
rm -rf /var/lib/apt/lists/*

EOF

sudo umount $TARGET_ROOTFS_DIR/dev

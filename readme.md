fork from https://github.com/rockchip-linux/rk-rootfs-build.git commit id:a63b0a30ab024c5555d58427d88561bf2a4bf7e4

## Introduction

A set of shell scripts that will build GNU/Linux distribution rootfs image
for rockchip platform.

## Available Distro

* Debian 10 (Buster-X11 and Wayland)~~

```
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## Usage for 32bit Debian 10 (Buster-32)

Building a base debian system by ubuntu-build-service from linaro.

```
	RELEASE=buster TARGET=desktop ARCH=armhf ./mk-base-debian.sh
```

Building the rk-debian rootfs:

```
	RELEASE=buster ARCH=armhf ./mk-rootfs.sh
```

Building the rk-debain rootfs with debug:

```
	VERSION=debug ARCH=armhf ./mk-rootfs-buster.sh
```

Creating the ext4 image(linaro-rootfs.img):

```
	./mk-image.sh
```

---

## Usage for 64bit Debian 10 (Buster-64)

Building a base debian system by ubuntu-build-service from linaro.

```
	RELEASE=buster TARGET=desktop ARCH=arm64 ./mk-base-debian.sh
```

Building the rk-debian rootfs:

```
	RELEASE=buster ARCH=arm64 ./mk-rootfs.sh
```

Building the rk-debain rootfs with debug:

```
	VERSION=debug ARCH=arm64 ./mk-rootfs-buster.sh
```

Creating the ext4 image(linaro-rootfs.img):

```
	./mk-image.sh
```
---

## Cross Compile for ARM Debian

[Docker + Multiarch](http://opensource.rock-chips.com/wiki_Cross_Compile#Docker)

## Package Code Base

Please apply [those patches](https://github.com/rockchip-linux/rk-rootfs-build/tree/master/packages-patches) to release code base before rebuilding!

## FAQ

- noexec or nodev issue
noexec or nodev issue /usr/share/debootstrap/functions: line 1450:
../rootfs/ubuntu-build-service/stretch-desktop-arm64/chroot/test-dev-null:
Permission denied E: Cannot install into target
...
mounted with noexec or nodev

Solution: mount -o remount,exec,dev xxx (xxx is the mount place), then rebuild it.
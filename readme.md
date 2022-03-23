### rk-rootfs-build

#### Directory Description
```bash
board/  -- user define rootfs build cmd folder, format:'board_name'-rootfs-buster.sh
    mk-rootfs-buster.sh  -- default build cmd
    mcxa-rk3568-td01-rootfs-buster.sh  -- 'mcxa-rk3568-td01' board build cmd
overlay-bd/
    default/
    mcxa-rk3568-td01/  -- 'mcxa-rk3568-td01' board user define rootfs files
        overlay/
        overlay-debug/  -- debug files
        overlay-firmware/
script/
build.sh  -- automatic build scripts based on configuration files(rootfs)
rootfs.cfg  -- user define rootfs config
setenv.sh
```

#### Rootfs Config
file: rootfs.cfg
```bash
# rootfs config
RELEASE=buster      # debian10-buster , debian9-stretch
ARCH=arm64          # armhf arm64
TARGET=base         # desktop , base
VERSION=debug       # debug

# kernel config
KERNEL_PATH=../kernel
```

#### Usage
1. edit rootfs.cfg
2. add to overlay-bd/ custom development board rootfs file directory
3. add to board/ custom rootfs file build command
4. ./build.sh

#### Official repository mirror

address: https://github.com/JeffyCN/rockchip_mirrors.git
branch: debian

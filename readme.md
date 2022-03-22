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
build.sh
rootfs.cfg
setenv.sh
```

#### Official repository mirror

address: https://github.com/JeffyCN/rockchip_mirrors.git
branch: debian

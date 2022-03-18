#!/bin/bash -e
### BEGIN INIT INFO
# Provides:          adbd
# Required-Start:
# Required-Stop:
# Default-Start: S
# Default-Stop: 6
# Short-Description:
# Description:       Linux ADB
### END INIT INFO

# setup configfs for adbd, usb mass storage and MTP....

UMS_EN=off
ADB_EN=off
MTP_EN=off
NTB_EN=off
ACM_EN=off
UAC1_EN=off
UAC2_EN=off
UVC_EN=off
RNDIS_EN=off

USB_ATTRIBUTE=0x409
USB_GROUP=rockchip
USB_SKELETON=b.1

CONFIGFS_DIR=/sys/kernel/config
USB_CONFIGFS_DIR=${CONFIGFS_DIR}/usb_gadget/${USB_GROUP}
USB_STRINGS_DIR=${USB_CONFIGFS_DIR}/strings/${USB_ATTRIBUTE}
USB_FUNCTIONS_DIR=${USB_CONFIGFS_DIR}/functions
USB_CONFIGS_DIR=${USB_CONFIGFS_DIR}/configs/${USB_SKELETON}

make_config_string()
{
	tmp=$CONFIG_STRING
	if [ -n "$CONFIG_STRING" ]; then
		CONFIG_STRING=${tmp}_${1}
	else
		CONFIG_STRING=$1
	fi
}

parameter_init()
{
	while read line
	do
		case "$line" in
			usb_mtp_en)
				MTP_EN=on
				make_config_string mtp
				;;
			usb_adb_en)
				ADB_EN=on
				make_config_string adb
				;;
			usb_ums_en)
				UMS_EN=on
				make_config_string ums
				;;
			usb_ntb_en)
				NTB_EN=on
				make_config_string ntb
				;;
			usb_acm_en)
				ACM_EN=on
				make_config_string acm
				;;
			usb_uac1_en)
				UAC1_EN=on
				make_config_string uac1
				;;
			usb_uac2_en)
				UAC2_EN=on
				make_config_string uac2
				;;
			usb_uvc_en)
				UVC_EN=on
				make_config_string uvc
				;;
			usb_rndis_en)
                               RNDIS_EN=on
                               make_config_string rndis
                               ;;

		esac
	done < $DIR/.usb_config


	case "$CONFIG_STRING" in
		ums)
			PID=0x0000
			;;
		mtp)
			PID=0x0001
			;;
		adb)
			PID=0x0006
			;;
		mtp_adb | adb_mtp)
			PID=0x0011
			;;
		ums_adb | adb_ums)
			PID=0x0018
			;;
		acm)
			PID=0x1005
			;;
		*)
			PID=0x0019
	esac
}

configfs_init()
{
	mkdir -p ${USB_CONFIGFS_DIR} -m 0770
	echo 0x2207 > ${USB_CONFIGFS_DIR}/idVendor
	echo $PID > ${USB_CONFIGFS_DIR}/idProduct
	mkdir -p ${USB_STRINGS_DIR}   -m 0770

	SERIAL=`cat /proc/cpuinfo | grep Serial | awk '{print $3}'`
	if [ -z $SERIAL ];then
		SERIAL=0123456789ABCDEF
	fi
	echo $SERIAL > ${USB_STRINGS_DIR}/serialnumber
	echo "rockchip"  > ${USB_STRINGS_DIR}/manufacturer
	echo "rk3xxx"  > ${USB_STRINGS_DIR}/product
	mkdir -p ${USB_CONFIGS_DIR}  -m 0770
	mkdir -p ${USB_CONFIGS_DIR}/strings/${USB_ATTRIBUTE}  -m 0770
	echo 500 > ${USB_CONFIGS_DIR}/MaxPower
	echo ${CONFIG_STRING} > ${USB_CONFIGS_DIR}/strings/${USB_ATTRIBUTE}/configuration

}

configure_uvc_resolution()
{
	mkdir ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H
	echo $UVC_DISPLAY_W > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/wWidth
	echo $UVC_DISPLAY_H > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/wHeight
	echo 666666 > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/dwDefaultFrameInterval
	echo $((UVC_DISPLAY_W*UVC_DISPLAY_H*80)) > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/dwMinBitRate
	echo $((UVC_DISPLAY_W*UVC_DISPLAY_H*160)) > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/dwMaxBitRate
	echo $((UVC_DISPLAY_W*UVC_DISPLAY_H*2)) > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/dwMaxVideoFrameBufferSize
	echo -e "666666\n1000000\n2000000" > ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m/$UVC_DISPLAY_H/dwFrameInterval
}

function_init()
{
	# UAC must be first setup when multi function composite.
	if [ $UAC1_EN = on ];then
		if [ ! -e "${USB_FUNCTIONS_DIR}/uac1.gs0" ] ;
		then
			mkdir ${USB_FUNCTIONS_DIR}/uac1.gs0
			ln -s ${USB_FUNCTIONS_DIR}/uac1.gs0 ${USB_CONFIGS_DIR}/uac1.gs0
		fi
	fi

	if [ $UAC2_EN = on ];then
		if [ ! -e "${USB_FUNCTIONS_DIR}/uac2.gs0" ] ;
		then
			mkdir ${USB_FUNCTIONS_DIR}/uac2.gs0
			ln -s ${USB_FUNCTIONS_DIR}/uac2.gs0 ${USB_CONFIGS_DIR}/uac2.gs0
		fi
	fi

	if [ $UMS_EN = on ];then
		if [ ! -e "${USB_FUNCTIONS_DIR}/mass_storage.0" ] ;
		then
			mkdir -p ${USB_FUNCTIONS_DIR}/mass_storage.0
			echo /dev/disk/by-partlabel/userdata > ${USB_FUNCTIONS_DIR}/mass_storage.0/lun.0/file
			ln -s ${USB_FUNCTIONS_DIR}/mass_storage.0 ${USB_CONFIGS_DIR}/mass_storage.0
		fi
	fi

	if [ $ADB_EN = on ];then
		if [ ! -e "${USB_FUNCTIONS_DIR}/ffs.adb" ] ;
		then
			mkdir -p ${USB_FUNCTIONS_DIR}/ffs.adb
			ln -s ${USB_FUNCTIONS_DIR}/ffs.adb ${USB_CONFIGS_DIR}/ffs.adb
		fi
	fi

	if [ $MTP_EN = on ];then
		if [ ! -e "mkdir -p ${USB_FUNCTIONS_DIR}/mtp.gs0" ] ;
		then
			mkdir -p ${USB_FUNCTIONS_DIR}/mtp.gs0
			ln -s ${USB_FUNCTIONS_DIR}/mtp.gs0 ${USB_CONFIGS_DIR}/mtp.gs0
		fi
	fi

	if [ $NTB_EN = on ];then
		if [ ! -e "mkdir -p ${USB_FUNCTIONS_DIR}/ffs.ntb" ] ;
		then
			mkdir -p ${USB_FUNCTIONS_DIR}/ffs.ntb
			ln -s ${USB_FUNCTIONS_DIR}/ffs.ntb ${USB_CONFIGS_DIR}/ffs.ntb
		fi
	fi

	if [ $ACM_EN = on ];then
		if [ ! -e "mkdir -p ${USB_FUNCTIONS_DIR}/acm.gs6" ] ;
		then
			mkdir -p ${USB_FUNCTIONS_DIR}/acm.gs6
			ln -s ${USB_FUNCTIONS_DIR}/acm.gs6 ${USB_CONFIGS_DIR}/acm.gs6
		fi
	fi
	if [ $UVC_EN = on ];then
		mkdir ${USB_FUNCTIONS_DIR}/uvc.gs6

		cat ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming_maxpacket
		echo 1 > /sys/kernel/config/usb_gadget/rockchip/functions/uvc.gs6/streaming_bulk

		mkdir ${USB_FUNCTIONS_DIR}/uvc.gs6/control/header/h
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/control/header/h ${USB_FUNCTIONS_DIR}/uvc.gs6/control/class/fs/h
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/control/header/h ${USB_FUNCTIONS_DIR}/uvc.gs6/control/class/ss/h

		mkdir ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m
		UVC_DISPLAY_W=640
		UVC_DISPLAY_H=480
		configure_uvc_resolution

		UVC_DISPLAY_W=1280
		UVC_DISPLAY_H=720
		configure_uvc_resolution

		UVC_DISPLAY_W=1920
		UVC_DISPLAY_H=1080
		configure_uvc_resolution

		UVC_DISPLAY_W=2560
		UVC_DISPLAY_H=1440
		configure_uvc_resolution

		mkdir ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/uncompressed/u ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h/u
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/mjpeg/m ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h/m
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/class/fs/h
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/class/hs/h
		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/header/h ${USB_FUNCTIONS_DIR}/uvc.gs6/streaming/class/ss/h

		ln -s ${USB_FUNCTIONS_DIR}/uvc.gs6 ${USB_CONFIGS_DIR}/uvc.gs6
	fi

}

case "$1" in
start)
	DIR=$(cd `dirname $0`; pwd)
	if [ ! -e "$DIR/.usb_config" ]; then
		echo "$0: Cannot find .usb_config"
		exit 0
	fi

	parameter_init
	if [ -z $CONFIG_STRING ]; then
		echo "$0: no function be selected"
		exit 0
	fi
	configfs_init
	function_init

	if [ $ADB_EN = on ];then
		if [ ! -e "/dev/usb-ffs/adb" ] ;
		then
			mkdir -p /dev/usb-ffs/adb
			mount -o uid=2000,gid=2000 -t functionfs adb /dev/usb-ffs/adb
		fi
		export service_adb_tcp_port=5555
		start-stop-daemon --start --oknodo --pidfile /var/run/adbd.pid --startas /usr/local/bin/adbd --background
		sleep 1
	fi

	if [ $MTP_EN = on ];then
		if [ $MTP_EN = on ]; then
			mtp-server&
		else
			sleep 1 && mtp-server&
		fi
	fi

	if [ $NTB_EN = on ];then
		if [ ! -e "/dev/usb-ffs/ntb" ] ;
		then
			mkdir -p /dev/usb-ffs/ntb
			mount -o uid=2000,gid=2000 -t functionfs ntb /dev/usb-ffs/ntb
		fi
	fi

	UDC=`ls /sys/class/udc/| awk '{print $1}'`
	 echo $UDC > ${USB_CONFIGFS_DIR}/UDC
	;;
stop)
	echo "none" > ${USB_CONFIGFS_DIR}/UDC
	if [ $ADB_EN = on ];then
		start-stop-daemon --stop --oknodo --pidfile /var/run/adbd.pid --retry 5
	fi
	;;
restart|reload)
	;;
*)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac

exit 0

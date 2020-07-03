#!/bin/bash

COMMON_DIR=$(cd `dirname $0`; pwd)
if [ -h $0 ]
then
        CMD=$(readlink $0)
        COMMON_DIR=$(dirname $CMD)
fi
cd $COMMON_DIR
cd ../../..
TOP_DIR=$(pwd)
RAMDISK_IMG=$1
RAMDISK_CFG=$2
echo "config is $RAMDISK_CFG"

BOARD_CONFIG=$TOP_DIR/device/rockchip/.BoardConfig.mk
source $BOARD_CONFIG
if [ -z $RK_KERNEL_ZIMG ]; then
	KERNEL_IMAGE=$TOP_DIR/$RK_KERNEL_IMG
else
	KERNEL_IMAGE=$TOP_DIR/$RK_KERNEL_ZIMG
fi

KERNEL_DTB=$TOP_DIR/kernel/resource.img

if [ -z $RAMDISK_CFG ]
then
	if [ -n "$RK_RECOVERY_RAMDISK" ]; then
		CPIO_IMG=$TOP_DIR/device/rockchip/rockimg/$RK_RECOVERY_RAMDISK
		TARGET_IMAGE=$TOP_DIR/rockdev/recovery.img
		rm -f $TARGET_IMAGE
		echo "use prebuilt $RK_RECOVERY_RAMDISK for CPIO image"
	else
		echo "config for building $RAMDISK_IMG doesn't exist, skip!"
		exit 0
	fi
fi

# build kernel
if [ -f $KERNEL_IMAGE ]
then
	echo "found kernel image"
else
	echo "kernel image doesn't exist, now build kernel image"
	$TOP_DIR/build.sh kernel
	if [ $? -eq 0 ]; then
		echo "build kernel done"
	else
		exit 1
	fi
fi

if [ -n "$RAMDISK_CFG" ]; then

	source $TOP_DIR/buildroot/build/envsetup.sh $RAMDISK_CFG
	CPIO_IMG=$TOP_DIR/buildroot/output/$RAMDISK_CFG/images/rootfs.cpio.gz
	TARGET_IMAGE=$TOP_DIR/buildroot/output/$RAMDISK_CFG/images/$RAMDISK_IMG

	# build ramdisk
	echo "====Start build $RAMDISK_CFG===="
	$TOP_DIR/buildroot/utils/brmake
	if [ $? -eq 0 ]; then
	    echo "log saved on $TOP_DIR/br.log"
	    echo "====Build $RAMDISK_CFG ok!===="
	else
	    echo "log saved on $TOP_DIR/br.log"
	    echo "====Build $RAMDISK_CFG failed!===="
	    tail -n 100 $TOP_DIR/br.log
	    exit 1
	fi
fi

echo -n "pack $RAMDISK_IMG..."
$TOP_DIR/kernel/scripts/mkbootimg --kernel $KERNEL_IMAGE --ramdisk $CPIO_IMG --second $KERNEL_DTB -o $TARGET_IMAGE
echo "done."

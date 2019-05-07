#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly-rk3288
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=firefly_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3288-firefly
# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu.txt
# packagefile for pack image files
export RK_PACKAGE_FILE=rk3288-ubuntu-package-file

# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# rootfs image path
export RK_ROOTFS_IMG=rootfs/ubuntu1604armhf-rootfs.img

# Recovery config
export RK_CFG_RECOVERY=
#OEM config
export RK_OEM_DIR=
#userdata config
export RK_USERDATA_DIR=

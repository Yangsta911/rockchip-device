#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=evb-px30
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=px30_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=px30-firefly
# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu.txt
# packagefile for make update image 
export RK_PACKAGE_FILE=px30-ubuntu-package-file

# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# rootfs image path
export RK_ROOTFS_IMG=ubunturootfs/ubuntu_16.04_arm64_20190226150448.img

# Recovery config
export RK_CFG_RECOVERY=
#OEM config
export RK_OEM_DIR=
#userdata config
export RK_USERDATA_DIR=


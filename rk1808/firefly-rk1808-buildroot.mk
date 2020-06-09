#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly_rk1808
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=firefly_rk1808_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk1808-firefly
# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu.txt
# packagefile for make update image
export RK_PACKAGE_FILE=rk1808-ubuntu-package-file
# Set userdata partition type
export RK_USERDATA_FS_TYPE=ext4
#OEM config
export RK_OEM_DIR=
#userdata config
export RK_USERDATA_DIR=

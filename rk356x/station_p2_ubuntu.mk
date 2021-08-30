#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3568_ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3568-firefly-roc-pc
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=station_linux_defconfig
# recovery ramdisk
export RK_RECOVERY_RAMDISK=rk356x-recovery-arm64-raw.cpio.gz

#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk356x_openwrt.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly-rk3568
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=station_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3568-firefly-roc-pc

# Openwrt version select
export RK_OPENWRT_VERSION_SELECT=lede
# Openwrt defconfig
export RK_OPENWRT_DEFCONFIG=ROC-3568-PC_config

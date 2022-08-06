#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Kernel defconfig
export RK_KERNEL_DEFCONFIG=firefly_linux_defconfig
#export RK_KERNEL_DEFCONFIG=firefly_roc-rk3399-pc_defconfig

# Kernel dts
export RK_KERNEL_DTS=rk3399-roc-pc-mipi101-M101014_BE45_A1
# DRM version
export RK_DRM_VERSION=2

# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC_3399_PC_PLUS

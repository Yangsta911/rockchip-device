#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Kernel defconfig
export RK_KERNEL_DEFCONFIG=station_linux_defconfig

# Kernel dts
export RK_KERNEL_DTS=rk3399-roc-pc-plus

# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC_3399_PC_PLUS

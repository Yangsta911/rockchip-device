#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=CS-R1_main-rk3399-JD4

# Kernel dts
export RK_KERNEL_DTS=rk3399-firefly-CS-R1-jd4-main

# PRODUCT MODEL
export RK_PRODUCT_MODEL=CORE_3399_JD4

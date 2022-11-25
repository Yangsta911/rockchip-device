#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3566-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3566-firefly-roc-pc
# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC_RK3566_PC
# Rootfs
export RK_ROOTFS_IMG=ubuntu_rootfs/rk356x_debian_rootfs.img

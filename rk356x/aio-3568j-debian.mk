#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3568-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3568-firefly-aioj
# PRODUCT MODEL
export RK_PRODUCT_MODEL=AIO_3568J
# Rootfs
export RK_ROOTFS_IMG=ubuntu_rootfs/rk356x_debian_rootfs.img
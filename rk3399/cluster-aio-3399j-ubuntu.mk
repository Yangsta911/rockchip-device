#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3399-firefly-aio-cluster
export RK_ROOTFS_IMG=ubunturootfs/ubuntu_18.04_20200413-1513_DESKTOP.img

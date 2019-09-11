#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3328-buildroot.mk

export RK_KERNEL_DEFCONFIG=firefly-roc-rk3328-pc_defconfig

# Kernel dts
export RK_KERNEL_DTS=rk3328-firefly-aiojd4

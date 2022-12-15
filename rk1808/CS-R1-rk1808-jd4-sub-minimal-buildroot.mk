#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk1808-buildroot.mk

# Kernel defconfig fragment
export RK_KERNEL_DEFCONFIG_FRAGMENT="firefly-linux-cs-r1.config"

# Kernel dts
export RK_KERNEL_DTS=rk1808-firefly-srjd4-sub

# Buildroot config
export RK_CFG_BUILDROOT=firefly_rk1808_cs_r1

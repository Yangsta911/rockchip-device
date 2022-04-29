#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3568-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3568j-firefly-itxq-lvds_m10r800-cam_2ms2mf
# PRODUCT MODEL
export RK_PRODUCT_MODEL=ITX_3568Q

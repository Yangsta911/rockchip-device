#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3568-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3568j-firefly-itxq-mipi_m10r800v2
# PRODUCT MODEL
export RK_PRODUCT_MODEL=ITX_3568Q

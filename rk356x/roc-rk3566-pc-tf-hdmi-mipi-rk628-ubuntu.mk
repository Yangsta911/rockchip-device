#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3566-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3566-firefly-roc-pc_tf-hdmi-mipi-rk628
# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC_RK3566_PC

#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3399-firefly-aioc-ai-mipi101-M101014_BE45_A1

# PRODUCT MODEL
export RK_PRODUCT_MODEL=AIO_3399C
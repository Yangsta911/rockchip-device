#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/firefly-rk3399-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3399-firefly-aiojd4

# PRODUCT MODEL
export RK_PRODUCT_MODEL=CORE_3399_JD4

# FIREFLY PRODUCT MODEL
FIREFLY_PRODUCT_MODEL=AIO_3399_JD4

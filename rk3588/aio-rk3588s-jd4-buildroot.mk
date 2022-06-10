CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/roc-rk3588s-pc-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=aio-3588s-jd4

# PRODUCT MODEL
export RK_PRODUCT_MODEL=AIO-3588S-JD4

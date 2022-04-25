CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/aio-rk3588s-jd4-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=aio-3588s-jd4-mipi101-M101014-BE45-A1

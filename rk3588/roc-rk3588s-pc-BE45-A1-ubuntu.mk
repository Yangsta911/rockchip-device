CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/roc-rk3588s-pc-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=roc-rk3588s-pc-mipi101-M101014-BE45-A1

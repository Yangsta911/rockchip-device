CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/roc-rk3588s-pc-ext-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=roc-rk3588s-pc-ext-mipi101-M101014-BE45-A1

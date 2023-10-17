CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/roc-rk3588-rt-buildroot.mk

export RK_KERNEL_DTS=roc-rk3588-rt-ext

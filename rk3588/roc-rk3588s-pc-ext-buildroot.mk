CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/roc-rk3588s-pc-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=roc-rk3588s-pc-ext

# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC-RK3588S-PC

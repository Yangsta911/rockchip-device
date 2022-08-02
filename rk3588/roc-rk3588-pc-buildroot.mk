CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/itx-3588j-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=roc-rk3588-pc

# PRODUCT MODEL
export RK_PRODUCT_MODEL=ROC-RK3588-PC

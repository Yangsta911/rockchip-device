CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/itx-3588j-buildroot.mk

# Kernel dts
export RK_KERNEL_DTS=rk3588-firefly-aio-3588q-mipi101-M101014-BE45-A1

# PRODUCT MODEL
export RK_PRODUCT_MODEL=AIO_3588Q

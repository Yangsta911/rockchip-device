CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/aio-3588mq-ubuntu.mk

# Kernel dts
export RK_KERNEL_DTS=rk3588-firefly-aio-3588mq-mipi101-M101014-BE45-A1

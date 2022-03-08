CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Kernel defconfig fragment
export RK_KERNEL_DEFCONFIG_FRAGMENT=firefly-linux.config

# parameter for GPT table
export RK_PARAMETER=parameter-firefly.txt

# Kernel dts
export RK_KERNEL_DTS=firefly-iboard-3588

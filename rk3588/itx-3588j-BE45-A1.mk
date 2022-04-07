CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Kernel defconfig fragment
export RK_KERNEL_DEFCONFIG_FRAGMENT=firefly-linux.config

# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu-fit.txt

# Kernel dts
export RK_KERNEL_DTS=rk3588-firefly-itx-3588j-mipi101-M101014-BE45-A1

# Set userdata partition type
export RK_USERDATA_FS_TYPE=ext4

# Set extboot
export FF_EXTBOOT=true

# PRODUCT MODEL
export RK_PRODUCT_MODEL=FIREFLY_3588

# recovery ramdisk
export RK_RECOVERY_RAMDISK=rk356x-recovery-arm64.cpio.gz

# Recovery config
export RK_CFG_RECOVERY=

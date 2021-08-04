#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly-rk3568
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=firefly_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3568-firefly-roc-pc

# Openwrt version select
export RK_OPENWRT_VERSION_SELECT=openwrt
# Openwrt defconfig
export RK_OPENWRT_DEFCONFIG=ROC-3568-PC_config
export RK_ROOTFS_SYSTEM=openwrt

# parameter for GPT table
export RK_PARAMETER=parameter-openwrt.txt
# packagefile for make update image
export RK_PACKAGE_FILE=rk356x-package-file-openwrt

# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# recovery ramdisk
export RK_RECOVERY_RAMDISK=rk356x-recovery-arm64.cpio.gz
# Set userdata partition type
export RK_USERDATA_FS_TYPE=ext4
# kernel image format type: fit(flattened image tree)
export RK_KERNEL_FIT_ITS=bootramdisk.its

# Buildroot config
export RK_CFG_BUILDROOT=
# Recovery config
export RK_CFG_RECOVERY=rockchip_rk356x_recovery
#OEM config
export RK_OEM_DIR=
#userdata config
export RK_USERDATA_DIR=

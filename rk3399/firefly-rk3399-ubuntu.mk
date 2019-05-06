#!/bin/bash

# Target arch
export RK_ARCH=arm64
# Uboot defconfig
export RK_UBOOT_DEFCONFIG=firefly-rk3399
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=firefly_linux_defconfig
# Kernel dts
export RK_KERNEL_DTS=rk3399-firefly
# boot image type
export RK_BOOT_IMG=boot.img
# kernel image path
export RK_KERNEL_IMG=kernel/arch/arm64/boot/Image
# parameter for GPT table
export RK_PARAMETER=parameter-ubuntu.txt
# sd_parameter for GPT table
export RK_SD_PARAMETER=parameter-recovery.txt
# packagefile for make update image 
export RK_PACKAGE_FILE=rk3399-ubuntu-package-file
# packagefile for make sdupdate image
export RK_SD_PACKAGE_FILE=rk3399-recovery-package-file
# Buildroot config
export RK_CFG_BUILDROOT=rockchip_rk3399
# Recovery config
export RK_CFG_RECOVERY=
# ramboot config
export RK_CFG_RAMBOOT=
# Pcba config
export RK_CFG_PCBA=rockchip_rk3399_pcba
# Build jobs
export RK_JOBS=8
# target chip
export RK_TARGET_PRODUCT=rk3399
# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# rootfs image path
export RK_ROOTFS_IMG=ubunturootfs/rk3399_ubuntu18.04_LXDE.img
# Set oem partition type, including ext2 squashfs
export RK_OEM_FS_TYPE=ext2
# Set userdata partition type, including ext2, fat
export RK_USERDATA_FS_TYPE=ext2
# Set flash type. support <emmc, nand, spi_nand, spi_nor>
export RK_STORAGE_TYPE=emmc
#OEM config
export RK_OEM_DIR=
#userdata config
export RK_USERDATA_DIR=
#misc image
export RK_MISC=wipe_all-misc.img
#choose enable distro module
export RK_DISTRO_MODULE="--wifi --audio"

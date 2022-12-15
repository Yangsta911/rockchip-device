#!/bin/bash

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)
BOARD_CONFIG=$TOP_DIR/device/rockchip/.BoardConfig.mk
CFG_DIR=$TOP_DIR/device/rockchip
ROCKDEV=$TOP_DIR/rockdev
[ -f $BOARD_CONFIG ] && source $BOARD_CONFIG
source $TOP_DIR/device/rockchip/common/Version.mk
PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_PARAMETER
SD_PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_SD_PARAMETER

NPROC=`nproc`
export RK_JOBS=$NPROC

if [ ! -d "$TOP_DIR/rockdev/pack" ];then
	mkdir -p rockdev/pack
fi

function usage()
{
	echo "Usage: build.sh [OPTIONS]"
	echo "Available options:"
	echo "*.mk               -switch to specified board config"
	echo "uboot              -build uboot"
	echo "spl                -build spl"
	echo "kernel             -build kernel"
	echo "modules            -build kernel modules"
	echo "toolchain          -build toolchain"
	echo "extboot            -build extlinux boot.img, boot from EFI partition"
	echo "rootfs             -build default rootfs, currently build buildroot as default"
	echo "buildroot          -build buildroot rootfs"
	echo "ramboot            -build ramboot image"
	echo "multi-npu_boot     -build boot image for multi-npu board"
	echo "yocto              -build yocto rootfs"
	echo "debian             -build debian9 stretch rootfs"
	echo "distro             -build debian10 buster rootfs"
	echo "pcba               -build pcba"
	echo "recovery           -build recovery"
	echo "all                -build uboot, kernel, rootfs, recovery image"
	echo "cleanall           -clean uboot, kernel, rootfs, recovery"
	echo "firmware           -pack all the image we need to boot up system"
	echo "sdupdateimg        -pack sdupdate image"
	echo "updateimg [-p]     -pack update image; [-p] compress"
	echo "sdbootimg [-p]     -pack sdboot image; [-p] compress"
	echo "otapackage         -pack ab update otapackage image"
	echo "save               -save images, patches, commands used to debug"
	echo "allsave            -build all & firmware & updateimg & save"
	echo ""
	echo "Default option is 'allsave'."
}

function build_extboot() {

    build_kernel

	BOOT=${TOP_DIR}/kernel/extboot.img
	rm -rf ${BOOT}

	echo -e "\e[36m Generate extLinuxBoot image start\e[0m"

	# 100 Mb
	mkfs.vfat -n "EFI" -S 512 -C ${BOOT} $((30 * 1024))

	echo "label kernel-4.4" > temp.conf
	echo "    kernel /Image" >> temp.conf
	echo "    fdt /${RK_KERNEL_DTS}.dtb" >> temp.conf

	mmd -i ${BOOT} ::/extlinux
	mcopy -i ${BOOT} -s temp.conf ::/extlinux/extlinux.conf
	mcopy -i ${BOOT} -s ${TOP_DIR}/kernel/arch/${RK_ARCH}/boot/dts/rockchip/${RK_KERNEL_DTS}.dtb ::
	mcopy -i ${BOOT} -s ${TOP_DIR}/kernel/arch/${RK_ARCH}/boot/Image ::

	rm temp.conf

	echo -e "\e[36m Generate extLinux Boot image : ${BOOT} success! \e[0m"
}

function build_uboot(){
	echo "============Start build uboot============"
	echo "TARGET_UBOOT_CONFIG=$RK_UBOOT_DEFCONFIG"
	echo "========================================="
	rm -f u-boot/*_loader_*.bin
	cd u-boot && ./make.sh $RK_UBOOT_DEFCONFIG && cd -
	if [ $? -eq 0 ]; then
		echo "====Build uboot ok!===="
	else
		echo "====Build uboot failed!===="
		exit 1
	fi
}

function build_spl(){
	echo "============Start build spl============"
	echo "TARGET_SPL_CONFIG=$RK_SPL_DEFCONFIG"
	echo "========================================="
	if [ -f u-boot/*spl.bin ]; then
		rm u-boot/*spl.bin
	fi
	cd u-boot && ./make.sh $RK_SPL_DEFCONFIG && ./make.sh spl-s && cd -
	if [ $? -eq 0 ]; then
		echo "====Build spl ok!===="
	else
		echo "====Build spl failed!===="
		exit 1
	fi
}

function build_kernel(){
	echo "============Start build kernel============"
	echo "TARGET_ARCH          =$RK_ARCH"
	echo "TARGET_KERNEL_CONFIG =$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    =$RK_KERNEL_DTS"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT =$RK_KERNEL_DEFCONFIG_FRAGMENT"
	echo "=========================================="
	cd $TOP_DIR/kernel && make ARCH=$RK_ARCH $RK_KERNEL_DEFCONFIG $RK_KERNEL_DEFCONFIG_FRAGMENT && make ARCH=$RK_ARCH $RK_KERNEL_DTS.img -j$RK_JOBS && cd -
	if [ $? -eq 0 ]; then
		echo "====Build kernel ok!===="
	else
		echo "====Build kernel failed!===="
		exit 1
	fi
}

function build_modules(){
	echo "============Start build kernel modules============"
	echo "TARGET_ARCH          =$RK_ARCH"
	echo "TARGET_KERNEL_CONFIG =$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_CONFIG_FRAGMENT =$RK_KERNEL_DEFCONFIG_FRAGMENT"
	echo "=================================================="
	cd $TOP_DIR/kernel && make ARCH=$RK_ARCH $RK_KERNEL_DEFCONFIG $RK_KERNEL_DEFCONFIG_FRAGMENT && make ARCH=$RK_ARCH modules -j$RK_JOBS && cd -
	if [ $? -eq 0 ]; then
		echo "====Build kernel ok!===="
	else
		echo "====Build kernel failed!===="
		exit 1
	fi
}

function build_toolchain(){
	echo "==========Start build toolchain =========="
	echo "TARGET_TOOLCHAIN_CONFIG=$RK_CFG_TOOLCHAIN"
	echo "========================================="
	[[ $RK_CFG_TOOLCHAIN ]] \
		&& /usr/bin/time -f "you take %E to build toolchain" $COMMON_DIR/mk-toolchain.sh $BOARD_CONFIG \
		|| echo "No toolchain step, skip!"
	if [ $? -eq 0 ]; then
		echo "====Build toolchain ok!===="
	else
		echo "====Build toolchain failed!===="
		exit 1
	fi
}

function build_buildroot(){
	echo "==========Start build buildroot=========="
	echo "TARGET_BUILDROOT_CONFIG=$RK_CFG_BUILDROOT"
	echo "========================================="
	/usr/bin/time -f "you take %E to build builroot" $COMMON_DIR/mk-buildroot.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "====Build buildroot ok!===="
	else
		echo "====Build buildroot failed!===="
		exit 1
	fi
}

function build_ramboot(){
	echo "=========Start build ramboot========="
	echo "TARGET_RAMBOOT_CONFIG=$RK_CFG_RAMBOOT"
	echo "====================================="
	/usr/bin/time -f "you take %E to build ramboot" $COMMON_DIR/mk-ramdisk.sh ramboot.img $RK_CFG_RAMBOOT
	if [ $? -eq 0 ]; then
		echo "====Build ramboot ok!===="
	else
		echo "====Build ramboot failed!===="
		exit 1
	fi
}

function build_multi-npu_boot(){
	if [ -z "$RK_MULTINPU_BOOT" ]; then
		echo "=========Please set 'RK_MULTINPU_BOOT=y' in BoardConfig.mk========="
		exit 1
	fi
	echo "=========Start build multi-npu boot========="
	echo "TARGET_RAMBOOT_CONFIG=$RK_CFG_RAMBOOT"
	echo "====================================="
	/usr/bin/time -f "you take %E to build multi-npu boot" $COMMON_DIR/mk-multi-npu_boot.sh
	if [ $? -eq 0 ]; then
		echo "====Build multi-npu boot ok!===="
	else
		echo "====Build multi-npu boot failed!===="
		exit 1
	fi
}

function build_yocto(){
	if [ -z "$RK_YOCTO_MACHINE" ]; then
		echo "This board doesn't support yocto!"
		exit 1
	fi

	echo "=========Start build ramboot========="
	echo "TARGET_MACHINE=$RK_YOCTO_MACHINE"
	echo "====================================="

	cd yocto
	ln -sf $RK_YOCTO_MACHINE.conf build/conf/local.conf
	source oe-init-build-env
	cd ..
	bitbake core-image-minimal -r conf/include/rksdk.conf

	if [ $? -eq 0 ]; then
		echo "====Build yocto ok!===="
	else
		echo "====Build yocto failed!===="
		exit 1
	fi
}

function build_debian(){
	cd debian

	if [ "$RK_ARCH" == "arm" ]; then
		ARCH=armhf
	fi
	if [ "$RK_ARCH" == "arm64" ]; then
		ARCH=arm64
	fi

	if [ ! -e linaro-stretch-alip-*.tar.gz ]; then
		echo "\033[36m Run mk-base-debian.sh first \033[0m"
		RELEASE=stretch TARGET=desktop ARCH=$ARCH ./mk-base-debian.sh
	fi

	VERSION=debug ARCH=$ARCH ./mk-rootfs-stretch.sh

	./mk-image.sh
	cd ..
	if [ $? -eq 0 ]; then
		echo "====Build Debian9 ok!===="
	else
		echo "====Build Debian9 failed!===="
		exit 1
	fi
}

function build_distro(){
	echo "===========Start build debian==========="
	echo "TARGET_ARCH=$RK_ARCH"
	echo "RK_DISTRO_DEFCONFIG=$RK_DISTRO_DEFCONFIG"
	echo "========================================"
	cd distro && make $RK_DISTRO_DEFCONFIG && /usr/bin/time -f "you take %E to build debian" $TOP_DIR/distro/make.sh && cd -
	if [ $? -eq 0 ]; then
		echo "====Build debian ok!===="
	else
		echo "====Build debian failed!===="
		exit 1
	fi
}

function build_rootfs(){

	case "$1" in
		yocto)
			build_yocto
			ROOTFS_IMG=yocto/build/tmp/deploy/images/$RK_YOCTO_MACHINE/rootfs.img
			;;
		debian)
			build_debian
			ROOTFS_IMG=debian/linaro-rootfs.img
			;;
		distro)
			build_distro
			ROOTFS_IMG=yocto/output/images/rootfs.$RK_ROOTFS_TYPE
			;;
		*)
			if [ -n $RK_CFG_BUILDROOT ];then
				build_buildroot
				ROOTFS_IMG=buildroot/output/$RK_CFG_BUILDROOT/images/rootfs.$RK_ROOTFS_TYPE
			fi
			;;
	esac

	[ -z "$ROOTFS_IMG" ] && return

	if [ ! -f "$ROOTFS_IMG" ]; then
		echo "$ROOTFS_IMG not generated?"
	else
		mkdir -p ${RK_ROOTFS_IMG%/*}
		rm -f $RK_ROOTFS_IMG
		ln -rsf $TOP_DIR/$ROOTFS_IMG $RK_ROOTFS_IMG
	fi
}

function build_recovery(){
	echo "==========Start build recovery=========="
	echo "TARGET_RECOVERY_CONFIG=$RK_CFG_RECOVERY"
	echo "========================================"
	/usr/bin/time -f "you take %E to build recovery" $COMMON_DIR/mk-ramdisk.sh recovery.img $RK_CFG_RECOVERY
	if [ $? -eq 0 ]; then
		echo "====Build recovery ok!===="
	else
		echo "====Build recovery failed!===="
		exit 1
	fi
}

function build_pcba(){
	echo "==========Start build pcba=========="
	echo "TARGET_PCBA_CONFIG=$RK_CFG_PCBA"
	echo "===================================="
	/usr/bin/time -f "you take %E to build pcba" $COMMON_DIR/mk-ramdisk.sh pcba.img $RK_CFG_PCBA
	if [ $? -eq 0 ]; then
		echo "====Build pcba ok!===="
	else
		echo "====Build pcba failed!===="
		exit 1
	fi
}

function build_all(){
	echo "============================================"
	echo "TARGET_ARCH=$RK_ARCH"
	echo "TARGET_PLATFORM=$RK_TARGET_PRODUCT"
	echo "TARGET_UBOOT_CONFIG=$RK_UBOOT_DEFCONFIG"
	echo "TARGET_SPL_CONFIG=$RK_SPL_DEFCONFIG"
	echo "TARGET_KERNEL_CONFIG=$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS=$RK_KERNEL_DTS"
	echo "TARGET_TOOLCHAIN_CONFIG=$RK_CFG_TOOLCHAIN"
	echo "TARGET_BUILDROOT_CONFIG=$RK_CFG_BUILDROOT"
	echo "TARGET_RECOVERY_CONFIG=$RK_CFG_RECOVERY"
	echo "TARGET_PCBA_CONFIG=$RK_CFG_PCBA"
	echo "TARGET_RAMBOOT_CONFIG=$RK_CFG_RAMBOOT"
	echo "============================================"

	#note: if build spl, it will delete loader.bin in uboot directory,
	# so can not build uboot and spl at the same time.
	if [ -z $RK_SPL_DEFCONFIG ]; then
		build_uboot
	else
		build_spl
	fi

	build_kernel
	build_toolchain && \
	build_rootfs ${RK_ROOTFS_SYSTEM:-buildroot}
	build_recovery
	build_ramboot
}

function build_cleanall(){
	echo "clean uboot, kernel, rootfs, recovery"
	cd $TOP_DIR/u-boot/ && make distclean && cd -
	cd $TOP_DIR/kernel && make distclean && cd -
	rm -rf $TOP_DIR/buildroot/output
	rm -rf $TOP_DIR/yocto/build
	rm -rf $TOP_DIR/distro/output
	rm -rf $TOP_DIR/debian/binary
}

function build_firmware(){
	./mkfirmware.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
		echo "Make image ok!"
	else
		echo "Make image failed!"
		exit 1
	fi
}


function gen_file_name() {
	local day=$(date +%y%m%d)
	#local time=$(date +%H%M)
	local os_all="buildroot debian ubuntu UnionTech UniKylin centos"

	local model=$(basename $(realpath ${BOARD_CONFIG}) .mk)
	local os_mk=$(echo $model | egrep -io ${os_all// /|} || true)
	# Set the string before os name in the BOARD_CONFIG file name as the model name
	[[ -n "$os_mk" ]] && model=${model/-$os_mk*/}
	IMGNAME=${model^^}

	# Set the string before first "_" in the rootfs file name as the system name
	# OSName_xxxx_vx.x.x.img"
	local rootfs=$(basename $(realpath $TOP_DIR/rockdev/rootfs.img))
	#remove suffix, get string before first "-" or "_"
	local os_name=$(echo ${rootfs%.*} | sed 's/[-_].*//')
	if [[ ${os_name^^} == "ROOTFS" ]] || [[ ${os_name^^} == "SYSTEM" ]]; then
		os_name=${os_mk}
	fi

	[[ -z "$os_name" ]] && os_name="Linux"

	#Uper first letter
	IMGNAME+=_$(echo ${os_name,,} | sed 's/./\u&/')

	#local os_mode=$(echo $rootfs | egrep -io "desktop|minimal|server" || true)
	local os_mode=$(echo $rootfs | egrep -io "gnome|xfce|minimal|server" || true)
	[[ -n "$os_mode" ]] && IMGNAME+=-$(echo ${os_mode,,} | sed 's/./\u&/')

	os_version=$(echo $rootfs | sed -n 's/.*[-_]\([vV][0-9.a-zA-Z]*\(\-[0-9]\{1,\}\)\{,1\}\)[-_\.].*/\1/p')
	if [[ -z "$os_version" ]]; then
		#get date string in rootfs as rootfs version
		os_version=$(echo $rootfs | sed -n 's/.*[-_]\(20[0-9]\{2,\}[-_.0-9]*\)[-_.].*/\1/p')
	fi
	if [[ -n "$os_version" ]]; then
		os_version=${os_version,,}
		#delete . - _ v
		os_version=${os_version/v/r}
		os_version=$(echo $os_version | sed 's/[-_\.]//g')
		IMGNAME+=-${os_version}
	fi

	local sdk_version=""
	local manifest=$(realpath ${TOP_DIR}/.repo/manifest.xml)
	if [[ -f $manifest ]]; then
		manifest=$(basename $(realpath ${TOP_DIR}/.repo/manifest.xml) .xml)
		sdk_version=$(echo $manifest | sed -n 's/.*[-_]\([vV][0-9.a-zA-Z]*\).*/\1/p')
		IMGNAME+=_${sdk_version}
	fi

	if [ -n "$1" ];then
		IMGNAME+=_${1}
	fi

	#IMGNAME+=_${day}-${time}.img
	IMGNAME+=_${day}.img

	echo -e "File name is \e[36m $IMGNAME\e[0m"
	if [ "$rename" == "0" ];then
		:
	else
		read -t 10 -e -p "Rename the file? [N|y]" ANS || :
		ANS=${ANS:-n}

		case $ANS in
				Y|y|yes|YES|Yes) rename=1;;
				N|n|no|NO|No) rename=0;;
				*) rename=0;;
		esac
	fi

	if [[ ${rename} == "1" ]]; then
		read -e -p "Enter new file name: " -i $IMGNAME newname
		IMGNAME=$newname
	fi
}


function build_sdbootimg(){
	packm="unpack"
	[[ -n "$1" ]] && [[ $1 != "-p" ]] && usage 
	[[ -n "$1" ]] && packm="pack"

	gen_file_name SDBOOT

	if [ $packm == "pack" ];then
		cd rockdev && ./version.sh $IMGNAME init && cd -
	fi

	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware

	echo "Make sdboot.img"
	cd $PACK_TOOL_DIR/rockdev && ./mksdbootimg.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/sdboot.img $IMAGE_PATH/pack/$IMGNAME
	if [ $? -eq 0 ]; then
		echo "Make sdboot image ok!"
		echo -e "\e[36m $IMAGE_PATH/pack/$IMGNAME \e[0m"
	else
	   echo "Make sdboot image failed!"
	   exit 1
	fi
	if [ $packm == "pack" ];then
		cd $TOP_DIR/rockdev \
		&& ./version.sh $IMGNAME pack $2 && cd -
	fi
}

function build_updateimg(){
	packm="unpack"
	[[ -n "$1" ]] && [[ $1 != "-p" ]] && usage 
	[[ -n "$1" ]] && packm="pack"

	gen_file_name 

	if [ $packm == "pack" ];then
		cd $TOP_DIR/rockdev \
		&& ./version.sh $IMGNAME init $2 && cd -
	fi

	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware
	if [ "$RK_LINUX_AB_ENABLE"x = "true"x ];then
		echo "Make Linux a/b update.img."
		build_otapackage
		source_package_file_name=`ls -lh $PACK_TOOL_DIR/rockdev/package-file | awk -F ' ' '{print $NF}'`
		cd $PACK_TOOL_DIR/rockdev && ln -fs "$source_package_file_name"-ab package-file && ./mkupdate.sh && cd -
		mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH/update_ab.img
		cd $PACK_TOOL_DIR/rockdev && ln -fs $source_package_file_name package-file && cd -
		if [ $? -eq 0 ]; then
			echo "Make Linux a/b update image ok!"
		else
			echo "Make Linux a/b update image failed!"
			exit 1
		fi

    else
	echo "Make update.img"
	cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH/pack/$IMGNAME
	rm -rf $IMAGE_PATH/update.img
	if [ $? -eq 0 ]; then
	   echo "Make update image ok!"
	   echo -e "\e[36m $IMAGE_PATH/pack/$IMGNAME \e[0m"
	else
	   echo "Make update image failed!"
	   exit 1
	fi

	if [ $packm == "pack" ];then
		cd $TOP_DIR/rockdev && ./version.sh $IMGNAME pack && cd -
	fi
    fi
}

function build_sdupdateimg(){

	gen_file_name sdupdate

	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware

	echo "Make sdupdate.img"
	if [ -f $SD_PARAMETER ]
	then
		echo -n "create parameter..."
		ln -s -f $SD_PARAMETER $ROCKDEV/parameter.txt
		echo "done."
	else
		echo -e "\e[31m error: $SD_PARAMETER not found! \e[0m"
		exit 1
	fi

	if [[ x"$RK_SD_PACKAGE_FILE" != x ]];then
		RK_PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
		cd $RK_PACK_TOOL_DIR
		rm -f package-file
		ln -sf $RK_SD_PACKAGE_FILE package-file
	fi

	cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH/pack/$IMGNAME
	rm -rf $IMAGE_PATH/update.img

	if [ $? -eq 0 ]; then
	   echo "Make sdupdate image ok!"
	   echo -e "\e[36m $IMAGE_PATH/pack/$IMGNAME \e[0m"
	else
	   echo "Make sdupdate image failed!"
	fi

	if [ -f $PARAMETER ]
	then
		ln -s -f $PARAMETER $ROCKDEV/parameter.txt
	fi

	if [[ x"$RK_PACKAGE_FILE" != x ]];then
		RK_PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
		cd $RK_PACK_TOOL_DIR
		rm -f package-file
		ln -sf $RK_PACKAGE_FILE package-file
	fi
}

function build_otapackage(){
	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware

	echo "Make ota ab update.img"
	source_package_file_name=`ls -lh $PACK_TOOL_DIR/rockdev/package-file | awk -F ' ' '{print $NF}'`
	cd $PACK_TOOL_DIR/rockdev && ln -fs "$source_package_file_name"-ota package-file && ./mkupdate.sh && cd -
	mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH/update_ota.img
	cd $PACK_TOOL_DIR/rockdev && ln -fs $source_package_file_name package-file && cd -
	if [ $? -eq 0 ]; then
		echo "Make update ota ab image ok!"
	else
		echo "Make update ota ab image failed!"
		exit 1
	fi
}

function build_save(){
	IMAGE_PATH=$TOP_DIR/rockdev
	DATE=$(date  +%Y%m%d.%H%M)
	STUB_PATH=Image/"$RK_KERNEL_DTS"_"$DATE"_RELEASE_TEST
	STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"
	export STUB_PATH=$TOP_DIR/$STUB_PATH
	export STUB_PATCH_PATH=$STUB_PATH/PATCHES
	mkdir -p $STUB_PATH

	#Generate patches
	$TOP_DIR/.repo/repo/repo forall -c "$TOP_DIR/device/rockchip/common/gen_patches_body.sh"

	#Copy stubs
	$TOP_DIR/.repo/repo/repo manifest -r -o $STUB_PATH/manifest_${DATE}.xml
	mkdir -p $STUB_PATCH_PATH/kernel
	cp $TOP_DIR/kernel/.config $STUB_PATCH_PATH/kernel
	cp $TOP_DIR/kernel/vmlinux $STUB_PATCH_PATH/kernel
	mkdir -p $STUB_PATH/IMAGES/
	cp $IMAGE_PATH/* $STUB_PATH/IMAGES/

	#Save build command info
	echo "UBOOT:  defconfig: $RK_UBOOT_DEFCONFIG" >> $STUB_PATH/build_cmd_info
	echo "KERNEL: defconfig: $RK_KERNEL_DEFCONFIG, dts: $RK_KERNEL_DTS" >> $STUB_PATH/build_cmd_info
	echo "BUILDROOT: $RK_CFG_BUILDROOT" >> $STUB_PATH/build_cmd_info

}

function build_allsave(){
	build_all
	build_firmware
	build_updateimg
	build_save
}
#=========================
# build targets
#=========================

if echo $@|grep -wqE "help|-h"; then
	usage
	exit 0
fi

OPTIONS="$@"
for option in ${OPTIONS:-allsave}; do
	echo "processing option: $option"
	case $option in
		*.mk)
			if [ -f $option ]; then
				CONF=${option}
			else
				CONF=$(find $CFG_DIR -name $option)
				echo "switching to board: $CONF"
				if [ ! -f $CONF ]; then
					echo "not exist!"
					exit 1
				fi
			fi

		    ln -rsf $CONF $BOARD_CONFIG

			unset RK_PACKAGE_FILE
			source $CONF
			if [[ x"$RK_PACKAGE_FILE" != x ]];then
				PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
				cd $PACK_TOOL_DIR
				rm -f package-file
				ln -sf $RK_PACKAGE_FILE package-file
			fi
    
		    MKUPDATE_FILE=${RK_TARGET_PRODUCT}-mkupdate.sh 
		    if [[ x"$MKUPDATE_FILE" != x-mkupdate.sh ]];then
				PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware/rockdev/
				cd $PACK_TOOL_DIR
				rm -f mkupdate.sh
				ln -sf $MKUPDATE_FILE mkupdate.sh
			fi
			;;
		buildroot|debian|distro|yocto)
			build_rootfs $option
			;;
		*)
			shift
			eval build_$option $@ || usage
			;;
	esac
done

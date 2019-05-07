#!/bin/bash

CMD=`realpath $0`
COMMON_DIR=`dirname $CMD`
TOP_DIR=$(realpath $COMMON_DIR/../../..)
BOARD_CONFIG=$TOP_DIR/device/rockchip/.BoardConfig.mk
CFG_DIR=$TOP_DIR/device/rockchip
ROCKDEV=$TOP_DIR/rockdev
source $BOARD_CONFIG
source $TOP_DIR/device/rockchip/common/Version.mk
PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_PARAMETER
SD_PARAMETER=$TOP_DIR/device/rockchip/$RK_TARGET_PRODUCT/$RK_SD_PARAMETER

 NPROC=`nproc`
 export RK_JOBS=$NPROC

if [ ! -n "$1" ];then
	echo "build all and save all as default"
	BUILD_TARGET=allsave
else
	BUILD_TARGET=$1
   	NEW_BOARD_CONFIG=$(find $CFG_DIR -name "$1")
fi

if [ ! -d "rockdev/pack" ];then
	mkdir rockdev/pack
fi

usage()
{
	echo "====USAGE: build.sh modules===="
	echo "uboot              -build uboot"
	echo "kernel             -build kernel"
	echo "modules            -build kernel modules"
	echo "extboot            -build extlinux boot.img, boot from EFI partition"
	echo "rootfs             -build default rootfs, currently build buildroot as default"
	echo "buildroot          -build buildroot rootfs"
	echo "ramboot            -build ramboot image"
	echo "multi-npu_boot     -build boot image for multi-npu board"
	echo "yocto              -build yocto rootfs"
	echo "debian             -build debian rootfs"
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
	echo "default            -build all modules"
	echo "BoardConfig Board  -select Board and it's BoardConfig.mk   "
	exit
}

function build_extboot_image() {

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
	# build uboot
	echo "============Start build uboot============"
	echo "TARGET_UBOOT_CONFIG=$RK_UBOOT_DEFCONFIG"
	echo "========================================="
	if [ -f u-boot/*_loader_*.bin ]; then
		rm u-boot/*_loader_*.bin
	fi
	cd u-boot && ./make.sh $RK_UBOOT_DEFCONFIG && cd -
	if [ $? -eq 0 ]; then
		echo "====Build uboot ok!===="
	else
		echo "====Build uboot failed!===="
		exit 1
	fi
}

function build_kernel(){
	# build kernel
	echo "============Start build kernel============"
	echo "TARGET_ARCH          =$RK_ARCH"
	echo "TARGET_KERNEL_CONFIG =$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS    =$RK_KERNEL_DTS"
	echo "=========================================="
	cd $TOP_DIR/kernel && make ARCH=$RK_ARCH $RK_KERNEL_DEFCONFIG && make ARCH=$RK_ARCH $RK_KERNEL_DTS.img -j$RK_JOBS && cd -
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
	echo "=================================================="
	cd $TOP_DIR/kernel && make ARCH=$RK_ARCH $RK_KERNEL_DEFCONFIG && make ARCH=$RK_ARCH modules -j$RK_JOBS && cd -
	if [ $? -eq 0 ]; then
		echo "====Build kernel ok!===="
	else
		echo "====Build kernel failed!===="
		exit 1
	fi
}

function build_buildroot(){
	# build buildroot
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
	# build ramboot image
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

function build_rootfs(){
	build_buildroot
}

function build_yocto(){
	echo "we don't support yocto at this time"
}

function build_debian(){
        # build debian
        echo "===========Start build debian==========="
	echo "TARGET_ARCH=$RK_ARCH"
        echo "RK_DISTRO_DEFCONFIG=$RK_DISTRO_DEFCONFIG"
	echo "========================================"
	/usr/bin/time -f "you take %E to build debian" $TOP_DIR/distro/make.sh $RK_DISTRO_DEFCONFIG
        if [ $? -eq 0 ]; then
                echo "====Build debian ok!===="
        else
                echo "====Build debian failed!===="
                exit 1
        fi
}

function build_recovery(){
	# build recovery
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
	# build pcba
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
	echo "TARGET_KERNEL_CONFIG=$RK_KERNEL_DEFCONFIG"
	echo "TARGET_KERNEL_DTS=$RK_KERNEL_DTS"
	echo "TARGET_BUILDROOT_CONFIG=$RK_CFG_BUILDROOT"
	echo "TARGET_RECOVERY_CONFIG=$RK_CFG_RECOVERY"
	echo "TARGET_PCBA_CONFIG=$RK_CFG_PCBA"
	echo "TARGET_RAMBOOT_CONFIG=$RK_CFG_RAMBOOT"
	echo "============================================"
	build_uboot
	build_kernel
	build_rootfs
	build_recovery
	build_ramboot
}

function clean_all(){
	echo "clean uboot, kernel, rootfs, recovery"
	cd $TOP_DIR/u-boot/ && make distclean && cd -
	cd $TOP_DIR/kernel && make distclean && cd -
	rm -rf buildroot/out
}

function build_firmware(){
	# mkfirmware.sh to genarate image
	./mkfirmware.sh $BOARD_CONFIG
	if [ $? -eq 0 ]; then
	    echo "Make image ok!"
	else
	    echo "Make image failed!"
	    exit 1
	fi
}


function gen_file_name() {
	day=$(date +%Y%m%d)
	time=$(date +%H%M)

	typeset -u board
	board=$(basename $(readlink ${BOARD_CONFIG}))
	board=${board%%.MK}
		
	rootfs=$(ls -l rockdev/ | grep rootfs.img | awk -F '/' '{print $(NF)}'|awk -F '_' '{print $2}')

	board=${board}${rootfs}-GPT
	if [ -n "$1" ];then
		board=$board-$1
	fi

	echo -e "File name is \e[36m $board \e[0m"
	read -t 10 -e -p "Rename the file? [N|y]" ANS 
	ANS=${ANS:-n}
	
	case $ANS in
			Y|y|yes|YES|Yes) rename=1;;
			N|n|no|NO|No) rename=0;;
			*) rename=0;;
	esac
	if [[ ${rename} == "1" ]]; then
		read -e -p "Enter new file name: " IMGNAME
		IMGNAME=$IMGNAME
	fi
	IMGNAME=${IMGNAME:-$board}
	IMGNAME=${IMGNAME}-${day}-${time}.img
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
		cd rockdev && ./version.sh $IMGNAME pack && cd -
	fi
}

function build_updateimg(){
	packm="unpack"
	[[ -n "$1" ]] && [[ $1 != "-p" ]] && usage 
	[[ -n "$1" ]] && packm="pack"

	gen_file_name 

	if [ $packm == "pack" ];then
		cd rockdev && ./version.sh $IMGNAME init $2 && cd -
	fi

	IMAGE_PATH=$TOP_DIR/rockdev
	PACK_TOOL_DIR=$TOP_DIR/tools/linux/Linux_Pack_Firmware
    if [ "$RK_LINUX_AB_ENABLE"x = "true"x ];then
        echo "Make Linux a/b update.img."
	    build_ota_ab_updateimg
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
		cd rockdev && ./version.sh $IMGNAME pack && cd -
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
	rm -rf $IMAGE_PATH/sdupdate.img

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

function build_ota_ab_updateimg(){
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

function build_all_save(){
	build_all
	build_firmware
	build_updateimg
	build_save
}
#=========================
# build target
#=========================
if [ $BUILD_TARGET == uboot ];then
    build_uboot
    exit 0
elif [ $BUILD_TARGET == kernel ];then
    build_kernel
    exit 0
elif [ $BUILD_TARGET == extboot ];then
    build_extboot_image
    exit 0
elif [ $BUILD_TARGET == modules ];then
    build_modules
    exit 0
elif [ $BUILD_TARGET == rootfs ];then
    build_rootfs
    exit 0
elif [ $BUILD_TARGET == buildroot ];then
    build_buildroot
    exit 0
elif [ $BUILD_TARGET == recovery ];then
    build_kernel
    build_recovery
    exit 0
elif [ $BUILD_TARGET == ramboot ];then
    build_ramboot
    exit 0
elif [ $BUILD_TARGET == multi-npu_boot ];then
    build_multi-npu_boot
    exit 0
elif [ $BUILD_TARGET == pcba ];then
    build_pcba
    exit 0
elif [ $BUILD_TARGET == yocto ];then
    build_yocto
    exit 0
elif [ $BUILD_TARGET == debian ];then
    build_debian
    exit 0
elif [ $BUILD_TARGET == updateimg ];then
    build_updateimg $2 $3
    exit 0
elif [ $BUILD_TARGET == sdbootimg ];then
    build_sdbootimg $2
    exit 0
elif [ $BUILD_TARGET == sdupdateimg ];then
    build_sdupdateimg
    exit 0
elif [ $BUILD_TARGET == otapackage ];then
    build_ota_ab_updateimg
    exit 0
elif [ $BUILD_TARGET == all ];then
    build_all
    exit 0
elif [ $BUILD_TARGET == firmware ];then
    build_firmware
    exit 0
elif [ $BUILD_TARGET == save ];then
    build_save
    exit 0
elif [ $BUILD_TARGET == cleanall ];then
    clean_all
    exit 0
elif [ $BUILD_TARGET == --help ] || [ $BUILD_TARGET == help ] || [ $BUILD_TARGET == -h ];then
    usage
    exit 0
elif [ $BUILD_TARGET == allsave ];then
    build_all_save
    exit 0
elif [ -f $NEW_BOARD_CONFIG ];then
    if [ ! -n "$NEW_BOARD_CONFIG" ];then
	    echo "==============================="
	    echo "ERR:  $1 not found  "
    	    echo "Can't found build config, please check again"
	    echo "ls device/rockchip/rkxxxx"
	    usage
	    exit 1
	fi
    echo $NEW_BOARD_CONFIG
    rm -f $BOARD_CONFIG
    ln -s $NEW_BOARD_CONFIG $BOARD_CONFIG
	unset RK_PACKAGE_FILE
	source $NEW_BOARD_CONFIG
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
    exit 0
fi


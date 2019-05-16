#!/bin/bash

BOARD_CONFIG=device/rockchip/.BoardConfig.mk

#ROOTFS_PATH 跟文件系统的存放目录 /home/ssd/daijh/rootfs_public
ROOTFS_PATH=$TOP_DIR/rootfs_public


fun_mkfirmware() {
	source $BOARD_CONFIG
	if [ $RK_ARCH == arm64 ];then
		ARCH="arm64"
	elif [ $RK_ARCH == arm ];then
		ARCH="armhf"
	fi
	rootfs_file=$(echo $1 | awk -F '"' '{print $2}')

	cd device/rockchip/common

	linenumber=$(cat -n mkfirmware.sh | grep "ROOTFS_IMG=" |awk '{print $1}')
	str=""$linenumber"c ROOTFS_IMG=$ROOTFS_PATH/$rootfs_file"
	sed -i "$str" mkfirmware.sh
	./mkfirmware.sh
}

fun_config() {
	mk_file=$(echo $1 | awk -F '"' '{print $2}')
	mk_file="${mk_file}-ubuntu.mk"
	./build.sh $mk_file	
	source $BOARD_CONFIG
	cd kernel
	git checkout stable-4.4-${RK_TARGET_PRODUCT}-linux
	if [ $? -ne 0 ]; then
		exit -1
	fi
	cd ../u-boot
	git checkout stable-4.4-${RK_TARGET_PRODUCT}-linux
	if [ $? -ne 0 ]; then
		exit -1
	fi
	cd ..
}

echo_green_enter() {
	    echo -e "\033[32m$1\033[0m"
}

mk_path=device/rockchip
board_list=`ls $mk_path/rk3288 $mk_path/rk3399 | grep .mk | grep -E "3399|3288"`



for i in $board_list
do
	board1=${i%-*}
	kk=`echo $DIS1 | grep "!$board1!"`
	if [ $? -ne 0 ]; then
		DIS1="$DIS1 !?!$board1!?!"
		#DIS2为去掉重复项
		DIS2="$DIS2 $board1"
	fi
done

for i in $DIS2
do
	DIS3="$DIS3 $i '----------' OFF "
done

DISTROS=$(whiptail --title "Checklist Dialog" --checklist \
"选择需要编译的板型" 30 52 22 \
$DIS3 3>&1 1>&2 2>&3)
 
 exitstatus=$?
 if [ $exitstatus = 0 ]; then
	echo "Your favorite distros are:" $DISTROS    
 else
	exit -1
fi

ROOTFS_list=`ls $ROOTFS_PATH | grep .img`

for i in $ROOTFS_list
do
	ROOTFS_LIST="$ROOTFS_LIST $i '----------' OFF "
done

ROOTFS=$(whiptail --title "Checklist Dialog" --checklist \
"选择需要打包的根文件系统" 30 72 22 \
 $ROOTFS_LIST 3>&1 1>&2 2>&3)

exitstatus=$?
 if [ $exitstatus = 0 ]; then
	echo "Your favorite distros are:" $ROOTFS    
 else
	exit -1
fi

vim rockdev/tmp.txt

for d in $DISTROS
do
	cd $TOP_DIR
	fun_config $d
	bash ./build.sh kernel	#编译kernel
	if [ $? -ne 0 ]; then
		exit -1
	fi
	bash ./build.sh uboot	#编译uboot
	if [ $? -ne 0 ]; then
		exit -1
	fi
	for r in $ROOTFS
	do
		fun_mkfirmware $r
		./build.sh updateimg -p -n
	done
done


rm -rf $TOP_DIR/rockdev/tmp.txt

#fun_config $DISTROS $ROOTFS

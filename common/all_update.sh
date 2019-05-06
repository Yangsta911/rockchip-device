#!/bin/bash
BOARD_CONFIG=device/rockchip/.BoardConfig.mk
ROOTFS_PATH=/home/ssd/daijh/rootfs_public
TOP_DIR=$(pwd)
fun_mkfirmware() {
	source $BOARD_CONFIG
	if [ $RK_ARCH == arm64 ];then
		ARCH="arm64"
	elif [ $RK_ARCH == arm ];then
		ARCH="armhf"
	fi
	rootfs_file=$(echo $1 | awk -F '"' '{print $2}')
	if [ $rootfs_file == ubuntu18.04 ];then
		rootfs_file="ubuntu_18.04_$ARCH"
	elif [ $rootfs_file == ubuntu16.04 ];then
		rootfs_file="ubuntu_16.04_$ARCH"
	fi
	cd device/rockchip/common
	rootfs_file=$(ls $ROOTFS_PATH | grep $rootfs_file )
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
	git co stable-4.4-${RK_TARGET_PRODUCT}-linux
	if [ $? -ne 0 ]; then
		exit -1
	fi
	cd ../u-boot
	git co stable-4.4-${RK_TARGET_PRODUCT}-linux
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
#echo $board_list

for i in $board_list
do
	board=${i%-*}
	DIS="$DIS $board '----------' OFF "
done

DISTROS=$(whiptail --title "Checklist Dialog" --checklist \
"选择需要编译的板型" 30 42 22 \
$DIS 3>&1 1>&2 2>&3)
 
 exitstatus=$?
 if [ $exitstatus = 0 ]; then
	echo "Your favorite distros are:" $DISTROS    
 else
	exit -1
fi

ROOTFS=$(whiptail --title "Checklist Dialog" --checklist \
"选择需要打包的根文件系统" 15 32 9 \
"ubuntu18.04" "date:" OFF \
"ubuntu16.04" "date:" OFF 3>&1 1>&2 2>&3)

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
	./build.sh kernel
	if [ $? -ne 0 ]; then
		exit -1
	fi
	./build.sh uboot
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
